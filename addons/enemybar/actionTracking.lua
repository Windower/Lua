-- 8: casting start, 4: casting finish
-- 7: ws start, 11: npc tp finish
-- 7: ws start, 3: ws finish
-- 6: job ability
-- 9: item start, 5: item finish

--require('extdata')
res = require('resources')
vector = require('vectors')

tracked_actions = {}
tracked_enmity = {}
framerate = 75
clean_actions_delay = framerate
clean_actions_tick = clean_actions_delay

local function unpack_bits(data, start, stop)
    --credit: Byrth / SnickySnacks
    local newval = 0   
    local c_count = math.ceil(stop/8)
    while c_count >= math.ceil((start+1)/8) do
        local cur_val = data:byte(c_count)
        local scal = 256
        if c_count == math.ceil(stop/8) then
            cur_val = cur_val%(2^((stop-1)%8+1))
        end
        if c_count == math.ceil((start+1)/8) then
            cur_val = math.floor(cur_val/(2^(start%8)))
            scal = 2^(8-start%8)
        end
        newval = newval*scal + cur_val
        c_count = c_count - 1
    end
    return newval
end

function parse_action_packet(data)
    local data = data:sub(5)
    local ai = {
        actor_id = unpack_bits(data,8,40),
        category = unpack_bits(data,50,54),
        param = unpack_bits(data,54,70),
        target_id = unpack_bits(data,118,150),
        param2 = unpack_bits(data,181,198),
    }
    return ai
end

function looking_at(a, b)
	local h = a.facing % math.pi
	local h2 = (math.atan2(a.x-b.x,a.y-b.y) + math.pi/2) % math.pi
	--windower.add_to_chat(1,''..h..' =? '..h2)
	return math.abs(h-h2) < 0.15
end

function is_party_member(id)
	if id == windower.ffxi.get_player().id then return true end

	local party = windower.ffxi.get_party()
	for i=0, party.party1_count-1 do
		if party['p'..i].mob and party['p'..i].mob.id == id then return true end
	end
	for i=0, party.party2_count-1 do
		if party['a1'..i].mob and party['a1'..i].mob.id == id then return true end
	end
	for i=0, party.party3_count-1 do
		if party['a2'..i].mob and party['a2'..i].mob.id == id then return true end
	end

    return false
end

function handle_action_packet(id, data)
	if 0x028 == id then
		local ai = parse_action_packet(data)

		-- get the actors.
		local actor = windower.ffxi.get_mob_by_id(ai.actor_id)
		local target = windower.ffxi.get_mob_by_id(ai.target_id)

		-- We're really not going to be able to deal with this without the actor, return.
		if not actor then return end
		-- couldn't find the actor, let's just give some debug output.
		if not target then
			target = {name='Unknown (id:'..ai.target_id..')',id=ai.target_id}
		end

		local pc = nil
		local mob = nil
		if actor.is_npc and not target.is_npc then
			pc = target
			mob = actor
		elseif target.is_npc and not actor.is_npc then
			mob = target
			pc = actor
		end

		if pc and mob and is_party_member(pc.id) then
			-- we have npc/pc interaction
			if actor == mob or not tracked_enmity[mob.id] then
				if tracked_enmity[mob.id] and tracked_enmity[mob.id].pc then
					if tracked_enmity[mob.id].pc.id ~= pc.id then
						--windower.add_to_chat(1,'enmity changed: '..mob.name..' -> '..pc.name)
					end
				else
					--windower.add_to_chat(1,'enmity gained: '..mob.name..' -> '..pc.name)					
				end

				tracked_enmity[mob.id] = {pc=pc, mob=mob, time=os.time()}
			end
		end

		-- from here on, we don't care about non-actions/spells/items
		if not S{8,4,7,11,3,6,9,5}:contains(ai.category) then return end

		-- if it's a starting packet, the id is in param2
		local action_id = ai.param
		if S{8,7,9}:contains(ai.category) then
			action_id = ai.param2
		end

		-- find the action
		local action_map = nil
		if S{8,4}:contains(ai.category) then
			action_map = res.spells[action_id]
		elseif S{5,9}:contains(ai.category) then
			action_map = res.items[action_id]
		else
			if actor.is_npc then
				action_map = res.monster_abilities[action_id]
			else
				if ai.category == 6 then
					action_map = res.job_abilities[action_id]
				elseif S{3,7,11}:contains(ai.category) then
					action_map = res.weapon_skills[action_id]
				end
			end
		end
		-- couldn't find the action, let's just give some debug output.
		if not action_map then
			action_map = {en='Unknown (id:'..action_id..')'}
		end 

		tracked_actions[ai.actor_id] = {actor=actor, target=target, ability=action_map, complete=S{4,11,3,5,6}:contains(ai.category), time=os.time()}
		--windower.add_to_chat(1,''..mob.name..(not tracked_actions[ai.actor_id].complete and ' begins ' or ' finishes ')..action_map.en..' -> '..(target and target.name or '?'))
	end
end

function clean_tracked_actions()
	clean_actions_tick = clean_actions_tick - 1

	if clean_actions_tick > 0 then return end

	local time = os.time()
	for id,action in pairs(tracked_actions) do
		-- for incomplete items, timeout at 30s.
		if not action.complete and time - action.time > 30 then
			--windower.add_to_chat(1,'forgeting: '..action.actor.name..' performed '..action.ability.en..' -> '..(action.target and action.target.name or '?'))
			tracked_actions[id] = nil

		-- for complete actions, timeout at 3s.
		elseif action.complete and time - action.time > 3 then
			--windower.add_to_chat(1,'forgeting: '..action.actor.name..' performed '..action.ability.en..' -> '..(action.target and action.target.name or '?'))
			tracked_actions[id] = nil
		end
	end

	for id,enmity in pairs(tracked_enmity) do
		if enmity.pc and time - enmity.time > 3 then
			local mob = windower.ffxi.get_mob_by_id(enmity.mob.id)
			if not mob or mob.hpp == 0 then
				--windower.add_to_chat(1,'enemy dead: '..enmity.mob.name)
				tracked_enmity[id] = nil
			elseif not looking_at(mob, windower.ffxi.get_mob_by_id(enmity.pc.id)) then
				--windower.add_to_chat(1,'enemy no longer hates: '..enmity.mob.name..' -> '..enmity.pc.name)
				tracked_enmity[id].pc = nil
			end
		end
	end

	clean_actions_tick = clean_actions_delay
end

function reset_tracked_actions()
	tracked_actions = {}
end
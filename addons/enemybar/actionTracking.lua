-- 8: casting start, 4: casting finish
-- 7: ws start, 11: npc tp finish
-- 7: ws start, 3: ws finish
-- 6: job ability
-- 9: item start, 5: item finish

--require('extdata')
res = require('resources')
vector = require('vectors')
packets = require('packets')

tracked_actions = {}
tracked_enmity = {}
tracked_debuff = {}
framerate = 75
clean_actions_delay = framerate
clean_actions_tick = clean_actions_delay

function looking_at(a, b)
	local h = a.facing % math.pi
	local h2 = (math.atan2(a.x-b.x,a.y-b.y) + math.pi/2) % math.pi
	--windower.add_to_chat(1,''..h..' =? '..h2)
	return math.abs(h-h2) < 0.15
end

function is_party_member_or_pet(mob)
	if not mob then return false end
	if mob.id == windower.ffxi.get_player().id then return true end
	local is_pet = mob.is_npc and mob.charmed

	local party = windower.ffxi.get_party()
	for i=0, party.party1_count-1 do
		if is_pet then
			if party['p'..i].mob and party['p'..i].mob.pet_index == mob.index then return true end
		else
			if party['p'..i].mob and party['p'..i].mob.id == mob.id then return true end
		end
	end
	for i=0, party.party2_count-1 do
		if is_pet then
			if party['a1'..i].mob and party['a1'..i].mob.pet_index == mob.index then return true end
		else
			if party['a1'..i].mob and party['a1'..i].mob.id == mob.id then return true end
		end
	end
	for i=0, party.party3_count-1 do
		if is_pet then
			if party['a2'..i].mob and party['a2'..i].mob.pet_index == mob.index then return true end
		else
			if party['a2'..i].mob and party['a2'..i].mob.id == id then return true end
		end
	end

    return false
end

function handle_action_packet(id, data)
	if 0x028 == id then
		local ai = windower.packets.parse_action(data)

		track_enmity(ai)
		track_actions(ai)
		track_debuffs(ai)
	elseif 0x029 then
    	local message_id = data:unpack('H',0x19)
    	if not message_id then return end
    	message_id = message_id%32768
		local param_1 = data:unpack('I',0x0D)
    	local target_id = data:unpack('I',0x09)
		if S{204,206}:contains(message_id) then
			-- wears off message.
			local target = windower.ffxi.get_mob_by_id(target_id)
			if target and tracked_debuff[target.id]  then
				tracked_debuff[target.id][param_1] = nil
				--windower.add_to_chat(1,'debuff wears: '..res.buffs[p['Param 1']].en..' -> '..target.name)
			end
		end
	end
end

function track_enmity(ai)
	local actor = windower.ffxi.get_mob_by_id(ai.actor_id)
	if not actor then return end

	for i,t in ipairs(ai.targets) do
		local target = windower.ffxi.get_mob_by_id(t.id)
		if target then
			local pc = nil
			local mob = nil
			if actor.is_npc and not actor.charmed and (not target.is_npc or target.charmed) then
				pc = target
				mob = actor
			elseif (target.is_npc and not target.charmed) and (not actor.is_npc or target.charmed)  then
				mob = target
				pc = actor
			end

			if pc and mob and is_party_member_or_pet(pc) then
				-- we have npc/pc interaction
				-- if the actor is the npc, then we know there's enmity. Otherwise, if the target of the pc spell isn't tracked, it definitely hates the pc now.
				if actor == mob or not tracked_enmity[mob.id] then
					if tracked_enmity[mob.id] and tracked_enmity[mob.id].pc then
						if tracked_enmity[mob.id].pc.id ~= pc.id then
							--windower.add_to_chat(1,'enmity changed: '..mob.name..' -> '..pc.name)
						end
					else
						--windower.add_to_chat(1,'enmity gained: '..mob.name..' -> '..pc.name)					
					end

					tracked_enmity[mob.id] = {pc=pc, mob=mob, time=os.time()}

					-- if the actor is the npc, we don't care about the other targets. The first target is the one they targeted.
					if actor == mob then return end
				end
			end
		end
	end
end

function track_actions(ai)
	local actor = windower.ffxi.get_mob_by_id(ai.actor_id)
	if not actor then return end

	local target = windower.ffxi.get_mob_by_id(ai.targets[1].id)
	if not target then
		target = {name='Unknown (id:'..ai.targets[1].id, id=ai.targets[1].id}
	end

	-- if the category is not casting magic, jas, items or ws, don't bother.
	if not S{8,4,7,11,3,6,9,5}:contains(ai.category) then return end

	-- if it's a starting packet, the id is in param2
	local action_id = ai.param
	if S{8,7,9}:contains(ai.category) then
		action_id = ai.targets[1].actions[1].param
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
end

function track_debuffs(ai)
	check_conflicting_debuffs(ai)
	if S{8,7,6,9}:contains(ai.category) then return end

	for i,t in ipairs(ai.targets) do
		local target = windower.ffxi.get_mob_by_id(t.id)
		if target and target.is_npc and not target.charmed then

		    if S{2,252}:contains(t.actions[1].message) then
		        local spell = ai.param
		        local effect = res.spells[spell].status

		        if effect then
		            apply_debuff(target, effect, spell)
		        end
		        
		    -- Non-damaging spells
		    elseif S{75,236,237,268,270,271}:contains(t.actions[1].message) then
		        local effect = t.actions[1].param
		        local spell = ai.param
		        
		        --if res.spells[spell].status and res.spells[spell].status == effect then
		            apply_debuff(target, effect, spell)
		        --end
		    end
		end
	end
end

function apply_debuff(target, effect, spell)	
    if not tracked_debuff[target.id] then
        tracked_debuff[target.id] = {}
    end

    local overwrites = res.spells[spell].overwrites or {}
    if not did_overwrite(target, spell, overwrites) then
        return
    end

    tracked_debuff[target.id][effect] = {target=target,spell=spell,effect=effect,time=os.time(),duration=res.spells[spell].duration or 0,pos={x=target.x,y=target.y}}
    --windower.add_to_chat(1,'tracking debuff: '..res.buffs[effect].en..' -> '..target.name..' from '..res.spells[spell].en)
end

function did_overwrite(target, new, t)
    if not tracked_debuff[target.id] then
        return true
    end
    
    for effect, tracked in pairs(tracked_debuff[target.id]) do
        local old = res.spells[tracked.spell].overwrites or {}
        
        -- Check if there isn't a higher priority debuff active
        if table.length(old) > 0 then
            for _,v in ipairs(old) do
                if new == v then
    				--windower.add_to_chat(1,'NOT overwritten: '..res.buffs[effect].en..' -> '..target.name..' from '..res.spells[tracked.spell].en)
                    return false
                end
            end
        end
        
        -- Check if a lower priority debuff is being overwritten
        if table.length(t) > 0 then
            for _,v in ipairs(t) do
                if tracked.spell == v then
                    tracked_debuff[target.id][effect] = nil
    				--windower.add_to_chat(1,'overwritten: '..res.buffs[effect].en..' -> '..target.name..' from '..res.spells[tracked.spell].en)
                end
            end
        end
    end
    return true
end

function check_conflicting_debuffs(ai)
	local actor = windower.ffxi.get_mob_by_id(ai.actor_id)
	if not actor then return end
	if actor.is_npc then
		-- the actor is an npc, let's check if they're supposed to be asleep/petrified/terror'd
		local debuffs = tracked_debuff[actor.id]
		if not debuffs then return end

		for id,debuff in pairs(debuffs) do
			if S{2,19,7,28}:contains(id) then
				-- it was inactive, but now it's doing!
				tracked_debuff[actor.id][id] = nil
			end
			if math.abs(debuff.pos.x-actor.x)>0.5 or math.abs(debuff.pos.y-actor.y)>0.5 then
				-- it was locked in place, but now it's not!
				tracked_debuff[actor.id][id] = nil
			end
		end
	end
end

function clean_tracked_actions()
	clean_actions_tick = clean_actions_tick - 1

	if clean_actions_tick > 0 then return end

	local player = windower.ffxi.get_mob_by_target("me")
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
		if time - enmity.time > 3 then
			local mob = windower.ffxi.get_mob_by_id(enmity.mob.id)
			if not mob or mob.hpp == 0 then
				--windower.add_to_chat(1,'enemy dead: '..enmity.mob.name)
				tracked_enmity[id] = nil
			elseif mob.status == 0 then
				--windower.add_to_chat(1,'enemy idle: '..enmity.mob.name)
				tracked_enmity[id] = nil
			elseif enmity.pc and not looking_at(mob, windower.ffxi.get_mob_by_id(enmity.pc.id)) then
				--windower.add_to_chat(1,'enemy no longer hates: '..enmity.mob.name..' -> '..enmity.pc.name)
				tracked_enmity[id].pc = nil
			elseif get_distance(player, mob) > 50 then
				tracked_enmity[id] = nil
			end
		end
	end

	for id,debuffs in pairs(tracked_debuff) do
		local mob = windower.ffxi.get_mob_by_id(id)
		if not mob or mob.hpp == 0 then
			tracked_debuff[id] = nil
		else
			for i,debuff in ipairs(debuffs) do
				-- if the duration is much longer than +50%, let's assume it wore. 
				if time - debuff.time > debuff.duration * 1.5 then 
					tracked_debuff[id][debuff.effect] = nil
				end
			end
		end
	end

	clean_actions_tick = clean_actions_delay
end

function reset_tracked_actions()
	tracked_actions = {}
	tracked_enmity = {}
	tracked_debuff = {}
end
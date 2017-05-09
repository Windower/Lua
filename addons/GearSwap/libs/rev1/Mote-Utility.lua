-------------------------------------------------------------------------------------------------------------------
-- General utility functions that can be used by any job files.
-- Outside the scope of what the main include file deals with.
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Buff utility functions.
-------------------------------------------------------------------------------------------------------------------

local cancel_spells_to_check = S{'Sneak', 'Stoneskin', 'Spectral Jig', 'Trance', 'Monomi: Ichi', 'Utsusemi: Ichi'}
local cancel_types_to_check = S{'Waltz', 'Samba'}

-- Function to cancel buffs if they'd conflict with using the spell you're attempting.
-- Requirement: Must have Cancel addon installed and loaded for this to work.
function cancel_conflicting_buffs(spell, action, spellMap, eventArgs)
	if cancel_spells_to_check:contains(spell.english) or cancel_types_to_check:contains(spell.type) then
		if spell.action_type == 'Ability' then
			local abil_recasts = windower.ffxi.get_ability_recasts()
			if abil_recasts[spell.recast_id] > 0 then
				add_to_chat(123,'Abort: Ability waiting on recast.')
				eventArgs.cancel = true
				return
			end
		elseif spell.action_type == 'Magic' then
			local spell_recasts = windower.ffxi.get_spell_recasts()
			if spell_recasts[spell.recast_id] > 0 then
				add_to_chat(123,'Abort: Spell waiting on recast.')
				eventArgs.cancel = true
				return
			end
		end
		
		if spell.english == 'Spectral Jig' and buffactive.sneak then
			cast_delay(0.2)
			send_command('cancel sneak')
		elseif spell.english == 'Sneak' and spell.target.type == 'SELF' and buffactive.sneak then
			send_command('cancel sneak')
		elseif spell.english == ('Stoneskin') then
			send_command('@wait 1.0;cancel stoneskin')
		elseif spell.english:startswith('Monomi') then
			send_command('@wait 1.7;cancel sneak')
		elseif spell.english == 'Utsusemi: Ichi' then
			send_command('@wait 1.7;cancel copy image*')
		elseif (spell.english == 'Trance' or spell.type=='Waltz') and buffactive['saber dance'] then
			cast_delay(0.2)
			send_command('cancel saber dance')
		elseif spell.type=='Samba' and buffactive['fan dance'] then
			cast_delay(0.2)
			send_command('cancel fan dance')
		end
	end
end


-- Some mythics have special durations for level 1 and 2 aftermaths
local special_aftermath_mythics = S{'Tizona', 'Kenkonken', 'Murgleis', 'Yagrush', 'Carnwenhan', 'Nirvana', 'Tupsimati', 'Idris'}

-- Call from job_precast() to setup aftermath information for custom timers.
function custom_aftermath_timers_precast(spell)
    if spell.type == 'WeaponSkill' then
        info.aftermath = {}
        
        local relic_ws = data.weaponskills.relic[player.equipment.main] or data.weaponskills.relic[player.equipment.range]
        local mythic_ws = data.weaponskills.mythic[player.equipment.main] or data.weaponskills.mythic[player.equipment.range]
        local empy_ws = data.weaponskills.empyrean[player.equipment.main] or data.weaponskills.empyrean[player.equipment.range]
        
        if not relic_ws and not mythic_ws and not empy_ws then
            return
        end

        info.aftermath.weaponskill = spell.english
        info.aftermath.duration = 0
        
        info.aftermath.level = math.floor(player.tp / 1000)
        if info.aftermath.level == 0 then
            info.aftermath.level = 1
        end
        
        if spell.english == relic_ws then
            info.aftermath.duration = math.floor(0.2 * player.tp)
            if info.aftermath.duration < 20 then
                info.aftermath.duration = 20
            end
        elseif spell.english == empy_ws then
            -- nothing can overwrite lvl 3
            if buffactive['Aftermath: Lv.3'] then
                return
            end
            -- only lvl 3 can overwrite lvl 2
            if info.aftermath.level ~= 3 and buffactive['Aftermath: Lv.2'] then
                return
            end
            
            -- duration is based on aftermath level
            info.aftermath.duration = 30 * info.aftermath.level
        elseif spell.english == mythic_ws then
            -- nothing can overwrite lvl 3
            if buffactive['Aftermath: Lv.3'] then
                return
            end
            -- only lvl 3 can overwrite lvl 2
            if info.aftermath.level ~= 3 and buffactive['Aftermath: Lv.2'] then
                return
            end

            -- Assume mythic is lvl 80 or higher, for duration
                        
            if info.aftermath.level == 1 then
                info.aftermath.duration = (special_aftermath_mythics:contains(player.equipment.main) and 270) or 90
            elseif info.aftermath.level == 2 then
                info.aftermath.duration = (special_aftermath_mythics:contains(player.equipment.main) and 270) or 120
            else
                info.aftermath.duration = 180
            end
        end
    end
end


-- Call from job_aftercast() to create the custom aftermath timer.
function custom_aftermath_timers_aftercast(spell)
    if not spell.interrupted and spell.type == 'WeaponSkill' and
       info.aftermath and info.aftermath.weaponskill == spell.english and info.aftermath.duration > 0 then

        local aftermath_name = 'Aftermath: Lv.'..tostring(info.aftermath.level)
        send_command('timers d "Aftermath: Lv.1"')
        send_command('timers d "Aftermath: Lv.2"')
        send_command('timers d "Aftermath: Lv.3"')
        send_command('timers c "'..aftermath_name..'" '..tostring(info.aftermath.duration)..' down abilities/00027.png')

        info.aftermath = {}
    end
end


-- Function to reset state.Buff values.
function reset_buff_states()
	if state.Buff then
		for buff,present in pairs(state.Buff) do
			state.Buff[buff] = buffactive[buff] or false
		end
	end
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions for changing spells and target types in an automatic manner.
-------------------------------------------------------------------------------------------------------------------

local waltz_tp_cost = {['Curing Waltz'] = 200, ['Curing Waltz II'] = 350, ['Curing Waltz III'] = 500, ['Curing Waltz IV'] = 650, ['Curing Waltz V'] = 800}

-- Utility function for automatically adjusting the waltz spell being used to match HP needs and TP limits.
-- Handle spell changes before attempting any precast stuff.
function refine_waltz(spell, action, spellMap, eventArgs)
	if spell.type ~= 'Waltz' then
		return
	end
	
	-- Don't modify anything for Healing Waltz or Divine Waltzes
	if spell.english == "Healing Waltz" or spell.english == "Divine Waltz" or spell.english == "Divine Waltz II" then
		return
	end

	local newWaltz = spell.english
	local waltzID
	
	local missingHP
	
	-- If curing ourself, get our exact missing HP
	if spell.target.type == "SELF" then
		missingHP = player.max_hp - player.hp
	-- If curing someone in our alliance, we can estimate their missing HP
	elseif spell.target.isallymember then
		local target = find_player_in_alliance(spell.target.name)
		local est_max_hp = target.hp / (target.hpp/100)
		missingHP = math.floor(est_max_hp - target.hp)
	end
	
	-- If we have an estimated missing HP value, we can adjust the preferred tier used.
	if missingHP ~= nil then
		if player.main_job == 'DNC' then
			if missingHP < 40 and spell.target.name == player.name then
				-- Not worth curing yourself for so little.
				-- Don't block when curing others to allow for waking them up.
				add_to_chat(122,'Full HP!')
				eventArgs.cancel = true
				return
			elseif missingHP < 200 then
				newWaltz = 'Curing Waltz'
				waltzID = 190
			elseif missingHP < 600 then
				newWaltz = 'Curing Waltz II'
				waltzID = 191
			elseif missingHP < 1100 then
				newWaltz = 'Curing Waltz III'
				waltzID = 192
			elseif missingHP < 1500 then
				newWaltz = 'Curing Waltz IV'
				waltzID = 193
			else
				newWaltz = 'Curing Waltz V'
				waltzID = 311
			end
		elseif player.sub_job == 'DNC' then
			if missingHP < 40 and spell.target.name == player.name then
				-- Not worth curing yourself for so little.
				-- Don't block when curing others to allow for waking them up.
				add_to_chat(122,'Full HP!')
				eventArgs.cancel = true
				return
			elseif missingHP < 150 then
				newWaltz = 'Curing Waltz'
				waltzID = 190
			elseif missingHP < 300 then
				newWaltz = 'Curing Waltz II'
				waltzID = 191
			else
				newWaltz = 'Curing Waltz III'
				waltzID = 192
			end
		else
			-- Not dnc main or sub; bail out
			return
		end
	end

	local tpCost = waltz_tp_cost[newWaltz]

	local downgrade
	
	-- Downgrade the spell to what we can afford
	if player.tp < tpCost and not buffactive.trance then
		--[[ Costs:
			Curing Waltz:     200 TP
			Curing Waltz II:  350 TP
			Curing Waltz III: 500 TP
			Curing Waltz IV:  650 TP
			Curing Waltz V:   800 TP
			Divine Waltz:     400 TP
			Divine Waltz II:  800 TP
		--]]
		
		if player.tp < 200 then
			add_to_chat(122, 'Insufficient TP ['..tostring(player.tp)..']. Cancelling.')
			eventArgs.cancel = true
			return
		elseif player.tp < 350 then
			newWaltz = 'Curing Waltz'
		elseif player.tp < 500 then
			newWaltz = 'Curing Waltz II'
		elseif player.tp < 650 then
			newWaltz = 'Curing Waltz III'
		elseif player.tp < 800 then
			newWaltz = 'Curing Waltz IV'
		end
		
		downgrade = 'Insufficient TP ['..tostring(player.tp)..']. Downgrading to '..newWaltz..'.'
	end

	
	if newWaltz ~= spell.english then
		send_command('@input /ja "'..newWaltz..'" '..tostring(spell.target.raw))
		if downgrade then
			add_to_chat(122, downgrade)
		end
		eventArgs.cancel = true
		return
	end

	if missingHP and missingHP > 0 then
		add_to_chat(122,'Trying to cure '..tostring(missingHP)..' HP using '..newWaltz..'.')
	end
end


-- Function to allow for automatic adjustment of the spell target type based on preferences.
function auto_change_target(spell, spellMap)
	-- Don't adjust targetting for explicitly named targets
	if not spell.target.raw:startswith('<') then
		return
	end

	-- Do not modify target for spells where we get <lastst> or <me>.
	if spell.target.raw == ('<lastst>') or spell.target.raw == ('<me>') then
		return
	end
	
	-- init a new eventArgs with current values
	local eventArgs = {handled = false, PCTargetMode = state.PCTargetMode, SelectNPCTargets = state.SelectNPCTargets}

	-- Allow the job to do custom handling, or override the default values.
	-- They can completely handle it, or set one of the secondary eventArgs vars to selectively
	-- override the default state vars.
	if job_auto_change_target then
		job_auto_change_target(spell, action, spellMap, eventArgs)
	end
	
	-- If the job handled it, we're done.
	if eventArgs.handled then
		return
	end
	
	local pcTargetMode = eventArgs.PCTargetMode
	local selectNPCTargets = eventArgs.SelectNPCTargets

	
	local validPlayers = S{'Self', 'Player', 'Party', 'Ally', 'NPC'}

	local intersection = spell.targets * validPlayers
	local canUseOnPlayer = not intersection:empty()
	
	local newTarget
	
	-- For spells that we can cast on players:
	if canUseOnPlayer and pcTargetMode ~= 'default' then
		-- Do not adjust targetting for player-targettable spells where the target was <t>
		if spell.target.raw ~= ('<t>') then
			if pcTargetMode == 'stal' then
				-- Use <stal> if possible, otherwise fall back to <stpt>.
				if spell.targets.Ally then
					newTarget = '<stal>'
				elseif spell.targets.Party then
					newTarget = '<stpt>'
				end
			elseif pcTargetMode == 'stpt' then
				-- Even ally-possible spells are limited to the current party.
				if spell.targets.Ally or spell.targets.Party then
					newTarget = '<stpt>'
				end
			elseif pcTargetMode == 'stpc' then
				-- If it's anything other than a self-only spell, can change to <stpc>.
				if spell.targets.Player or spell.targets.Party or spell.targets.Ally or spell.targets.NPC then
					newTarget = '<stpc>'
				end
			end
		end
	-- For spells that can be used on enemies:
	elseif spell.targets and spell.targets.Enemy and selectNPCTargets then
		-- Note: this means macros should be written for <t>, and it will change to <stnpc>
		-- if the flag is set.  It won't change <stnpc> back to <t>.
		newTarget = '<stnpc>'
	end
	
	-- If a new target was selected and is different from the original, call the change function.
	if newTarget and newTarget ~= spell.target.raw then
		change_target(newTarget)
	end
end


-------------------------------------------------------------------------------------------------------------------
-- Environment utility functions.
-------------------------------------------------------------------------------------------------------------------

-- Function to get the current weather intensity: 0 for none, 1 for single weather, 2 for double weather.
function get_weather_intensity()
	return gearswap.res.weather[world.weather_id].intensity
end


-- Returns true if you're in a party solely comprised of Trust NPCs.
-- TODO: Do we need a check to see if we're in a party partly comprised of Trust NPCs?
function is_trust_party()
	-- Check if we're solo
	if party.count == 1 then
		return false
	end
	
	-- Can call a max of 3 Trust NPCs, so parties larger than that are out.
	if party.count > 4 then
		return false
	end

	-- If we're in an alliance, can't be a Trust party.
	if alliance[2].count > 0 or alliance[3].count > 0 then
		return false
	end
	
	-- Check that, for each party position aside from our own, the party
	-- member has one of the Trust NPC names, and that those party members
	-- are flagged is_npc.
	for i = 2,4 do
		if party[i] then
			if not npcs.Trust:contains(party[i].name) then
				return false
			end
			if party[i].mob and party[i].mob.is_npc == false then
				return false
			end
		end
	end
	
	-- If it didn't fail any of the above checks, return true.
	return true
end


-- Call these function with a list of equipment slots to check ('head', 'neck', 'body', etc)
-- Returns true if any of the specified slots are currently encumbered.
-- Returns false if all specified slots are unencumbered.
function is_encumbered(...)
	local check_list = {...}
	-- Compensate for people passing a table instead of a series of strings.
	if type(check_list[1]) == 'table' then
		check_list = check_list[1]
	end
	local check_set = S(check_list)
	
	for slot_id,slot_name in pairs(gearswap.default_slot_map) do
		if check_set:contains(slot_name) then
			if gearswap.encumbrance_table[slot_id] then
				return true
			end
		end
	end
	
	return false
end

-------------------------------------------------------------------------------------------------------------------
-- Elemental gear utility functions.
-------------------------------------------------------------------------------------------------------------------

-- General handler function to set all the elemental gear for an action.
function set_elemental_gear(spell)
	set_elemental_gorget_belt(spell)
	set_elemental_obi_cape_ring(spell)
	set_elemental_staff(spell)
end


-- Set the name field of the predefined gear vars for gorgets and belts, for the specified weaponskill.
function set_elemental_gorget_belt(spell)
	if spell.type ~= 'WeaponSkill' then
		return
	end

	-- Get the union of all the skillchain elements for the weaponskill
	local weaponskill_elements = S{}:
		union(skillchain_elements[spell.skillchain_a]):
		union(skillchain_elements[spell.skillchain_b]):
		union(skillchain_elements[spell.skillchain_c])
	
	gear.ElementalGorget.name = get_elemental_item_name("gorget", weaponskill_elements) or gear.default.weaponskill_neck  or ""
	gear.ElementalBelt.name   = get_elemental_item_name("belt", weaponskill_elements)   or gear.default.weaponskill_waist or ""
end


-- Function to get an appropriate obi/cape/ring for the current action.
function set_elemental_obi_cape_ring(spell)
	if spell.element == 'None' then
		return
	end
	
	local world_elements = S{world.day_element}
	if world.weather_element ~= 'None' then
		world_elements:add(world.weather_element)
	end

	local obi_name = get_elemental_item_name("obi", S{spell.element}, world_elements)
	gear.ElementalObi.name = obi_name or gear.default.obi_waist  or ""
	
	if obi_name then
		if player.inventory['Twilight Cape'] or player.wardrobe['Twilight Cape'] then
			gear.ElementalCape.name = "Twilight Cape"
		end
		if (player.inventory['Zodiac Ring'] or player.wardrobe['Zodiac Ring']) and spell.english ~= 'Impact' and
			not S{'Divine Magic','Dark Magic','Healing Magic'}:contains(spell.skill) then
			gear.ElementalRing.name = "Zodiac Ring"
		end
	else
		gear.ElementalCape.name = gear.default.obi_back
		gear.ElementalRing.name = gear.default.obi_ring
	end
end


-- Function to get the appropriate fast cast and/or recast staves for the current spell.
function set_elemental_staff(spell)
	if spell.action_type ~= 'Magic' then
		return
	end

	gear.FastcastStaff.name = get_elemental_item_name("fastcast_staff", S{spell.element}) or gear.default.fastcast_staff  or ""
	gear.RecastStaff.name   = get_elemental_item_name("recast_staff", S{spell.element})   or gear.default.recast_staff    or ""
end


-- Gets the name of an elementally-aligned piece of gear within the player's
-- inventory that matches the conditions set in the parameters.
--
-- item_type: Type of item as specified in the elemental_map mappings.
-- EG: gorget, belt, obi, fastcast_staff, recast_staff
--
-- valid_elements: Elements that are valid for the action being taken.
-- IE: Weaponskill skillchain properties, or spell element.
--
-- restricted_to_elements: Secondary elemental restriction that limits
-- whether the item check can be considered valid.
-- EG: Day or weather elements that have to match the spell element being queried.
--
-- Returns: Nil if no match was found (either due to elemental restrictions,
-- or the gear isn't in the player inventory), or the name of the piece of
-- gear that matches the query.
function get_elemental_item_name(item_type, valid_elements, restricted_to_elements)
	local potential_elements = restricted_to_elements or elements.list
	local item_map = elements[item_type:lower()..'_of']
	
	for element in (potential_elements.it or it)(potential_elements) do
		if valid_elements:contains(element) and (player.inventory[item_map[element]] or player.wardrobe[item_map[element]]) then
			return item_map[element]
		end
	end
end


-------------------------------------------------------------------------------------------------------------------
-- Function to easily change to a given macro set or book.  Book value is optional.
-------------------------------------------------------------------------------------------------------------------

function set_macro_page(set,book)
	if not tonumber(set) then
		add_to_chat(123,'Error setting macro page: Set is not a valid number ('..tostring(set)..').')
		return
	end
	if set < 1 or set > 10 then
		add_to_chat(123,'Error setting macro page: Macro set ('..tostring(set)..') must be between 1 and 10.')
		return
	end

	if book then
		if not tonumber(book) then
			add_to_chat(123,'Error setting macro page: book is not a valid number ('..tostring(book)..').')
			return
		end
		if book < 1 or book > 20 then
			add_to_chat(123,'Error setting macro page: Macro book ('..tostring(book)..') must be between 1 and 20.')
			return
		end
		send_command('@input /macro book '..tostring(book)..';wait .1;input /macro set '..tostring(set))
	else
		send_command('@input /macro set '..tostring(set))
	end
end


-------------------------------------------------------------------------------------------------------------------
-- Utility functions for including local user files.
-------------------------------------------------------------------------------------------------------------------

-- Attempt to load user gear files in place of default gear sets.
-- Return true if one exists and was loaded.
function load_sidecar(job)
	if not job then return false end
	
	-- filename format example for user-local files: whm_gear.lua, or playername_whm_gear.lua
	local filenames = {player.name..'_'..job..'_gear.lua', job..'_gear.lua',
		'gear/'..player.name..'_'..job..'_gear.lua', 'gear/'..job..'_gear.lua',
		'gear/'..player.name..'_'..job..'.lua', 'gear/'..job..'.lua'}
	return optional_include(filenames)
end

-- Attempt to include user-globals.  Return true if it exists and was loaded.
function load_user_globals()
	local filenames = {player.name..'-globals.lua', 'user-globals.lua'}
	return optional_include(filenames)
end

-- Optional version of include().  If file does not exist, does not
-- attempt to load, and does not throw an error.
-- filenames takes an array of possible file names to include and checks
-- each one.
function optional_include(filenames)
	for _,v in pairs(filenames) do
		local path = gearswap.pathsearch({v})
		if path then
			include(v)
			return true
		end
	end
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions for vars or other data manipulation.
-------------------------------------------------------------------------------------------------------------------

-- Attempt to locate a specified name within the current alliance.
function find_player_in_alliance(name)
	for party_index,ally_party in ipairs(alliance) do
		for player_index,_player in ipairs(ally_party) do
			if _player.name == name then
				return _player
			end
		end
	end
end


-- buff_set is a set of buffs in a library table (any of S{}, T{} or L{}).
-- This function checks if any of those buffs are present on the player.
function has_any_buff_of(buff_set)
	return buff_set:any(
		-- Returns true if any buff from buff set that is sent to this function returns true:
		function (b) return buffactive[b] end
	)
end


-- Invert a table such that the keys are values and the values are keys.
-- Use this to look up the index value of a given entry.
function invert_table(t)
	if t == nil then error('Attempting to invert table, received nil.', 2) end
	
	local i={}
	for k,v in pairs(t) do 
		i[v] = k
	end
	return i
end


-- Gets sub-tables based on baseSet from the string str that may be in dot form
-- (eg: baseSet=sets, str='precast.FC', this returns the table sets.precast.FC).
function get_expanded_set(baseSet, str)
	local cur = baseSet
	for i in str:gmatch("[^.]+") do
		if cur then
			cur = cur[i]
		end
	end
	
	return cur
end


-------------------------------------------------------------------------------------------------------------------
-- Utility functions data and event tracking.
-------------------------------------------------------------------------------------------------------------------

-- This is a function that can be attached to a registered event for 'time change'.
-- It will send a call to the update() function if the time period changes.
-- It will also call job_time_change when any of the specific time class values have changed.
-- To activate this in your job lua, add this line to your user_setup function:
-- windower.register_event('time change', time_change)
--
-- Variables it sets: classes.Daytime, and classes.DuskToDawn.  They are set to true
-- if their respective descriptors are true, or false otherwise.
function time_change(new_time, old_time)
	local was_daytime = classes.Daytime
	local was_dusktime = classes.DuskToDawn
	
	if new_time >= 6*60 and new_time < 18*60 then
		classes.Daytime = true
	else
		classes.Daytime = false
	end

	if new_time >= 17*60 or new_time < 7*60 then
		classes.DuskToDawn = true
	else
		classes.DuskToDawn = false
	end
	
	if was_daytime ~= classes.Daytime or was_dusktime ~= classes.DuskToDawn then
		if job_time_change then
			job_time_change(new_time, old_time)
		end

		handle_update({'auto'})
	end
end



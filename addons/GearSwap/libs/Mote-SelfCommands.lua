-------------------------------------------------------------------------------------------------------------------
-- General functions for manipulating state values via self-commands.
-- Only handles certain specific states that we've defined, though it
-- allows the user to hook into the cycle command.
-------------------------------------------------------------------------------------------------------------------

-- Routing function for general known self_commands.
-- Handles splitting the provided command line up into discrete words, for the other functions to use.
function self_command(commandArgs)
	local commandArgs = commandArgs
	if type(commandArgs) == 'string' then
		commandArgs = T(commandArgs:split(' '))
		if #commandArgs == 0 then
			return
		end
	end

	-- init a new eventArgs
	local eventArgs = {handled = false}

	-- Allow jobs to override this code
	if job_self_command then
		job_self_command(commandArgs, eventArgs)
	end

	if not eventArgs.handled then
		-- Of the original command message passed in, remove the first word from
		-- the list (it will be used to determine which function to call), and
		-- send the remaining words as parameters for the function.
		local handleCmd = table.remove(commandArgs, 1)

		if selfCommandMaps[handleCmd] then
			selfCommandMaps[handleCmd](commandArgs)
		end
	end
end


-- Individual handling of self-commands


-- Handle toggling specific vars that we know of.
-- Valid toggles: Defense, Kiting
-- Returns true if a known toggle was handled.  Returns false if not.
-- User command format: gs c toggle [field]
function handle_toggle(cmdParams)
	if #cmdParams == 0 then
		add_to_chat(123,'Mote-GearSwap: Toggle parameter failure: field not specified.')
		return
	end

	local toggleField = cmdParams[1]:lower()
	local reportDescription
	local notifyDescription
	local oldVal
	local newVal

	-- Known global states
	if toggleField == 'defense' then
		oldVal = state.Defense.Active
		state.Defense.Active = not state.Defense.Active
		newVal = state.Defense.Active
		notifyDescription = state.Defense.Type .. ' Defense'
		if state.Defense.Type == 'Physical' then
			reportDescription = 'Physical defense ('..state.Defense.PhysicalMode..')'
		else
			reportDescription = 'Magical defense ('..state.Defense.MagicalMode..')'
		end
	elseif toggleField == 'kite' or toggleField == 'kiting' then
		oldVal = state.Kiting
		state.Kiting = not state.Kiting
		newVal = state.Kiting
		notifyDescription = 'Kiting'
		reportDescription = 'Kiting'
	elseif toggleField == 'selectnpctargets' then
		oldVal = state.SelectNPCTargets
		state.SelectNPCTargets = not state.SelectNPCTargets
		newVal = state.SelectNPCTargets
		notifyDescription = 'NPC Target Selection'
		reportDescription = 'NPC Target Selection'
	elseif type(state[cmdParams[1]]) == 'boolean' then
		oldVal = state[cmdParams[1]]
		state[cmdParams[1]] = not state[cmdParams[1]]
		newVal = state[cmdParams[1]]
		notifyDescription = cmdParams[1]
		reportDescription = cmdParams[1]
	elseif job_toggle_state then
		reportDescription, newVal = job_toggle_state(cmdParams[1])
	end

	-- Notify user file of changes to global states.
	if oldVal ~= nil then
		if job_state_change and newVal ~= oldVal then
			job_state_change(notifyDescription, newVal, oldVal)
		end
	end

	if reportDescription then
		add_to_chat(122,reportDescription..' is now '..on_off_names[newVal]..'.')
		handle_update({'auto'})
	else
		add_to_chat(123,'Mote-GearSwap: Toggle: Unknown field ['..toggleField..']')
	end
end


-- Function to handle turning on particular states, while possibly also setting a mode value.
-- User command format: gs c activate [field]
function handle_activate(cmdParams)
	if #cmdParams == 0 then
		add_to_chat(123,'Mote-GearSwap: Activate parameter failure: field not specified.')
		return
	end

	local activateField = cmdParams[1]:lower()
	local reportDescription
	local notifyDescription
	local oldVal
	local newVal = true

	-- Known global states
	if activateField == 'defense' then
		oldVal = state.Defense.Active
		state.Defense.Active = true
		notifyDescription = state.Defense.Type .. ' Defense'
		if state.Defense.Type == 'Physical' then
			reportDescription = 'Physical defense ('..state.Defense.PhysicalMode..')'
		else
			reportDescription = 'Magical defense ('..state.Defense.MagicalMode..')'
		end
	elseif activateField == 'physicaldefense' then
		oldVal = state.Defense.Active
		state.Defense.Active = true
		state.Defense.Type = 'Physical'
		notifyDescription = state.Defense.Type .. ' Defense'
		reportDescription = 'Physical defense ('..state.Defense.PhysicalMode..')'
	elseif activateField == 'magicaldefense' then
		oldVal = state.Defense.Active
		state.Defense.Active = true
		state.Defense.Type = 'Magical'
		notifyDescription = state.Defense.Type .. ' Defense'
		reportDescription = 'Magical defense ('..state.Defense.MagicalMode..')'
	elseif activateField == 'kite' or toggleField == 'kiting' then
		oldVal = state.Kiting
		state.Kiting = true
		notifyDescription = 'Kiting'
		reportDescription = 'Kiting'
	elseif activateField == 'selectnpctargets' then
		oldVal = state.SelectNPCTargets
		state.SelectNPCTargets = true
		notifyDescription = 'NPC Target Selection'
		reportDescription = 'NPC Target Selection'
	elseif type(state[cmdParams[1]]) == 'boolean' then
		oldVal = state[cmdParams[1]]
		state[cmdParams[1]] = true
		notifyDescription = cmdParams[1]
		reportDescription = cmdParams[1]
	elseif job_activate_state then
		reportDescription, newVal = job_activate_state(cmdParams[1])
	end

	-- Notify user file of changes to global states.
	if oldVal ~= nil then
		if job_state_change and newVal ~= oldVal then
			job_state_change(notifyDescription, newVal, oldVal)
		end
	end

	if reportDescription then
		add_to_chat(122,reportDescription..' is now '..on_off_names[newVal]..'.')
		handle_update({'auto'})
	else
		add_to_chat(123,'Mote-GearSwap: Activate: Unknown field ['..activateField..']')
	end
end


-- Handle cycling through the options for specific vars that we know of.
-- Valid fields: OffenseMode, DefenseMode, WeaponskillMode, IdleMode, RestingMode, CastingMode, PhysicalDefenseMode, MagicalDefenseMode
-- All fields must end in 'Mode'
-- Returns true if a known toggle was handled.  Returns false if not.
-- User command format: gs c cycle [field]
function handle_cycle(cmdParams)
	if #cmdParams == 0 then
		add_to_chat(123,'Mote-GearSwap: Cycle parameter failure: field not specified.')
		return
	end
	
	-- identifier for the field we're changing
	local paramField = cmdParams[1]
	local modeField = paramField
	local order = (cmdParams[2] and S{'reverse', 'backwards', 'r'}:contains(cmdParams[2]:lower()) and 'backwards') or 'forward'

	if paramField:endswith('mode') or paramField:endswith('Mode') then
		-- Remove 'mode' from the end of the string
		modeField = paramField:sub(1,#paramField-4)
	end

	-- Convert WS to Weaponskill
	if modeField == "ws" then
		modeField = "weaponskill"
	end
	
	-- Capitalize the field (for use on output display)
	modeField = modeField:gsub("%f[%a]%a", string.upper)

	-- Get the options.XXXModes table, and the current state mode for the mode field.
	local modeList, currentValue = get_mode_list(modeField)

	if not modeList then
		if _global.debug_mode then add_to_chat(123,'Unknown mode : '..modeField..'.') end
		return
	end

	-- Get the index of the current mode.  Index starts at 0 for 'undefined', so that it can increment to 1.
	local invertedTable = invert_table(modeList)
	local index = 0
	if invertedTable[currentValue] then
		index = invertedTable[currentValue]
	end

	-- Increment to the next index in the available modes.
	if order == 'forward' then
		index = index + 1
		if index > #modeList then
			index = 1
		end
	else
		index = index - 1
		if index < 1 then
			index = #modeList
		end
	end

	-- Determine the new mode value based on the index.
	local newModeValue = ''
	if index and modeList[index] then
		newModeValue = modeList[index]
	else
		newModeValue = 'Normal'
	end

	-- And save that to the appropriate state field.
	set_option_mode(modeField, newModeValue)

	if job_state_change and newModeValue ~= currentValue then
		job_state_change(modeField..'Mode', newModeValue, currentValue)
	end

	-- Display what got changed to the user.
	add_to_chat(122,modeField..' mode is now '..newModeValue..'.')
	handle_update({'auto'})
end

-- Function to set various states to specific values directly.
-- User command format: gs c set [field] [value]
function handle_set(cmdParams)
	if #cmdParams > 1 then
		-- identifier for the field we're setting
		local field = cmdParams[1]
		local lowerField = field:lower()
		local capField = lowerField:gsub("%a", string.upper, 1)
		local setField = cmdParams[2]
		local reportDescription
		local notifyDescription
		local fieldDesc
		local oldVal
		local newVal


		-- Check if we're dealing with a boolean
		if on_off_values:contains(setField:lower()) then
			newVal = true_values:contains(setField:lower())

			if lowerField == 'defense' then
				oldVal = state.Defense.Active
				state.Defense.Active = newVal
				notifyDescription = state.Defense.Type .. ' Defense'
				if state.Defense.Type == 'Physical' then
					reportDescription = 'Physical defense ('..state.Defense.PhysicalMode..')'
				else
					reportDescription = 'Magical defense ('..state.Defense.MagicalMode..')'
				end
			elseif lowerField == 'kite' or lowerField == 'kiting' then
				oldVal = state.Kiting
				state.Kiting = newVal
				notifyDescription = 'Kiting'
				reportDescription = 'Kiting'
			elseif lowerField == 'selectnpctargets' then
				oldVal = state.SelectNPCTargets
				state.SelectNPCTargets = newVal
				notifyDescription = 'NPC Target Selection'
				reportDescription = 'NPC Target Selection'
			elseif type(state[field]) == 'boolean' then
				oldVal = state[field]
				state[field] = newVal
				notifyDescription = field
				reportDescription = field
			elseif job_set_state then
				reportDescription, newVal = job_set_state(field, newVal)
			end


			-- Notify user file of changes to global states.
			if oldVal ~= nil then
				if job_state_change and newVal ~= oldVal then
					job_state_change(notifyDescription, newVal, oldVal)
				end
			end

			if reportDescription then
				add_to_chat(122,reportDescription..' is now '..on_off_names[newVal]..'.')
			else
				add_to_chat(123,'Mote-GearSwap: Set: Unknown field ['..field..']')
			end
		-- Check if we're dealing with some sort of cycle field (ends with 'mode').
		elseif lowerField:endswith('mode') or type(state[capField..'Mode']) == 'string' then
			local modeField = lowerField
			
			-- Remove 'mode' from the end of the string
			if modeField:endswith('mode') then
				modeField = lowerField:sub(1,#lowerField-4)
			end

			-- Convert WS to Weaponskill
			if modeField == "ws" then
				modeField = "weaponskill"
			end
			
			-- Capitalize the field (for use on output display)
			modeField = modeField:gsub("%a", string.upper, 1)

			-- Get the options.XXXModes table, and the current state mode for the mode field.
			local modeList
			modeList, oldVal = get_mode_list(modeField)

			if not modeList or not table.contains(modeList, setField) then
				add_to_chat(123,'Unknown mode value: '..setField..' for '..modeField..' mode.')
				return
			end

			-- And save that to the appropriate state field.
			set_option_mode(modeField, setField)

			-- Notify the job script of the change.
			if job_state_change and setField ~= oldVal then
				job_state_change(modeField, setField, oldVal)
			end

			-- Display what got changed to the user.
			add_to_chat(122,modeField..' mode is now '..setField..'.')
		-- Or distance (where we may need to get game state info)
		elseif lowerField == 'distance' then
			if setField then
				newVal = tonumber(setField)
				if newVal ~= nil then
					oldVal = state.MaxWeaponskillDistance
					state.MaxWeaponskillDistance = newVal
				else
					add_to_chat(123,'Invalid distance value: '..tostring(setField))
					return
				end

				-- Notify the job script of the change.
				if job_state_change and newVal ~= oldVal then
					job_state_change('MaxWeaponskillDistance', newVal, oldVal)
				end

				add_to_chat(122,'Max weaponskill distance is now '..tostring(newVal)..'.')
			else
				-- set max weaponskill distance to the current distance the player is from the mob.
				-- Get current player distance and use that
				add_to_chat(123,'TODO: get player distance.')
			end
		-- If trying to set a number
		elseif tonumber(setField) then
			if state[field] and type(state[field]) == 'number' then
				oldVal = state[field]
				newVal = tonumber(setField)
				state[field] = newVal
				reportDescription = field

				-- Notify the job script of the change.
				if job_state_change and newVal ~= oldVal then
					job_state_change(field, newVal, oldVal)
				end
			elseif state[field] then
				add_to_chat(123,'Mote-GearSwap: Set: Attempting to set a numeric value ['..setField..'] in a non-numeric field ['..field..'].')
				return
			elseif job_set_state then
				reportDescription, newVal = job_set_state(field, setField)
			end

			if reportDescription then
				add_to_chat(122,field..' is now '..tostring(newVal)..'.')
			else
				add_to_chat(123,'Mote-GearSwap: Set: Unknown field ['..field..']')
			end
		-- otherwise assume trying to set a text field
		else
			if lowerField == 'combatform' then
				oldVal = state.CombatForm
				state.CombatForm = setField
				newVal = setField
				notifyDescription = 'Combat Form'
				reportDescription = 'Combat Form'
			elseif lowerField == 'combatweapon' then
				oldVal = state.CombatWeapon
				state.CombatWeapon = setField
				newVal = setField
				notifyDescription = 'Combat Weapon'
				reportDescription = 'Combat Weapon'
			elseif state[field] and type(state[field]) == 'string' then
				oldVal = state[field]
				state[field] = setField
				newVal = setField
				notifyDescription = field
				reportDescription = field
			elseif job_set_state then
				reportDescription, newVal = job_set_state(field, setField)
			end

			-- Notify user file of changes to global states.
			if oldVal ~= nil then
				if job_state_change and newVal ~= oldVal then
					job_state_change(notifyDescription, newVal, oldVal)
				end
			end

			if reportDescription then
				add_to_chat(122,reportDescription..' is now '..newVal..'.')
			else
				add_to_chat(123,'Mote-GearSwap: Set: Unknown field ['..field..']')
			end
		end
	else
		if _global.debug_mode then add_to_chat(123,'--handle_set parameter failure: insufficient fields') end
		return false
	end

	handle_update({'auto'})
	return true
end


-- Function to turn off togglable features, or reset values to their defaults.
-- User command format: gs c reset [field]
function handle_reset(cmdParams)
	if #cmdParams == 0 then
		if _global.debug_mode then add_to_chat(123,'handle_reset: parameter failure: reset type not specified') end
		return
	end

	resetState = cmdParams[1]:lower()

	if resetState == 'defense' then
		state.Defense.Active = false
		add_to_chat(122,state.Defense.Type..' defense is now off.')
	elseif resetState == 'kite' or resetState == 'kiting' then
		state.Kiting = false
		add_to_chat(122,'Kiting is now off.')
	elseif resetState == 'melee' then
		state.OffenseMode = options.OffenseModes[1]
		state.DefenseMode = options.DefenseModes[1]
		add_to_chat(122,'Melee has been reset to defaults.')
	elseif resetState == 'casting' then
		state.CastingMode = options.CastingModes[1]
		add_to_chat(122,'Casting has been reset to default.')
	elseif resetState == 'distance' then
		state.MaxWeaponskillDistance = 0
		add_to_chat(122,'Max weaponskill distance limitations have been removed.')
	elseif resetState == 'target' then
		state.SelectNPCTargets = false
		state.PCTargetMode = 'default'
		add_to_chat(122,'Adjusting target selection has been turned off.')
	elseif resetState == 'all' then
		state.Defense.Active = false
		state.Defense.PhysicalMode = options.PhysicalDefenseModes[1]
		state.Defense.MagicalMode = options.MagicalDefenseModes[1]
		state.Kiting = false
		state.OffenseMode = options.OffenseModes[1]
		state.DefenseMode = options.DefenseModes[1]
		state.CastingMode = options.CastingModes[1]
		state.IdleMode = options.IdleModes[1]
		state.RestingMode = options.RestingModes[1]
		state.MaxWeaponskillDistance = 0
		state.SelectNPCTargets = false
		state.PCTargetMode = 'default'
		mote_vars.show_set = nil
		if job_reset then
			job_reset(resetState)
		end
		add_to_chat(122,'Everything has been reset to defaults.')
	elseif job_reset then
		job_reset(resetState)
	else
		add_to_chat(123,'handle_reset: unknown state to reset: '..resetState)
		return
	end

	if job_state_change then
		job_state_change('Reset', resetState)
	end

	handle_update({'auto'})
end


-- User command format: gs c update [option]
-- Where [option] can be 'user' to display current state.
-- Otherwise, generally refreshes current gear used.
function handle_update(cmdParams)
	-- init a new eventArgs
	local eventArgs = {handled = false}

	reset_buff_states()

	-- Allow jobs to override this code
	if job_update then
		job_update(cmdParams, eventArgs)
	end

	if not eventArgs.handled then
		if handle_equipping_gear then
			handle_equipping_gear(player.status)
		end
	end

	if cmdParams[1] == 'user' then
		display_current_state()
	end
end


-- showset: equip the current TP set for examination.
function handle_show_set(cmdParams)
	local showset_type
	if cmdParams[1] then
		showset_type = cmdParams[1]:lower()
	end

	-- If no extra parameters, or 'tp' as a parameter, show the current TP set.
	if not showset_type or showset_type == 'tp' then
		local meleeGroups = ''
		if #classes.CustomMeleeGroups > 0 then
			meleeGroups = ' ['
			for i = 1,#classes.CustomMeleeGroups do
				meleeGroups = meleeGroups..classes.CustomMeleeGroups[i]
			end
			meleeGroups = meleeGroups..']'
		end

		add_to_chat(122,'Showing current TP set: ['..state.OffenseMode..'/'..state.DefenseMode..']'..meleeGroups)
		equip(get_melee_set())
	-- If given a param of 'precast', block equipping midcast/aftercast sets
	elseif showset_type == 'precast' then
		mote_vars.show_set = 'precast'
		add_to_chat(122,'GearSwap will now only equip up to precast gear for spells/actions.')
	-- If given a param of 'midcast', block equipping aftercast sets
	elseif showset_type == 'midcast' then
		mote_vars.show_set = 'midcast'
		add_to_chat(122,'GearSwap will now only equip up to midcast gear for spells.')
	-- If given a param of 'midcast', block equipping aftercast sets
	elseif showset_type == 'petmidcast' or showset_type == 'pet_midcast' then
		mote_vars.show_set = 'pet_midcast'
		add_to_chat(122,'GearSwap will now only equip up to pet midcast gear for spells.')
	-- With a parameter of 'off', turn off showset functionality.
	elseif showset_type == 'off' then
		mote_vars.show_set = nil
		add_to_chat(122,'Show Sets is turned off.')
	end
end

-- Minor variation on the GearSwap "gs equip naked" command, that ensures that
-- all slots are enabled before removing gear.
-- Command: "gs c naked"
function handle_naked(cmdParams)
	enable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
	equip(sets.naked)
end


------  Utility functions to support self commands. ------

-- Function to get the options.XXXModes list and the corresponding state value for the requested field.
function get_mode_list(field)
	local modeList = {}
	local currentValue = ''
	local lowerField = field:lower()

	if type(state[field..'Mode']) == 'string' and type(options[field..'Modes']) == 'table' then
		-- Handles: Offense, Defense, Ranged, Casting, Weaponskill, Idle, Resting modes
		modeList = options[field..'Modes']
		currentValue = state[field..'Mode']
	elseif lowerField == 'physicaldefense' then
		modeList = options.PhysicalDefenseModes
		currentValue = state.Defense.PhysicalMode
	elseif lowerField == 'magicaldefense' then
		modeList = options.MagicalDefenseModes
		currentValue = state.Defense.MagicalMode
	elseif lowerField == 'pctarget' then
		modeList = options.TargetModes
		currentValue = state.PCTargetMode
	elseif type(state[field..'Mode']) == 'string' and type(options[field..'Modes']) ~= 'table' then
		-- naming conflict
		add_to_chat(123,'No valid options table for field: '..field)
	elseif type(state[field..'Mode']) ~= 'string' and type(options[field..'Modes']) == 'table' then
		-- naming conflict
		add_to_chat(123,'No valid state string for field: '..field)
	elseif job_get_option_modes then
		-- Allow job scripts to expand the mode table lists
		modeList, currentValue = job_get_option_modes(field)
		if not modeList then
			add_to_chat(123,'Attempt to acquire options list for unknown state field: '..field)
			return nil
		end
	else
		add_to_chat(123,'Attempt to acquire options list for unknown state field: '..field)
		return nil
	end

	return modeList, currentValue
end

-- Function to set the appropriate state value for the specified field.
function set_option_mode(field, val)
    local lowerField = field:lower()
    
	if type(state[field..'Mode']) == 'string' then
		-- Handles: Offense, Defense, Ranged, Casting, Weaponskill, Idle, Resting modes
		state[field..'Mode'] = val
	elseif lowerField == 'physicaldefense' then
		state.Defense.PhysicalMode = val
	elseif lowerField == 'magicaldefense' then
		state.Defense.MagicalMode = val
	elseif lowerField == 'pctarget' then
		state.PCTargetMode = val
	elseif job_set_option_mode then
		-- Allow job scripts to expand the mode table lists
		if not job_set_option_mode(field, val) then
			add_to_chat(123,'Attempt to set unknown option field: '..field)
		end
	else
		add_to_chat(123,'Attempt to set unknown option field: '..field)
	end
end


-- Function to display the current relevant user state when doing an update.
-- Uses display_current_job_state instead if that is defined in the job lua.
function display_current_state()
	local eventArgs = {handled = false}
	if display_current_job_state then
		display_current_job_state(eventArgs)
	end

	if not eventArgs.handled then
		local defenseString = ''
		if state.Defense.Active then
			local defMode = state.Defense.PhysicalMode
			if state.Defense.Type == 'Magical' then
				defMode = state.Defense.MagicalMode
			end

			defenseString = 'Defense: '..state.Defense.Type..' '..defMode..', '
		end

		local pcTarget = ''
		if state.PCTargetMode ~= 'default' then
			pcTarget = ', Target PC: '..state.PCTargetMode
		end

		local npcTarget = ''
		if state.SelectNPCTargets then
			pcTarget = ', Target NPCs'
		end


		add_to_chat(122,'Melee: '..state.OffenseMode..'/'..state.DefenseMode..', WS: '..state.WeaponskillMode..', '..defenseString..
			'Kiting: '..on_off_names[state.Kiting]..pcTarget..npcTarget)
	end

	if mote_vars.show_set then
		add_to_chat(122,'Show Sets it currently showing ['..mote_vars.show_set..'] sets.  Use "//gs c showset off" to turn it off.')
	end
end

-------------------------------------------------------------------------------------------------------------------
-- Test functions.
-------------------------------------------------------------------------------------------------------------------

-- A function for testing lua code.  Called via "gs c test".
function handle_test(cmdParams)
	if user_test then
		user_test(cmdParams)
	end
end



-------------------------------------------------------------------------------------------------------------------
-- The below table maps text commands to the above handler functions.
-------------------------------------------------------------------------------------------------------------------

selfCommandMaps = {
	['toggle']   = handle_toggle,
	['activate'] = handle_activate,
	['cycle']    = handle_cycle,
	['set']      = handle_set,
	['reset']    = handle_reset,
	['update']   = handle_update,
	['showset']  = handle_show_set,
	['naked']    = handle_naked,
	['test']     = handle_test}


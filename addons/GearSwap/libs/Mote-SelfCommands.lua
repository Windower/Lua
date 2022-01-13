-------------------------------------------------------------------------------------------------------------------
-- General functions for manipulating state values via self-commands.
-- Only handles certain specific states that we've defined, though it
-- allows the user to hook into the cycle command.
-------------------------------------------------------------------------------------------------------------------

-- Routing function for general known self_commands.  Mappings are at the bottom of the file.
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


-------------------------------------------------------------------------------------------------------------------
-- Functions for manipulating state vars.
-------------------------------------------------------------------------------------------------------------------

-- Function to set various states to specific values directly.
-- User command format: gs c set [field] [value]
-- If a boolean [field] is used, but not given a [value], it will be set to true.
function handle_set(cmdParams)
    if #cmdParams == 0 then
        add_to_chat(123,'Mote-Libs: Set parameter failure: field not specified.')
        return
    end
    
    local state_var = get_state(cmdParams[1])
    
    if state_var then
        local oldVal = state_var.value
        state_var:set(T(cmdParams):slice(2):concat(' '))
        local newVal = state_var.value
        
        local descrip = state_var.description or cmdParams[1]
        if job_state_change then
            job_state_change(descrip, newVal, oldVal)
        end

        local msg = descrip..' is now '..state_var.current
        if state_var == state.DefenseMode and newVal ~= 'None' then
            msg = msg .. ' (' .. state[newVal .. 'DefenseMode'].current .. ')'
        end
        msg = msg .. '.'
        
        add_to_chat(122, msg)
        handle_update({'auto'})
    else
        add_to_chat(123,'Mote-Libs: Set: Unknown field ['..cmdParams[1]..']')
    end

    -- handle string states: CombatForm, CombatWeapon, etc
end

-- Function to reset values to their defaults.
-- User command format: gs c reset [field]
-- Or: gs c reset all
function handle_reset(cmdParams)
    if #cmdParams == 0 then
        if _global.debug_mode then add_to_chat(123,'handle_reset: parameter failure: reset type not specified') end
        return
    end
    
    local state_var = get_state(cmdParams[1])

    local oldVal
    local newVal
    local descrip
    
    if state_var then
        oldVal = state_var.value
        state_var:reset()
        newVal = state_var.value
        
        local descrip = state_var.description or cmdParams[1]
        if job_state_change then
            job_state_change(descrip, newVal, oldVal)
        end

        add_to_chat(122,descrip..' is now '..state_var.current..'.')
        handle_update({'auto'})
    elseif cmdParams[1]:lower() == 'all' then
        for k,v in pairs(state) do
            if v._type == 'mode' then
                oldVal = v.value
                v:reset()
                newVal = v.value
                
                descrip = state_var.description
                if descrip and job_state_change then
                    job_state_change(descrip, newVal, oldVal)
                end
            end
        end

        if job_reset_state then
            job_reset_state('all')
        end

        if job_state_change then
            job_state_change('Reset All')
        end

        add_to_chat(122,"All state vars have been reset.")
        handle_update({'auto'})
    elseif job_reset_state then
        job_reset_state(cmdParams[1])
    else
        add_to_chat(123,'Mote-Libs: Reset: Unknown field ['..cmdParams[1]..']')
    end
end


-- Handle cycling through the options list of a state var.
-- User command format: gs c cycle [field]
function handle_cycle(cmdParams)
    if #cmdParams == 0 then
        add_to_chat(123,'Mote-Libs: Cycle parameter failure: field not specified.')
        return
    end
    
    local state_var = get_state(cmdParams[1])
    
    if state_var then
        local oldVal = state_var.value
        if cmdParams[2] and S{'reverse', 'backwards', 'r'}:contains(cmdParams[2]:lower()) then
            state_var:cycleback()
        else
            state_var:cycle()
        end
        local newVal = state_var.value
        
        local descrip = state_var.description or cmdParams[1]
        if job_state_change then
            job_state_change(descrip, newVal, oldVal)
        end

        add_to_chat(122,descrip..' is now '..state_var.current..'.')
        handle_update({'auto'})
    else
        add_to_chat(123,'Mote-Libs: Cycle: Unknown field ['..cmdParams[1]..']')
    end
end


-- Handle cycling backwards through the options list of a state var.
-- User command format: gs c cycleback [field]
function handle_cycleback(cmdParams)
    cmdParams[2] = 'reverse'
    handle_cycle(cmdParams)
end


-- Handle toggling of boolean mode vars.
-- User command format: gs c toggle [field]
function handle_toggle(cmdParams)
    if #cmdParams == 0 then
        add_to_chat(123,'Mote-Libs: Toggle parameter failure: field not specified.')
        return
    end
    
    local state_var = get_state(cmdParams[1])
    
    if state_var then
        local oldVal = state_var.value
        state_var:toggle()
        local newVal = state_var.value
        
        local descrip = state_var.description or cmdParams[1]
        if job_state_change then
            job_state_change(descrip, newVal, oldVal)
        end

        add_to_chat(122,descrip..' is now '..state_var.current..'.')
        handle_update({'auto'})
    else
        add_to_chat(123,'Mote-Libs: Toggle: Unknown field ['..cmdParams[1]..']')
    end
end


-- Function to force a boolean field to false.
-- User command format: gs c unset [field]
function handle_unset(cmdParams)
    if #cmdParams == 0 then
        add_to_chat(123,'Mote-Libs: Unset parameter failure: field not specified.')
        return
    end
    
    local state_var = get_state(cmdParams[1])
    
    if state_var then
        local oldVal = state_var.value
        state_var:unset()
        local newVal = state_var.value
        
        local descrip = state_var.description or cmdParams[1]
        if job_state_change then
            job_state_change(descrip, newVal, oldVal)
        end

        add_to_chat(122,descrip..' is now '..state_var.current..'.')
        handle_update({'auto'})
    else
        add_to_chat(123,'Mote-Libs: Toggle: Unknown field ['..cmdParams[1]..']')
    end
end

-------------------------------------------------------------------------------------------------------------------

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


-- showtp: equip the current TP set for examination.
function handle_showtp(cmdParams)
    local msg = 'Showing current TP set: ['.. state.OffenseMode.value
    if state.HybridMode.value ~= 'Normal' then
        msg = msg .. '/' .. state.HybridMode.value
    end
    msg = msg .. ']'

    if #classes.CustomMeleeGroups > 0 then
        msg = msg .. ' ['
        for i = 1,#classes.CustomMeleeGroups do
            msg = msg .. classes.CustomMeleeGroups[i]
            if i < #classes.CustomMeleeGroups then
                msg = msg .. ', '
            end
        end
        msg = msg .. ']'
    end

    add_to_chat(122, msg)
    equip(get_melee_set())
end


-- Minor variation on the GearSwap "gs equip naked" command, that ensures that
-- all slots are enabled before removing gear.
-- Command: "gs c naked"
function handle_naked(cmdParams)
    enable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
    equip(sets.naked)
end


-------------------------------------------------------------------------------------------------------------------

-- Get the state var that matches the requested name.
-- Only returns mode vars.
function get_state(name)
    if state[name] then
        return state[name]._class == 'mode' and state[name] or nil
    else
        local l_name = name:lower()
        for key,var in pairs(state) do
            if key:lower() == l_name then
                return var._class == 'mode' and var or nil
            end
        end
    end
end


-- Function to reset state.Buff values (called from update).
function reset_buff_states()
    if state.Buff then
        for buff,present in pairs(state.Buff) do
            if mote_vars.res_buffs:contains(buff) then
                state.Buff[buff] = buffactive[buff] or false
            end
        end
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
        local msg = 'Melee'
        
        if state.CombatForm.has_value then
            msg = msg .. ' (' .. state.CombatForm.value .. ')'
        end
        
        msg = msg .. ': '
        
        msg = msg .. state.OffenseMode.value
        if state.HybridMode.value ~= 'Normal' then
            msg = msg .. '/' .. state.HybridMode.value
        end
        msg = msg .. ', WS: ' .. state.WeaponskillMode.value
        
        if state.DefenseMode.value ~= 'None' then
            msg = msg .. ', Defense: ' .. state.DefenseMode.value .. ' (' .. state[state.DefenseMode.value .. 'DefenseMode'].value .. ')'
        end
        
        if state.Kiting.value == true then
            msg = msg .. ', Kiting'
        end

        if state.PCTargetMode.value ~= 'default' then
            msg = msg .. ', Target PC: '..state.PCTargetMode.value
        end

        if state.SelectNPCTargets.value == true then
            msg = msg .. ', Target NPCs'
        end

        add_to_chat(122, msg)
    end

    if state.EquipStop.value ~= 'off' then
        add_to_chat(122,'Gear equips are blocked after ['..state.EquipStop.value..'].  Use "//gs c reset equipstop" to turn it off.')
    end
end

-- Generic version of this for casters
function display_current_caster_state()
    local msg = ''
    
    if state.OffenseMode.value ~= 'None' then
        msg = msg .. 'Melee'

        if state.CombatForm.has_value then
            msg = msg .. ' (' .. state.CombatForm.value .. ')'
        end
        
        msg = msg .. ', '
    end
    
    msg = msg .. 'Casting ['..state.CastingMode.value..'], Idle ['..state.IdleMode.value..']'
    
    if state.DefenseMode.value ~= 'None' then
        msg = msg .. ', ' .. 'Defense: ' .. state.DefenseMode.value .. ' (' .. state[state.DefenseMode.value .. 'DefenseMode'].value .. ')'
    end
    
    if state.Kiting.value == true then
        msg = msg .. ', Kiting'
    end

    if state.PCTargetMode.value ~= 'default' then
        msg = msg .. ', Target PC: '..state.PCTargetMode.value
    end

    if state.SelectNPCTargets.value == true then
        msg = msg .. ', Target NPCs'
    end

    add_to_chat(122, msg)
end


-------------------------------------------------------------------------------------------------------------------

-- Function to show what commands are available, and their syntax.
-- Syntax: gs c help
-- Or: gs c
function handle_help(cmdParams)
    if cmdParams[1] and cmdParams[1]:lower():startswith('field') then
        print('Predefined Library Fields:')
        print('--------------------------')
        print('OffenseMode, HybridMode, RangedMode, WeaponskillMode')
        print('CastingMode, IdleMode, RestingMode, Kiting')
        print('DefenseMode, PhysicalDefenseMode, MagicalDefenseMode')
        print('SelectNPCTargets, PCTargetMode')
        print('EquipStop (precast, midcast, pet_midcast)')
    else
        print('Custom Library Self-commands:')
        print('-----------------------------')
        print('Show TP Set:      gs c showtp')
        print('Toggle bool:      gs c toggle [field]')
        print('Cycle list:       gs c cycle [field] [(r)everse]')
        print('Cycle list back:  gs c cycleback [field]')
        print('Reset a state:    gs c reset [field]')
        print('Reset all states: gs c reset all')
        print('Set state var:    gs c set [field] [value]')
        print('Set bool true:    gs c set [field]')
        print('Set bool false:   gs c unset [field]')
        print('Remove gear:      gs c naked')
        print('Show TP Set:      gs c showtp')
        print('State vars:       gs c help field')
    end
end


-- A function for testing lua code.  Called via "gs c test".
function handle_test(cmdParams)
    if user_test then
        user_test(cmdParams)
    elseif job_test then
        job_test(cmdParams)
    end
end


-------------------------------------------------------------------------------------------------------------------
-- The below table maps text commands to the above handler functions.
-------------------------------------------------------------------------------------------------------------------

selfCommandMaps = {
    ['toggle']   = handle_toggle,
    ['cycle']    = handle_cycle,
    ['cycleback']= handle_cycleback,
    ['set']      = handle_set,
    ['reset']    = handle_reset,
    ['unset']    = handle_unset,
    ['update']   = handle_update,
    ['showtp']   = handle_showtp,
    ['naked']    = handle_naked,
    ['help']     = handle_help,
    ['test']     = handle_test}


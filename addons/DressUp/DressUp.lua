-- Copyright © 2013-2017, Cairthenn
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of DressUp nor the
      -- names of its contributors may be used to endorse or promote products
      -- derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL Cairthenn BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'DressUp'
_addon.author = 'Cair'
_addon.version = '1.21'
_addon.commands = {'DressUp','du'}


packets = require('packets')
require('luau')
require('helper_functions')
require('static_variables')


models = {}
require('head')
require('body')
require('hands')
require('legs')
require('feet')

settings = config.load(defaults)
info = T{
    names = T{},
    self = T{},
    party = S{}
}

model_names = S{"Face","Race","Head","Body","Hands","Legs","Feet","Main","Sub","Ranged"}

local initialize = function()
    local player = windower.ffxi.get_player()
    info.self.name = player.name:lower()
    info.self.id = player.id
    info.self.index = player.index

    if not settings[info.self.name] then
        settings[info.self.name] = {}
    end

    print_blink_settings("global")
    if load_profile(player.main_job) then
        notice('Loaded profile: ' .. player.main_job)
    end

    update_model(info.self.index)
end

windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in then
        initialize()
    end
end)

windower.register_event('login', initialize)

windower.register_event('logout', function()
    info.self:clear()
end)

windower.register_event('job change',function(job)
    if load_profile(res.jobs[job].name) then
        update_model(info.self.index)
        notice('Loaded profile: ' .. res.jobs[job].name)
    end
end)


local modify_gear = function(packet, name, freeze, models)
    local modified = false

    for k, v in pairs(packet) do
        if model_names[k] then
            if rawget(settings, name) and settings[name][k:lower()] then
                -- Settings for individuals
                packet[k] = settings[name][k:lower()]
                modified = true
            elseif table.containskey(settings.replacements[k:lower()], tostring(v)) then
                -- Replace specific gear
                packet[k] = settings.replacements[k:lower()][tostring(v)]
                modified = true
            elseif freeze and models and models[k] then
                -- Swap the model values from memory to the packet to prevent blinking
                packet[k] = models[k]
                modified = true
            end
        end
    end  

    return modified, packet
end

windower.register_event('incoming chunk',function (id, _, data)
    
    if id ~= 0x00A and id ~= 0x00D and id ~= 0x051 then
        return
    end

    local packet = packets.parse('incoming', data)
    local modified

    -- Processing based on packet type
    if id == 0x00A then
        info.self.id = packet['Player']
        info.self.index = packet['Player Index']
        info.self.name = packet['Player Name']:lower()
        modified,packet = modify_gear(packet, info.self.name)
        return modified and packets.build(packet)
    end

    if id == 0x0D and not packet['Update Model'] then
        return
    end

    local char_id = packet.Player or info.self.id
    local char_index = packet.Index or info.self.index
    local character = windower.ffxi.get_mob_by_index(char_index or -1)
    local blink_type, name = 'others'
    local models

    if character and character.models and table.length(character.models) == 9 and
        (id == 0x051 or (id == 0x00D and character.id == packet.Player) ) then
        models = T{
            Race    = character.race,
            Face    = character.models[1],
            Head    = character.models[2]+0x1000,
            Body    = character.models[3]+0x2000,
            Hands   = character.models[4]+0x3000,
            Legs    = character.models[5]+0x4000,
            Feet    = character.models[6]+0x5000,
            Main    = character.models[7]+0x6000,
            Sub     = character.models[8]+0x7000,
            Ranged  = character.models[9]+0x8000}
    end

    if not info.names[char_id] then
        if packet['Update Name'] then
            info.names[char_id] = packet['Character Name']:lower()
        elseif character then
            info.names[char_id] = character.name:lower()
        else
            return
        end
    end

    local player = windower.ffxi.get_player()

    if player.follow_index == char_index then
        blink_type = "follow"
    elseif character and character.in_alliance then
        blink_type = "party"
    else
        blink_type = "others"
    end

    if info.names[char_id] == info.self.name then
        name = info.self.name
        blink_type = "self"
    elseif settings[info.names[char_id]] then
        name = info.names[char_id]
    else
        name = "others"
    end
    
    -- Model ID 0xFFFF in ranged slot signifies a monster. This prevents undesired results.
    modified,packet = modify_gear(packet, name, blink_logic(blink_type, char_index, player), models)
    return packet['Ranged'] ~= 0xFFFF and modified and packets.build(packet)
end)

--[[windower.register_event('outgoing chunk',function (id, data)
    if id == 0x17 then
        -- Block the NPC/armor mismatch error packet
        return true
    end
end)
-- It appear that blocking this packet might have been causing people to not show up occasionally.
-- Rather than an unnatural error packet, it might be a normal part of client-server communication.]]

windower.register_event('addon command', function (command,...)
    command = command and command:lower() or 'help'
    local args = T{...}:map(string.lower)
    local _clear = nil
    
    if command == 'help' then
        print(helptext)
    elseif command == "eval" then
        assert(loadstring(L{...}:concat(' ')))()
    
    elseif command == "autoupdate" or command == "au" then
        settings.autoupdate = not settings.autoupdate
        notice("AutoUpdate setting is now "..tostring(settings.autoupdate)..".")
        
    elseif command == "save" or command == "s" then
        save_profile(args:concat(''))
    
    elseif command == "load" or command == "l" then
        if load_profile(args:concat('')) then
            notice('Loaded profile: ' .. args:concat(''))
        else
            error('Failed to find a profile named: ' .. args:concat(''))
        end
    
    elseif command == "delete" or command == "d" then
        if settings.profiles[args:concat(''):lower()] then
            settings.profiles[args:concat(''):lower()] = nil
            notice('Deleted profile: ' .. args:concat(''))
        else
            error('Failed to find a profile named: ' .. args:concat(''))
        end
   ----------------------------------------------------------
    --------------- Commands for model changes ---------------
    ----------------------------------------------------------
    
    elseif T{"self","others","player"}:contains(command) then
        if not args[1] then
            error("That is not a valid selection.")
            return
        end
        
        if command == "player" then
            command = args:remove(1)
        elseif command == "self" then
            command = info.self.name
        end
        
        if not settings[command] then
            settings[command] = {}
        end
        
        local _selection = S{"head","body","hands","legs","feet","main","sub","ranged","race","face"}:contains(args[1]) and args:remove(1)

        if not _selection then
            error("That is not a valid selection.")
            return    
        elseif _selection == "race" then
            if not args[1] then
                error("Please specify a race.")
                return
            elseif table.containskey(_races,args[1]) then 
                if args[1] == "mithra" or args[1] == "galka" then
                    settings[command]["race"] = _races[args[1]]
                elseif args[2] and S{"male","female","m","f"}:contains(args[2]) then
                    settings[command]["race"] = _races[args[1]][args[2]]
                else
                    error("Please specify male or female.")
                    return
                end
                
            elseif S{0,1,2,3,4,5,6,7,8}:contains(tonumber(args[1])) then
                settings[command]["race"] = tonumber(args[1])
            end
        
        elseif _selection == "face" then
            if not args[1] then
                error("Please specify a face.")
                return
            elseif table.containskey(_faces,args[1]) then
                settings[command]["face"] = _faces[args[1]]
            elseif S{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,29,30}:contains(tonumber(args[1])) then
                settings[command]["face"] = tonumber(args[1])
            end
        
        else
            if not args[1] then
                error("Please specify an item.")
                return
            else                    
                local item_id = tonumber(args[1]) or get_item_id(args[1],_selection)
                if not item_id then
                    error("That item is not recognized.")
                    return    
                elseif table.containskey(models[_selection],item_id) then
                    if models[_selection][item_id] == ' ' then 
                        error("That item has not been identified.")
                        return
                    else
                        settings[command][_selection] = models[_selection][item_id].model
                    end
                else
                    error("That is not the correct item type.")
                    return
                end
            end
        end
        
    ----------------------------------------------------------
    ---------------- Commands for blink rules ----------------
    ----------------------------------------------------------
    
    elseif S{"blinking","blinkmenot","bmn"}:contains(command) then
        if not args[1] or args[1] == "settings" then
            _print = S{"self","others","party","all","follow"}:contains(args[2]) and args[2] or "global"
            print_blink_settings(_print)
            return
        else
            local _one = S{"self","others","party","follow","all"}:contains(args[1]) and args[1]
            local _two = S{"target","always","combat","all"}:contains(args[2]) and args[2]
            local _blinkbool
            if args[3] and S{"on","off","true","false","t","f"}:contains(args[3]) then
                _blinkbool = (S{"on","true","t"}:contains(args[3]) and true) or (S{"off","false","f"}:contains(args[3]) and false)
            else
                _blinkbool = "flip"
            end
            
            if _one and _two then
                if _blinkbool == "flip" then
                    if _two == "all" then
                        error("Specify [on/off] for selection 'all'.")
                        return
                    else
                        settings.blinking[_one][_two] = not settings.blinking[_one][_two]
                        print_blink_settings(_one)
                    end
                else
                    if _two == "all" then
                        settings.blinking[_one]["target"] = _blinkbool
                        settings.blinking[_one]["always"] = _blinkbool
                        settings.blinking[_one]["combat"] = _blinkbool
                    else
                        settings.blinking[_one][_two] = _blinkbool
                    end
                    print_blink_settings(_one)
                end
            else
                error("Invalid selections for blinking.")
                return
            end
        end
        
    ----------------------------------------------------------
    ------------- Commands for clearing settings -------------
    ----------------------------------------------------------
    
    elseif S{"clear","remove","delete"}:contains(command) then
        if not args[1] then
            error("Please specify something to clear.")
            return
        end
        _clear = S{"replacements","self","others","player"}:contains(args[1]) and args:remove(1)
        if _clear == "player" then
            _clear = args:remove(1)
        elseif _clear == "self" then
            _clear = info.self.name
        end
        
        local _selection = S{"head","body","hands","legs","feet","main","sub","ranged","race","face"}:contains(args[1]) and args:remove(1)
        if not _clear then
            error("Invalid clearing selection.")
            return
        elseif _clear == "replacements" then
            if not _selection and settings[_clear] then
                settings[_clear] = { face = {}, race = {}, head = {}, body = {}, hands = {}, legs = {}, feet = {}, main = {}, sub = {}, ranged = {} }
            elseif not args[1] then
                settings[_clear][_selection] = {}
            elseif args[1] and settings[_clear][_selection] then
                --To do: Expand on this to lookup keys for specified choices
                settings[_clear][_selection][args[1]] = nil
            else
                error("The specified settings do not exist.")
                return
            end
        else
            if not _selection and settings[_clear] then
                settings[_clear] = {}
            elseif settings[_clear][_selection] then
                settings[_clear][_selection] = nil
            
            else
                error("The specified settings do not exist.")
                return
            end
        end
    
    ----------------------------------------------------------
    -------------- Commands for 1:1 replacement --------------
    ----------------------------------------------------------
    elseif S{"replacements","replace","switch"}:contains(command) then
        if not args[1] then
            error("Please specify something to replace.")
            return
        end
        local _models = {}
        local _selection = S{"head","body","hands","legs","feet","main","sub","ranged","race","face"}:contains(args[1]) and args:remove(1)
        
        if not _selection then
            error("That is not a valid selection.")
            return    
        elseif _selection == "race" then
            local _working = true
            while #_models ~= 2 do
                if not args[1] then
                    error("Please specify a race for #"..#_models + 1)
                    return
                elseif table.containskey(_races,args[1]) then 
                    if args[1] == "mithra" or args[1] == "galka" then
                        table.append(_models,_races[args:remove(1)])
                    elseif args[2] and S{"male","female","m","f"}:contains(args[2]) then
                        table.append(_models,_races[args:remove(1)][args:remove(1)])
                    else
                        error("Please specify male or female for #"..#_models + 1)
                        return
                    end
                    
                elseif S{0,1,2,3,4,5,6,7,8}:contains(tonumber(args[1])) then
                    table.append(_models,tonumber(args:remove(1)))
                end
            end
        elseif _selection == "face" then
            while #_models ~= 2 do
                if not args[1] then
                    error("Please specify a face for #"..#_models + 1)
                    return
                elseif table.containskey(_faces,args[1]) then
                    table.append(_models,_faces[args:remove(1)])
                elseif S{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,29,30}:contains(tonumber(args[1])) then
                    table.append(_models,tonumber(args:remove(1)))
                end
            end
        else
            while #_models ~= 2 do
                if not args[1] then
                    error("Please specify an item.")
                    return
                else                    
                    local item_id = tonumber(args[1]) or get_item_id(args[1],_selection)
                    args:remove(1)
                    if not item_id then
                        error("Item #".. #_models + 1 .." is not recognized.")
                        return    
                    elseif table.containskey(models[_selection],item_id) then
                        if models[_selection][item_id] == ' ' then 
                            error("Item #".. #_models + 1 .." has not been identified.")
                            return
                        else
                            table.append(_models,models[_selection][item_id].model)
                        end
                    else
                        error("Item #".. #_models + 1 .." is not the correct type.")
                        return
                    end
                end
            end
        end
        
        if #_models == 2 then
            settings.replacements[_selection][tostring(_models[1])] = tostring(_models[2])
        else
            error("Something went wrong!")
            return
        end
    end
    if settings.autoupdate and ((command == info.self.name) or (_clear == info.self.name)) then
        update_model(windower.ffxi.get_player().index)
    end
    
    settings:save('all')
end)

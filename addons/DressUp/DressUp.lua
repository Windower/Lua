-- Copyright (c) 2013, Cairthenn
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
_addon.author = 'Cairthenn'
_addon.version = '1.0'
_addon.commands = {'DressUp','du'}

--Libs
config = require('config')
require('luau')

--DressUp files


require('helper_functions')
require('static_variables')
models = {}
require('head')
require('body')
require('hands')
require('legs')
require('feet')

windower.register_event('load','login',function ()
    settings = config.load(defaults)
    _char = nil
    if windower.ffxi.get_player() then
        _char = windower.ffxi.get_player().name:lower()
        if not settings[_char] then settings[_char] = {} end
        print_blink_settings("global")
    end
    zone_reset = 2
end)

windower.register_event('logout',function() _char = nil end)

windower.register_event('incoming chunk',function (id, data)
    if id == 0x0a then
        if not _char then return end
        local _ignore = data:sub(1,68)
        local self = T{ Face = data:byte(69), Race = data:byte(70), 
                        Head = data:byte(71) + 256*data:byte(72),
                        Body = data:byte(73) + 256*data:byte(74),
                        Hands = data:byte(75) + 256*data:byte(76),
                        Legs = data:byte(77) + 256*data:byte(78),
                        Feet = data:byte(79) + 256*data:byte(80),
                        Main = data:byte(81) + 256*data:byte(82),
                        Sub = data:byte(83) + 256*data:byte(84),
                        Ranged = data:byte(85) + 256*data:byte(86),
                        }
        local _end = data:sub(87)
        
        for k,v in pairs(self) do
            if S{"Face","Race","Head","Body","Hands","Legs","Feet","Main","Sub","Ranged"}:contains(k) and v ~= 0 then
                if settings[_char][k:lower()] then
                    self[k] = Int2LE(settings[_char][k:lower()],k)
                elseif table.containskey(settings.replacements[k:lower()],tostring(v)) then
                    self[k] = Int2LE(settings.replacements[k:lower()][tostring(v)],k)
                else
                    self[k] = Int2LE(v,k)
                end
            end
        end  
            
        return  _ignore..self["Face"]..self["Race"]..self["Head"]..self["Body"]..self["Hands"]..
                      self["Legs"]..self["Feet"]..self["Main"]..self["Sub"]..self["Ranged"].._end
    
    elseif id == 0x51 then
        if not _char then return end
        
        local _ignore = data:sub(1,4)
        local self = T{ Face = data:byte(5), Race = data:byte(6), 
                        Head = data:byte(7) + 256*data:byte(8),
                        Body = data:byte(9) + 256*data:byte(10),
                        Hands = data:byte(11) + 256*data:byte(12),
                        Legs = data:byte(13) + 256*data:byte(14),
                        Feet = data:byte(15) + 256*data:byte(16),
                        Main = data:byte(17) + 256*data:byte(18),
                        Sub = data:byte(19) + 256*data:byte(20),
                        Ranged = data:byte(21) + 256*data:byte(22),
                        }
        local _end = data:sub(23)
        
        for k,v in pairs(self) do
            if S{"Face","Race","Head","Body","Hands","Legs","Feet","Main","Sub","Ranged"}:contains(k) and v ~= 0 then
                if settings[_char][k:lower()] then
                    self[k] = Int2LE(settings[_char][k:lower()],k)
                elseif table.containskey(settings.replacements[k:lower()],tostring(v)) then
                    self[k] = Int2LE(settings.replacements[k:lower()][tostring(v)],k)
                else
                    self[k] = Int2LE(v,k)
                end
            end
        end
            
        local blink_type = windower.ffxi.get_player().autorun and "follow" or "self"
        block = blink_logic(blink_type,windower.ffxi.get_player().index)
        
        -- Model ID 0xFFFF in ranged slot signifies a monster. This prevents undesired results.
        if self["Ranged"] ~= string.char(0xFF,0xFF) then
            return block or _ignore..self["Face"]..self["Race"]..self["Head"]..self["Body"]..self["Hands"]..
                      self["Legs"]..self["Feet"]..self["Main"]..self["Sub"]..self["Ranged"].._end
        end
    elseif id == 0x00d then
                       
            local _ignore = data:sub(1,68)
            local pc = T{   Face = data:byte(69), Race = data:byte(70), 
                            Head = data:byte(71) + 256*data:byte(72),
                            Body = data:byte(73) + 256*data:byte(74),
                            Hands = data:byte(75) + 256*data:byte(76),
                            Legs = data:byte(77) + 256*data:byte(78),
                            Feet = data:byte(79) + 256*data:byte(80),
                            Main = data:byte(81) + 256*data:byte(82),
                            Sub = data:byte(83) + 256*data:byte(84),
                            Ranged = data:byte(85) + 256*data:byte(86),
                            }
            local _end = data:sub(87)
            
            local _Index = data:byte(9) + 256*data:byte(10)
            local character = windower.ffxi.get_mob_by_index(_Index)
            local blink_type = "others"
            local block = false
            local return_packet = false
            -- Name is used to check for custom model settings, blink_type is similar but passes arguments to blink logic.
            
            if character then
                if windower.ffxi.get_player().follow_index == character.index then
                    blink_type = "follow"
                elseif character.in_alliance then
                    blink_type = "party"
                else
                    blink_type = "others"
                end
                
                if character.name == windower.ffxi.get_player().name then
                    name = _char
                    blink_type = "self"
                elseif settings[character.name:lower()] then
                    name = character.name:lower()
                else
                    name = "others"
                end
            else
                name = "others"
            end
            
            for k,v in pairs(pc) do
                if S{"Face","Race","Head","Body","Hands","Legs","Feet","Main","Sub","Ranged"}:contains(k) and v ~= 0 then
                    if settings[name][k:lower()] then
                        pc[k] = Int2LE(settings[name][k:lower()],k)
                        return_packet = true
                    elseif table.containskey(settings.replacements[k:lower()],tostring(v)) then
                        pc[k] = Int2LE(settings.replacements[k:lower()][tostring(v)],k)
                        return_packet = true
                    else
                        pc[k] = Int2LE(v,k)
                    end
                end
            end    
            
            --Begin blinking region
            
            if character then
                if model_mask:contains(data:byte(11)) then
                    block = blink_logic(blink_type,character.index)
                    if block == true then return_packet = true end
                end
            end
            
            --End blinking region
            
            -- Prevents superfluous returning of the PC Update packet by only doing so if the requirements are flagged
            if return_packet and pc["Ranged"] ~= string.char(0xFF,0xFF) then
                return block or _ignore..pc["Face"]..pc["Race"]..pc["Head"]..pc["Body"]..pc["Hands"]..
                       pc["Legs"]..pc["Feet"]..pc["Main"]..pc["Sub"]..pc["Ranged"].._end
            end
    end
end
)

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
            command = _char
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
            _clear = _char
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
    if settings.autoupdate and ((command == _char) or (_clear == _char)) then
        local _requestindex = Int2LE(windower.ffxi.get_player().index,2)
        windower.packets.inject_outgoing(0x16,string.char(0,0,0,0).._requestindex..string.char(0,0))
    end
    
    settings:save('all')
end)

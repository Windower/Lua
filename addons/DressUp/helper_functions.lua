-- Copyright © 2013-2015, Cairthenn
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

function get_item_id(str,slot)
    local item_result = false
    
    if str == "none" then
        return "None"
    else
    
        for k,v in pairs(models[slot]) do
            if v['enl'] == str or v['name'] == str then
                item_result = k
            end
        end
        if item_result then 
            return tonumber(item_result)
        else
            return false
        end
    end
end

function update_model(index)
    packets.inject(packets.new('outgoing', 0x016, { ['Target Index'] = index }))
end

function load_profile(name)

    if settings.profiles[windower.ffxi.get_player().name:lower() ..'_'.. name:lower()] then
        settings[windower.ffxi.get_player().name:lower()]:update(settings.profiles[windower.ffxi.get_player().name:lower() ..'_'.. name:lower()])
        return true
    elseif settings.profiles[name:lower()] then
        settings[windower.ffxi.get_player().name:lower()]:update(settings.profiles[name:lower()])
        return true
    end
    
    return false
end

function save_profile(name)
    if not name or name:len() == 0 then 
        error('No profile name was entered.') 
    end
    
    if not settings.profiles[name:lower()] then settings.profiles[name:lower()] = T{} end    
    settings.profiles[name:lower()]:update(settings[windower.ffxi.get_player().name:lower()])
    notice('Saved your current settings to the profile: ' .. name)
end

function blink_logic(blink_type,character_index,player)
    if settings.blinking["all"]["always"] then
        return true
    elseif settings.blinking[blink_type]["always"] then
        return true
    end
    
    if settings.blinking["all"]["combat"] and player.in_combat then
        return true
    elseif settings.blinking[blink_type]["combat"] and player.in_combat then
        return true
    end

    if settings.blinking["all"]["target"] and player.target_index == character_index then
        return true
    elseif settings.blinking[blink_type]["target"] and player.target_index == character_index then
        return true
    end
    
    return false
end

function print_blink_settings(option)
    print('DressUp (v'.._addon.version..') Blink Prevention Settings') 
    if option == "global" or option == "all" then
    print(('All:    '):text_color(255,255,255)..table.concat(map(settings.blinking["all"],formatting)," "))
    end
    if option == "global" or option == "self" then
    print(('Self:   '):text_color(255,255,255)..table.concat(map(settings.blinking["self"],formatting)," "))
    end
    if option == "global" or option == "others" then
    print(('Others: '):text_color(255,255,255)..table.concat(map(settings.blinking["others"],formatting)," "))
    end
    if option == "global" or option == "party" then
    print(('Party:  '):text_color(255,255,255)..table.concat(map(settings.blinking["party"],formatting)," "))
    end
    if option == "global" or option == "follow" then
    print(('Follow: '):text_color(255,255,255)..table.concat(map(settings.blinking["follow"],formatting)," "))
    end
end

function map(t, func)
  local out = {}
  for k,v in pairs(t) do
    out[k] = func(k, v)
  end
  return out
end

function formatting(k, v) 
    v = tostring(v):gsub("^%l", string.upper)
    if windower.wc_match(v,"True") then
        v = ('T'):text_color(0, 255, 0)
    else
        v = 'F'
    end
  return k:gsub("^%l", string.upper) ..': ['..v..']' 
end

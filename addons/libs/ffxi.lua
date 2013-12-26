--[[
A few functions to interface ingame structures and values.
]]

local ffxi = {}

_libs = _libs or {}
_libs.ffxi = ffxi
_libs.tablehelper = _libs.tablehelper or require('tablehelper')
_libs.stringhelper = _libs.stringhelper or require('stringhelper')
_libs.functions = _libs.functions or require('functions')
_libs.json = _libs.json or require('json')

ffxi.data = _libs.json.read('../libs/ffxidata.json')

-- Returns ingame time from server time.
-- TODO: Waiting on server-time interface function.
function ffxi.get_time(time)
    return 4
end

-- Returns the game time from the float-representation.
function ffxi.format_time(time)
    time = tostring(math.round(time, 2)):split('.')
    local hours = time[1]:zfill(2)
    local minutes = time[2]:zfill(2)
    return hours..':'..minutes
end

-- Returns the element of the storm effect currently on the player. If none present, returns nil.
function ffxi.get_storm()
    for storm, element in pairs(ffxi.data.elements.storms) do
        if T(windower.ffxi.get_player()['buffs']):contains(storm) then
            return element
        end
    end

    return nil
end

-- Prints a list of icons and their keys to the chatlog.
function ffxi.showicons()
    for key, val in pairs(ffxi.data.chat.icons) do
        log('Icon', 'ffxi.data.chat.icons.'..key..':', val)
    end
end

-- Prints a list of chars and their keys to the chatlog.
function ffxi.showchars()
    for key, val in pairs(ffxi.data.chat.chars) do
        log('Icon', 'ffxi.data.chat.chars.'..key..':', val)
    end
end

-- Prints the game colors and their IDs.
function ffxi.showcolors()
    for key, val in pairs(ffxi.data.chat.colors) do
        log('Color', 'ffxi.data.chat.colors.'..key..':', ('Color sample text.'):color(val))
    end
end

-- Returns the target's id.
function ffxi.target_id(default)
    return windower.ffxi.get_mob_by_index(windower.ffxi.get_player()['target_index'])['id'] or default
end

-- Returns the target's name.
function ffxi.target_name(default)
    return windower.ffxi.get_mob_by_index(windower.ffxi.get_player()['target_index'])['name'] or default
end

-- Returns a name based on an id.
function ffxi.id_to_name(id)
    return windower.ffxi.get_mob_by_id(id)['name']
end

-- Returns a name based on an index.
function ffxi.index_to_name(index)
    return windower.ffxi.get_mob_by_index(index)['name']
end

return ffxi

--[[
Copyright (c) 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

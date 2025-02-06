--[[
Copyright © 2024, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of chatmon nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local trigger_class = {}
local meta = {__index = trigger_class}

local function get_match(match)
    if match ~= '<name>' then
        return match
    end

    -- this is done to have parity with the old plugin.
    local player_name = windower.ffxi.get_player().name:lower()
    return '* ' .. player_name .. '|'
                .. player_name .. ' *|*\''
                .. player_name .. '\'*|*('
                .. player_name .. ')*|'
                .. player_name .. '|* '
                .. player_name .. ' *|* '
                .. player_name .. '? *|* '
                .. player_name .. '?|'
                .. player_name .. '? *|'
                .. player_name .. '?|*<'
                .. player_name .. '>*'
end

local field_checkers = {}
function field_checkers.from(trigger, event)
    return trigger.from:contains(event.from)
end

function field_checkers.notFrom(trigger, event)
    return not trigger.notFrom:contains(event.from)
end

function field_checkers.match(trigger, event)
    local match = get_match(trigger.match)
    return windower.wc_match(event.text, match)
end

function field_checkers.notMatch(trigger, event)
    local match = get_match(trigger.notMatch)
    return not windower.wc_match(event.text, match)
end

function field_checkers.sender(trigger, event)
    return windower.wc_match(event.sender, trigger.sender)
end

function field_checkers.notSender(trigger, event)
    return windower.wc_match(event.sender, trigger.notSender)
end

function trigger_class:check(event)
    for k in pairs(self) do
        if field_checkers[k] and not field_checkers[k](self, event) then
            return false
        end
    end

    return true
end

function trigger_class:new(o)
    return setmetatable(o, meta)
end

return trigger_class

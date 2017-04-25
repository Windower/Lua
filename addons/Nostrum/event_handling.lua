--[[Copyright © 2014-2017, trv
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Nostrum nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL trv BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.--]]

events = {
    ['load'] = true,
    ['unload'] = true,
    ['mouse input'] = true,
    ['keyboard input'] = true,
    ['addon command'] = true,
    ['hp change'] = true, -- any time hp changes for an alliance member
    ['tp change'] = true, -- any time tp changes for an alliance member
    ['mp change'] = true,  -- any time mp changes for an alliance member
    ['hpp change'] = true, -- any time hpp changes for an alliance member
    ['mpp change'] = true, -- any time mpp changes for an alliance member
    ['target change'] = true,
    ['target hpp change'] = true,
    ['member join'] = true, -- any addition to the alliance
    ['member leave'] = true,
    ['member zone'] = true,
    ['member appear'] = true,
    ['member disappear'] = true, -- any time an alliance member moves greater than 50 yalms away
    ['zoning'] = true, -- any time the player would receive the "downloading data" screen
    ['zone change'] = true, -- any time the player zones
    ['buff change'] = true, -- any time a buff table changes
    ['buff gain'] = true, -- any time a party member gains a buff
    ['buff loss'] = true, -- any time a party member loses a buff
    ['new party'] = true, -- any time a new party is created within the alliance
    ['disband party'] = true, -- any time a party's count reaches zero
    ['distance change'] = true, -- any time the distance between the player and an alliance member changes
    ['job change'] = true,
}

event_registry = {}

--[[
    Nostrum does not wrap any events that return modified
    information. This function would not work in those cases.
--]]

function call_events(event, ...)
    local function_list = event_registry[event]
    
    if not function_list then print('No event registry record!') end
    
    local bail = false
    local start, stop = 1, function_list.n
    
    repeat
        local fn = function_list[start]
        
        if fn then
            local pass, err = _pcall(fn, ...)
            
            if pass then
                bail = err
            else
                print(err)
            end
        end
        
        start = start + 1
    until bail or start > stop

    return bail
end

function nostrum.register_event(event, fn)
    if not events[event] then
        print('Not a valid event: ' .. (tostring(event) or '?'))
        return
    elseif not fn or type(fn) ~= 'function' then
        print('Function expected when registering event')
    end
    
    local n
    local registry = event_registry[event]
    
    for i = 1, registry.n do
        if not registry[i] then
            n = i
            break
        end
    end
    
    if not n then
        n = registry.n + 1
        registry.n = n
    end
    
    registry[n] = fn

    return n
end
 
function nostrum.unregister_event(event, n)
    if not events[event] then
        print('Not a valid event: ' .. (tostring(event) or '?'))
        return
    elseif not n then
        print('Number expected when unregistering event')
        return
    end

    if type(n) == 'number' then
        event_registry[event][n] = nil
    else
        local registry = event_registry[event]
        for i = 1, registry.n do
            if registry[i] == n then
                registry[i] = nil
                return
            end
        end
    end
end

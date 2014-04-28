--[[
A library to make the manipulation of the action packet easier.

The primary functionality provided here are iterators which allow for
easy traversal of the sub-tables within the packet. Example:

=======================================================================================
require 'actions'

function event_action(act)
  action = Action(act) -- constructor

    -- print out all melee hits to the console
    if action:get_category_string() == 'melee' then
        for target in action:get_targets() do -- target iterator
            for subaction in target:get_actions() do -- subaction iterator
                if subaction.message == 1 then -- 1 is the code for messages
                    print(string.format("%s hit %s for %d damage",
                          action:get_actor_name(), target:get_name(), subaction.param))
                end
            end
        end
    end
end
=======================================================================================

]]

_libs = _libs or {}
_libs.actions = true

local category_strings = {
    'melee',
    'ranged_finish',
    'weaponskill_finish',
    'spell_finish',
    'item_finish',
    'job_ability',
    'weaponskill_begin',
    'casting_begin',
    'item_begin',
    'unknown',
    'mob_tp_finish',
    'ranged_begin',
    'avatar_tp_finish',
    'job_ability_unblinkable',
    'job_ability_run'
}

local action = {}
-- Constructor for Actions.
-- Usage: action = Action(raw_action)
function Action(a)
    if a == nil then
        return
    end

    local new_instance = {}
    new_instance.raw = a

    return setmetatable(new_instance, {__index = function(t, k) if rawget(t, k) ~= nil then return t[k] else return action[k] end end})
end

function action.get_category_string(self)
    return category_strings[self.raw['category']]
end

-- Returns the name of this actor if there is one
function action.get_actor_name(self)
    local mob = windower.ffxi.get_mob_by_id(self.raw['actor_id'])

    if mob then
        return mob['name']
    else
        return nil
    end
end

-- Returns an iterator for this action's targets
function action.get_targets(self)
    local targets = self.raw['targets']
    local target_count = self.raw['target_count']
    local i = 0
    return function () 
        i = i + 1
        if i <= target_count then
            return Target(targets[i])
        end
    end
end

local target = {}

-- Constructor for target wrapper
function Target(t)
    if t == nil then
        return
    end

    local new_instance = {}
    new_instance.raw = t

    return setmetatable(new_instance, {__index = target})
end

-- Returns an iterator for this target's subactions
function target.get_actions(self)
    local subactions = self.raw['actions']
    local action_count = self.raw['action_count']
    local i = 0
    return function () 
        i = i + 1
        if i <= action_count then
            return subactions[i]
        end
    end
end

-- Returns the name of this target if there is one
function target.get_name(self)
    local mob = windower.ffxi.get_mob_by_id(self.raw['id'])

    if mob then
        return mob['name']
    else
        return nil
    end
end

--[[
Copyright (c) 2013, Suji
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of actions nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL SUJI BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

--[[
A library to make the manipulation of the action packet easier.

The primary functionality provided here are iterators which allow for
easy traversal of the sub-tables within the packet. Example:

=======================================================================================
require 'actions'

function event_action(act)
  action = Action(act) -- constructor

    -- print out all melee hits to the console
    if actionpacket:get_category_string() == 'melee' then
        for target in actionpacket:get_targets() do -- target iterator
            for action in target:get_actions() do -- subaction iterator
                if action.message == 1 then -- 1 is the code for messages
                    print(string.format("%s hit %s for %d damage",
                          actionpacket:get_actor_name(), target:get_name(), action.param))
                end
            end
        end
    end
end
=======================================================================================

]]

_libs = _libs or {}
_libs.actions = true
_libs.tables = _libs.tables or require 'tables'
local res = require 'resources'

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

-- ActionPacket operations
ActionPacket = {}


local actionpacket = {}
-- Constructor for Actions.
-- Usage: actionpacket = ActionPacket(raw_action)

function ActionPacket.new(a)
    if a == nil then
        return
    end

    local new_instance = {}
    new_instance.raw = a

    return setmetatable(new_instance, {__index = function(t, k) if rawget(t, k) ~= nil then return t[k] else return actionpacket[k] end end})
end


-- Opens a listener event for the action packet at the incoming chunk level before modifications.
-- Passes in the documented act structure and the original action packet string.
function ActionPacket.open_listener(funct)
    if not funct or type(funct) ~= 'function' then return end
    local id = windower.register_event('incoming chunk',function(id, org, modi, is_injected, is_blocked)
        if id == 0x28 then
            local act = windower.packets.parse_action(org)
            funct(act,original)
        end
    end)
    return id
end

function ActionPacket.close_listener(id)
    if not id or type(id) ~= 'number' then return end
    windower.unregister_event(id)
end




function actionpacket:get_category_string()
    return category_strings[self.raw['category']]
end

function actionpacket:get_spell()
    local info = self:get_targets()():get_actions()():get_basic_info()
    if rawget(info,'resource') and rawget(info,'spell_id') and rawget(rawget(res,rawget(info,'resource')),rawget(info,'spell_id')) then
        local copied_line = {}
        for i,v in pairs(rawget(rawget(res,rawget(info,'resource')),rawget(info,'spell_id'))) do
            rawset(copied_line,i,v)
        end
        setmetatable(copied_line,getmetatable(res[rawget(info,'resource')][rawget(info,'spell_id')]))
        return copied_line
    end
end

-- Returns the name of this actor if there is one
function actionpacket:get_actor_name()
    local mob = windower.ffxi.get_mob_by_id(self.raw['actor_id'])

    if mob then
        return mob['name']
    else
        return nil
    end
end

--Returns the id of the actor
function actionpacket:get_id()
	return self.raw['actor_id']
end

-- Returns an iterator for this actionpacket's targets
function actionpacket:get_targets()
    local targets = self.raw['targets']
    local target_count = self.raw['target_count']
    local i = 0
    return function () 
        i = i + 1
        if i <= target_count then
            return Target(self.raw['category'],self.raw['param'],targets[i])
        end
    end
end

local target = {}

-- Constructor for target wrapper
function Target(category,top_level_param,t)
    if t == nil then
        return
    end

    local new_instance = {}
    new_instance.raw = t
    new_instance.category = category
    new_instance.top_level_param = top_level_param

    return setmetatable(new_instance, {__index = function (t, k) if rawget(t, k) ~= nil then return t[k] else return target[k] end end})
end

-- Returns an iterator for this target's actions
function target:get_actions()
    local action_count = self.raw['action_count']
    local i = 0
    return function () 
        i = i + 1
        if i <= action_count then
            return Action(self.category,self.top_level_param,self.raw['actions'][i])
        end
    end
end

-- Returns the name of this target if there is one
function target:get_name()
    local mob = windower.ffxi.get_mob_by_id(self.raw['id'])

    if mob then
        return mob['name']
    else
        return nil
    end
end

local reaction_strings = {
    [1] = 'evade',
    [2] = 'parry',
    [4] = 'block/guard',
    [8] = 'hit'
    -- 12 = blocked?
    }

local animation_strings = {
    [0] = 'main hand',
    [1] = 'off hand',
    [2] = 'left kick',
    [3] = 'right kick',
    [4] = 'daken throw'
    }

local effect_strings = {
    [2] = 'critical hit'
    }

local stagger_strings = {
    }

local add_effect_animation_strings = {}

add_effect_animation_strings['melee'] = {
    [1]   = 'enfire',
    [2]   = 'enblizzard',
    [3]   = 'enaero',
    [4]   = 'enstone',
    [5]   = 'enthunder',
    [6]   = 'enwater',
    [7]   = 'enlight',
    [8]   = 'endark',
    [12]  = 'enblind',
    [14]  = 'enpetrify',
    [21]  = 'endrain',
    [22]  = 'enaspir',
    [23]  = 'enhaste',
    }

add_effect_animation_strings['ranged_finish'] = add_effect_animation_strings['melee']

add_effect_animation_strings['weaponskill_finish'] = {
    [1]   = 'light',
    [2]   = 'darkness',
    [3]   = 'gravitation',
    [4]   = 'fragmentation',
    [5]   = 'distortion',
    [6]   = 'fusion',
    [7]   = 'compression',
    [8]   = 'liquefaction',
    [9]   = 'induration',
    [10]  = 'reverberation',
    [11]  = 'transfixion',
    [12]  = 'scission',
    [13]  = 'detonation',
    [14]  = 'impaction',
    }

add_effect_animation_strings['spell_finish'] = add_effect_animation_strings['weaponskill_finish']

local add_effect_effect_strings = {
    }

local spike_effect_animation_strings = {
    [1]  = 'blaze spikes',
    [2]  = 'ice spikes',
    [3]  = 'dread spikes',
    [4]  = 'water spikes',
    [5]  = 'shock spikes',
    [6]  = 'reprisal',
    [7]  = 'wind spikes',
    [8]  = 'stone spikes',
    [63] = 'counter',
    }

local spike_effect_effect_strings = {
    }

local action = {}

function Action(category,top_level_param,t)
    if category == nil or t == nil then
        return
    end

    local new_instance = {}
    new_instance.raw = t
    new_instance.raw.category = category_strings[category] or category
    new_instance.raw.top_level_param = top_level_param

    return setmetatable(new_instance, {__index = function (t, k) if rawget(t, k) ~= nil then return t[k] else return action[k] or rawget(rawget(t,'raw'),k) end end})
end

function action:get_basic_info()
    local reaction = self:get_reaction_string()
    local animation = self:get_animation_string()
    local effect = self:get_effect_string()
    local stagger = self:get_stagger_string()
    
    local value, resource, spell_id, interruption, action_type = self:get_spell()
    
    return {reaction = reaction, animation = animation, effect=effect,
        stagger = stagger, value = value, resource = resource, spell_id = spell_id,
        interruption = interruption, type = action_type}
end

function action:get_reaction_string()
    local reaction = rawget(rawget(self,'raw'),'reaction')
    return rawget(reaction_strings,reaction) or reaction
end

function action:get_animation_string()
    local animation = rawget(rawget(self,'raw'),'animation')
    return rawget(animation_strings,animation) or animation
end

function action:get_effect_string()
    local effect = rawget(rawget(self,'raw'),'effect')
    return rawget(effect_strings,effect) or effect
end

function action:get_stagger_string()
    local stagger = rawget(rawget(self,'raw'),'stagger')
    return rawget(stagger_strings,stagger) or stagger
end


local cat_to_res_map = {['weaponskill_finish']='weapon_skills', ['spell_finish']='spells',
    ['item_finish']='items', ['job_ability']='job_abilities', ['weaponskill_begin']='weapon_skills',
    ['casting_begin']='spells', ['item_begin']='items', ['mob_tp_finish']='monster_abilities',
    ['avatar_tp_finish']='job_abilities', ['job_ability_unblinkable']='job_abilities',
    ['job_ability_run']='job_abilities'}
local begin_categories = {['weaponskill_begin']=true, ['casting_begin']=true, ['item_begin']=true}
local finish_categories = {['weaponskill_finish']=true, ['spell_finish']=true, ['item_finish']=true,
    ['job_ability']=true, ['mob_tp_finish']=true, ['avatar_tp_finish']=true, ['job_ability_unblinkable']=true,
    ['job_ability_run']=true}
function action:get_spell()
    local category = rawget(rawget(self,'raw'),'category')
    -- It's far more accurate to filter by the resources line.
    
    local function fieldsearch(message_id)
        if not res.action_messages[message_id] then return false end
        local fields = {}
        res.action_messages[message_id].english:gsub("${(.-)}", function(a) if a ~= 'actor' and a ~= 'target' and a ~= 'lb' then rawset(fields,a,true) end end)
        return fields
    end
    
    local message_id = self:get_message_id()
    local fields = fieldsearch(message_id)
    local value = rawget(finish_categories, category) and rawget(rawget(self, 'raw'), 'param')
    local spell_id = rawget(begin_categories, category) and rawget(rawget(self, 'raw'), 'param') or
        rawget(finish_categories, category) and rawget(rawget(self, 'raw'), 'top_level_param')
    local interruption = rawget(begin_categories, category) and rawget(rawget(self, 'raw'), 'top_level_param') == 28787
    if interruption == nil then interruption = false end
    local message = rawget(rawget(self,'raw'),'message')
    
    local msg_id_to_unit_map = {
        [14] = 'shadows',
        [25] = 'HP',
        [31] = 'shadows',
        [112] = 'doom_counter',
        [120] = 'gil',
        [132] = 'damage',
        [133] = 'petra',
        [152] = 'MP',
        [161] = 'damage',
        [162] = 'MP',
        [165] = 'TP',
        [187] = 'damage',
        [224] = 'MP',
        [225] = 'MP',
        [226] = 'TP',
        [227] = 'damage',
        [228] = 'MP',
        [229] = 'damage',
        [231] = 'effects',
        [274] = 'damage',
        [275] = 'MP',
        [276] = 'MP',
        [281] = 'damage',
        [357] = 'HP',
        [358] = 'MP',
        [362] = 'TP',
        [363] = 'TP',
        [366] = 'MP',
        [369] = 'attributes',
        [370] = 'effects',
        [383] = 'HP',
        [400] = 'effects',
        [401] = 'effects',
        [403] = 'attributes',
        [404] = 'effects',
        [405] = 'effects',
        [409] = 'TP',
        [417] = 'attributes',
        [420] = 'roll',
        [422] = 'roll',
        [424] = 'roll',
        [425] = 'roll',
        [451] = 'MP',               --  Devotion
        [452] = 'TP',               --  Shikikiyo
        [454] = 'TP',               --  Absorb-TP
        [519] = 'daze',             --  Quickstep
        [520] = 'daze',             --  Box Step
        [521] = 'daze',             --  Stutter Step
        [530] = 'petrify_counter',  --  Gradual Petrify
        [535] = 'shadows',          --  Blinked Retaliation
        [537] = 'TP',               --  Reverse Flourish
        [557] = 'alexandrite',      --  Using a pouch
        [560] = 'FM',               --  No Foot Rise
        [570] = 'effects',          --  Divine Veil with actor
        [571] = 'effects',          --  Divine Veil without actor
        [572] = 'effects',          --  Sacrifice
        [585] = 'enmity',           --  Libra with actor
        [586] = 'enmity',           --  Libra without actor
        [587] = 'HP',
        [588] = 'MP',
        [589] = 'effects',
        [591] = 'daze',             --  Feather Step
        [603] = 'TH',               --  Treasure Hunter level melee
        [607] = 'effects',
        [608] = 'TH',               --  Bounty Shot
        [642] = 'effects',
        [644] = 'effects',
        [652] = 'TP',               --  TP Drain
        [674] = 'number_of_items',  --  Scavenge
        [730] = 'TP'
        }
    
    local action_type = msg_id_to_unit_map[message_id] or (string.find(message,'${number} points of damage') or
        string.find(message,'drains ${number} HP')) and 'damage' or (string.find(message,
        'recovers ${number} hit points') or string.find(message,'recovers ${number} HP')) and 'HP'
    
    local resource
    if not fields or message_id == 31 then
        -- If there is no message, assume the resources type based on the category.
        resource = rawget(cat_to_res_map,category) or false
    else
        local msgID_to_res_map = {
            [244] = 'job_abilities', -- Mug
            [328] = 'job_abilities', -- BPs that are out of range
            }
        -- If there is a message, interpret the fields.
        resource = msgID_to_res_map[message_id] or fields.spell and 'spells' or
            fields.weapon_skill and 'weapon_skills' or fields.ability and 'job_abilities' or
            fields.item and 'items' or rawget(cat_to_res_map,category)
        local msgID_to_value_map = {
            [240] = 43, -- Hide
            [241] = 43, -- Hide failing
            [303] = 74, -- Divine Seal
            [304] = 75, -- Elemental Seal
            [305] = 76, -- Trick Attack
            [311] = 79, -- Cover
            }
        value = msgID_to_value_map[message_id] or value
    end
    
    -- value will be a number or false
    -- resource will be false or a string
    -- spell_id will either be false or a number
    -- interruption will be a boolean
    return value, resource, spell_id, interruption, action_type
end

function action:get_message_id()
    local message_id = rawget(rawget(self,'raw'),'message')
    return message_id or 0
end

function action:get_additional_effect()
    local add_effect_animation = self:get_additional_effect_animation_string()
    local add_effect_effect = self:get_additional_effect_effect_string()
    return {add_effect_animation = add_effect_animation, add_effect_effect = add_effect_effect}
end

function action:get_additional_effect_animation_string()
    local add_effect_animation = rawget(rawget(self,'raw'),'add_effect_animation')
    return rawget(rawget(add_effect_animation_strings,rawget(rawget(self,'raw'),'category')),add_effect_animation) or add_effect_animation
end

function action:get_additional_effect_effect_string()
    local add_effect_effect = rawget(rawget(self,'raw'),'add_effect_effect')
    return rawget(add_effect_effect_strings,add_effect_effect) or add_effect_effect
end


function action:get_spike_effect()
    local spike_effect_effect = self:get_spike_effect_effect_string()
    local spike_effect_animation = self:get_spike_effect_animation_string()
    return {spike_effect_effect = spike_effect_effect, spike_effect_animation = spike_effect_animation}
end

function action:get_spike_effect_effect_string()
    local spike_effect_effect = rawget(rawget(self,'raw'),'spike_effect_effect')
    return rawget(spike_effect_effect_strings,spike_effect_effect) or spike_effect_effect
end

function action:get_spike_effect_animation_string()
    local spike_effect_animation = rawget(rawget(self,'raw'),'spike_effect_animation')
    return rawget(spike_effect_animation_strings,spike_effect_animation) or spike_effect_animation
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

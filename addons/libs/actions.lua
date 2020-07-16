--[[
A library to make the manipulation of the action packet easier.

The primary functionality provided here are iterators which allow for
easy traversal of the sub-tables within the packet. Example:

=======================================================================================
require('actions')

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

require('tables')

local table = _libs.tables
local res = require('resources')

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

local function act_to_string(original,act)
    if type(act) ~= 'table' then return act end
    
    function assemble_bit_packed(init,val,initial_length,final_length)
        if not init then return init end
        
        if type(val) == 'boolean' then
            if val then val = 1 else val = 0 end
        elseif type(val) ~= 'number' then
            return false
        end
        local bits = initial_length%8
        local byte_length = math.ceil(final_length/8)
        
        local out_val = 0
        if bits > 0 then
            out_val = init:byte(#init) -- Initialize out_val to the remainder in the active byte.
            init = init:sub(1,#init-1) -- Take off the active byte
        end
        out_val = out_val + val*2^bits -- left-shift val by the appropriate amount and add it to the remainder (now the lsb-s in val)
        
        while out_val > 0 do
            init = init..string.char(out_val%256)
            out_val = math.floor(out_val/256)
        end
        while #init < byte_length do
            init = init..string.char(0)
        end
        return init
    end
    
    local react = assemble_bit_packed(original:sub(1,4),act.size,32,40)
    react = assemble_bit_packed(react,act.actor_id,40,72)
    react = assemble_bit_packed(react,act.target_count,72,82)
    react = assemble_bit_packed(react,act.category,82,86)
    react = assemble_bit_packed(react,act.param,86,102)
    react = assemble_bit_packed(react,act.unknown,102,118)
    react = assemble_bit_packed(react,act.recast,118,150)
    
    local offset = 150
    for i = 1,act.target_count do
        react = assemble_bit_packed(react,act.targets[i].id,offset,offset+32)
        react = assemble_bit_packed(react,act.targets[i].action_count,offset+32,offset+36)
        offset = offset + 36
        for n = 1,act.targets[i].action_count do
            react = assemble_bit_packed(react,act.targets[i].actions[n].reaction,offset,offset+5)
            react = assemble_bit_packed(react,act.targets[i].actions[n].animation,offset+5,offset+16)
            react = assemble_bit_packed(react,act.targets[i].actions[n].effect,offset+16,offset+21)
            react = assemble_bit_packed(react,act.targets[i].actions[n].stagger,offset+21,offset+27)
            react = assemble_bit_packed(react,act.targets[i].actions[n].param,offset+27,offset+44)
            react = assemble_bit_packed(react,act.targets[i].actions[n].message,offset+44,offset+54)
            react = assemble_bit_packed(react,act.targets[i].actions[n].unknown,offset+54,offset+85)
            
            react = assemble_bit_packed(react,act.targets[i].actions[n].has_add_effect,offset+85,offset+86)
            offset = offset + 86
            if act.targets[i].actions[n].has_add_effect then
                react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_animation,offset,offset+6)
                react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_effect,offset+6,offset+10)
                react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_param,offset+10,offset+27)
                react = assemble_bit_packed(react,act.targets[i].actions[n].add_effect_message,offset+27,offset+37)
                offset = offset + 37
            end
            react = assemble_bit_packed(react,act.targets[i].actions[n].has_spike_effect,offset,offset+1)
            offset = offset + 1
            if act.targets[i].actions[n].has_spike_effect then
                react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_animation,offset,offset+6)
                react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_effect,offset+6,offset+10)
                react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_param,offset+10,offset+24)
                react = assemble_bit_packed(react,act.targets[i].actions[n].spike_effect_message,offset+24,offset+34)
                offset = offset + 34
            end
        end
    end
    if react then
        while #react < #original do
            react = react..original:sub(#react+1,#react+1)
        end
    else
        print('Action Library failure in '..(_addon.name or 'Unknown Addon')..': Invalid Act table returned.')
    end
    return react
end

-- Opens a listener event for the action packet at the incoming chunk level before modifications.
-- Passes in the documented act structures for the original and modified packets.
-- If a table is returned, the library will treat it as a modified act table and recompose the packet string from it.
-- If an invalid act table is passed, it will silently fail to be returned.
function ActionPacket.open_listener(funct)
    if not funct or type(funct) ~= 'function' then return end
    local id = windower.register_event('incoming chunk',function(id, org, modi, is_injected, is_blocked)
        if id == 0x28 then
            local act_org = windower.packets.parse_action(org)
            act_org.size = org:byte(5)
            local act_mod = windower.packets.parse_action(modi)
            act_mod.size = modi:byte(5)
            return act_to_string(org,funct(act_org,act_mod))
        end
    end)
    return id
end

function ActionPacket.close_listener(id)
    if not id or type(id) ~= 'number' then return end
    windower.unregister_event(id)
end


local actor_animation_twoCC = {
        wh='White Magic',
        bk='Black Magic',
        bl='Blue Magic',
        sm='Summoning Magic',
        te='TP Move',
        ['k0']='Melee Attack',
        ['lg']='Ranged Attack',
    }

function actionpacket:get_animation_string()
    return actor_animation_twoCC[string.char(actor_animation_twoCC[self.raw['unknown']]%256,math.floor(actor_animation_twoCC[self.raw['unknown']]/256))]
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
    new_instance.id = t.id

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
    local message_id = self:get_message_id()
    
    local param, resource, spell_id, interruption, conclusion = self:get_spell()
    
    return {reaction = reaction, animation = animation, effect=effect, message_id = message_id,
        stagger = stagger, param = param, resource = resource, spell_id = spell_id,
        interruption = interruption, conclusion = conclusion}
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
local begin_categories = {['weaponskill_begin']=true, ['casting_begin']=true, ['item_begin']=true, ['ranged_begin']=true}
local finish_categories = {['melee']=true,['ranged_finish']=true,['weaponskill_finish']=true, ['spell_finish']=true, ['item_finish']=true,
    ['job_ability']=true, ['mob_tp_finish']=true, ['avatar_tp_finish']=true, ['job_ability_unblinkable']=true,
    ['job_ability_run']=true}
local msg_id_to_conclusion_map = {
    [26]   = {subject="target", verb="gains",   objects={"HP","MP"}     },
    [31]   = {subject="target", verb="loses",   objects={"shadows"}     },
    [112]  = {subject="target", verb="count",   objects={"doom"}        },
    [120]  = {subject="actor",  verb="gains",   objects={"Gil"}         },
    [132]  = {subject="target", verb="steals",  objects={"HP"}          },
    [133]  = {subject="actor",  verb="steals",  objects={"Petra"}       },
    [152]  = {subject="actor",  verb="gains",   objects={"MP"}          },
    [229]  = {subject="target", verb="loses",   objects={"HP"}          },
    [231]  = {subject="actor",  verb="loses",   objects={"effects"}     },
    [530]  = {subject="target", verb="count",   objects={"petrify"}     }, --  Gradual Petrify
    [557]  = {subject="actor",  verb="gains",   objects={"Alexandrite"} }, --  Using a pouch
    [560]  = {subject="actor",  verb="gains",   objects={"FMs"}         }, --  No Foot Rise
    [572]  = {subject="actor",  verb="steals",  objects={"ailments"}    }, --  Sacrifice
    [585]  = {subject="actor",  verb="has",     objects={"enmity"}      }, --  Libra with actor
    [586]  = {subject="target", verb="has",     objects={"enmity"}      }, --  Libra without actor
    [674]  = {subject="actor",  verb="gains",   objects={"items"}       }, --  Scavenge
    [730]  = {subject="target", verb="has",     objects={"TP"}          },
    }
local expandable = {}
expandable[{1,  2,  67, 77, 110,157,
            163,185,196,197,223,252,
            264,265,288,289,290,291,
            292,293,294,295,296,297,
            298,299,300,301,302,317,
            352,353,379,419,522,576,
            577,648,650,732,767,768}]         = {subject="target", verb="loses",   objects={"HP"}         }
expandable[{122,167,383}]             = {subject="actor",  verb="gains",   objects={"HP"}         }
expandable[{7,  24, 102,103,238,263,
        306,318,357,367,373,382,384,
        385,386,387,388,389,390,391,
        392,393,394,395,396,397,398,
        539,587,606,651,769,770}]             = {subject="target", verb="gains",   objects={"HP"}         }
expandable[{25, 224,276,358,451,588}] = {subject="target", verb="gains",   objects={"MP"}         }
expandable[{161,187,227,274,281}]     = {subject="actor",  verb="steals",  objects={"HP"}         }
expandable[{165,226,454,652}]         = {subject="actor",  verb="steals",  objects={"TP"}         }
expandable[{162,225,228,275,366}]     = {subject="actor",  verb="steals",  objects={"MP"}         }
expandable[{362,363}]                 = {subject="target", verb="loses",   objects={"TP"}         }
expandable[{369,403,417}]             = {subject="actor",  verb="steals",  objects={"attributes"} }
expandable[{370,404,642}]             = {subject="actor",  verb="steals",  objects={"effects"}    }
expandable[{400,570,571,589,607}]     = {subject="target", verb="loses",   objects={"ailments"}   }
expandable[{401,405,644}]             = {subject="target", verb="loses",   objects={"effects"}    }
expandable[{409,452,537}]             = {subject="target", verb="gains",   objects={"TP"}         }
expandable[{519,520,521,591}]         = {subject="target", verb="gains",   objects={"daze"}       }
expandable[{14, 535}]                 = {subject="actor",  verb="loses",   object={"shadows"}     }
expandable[{603,608}]                 = {subject="target", verb="gains",   objects={"TH"}         }
expandable[{33, 44, 536,}]            = {subject="actor",  verb="loses",   objects={"HP"}         }
for ids,tab in pairs(expandable) do
    for _,id in pairs(ids) do
        msg_id_to_conclusion_map[id] = tab
    end
end
local function msg_id_to_conclusion(msg_id)
    return rawget(msg_id_to_conclusion_map,msg_id) or false
end

function action:get_spell()
    local category = rawget(rawget(self,'raw'),'category')
    -- It's far more accurate to filter by the resources line.
    
    local function fieldsearch(message_id)
        if not message_id or not res.action_messages[message_id] or not res.action_messages[message_id].en then return false end
        local fields = {}
        res.action_messages[message_id].en:gsub("${(.-)}", function(a) if a ~= "actor" and a ~= "target" and a ~= 'lb' then rawset(fields,a,true) end end)
        return fields
    end
    
    local message_id = self:get_message_id()
    local fields = fieldsearch(message_id)
    local param = rawget(finish_categories, category) and rawget(rawget(self, 'raw'), 'param')
    local spell_id = rawget(begin_categories, category) and rawget(rawget(self, 'raw'), 'param') or
        rawget(finish_categories, category) and rawget(rawget(self, 'raw'), 'top_level_param')
    local interruption = rawget(begin_categories, category) and rawget(rawget(self, 'raw'), 'top_level_param') == 28787
    if interruption == nil then interruption = false end
        
    local conclusion = msg_id_to_conclusion(message_id)
    
    local resource
    if not fields or message_id == 31 then
        -- If there is no message, assume the resources type based on the category.
        if category == 'weaponskill_begin' and spell_id <= 256 then
            resource = 'weapon_skills'
        elseif category == 'weaponskill_begin' then
            resource = 'monster_abilities'
        else
            resource = rawget(cat_to_res_map,category) or false
        end
    else
        local msgID_to_res_map = {
            [244] = 'job_abilities', -- Mug
            [328] = 'job_abilities', -- BPs that are out of range
            }
        -- If there is a message, interpret the fields.
        resource = msgID_to_res_map[message_id] or fields.spell and 'spells' or
            fields.weapon_skill and spell_id <= 256 and 'weapon_skills' or
            fields.weapon_skill and spell_id > 256 and 'monster_abilities' or
            fields.ability and 'job_abilities' or
            fields.item and 'items' or rawget(cat_to_res_map,category)
        local msgID_to_spell_id_map = {
            [240] = 43, -- Hide
            [241] = 43, -- Hide failing
            [303] = 74, -- Divine Seal
            [304] = 75, -- Elemental Seal
            [305] = 76, -- Trick Attack
            [311] = 79, -- Cover
            }
        spell_id = msgID_to_spell_id_map[message_id] or spell_id
    end
    
    -- param will be a number or false
    -- resource will be a string or false
    -- spell_id will either be a number or false
    -- interruption will be true or false
    -- conclusion will either be a table or false
    
    return param, resource, spell_id, interruption, conclusion
end

function action:get_message_id()
    local message_id = rawget(rawget(self,'raw'),'message')
    return message_id or 0
end

---------------------------------------- Additional Effects ----------------------------------------
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
    [15]  = 'radiance',
    [16]  = 'umbra',
    }

add_effect_animation_strings['spell_finish'] = add_effect_animation_strings['weaponskill_finish']
add_effect_animation_strings['mob_tp_finish'] = add_effect_animation_strings['weaponskill_finish']
add_effect_animation_strings['avatar_tp_finish'] = add_effect_animation_strings['weaponskill_finish']

local add_effect_effect_strings = {}

function action:get_add_effect()
    if not rawget(rawget(self,'raw'),'has_add_effect') then return false end
    local animation = self:get_add_effect_animation_string()
    local effect = self:get_add_effect_effect_string()
    local param = rawget(rawget(self,'raw'),'add_effect_param')
    local message_id = rawget(rawget(self,'raw'),'add_effect_message')
    local conclusion = msg_id_to_conclusion(message_id)
    return {animation = animation, effect = effect, param = param,
        message_id = message_id,conclusion = conclusion}
end

function action:get_add_effect_animation_string()
    local add_effect_animation = rawget(rawget(self,'raw'),'add_effect_animation')
    local add_eff_animation_tab = rawget(add_effect_animation_strings,rawget(rawget(self,'raw'),'category'))
    return add_eff_animation_tab and rawget(add_eff_animation_tab,add_effect_animation) or add_effect_animation
end

function action:get_add_effect_effect_string()
    local add_effect_effect = rawget(rawget(self,'raw'),'add_effect_effect')
    return rawget(add_effect_effect_strings,add_effect_effect) or add_effect_effect
end

function action:get_add_effect_conclusion()
    return msg_id_to_conclusion(rawget(rawget(self,'raw'),'add_effect_message'))
end


------------------------------------------- Spike Effects ------------------------------------------
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
function action:get_spike_effect()
    if not rawget(rawget(self,'raw'),'has_spike_effect') then return false end
    local effect = self:get_spike_effect_effect_string()
    local animation = self:get_spike_effect_animation_string()
    local param = rawget(rawget(self,'raw'),'spike_effect_param')
    local message_id = rawget(rawget(self,'raw'),'spike_effect_message')
    local conclusion = msg_id_to_conclusion(message_id)
    return {animation = animation, effect = effect, param = param,
        message_id = message_id,conclusion = conclusion}
end

function action:get_spike_effect_effect_string()
    local spike_effect_effect = rawget(rawget(self,'raw'),'spike_effect_effect')
    return rawget(spike_effect_effect_strings,spike_effect_effect) or spike_effect_effect
end

function action:get_spike_effect_animation_string()
    local spike_effect_animation = rawget(rawget(self,'raw'),'spike_effect_animation')
    return rawget(spike_effect_animation_strings,spike_effect_animation) or spike_effect_animation
end

function action:get_additional_effect_conclusion()
    return msg_id_to_conclusion(rawget(rawget(self,'raw'),'spike_effect_message'))
end

--[[
Copyright © 2013, Suji
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

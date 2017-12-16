--[[
        Copyright © 2017, SirEdeonX
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of xivhotbar nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL SirEdeonX BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local storage = require('storage')
local action_manager = require('action_manager')

local player = {}

player.name = ''
player.main_job = ''
player.sub_job = ''
player.server = ''

player.vitals = {}
player.vitals.mp = 0
player.vitals.tp = 0

player.hotbar = {}

player.hotbar_settings = {}
player.hotbar_settings.max = 1
player.hotbar_settings.active_hotbar = 1
player.hotbar_settings.active_environment = 'field'

-- initialize player
function player:initialize(windower_player, server, theme_options)
    self.name = windower_player.name
    self.main_job = windower_player.main_job
    self.sub_job = windower_player.sub_job
    self.server = server

    self.hotbar_settings.max = theme_options.hotbar_number

    self.vitals.mp = windower_player.vitals.mp
    self.vitals.tp = windower_player.vitals.tp

    storage:setup(self)
end

-- update player jobs
function player:update_jobs(main, sub)
    self.main_job = main
    self.sub_job = sub

    storage:update_filename(main, sub)
end

-- load hotbar for current player and job combination
function player:load_hotbar()
    self:reset_hotbar()

    -- if hotbar file exists, load it. If not, create a default hotbar
    if storage.file:exists() then
        self:load_from_file()
    else
        self:create_default_hotbar()
    end
end

-- load a hotbar from existing file
function player:load_from_file()
    windower.console.write('XIVHOTBAR: load hotbars for ' .. storage.filename)

    local contents = xml.read(storage.file)

    if contents.name ~= 'hotbar' then
        windower.console.write('XIVHOTBAR: invalid hotbar on ' .. storage.filename)
        return
    end

    -- parse xml to hotbar
    for key, environment in ipairs(contents.children) do
        if environment.name == 'field' or environment.name == 'battle' then
            for key, hotbar in ipairs(environment.children) do     -- hotbar number
                for key, slot in ipairs(hotbar.children) do       -- slot number
                    local new_action = {}

                    for key, action in ipairs(slot.children) do   -- action
                        if action.name == 'type' then
                            new_action.type = action.children[1].value
                        elseif action.name == 'action' then
                            new_action.action = action.children[1].value
                        elseif action.name == 'target' then
                            if action.children[1] == nil then
                                new_action.target = nil
                            else
                                new_action.target = action.children[1].value
                            end

                        elseif action.name == 'alias' then
                            new_action.alias = action.children[1].value
                        elseif action.name == 'icon' then
                            new_action.icon = action.children[1].value
                        end
                    end

                    self:add_action(
                        action_manager:build(new_action.type, new_action.action, new_action.target, new_action.alias, new_action.icon),
                        environment.name,
                        hotbar.name:gsub('hotbar_', ''),
                        slot.name:gsub('slot_', '')
                    )
                end
            end
        end
    end
end

-- create a default hotbar
function player:create_default_hotbar()
    windower.console.write('XIVHotbar: no hotbar found. Creating default for ' .. storage.filename)

    -- add default actions to the new hotbar
    self:add_action(action_manager:build_custom('attack on', 'Attack', 'attack'), 'field', 1, 1)
    self:add_action(action_manager:build_custom('check', 'Check', 'check'), 'field', 1, 2)
    self:add_action(action_manager:build_custom('returntrust all', 'No Trusts', 'return-trust'), 'field', 1, 9)
    self:add_action(action_manager:build_custom('heal', 'Heal', 'heal'), 'field', 1, 0)

    self:add_action(action_manager:build_custom('check', 'Check', 'check'), 'battle', 1, 9)
    self:add_action(action_manager:build_custom('attack off', 'Disengage', 'disengage'), 'battle', 1, 0)

    local new_hotbar = {}
    new_hotbar.hotbar = self.hotbar

    storage:store_new_hotbar(new_hotbar)
end

-- reset player hotbar
function player:reset_hotbar()
    self.hotbar = {
        ['battle'] = {},
        ['field'] = {}
    }

    for h=1,self.hotbar_settings.max,1 do
        self.hotbar.field['hotbar_' .. h] = {}
        self.hotbar.battle['hotbar_' .. h] = {}
    end

    self.hotbar_settings.active_hotbar = 1
end

-- toggle bar environment
function player:toggle_environment()
    if self.hotbar_settings.active_environment == 'battle' then
        self.hotbar_settings.active_environment = 'field'
    else
        self.hotbar_settings.active_environment = 'battle'
    end
end

-- set bar environment to battle
function player:set_battle_environment(in_battle)
    local environment = 'field'
    if in_battle then environment = 'battle' end

    self.hotbar_settings.active_environment = environment
end

-- change active hotbar
function player:change_active_hotbar(new_hotbar)
    self.hotbar_settings.active_hotbar = new_hotbar

    if self.hotbar_settings.active_hotbar > self.hotbar_settings.max then
        self.hotbar_settings.active_hotbar = 1
    end
end

-- add given action to a hotbar
function player:add_action(action, environment, hotbar, slot)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    if slot == 10 then slot = 0 end

    if self.hotbar[environment] == nil then
        windower.console.write('XIVHOTBAR: invalid hotbar (environment)')
        return
    end

    if self.hotbar[environment]['hotbar_' .. hotbar] == nil then
        windower.console.write('XIVHOTBAR: invalid hotbar (hotbar number)')
        return
    end

    if self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] == nil then
        self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] = {}
    end

    self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] = action
end

-- execute action from given slot
function player:execute_action(slot)
    local action = self.hotbar[self.hotbar_settings.active_environment]['hotbar_' .. self.hotbar_settings.active_hotbar]['slot_' .. slot]

    if action == nil then return end

    if action.type == 'ct' then
        local command = '/' .. action.action

        if  action.target ~= nil then
            command = command .. ' <' ..  action.target .. '>'
        end

        windower.chat.input(command)
        return
    end

    windower.chat.input('/' .. action.type .. ' "' .. action.action .. '" <' .. action.target .. '>')
end

-- remove action from slot
function player:remove_action(environment, hotbar, slot)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    if slot == 10 then slot = 0 end

    if self.hotbar[environment] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar] == nil then return end

    self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] = nil
end

-- copy action from one slot to another
function player:copy_action(environment, hotbar, slot, to_environment, to_hotbar, to_slot, is_moving)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    if to_environment == 'b' then to_environment = 'battle' elseif to_environment == 'f' then to_environment = 'field' end
    if slot == 10 then slot = 0 end
    if to_slot == 10 then to_slot = 0 end

    if self.hotbar[environment] == nil or self.hotbar[to_environment] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar] == nil or self.hotbar[to_environment]['hotbar_' .. to_hotbar] == nil then return end

    self.hotbar[to_environment]['hotbar_' .. to_hotbar]['slot_' .. to_slot] = self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot]

    if is_moving then self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] = nil end
end

-- update action alias
function player:set_action_alias(environment, hotbar, slot, alias)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    if slot == 10 then slot = 0 end

    if self.hotbar[environment] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] == nil then return end

    self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot].alias = alias
end

-- update action icon
function player:set_action_icon(environment, hotbar, slot, icon)
    if environment == 'b' then environment = 'battle' elseif environment == 'f' then environment = 'field' end
    if slot == 10 then slot = 0 end

    if self.hotbar[environment] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar] == nil then return end
    if self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot] == nil then return end

    self.hotbar[environment]['hotbar_' .. hotbar]['slot_' .. slot].icon = icon
end

-- save current hotbar
function player:save_hotbar()
    local new_hotbar = {}
    new_hotbar.hotbar = self.hotbar

    storage:save_hotbar(new_hotbar)
end

return player
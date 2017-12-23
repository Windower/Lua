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

local database = require('database')  -- TODO: IMPORT FROM RES

local ui = {}

local text_setup = {
    flags = {
        draggable = false
    }
}

local right_text_setup = {
    flags = {
        right = true,
        draggable = false
    }
}

local images_setup = {
    draggable = false
}

-- ui metrics
ui.hotbar_width = 0
ui.hotbar_spacing = 0
ui.slot_spacing = 0
ui.pos_x = 0
ui.pos_y = 0

-- ui variables
ui.battle_notice = images.new(images_setup)
ui.feedback_icon = nil
ui.hotbars = {}

-- ui theme options
ui.theme = {}

-- ui control
ui.feedback = {}
ui.feedback.is_active = false
ui.feedback.current_opacity = 0
ui.feedback.max_opacity = 0
ui.feedback.speed = 0

ui.disabled_slots = {}
ui.disabled_slots.actions = {}
ui.disabled_slots.no_vitals = {}
ui.disabled_slots.on_cooldown = {}

ui.is_setup = false
-----------------------------
-- Helpers
-----------------------------

-- setup images
function setup_image(image, path)
    image:path(path)
    image:repeat_xy(1, 1)
    image:draggable(false)
    image:fit(true)
    image:alpha(255)
    image:show()
end

-- setup text
function setup_text(text, theme_options)
    text:bg_alpha(0)
    text:bg_visible(false)
    text:font(theme_options.font)
    text:size(theme_options.font_size)
    text:color(theme_options.font_color_red, theme_options.font_color_green, theme_options.font_color_blue)
    text:stroke_transparency(theme_options.font_stroke_alpha)
    text:stroke_color(theme_options.font_stroke_color_red, theme_options.font_stroke_color_green, theme_options.font_stroke_color_blue)
    text:stroke_width(theme_options.font_stroke_width)
    text:show()
end

-- get x position for a given hotbar and slot
function ui:get_slot_x(h, i)
    return self.pos_x + 10 + ((40 + self.slot_spacing) * (i - 1))
end

-- get y position for a given hotbar and slot
function ui:get_slot_y(h, i)
    return self.pos_y - (((h - 1) * self.hotbar_spacing))
end

-----------------------------
-- Setup UI
-----------------------------

-- setup ui
function ui:setup(theme_options)
    database:import()

    self.theme.hide_empty_slots = theme_options.hide_empty_slots
    self.theme.hide_action_names = theme_options.hide_action_names
    self.theme.hide_action_cost = theme_options.hide_action_cost
    self.theme.hide_action_element = theme_options.hide_action_element
    self.theme.hide_recast_animation = theme_options.hide_recast_animation
    self.theme.hide_recast_text = theme_options.hide_recast_text
    self.theme.hide_battle_notice = theme_options.hide_battle_notice

    self.theme.slot_opacity = theme_options.slot_opacity
    self.theme.disabled_slot_opacity = theme_options.disabled_slot_opacity
    self.theme.hotbar_number = theme_options.hotbar_number

    self.theme.mp_cost_color_red = theme_options.mp_cost_color_red
    self.theme.mp_cost_color_green = theme_options.mp_cost_color_green
    self.theme.mp_cost_color_blue = theme_options.mp_cost_color_blue
    self.theme.tp_cost_color_red = theme_options.tp_cost_color_red
    self.theme.tp_cost_color_green = theme_options.tp_cost_color_green
    self.theme.tp_cost_color_blue = theme_options.tp_cost_color_blue

    self:setup_metrics(theme_options)
    self:load(theme_options)

    self.is_setup = true
end

-- load the images and text
function ui:load(theme_options)
    -- load battle notice
    setup_image(self.battle_notice, windower.addon_path .. '/themes/' .. (theme_options.battle_notice_theme:lower()) .. '/notice.png')
    self.battle_notice:pos(self.pos_x + self.hotbar_width - 90, self.pos_y - (theme_options.hotbar_spacing * (theme_options.hotbar_number - 1)) - 24)
    self.battle_notice:hide()

    -- create ui elements for hotbars
    for h=1,theme_options.hotbar_number,1 do
        self.hotbars[h] = {}
        self.hotbars[h].slot_background = {}
        self.hotbars[h].slot_icon = {}
        self.hotbars[h].slot_recast = {}
        self.hotbars[h].slot_frame = {}
        self.hotbars[h].slot_element = {}
        self.hotbars[h].slot_text = {}
        self.hotbars[h].slot_cost = {}
        self.hotbars[h].slot_recast_text = {}
        self.hotbars[h].slot_key = {}

        for i=1,10,1 do
            local slot_pos_x = self:get_slot_x(h, i)
            local slot_pos_y = self:get_slot_y(h, i)
            local right_slot_pos_x = slot_pos_x - windower.get_windower_settings().ui_x_res

            self.hotbars[h].slot_background[i] = images.new(images_setup)
            self.hotbars[h].slot_icon[i] = images.new(images_setup)
            self.hotbars[h].slot_recast[i] = images.new(images_setup)
            self.hotbars[h].slot_frame[i] = images.new(images_setup)
            self.hotbars[h].slot_element[i] = images.new(images_setup)
            self.hotbars[h].slot_text[i] = texts.new(text_setup)
            self.hotbars[h].slot_cost[i] = texts.new(text_setup)
            self.hotbars[h].slot_recast_text[i] = texts.new(text_setup)
            self.hotbars[h].slot_key[i] = texts.new(text_setup)

            setup_image(self.hotbars[h].slot_background[i], windower.addon_path..'/themes/' .. (theme_options.slot_theme:lower()) .. '/slot.png')
            setup_image(self.hotbars[h].slot_icon[i], windower.addon_path..'/images/other/blank.png')
            setup_image(self.hotbars[h].slot_frame[i], windower.addon_path..'/themes/' .. (theme_options.frame_theme:lower()) .. '/frame.png')
            setup_image(self.hotbars[h].slot_element[i], windower.addon_path..'/images/other/blank.png')
            setup_text(self.hotbars[h].slot_text[i], theme_options)
            setup_text(self.hotbars[h].slot_cost[i], theme_options)
            setup_text(self.hotbars[h].slot_recast_text[i], theme_options)
            setup_text(self.hotbars[h].slot_key[i], theme_options)

            self.hotbars[h].slot_cost[i]:size(8)
            self.hotbars[h].slot_cost[i]:stroke_transparency(220)
            self.hotbars[h].slot_background[i]:alpha(theme_options.slot_opacity)
            self.hotbars[h].slot_background[i]:pos(slot_pos_x, slot_pos_y)
            self.hotbars[h].slot_icon[i]:pos(slot_pos_x, slot_pos_y)
            self.hotbars[h].slot_frame[i]:pos(slot_pos_x, slot_pos_y)
            self.hotbars[h].slot_element[i]:pos(slot_pos_x + 28, slot_pos_y - 4)

            self.hotbars[h].slot_text[i]:pos(slot_pos_x, slot_pos_y + 40)
            self.hotbars[h].slot_cost[i]:pos(slot_pos_x, slot_pos_y + 28)
            self.hotbars[h].slot_recast_text[i]:pos(slot_pos_x, slot_pos_y + 14)
            self.hotbars[h].slot_recast_text[i]:size(9)
            self.hotbars[h].slot_key[i]:pos(slot_pos_x - 1, slot_pos_y - 4)
            self.hotbars[h].slot_key[i]:size(9)
            self.hotbars[h].slot_key[i]:alpha(200)

            local key = i
            if i == 10 then key = 0 end

            if h == 3 then
                self.hotbars[h].slot_key[i]:text('c' .. key)
            elseif h == 2 then
                self.hotbars[h].slot_key[i]:text('s' .. key)
            else
                self.hotbars[h].slot_key[i]:text(tostring(key))
            end
        end
    end

    -- load feedback icon last so it stays above everything else
    self.feedback_icon = images.new(images_setup)
    setup_image(self.feedback_icon, windower.addon_path .. '/images/other/feedback.png')
    self.feedback.max_opacity = theme_options.feedback_max_opacity
    self.feedback.speed = theme_options.feedback_speed
    self.feedback.current_opacity = self.feedback.max_opacity
    self.feedback_icon:hide()
end

-- setup positions and dimensions for ui
function ui:setup_metrics(theme_options)
    self.hotbar_width = (400 + theme_options.slot_spacing * 9)
    self.pos_x = (windower.get_windower_settings().x_res / 2) - (self.hotbar_width / 2) + theme_options.offset_x
    self.pos_y = (windower.get_windower_settings().y_res - 120) + theme_options.offset_y

    self.slot_spacing = theme_options.slot_spacing

    if theme_options.hide_action_names == true then
        theme_options.hotbar_spacing = theme_options.hotbar_spacing - 10
        self.pos_y = self.pos_y + 10
    end

    self.hotbar_spacing = theme_options.hotbar_spacing
end

-- hide all ui components
function ui:hide()
    self.battle_notice:hide()
    self.feedback_icon:hide()

    for h=1,self.theme.hotbar_number,1 do
        for i=1,10,1 do
            self.hotbars[h].slot_background[i]:hide()
            self.hotbars[h].slot_icon[i]:hide()
            self.hotbars[h].slot_frame[i]:hide()
            self.hotbars[h].slot_recast[i]:hide()
            self.hotbars[h].slot_element[i]:hide()
            self.hotbars[h].slot_text[i]:hide()
            self.hotbars[h].slot_cost[i]:hide()
            self.hotbars[h].slot_recast_text[i]:hide()
            self.hotbars[h].slot_key[i]:hide()
        end
    end
end

-- show ui components
function ui:show(player_hotbar, environment)
    if self.theme.hide_battle_notice == false and environment == 'battle' then self.battle_notice:show() end

    for h=1,self.theme.hotbar_number,1 do
        for i=1,10,1 do
            local slot = i
            if slot == 10 then slot = 0 end

            local action = player_hotbar[environment]['hotbar_' .. h]['slot_' .. slot]

            if self.theme.hide_empty_slots == false then self.hotbars[h].slot_background[i]:show() end
            self.hotbars[h].slot_icon[i]:show()
            if action ~= nil then self.hotbars[h].slot_frame[i]:show() end
            if self.theme.hide_recast_animation == false then self.hotbars[h].slot_recast[i]:show() end
            if self.theme.hide_action_element == false then self.hotbars[h].slot_element[i]:show() end
            if self.theme.hide_action_names == false then self.hotbars[h].slot_text[i]:show() end
            if self.theme.hide_action_cost == false then self.hotbars[h].slot_cost[i]:show() end
            if self.theme.hide_recast_text == false then self.hotbars[h].slot_recast_text[i]:show() end
            if self.theme.hide_empty_slots == false then self.hotbars[h].slot_key[i]:show() end
        end
    end
end

-----------------------------
-- Actions UI
-----------------------------

-- load player hotbar
function ui:load_player_hotbar(player_hotbar, player_vitals, environment)
    if environment == 'battle' and self.theme.hide_battle_notice == false then
        self.battle_notice:show()
    else
        self.battle_notice:hide()
    end

    -- reset disabled slots
    self.disabled_slots.actions = {}
    self.disabled_slots.no_vitals = {}
    self.disabled_slots.on_cooldown = {}

    for h=1,self.theme.hotbar_number,1 do
        for i=1,10,1 do
            local slot = i
            if slot == 10 then slot = 0 end

            self:load_action(h, i, player_hotbar[environment]['hotbar_' .. h]['slot_' .. slot], player_vitals)
        end
    end
end

-- load action into a hotbar slot
function ui:load_action(hotbar, slot, action, player_vitals)
    local is_disabled = false

    self:clear_slot(hotbar, slot)

    -- if slot is empty, leave it cleared
    if action == nil then
        if self.theme.hide_empty_slots == true then
            self.hotbars[hotbar].slot_background[slot]:hide()
            self.hotbars[hotbar].slot_key[slot]:hide()
        else
            self.hotbars[hotbar].slot_background[slot]:show()
            self.hotbars[hotbar].slot_key[slot]:show()
        end

        return
    end

    -- if slot has a skill (ma, ja or ws)
    if action.type == 'ma' or action.type == 'ja' or action.type == 'ws' then
        local skill = nil

        -- if its magic, look for it in spells
        if action.type == 'ma' and database.spells[(action.action):lower()] ~= nil then
            skill = database.spells[(action.action):lower()]
            self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/icons/spells/' .. (string.format("%05d", skill.icon)) .. '.png')
        elseif (action.type == 'ja' or action.type == 'ws') and database.abilities[(action.action):lower()] ~= nil then
            skill = database.abilities[(action.action):lower()]

            if action.type == 'ja' then
                self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/icons/abilities/' .. string.format("%05d", skill.icon) .. '.png')
            else
                self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/icons/weapons/sword.png')
                skill.tpcost = '1000'
            end
        end


        self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot) + 4, self:get_slot_y(hotbar, slot) + 4) -- temporary fix for 32 x 32 icons
        self.hotbars[hotbar].slot_icon[slot]:show()

        self.hotbars[hotbar].slot_key[slot]:show()
        self.hotbars[hotbar].slot_background[slot]:alpha(200)
        self.hotbars[hotbar].slot_background[slot]:show()

        if skill ~= nil then
            -- display skill element
            if skill.element ~= nil and skill.element ~= 'None' and self.theme.hide_action_element == false then
                self.hotbars[hotbar].slot_element[slot]:path(windower.addon_path .. '/images/icons/elements/' .. skill.element .. '.png')
                self.hotbars[hotbar].slot_element[slot]:show()
            end

            -- display mp cost
            if skill.mpcost ~= nil and skill.mpcost ~= '0' then
                self.hotbars[hotbar].slot_cost[slot]:color(self.theme.mp_cost_color_red, self.theme.mp_cost_color_green, self.theme.mp_cost_color_blue)
                self.hotbars[hotbar].slot_cost[slot]:text(skill.mpcost)

                if player_vitals.mp < tonumber(skill.mpcost) then
                    self.disabled_slots.no_vitals[action.action] = true
                    is_disabled = true
                end
            -- display tp cost
            elseif skill.tpcost ~= nil and skill.tpcost ~= '0' then
                self.hotbars[hotbar].slot_cost[slot]:color(self.theme.tp_cost_color_red, self.theme.tp_cost_color_green, self.theme.tp_cost_color_blue)
                self.hotbars[hotbar].slot_cost[slot]:text(skill.tpcost)

                if player_vitals.tp < tonumber(skill.tpcost) then
                    self.disabled_slots.no_vitals[action.action] = true
                    is_disabled = true
                end
            end
        end
    -- if action is an item
    elseif action.type == 'item' then
        self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot))
        self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/icons/custom/item.png')
        self.hotbars[hotbar].slot_icon[slot]:show()
    else
        self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot))
    end

    -- if action is custom
    if action.icon ~= nil then
        self.hotbars[hotbar].slot_background[slot]:alpha(200)
        self.hotbars[hotbar].slot_icon[slot]:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot))
        self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/icons/custom/' .. action.icon .. '.png')
        self.hotbars[hotbar].slot_icon[slot]:show()
    end

    -- check if action is on cooldown
    if self.disabled_slots.on_cooldown[action.action] ~= nil then is_disabled = true end

    self.hotbars[hotbar].slot_frame[slot]:show()
    self.hotbars[hotbar].slot_text[slot]:text(action.alias)

    -- hide elements according to settings
    if self.theme.hide_action_names == true then self.hotbars[hotbar].slot_text[slot]:hide() else self.hotbars[hotbar].slot_text[slot]:show() end
    if self.theme.hide_action_cost == true then self.hotbars[hotbar].slot_cost[slot]:hide() else self.hotbars[hotbar].slot_cost[slot]:show() end

    -- if slot is disabled, disable it
    if is_disabled == true then
        self:toggle_slot(hotbar, slot, false)
        self.disabled_slots.actions[action.action] = true
    end
end

-- reset slot
function ui:clear_slot(hotbar, slot)
    self.hotbars[hotbar].slot_background[slot]:alpha(self.theme.slot_opacity)
    self.hotbars[hotbar].slot_frame[slot]:hide()
    self.hotbars[hotbar].slot_icon[slot]:path(windower.addon_path .. '/images/other/blank.png')
    self.hotbars[hotbar].slot_icon[slot]:hide()
    self.hotbars[hotbar].slot_icon[slot]:alpha(255)
    self.hotbars[hotbar].slot_icon[slot]:color(255, 255, 255)
    self.hotbars[hotbar].slot_element[slot]:path(windower.addon_path .. '/images/other/blank.png')
    self.hotbars[hotbar].slot_element[slot]:alpha(255)
    self.hotbars[hotbar].slot_element[slot]:hide()
    self.hotbars[hotbar].slot_text[slot]:text('')
    self.hotbars[hotbar].slot_cost[slot]:alpha(255)
    self.hotbars[hotbar].slot_cost[slot]:text('')
end

-----------------------------
-- Disabled Slots
-----------------------------

-- check player vitals
function ui:check_vitals(player_hotbar, player_vitals, environment)
    for h=1,self.theme.hotbar_number,1 do
        for i=1,10,1 do
            local slot = i
            if slot == 10 then slot = 0 end

            local action = player_hotbar[environment]['hotbar_' .. h]['slot_' .. slot]

            if action ~= nil then
                local skill = nil
                local is_disabled = false

                -- if its magic, look for it in spells
                if action.type == 'ma' and database.spells[(action.action):lower()] ~= nil then
                    skill = database.spells[(action.action):lower()]
                elseif (action.type == 'ja' or action.type == 'ws') and database.abilities[(action.action):lower()] ~= nil then
                    skill = database.abilities[(action.action):lower()]
                end

                if skill ~= nil then
                    if (skill.mpcost ~= nil and skill.mpcost ~= '0' and player_vitals.mp < tonumber(skill.mpcost)) or (skill.tpcost ~= nil and skill.tpcost ~= '0' and player_vitals.tp < tonumber(skill.tpcost)) then
                        self.disabled_slots.no_vitals[action.action] = true
                        is_disabled = true
                    else
                        self.disabled_slots.no_vitals[action.action] = nil
                    end

                    -- if it's not disabled by vitals nor cooldown, enable slot
                    if is_disabled == false and self.disabled_slots.actions[action.action] == true and self.disabled_slots.on_cooldown[action.action] == nil then
                        self.disabled_slots.actions[action.action] = nil
                        self:toggle_slot(h, i, true)
                    end

                    -- if its disabled, disable slot
                    if is_disabled == true and self.disabled_slots.actions[action.action] == nil then
                        self.disabled_slots.actions[action.action] = true
                        self:toggle_slot(h, i, false)
                    end
                end
            end
        end
    end
end

-- check action recasts
function ui:check_recasts(player_hotbar, player_vitals, environment)
    for h=1,self.theme.hotbar_number,1 do
        for i=1,10,1 do
            local slot = i
            if slot == 10 then slot = 0 end

            local action = player_hotbar[environment]['hotbar_' .. h]['slot_' .. slot]

            if action == nil or (action.type ~= 'ma' and action.type ~= 'ja' and action.type ~= 'ws') then
                self:clear_recast(h, i)
            else
                local skill = nil
                local skill_recasts = nil
                local in_cooldown = false
                local is_in_seconds = false

                -- if its magic, look for it in spells
                if action.type == 'ma' and database.spells[(action.action):lower()] ~= nil then
                    skill = database.spells[(action.action):lower()]
                    skill_recasts = windower.ffxi.get_spell_recasts()
                elseif (action.type == 'ja' or action.type == 'ws') and database.abilities[(action.action):lower()] ~= nil then
                    skill = database.abilities[(action.action):lower()]
                    skill_recasts = windower.ffxi.get_ability_recasts()
                    is_in_seconds = true
                end

                -- check if skill is in cooldown
                if skill ~= nil and skill_recasts[tonumber(skill.icon)] ~= nil and skill_recasts[tonumber(skill.icon)] > 0 then
                    -- register first cooldown to calculate percentage
                    if self.disabled_slots.on_cooldown[action.action] == nil then
                        self.disabled_slots.on_cooldown[action.action] = skill_recasts[tonumber(skill.icon)]

                        -- setup recast elements
                        self.hotbars[h].slot_recast[i]:path(windower.addon_path..'/images/other/black-square.png')
                    end

                    in_cooldown = true
                end

                -- if skill is in cooldown
                if in_cooldown == true then
                    -- disable slot if it's not disabled
                    if self.disabled_slots.actions[action.action] == nil then
                        self.disabled_slots.actions[action.action] = true
                        self:toggle_slot(h, i, false)
                    end

                    -- show recast animation
                    if self.theme.hide_recast_animation == false or self.theme.hide_recast_text == false then
                        local new_height = 40 * (skill_recasts[tonumber(skill.icon)] / tonumber(self.disabled_slots.on_cooldown[action.action]))
                        if new_height > 40 then new_height = 40 end -- temporary bug fix
                        local recast_time = calc_recast_time(skill_recasts[tonumber(skill.icon)], is_in_seconds)

                        in_cooldown = true

                        -- show recast if settings allow it
                        if self.theme.hide_recast_animation == false then
                            self.hotbars[h].slot_recast[i]:alpha(150)
                            self.hotbars[h].slot_recast[i]:size(40, new_height)
                            self.hotbars[h].slot_recast[i]:pos(self:get_slot_x(h, i), self:get_slot_y(h, i) + (40 - new_height))
                            self.hotbars[h].slot_recast[i]:show()
                        end

                        if self.theme.hide_recast_text == false then
                            self.hotbars[h].slot_recast_text[i]:text(recast_time)
                        end
                    end
                else
                    -- clear recast animation
                    self:clear_recast(h, i)

                    if self.disabled_slots.on_cooldown[action.action] == true then
                        self.disabled_slots.on_cooldown[action.action] = nil
                    end

                    -- if it's not disabled by vitals nor cooldown, enable slot
                    if self.disabled_slots.actions[action.action] == true and self.disabled_slots.no_vitals[action.action] == nil then
                        self.disabled_slots.actions[action.action] = nil
                        self:toggle_slot(h, i, true)
                    end
                end
            end
        end
    end
end

-- clear recast from a slot
function ui:clear_recast(hotbar, slot)
    self.hotbars[hotbar].slot_recast[slot]:hide()
    self.hotbars[hotbar].slot_recast_text[slot]:alpha(255)
    self.hotbars[hotbar].slot_recast_text[slot]:color(255, 255, 255)
    self.hotbars[hotbar].slot_recast_text[slot]:text('')
end

-- calculate recast time
function calc_recast_time(time, in_seconds)
    local recast = time / 60

    if in_seconds then
        if recast >= 60 then
            recast = string.format("%dh", recast / 60)
        elseif recast >= 1 then
            recast = string.format("%dm", recast)
        else
            recast = string.format("%ds", recast * 60)
        end
    else
        if recast >= 60 then
            recast = string.format("%dm", recast / 60)
        else
            recast = string.format("%ds", math.round(recast * 10)*0.1)
        end
    end

    return recast
end

-- disable slot
function ui:toggle_slot(hotbar, slot, is_enabled)
    local opacity = self.theme.disabled_slot_opacity

    if is_enabled == true then
        opacity = 255
    end

    self.hotbars[hotbar].slot_element[slot]:alpha(opacity)
    self.hotbars[hotbar].slot_cost[slot]:alpha(opacity)
    self.hotbars[hotbar].slot_icon[slot]:alpha(opacity)
end

-----------------------------
-- Feedback UI
-----------------------------

-- trigger feedback visuals in given hotbar and slot
function ui:trigger_feedback(hotbar, slot)
    if slot == 0 then slot = 10 end

    self.feedback_icon:pos(self:get_slot_x(hotbar, slot), self:get_slot_y(hotbar, slot))
    self.feedback.is_active = true
end

-- show feedback
function ui:show_feedback()
    if self.feedback.current_opacity ~= 0 then
        self.feedback.current_opacity = self.feedback.current_opacity - self.feedback.speed
        self.feedback_icon:alpha(self.feedback.current_opacity)
        self.feedback_icon:show()
    elseif self.feedback.current_opacity < 1 then
        self.feedback_icon:hide()
        self.feedback.current_opacity = self.feedback.max_opacity
        self.feedback.is_active= false
    end
end

return ui

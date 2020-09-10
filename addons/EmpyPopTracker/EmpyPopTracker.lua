--[[
Copyright © 2020, Dean James (Xurion of Bismarck)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Empy Pop Tracker nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Dean James (Xurion of Bismarck) BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'Empy Pop Tracker'
_addon.author = 'Dean James (Xurion of Bismarck)'
_addon.commands = { 'ept', 'empypoptracker' }
_addon.version = '2.4.0'

config = require('config')
res = require('resources')
nm_data = require('nms/index')

active = false

local EmpyPopTracker = {}

local defaults = {}
defaults.text = {}
defaults.text.pos = {}
defaults.text.pos.x = 0
defaults.text.pos.y = 0
defaults.text.bg = {}
defaults.text.bg.alpha = 150
defaults.text.bg.blue = 0
defaults.text.bg.green = 0
defaults.text.bg.red = 0
defaults.text.bg.visible = true
defaults.text.padding = 8
defaults.text.text = {}
defaults.text.text.font = 'Consolas'
defaults.text.text.size = 10
defaults.tracking = 'briareus'
defaults.visible = true
defaults.add_to_chat_mode = 8
defaults.colors = {}
defaults.colors.needed = {}
defaults.colors.needed.red = 255
defaults.colors.needed.green = 50
defaults.colors.needed.blue = 50
defaults.colors.obtained = {}
defaults.colors.obtained.red = 100
defaults.colors.obtained.green = 255
defaults.colors.obtained.blue = 100
defaults.colors.pool = {}
defaults.colors.pool.red = 255
defaults.colors.pool.green = 170
defaults.colors.pool.blue = 0
defaults.colors.bg = {}
defaults.colors.bg.red = 0
defaults.colors.bg.green = 0
defaults.colors.bg.blue = 0
defaults.colors.bgall = {}
defaults.colors.bgall.red = 0
defaults.colors.bgall.green = 75
defaults.colors.bgall.blue = 0

EmpyPopTracker.settings = config.load(defaults)
EmpyPopTracker.text = require('texts').new(EmpyPopTracker.settings.text, EmpyPopTracker.settings)

function start_color(color)
    return '\\cs(' .. EmpyPopTracker.settings.colors[color].red .. ',' .. EmpyPopTracker.settings.colors[color].green .. ',' .. EmpyPopTracker.settings.colors[color].blue .. ')'
end

function owns_item(id, items)
    for _, bag in pairs(items) do
        if type(bag) == 'table' then
            for _, item in ipairs(bag) do
                if item.id == id then
                    return true
                end
            end
        end
    end

    return false
end

function get_item_count(id, items)
    local count = 0
    for _, bag in pairs(items) do
        if type(bag) == 'table' then
            for _, item in ipairs(bag) do
                if item.id == id then
                    count = count + item.count
                end
            end
        end
    end

    return count
end

function owns_key_item(id, items)
    local owned = false

    for _, item_id in pairs(items) do
        if item_id == id then
            owned = true
            break
        end
    end

    return owned
end

function item_treasure_pool_count(id, treasure)
    local count = 0

    for _, item in pairs(treasure) do
        if item.item_id == id then
            count = count + 1
        end
    end

    return count
end

function ucwords(str)
    local result = string.gsub(str, '(%a)([%w_\']*)', function(first, rest)
        return first:upper() .. rest:lower()
    end)

    return result
end

function get_indent(depth)
    return string.rep('  ', depth)
end

function generate_text(data, key_items, items, depth)
    local text = depth == 1 and data.name or ''
    for _, pop in pairs(data.pops) do
        local resource
        local item_scope
        local owns_pop
        local in_pool_count = 0
        local item_identifier = ''

        if pop.type == 'key item' then
            resource = res.key_items[pop.id]
            owns_pop = owns_key_item(pop.id, key_items)
            item_identifier = 'Ж '
        else
            resource = res.items[pop.id]
            owns_pop = owns_item(pop.id, items)
            in_pool_count = item_treasure_pool_count(pop.id, items.treasure)
        end

        local pop_name = 'Unknown pop'
        if resource then
            pop_name = ucwords(resource.name)
        end

        --separator line for each top-level mob
        if depth == 1 then
            text = text .. '\n'
        end

        local item_colour
        if owns_pop then
            item_colour = start_color('obtained')
        else
            item_colour = start_color('needed')
        end

        local pool_notification = ''
        if in_pool_count > 0 then
            pool_notification = start_color('pool') .. ' [' .. in_pool_count .. ']' .. '\\cr'
        end
        text = text .. '\n' .. get_indent(depth) .. pop.dropped_from.name .. '\n' .. get_indent(depth) .. ' >> ' .. item_colour .. item_identifier .. pop_name .. '\\cr' .. pool_notification
        if pop.dropped_from.pops then
            text = text .. generate_text(pop.dropped_from, key_items, items, depth + 1)
        end
    end

    if data.item then
        local count = get_item_count(data.item, items)
        local start = ''
        local finish = ''
        if count >= data.item_target_count then
            start = start_color('obtained')
            finish = '\\cr'
        end

        text = text .. '\n\n' .. start .. res.items[data.item].name .. ': ' .. count .. '/' .. data.item_target_count .. finish
    end

    return text
end

EmpyPopTracker.generate_info = function(nm, key_items, items)
    return {
        has_all_pops = not nm.pops or T(nm.pops):all(function(item)
            return item.type == 'item' and owns_item(item.id, items) or owns_key_item(item.id, key_items)
        end),
        text = generate_text(nm, key_items, items, 1)
    }
end

function find_nms(pattern)
    local matching_nms = {}
    local lower_pattern = pattern:lower()
    for _, nm in pairs(nm_data) do
        local nm_name = nm.name:lower()
        local result = windower.wc_match(nm_name, lower_pattern)
        if result then
            table.insert(matching_nms, nm_name)
        end
    end

    return matching_nms
end

windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or 'help'

    if commands[command] then
        commands[command](...)
    else
        commands.help()
    end
end)

commands = {}

commands.track = function(...)
    local nm_search_pattern = table.concat({...}, ' ')
    local matching_nm_names = find_nms(nm_search_pattern)

    if #matching_nm_names == 0 then
        windower.add_to_chat(EmpyPopTracker.settings.add_to_chat_mode, 'Unable to find a NM using: "' .. nm_search_pattern .. '"')
    elseif #matching_nm_names > 1 then
        windower.add_to_chat(EmpyPopTracker.settings.add_to_chat_mode, '"' .. nm_search_pattern .. '" matches ' .. #matching_nm_names .. ' NMs. Please be more explicit:')
        for key, matching_file_name in pairs(matching_nm_names) do
            windower.add_to_chat(EmpyPopTracker.settings.add_to_chat_mode, '  Match ' .. key .. ': ' .. ucwords(matching_file_name))
        end
    else
        active = true
        windower.add_to_chat(EmpyPopTracker.settings.add_to_chat_mode, 'Now tracking: ' .. ucwords(matching_nm_names[1]))
        EmpyPopTracker.settings.tracking = matching_nm_names[1]
        EmpyPopTracker.update()
        commands.show()
    end
end
commands.t = commands.track

commands.hide = function()
    active = false
    EmpyPopTracker.text:visible(false)
    EmpyPopTracker.settings.visible = false
    EmpyPopTracker.settings:save()
end

commands.show = function()
    active = true
    EmpyPopTracker.text:visible(true)
    EmpyPopTracker.settings.visible = true
    EmpyPopTracker.settings:save()
    EmpyPopTracker.update()
end

commands.help = function()
    windower.add_to_chat(EmpyPopTracker.settings.add_to_chat_mode, '---Empy Pop Tracker---')
    windower.add_to_chat(EmpyPopTracker.settings.add_to_chat_mode, 'Available commands:')
    windower.add_to_chat(EmpyPopTracker.settings.add_to_chat_mode, '//ept track briareus - tracks Briareus pops (search patterns such as apadem* work too!)')
    windower.add_to_chat(EmpyPopTracker.settings.add_to_chat_mode, '//ept hide - hides the UI')
    windower.add_to_chat(EmpyPopTracker.settings.add_to_chat_mode, '//ept show - shows the UI')
    windower.add_to_chat(EmpyPopTracker.settings.add_to_chat_mode, '//ept list - lists all trackable NMs')
    windower.add_to_chat(EmpyPopTracker.settings.add_to_chat_mode, '//ept help - displays this help')
end

commands.list = function()
    windower.add_to_chat(EmpyPopTracker.settings.add_to_chat_mode, '---Empy Pop Tracker---')
    windower.add_to_chat(EmpyPopTracker.settings.add_to_chat_mode, 'Trackable NMs:')
    for _, nm in pairs(nm_data) do
        windower.add_to_chat(EmpyPopTracker.settings.add_to_chat_mode, ucwords(nm.name))
    end
end

commands.bg = function()
    local tracking_nm = nm_data[EmpyPopTracker.settings.tracking]
    local url = 'https://www.bg-wiki.com/bg/' .. tracking_nm.name
    windower.open_url(url)
end

EmpyPopTracker.update = function()
    local key_items = windower.ffxi.get_key_items()
    local items = windower.ffxi.get_items()
    local tracked_nm_data = nm_data[EmpyPopTracker.settings.tracking]
    local generated_info = EmpyPopTracker.generate_info(tracked_nm_data, key_items, items)
    EmpyPopTracker.text:text(generated_info.text)
    if generated_info.has_all_pops then
        EmpyPopTracker.text:bg_color(EmpyPopTracker.settings.colors.bgall.red, EmpyPopTracker.settings.colors.bgall.green, EmpyPopTracker.settings.colors.bgall.blue)
    else
        EmpyPopTracker.text:bg_color(EmpyPopTracker.settings.colors.bg.red, EmpyPopTracker.settings.colors.bg.green, EmpyPopTracker.settings.colors.bg.blue)
    end
    if EmpyPopTracker.settings.visible then
        EmpyPopTracker.text:visible(true)
    end
end

windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in and EmpyPopTracker.settings.visible then
        active = true
        EmpyPopTracker.update()
    end
end)

windower.register_event('add item', 'remove item', function()
    if active then
        EmpyPopTracker.update()
    end
end)

windower.register_event('incoming chunk', function(id)
    --0x055: KI update
    --0x0D2: Treasure pool addition
    --0x0D3: Treasure pool lot/drop
    if active and id == 0x055 or id == 0x0D2 or id == 0x0D3 then
        EmpyPopTracker.update()
    end
end)

windower.register_event('login', function()
    if EmpyPopTracker.settings.visible then
        EmpyPopTracker.text:visible(true)
        active = true
    end
end)

windower.register_event('logout', function()
    EmpyPopTracker.text:visible(false)
    active = false
end)

return EmpyPopTracker

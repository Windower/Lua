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

_addon.name = "Empy Pop Tracker"
_addon.author = "Dean James (Xurion of Bismarck)"
_addon.commands = { "ept", "empypoptracker" }
_addon.version = "2.0.0"

config = require("config")
res = require("resources")
nm_data = require("nms/index")

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
defaults.text.text.font = "Consolas"
defaults.text.text.size = 10
defaults.tracking = "briareus"
defaults.visible = true

EmpyPopTracker.settings = config.load(defaults)
EmpyPopTracker.text = require("texts").new(EmpyPopTracker.settings.text, EmpyPopTracker.settings)

colors = {}
colors.success = "\\cs(100,255,100)"
colors.danger = "\\cs(255,50,50)"
colors.warning = "\\cs(255,170,0)"
colors.close = "\\cr"

function owns_item(id, items)
    local owned = false

    -- Loop maximum 80 times over all slots. 80 indexes are returned for each bag regardless of max capacity.
    for i = 1, 80, 1 do
        if items.safe[i].id == id or
            items.safe2[i].id == id or
            items.locker[i].id == id or
            items.sack[i].id == id or
            items.satchel[i].id == id or
            items.inventory[i].id == id or
            items.storage[i].id == id then
                owned = true
                break
        end
    end

    return owned
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
    return string.gsub(str, "(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

function get_indent(depth)
    return string.rep("  ", depth)
end

function generate_text(data, key_items, items, depth)
    local text = depth == 1 and data.name or ""
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
            pop_name = ucwords(resource.en)
        end

        --separator line for each top-level mob
        if depth == 1 then
            text = text .. "\n"
        end

        local item_colour
        if owns_pop then
            item_colour = colors.success
        else
            item_colour = colors.danger
        end

        local pool_notification = ''
        if in_pool_count > 0 then
            pool_notification = colors.warning .. ' [' .. in_pool_count .. ']' .. colors.close
        end
        text = text .. "\n" .. get_indent(depth) .. pop.dropped_from.name .. "\n" .. get_indent(depth) .. ' >> ' .. item_colour .. item_identifier .. pop_name .. colors.close .. pool_notification
        if pop.dropped_from.pops then
            text = text .. generate_text(pop.dropped_from, key_items, items, depth + 1)
        end
    end

    return text
end

EmpyPopTracker.add_to_chat = function(message)
    if type(message) ~= 'string' then
        error('add_to_chat requires the message arg to be a string')
    end

    windower.add_to_chat(8, message)
end

EmpyPopTracker.generate_info = function(nm, key_items, items)
    local nm_type = type(nm)
    if nm_type ~= 'table' then
        error('generate_info requires the nm arg to be a table, but got ' .. nm_type .. ' instead')
    end

    local info = {
        has_all_kis = true,
        text = ""
    }

    if nm.pops then
        for _, key_item_data in pairs(nm.pops) do
            local has_pop_ki = owns_key_item(key_item_data.id, key_items)

            if not has_pop_ki then
                info.has_all_kis = false
            end
        end
    end

    info.text = generate_text(nm, key_items, items, 1)

    return info
end

function find_nms(query)
    local matching_nms = {}
    local lower_query = query:lower()
    for _, nm in pairs(nm_data) do
        local result = string.match(nm.name:lower(), '(.*' .. lower_query .. '.*)')
        if result then
            table.insert(matching_nms, result)
        end
    end
    return matching_nms
end

windower.register_event("addon command", function(command, ...)
    if commands[command] then
        commands[command](...)
    else
        commands.help()
    end
end)

commands = {}

commands.track = function(...)
    local args = {...}
    local nm_name = args[1]
    local matching_nm_names = find_nms(nm_name)

    if #matching_nm_names == 0 then
        EmpyPopTracker.add_to_chat('Unable to find a NM using: "' .. nm_name .. '"')
    elseif #matching_nm_names > 1 then
        EmpyPopTracker.add_to_chat('"' .. nm_name .. '" matches ' .. #matching_nm_names .. ' NMs. Please be more explicit:')
        for key, matching_file_name in pairs(matching_nm_names) do
            EmpyPopTracker.add_to_chat('  Match ' .. key .. ': ' .. ucwords(matching_file_name))
        end
    else
        active = true
        EmpyPopTracker.add_to_chat("Now tracking: " .. ucwords(matching_nm_names[1]))
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
    EmpyPopTracker.add_to_chat("---Empy Pop Tracker---")
    EmpyPopTracker.add_to_chat("Available commands:")
    EmpyPopTracker.add_to_chat("//ept t|track briareus - tracks Briareus pops (partial names such as apadem work too!)")
    EmpyPopTracker.add_to_chat("//ept hide - hides the UI")
    EmpyPopTracker.add_to_chat("//ept show - shows the UI")
    EmpyPopTracker.add_to_chat("//ept list - lists all trackable NMs")
    EmpyPopTracker.add_to_chat("//ept help - displays this help")
end

commands.list = function()
    EmpyPopTracker.add_to_chat("---Empy Pop Tracker---")
    EmpyPopTracker.add_to_chat("Trackable NMs:")
    for _, nm in pairs(nm_data) do
        EmpyPopTracker.add_to_chat(ucwords(nm.name))
    end
end

commands.bg = function()
    local tracking_nm = nm_data[EmpyPopTracker.settings.tracking]
    windower.open_url(tracking_nm.bg_url)
end

EmpyPopTracker.update = function()
    local key_items = windower.ffxi.get_key_items()
    local items = windower.ffxi.get_items()
    local tracked_nm_data = nm_data[EmpyPopTracker.settings.tracking]
    local generated_info = EmpyPopTracker.generate_info(tracked_nm_data, key_items, items)
    EmpyPopTracker.text:text(generated_info.text)
    if generated_info.has_all_kis then
        EmpyPopTracker.text:bg_color(0, 75, 0)
    else
        EmpyPopTracker.text:bg_color(0, 0, 0)
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

--[[
Copyright © 2025, Arakon
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of Dimmer nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.name = 'gearstats'
_addon.author = 'Arakon'
_addon.version = '1.0'
_addon.commands = {'gearstats'}

require("lists")
require("tables")
local extdata = require("extdata")
local res = require('resources')
local files = require('files')
local jsonHelper = require("json_helper")

defaults = {
	priority_list = L{
        L{"DMG","Delay","DEF","HP","MP","Haste"},
        L{"STR","DEX","AGI","VIT","INT","MND","CHR"},
        L{"Accuracy","Attack","Ranged Accuracy","Ranged Attack","Magic Accuracy","Magic Atk. Bonus","Magic Damage", "Magic burst damage"},
        L{"Evasion","Magic Evasion","Magic Def. Bonus","Damage taken","Physical damage taken","Magical damage taken"},
        L{'Regain',"Store TP","Double Attack","Triple Attack","Quad Attack","Dual Wield"},
        L{'Weapon skill damage','TP Bonus','Skillchain Bonus','Physical damage limit'},
        L{'Enmity','Counter','Subtle Blow','Subtle Blow II'},
        L{'Refresh','Conserve MP','Fast Cast','Occ. quickens spellcasting', 'Spell interruption rate down'},
    },
    mapping_table = {},
    merge_pet_stats = true,
    line_wrap = 80,
}

defaults.mapping_table["Accuracy"] = "Acc"
defaults.mapping_table["Attack"] = "Atk"
defaults.mapping_table["Ranged Accuracy"] = "R.Acc"
defaults.mapping_table["Ranged Attack"] = "R.Atk"
defaults.mapping_table["Magic Accuracy"] = "M.Acc"
defaults.mapping_table["Magic Atk. Bonus"] = "M.Atk.Bn"
defaults.mapping_table["Magic Damage"] = "M.Dmg"
defaults.mapping_table["Magic burst damage"] = "MB.Dmg"
defaults.mapping_table["Evasion"] = "Eva"
defaults.mapping_table["Magic Evasion"] = "M.Eva"
defaults.mapping_table["Magic Def. Bonus"] = "M.Def.Bn"
defaults.mapping_table["Damage taken"] = "DT"
defaults.mapping_table["Physical damage taken"] = "PDT"
defaults.mapping_table["Magical damage taken"] = "MDT"
defaults.mapping_table["Double Attack"] = "Double Atk."
defaults.mapping_table["Triple Attack"] = "Triple Atk."
defaults.mapping_table["Quad Attack"] = "Quad Atk."
defaults.mapping_table['Weapon skill damage'] = "WS.Dmg"
defaults.mapping_table['Skillchain Bonus'] = "SC.Bonus"
defaults.mapping_table['Physical damage limit'] = "PDL"
defaults.mapping_table['Occ. quickens spellcasting'] = "Quick Cast"
defaults.mapping_table['Spell interruption rate down'] = "Interrupt Down Rate"

settings = {}

gameinfo = {
	equipment = {},
	equipment_stats = {}
}

--- Generic Functions

function addon_console(...)
    windower.console.write('%s: %s':format(_addon.name,table.concat({...},', ')))
end

function addon_message(...)
    windower.add_to_chat(7,'%s: %s':format(_addon.name,table.concat({...},', ')))
end

function addon_trace(...)
    if gameinfo.trace then
        windower.add_to_chat(7,'%s: %s':format(_addon.name,table.concat({...},', ')))
    end
end

function flag_to_string(flag)
    if (not flag) then
        return '[Off]'
    end
    return '[On]'
end

function table_clear(obj)
    if type(obj) == 'table' then
        for key in pairs(obj) do
            rawset(obj, key, nil)
        end
    end
end

function table_merge(to_obj, from_obj)
    if type(to_obj) == 'table' and type(from_obj) == 'table' then
        for key, value in pairs(from_obj) do
            if to_obj[key] ~= nil then
                if type(to_obj[key]) == 'table' and type(from_obj[key]) == 'table' then
                    table_merge(to_obj[key], from_obj[key])
                elseif type(to_obj[key]) =='number' and type(from_obj[key]) == 'number' then
                    to_obj[key] = to_obj[key] + from_obj[key]
                elseif type(to_obj[key]) =='boolean' and type(from_obj[key]) == 'boolean' then
                    to_obj[key] = to_obj[key] and from_obj[key]
                else
                    to_obj[key] = tostring(to_obj[key])..' '..tostring(from_obj[key])
                end
            else
                if type(from_obj[key]) == 'table' then
                    to_obj[key] = {}
                    table_merge(to_obj[key], from_obj[key])
                else
                    to_obj[key] = from_obj[key]
                end
            end
        end
    end
    return to_obj
end

function table_remove_keys(obj, list)
    if type(obj) == 'table' then
        for key in list:it() do
            rawset(obj, key, nil)
        end
    end
end

function remove_from_list(list, item)
    if not list or not item then
        return
    end
    list = list:filter(function(val) return (val ~= item) end)
end

function from_json(data)
    if type(data) ~= "string" then
        return T{}
    end
    return jsonHelper:fromJson(data)
end

function to_json(data)
    if not data then
        return "{}"
    end
    return jsonHelper:toJson(data)
end

function matchWithDefault(current, default)
    for key, value in pairs(default) do
        if current[key] == nil or (type(current[key]) ~= type(value)) or (type(current[key]) == 'table' and class(current[key]) ~= class(value)) then
            current[key] = value
        end
    end
    for key, _ in pairs(current) do
        if default[key] == nil then
            current[key] = nil
        end
    end
    return current
end

function load_settings()
    local filepath = "data/settings.json"
    local file = files.new(filepath, true)
    if not file:exists() then
        matchWithDefault(settings, defaults)
        save_settings()
    end
    local filecontent = file:read(filepath)
    settings = from_json(filecontent)
    settings = matchWithDefault(settings, defaults)
end

function save_settings()
    local filepath = "data/settings.json"
    local file = files.new(filepath, true)
    file:write(to_json(settings))
end

function print_debug(filepath)
    local file = files.new(filepath, true)
    local data = {
        settings = setting,
        gameinfo = gameinfo
    }
    file:write(to_json(data), true)
end
--- Stats Functions

local function extract_stats_from_str(str, prefix)
    local stats = {}
    -- General string replacement
    str = str:gsub('(Converts )([%d%.]+)(%%?[%a%s]+)','%1%3: %2'):gsub('%s%s',' ')
    str = str:gsub('(%a)[%-](%a)','%1 %2')
    local match = str:match('^\".*\"$')
    if match then
        match = match:gsub('\"','')
        stats[match] = 1
        return stats, prefix
    end
    local name, op, value
    for name, op, value in str:gmatch('(%u[^%d:%+%-]+)([:]?[%+%-]?)%s?([%d%.～]*)[%%]?') do
        local is_prefix = false
        if op == nil or op == '' then
            op = ''
        end
        if value == nil or value == '' then
            if op == ':' then
                is_prefix = true
                prefix = name
            else
                value = 1
            end
        else
            local offset = value:find('～')
            if offset ~= nil then
                value = value:match('～([%d]+)')
            end
            if op:find('-') ~= nil then
                value = '-'.. value
            end
            value = tonumber(value)
        end
        if not is_prefix then
            name = name:gsub('\"',''):gsub('^%s+',''):gsub('%s+$','')
            local offset = name:find(':')
            if (offset ~= nil) and (name:sub(offset+1, offset+1) ~= '+') then
                prefix = name:sub(1, offset - 1):gsub('%s+$','')
                name = name:sub(offset+1):gsub('^%s+','')
            end
            if prefix ~= nil then
                if not stats[prefix] then
                    stats[prefix] = {}
                end
                if stats[prefix][name] then
                    stats[prefix][name] = stats[prefix][name] + value
                else
                    stats[prefix][name] = value
                end
            else
                if stats[name] then
                    stats[name] = stats[name] + value
                else
                    stats[name] = value
                end
            end
        end
    end
    return stats, prefix
end

local function extract_stats(gear)
    local stats = {}
    local str_stats
    if gear.description then
        local prefix = nil
        local has_stats = false
        for str in gear.description:it() do
            if not has_stats and str:match('^%a([^%:%+%-]*)[%.%l]$') then
                -- if not stats['description'] then
                --     stats['description'] = ''
                -- end
                -- stats['description'] = stats['description']..str
            else
                has_stats = true
                str_stats, prefix = extract_stats_from_str(str, prefix)
                table_merge(stats, str_stats)
            end
        end
    end
    if gear.extdata and gear.extdata.augment_system then
        if gear.extdata.augment_system == 1 then
            local prefix = nil
            for key,str in pairs(gear.extdata.augments) do
                if str:match('^System: %d') then
                    -- Skip useless string
                else
                    str_stats, prefix = extract_stats_from_str(str, prefix)
                    table_merge(stats, str_stats)
                end
            end
        end
    end
    return stats
end

local function merge_stats(stats)
    local merge_pair = {}
    for key, value in pairs(stats) do
        if type(value) == 'table' then
            merge_stats(stats[key])
        elseif key:match('%.') then
            local fuzzykey = key:gsub('(%a+)%.',function(word) return (word:gsub('(%w)','%1%%a*')..'%.?%s?') end)
            fuzzykey = '^'..fuzzykey..'$'
            addon_trace('Searching for %s using %s':format(key, fuzzykey))
            for x,y in pairs(stats) do
                if x:match(fuzzykey) and x ~= key then
                    addon_trace('Found match for %s - %s':format(key, x))
                    merge_pair[key] = x
                    break
                end
            end
        end
    end
    for from_key, to_key in pairs(merge_pair) do
        addon_trace('Merging %s to %s':format(from_key, to_key))
        stats[to_key] = (stats[to_key] or 0) + (stats[from_key] or 0)
        stats[from_key] = nil
    end
end

function update_gear()
	gameinfo.equipment_stats = {}
	gameinfo.equipment = {}
    local equipment = windower.ffxi.get_items('equipment')
    local bags = L{0,8,10,11,12,13,14,15,16}
    local slots = L{"main","sub","range","ammo","head","body","hands","legs","feet","neck","waist","back","left_ear","right_ear","left_ring","right_ring"}
    for slot in slots:it() do
        local index = equipment[slot]
        local bag = equipment[slot.."_bag"]
        local gear = {}
        if index > 0 and bags:contains(bag) then
            item = windower.ffxi.get_items(bag, index)
            if item ~= nil and item.id ~= nil and res.items[item.id] then
                gear.id = item.id
                gear.name = res.items[item.id].name
                gear.description = L{}
                if res.item_descriptions[item.id] then
                    local desc = res.item_descriptions[item.id].english
                    local set_str = nil
                    local str = nil
                    for match in desc:gmatch("([^\n]+)") do
                        addon_trace("%s description length %d - str %s match %s":format(gear.name, gear.description:length(), tostring(str), match))
                        if str and match:match("^%l") then
                            str = str..' '..match
                        elseif match:match('^Set: ') then
                            if str then
                                gear.description:append(str)
                                str = nil
                            end
                            set_str = match
                        elseif set_str ~= nil then
                            set_str = set_str..' '..match
                        else
                            if str then
                                gear.description:append(str)
                            end
                            str = match
                        end
                    end
                    if str then
                        gear.description:append(str)
                    end
                    if set_str then
                        gear.description:append(set_str)
                    end
                end
                gear.extdata = extdata.decode(item)
                if (gear.extdata) then
                    gear.extdata.__raw = nil
                end
                gear.count = math.max(item.count, 1)
            end
            gear.stats = extract_stats(gear)
            table_merge(gameinfo.equipment_stats, gear.stats)
        end
        gameinfo.equipment[slot] = gear
    end
    -- Merge the stats from Pet into the Individual pet types
    if settings.merge_pet_stats and gameinfo.equipment_stats['Pet'] then
        for key in L{'Automaton','Avatar','Wyvern'}:it() do
            if gameinfo.equipment_stats[key] then
                table_merge(gameinfo.equipment_stats[key], gameinfo.equipment_stats['Pet'])
            end
        end
        gameinfo.equipment_stats['Pet'] = nil
    end
    merge_stats(gameinfo.equipment_stats)
end

commands = T{}

commands['trace'] = {
help = "Trace log - toggle | on | off ",
func = function(args)
    if not args[1] then
        gameinfo.trace = not gameinfo.trace
    elseif args[1]:lower() == 'on' then
        gameinfo.trace = true
    elseif args[1]:lower() == 'off' then
        gameinfo.trace = false
    end
    addon_message('Trace logs '..flag_to_string(gameinfo.trace))
end}

function print_stats_table(stats, prefix, priority_list, mapping_table, split)
    local done_list = L{}
    local output = L{}
    local message = ''
    for row in priority_list:it() do
        for key in row:it() do
            if stats[key] ~= nil then
                local name = key
                if mapping_table[name] ~= nil then
                    name = mapping_table[name]
                end
                local str = "%s:%d":format(name, stats[key])
                if (message:len() + str:len() > settings.line_wrap) then
                    output:append(message)
                    message = ''
                end
                if (message:len() == 0) and (prefix:len() > 0) then
                    message = prefix..' -'
                end
                message = message..' '..str
                done_list:append(key)
            end
        end
        if split and (message:len() > 0) then
            output:append(message)
            message = ''
        end
    end
    if message:len() > 0 then
        output:append(message)
        message = ''
    end
    local sub_prefix = 'Skill'
    if prefix:len() then
        sub_prefix = prefix..':'..sub_prefix
    end
    for key, value in pairs(stats) do
        if key:match('skill$') then
            local str = '%s:%s':format(key:gsub('%s*skill$',''), tostring(value))
            if (message:len() + str:len() > settings.line_wrap) then
                output:append(message)
                message = ''
            end
            if (message:len() == 0) and (sub_prefix:len() > 0) then
                message = sub_prefix..' -'
            end
            message = message..' '..str
            done_list:append(key)
        end
    end
    if (message:len() > 0) then
        output:append(message)
        message = ''
    end
    for key, value in pairs(stats) do
        if (not done_list:contains(key)) and type(value) ~= 'table' then
            local name = key
            if mapping_table[name] ~= nil then
                name = mapping_table[name]
            end
            local str = "%s:%s":format(name, tostring(value))
            if (message:len() + str:len() > settings.line_wrap) then
                output:append(message)
                message = ''
            end
            if (message:len() == 0) and (prefix:len() > 0) then
                message = prefix..' -'
            end
            message = message..' '..str
            done_list:append(key)
        end
    end
    if message:len() > 0 then
        output:append(message)
        message = ''
    end
    return output:concat('\n')
end

commands['print'] = {
help = "Print the stats of current gear",
func = function(args)
    update_gear()
    addon_message("Generating Equipment Stats")
    output = print_stats_table(gameinfo.equipment_stats, '', settings.priority_list, settings.mapping_table, true)
    for key, value in pairs(gameinfo.equipment_stats) do
        if type(value) == 'table' then
            output = output..'\n'..print_stats_table(value, key, settings.priority_list, settings.mapping_table, false)
        end
    end
    for str in output:gmatch("([^\n]+)") do
    	addon_message(str)
    end
end}

commands['file'] = {
help = "Save the stats of current gear to file, arguments are added as header message",
func = function(args)
    update_gear()
    local player = windower.ffxi.get_player()
    local filename = "data/"..player.name:lower().."_"..player.main_job..".txt"
    addon_message("Generating Equipment Stats to %s":format(filename))
    local args_str = args:concat(' ')
    local header = "=====[ %s ]======\n":format(args_str)
    output = print_stats_table(gameinfo.equipment_stats, '', settings.priority_list, settings.mapping_table, true)
    for key, value in pairs(gameinfo.equipment_stats) do
        if type(value) == 'table' then
            output = output..'\n'..print_stats_table(value, key, settings.priority_list, settings.mapping_table, false)
        end
    end
    output = header..output.."\n"
    local file = files.new(filename, true)
    file:append(output, true)
end}

commands['debug'] = {
help = "Print all structures to file",
func = function(args)
	addon_message("Generating data/debug.json")
    print_debug("data/debug.json")
end}

commands['load'] = {
help = "Load settings",
func = function(args)
    load_settings()
    addon_message('settings loaded.')
end}

commands['save'] =  {
help = "Save settings",
func = function(args)
    save_settings()
    addon_message('settings saved.')
end}

commands['help'] = {
help = "Command Help",
func = function(args)
    addon_message("Commands")
    for command, value in pairs(commands) do
        if value.help then
            addon_message("%s - %s":format(command, value.help))
        else
            addon_message("%s":format(command))
        end
    end
    addon_message("Settings")
    for command, value in pairs(settings) do
        if commands[command] == nil then
            if type(settings[command]) == 'boolean' then
                addon_message("%s - boolean: default - toggle | on - enable | off - disable":format(command))
            elseif type(settings[command]) == 'number' then
                addon_message("%s - <number>":format(command))
            elseif type(settings[command]) == 'string' then
                addon_message("%s - <string> ...":format(command))
            end
        end
    end
end}

windower.register_event('addon command', function(command, ...)
    local args = L{...}
    command = command and command:lower() or 'help'
    if commands:containskey(command) and commands[command].func ~= nil then
        commands[command].func(args)
    elseif settings[command] ~= nil then
        if #args < 1 then
            if type(settings[command]) == 'boolean' then
                settings[command] = not settings[command]
                addon_message(command..' is now set to '..flag_to_string(settings[command]))
            elseif _static[command] ~= nil then
                for i = 1, #_static[command] do
                    if _static[command][i] == settings[command] then
                        i = i + 1
                        if i > #_static[command] then
                            i = 1
                        end
                        settings[command] = _static[command][i]
                        break
                    end
                end
                addon_message(command..' is now set to '..settings[command])
            else
                addon_message(command..' requires argument')
            end
        else
            local arg = tonumber(args[1]) or args[1]:lower()
            if type(settings[command]) == 'boolean' then
                if arg == 'on' then
                    settings[command] = true
                    addon_message(command..' is now set to '..flag_to_string(settings[command]))
                elseif arg == 'off' then
                    settings[command] = false
                    addon_message(command..' is now set to '..flag_to_string(settings[command]))
                else
                    addon_message(command..' invalid option '..arg)
                end
            elseif type(settings[command]) == 'number' then
                settings[command] = tonumber(args[1])
                addon_message(command..' is now set to '..settings[command])
            elseif type(settings[command]) == 'string' then
                settings[command] = args.concat(' '):lower()
                addon_message(command..' is now set to '..settings[command])
            end
        end
	else
    	commands['help'].func(args)
    end
end)

load_settings()

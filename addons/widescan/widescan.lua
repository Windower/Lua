--[[
Copyright 2026, Nifim

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
_addon = {}
_addon.name = 'WideScan'
_addon.version = '1.0.0'
_addon.author = 'Nifim'
_addon.commands = {'wsn','widescan'}

require('luau')
require('table')
require('logger')
local packets = require('packets')
local packet_handler = require('packet_handler')
local placeholder_lists = require('placeholder_lists')

local help_text = [[Help Text:
wsn (s)can  [(n)ame|(i)ndex|(p)laceholder] <name|index> - Scans for mobs matching the provided parameter.
wsn (t)rack [(n)ame|(i)ndex|(p)laceholder] <name|index> - Scans for a mob then tracks it if found.
wsn (e)nd                                               - Ends the current tracking.

example usage:
    //widescan scan name hare*                          - Name of the mob to search for (supports wildcards).
    //wsn track index 0x1A2B                            - Index of the mob to search for (hexadecimal).
    //wsn s i 0x1 i 0x2 i 0x3                           - You can scan for multiple mobs at once.
    //wsn t p oky                                       - Use the placeholder list (e.g., Okyupete).
]]

local widescan = {}

local scan_list = {}
local scan_call_back

local keys = {
    i = 'index',
    index = 'index',
    n = 'name',
    name = 'name',
    p = 'placeholder',
    placeholder = 'placeholder'
}

function widescan.command_handler(cmd, ...)
    local arg = T{...}:map(string.lower) or {}
    cmd = cmd and cmd:lower() or 'help'
    if widescan.cmd[cmd] then
        widescan.cmd[cmd](arg)
    end
end
windower.register_event('addon command', widescan.command_handler)

widescan.cmd = {}

function widescan.cmd.help()
    print(help_text)
end

function widescan.cmd.track(args)
    widescan.cmd.scan(args, true)
end
widescan.cmd.t = widescan.cmd.track

function widescan.cmd.scan(args, track)
    local query = {}

    if args:length() % 2 ~= 0 then
        error('The number of parameters must be even.', args:length(), args)
        return nil
    end

    for i = 1, #args, 2 do
        local key = keys[args[i]]
        local value = args[i + 1]
        query[key] = value
    end

    local zone_id = windower.ffxi.get_info().zone
    if query['placeholder'] and placeholder_lists[zone_id] then
        local nms = {}
        for nm_name in pairs(placeholder_lists[zone_id]) do
            if (windower.wc_match(nm_name, query['placeholder'] .. '*')) then
                table.insert(nms, nm_name)
            end
        end
        if #nms == 0 then
            log(string.format('No name in placeholder list matches: %s', query['placeholder']))
            return
        elseif #nms > 1 then
            log(string.format('Provided name is too ambiguous: %s', query['placeholder']))
            for _, value in ipairs(nms) do
                log(string.format('- %s', value:gsub("^%a", string.upper)
                                               :gsub("(%s)(%a)", function(spaces, char) return spaces .. char:upper() end)))
            end
            return
        end
        query['placeholder'] = nms[1]
    end

    scan_call_back = coroutine.create(widescan.query)
    coroutine.resume(scan_call_back, query, track)
end
widescan.cmd.s = widescan.cmd.scan

widescan.cmd['end'] = function()
    windower.ffxi.wide_scan_stop_tracking()
end
widescan.cmd.e = widescan.cmd['end']

function widescan.query(query, track)
    widescan.request_scan();
    coroutine.yield()
    local found = {}
    local matched_name
    query.index_list = {}
    local mob_list = windower.ffxi.get_mob_list()
    for _, v in ipairs(scan_list) do
        local matched = false
        if query['name'] then
            local mob_name = mob_list[v.Index]
            v.Name = mob_name
            matched = matched and mob_name:lower():match(query['name'])
            if windower.wc_match(mob_name:lower(), query['name']) then
                if matched_name ~= nil and mob_name ~= query['name'] then
                    log(string.format('Provided name is too ambiguous: %s', query['name']))
                end
                table.insert(query.index_list, v.Index)
                matched = true
            end
        end

        if query['index'] then
            matched = tonumber(query['index'], 16) == v.Index
        end

        local zone_id = windower.ffxi.get_info().zone
        if query['placeholder'] and placeholder_lists[zone_id] then
            matched = placeholder_lists[zone_id][query['placeholder']][v.Index]
        end

        if matched then
            local mob_name = mob_list[v.Index]
            table.insert(found, {Index = v.Index, Name = mob_name})
        end
    end

    if #found == 1 then
        local text = track and 'Tracking' or 'Found'
        log(string.format('%s: %-16s [0x%04X]', text, found[1].Name, found[1].Index))
        if track then
            windower.ffxi.wide_scan_track_index(found[1].Index)
        end
    elseif #found == 0 then
        log('No matches found.')
    else
        local text = track and 'Refine your search' or ''
        log('Multiple matches found. ' .. text)
        table.sort(found, function(a, b)
            return a.Index < b.Index
        end)

        for _, value in pairs(found) do
            log(string.format('- %-16s [0x%04X]', value.Name, value.Index))
        end
    end
end

function widescan.ingest_mob_data(mob)
    if mob.Type == 0 then
        print(mob.Type, mob.Index, mob.Name)
        return
    end

    table.insert(scan_list, mob)
end
packet_handler:register(0x0F4, widescan.ingest_mob_data)

local scan_states = {
    [0x01] = function()
        if scan_call_back then
            scan_list = {}
        end
    end,

    [0x02] = function()
        if scan_call_back then
            coroutine.resume(scan_call_back)
        end
    end
}

function widescan.scan_state_machine(data)
    if scan_states[data.Type] then
        scan_states[data.Type]()
    end
end
packet_handler:register(0x0F6, widescan.scan_state_machine)

function widescan.request_scan()
    log('Scanning...')
    local tracking = windower.ffxi.wide_scan_get_tracking_info()
    if tracking then
        windower.ffxi.wide_scan_stop_tracking()
    else
        local packet = packets.new('outgoing', 0x0F4, {
            ['Flags'] = 1
        })
        packets.inject(packet)
    end
end

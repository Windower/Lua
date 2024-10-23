_addon = {}
_addon.name = 'switch_focus'
_addon.version = '1.0.0'
_addon.author = 'WindowerDevTeam'
_addon.commands = {'swf', 'switch', 'switch_focus'}

require('tables')
require('strings')
local box_list = require('box_list')

local back_name
local switch = {cmd = {}}

function switch.command(cmd, ...)
    local args = T{...}:map(string.lower) or {}
    cmd = cmd and cmd:lower() or 'help'
    if switch.cmd[cmd] then
        switch.cmd[cmd](args)
    end
end
windower.register_event('addon command', switch.command)

function switch.cmd.to(args)
    local name = args[1]

    if not box_list:get_index_of(name) then
        for i = 1, box_list:len() do
            local value = box_list[i]
            if windower.wc_match(value, name .. '*') then
                name = value
                break
            end
        end
    end

    windower.send_ipc_message(string.format('to,%s,%s', windower.ffxi.get_player().name:lower(), name:lower()))
    coroutine.sleep(0.1)

    if (windower.has_focus()) then
        windower.send_ipc_message(string.format('to,%s,@lobby', windower.ffxi.get_player().name:lower(), name:lower()))
    end
end

function switch.cmd.back()
    if back_name then
        windower.send_ipc_message(string.format('to,%s,%s', windower.ffxi.get_player().name:lower(), back_name:lower()))
    end
end

function switch.cmd.prev()
    local name = windower.ffxi.get_player().name:lower()
    local index = box_list:get_index_of(name)

    local prev = box_list[((index - 2) % box_list:len()) + 1]
    while (next ~= name) do
        switch.cmd.to({prev})
        coroutine.sleep(0.1)

        if (not windower.has_focus()) then
            break
        end

        windower.send_ipc_message('clear,' .. prev)
        box_list:remove(prev)

        prev = box_list[((index - 2) % box_list:len()) + 1]
    end
end
switch.cmd.p = switch.cmd.prev

function switch.cmd.next()
    local name = windower.ffxi.get_player().name:lower()
    local index = box_list:get_index_of(name)

    local next = box_list[(index % box_list:len()) + 1]
    while (next ~= name) do
        switch.cmd.to({next})
        coroutine.sleep(0.1)

        if (not windower.has_focus()) then
            break
        end

        windower.send_ipc_message('clear,' .. next)
        box_list:remove(next)

        next = box_list[(index % box_list:len()) + 1]
    end
end
switch.cmd.n = switch.cmd.next

switch.ipc = {}
local function ipc_message(raw_msg)
    raw_msg = raw_msg and raw_msg:lower()
    print(raw_msg)
    local msg = string.split(''..raw_msg, ',')
    if switch.ipc[msg[1]] then
        switch.ipc[msg[1]](msg)
    end
end
windower.register_event('ipc message', ipc_message)

function switch.ipc.to(msg)
    local from_name = msg[2]
    local to_name = msg[3]
    local player =  windower.ffxi.get_player()
    if windower.has_focus ~= true and ((player and to_name == player.name:lower()) or (to_name == '@lobby' and not windower.ffxi.get_info().logged_in)) then
        back_name = from_name
        windower.take_focus()
    end
end

function switch.ipc.join(msg)
    local name = msg[2]
    if not box_list:get_index_of(name) then
        box_list:add(name)
        windower.send_ipc_message('join,' .. windower.ffxi.get_player().name:lower())
    end
end

function switch.ipc.clear(msg)
    local name = msg[2]
    box_list:remove(name)
end

local function on_login(name)
    box_list:add(name:lower())
    windower.send_ipc_message('clear,' .. name:lower()) --We need to do this to ensure we get everyone to respond.
    windower.send_ipc_message('join,' .. name:lower())
end
windower.register_event('login', on_login)

local function on_logout(name)
    windower.send_ipc_message('clear,' .. name:lower())
end
windower.register_event('logout',  on_logout)

local function on_load()
    if windower.ffxi.get_info().logged_in then
        on_login(windower.ffxi.get_player().name)
    end
end
windower.register_event('load', on_load)

local function on_unload()
    if windower.ffxi.get_info().logged_in then
        on_logout(windower.ffxi.get_player().name)
    end
end
windower.register_event('unload', on_unload)

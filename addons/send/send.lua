_addon.version = '1.4'
_addon.name = 'Send'
_addon.command = 'send'
_addon.author = 'Byrth, Lili'

require('tables')

local debug = false

-- The @job:N target (e.g. @cor:2) selects the Nth character on a job. Every instance announces its
-- name and job over IPC so the sender can look it up. Characters sharing a job are ordered
-- alphabetically. The command itself is never modified.
local JOBS = T{'war','mnk','whm','blm','rdm','thf','pld','drk','bst','brd','rng','sam','nin','drg','smn',
               'blu','cor','pup','dnc','sch','geo','run'}
local roster = {}    -- character name -> job (lowercase)

local function announce()
    local player = windower.ffxi.get_player()
    if player and player.main_job then
        roster[player.name] = player.main_job:lower()
        windower.send_ipc_message('send @roster %s %s':format(player.name, player.main_job:lower()))
    end
end

-- Returns the nth (default 1) character name on the job, ordered alphabetically.
local function lookup_job(job, n)
    job = job:lower()
    if not JOBS:contains(job) then return nil end
    local names = {}
    for name, j in pairs(roster) do
        if j == job then names[#names + 1] = name end
    end
    table.sort(names, function(a, b) return a:lower() < b:lower() end)
    return names[n or 1]
end

require('functions')
require('chat')

windower.register_event('addon command', function(target, ...)
    if not target then
        error('No target provided.')
        return
    end

    if not ... then
        error('No command provided.')
        return
    end

    target = target:lower()

    if target == '@debug' then
        local arg = (... == 'on' or ... == 'off') and ... or error('Invalid argument. Usage: send @debug <on|off>')
        debug = arg == 'on'
        return windower.add_to_chat(55, 'send: debug ' .. tostring(debug))
    end

    local command = T{...}:map(string.strip_format .. windower.convert_auto_trans):map(function(str)
        return str:find(' ', string.encoding.shift_jis, true) and str:enclose('"') or str
    end):sconcat():gsub('<(%a+)id>', function(target_string)
        local entity = windower.ffxi.get_mob_by_target(target_string)
        return entity and entity.id or '<' .. target_string .. 'id>'
    end)

    -- @job:N as a target resolves to that character's name
    local tjob, tidx = target:match('^@(%a%a%a):(%d+)$')
    if tjob and JOBS:contains(tjob) then
        local name = lookup_job(tjob, tonumber(tidx))
        if not name then
            return windower.add_to_chat(55, 'send: no character found for ' .. target)
        end
        target = name:lower()
    end

    local player = windower.ffxi.get_player()

    if player and target == player['name']:lower() then
        execute_command(command)
        return
    elseif target == '@all' then
        execute_command(command)
    elseif player and target == '@'..player.main_job:lower() then
        execute_command(command)
    elseif target == '@party' then
        if player then
            execute_command(command)
        end
        target = target .. player.name
    elseif target == '@zone' then
        if player then
            execute_command(command)
        end
        target = target .. windower.ffxi.get_info().zone
    end

    command = 'send ' .. target .. ' ' .. command

    if debug then
        windower.add_to_chat(207, 'send (debug): ' .. command)
    end

    windower.send_ipc_message(command)
end)

windower.register_event('ipc message', function (msg)
    if debug then
        windower.add_to_chat(207, 'send receive (debug): ' .. msg)
    end

    local split = msg:split(' ', string.encoding.shift_jis, 3, false, true)
    if #split < 3 or split[1] ~= 'send' then
        return
    end

    if split[2] == '@roster' then
        local name, job = split[3]:match('^(%S+) (%S+)$')
        if name then roster[name] = job end
        return
    elseif split[2] == '@rosterreq' then
        announce()
        return
    end

    local target = split[2]
    local command = split[3]

    if target == '@all' or target == '@others' then
        execute_command(command)
        return
    end

    local info = windower.ffxi.get_info()
    if not info.logged_in then
        return
    end

    local player = windower.ffxi.get_player()

    if target:lower() == player.name:lower() then
        execute_command(command)
    elseif target:startswith('@') then
        local arg = target:sub(2):lower()

        if arg == player.main_job:lower() then
            execute_command(command)
        elseif arg:startswith('party') then
            local sender = arg:sub(6, #arg):lower()
            local party = windower.ffxi.get_party()
            for i = 1, 5 do
                local idx = 'p'..i
                if party[idx] and party[idx].name:lower() == sender then
                    execute_command(command)
                    return
                end
            end
        elseif arg:startswith('zone') then
            if tonumber(arg:sub(5)) == info.zone then
                execute_command(command)
            end
        end
    end
end)

function execute_command(msg)
    if msg:sub(1, 2) == '//' then
        windower.send_command(msg:sub(3))
    elseif msg:sub(1, 1) == '/' then
        windower.send_command('input '..msg)
    elseif msg:sub(1, 3) == 'atc' then
        windower.add_to_chat(55, msg:sub(5))
    else
        windower.send_command(msg)
    end
end

windower.register_event('login', function()
    coroutine.schedule(function()
        announce()
        windower.send_ipc_message('send @rosterreq x')
    end, 3)
end)

windower.register_event('job change', 'zone change', function()
    coroutine.schedule(announce, 3)
end)

windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in then
        announce()
        windower.send_ipc_message('send @rosterreq x')
    end
end)

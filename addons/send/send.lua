_addon.version = '1.2'
_addon.name = 'Send'
_addon.command = 'send'
_addon.author = 'Byrth, Lili'

local debug = false

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
        return str:find(' ', string.encoding.shift_jis) and str:enclose('"') or str
    end):sconcat():gsub('<(%a+)id>', function(target_string)
        local entity = windower.ffxi.get_mob_by_target(target_string)
        return entity and entity.id or '<' .. target_string .. 'id>'
    end)

    local player = windower.ffxi.get_player()

    if player and target == player['name']:lower() then
        execute_command(command)
        return
    elseif player and target == '@all' or target == '@'..player.main_job:lower() then
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

    local info = windower.ffxi.get_info()
    if not info.logged_in then
        return
    end

    local split = msg:split(' ', string.encoding.shift_jis, 3)
    if #split < 3 or split[1] ~= 'send' then
        return
    end

    local target = split[2]
    local command = split[3]

    local player = windower.ffxi.get_player()

    if target:lower() == player.name:lower() then
        execute_command(command)
    elseif target:startswith('@') then
        local arg = target:sub(2):lower()

        if arg == player.main_job:lower() or arg == 'all' or arg == 'others' then
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

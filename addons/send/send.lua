_addon.version = '1.1'
_addon.name = 'Send'
_addon.command = 'send'
_addon.author = 'Byrth'

local debug = false

function print_debug(msg)
    if not debug then
        return
    end

    windower.add_to_chat(55, msg)
end

windower.register_event('addon command',function (...)
    local num_args = select('#', ...)
    if num_args < 2 then
        windower.add_to_chat(55,"Send commands must be in the format 'send <name/@all/@party/@others/@job> <command>'")
        return
    end

    local args = {...}
    local target = args[1]
    local player = windower.ffxi.get_player()

    print_debug('Processing command')
    print_debug(' - Target: '..target)
    print_debug(' - Sender: '..player['name'])

    if player and target:lower() == player['name']:lower() then
        table.remove(args, 1)
        relevant_msg(table.concat(args, ' '))
    elseif target:lower() == '@all' or target:lower() == '@party' or target:lower() == '@'..player.main_job:lower() then
        send_msg(player, args)
        table.remove(args, 1)
        relevant_msg(table.concat(args, ' '))
    else
        send_msg(player, args)
    end
end)

windower.register_event('ipc message',function (msg)

    print_debug('Received message')
    print_debug(' - '..msg)

    local broken = split(msg, ' ')

    local command = table.remove(broken, 1)
    if command ~= 'send' then
        print_debug('Message discarded because it is not handled by this addon')
        return
    end

    if #broken < 2 then
        print_debug('Message discarded because it is not in the format <name/@all/@party/@others/@job> <command>')
        return
    end

    local qual = table.remove(broken, 1)
    local qual_broken = split(qual, ':')
    local target = qual_broken[1]
    local sender = #qual_broken > 1 and qual_broken[2] or ''
    local player = windower.ffxi.get_player()

    if player and target:lower() == player.name:lower() then
        relevant_msg(table.concat(broken,' '))
        return
    end

    if string.char(target:byte(1)) == '@' then
        local arg = string.char(target:byte(2, target:len()))
        if player and arg:upper() == player.main_job:upper() then
            relevant_msg(table.concat(broken,' '))
            return
        elseif arg:upper() == 'ALL' then
            relevant_msg(table.concat(broken,' '))
            return
        elseif arg:upper() == 'OTHERS' then
            relevant_msg(table.concat(broken,' '))
            return
        elseif arg:upper() == 'PARTY' then
            local party = windower.ffxi.get_party()
            for i = 0, 4 do
                local index = "p" .. i
                if party[index] and party[index].name:lower() == sender:lower() then
                    relevant_msg(table.concat(broken,' '))
                    return
                end
            end

            print_debug('Message discarded because player '..player['name']..' is not in a party with '..sender)

            return
        else
            print_debug('Message discarded because target '..target..' is not valid or is not meant for player '..player['name'])
        end
    end
end)

function split(msg, match)
    if msg == nil then return '' end
    local length = msg:len()
    local splitarr = {}
    local u = 1
    while u <= length do
        local nextanch = msg:find(match,u)
        if nextanch ~= nil then
            splitarr[#splitarr+1] = msg:sub(u,nextanch-match:len())
            if nextanch~=length then
                u = nextanch+match:len()
            else
                u = length
            end
        else
            splitarr[#splitarr+1] = msg:sub(u,length)
            u = length+1
        end
    end
    return splitarr
end

function send_msg(player, args)
    args[1] = args[1]..':'..player['name']

    local term = table.concat(args, ' ')
    term = term:gsub('<(%a+)id>', function(target_string)
        local entity = windower.ffxi.get_mob_by_target(target_string)
        return entity and entity.id or '<' .. target_string .. 'id>'
    end)

    local msg = 'send ' .. term

    print_debug('Sending command')
    print_debug(' - '..msg)

    windower.send_ipc_message(msg)
end

function relevant_msg(msg)
    if msg:sub(1,3)=='atc' then
        windower.add_to_chat(55,msg:sub(5))
        return
    end

    if msg:sub(1,2)=='//' then
        msg = msg:sub(3)
    elseif msg:sub(1,1)=='/' then
        msg = 'input '..msg
    end

    print_debug('Executing command')
    print_debug(' - '..msg)

    windower.send_command(msg)
end


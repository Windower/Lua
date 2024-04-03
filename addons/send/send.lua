_addon.version = '1.2'
_addon.name = 'Send'
_addon.command = 'send'
_addon.author = 'Byrth, Lili'

local debug = false

require('chat')

windower.register_event('addon command', function (...)
    if ...:lower() == '@debug' then
        debug = not debug
        windower.add_to_chat(55, 'send: debug ' .. tostring(debug))
        return
    end

    local term = T{...}:map(function(str)
        str = windower.convert_auto_trans(str):strip_format()
        if str:find(' ', string.encoding.shift_jis) then
            return str:enclose('"')
        end
        return str
    end):sconcat():gsub('<(%a+)id>', function(target_string)
        local entity = windower.ffxi.get_mob_by_target(target_string)
        return entity and entity.id or '<' .. target_string .. 'id>'
    end)

    if debug then
        windower.add_to_chat(207, 'send (debug): '..term)
    end

    local broken_init = split(term, ' ')
    local qual = table.remove(broken_init, 1):lower()
    local player = windower.ffxi.get_player()

    if #broken_init < 1 then
        return
    end

    if player and qual == player['name']:lower() then
        relevant_msg(table.concat(broken_init, ' '))
        return
    elseif qual == '@all' or qual == '@'..player.main_job:lower() then
        if player then
            relevant_msg(table.concat(broken_init, ' '))
        end
    elseif qual:startswith('@party') then
        if player then
            relevant_msg(table.concat(broken_init, ' '))
        end
        local qual = qual .. windower.ffxi.get_player().name
        term =  qual .. ' ' .. table.concat(broken_init, ' ')
    elseif qual:startswith('@zone') then
        if player then
            relevant_msg(table.concat(broken_init, ' '))
        end
        local qual = qual .. windower.ffxi.get_info().zone
        term =  qual .. ' ' .. table.concat(broken_init, ' ')
    end

    windower.send_ipc_message('send ' .. term)
end)

windower.register_event('ipc message', function (msg)
    if debug then
        windower.add_to_chat(207, 'send receive (debug): ' .. msg)
    end

    local broken = split(msg, ' ')
    local command = table.remove(broken, 1)

    if command ~= 'send' or #broken < 2 then
        return
    end

    local qual = table.remove(broken, 1)
    local player = windower.ffxi.get_player()
    if not player then
        return
    end

    if qual:lower() == player.name:lower() then
        relevant_msg(table.concat(broken, ' '))
    elseif string.char(qual:byte(1)) == '@' then
        local arg = string.char(qual:byte(2, qual:len())):upper()

        if arg == player.main_job:upper() or arg == 'ALL' or arg == 'OTHERS' then
            relevant_msg(table.concat(broken, ' '))
        elseif arg:startswith('PARTY') then
            local name = arg:sub(6, #arg):lower()
            local party = windower.ffxi.get_party()
            local sameparty = function()
                for i=1, 5 do
                    local idx = 'p'..i
                    if party[idx] and party[idx].name:lower() == name then
                        return true
                    end
                end
            end()

            if sameparty then
                relevant_msg(table.concat(broken, ' '))
            end
        elseif arg:upper():startswith('ZONE') then
            local samezone = tonumber(arg:sub(5, #arg)) == windower.ffxi.get_info().zone

            if samezone then
                relevant_msg(table.concat(broken, ' '))
            end
        end
    end
end)

function split(msg, match)
    if msg == nil then return '' end
    local length = msg:len()
    local splitarr = {}
    local u = 1
    while u <= length do
        local nextanch = msg:find(match, string.encoding.shift_jis, u)
        if nextanch ~= nil then
            splitarr[#splitarr + 1] = msg:sub(u, nextanch - match:len())
            if nextanch ~= length then
                u = nextanch + match:len()
            else
                u = length
            end
        else
            splitarr[#splitarr + 1] = msg:sub(u, length)
            u = length + 1
        end
    end
    return splitarr
end

function relevant_msg(msg)
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

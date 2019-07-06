_addon.version = '1.0'
_addon.name = 'Send'
_addon.command = 'send'
_addon.author = 'Byrth'

windower.register_event('addon command',function (...)
    local term = table.concat({...}, ' ')

    term = term:gsub('<(%a+)id>', function(target_string)
        local entity = windower.ffxi.get_mob_by_target(target_string)
        return entity and entity.id or '<' .. target_string .. 'id>'
    end)

    local broken_init = split(term, ' ')
    local qual = table.remove(broken_init,1)
    local player = windower.ffxi.get_player()

    if qual:lower()==player['name']:lower() then
        if broken_init ~= nil then
        relevant_msg(table.concat(broken_init,' '))
        end
    elseif qual:lower()=='@all' or qual:lower()=='@'..player.main_job:lower() then
        if broken_init ~= nil then
            relevant_msg(table.concat(broken_init,' '))
        end
        windower.send_ipc_message('send ' .. term)
    else
        windower.send_ipc_message('send ' .. term)
    end
end)

windower.register_event('ipc message',function (msg)
    local broken = split(msg, ' ')

    local command = table.remove(broken, 1)
    if command ~= 'send' then
        return
    end

    if #broken < 2 then return end
    
    local qual = table.remove(broken,1)
    local player = windower.ffxi.get_player()
    if qual:lower()==player.name:lower() then
        relevant_msg(table.concat(broken,' '))
    end
    if string.char(qual:byte(1)) == '@' then
        local arg = string.char(qual:byte(2, qual:len()))
        if arg:upper() == player.main_job:upper() then
            if broken ~= nil then
                relevant_msg(table.concat(broken,' '))
            end
        elseif arg:upper() == 'ALL' then
            if broken ~= nil then
                relevant_msg(table.concat(broken,' '))
            end
        elseif arg:upper() == 'OTHERS' then
            if broken ~= nil then
                relevant_msg(table.concat(broken,' '))
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

function relevant_msg(msg)
    local player = windower.ffxi.get_player()
    
    if msg:sub(1,2)=='//' then
        windower.send_command(msg:sub(3))
    elseif msg:sub(1,1)=='/' then
        windower.send_command('input '..msg)
    elseif msg:sub(1,3)=='atc' then
        windower.add_to_chat(55,msg:sub(5))
    else
        windower.send_command(msg)
    end

end


_addon.commands = {'answeringmachine','am'}
_addon.name = 'AnsweringMachine'
_addon.author = 'Byrth'
_addon.version = '1.4'


texts = require('texts')
AM_box = texts.new('')
AM_box:size(24)

last_activity = os.time()
unseen_message_count = 0

textspeed = 0
text_list = {[1]=os.time()}
text_list[2] = text_list[1]
text_list[3] = text_list[1]
text_list[4] = text_list[1]
text_list[5] = text_list[1]
text_list[6] = text_list[1]
text_list[7] = text_list[1]
text_list[8] = text_list[1]
text_list[9] = text_list[1]
text_list[10] = text_list[1]
text_index = 1

recording = {}

windower.register_event('addon command',function (...)
    term = table.concat({...}, ' ')
    local broken = split(term, ' ')
    if broken[1] ~= nil then
        if broken[1]:upper() == "CLEAR" then
            if broken[2] == nil then
                recording = {}
                windower.add_to_chat(4,'Answering Machine>> Blanking the recordings')
            elseif recording[broken[2]:upper()] then
                windower.add_to_chat(4,'Answering Machine>> Deleting conversation with '..uc_first(broken[2]))
                recording[broken[2]:upper()]=nil
            else
                windower.add_to_chat(5,'Cancel error: Could not find specified player in tell history')
            end
        elseif broken[1]:upper() == "LIST" then
            local trig
            for i,v in pairs(recording) do
                windower.add_to_chat(5,#v..' exchange'..pl(#v)..' with '..uc_first(i))
                trig = true
            end
            if not trig then
                windower.add_to_chat(5,'No exchanges recorded.')
            end
        elseif broken[1]:upper() == "PLAY" then
            if broken[2] then
                if recording[broken[2]:upper()] then
                    local num = #recording[broken[2]:upper()]
                    windower.add_to_chat(5,num..' exchange'..pl(num)..'with '..uc_first(broken[2]))
                    print_messages(recording[broken[2]:upper()],broken[2])
                end
            else
                windower.add_to_chat(4,'Answering Machine>> Playing back all messages')
                for i,v in pairs(recording) do
                    windower.add_to_chat(5,#v..' exchange'..pl(#v)..' with '..uc_first(i))
                    print_messages(v,i)
                end
            end
        elseif broken[1]:upper() == "HELP" then
            print('am clear <name> : Clears current messages, or only messages from <name> if provided')
            print('am help : Lists these commands!')
            print('am list : Lists the names of people who have sent you tells')
            print('am msg <message> : Sets your away message, which will be sent to non-GMs only once after plugin load or message clear')
            print('am play <name> : Plays current messages, or only messages from <name> if provided')
        elseif broken[1]:upper() == "MSG" then
            table.remove(broken,1)
            if #broken ~= 0 then
                away_msg=table.concat(broken,' ')
                windower.add_to_chat(123,'AnsweringMachine: Message set to: '..away_msg)
            end
        elseif broken[1] == 'box' and broken[2] == 'pos' and tonumber(broken[3]) and tonumber(broken[4]) then
            AM_box:pos(tonumber(broken[3]),tonumber(broken[4]))
        end
    end
end)

windower.register_event('chat message',function(message,player,mode,isGM)
    if mode==3 then
        if recording[player:upper()] then
            recording[player:upper()][#recording[player:upper()]+1] = {message=message,outgoing=false,timestamp=os.time(),seen=false}
        else
            recording[player:upper()] = {{message=message,outgoing=false,timestamp=os.time(),seen=false}}
            if away_msg and not isGM then
                windower.send_command('@input /tell '..player..' '..away_msg)
            end
        end
        unseen_message_count = unseen_message_count + 1
    end
end)

windower.register_event('outgoing chunk',function(id,original,modified,injected,blocked)
    if not blocked and id == 0x0B6 then
        local name = trim(original:sub(0x6,0x14))
        local message = trim(original:sub(0x15))
        if recording[name:upper()] then
            recording[name:upper()][#recording[name:upper()]+1] = {message=message,outgoing=true,timestamp=os.time(),seen=true}
        else
            recording[name:upper()] = {{message=message,outgoing=true,timestamp=os.time(),seen=true}}
        end
    end
end)

windower.register_event('incoming text',function(org,mod,org_m,mod_m,blocked)
    if not blocked then
        text_list[text_index] = os.time()
        text_index = text_index + 1
        if text_index%11==0 then text_index = 1 end
    end
end)

function split(msg, match)
    local length = msg:len()
    local splitarr = {}
    local u = 1
    while u < length do
        local nextanch = msg:find(match,u)
        if nextanch ~= nil then
            splitarr[#splitarr+1] = msg:sub(u,nextanch-1)
            if nextanch~=length then
                u = nextanch+1
            else
                u = length
            end
        else
            splitarr[#splitarr+1] = msg:sub(u,length)
            u = length
        end
    end
    return splitarr
end

function uc_first(msg)
    local length = msg:len()
    local first_char = msg:sub(1,1)
    local rest = msg:sub(2,length)
    return first_char:upper()..rest:lower()
end

function trim(msg)
    for i=2,string.len(msg) do
        if msg:byte(i) == 0 then
            return msg:sub(1,i-1)
        end
    end
    return msg
end

function pl(num)
    if num > 1 then
        return 's'
    else
        return ''
    end
end

function arrows(bool,name)
    if bool then
        return name..'>> '
    else
        return '>>'..name..' : '
    end
end

function print_messages(tab,name)
    for p,q in ipairs(tab) do
        windower.add_to_chat(4,os.date('%H:%M:%S',q.timestamp)..' '..arrows(q.outgoing,uc_first(name))..q.message)
        tab[p].seen = true
    end
end

windower.register_event('postrender',function()
    AM_box:clear()
    AM_box:append(unseen_message_count..' Message'..pl(unseen_message_count))
    local t = os.clock()%1
    AM_box:bg_color(255,150+100*math.sin(t*math.pi),150+100*math.sin(t*math.pi))
    AM_box:color(0,0,0)
    if unseen_message_count > 0 then
        AM_box:show()
    else
        AM_box:hide()
    end
end)

function activity()
    last_activity = os.time()
    if unseen_message_count > 0 then
        local temp_message_count = 0
        for i,v in pairs(recording) do
            for n,m in pairs(v) do
                if not m.seen then
                    if m.timestamp < text_list[((text_index+1)==11 and 1) or (text_index+1)] then
                        temp_message_count = temp_message_count + 1
                    else
                        recording[i][n].seen = true
                    end
                end
            end
        end
        unseen_message_count = temp_message_count
    end
end

windower.register_event('keyboard',activity)

windower.register_event('mouse',activity)
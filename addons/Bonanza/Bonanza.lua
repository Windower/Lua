--[[
Copyright © 2018, from20020516
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of Bonanza nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL from20020516 BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.name = 'Bonanza'
_addon.author = 'from20020516'
_addon.version = '1.1'
_addon.command = 'bonanza'

extdata = require('extdata')
packets = require('packets')
require('logger')

marble = {id=2559,price=2000,limit=10} --general settings

win_numbers = {}
math.randomseed(os.time())

--search your bags for bonanza marble and get number then add prefix 0
function search_marbles()
    local marbles = {}
    local bags = {0,1,2,4,5,6,7,9}
    local items = windower.ffxi.get_items
    for bag_ind=1,#bags do
        for index=1,windower.ffxi.get_bag_info(bags[bag_ind]).max do
            local item = items(bags[bag_ind],index)
            if item.id == marble.id then --bonanza marble
                local five_digits = string.format('%05s',extdata.decode(item).number)
                table.insert(marbles,{bags[bag_ind],index,five_digits})
            end
        end
    end
    return marbles;
end

windower.register_event('addon command',function(...)
    moogle = windower.ffxi.get_mob_by_name('Bonanza Moogle')
    decides = {}
    local cmd={...}
    local count = marble.limit-#search_marbles()
    for i=1,#cmd do
        math.random() --shuffle rand
        cmd[i] = tonumber(cmd[i]) and cmd[i]*1 or cmd[i]
    end
    if not cmd[1] or cmd[1] == 'help' then
        local chat = windower.add_to_chat
        local color = string.color
        chat(1,'Bonanza - Command List:')
        chat(207,'//bonanza '..color('<number> [number] ...',166))
        chat(160,' purchase specified marble(s).')
        chat(207,'//bonanza '..color('random',166))
        chat(160,' purchase up to 10 marbles with at random.')
        chat(207,'//bonanza '..color('sequence <number>',166))
        chat(160,' purchase up to 10 marbles with consecutive number.')
        chat(160,' e.g. '..color('15250',166)..' then buying '..color('15250',166)..' to '..color('15259',166)..'.')
        chat(207,'//bonanza '..color('last <number>',166))
        chat(160,' purchase up to 10 random marbles with tail of specified 0-9.')
        local zero = color('0',166)
        chat(160,' e.g. '..zero..' then buying 2224'..zero..', 6231'..zero..', 4586'..zero..'...')
    elseif cmd[1] == 'judge' then
        windower.chat.input('/smes')
    elseif count == 0 then
        error('you have already '..marble.limit..' marbles.')
    elseif cmd[1] == 'random' then
        for i=1,count do
            table.insert(decides,math.random(0,99)+math.random(0,99)*100+math.random(0,9)*10000)
        end
    elseif cmd[1] == 'sequence' then
        local n = math.min(cmd[2],10000-count)
        for i=n,n+count-1 do
            table.insert(decides,i)
        end
    elseif cmd[1] == 'last' and 10 > cmd[2] then
        for i=1,count do
            table.insert(decides,tonumber(math.random(0,9999)..cmd[2]))
        end
    elseif 100000 > cmd[1] and not cmd[marble.limit+1] then
        decides = cmd
    end

    if #decides > 0 then
        talk_moogle()
    end
end)

function talk_moogle()
    if #decides > 0 then
        hide_ui = true
        local packet = packets.new('outgoing',0x01A,{
            ['Target']=moogle.id,
            ['Target Index']=moogle.index})
        packets.inject(packet)
    end
end

windower.register_event('incoming chunk',function(id,data)
    if S{0x020,0x034}[id] and hide_ui then
        --got a marble.
        local p = packets.parse('incoming',data)
        if id == 0x020 and p['Item'] == marble.id and p['Bag'] == 0 then
            local item = windower.ffxi.get_items(0,p['Index'])
            if extdata.decode(item).number == decides[1] then
                hide_ui = false
                table.remove(decides,1)
                talk_moogle()
            end
        --responced to talk.
        elseif id == 0x034 and p['NPC'] == moogle.id then
            if moogle.distance > 36 then
                error('not close enough to Bonanza Moogle.')
            elseif marble.price > windower.ffxi.get_items().gil then
                error('not have enough gils.')
            else
                local packet = packets.new('outgoing',0x05B)
                local i = decides[1]
                log('Purchase a Bonanza Marble #'..string.format('%05s',i))
                --packet part 1
                    packet['Target']=moogle.id
                    packet['Option Index']=2+i%256*256
                    packet['Target Index']=moogle.index
                    packet['Automated Message']=true
                    packet['_unknown1']=(i-i%256)/256
                    packet['Zone']=p['Zone']
                    packet['Menu ID']=p['Menu ID']
                packets.inject(packet)
                --packet part 2
                    packet['Option Index']=3
                    packet['Automated Message']=false
                packets.inject(packet)
                return true; --hide ui
            end
        end
    end
end)

--get winning numbers(str) from /smes.
windower.register_event('incoming text',function(original,modified,mode)
    local jis = windower.from_shift_jis(original) --valid in english environment
    if mode == 200 and windower.regex.match(jis,'digit|けた') then
        local numbers = windower.regex.match(jis,'["「]([0-9]+)[」"]')[1][1]
        table.insert(win_numbers,6-string.len(numbers),numbers)
        if #win_numbers == 5 then
            scan_marbles()
        end
    end
end)

function scan_marbles()
    log('Winning numbers is..',unpack(win_numbers))
    local marbles = search_marbles()
    local colors = {51,18,166,207,208,161}
    for m=1,#marbles do
        local number = marbles[m][3]
        if S{1,2,4,9}[marbles[m][1]] and windower.ffxi.get_info().mog_house
        or S{5,6,7}[marbles[m][1]] then
            windower.ffxi.get_item(marbles[m][1],marbles[m][2])
        end
        for r=1,5 do
            local text = _addon.name..': #'..string.format("%02s",m)..' '..number..' <Rank'
            if win_numbers[r] == windower.regex.match(number,"[0-9]{1,"..(6-r).."}$")[1][0] then
                windower.add_to_chat(colors[r],text..r..'>')
                break;
            elseif r == 5 then
                windower.add_to_chat(colors[6],text..'6'..'>')
            end
        end
    end
    win_numbers = {}
end

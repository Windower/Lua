--Copyright © 2017, Krizz
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of thtracker nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL KRIZZ BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


_addon.name = 'THTracker'
_addon.author = 'Krizz'
_addon.version = 1.2
_addon.commands = {'thtracker', 'th'}

config = require ('config')
texts = require ('texts')
packets = require('packets')
require('logger')

defaults = {}
defaults.pos = {}
defaults.pos.x = 1000
defaults.pos.y = 200
defaults.color = {}
defaults.color.alpha = 200
defaults.color.red = 200
defaults.color.green = 200
defaults.color.blue = 200
defaults.bg = {}
defaults.bg.alpha = 200
defaults.bg.red = 30
defaults.bg.green = 30
defaults.bg.blue = 30

settings = config.load(defaults)

th = texts.new('${th_string}', settings)

local th_table = {}

windower.register_event('addon command', function(command, ...)
    command = command and command:lower()
    local params = {...}

    if command == 'pos' then
        local posx, posy = tonumber(params[2]), tonumber(params[3])
        if posx and posy then
            th:pos(posx, posy)
        end
    elseif command == "hide" then
        th:hide()
    elseif command == 'show' then
        th:show()
    else
        print('th help : Shows help message')
        print('th pos <x> <y> : Positions the list')
        print('th hide : Hides the box')
        print('th show : Shows the box')
    end
end)

windower.register_event('incoming chunk', function(id, data)
    if id == 0x028 then
        local packet = packets.parse('incoming', data)
        if packet.Category == 1 and packet['Target 1 Action 1 Has Added Effect'] and packet['Target 1 Action 1 Added Effect Message'] == 603 then
            th_table[packet['Target 1 ID']] = 'TH: '..packet['Target 1 Action 1 Added Effect Param']
            update_text()
        elseif packet.Category == 3 and packet['Target 1 Action 1 Message'] == 608 then
            th_table[packet['Target 1 ID']] = 'TH: '..packet['Target 1 Action 1 Param']
            update_text()
        end
    elseif id == 0x038 then
        local packet = packets.parse('incoming', data)
        if th_table[packet['Mob']] and packet['Type'] == 'kesu' then
            th_table[packet['Mob']] = nil
            update_text()
        end
    elseif id == 0x00E then
        local packet = packets.parse('incoming', data)
        if th_table[packet['NPC']] and packet['Status'] == 0 and packet['HP %'] == 100 then
            th_table[packet['NPC']] = nil
            update_text()
        end
    end
end)

windower.register_event('zone change', function()
    th_table = {}
    update_text()
end)

windower.register_event('target change', function()
    update_text()
end)

function update_text()
    local current_string
    local target = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')
    if target and th_table[target.id] then
        current_string = target.name..'\n '..th_table[target.id]
        th:show()
    else
        current_string = ''
        th:hide()
    end
    th.th_string = current_string
end

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
_addon.version = 1.1
_addon.commands = {'thtracker', 'th'}

config = require ('config')
texts = require ('texts')
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

th = texts.new('No current mob', settings)

windower.register_event('addon command', function(command, ...)
    command = command and command:lower()
    local args = {...}

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

windower.register_event('incoming text', function(original, new, color)
    original = original:strip_format()
    local name, count = original:match('Additional effect: Treasure Hunter effectiveness against[%s%a%a%a]- (.*) increases to (%d+).')
    
    if name and count then
        name = name.gsub(name, "the ", "")
        mob = name
        th:text(' '..name..'\n TH: '..count);
        th:show()
    end

    local deadmob = original:match('%w+ defeats[%s%a%a%a]- (.*).')
    
    if deadmob then
        deadmob = deadmob.gsub(deadmob, "the ", "")
    end
    
    if deadmob == mob then
        
        th:text('No current mob')
        th:hide()
        mob = nil
    end

end)

windower.register_event('zone change', function()
    th:text('No current mob')
    th:hide()
end)
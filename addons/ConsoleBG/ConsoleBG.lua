_addon.name = 'ConsoleBG'
_addon.author = 'StarHawk'
_addon.version = '0.9.0.1'
_addon.command = 'consolebg'

config = require('config')
require('logger')

defaults = {}
defaults.bg = {}
defaults.bg.alpha = 255
defaults.bg.red = 0
defaults.bg.green = 0
defaults.bg.blue = 0
defaults.pos = {}
defaults.pos.x = 1
defaults.pos.y = 25
defaults.extents = {}
defaults.extents.x = 600
defaults.extents.y = 314

settings = config.load(defaults)

windower.prim.create('ConsoleBG')

consolesetting_commands = T{
    color = 'Color',
    c = 'Color',
    size = 'Size',
    s = 'Size',
}

config.register(settings, function(settings)
    windower.prim.set_color('ConsoleBG', settings.bg.alpha, settings.bg.red, settings.bg.green, settings.bg.blue)
    windower.prim.set_position('ConsoleBG', settings.pos.x, settings.pos.y)
    windower.prim.set_size('ConsoleBG', settings.extents.x, settings.extents.y)
end)

function consolesettings(command1, ...)
local values = L{...}
local command1 = command1:lower()
    if command1 == 'color' then
        log('Colors changed! Alpha: ' .. math.floor(values[1]) .. ' Red: ' .. math.floor(values[2]) .. ' Green: ' .. math.floor(values[3]) .. ' Blue: ' .. math.floor(values[4]))
        settings.bg.alpha = math.floor(tonumber(values[1]))
        settings.bg.red = math.floor(tonumber(values[2]))
        settings.bg.green = math.floor(tonumber(values[3]))
        settings.bg.blue = math.floor(tonumber(values[4]))
    elseif command1 == 'size' then
        log('Size changed! Anchor X: ' .. math.floor(values[1]) .. ' Width: ' .. math.floor(values[2]) .. ' Anchor Y: ' .. math.floor(values[3]) .. ' Height: ' .. math.floor(values[4]))
        settings.pos.x = math.floor(tonumber(values[1]))
        settings.extents.x = math.floor(tonumber(values[2]))
        settings.pos.y = math.floor(tonumber(values[3]))
        settings.extents.y = math.floor(tonumber(values[4]))
    end

   config.save(settings)
   config.reload(settings)
end

windower.register_event('addon command', function(command1, ...)
local argcount = select('#', ...)

    command1 = command1 and command1:lower() or 'help'

    if consolesetting_commands:containskey(command1) then
        command1 = consolesetting_commands[command1]
        if ((4 > argcount) or (argcount > 4)) then
            log('Invalid syntax. Please check the "help" command.')
        else
            consolesettings(command1, ...)  
        end

    elseif command1 == 'help' then
        print('%s v%s':format(_addon.name, _addon.version))
        print('    \\cs(255,255,255)color  <values>\\cr - Changes background color and transparency Valid range: 0-255')
        print('    \\crExample:\\cs(255,255,255) color 255 0 1 2\\cr - Alpha: 255 Red: 0 Green: 1 Blue: 2')
        print('    \\cs(255,255,255)size <values>\\cr - Set anchor points and size')
        print('    \\crExample:\\cs(255,255,255) size 1 700 25 310\\cr - X: 1 Width: 700 Y: 25 Height: 310')
    
    else
    log("Unknown command! Please use the 'help' command for a list of commands.")
    
    end
end)


windower.register_event('prerender', function()
    windower.prim.set_visibility('ConsoleBG', windower.console.visible())
end)

--[[
Copyright © 2015, Windower
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

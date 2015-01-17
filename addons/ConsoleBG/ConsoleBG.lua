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

config.register(settings, function(settings)
    windower.prim.set_color('ConsoleBG', settings.bg.alpha, settings.bg.red, settings.bg.green, settings.bg.blue)
    windower.prim.set_position('ConsoleBG', settings.pos.x, settings.pos.y)
    windower.prim.set_size('ConsoleBG', settings.extents.x, settings.extents.y)
end)

windower.register_event('addon command', function(command1, command2, command3)

    command1 = command1 and command1:lower() or 'help'
    command2 = command2 and command2:lower()
    command3 = command3 and command3:lower() or nil

    if command1 == 'pos' then
        if not (command2 == 'x' or command2 == 'y') then
            error('Please specify x or y.')
        elseif not command3 then
            error('Please specify a value.')
            return
        end

        if command2 == 'x' then
            settings.pos.x = math.floor(command3)
            log('Position X set to %s':format(settings.pos.x))
            config.save(settings)
            config.reload(settings)

        elseif command2 == 'y' then
            settings.pos.y = math.floor(command3)
            log('Position Y set to %s':format(settings.pos.y))
            config.save(settings)
            config.reload(settings)
        end

    elseif command1 == 'bg' then
    local bgvalue = tonumber(command3)
        if not (command2 == 'alpha' or command2 == 'red' or command2 == 'green' or command2 == 'blue') then
            error('Please specify alpha, red, green or blue.')
            return
        elseif (not bgvalue) or ((0 > bgvalue) or (bgvalue > 255)) then
            error('Please specify a value (0-255).')
            return
        end

        if command2 == 'alpha' then
            settings.bg.alpha = math.floor(command3)
            log('Alpha set to %s':format(settings.bg.alpha))
            config.save(settings)
            config.reload(settings)
            
        elseif command2 == 'red' then
            settings.bg.red = math.floor(command3)
            log('Red set to %s':format(settings.bg.red))
            config.save(settings)
            config.reload(settings)

        elseif command2 == 'green' then
            settings.bg.green = math.floor(command3)
            log('Green set to %s':format(settings.bg.green))
            config.save(settings)
            config.reload(settings)

        elseif command2 == 'blue' then
            settings.bg.blue = math.floor(command3)
            log('Blue set to %s':format(settings.bg.blue))
            config.save(settings)
            config.reload(settings)
        end

    elseif command1 == 'extent' then
        if not (command2 == 'x' or command2 == 'y') then
            error('Please specify x or y.')
        elseif not command3 then
            error('Please specify a value.')
            return
        end

        if command2 == 'x' then
            settings.extents.x = math.floor(command3)
            log('Extent X set to %s':format(settings.extents.x))
            config.save(settings)
            config.reload(settings)

        elseif command2 == 'y' then
            settings.extents.y = math.floor(command3)
            log('Extent Y set to %s':format(settings.extents.y))
            config.save(settings)
            config.reload(settings)
        end

    elseif command1 == 'help' then
        print('%s v%s':format(_addon.name, _addon.version))
        print('    \\cs(255,255,255)bg alpha|blue|green|red <value>\\cr - Changes background color/transparency')
        print('    \\cs(255,255,255)pos x|y <value>\\cr - Set anchor points')
        print('    \\cs(255,255,255)extent x|y <value>\\cr - Set the width/height')
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

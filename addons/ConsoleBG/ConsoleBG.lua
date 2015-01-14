_addon.name = 'ConsoleBG'
_addon.author = 'StarHawk'
_addon.version = '0.9.0.0'
_addon.command = 'consolebg'

config = require('config')

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

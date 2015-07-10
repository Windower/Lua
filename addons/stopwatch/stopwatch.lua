_addon.name = 'stopwatch'
_addon.author = 'Patrick Finnigan (Puhfyn@Ragnarok)'
_addon.version = '1.0'
_addon.commands = {'sw', 'stopwatch'}

require('logger')
config = require('config')
texts = require('texts')
timeit = require('timeit')

defaults = {}
defaults.pos = {}
defaults.pos.x = 450
defaults.pos.y = 0
defaults.text = {}
defaults.text.font = 'Arial'
defaults.text.size = 12

settings = config.load(defaults)
times = texts.new(settings)
is_active = false
cumulative_time = 0
timer = timeit.new()

windower.register_event('prerender', function()
    local info = windower.ffxi.get_info()
    if not info.logged_in then
        times:hide()
        return
    end

    total_time = cumulative_time
    if is_active == true then
        total_time = total_time + timer:check()
    end
    times:text(string.format('%0.2d:%0.2d:%0.2d', math.floor(total_time / 3600), math.floor(total_time / 60) % 60, math.floor(total_time) % 60))
    times:visible(true)
end)

windower.register_event('addon command', function(command)
    command = command:lower()

    if command == 'start' then
        if is_active == false then
            is_active = true
            timer:start()
        end
    elseif command == 'stop' then
        if is_active == true then
            is_active = false
            cumulative_time = cumulative_time + timer:stop()
        end
    elseif command == 'reset' then
        cumulative_time = 0
        timer:next()
    else
        log("'sw start' to start the stopwatch" )
        log("'sw stop' to stop the stopwatch")
        log("'sw reset' to reset the stopwatch cumulative time to 0")
    end
end)

--[[
Copyright © 2015, Patrick Finnigan
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of stopwatch nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Patrick Finnigan BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

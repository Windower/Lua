_addon.name = 'Logger'
_addon.author = 'Aikar'
_addon.version = '1.0.1.1'

require('chat')
local files = require('files')
local config = require('config')

local defaults = {}
defaults.AddTimestamp = false
defaults.TimestampFormat = '%H:%M:%S'

local settings = config.load(defaults)

local name
local file
local refresh_file
do
    local offset
    do
        local now = os.time()
        offset = os.difftime(now, os.time(os.date('!*t', now)))
    end

    local next = 0

    refresh_file = function(time)
        if time < next then
            return
        end

        local date = os.date('*t', time)
        file = files.new(('../../logs/%s_%.4u.%.2u.%.2u.log'):format(name, date.year, date.month, date.day))
        if not file:exists() then
            file:create()
        end

        next = math.floor((time + offset) / 86400) * 86400 - offset
    end
end

windower.register_event('incoming text', function(_, text, _, _, blocked)
    if blocked or text == '' then
        return
    end

    local time = os.time()
    refresh_file(time)

    local formatted = text:strip_colors()
    if settings.AddTimestamp then
        file:append(('%s %s\n'):format(os.date(settings.TimestampFormat, time), formatted))
    else
        file:append(('%s\n'):format(formatted))
    end
end)

windower.register_event('load', 'login', 'logout', function()
    local player = windower.ffxi.get_player()
    name = player and player.name
    if name ~= nil then
        refresh_file(os.time())
    else
        file = nil
    end
end)

--[[
Copyright 2015-2026 Windower

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
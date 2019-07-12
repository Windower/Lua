require('luau')
local url = require('socket.url')

_addon.name = 'Linker'
_addon.author = 'Arcon'
_addon.version = '1.1.0.0'
_addon.command = 'linker'
_addon.commands = {'web'}
_addon.language = 'English'

defaults = {}
defaults.raw = {}

-- FFXI info sites
defaults.raw.db = 'http://ffxidb.com/'
defaults.raw.ah = 'http://ffxiah.com/'
defaults.raw.bg = 'http://wiki.bluegartr.com/bg/Main_Page'
defaults.raw.ge = 'http://ffxi.gamerescape.com/wiki/Main_Page'
defaults.raw.wikia = 'http://wiki.ffxiclopedia.org/wiki/Main_Page'

-- FFXI community sites
defaults.raw.of = 'http://forum.square-enix.com/ffxi/forum.php'
defaults.raw.bgf = 'http://www.bluegartr.com/forum.php'
defaults.raw.ahf = 'http://www.ffxiah.com/forum'
defaults.raw.gw = 'http://guildwork.com/'

-- Windower
defaults.raw.win = 'http://windower.net/'
defaults.raw.winf = 'http://forums.windower.net/'
defaults.raw.winw = 'http://wiki.windower.net/'

-- Miscallenous sites
defaults.raw.g = 'http://google.com/'
defaults.raw.wa = 'http://wolframalpha.com/'

defaults.search = {}

-- FFXI info sites
defaults.search.db = 'http://ffxidb.com/search?q=${query}'
defaults.search.ah = 'http://ffxiah.com/search/item?q=${query}'
defaults.search.bg = 'http://wiki.bluegartr.com/index.php?title=Special:Search&search=${query}'
defaults.search.ge = 'http://ffxi.gamerescape.com/wiki/Special:Search?search=${query}'
defaults.search.wikia = 'https://ffxiclopedia.fandom.com/wiki/Special:Search?query=${query}'

-- Miscallenous sites
defaults.search.g = 'http://google.com/?q=${query}'
defaults.search.wa = 'http://wolframalpha.com/?i=${query}'

settings = config.load(defaults)

-- Interpreter

windower.register_event('addon command', function(command, ...)
    if not ... or not settings.search[command] and settings.raw[command] then
        windower.open_url(settings.raw[command])
    elseif settings.search[command] then
        local query_string = url.escape(L{...}:concat(' '))
        local adjusted_query_string = query_string:gsub('%%', '%%%%')
        windower.open_url((settings.search[command]:gsub('${query}', adjusted_query_string)))
    else
        error('Command "' .. command .. '" not found.')
    end
end)

--[[
Copyright (c) 2013-2014, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

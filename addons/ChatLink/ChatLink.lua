_addon.name = 'ChatLink'
_addon.author = 'Aureus'
_addon.version = '1.2.0.0'
_addon.commands = {'chatlink', 'clink'}

require('pack')
require('lists')
require('logger')
require('strings')

urls = L{}
ids = {}

pattern = L{
    -- Matches mail addresses
    '[\\w.-]+@[\\w.%-]+\\.[a-z]{2,5}\\b',
    -- Matches domain names preceded by a scheme
    '\\w+://[\\w%-]+(?:\\.[\\w%-]+)*\\.\\w{2,5}(?:\\:\\d{1,5}(?!\\d))?(?:/[^\\s]*)?',
    -- Matches IPv4, optionally preceded by a scheme
    '(?:\\w+://)?\\d{1,3}(?:\\.\\d{1,3}){3}(?:\\:\\d{1,5}(?!\\d))?(?:/[^\\s]*)?',
    -- Matches domain names without scheme. Only a few select TLDs allowed to avoid false positives
    '[\\w%-]+(?:\\.[\\w%-]+)*\\.(?:com|net|org|jp|uk|de|fr|it|es|ru|be|io)(?:\\:\\d{1,5}(?!\\d))?(?:/[^\\s]*)?',
}:concat('|')

replace = function(url)
    if not ids[url] then
        urls:append(url)
        ids[url] = #urls
    end

    return '[%u]%s':format(ids[url], url)
end

identifier = ('ChatLink' .. 0x01:char()):map(function(char)
    return 'h':pack(char:byte() * 0x100 + 0x1E)
end)

windower.register_event('incoming text', function(_, text, color)
    return not text:match(identifier) and windower.regex.replace(text, pattern, replace) or nil
end)

windower.register_event('addon command', function(command, id)
    command = command and command:lower() or 'help'

    if command == 'list' or command == 'l' then
        if urls:empty() then
            return log('No URLs found.')
        end

        log('%u %s found.':format(#urls, 'URL':plural(urls)))
        for url, key in urls:it() do
            log('%s    [%u]: %s':format(identifier, key, url))
        end

    else
        local key = tonumber(id)
        if not key then
            return error('The ID "%s" is not a number.':format(id))
        end

        if not urls[key] then
            return error('The ID "%s" was not found. Currently the highest ID is %u: %s':format(#urls, urls[#urls]))
        end

        if command == 'open' or command == 'o' then
            windower.open_url(urls[key])

        elseif command == 'copy' or command == 'c' then
            windower.copy_to_clipboard(urls[key])

        end

    end
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

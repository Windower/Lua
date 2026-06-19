_addon.name = 'ChatLink'
_addon.author = 'Aureus'
_addon.version = '1.3.0.0'
_addon.commands = {'chatlink', 'clink'}

require('pack')
require('lists')
require('logger')
require('strings')
require('chat')

local urls = L{}
local ids = {}

local block = L{}

local help_text = L{}
do
    local highlight_color = 300

    local make_line = function(line, command, ...)
        local sub = L{...}:map(function(arg) return ' <' .. arg:color(highlight_color) .. '>' end):concat()
        local first = command:sub(1, 1)
        local rest = command:sub(2)
        return ('    (%s)%s%s: %s'):format(first:color(highlight_color), rest:color(highlight_color), sub, line)
    end

    help_text:append('Available commands:')
    help_text:append(make_line('Lists all currently saved URLs', 'list'))
    help_text:append(make_line('Opens the URL with the provided ID', 'open', 'id'))
    help_text:append(make_line('Copies the URLs with the provided ID to the clipboard', 'copy', 'id'))
end

local pattern = L{
    -- Matches mail addresses
    '[\\w.-]+@[\\w.%-]+\\.[a-z]{2,5}\\b',
    -- Matches domain names preceded by a scheme
    '\\w+://[\\w%-]+(?:\\.[\\w%-]+)*\\.\\w{2,5}(?::\\d{1,5}\\b)?(?:/[^\\s]*)?',
    -- Matches IPv4, optionally preceded by a scheme
    '(?:\\w+://)?\\d{1,3}(?:\\.\\d{1,3}){3}(?::\\d{1,5}\\b)?(?:/[^\\s]*)?',
    -- Matches domain names without scheme. Only a few select TLDs allowed to avoid false positives
    '[\\w%-]+(?:\\.[\\w%-]+)*\\.(?:com|net|org|jp|uk|de|fr|it|es|ru|be|io)(?::\\d{1,5}\\b)?(?:/[^\\s]*)?',
}:concat('|')

local replace = function(url)
    if not ids[url] then
        urls:append(url)
        ids[url] = #urls
    end

    return ('[%u]%s'):format(ids[url], url)
end

windower.register_event('incoming text', function(original, text)
    local blocked = block:first()
    if blocked and original:contains(blocked) then
        block:remove(1)
        return
    end
    return windower.regex.replace(text, pattern, replace) or nil
end)

windower.register_event('addon command', function(command, id)
    command = command and command:lower() or 'help'

    if command == 'list' or command == 'l' then
        if urls:empty() then
            return log('No URLs found.')
        end

        log(('URLs found: %s'):format(#urls))
        for url, key in urls:it() do
            local text = ('    [%u]: %s'):format(key, url)
            block:append(text)
            log(text)
        end

    elseif id ~= nil then
        local key = tonumber(id)
        if not key then
            error(('The ID "%s" is not a number.'):format(id))
            return
        end

        if not urls[key] then
            error(('The ID "%s" was not found. Currently the highest ID is %u: %s'):format(#urls, urls[#urls]))
            return
        end

        if command == 'open' or command == 'o' then
            windower.open_url(urls[key])

        elseif command == 'copy' or command == 'c' then
            windower.copy_to_clipboard(urls[key])

        end

    else
        for line in help_text:it() do
            log(line)
        end

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

_addon.name = 'ChatLink'
_addon.author = 'Aureus'
_addon.version = '1.0.0.0'
_addon.commands = {'chatlink', 'clink'}

require('lists')
require('logger')

urls = L{}
ids = {}

windower.register_event('incoming text', function(_, text)
    return (text:gsub('', function(url)
        if not ids[url] then
            urls:append(url)
            ids[url] = #urls
        end

        return '[%u]%s':format(ids[url], url)
    end))
end)

windower.register_event('addon command', function(command, id)
    command = command and command:lower() or 'help'

    if command == 'open' or command == 'o' then
        local key = tonumber(id)
        if not key then
            return error('The ID "%s" is not a number.':format(id))
        end

        if not urls[key] then
            return error('The ID "%s" was not found. Currently the highest ID is %u: %s':format(#urls, urls[#urls]))
        end

        windower.open_url(urls[key])

    elseif command == 'list' or command == 'l' then
        if urls:empty() then
            log('No URLs found.')
            return
        end

        log('%u URLs found.':format(#urls))
        for url, key in urls:it() do
            log('    %u: %s':format(key, url))
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

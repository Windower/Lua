--[[
Copyright © 2024, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of chatmon nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

if not windower.file_exists(windower.windower_path .. 'plugins\\ChatMon.dll') then
    return false
end

local function read_all_lines(file_name)
    local f = assert(io.open(file_name, 'r'))
    local text = f:read('*all')
    f:close()
    return text
end

local file = windower.windower_path .. 'plugins\\ChatMon.xml'
local text = read_all_lines(file)

if text == '' then
    return nil
end

require('strings')
require('lists')

local quote = function(token)
    return '\'' .. token .. '\''
end

local function format_set(values)
    if values == nil or values:length() == 0 then
        return 'S{}'
    end

    return 'S{ ' .. values:map(quote):concat(', ') .. ' }'
end

local sounds = {
    ['tell'] = 'IncomingTell.wav',
    ['talk'] = 'IncomingTalk.wav',
    ['emote'] = 'IncomingEmote.wav',
    ['invite'] = 'PartyInvitation.wav',
    ['examine'] = 'IncomingExamine.wav',
}

local function format_trigger(from, not_from, match, not_match, sound)
    return '{ ' .. L{
        'from = ' .. format_set(from),
        'notFrom = ' .. format_set(not_from),
        'match = ' .. quote(match or '*'),
        'notMatch = ' .. quote(not_match or ''),
        'sound = ' .. quote(sound),
    }:concat(', ') .. ' }'
end

local entities = {
    amp = '&',
    lt = '<',
    gt = '>',
    apos = '\\\'',
    quot = '"',
}

local converted = text
    :gsub('.*<ChatMon>', 'return {')
    :gsub('(=".-")', '%1,')
    :gsub('<settings', 'settings = {')
    :gsub('<%!%-%-.-%-%->%s*', '')
    :gsub('<trigger', '{')
    :gsub('</ChatMon>', '}')
    :gsub('/?>', '},')
    :gsub('&(%w+);', entities)
    :gsub('\\', '\\\\\\\\')

local chatmon_plugin_xml = loadstring(converted)()

local defaults = L{
    { name='tell' },
    { name='emote' },
    { name='invite', sound='invite' },
    { name='examine' },
    { name='talk', from=L{'say', 'shout', 'party', 'linkshell', 'linkshell2'}, match='<name>' },
}

local triggers = L{}

for data in defaults:it() do
    local name = data.name:ucfirst()
    local comment = chatmon_plugin_xml.settings[name .. 'Sound']:lower() == 'none'
    triggers:append((comment and '-- ' or '') .. format_trigger(data.from, data.not_from, data.match, data.not_match, sounds[data.sound or data.name]))
end

local function parse_from(from)
    local matches = L{}

    for match in string.gmatch((from or ''):lower(), '[^|/\\,%s]+') do
        matches:append(match)
    end

    return matches
end

for _, trigger in ipairs(chatmon_plugin_xml) do
    local sound = trigger.sound and (sounds[trigger.sound:lower()] or trigger.sound) or 'IncomingTalk.wav'
    triggers:append(format_trigger(parse_from(trigger.from), parse_from(trigger.not_from), trigger.match, trigger.not_match, sound))
end

local trigger_text = 'return {\n' .. triggers:map(function(line) return '    ' .. line .. ',\n' end):concat() .. '}\n'

local global = assert(io.open(windower.addon_path .. '/data/triggers/global.lua', 'w'))
global:write(trigger_text)
global:close()

local settings = {}
settings.DisableOnFocus = false
settings.SoundInterval = tonumber(chatmon_plugin_xml.settings.SoundInterval)

coroutine.schedule(function()
    windower.create_dir(windower.windower_path .. 'plugins\\deprecated')
    os.rename(windower.windower_path .. 'plugins\\ChatMon.xml', windower.windower_path .. 'plugins\\deprecated\\ChatMon.xml')
    os.rename(windower.windower_path .. 'plugins\\ChatMon.dll', windower.windower_path .. 'plugins\\deprecated\\ChatMon.dll')
end, 0)

return settings

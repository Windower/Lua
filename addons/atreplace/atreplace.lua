--Copyright © 2024, Lili
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of atreplace nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL Lili BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'atreplace'
_addon.author = 'Lili'
_addon.version = '1.4.4'
_addon.commands = { 'atreplace', 'at' }

local res = require('resources')
require('pack')
require('logger')

local validterms = { auto_translates = S{}, items = S{}, key_items = S{} }
local cache = {}
local lang = windower.ffxi.get_info().language:lower()

at_term = function(str)
    local term = str:lower()

    if cache[term] then
        return cache[term]
    end

    local at
    local id = validterms.auto_translates[term] or validterms.items[term] or validterms.key_items[term] 

    if id then
        -- Arcon is the best
        local is_item = validterms.items[term] and true
        local high = (id / 0x100):floor() ~= 0
        local low = (id % 0x100) ~= 0
        local any_zero = not (high and low)
        local mask = validterms.auto_translates[term] and 2:char() or 'qqqqq':pack(
            low,
            high,
            not is_item == any_zero,
            is_item and any_zero,
            not is_item
        )

        at = 'CS1C>HC':pack(0xFD, mask, 2, id, 0xFD):gsub("%z", 0xFF:char())
    end

    cache[term] = at or str
    return cache[term]
end

windower.register_event('load',function()
    local keys = { 'english', 'english_log', 'japanese', 'japanese_log' }
    for category,_ in pairs(validterms) do
        for id, t in pairs(res[category]) do
            if not (category == 'auto_translates' and id % 0x100 == 0) then
                for _,key in pairs(keys) do
                    if t[key] then
                        validterms[category][t[key]:lower()] = id
                    end
                end
            end
        end
    end
end)

windower.register_event('outgoing text', function(org, mod, blk)
    if org == mod then
        return mod:gsub("_%((..-)%)", at_term)
    end
end)

windower.register_event('addon command', function(...)
    local args = T{...}
    local mode = args[1] and args[1]:lower() or 'help'
    
    if mode == 'r' or mode == 'reload' then
        windower.send_command('lua r '.._addon.name)
        return
        
    elseif mode == 'u' or mode == 'unload' then
        windower.send_command('lua u '.._addon.name)
        return
    
    elseif mode == 'search' or mode == 'find' then
        table.remove(args,1)
        local arg = args:concat(' ')
        local query = arg:gsub('%a', function(char) return string.format("([%s%s])", char:lower(), char:upper()) end)
        
        log("Search results for '%s'":format(arg:color(258)))
        for cat, t in pairs(validterms) do
            local r = ''
            for name,id in pairs(t) do
                if name:match(query) then
                    r = '%s %s,':format(r, res[cat][id][lang])
                end
            end
            if #r > 512 then
                local msg = '...\n' .. '(too many %s, try using a longer search string) ':format(cat):color(123)
                local pos = r:find(',', 512-#msg)
                r = r:sub(1, pos-1) .. msg
            end
            if #r > 1 then
                log('[' .. cat:upper() .. ']', r:sub(1,-2))
            end
        end
        
        return
    elseif mode == 'c' or mode == 'copy' then
        table.remove(args,1)
        local str = args:concat(' '):gsub("_%((..-)%)", at_term)
        windower.copy_to_clipboard(windower.from_shift_jis(str))
    
        return
    end
end)


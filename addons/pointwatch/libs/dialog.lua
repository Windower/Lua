--Copyright (c) 2014, Byrthnoth
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-- This library was written to help find the ID of a known
-- action message corresponding to an entry in the dialog tables.
-- While the IDs can be collected in-game, they occasionally
-- change and would otherwise need to be manually updated.
-- It can also be used to find and decode an entry given the ID.

-- Common parameters:
-- dat: The entire content of the zone dialog DAT file
-- i.e. local dat = io.open('path/to/dialog/DAT', 'rb'):read('*a')
-- entry: The string you are looking for. If you do not know the
-- entire string, use dev_find_substring.

local xor = require('bit').bxor
require('pack')
local string = require('string')
local unpack = string.unpack
local pack = string.pack
local find = string.find

local dialog = {}

local function decode(int)
    return xor(int, 0x80808080)
end
local encode = decode

local floor = require('math').floor
local function binary_search(pos, dat, n)
    local l, r, m = 1, n
    while l < r do
        m = floor((l+r)/2)
        if decode(unpack('<I', dat, 1+4*m)) < pos then
        -- offset given by mth ID < offset to string
            l = m + 1
        else
            r = m
        end
    end
    return l-2 -- we want the index to the left of where "pos" would be placed
end

local function plain_text_gmatch(text, substring, n)
    n = n or 1
    return function()
        local pos = find(text, substring, n, true)
        if pos then n = pos + 1 end
        return pos
    end
end

function dialog.dev_get_offset(dat, id) -- sanity check function
    return string.format('%x', decode(unpack('<I', dat, 5+4*id)))
end

-- Returns an array-like table containing every ID which matched
-- the given entry.
-- An important note about this function: The tables contain an
-- enormous number of duplicate entries. Additionally, some short
-- entries can occur as substrings of longer entries. Results
-- which fall into the second case should be filtered out.
-- If you are dealing with the first case, it may help to look at
-- any other messages which were received at the same time.
function dialog.get_ids_matching_entry(dat, entry)
    local last_offset = decode(unpack('<I', dat, 5))
    local res = {}
    local n = 0
    local start = 5
    for i in plain_text_gmatch(dat, entry, last_offset) do
        local encoded_pos = pack('<I', encode(i-5))
        local offset = find(dat, encoded_pos, start, true)
        if offset then
            offset = offset-1
            local next_pos
            if offset > last_offset then
                break
            elseif offset == last_offset then
                next_pos = #dat+1
            else
                next_pos = decode(unpack('<I', dat, offset+5))+5
            end

            if next_pos-i == #entry then
                n = n + 1
                res[n] = (offset-4)/4
            end
            start = offset+1
        end
    end
    res.n = n

    return res
end

-- This function is intended to be used only during development
-- to find the ID of a dialog entry given a substring.
-- This is necessary because SE uses certain bytes to indicate
-- things like placeholders or pauses and it is unlikely you
-- will know the entire content of the entry you're looking for
-- from the get-go.
-- Returns an array-like table which contains the ID of every entry
-- containing a given substring.
function dialog.dev_find_substring(dat, substring)
    local last_offset = decode(unpack('<I', dat, 5)) + 5
    local res = {}
    local pos = find(dat, dialog.encode_string(substring), last_offset, true)
    local n = 0
    for i in plain_text_gmatch(dat, substring, last_offset) do
        n = n + 1
        res[n] = i
    end
    if res.n == 0 then print('No results for ', substring) return end
    local entry_count = (last_offset-5)/4
    for i = 1, n do
        res[i] = binary_search(res[i]-1, dat, entry_count)
    end
    res.n = n

    return res
end

-- Returns the encoded entry from a given dialog table. If you
-- want to decode the entry, use dialog.decode_string.
function dialog.get_entry(dat, id)
    local entry_count = decode(unpack('<I', dat, 5))/4
    local offset, next_offset = unpack('<II', dat, 4*id+5)
    offset, next_offset = decode(offset)+5, decode(next_offset)+5
    if id == entry_count-1 then
        next_offset = #dat+1
    end

    return string.sub(dat, offset, next_offset-1)
end

-- Creates a serialized representation of a string which can
-- be copied and pasted into the contents of an addon.
function dialog.serialize(entry)
    return 'string.char('
        .. string.sub(string.gsub(entry, '.', function(c)
            return tostring(string.byte(c)) .. ','
        end), 1, -2)
        ..')'
end

function dialog.encode_string(s)
    return string.gsub(s, '.', function(c)
        return string.char(xor(string.byte(c), 0x80))
    end)
end

dialog.decode_string = dialog.encode_string

return dialog


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

local xor = require('bit').bxor
require('pack')
local unpack = require('string').unpack
local pack = require('string').pack
local find = require('string').find

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
    return l-2
    -- -1 since we want the index to the left of where "pos" would be placed
    -- another -1 to convert to 0-indexing
end

function dialog.dev_get_offset(dat, id) -- sanity check function
    return decode(unpack('<I', dat, 5+4*id))
end

-- The goal is generally to get the ID of some entry to the
-- dialog tables. The difficulty is that the IDs occasionally
-- change. However, if you have the full entry string, you can
-- work backwards to get the ID.
-- dat: The entire content of the zone dialog DAT file
-- entry: The string you are looking for. It would be best to
-- pass the entire string, but this will technically work as
-- long as you get the first character correct and include 
-- enough of the entry for the string to be unique.
-- If you do not know the entire string, use dev_find_substring.
function dialog.get_entry_id(dat, entry)
    local pos = find(dat, entry)
    if not pos then print('The given encoded text was not found within the file.') return end
    pos = pack('<I', encode(pos-5))
    local id = find(dat, pos)
    if not id then print('The position of the text does not match any of the defined offsets.', pos) return end

    return (id-5)/4
end

-- This function is intended to be used only during development
-- to find the ID of a dialog entry given a substring.
-- This is necessary because SE uses certain bytes to indicate
-- things like placeholders or pauses and it is unlikely you
-- will know the entire content of the entry you're looking for
-- from the get-go.
-- TODO it would be cool if you could pass a pattern
function dialog.dev_find_substring(dat, substring)
    local pos = find(dat, dialog.encode_string(substring))
    if not pos then print('No results for ', substring) return end

    return binary_search(pos-1, dat, decode(unpack('<I', dat, 5))/4)
end

-- Once you get the ID from dev_find_substring, you should get
-- the full entry.
function dialog.get_entry(dat, id)
    local entry_count = decode(unpack('<I', dat, 5))/4
    local offset, next_offset
    if id + 1 == entry_count then -- TODO I'm not sure this is a valid entry
        offset, next_offset = unpack('<I', dat, 4*id+5), #dat
        offset = decode(offset)+5
    else
        offset, next_offset = unpack('<II', dat, 4*id+5)
        offset, next_offset = decode(offset)+5, decode(next_offset)+4
    end
    return string.sub(dat, offset, next_offset)
end

-- Finally, you should serialize the entry so that you can
-- simply pass the full string to get_entry_id in the future.
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


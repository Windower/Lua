-- This library was written to help find the ID of a known
-- action message corresponding to an entry in the dialog tables.
-- While the IDs can be collected in-game, they occasionally
-- change and would otherwise need to be manually updated.
-- It can also be used to find and decode an entry given the ID.

-- Common parameters:
--
-- dat: Either the entire content of the zone dialog DAT file or
-- a file descriptor.
-- i.e. either local dat = io.open('path/to/dialog/DAT', 'rb')
-- or  dat = dat:read('*a')
-- The functions are expected to be faster when passed a string,
-- but will use less memory when receiving a file descriptor.
--
-- entry: The string you are looking for. Whether or not the string
-- is expected to be encoded should be indicated in the parameter's
-- name. If you do not know the entire string, use dev.find_substring
-- and serialize the result.

local xor = require('bit').bxor
local floor = require('math').floor
local string = require('string')
local find = string.find
local sub = string.sub
local gsub = string.gsub
local format = string.format
local char = string.char
local byte = string.byte
require('pack')
local unpack = string.unpack
local pack = string.pack

local function decode(int)
    return xor(int, 0x80808080)
end
local encode = decode

local function binary_search(pos, dat, n)
    local l, r, m = 1, n
    while l < r do
        m = floor((l + r) / 2)
        if decode(unpack(dat, '<I', 1 + 4 * m)) < pos then
        -- offset given by mth ID < offset to string
            l = m + 1
        else
            r = m
        end
    end
    return l - 2 -- we want the index to the left of where "pos" would be placed
end

local function plain_text_gmatch(text, substring, n)
    n = n or 1
    return function()
        local head, tail = find(text, substring, n, true)
        if head then n = head + 1 end
        return head, tail
    end
end

local dialog = {}

-- Returns the number of entries in the given dialog DAT file
function dialog.entry_count(dat)
    if type(dat) == 'userdata' then
        dat:seek('set', 4)
        return decode(unpack(dat:read(4), '<I')) / 4
    end
    return decode(unpack(dat, '<I', 5)) / 4
end

-- Returns an array-like table containing every ID which matched
-- the given entry. Note that the tables contain an enormous
-- number of duplicate entries.
function dialog.get_ids_matching_entry(dat, encoded_entry)
    local res = {}
    local n = 0
    if type(dat) == 'string' then
        local last_offset = decode(unpack(dat, '<I', 5))
        local start = 5
        for head, tail in plain_text_gmatch(dat, encoded_entry, last_offset) do
            local encoded_pos = encode(head - 5)
            if encoded_pos < 0 then
                encoded_pos = encoded_pos + 0x100000000
            end
            encoded_pos = pack('<I', encoded_pos)
            local offset = find(dat, encoded_pos, start, true)
            if offset then
                offset = offset - 1
                local next_pos
                if offset > last_offset then
                    break
                elseif offset == last_offset then
                    next_pos = #dat + 1
                else
                    next_pos = decode(unpack(dat, '<I', offset + 5)) + 5
                end

                if next_pos - head == tail - head + 1 then
                    n = n + 1
                    res[n] = (offset - 4) / 4
                end
                start = offset + 1
            end
        end

    elseif type(dat) == 'userdata' then
        dat:seek('set', 4)
        local offset = decode(unpack(dat:read(4), '<I'))
        local entry_count = offset / 4
        local entry_length = #encoded_entry
        for i = 1, entry_count - 1 do
            dat:seek('set', 4 * i + 4)
            local next_offset = decode(unpack(dat:read(4), '<I'))
            if next_offset - offset == entry_length then
                dat:seek('set', offset + 4)
                if dat:read(entry_length) == encoded_entry then
                    n = n + 1
                    res[n] = i - 1
                end
            end

            offset = next_offset
        end
        local m = dat:seek('end')
        if m - offset - 4 == entry_length then
            dat:seek('set', offset + 4)
            if dat:read(entry_length) == encoded_entry then
                n = n + 1
                res[n] = entry_count - 1
            end
        end
    end

    return res
end

-- Returns the encoded entry from a given dialog table. If you
-- want to decode the entry, use dialog.decode_string.
function dialog.get_entry(dat, id)
    local entry_count, offset, next_offset
    if type(dat) == 'string' then
        entry_count = decode(unpack(dat, '<I', 5)) / 4
        if id == entry_count - 1 then
            offset = decode(unpack(dat, '<I', 4 * id + 5)) + 5
            next_offset = #dat + 1
        else
            offset, next_offset = unpack(dat, '<II', 4 * id + 5)
            offset, next_offset = decode(offset) + 5, decode(next_offset) + 5
        end

        return sub(dat, offset, next_offset - 1)
    elseif type(dat) == 'userdata' then
        dat:seek('set', 4)
        entry_count = decode(unpack(dat:read(4), '<I')) / 4
        dat:seek('set', 4 * id + 4)
        if id == entry_count - 1 then
            offset = decode(unpack(dat:read(4), '<I'))
            next_offset = dat:seek('end') + 1
        else
            offset, next_offset = unpack(dat:read(8), '<II')
            offset, next_offset = decode(offset), decode(next_offset)
        end

        dat:seek('set', offset + 4)
        return dat:read(next_offset - offset)
    end
end

-- Creates a serialized representation of a string which can
-- be copied and pasted into the contents of an addon.
function dialog.serialize(entry)
    return 'string.char('
        .. sub(gsub(entry, '.', function(c)
            return tostring(string.byte(c)) .. ','
        end), 1, -2)
        ..')'
end

function dialog.encode_string(s)
    return gsub(s, '.', function(c)
        return char(xor(byte(c), 0x80))
    end)
end

dialog.decode_string = dialog.encode_string

-- If a zone has a dialog message dat file, this function will
-- return a file descriptor for it in "read/binary" mode.
function dialog.open_dat_by_zone_id(zone_id, language)
    local dat_id
    if zone_id > 299 then
        -- The English dialog files are currently 300 ids
        -- ahead of the Japanese dialog files. If a zone with
        -- id 300 or greater is added, SE will have to move to
        -- a new range of ids which someone will need to locate.
        print('Dialog library: zone id out of range.')
        return
    elseif zone_id > 255 then
        dat_id = zone_id + 85035
    else
        dat_id = zone_id + 6120
    end
    if language == 'english' then
        dat_id = dat_id + 300
    elseif language ~= 'japanese' then
        print(
            _addon and _addon.name or '???',
            'Dialog library: open_dat_by_zone_id expected '
            .. '"english" or "japanese". (Got: ' .. language .. ')'
        )
        return
    end

    local dat_path = windower.ffxi_path
    if not dat_path:endswith('\\') then
        dat_path = dat_path..'\\'
    end
    local path
    local vtable = dat_path .. 'VTABLE.DAT'
    local ftable = dat_path .. 'FTABLE.DAT'
    local n = 1
    local rom = dat_path .. 'ROM/'
    repeat
        local v = io.open(vtable, 'rb')
        v:seek('set', dat_id)
        if byte(v:read(1)) > 0 then
            local f = io.open(ftable, 'rb')
            local dat = f:read('*a')
            f:close()

            local offset = 2*dat_id+1
            local packed_16bit = byte(dat, offset + 1) * 256 + byte(dat, offset)
            local dir = floor(packed_16bit / 128)
            local file = packed_16bit - dir * 128
            
            path = rom .. tostring(dir) .. '/' .. tostring(file) .. '.DAT'
        end
        v:close()
        n = n + 1
        local d = tostring(n)
        rom = dat_path .. 'ROM' .. d .. '/'
        vtable = rom .. 'VTABLE' .. d .. '.DAT'
        ftable = rom .. 'FTABLE' .. d .. '.DAT'
    until path or not windower.dir_exists(rom)

    if path then
        return io.open(path, 'rb')
    end
end

dialog.dev = {}

-- Returns the hex offset of the dialog entry with the given ID.
-- May be useful if you are viewing the file in a hex editor.
function dialog.dev.get_offset(dat, id)
    local offset
    if type(dat) == 'string' then
        offset = unpack(dat, '<I', 5 + 4 * id)
    elseif type(dat) == 'userdata' then
        dat:seek('set', 4 * id  + 4)
        offset = unpack(dat:read(4), '<I')
    end
    return format('0x%08X', decode(offset))
end

-- This function is intended to be used only during development
-- to find the ID of a dialog entry given a substring.
-- This is necessary because SE uses certain bytes to indicate
-- things like placeholders or pauses and it is unlikely you
-- will know the entire content of the entry you're looking for
-- from the get-go.
-- Returns an array-like table which contains the ID of every entry
-- containing a given substring.
function dialog.dev.find_substring(dat, unencoded_string)
    local last_offset = decode(unpack(dat, '<I', 5)) + 5
    local res = {}
    -- local pos = find(dat, unencoded_string), last_offset, true)
    local n = 0
    for i in plain_text_gmatch(dat, dialog.encode_string(unencoded_string), last_offset) do
        n = n + 1
        res[n] = i
    end
    if n == 0 then print('No results for ', unencoded_string) return end
    local entry_count = (last_offset - 5) / 4
    for i = 1, n do
        res[i] = binary_search(res[i] - 1, dat, entry_count)
    end

    return res
end

return dialog


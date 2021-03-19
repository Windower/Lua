-- icon_extractor v1.0.1
-- Written by Rubenator of Leviathan
-- Base Code graciously provided by Trv of Windower discord
local icon_extractor = {}

local game_path = windower.pol_path.."\/..\/FINAL FANTASY XI"

local string = require 'string'
local io = require 'io'
local math = require 'math'

local concat = table.concat
local floor = math.floor
local byte = string.byte
local char = string.char
local sub = string.sub

local file_size = '\122\16\00\00'
local reserved1 = '\00\00'
local reserved2 = '\00\00'
local starting_address = '\122\00\00\00'

local default = '\00\00\00\00'

local dib_header_size = '\108\00\00\00'
local bitmap_width = '\32\00\00\00'
local bitmap_height = '\32\00\00\00'
local n_color_planes = '\01\00'
local bits_per_pixel = '\32\00'
local compression_type = '\03\00\00\00'
local image_size = '\00\16\00\00'
local h_resolution_target = default
local v_resolution_target = default
local default_n_colors = default
local important_colors = default
local alpha_mask = '\00\00\00\255'
local red_mask = '\00\00\255\00'
local green_mask = '\00\255\00\00'
local blue_mask = '\255\00\00\00'
local colorspace = 'sRGB'
local endpoints = string.rep('\00', 36)
local red_gamma = default
local green_gamma = default
local blue_gamma = default

local header = 'BM' .. file_size .. reserved1 .. reserved2 .. starting_address
        .. dib_header_size .. bitmap_width .. bitmap_height .. n_color_planes
        .. bits_per_pixel .. compression_type .. image_size
        .. h_resolution_target .. v_resolution_target
        .. default_n_colors .. important_colors
        .. red_mask .. green_mask .. blue_mask .. alpha_mask
        .. colorspace .. endpoints .. red_gamma .. green_gamma .. blue_gamma

--local icon_file = io.open('C:/Program Files (x86)/PlayOnline/SquareEnix/FINAL FANTASY XI/ROM/118/106.DAT', 'rb')
local color_lookup = {}
local bmp_segments = {}

for i = 0, 255 do
	color_lookup[string.char(i)] = ''
end

--[[
3072 bytes per icon
640 bytes for stats, string table, etc.
2432 bytes for pixel data
--]]

local item_dat_map = {
    [1]={min=1, max=4095, dat_path='118/106', offset=-1},
    [2]={min=4096, max=8191, dat_path='118/107', offset=0},
    [3]={min=8192, max=8703, dat_path='118/110', offset=0},
    [4]={min=8704, max=10239, dat_path='301/115', offset=0},
    [5]={min=10240, max=16383, dat_path='118/109', offset=0},
    [6]={min=16384, max=23039, dat_path='118/108', offset=0},
    [7]={min=23040, max=28671, dat_path='286/73', offset=0},
    [8]={min=28672, max=29695, dat_path='217/21', offset=0},
    [9]={min=29696, max=30719, dat_path='288/80', offset=0},
    [10]={min=61440, max=61951, dat_path='288/67', offset=0},
    [11]={min=65535, max=65535, dat_path='174/48', offset=0},
}

local item_by_id = function (id, output_path)
    local dat_stats = find_item_dat_map(id)
    local icon_file = open_dat(dat_stats)
    
    local id_offset = dat_stats.min + dat_stats.offset
    icon_file:seek('set', (id - id_offset) * 0xC00 + 0x2BD)
    local data = icon_file:read(2048)

    bmp = convert_item_icon_to_bmp(data)

    local f = io.open(output_path, 'wb')
    f:write(bmp)
    coroutine.yield()
    f:close()
end
icon_extractor.item_by_id = item_by_id

function find_item_dat_map(id)
    for _,stats in pairs(item_dat_map) do
        if id >= stats.min and id <= stats.max then
            return stats
        end
    end
    return nil
end

function open_dat(dat_stats)
    local icon_file = nil
    if dat_stats.file then
        icon_file = dat_stats.file
    else
        if not game_path then
            error("ffxi_path must be set before using icon_extractor library")
        end
        filename = game_path .. '/ROM/' .. tostring(dat_stats.dat_path) .. ".DAT"
        icon_file = io.open(filename, 'rb')
        if not icon_file then return end
        dat_stats.file = icon_file
    end
    return icon_file
end

-- 32 bit color palette-indexed bitmaps. Bits are rotated and must be decoded.
local encoded_to_decoded_char = {}
local encoded_byte_to_rgba = {}
local alpha_encoded_to_decoded_adjusted_char = {}
local decoded_byte_to_encoded_char = {}
for i = 0, 255 do
	encoded_byte_to_rgba[i] = ''
	local n = (i % 32) * 8 + floor(i / 32)
	encoded_to_decoded_char[char(i)] = char(n)
	decoded_byte_to_encoded_char[n] = char(i)
	n = n * 2
	n = n < 256 and n or 255
	alpha_encoded_to_decoded_adjusted_char[char(i)] = char(n)
end
local decoder = function(a, b, c, d)
	return encoded_to_decoded_char[a]..
		encoded_to_decoded_char[b]..
		encoded_to_decoded_char[c]..
		alpha_encoded_to_decoded_adjusted_char[d]
end
function convert_item_icon_to_bmp(data)
	local color_palette = string.gsub(sub(data, 1, 1024), '(.)(.)(.)(.)', decoder)
	-- rather than decoding all 2048 bytes, decode only the palette and index it by encoded byte
	for i = 0, 255 do
		local offset = i * 4 + 1
		encoded_byte_to_rgba[decoded_byte_to_encoded_char[i]] = sub(color_palette, offset, offset + 3)
	end

	return header .. string.gsub(sub(data, 1025, 2048), '(.)', function(a) return encoded_byte_to_rgba[a] end)
end


local buff_dat_map = {
    [1]={min=0, max=1024, dat_path='119/57', offset=0},
}
function find_buff_dat_map(id)
    for _,stats in pairs(buff_dat_map) do
        if id >= stats.min and id <= stats.max then
            return stats
        end
    end
    return nil
end
local buff_by_id = function (id, output_path)
    local dat_stats = find_buff_dat_map(id)
    local icon_file = open_dat(dat_stats)
    
    local id_offset = dat_stats.min + dat_stats.offset
    icon_file:seek('set', (id - id_offset) * 0x1800)
    local data = icon_file:read(0x1800)

    bmp = convert_buff_icon_to_bmp(data)

    local f = io.open(output_path, 'wb')
    f:write(bmp)
    coroutine.yield()
    f:close()
end
icon_extractor.buff_by_id = buff_by_id


local ffxi_path = function(location)
    game_path = location
end
icon_extractor.ffxi_path = ffxi_path


-- A mix of 32 bit color uncompressed and *color palette-indexed bitmaps
-- Offsets defined specifically for status icons
-- * some maps use this format as well, but at 512 x 512
function convert_buff_icon_to_bmp(data)
	local length = byte(data, 0x282) -- The length is technically sub(0x281, 0x284), but only 0x282 is unique

    if length == 16 then -- uncompressed
        data = sub(data, 0x2BE, 0x12BD)
        data = string.gsub(data, '(...)\128', '%1\255') -- All of the alpha bytes are currently 0 or 0x80.
    elseif length == 08 then -- color table
        local color_palette = sub(data, 0x2BE, 0x6BD)
        color_palette = string.gsub(color_palette, '(...)\128', '%1\255')
    
        local n = 0
        for i = 1, 1024, 4 do
            color_lookup[char(n)] = sub(color_palette, i, i + 3)
            n = n + 1
        end
    
        data = string.gsub(sub(data, 0x6BE, 0xABD), '(.)', function(i) return color_lookup[i] end)
    elseif length == 04 then -- XIVIEW
        data = sub(data, 0x2BE, 0x12BD)
    end
    
	return header .. data
end

windower.register_event('unload', function()
    for _,dat in pairs(item_dat_map) do
        if dat and dat.file then
            dat.file:close()
        end
    end
    for _,dat in pairs(buff_dat_map) do
        if dat and dat.file then
            dat.file:close()
        end
    end
end);

return icon_extractor

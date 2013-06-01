--[[
A few functions that add an interface for color editing.
]]

_libs = _libs or {}
_libs.chat = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.sets = _libs.sets or require 'sets'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'
local json = require 'json'
_libs.json = _libs.json or (json ~= nil)
_libs.logger = _libs.logger or require 'logger'

local res, err = json.read('../libs/ffxidata.json')
if err then
	error(err)
end
local chat = (ffxi and ffxi.data and ffxi.data.chat) or json.read('../libs/ffxidata.json').chat
local colors = chat.colors
local color_controls = chat.colorcontrols

--[[
	Local functions.
]]

local make_color

-- Returns a color from a given input.
function make_color(col)
	if type(col) == 'number' then
		if col <= 0x000 or col == 0x100 or col == 0x101 or col > 0x1FF then
			warning('Invalid color number '..col..'. Only numbers between 1 and 511 permitted, except 256 and 257.')
			col = ''
		elseif col <= 0xFF then
			col = color_controls[1]..string.char(col)
		else
			col = color_controls[2]..string.char(col - 256)
		end
	else
		if #col > 2 then
			local cl = col
			col = colors[col]
			if col == nil then
				warning('Color \''..cl..'\' not found.')
				col = ''
			end
		end
	end
	
	return col
end

local invalids = S{0, 256, 257}

-- Returns str colored as specified by newcolor. If oldcolor is omitted, the string color will reset.
function string.color(str, new_color, reset_color)
	if new_color == nil or invalids:contains(new_color) then
		return str
	end

	reset_color = reset_color or color_controls.reset

	new_color = make_color(new_color)
	reset_color = make_color(reset_color)

	return str:enclose(new_color, reset_color)
end

-- Strips a string of all colors.
function string.strip_colors(str)
	return (str:gsub('[\x1E\x1F].', ''))
end

-- Strips a string of auto-translate tags.
function string.strip_auto_translate(str)
	return (str:gsub('\xEF[\x27\x28]', ''))
end

-- Strips a string of all colors and auto-translate tags.
function string.strip_format(str)
	return (str:gsub('[\x1E\x1F\x7F].', ''):gsub('\xEF[\x27\x28]', ''))
end

--[[
	The following functions are for text object strings, since they behave differently than chatlog strings.
]]

-- Returns str colored as specified by (new_alpha, new_red, ...). If reset values are omitted, the string color will reset.
function string.text_color(str, new_red, new_green, new_blue, reset_red, reset_green, reset_blue)
	if str == '' then
		return str
	end

	if reset_blue then
		return '\\cs('..new_red..', '..new_green..', '..new_blue..')'..str..'\\cs('..reset_red..', '..reset_green..', '..reset_blue..')'
	end
	
	return '\\cs('..new_red..', '..new_green..', '..new_blue..')'..str..'\\cr'
end

-- Returns a color string in console format.
function chat.make_text_color(red, green, blue)
	return '\\cs('..red..', '..green..', '..blue..')'
end

-- Returns a string stripped of console formatting information.
function string.text_strip_format(str)
	return (str:gsub('\\cs%(%s*%d+,%s*%d+,%s*%d+%s*%)(.-)', ''):gsub('\\cr', ''))
end

chat.text_color_reset = '\\cr'

return chat

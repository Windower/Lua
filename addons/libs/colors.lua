--[[
A few functions that add an interface for color editing.
]]

_libs = _libs or {}
_libs.colors = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'
local json = require 'json'
_libs.json = _libs.json or (json ~= nil)
_libs.logger = _libs.logger or require 'logger'

local chat = ((ffxi and ffxi.data and ffxi.data.chat) or json.read('../libs/ffxidata.json')).chat
local colors = chat.colors
local colorcontrols = chat.colorcontrols

--[[
	Local functions.
]]

local make_color

-- Returns a color from a given input.
function make_color(col)
	if type(col) == 'number' then
		if col < 0 or col >= 512 then
			warning('Invalid color number '..col..'. Only numbers between 0 and 512 permitted.')
			col = ''
		elseif col < 256 then
			col = colorcontrols[1]..string.char(col)
		else
			col = colorcontrols[2]..string.char(col % 256)
		end
	else
		if col:length() > 2 then
			local cl = col
			col = colors[col]
			if col == 'nil' then
				warning('Color \''..cl..'\' not found.')
				col = ''
			end
		end
	end
	
	return col
end

-- Returns str colored as specified by newcolor. If oldcolor is omitted, the string will stay in newcolor.
function string.color(str, newcolor, resetcolor)
	if newcolor == nil then
		return str
	end
	
	resetcolor = resetcolor or colorcontrols['reset']
	
	newcolor = make_color(newcolor)
	resetcolor = make_color(resetcolor)
	
	return str:enclose(newcolor, resetcolor)
end

-- Strips a string of all colors.
function string.stripcolors(str)
	return (str:gsub('[\x1E\x1F].', ''))
end

-- Strips a string of auto-translate tags.
function string.stripautotrans(str)
	return (str:gsub('\xEF[\x27\x28]', ''))
end

-- Strips a string of all colors and auto-translate tags.
function string.stripformat(str)
	return (str:gsub('[\x1E\x1F\x7F].', ''):gsub('\xEF[\x27\x28]', ''))
end

return chat
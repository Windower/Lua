--[[
A few functions that add an interface for color editing.
]]

_libs = _libs or {}
_libs.colors = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'
_libs.jsonreader = _libs.jsonreader or require 'jsonreader'
_libs.logger = _libs.logger or require 'logger'

ffxidata = ffxidata or jsonreader.read('ffxidata.json')

-- Returns str colored as specified by newcolor. If oldcolor is omitted, the string will stay in newcolor.
function string.setcolor(str, newcolor, oldcolor)
	if type(newcolor) == 'string' then
		newcolor = ffxidata.chatcolors[newcolor]
		if newcolor == nil then
			warning('Color "'..newcolor..'" not found.')
			return str
		end
	end
	
	if oldcolor == nil then
		return string.char(31, newcolor)..str
	end
	return string.char(31, newcolor)..str..string.char(31, oldcolor)
end

-- Returns the given string with all color codes stripped from it.
function string.strip_color(str)
	--[[ Specifically, we target the following:
	     - \x1F\x?? : colors in add_to_chat
	     - \x1E\x?? : game color highlights (including the color reset, \x1E\x01)
	--]]
	local chars = T{}
	local color_next = false -- true if we find a color indicator character
	
	for i=1, #str do
		local c = str:sub(i, i)
		
		if color_next then
			-- skip the current character
			color_next = false
		else
			if c:byte(1) == 0x1E then
				color_next = true
			elseif c:byte(1) == 0x1F then
				color_next = true
			else
				chars:append(c)
			end
		end
	end
	
	return table.concat(chars, '')
end

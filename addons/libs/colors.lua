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

-- Returns the given string with all color codes removed from it.
function string.trim_color(str)
	--[[ Specifically, we target the following:
	     - \x1F\x?? : colors in add_to_chat
	     - \x1E\x01 : color reset
	--]]
	local chars = T{}
	local color_next = false -- true if we find a color indicator character
	local prev_char = nil
	
	for i=1, #str do
		local c = str:sub(i, i)
		
		if color_next then
			if prev_char:byte(1) == 0x1E and c:byte(1) ~= 0x01 then
				-- Allow for all \x1E\x?? numbers except \x1E\x01 explicitly
				chars:append(c)
			end			
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
		
		prev_char = c
	end
	
	return table.concat(chars, '')
end

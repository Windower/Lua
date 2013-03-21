--[[
A few functions to interface ingame structures and values.
]]

_libs = _libs or {}
_libs.ffxi = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'
_libs.jsonreader = _libs.jsonreader or require 'jsonreader'

ffxidata = ffxidata or jsonreader.read('ffxidata.json')

-- Returns ingame time from server time.
-- TODO: Waiting on server-time interface function.
function get_time(time)
	return 4
end

-- Returns the game time from the float-representation.
function format_time(time)
	time = tostring(math.round(time, 2)):split('.'):print()
	local hours = time[1]:zfill(2)
	local minutes = time[2]:zfill(2)
	return hours..':'..minutes
end

-- Returns the element of the storm effect currently on the player. If none present, returns nil.
function get_storm()
	for storm, element in pairs(ffxi.elements.storms) do
		if T(get_player()['buffs']):contains(storm) then
			return element
		end
	end
	
	return nil
end
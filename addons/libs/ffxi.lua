--[[
A few functions to interface ingame structures and values.
]]

_libs = _libs or {}
_libs.ffxi = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'
_libs.functools = _libs.functools or require 'functools'
local json = require 'json'
_libs.json = _libs.json or (json ~= nil)

local ffxi = T{}
ffxi.data = json.read('../libs/ffxidata.json')

-- Returns ingame time from server time.
-- TODO: Waiting on server-time interface function.
function ffxi.get_time(time)
	return 4
end

-- Returns the game time from the float-representation.
function ffxi.format_time(time)
	time = tostring(math.round(time, 2)):split('.')
	local hours = time[1]:zfill(2)
	local minutes = time[2]:zfill(2)
	return hours..':'..minutes
end

-- Returns the element of the storm effect currently on the player. If none present, returns nil.
function ffxi.get_storm()
	for storm, element in pairs(ffxi.data.elements.storms) do
		if T(get_player()['buffs']):contains(storm) then
			return element
		end
	end

	return nil
end

-- Prints a list of icons and their keys to the chatlog.
function ffxi.showicons()
	for key, val in pairs(ffxi.data.chat.icons) do
		log('Icon', 'ffxi.data.chat.icons.'..key..':', val)
	end
end

-- Prints a list of chars and their keys to the chatlog.
function ffxi.showchars()
	for key, val in pairs(ffxi.data.chat.chars) do
		log('Icon', 'ffxi.data.chat.chars.'..key..':', val)
	end
end

-- Prints the game colors and their IDs.
function ffxi.showcolors()
	for key, val in pairs(ffxi.data.chat.colors) do
		log('Color', 'ffxi.data.chat.colors.'..key..':', ('Color sample text.'):color(val))
	end
end

-- Returns the target's id.
function ffxi.target_id(default)
	return get_mob_by_index(get_player()['target_index'])['id'] or default
end

-- Returns the target's name.
function ffxi.target_name(default)
	return get_mob_by_index(get_player()['target_index'])['name'] or default
end

-- Returns a name based on an id.
function ffxi.id_to_name(id)
	return get_mob_by_id(id)['name']
end

-- Returns a name based on an index.
function ffxi.index_to_name(index)
	return get_mob_by_index(index)['name']
end

return ffxi


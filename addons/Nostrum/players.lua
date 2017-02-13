--[[
    A short class for creating new player tables. Expects
    to be passed the entity table for the new player.
--]]

local players = {}
_meta = _meta or {}
_meta.players = _meta.players or {__index = players}

function players.new()
    local t = {
		hp = 0,
		mp = 0,
		tp = 0,
		id = 0,
		hpp = 0,
		mpp = 0,
		pos = {x = 0, y = 0},
		spot = 0,
		name = '???',
		zone = 0,
		index = 0,
		party = 0,
		buffs = {n = 0},
		is_trust = false,
		out_of_zone = true,
		out_of_sight = true,
		seeking_information = true,
    }
	
	return setmetatable(t, _meta.players)
end

function players.change_zone(t, zone_id)
	t.out_of_zone = zone_id == 0
	t.zone = zone_id
end

function players.copy(t)
	-- to do
end

return players
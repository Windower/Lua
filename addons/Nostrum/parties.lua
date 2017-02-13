--[[
    A short class for maintaining accurate party lists.
--]]

local parties = {}
local meta = {}
_meta = _meta or {}
_meta.parties = {__index = parties}

function parties.new()
	local t = {nil, nil, nil, nil, nil, nil}
	local m = {}
	meta[t] = m

	m.n = 0
	
    return setmetatable(t, _meta.parties)
end

function parties.form_alliance(...)
    local t = {...}
    local alliance = {}
    
    for i = 1, #t do
        local party = t[i]
        for j = 1, 6 do
            alliance[6 * (i - 1) + j] = party[j]
        end
    end
    
    return alliance
end

function parties.kick(t, id)
	local i = 1
	local position
	local m = meta[t]
	local n = m.n
	
	repeat
		position = t[i] == id and i or nil
		i = i + 1
	until position or i > n
	
	if position then
		table.remove(t, position)
		t[6] = nil
		m.n = n - 1
		
		return position
	else
		return false
	end
end

function parties.invite(t, id)
    local m = meta[t]
	local n = m.n + 1
	
	m.n = n
    t[n] = id
	
	return n
end

function parties.carbon_copy(t)
	local m = meta[t]
	local cc = {}
	
	for i = 1, m.n do
		cc[i] = t[i]
	end
	
	cc.n = m.n
	
	return cc
end

function parties.count(t)
	return meta[t].n
end

function parties.dissolve(t)
	--meta[t] = nil
	for i = 1, meta[t].n do
		t[i] = nil
	end
	
	meta[t].n = 0
end

return parties
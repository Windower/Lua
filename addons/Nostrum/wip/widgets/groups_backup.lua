local groups = {}
local meta = {}

_libs = _libs or {}
_libs.groups = groups

_meta = _meta or {}
_meta.groups = _meta.groups or {}
_meta.groups.__class = 'Group'
_meta.groups.__index = groups

function groups.new(t)
	t = t or {}
	
	local m = {}
	meta[t] = m
	
	m.members = {n=0}
	m.offsets = {}
	
	for i = 1, #t do
		groups.add(t, t[i])
	end
	
	return setmetatable(t, _meta.groups)
end

function groups.pos(t, x, y)
	local m = meta[t]
	local members = m.members
	
	for i = 1,members.n do
		local object = members[i]
		local x_off, y_off = object:pos()
		
		object:pos(x + x - x_off, y + y - y_off)
	end
end

function groups.add(t, object)
	local m = meta[t]
	
	local x, y = object:pos()
	
	m.offsets[object] = {x=x, y=y}
	
	local n = members.n + 1
	
	members[n] = object
	members.n = n
	
	object._group = t
end

function groups.visible(t, bool)
	if bool == nil then
		return meta[t].visible
	end
	
	local m = meta[t]
	
	m.visible = bool
	
	local members = m.members
	for i = 1, members.n do
		members[i]:visible(bool)
	end
end

function groups.hide(t)
	local members = meta[t].members
	for i = 1, members.n do
		members[i]:visible(false)
	end
end

function groups.show(t)
	local members = meta[t].members
	for i = 1, members.n do
		members[i]:visible(true)
	end
end

function groups.detach(t, object)
	-- Remove the _group key from the object so that the widgets library
	-- won't drag the entire group if the object is grabbed.
	-- The object remains in the group.

	object._group = object._group == meta[t].id and nil or object._group
end

return groups
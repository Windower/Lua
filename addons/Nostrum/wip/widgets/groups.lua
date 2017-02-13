local groups = {}
local meta = {}

_libs = _libs or {}
_libs.groups = groups

_meta = _meta or {}
_meta.groups = _meta.groups or {}
_meta.groups.__index = groups

function groups.new(x, y, w, h)
	
	local t = {}
	local m = {}
	
	meta[t] = m
	
	m.offsets = {}
	m.events = {}
	m.visible = true -- ?
	m.x1, m.y1, m.w, m.h = x, y, w, h
	m.x2, m.y2 = x + w, y + h
	
	t._subwidgets = {n = 0}
	t.n = 0
	
	if _libs.widgets then
		groups.register_event(t, 'drop', function()
			local subwidgets = t._subwidgets
			local x, y = groups.pos(t)
			
			for i = 1, subwidgets.n do
				local object = subwidgets[i]
				if widgets.tracking(object) then
					local offsets = m.offsets[object]
					local _x, _y = x + offsets.x, y + offsets.y
					widgets.update_object(object, _x, _x + object:width(), _y, _y + object:height())
				end
			end
		end)
	end
	
	
	--[[for i = 1, #args do
		groups.add(t, t[i])
	end--]]
	
	return setmetatable(t, _meta.groups)
end

function groups.destroy(t)
	meta[t] = nil
end

function groups.hover(t, x, y)
	local m = meta[t]
	return m.x1 <= x
		and m.x2 >= x
		and m.y1 <= y
		and m.y2 >= y
end

function groups.pos(t, x, y)
	local m = meta[t]
	
	if not y then return m.x1, m.y1 end
	
	if t.handle then
		t.handle:pos(x, y)
		y = y + 30
	end
	
	local members = t._subwidgets
	
	for i = 1,members.n do
		local object = members[i]
		local offsets = m.offsets[object]
		--probably where the multiple pos calls are coming from
		object:pos(x + offsets.x, y + offsets.y)
	end
	
	m.x1, m.y1 = x, y
	m.x2, m.y2 = x + m.w, y + m.h
end

function groups.pos_x(t, x)
	if not x then return meta[t].x1 end
	
	local m = meta[t]
	
	if t.handle then
		t.handle:pos_x(x)
	end

	local members = t._subwidgets
	
	for i = 1,members.n do
		local object = members[i]
		local offsets = m.offsets[object]
		
		object:pos_x(x + offsets.x)
	end
	
	m.x1 = x
	m.x2 = x + m.w
end

function groups.pos_y(t, y)
	if not y then return meta[t].y1 end
	
	local m = meta[t]
	
	if t.handle then
		t.handle:pos_y(y)
		y = y + 30
	end

	local members = t._subwidgets
	
	for i = 1,members.n do
		local object = members[i]
		local offsets = m.offsets[object]
		
		object:pos_y(y + offsets.y)
	end
	
	m.y1 = y
	m.y2 = y + m.h
end

function groups.add(t, object)
	local m = meta[t]
	
	local x, y = object:pos()
	x, y = x - m.x1, y - m.y1
	
	m.offsets[object] = {x=x, y=y}
	
	local members = t._subwidgets
	local n = members.n + 1
	
	members[n] = object
	members.n = n
	
	object._group = t
end

function groups.contains(t, object)
	return meta[t].offsets[object] and true or false
end

function groups.visible(t, bool)
	if bool == nil then
		return meta[t].visible
	end
	
	local m = meta[t]
	
	m.visible = bool
	
	local members = t._subwidgets
	for i = 1, members.n do
		members[i]:visible(bool)
	end
end

function groups.width(t, w)
	if not w then return meta[t].w end
	
	meta[t].w = w
end

function groups.height(t, h)
	if not h then return meta[t].h end
	
	meta[t].h = h
end

function groups.hide(t)
	meta[t].visible = false
	local members = t._subwidgets
	
	for i = 1, members.n do
		members[i]:visible(false)
	end
end

function groups.show(t)
	meta[t].visible = false
	local members = t._subwidgets
	
	for i = 1, members.n do
		members[i]:visible(true)
	end
end

function groups.detach(t, object)
	-- Remove the _group key from the object so that the widgets library
	-- won't drag the entire group if the object is grabbed.
	-- The object remains in the group.

	object._group = object._group == t and nil or object._group
end

function groups.events(t, event)
	local function_list = meta[t].events[event]
	if not function_list then return nil end
	
	local n = 0
	local m = function_list.n
	
	return function()
		n = n + 1
		local fn = function_list[n]
		
		-- handle holes in the list
		while not fn and n <= m do
			n = n + 1
			fn = function_list[n]
		end

		return fn
	end
end

function groups.register_event(t, event, fn)
    local m = meta[t].events

    m[event] = m[event] or {n = 0}
    local n
    for i = 1, m[event].n do
        if not m[event][i] then
            n = i
            break
        end
    end
    if not n then
        n = m[event].n + 1
        m[event].n = n
    end
    m[event][n] = fn

    return n
end
 
function groups.unregister_event(t, event, n)
    if not (events[event] and meta[t].events[event]) then
        return
    end

    if type(n) == 'number' then
        meta[t].events[event][n] = nil
    else
        for i = 1, meta[t].events[event].n do
            if meta[t].events[event][i] == n then
                meta[t].events[event][i] = nil
                return
            end
        end
    end
end

return groups
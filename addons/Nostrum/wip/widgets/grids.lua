local grids = {}
local meta = {}
local groups = _libs.groups or require 'widgets/groups'

_libs = _libs or {}
_libs.grids = grids

_meta = _meta or {}
_meta.grids = _meta.grids or {}
_meta.grids.__index = function(t, k) return grids[k] or groups[k] end

local function call_events(object, event, ...)
	local it = object:events(event)
	local block_event = false
	
	if it then
		for fn in it do
			block_event = fn(...)
			
			if block_event then break end
		end
	end
	
	return block_event
end

function grids.new(x, y, cell_width, cell_height, rows, columns)
	
	local t = groups.new(x, y, columns*cell_width, rows*cell_height)
	local m = {}
	
	meta[t] = m
	
	m.events = {}
	m.r = rows
	m.c = columns
	m.w = cell_width
	m.h = cell_height
	
	for i = 1, rows do
		t[i] = {}
		for j = 1, columns do
			t[i][j] = {}
		end
	end

	
	if _libs.widgets then
		grids.register_event(t, 'drop', function()
			local subwidgets = t._subwidgets
			local x, y = grids.pos(t)
			
			for i = 1, subwidgets.n do
				local object = subwidgets[i]
				if widgets.tracking(object) then
					local offsets = m.offsets[object]
					local _x, _y = x + offsets.x, y + offsets.y
					widgets.update_object(object, _x, _x + object:width(), _y, _y + object:height())
				end
			end
		end)
		
		local events_with_x_y_data = {
			--'move', -- need to spoof focus change 			['focus change'] = true,
			'left click',
			'right click',	
			'middle click',
			'x button click',
			'left button down',
			'right button down',
			'left button up',
			'right button up',
			'middle button down',
			'middle button up',
			'scroll',
			'x button down',
			'x button up',
		}

		local function locate_object_in_contents(x, y)
			local pos_x, pos_y = groups.pos(t)
			local w, h = groups.width(t), groups.height(t)
			
			local r = math.ceil((y - pos_y)/m.h)
			local c = math.ceil((x - pos_x)/m.w)
			
			local object = t[r][c]
			
			return object:visible() and object:hover(x, y) and object
		end
		
		local function redirect_events(x, y, ...)
			local object = locate_object_in_contents(x, y)
			
			if object then
				return call_events(object, ...)
			end
		end
		
		local function move(x, y)
			local object = locate_object_in_contents(x, y)
			
			if object then
				if object._can_take_focus and object ~= widgets.get_object_with_focus() then
					widgets.assign_focus(object)
					call_events(object, 'focus change', true)
				end
				
				return call_events(object, 'move', x, y)
			end
		end		
		
		for i = 1, #events_with_x_y_data do
			grids.register_event(t, events_with_x_y_data[i], redirect_events)
		end
		
		grids.register_event(t, 'move', move)

	end
	
	return setmetatable(t, _meta.grids)
end

function grids.destroy(t)
	meta[t] = nil
end

function grids.new_row(t)
	local m = meta[t]
	local n = m.r + 1 --#t + 1
	local row = {}

	m.r = n	

	-- adjust group height
	groups.height(t, n * m.h)
	
	-- add a new row
	for i = 1, m.c do
		row[i] = {}
	end
	
	t[n] = row
end

function grids.new_column(t)
	local m = meta[t]
	local c = m.c + 1
	
	m.c = c
	
	-- adjust the group width	
	groups.width(t, c * m.w)
	
	-- add a new column to each row
	for i = 1, m.r do
		t[i][c] = {}
	end
	
end

function grids.events(t, event)
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

function grids.register_event(t, event, fn)
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
 
function grids.unregister_event(t, event, n)
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

return grids
--[[Copyright © 2014-2017, trv
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Nostrum nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL trv BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER I N CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.--]]

local widgets = {}

_libs = _libs or {}
_libs.widgets = widgets

local quadtree = require 'quadtree'
_libs.quadtrees = quadtree

prims = _libs.prims or require 'widgets/prims'
texts = _libs.texts or require 'texts'
groups = _libs.groups or require 'widgets/groups'
buttons = _libs.buttons or require 'widgets/buttons'
sliders = _libs.slider or require 'widgets/slider'
scroll_text = _libs.scrolling_text or require 'widgets/scroll_text'
scroll_menu = _libs.scrolling_text_menu or require 'widgets/scroll_menu'
windows = _libs.windows or require 'widgets/windows'
simple_buttons = _libs.simple_buttons or require 'widgets/simple_button'
grids = _libs.grids or require 'widgets/grids'

local click_types = {
	[0]='move',
	'left button down',
    'left button up',
    nil,
    'right button down',
    'right button up',
    'middle button down',
    'middle button up',
    nil,
    nil,
    'scroll',
    'x button down',
    'x button up',
}

local events = {
	['drag'] = true,
	['move'] = true,
	['left click'] = true,
	['right click'] = true,	
	['middle click'] = true,
	['x button click'] = true,
	['focus change'] = true,
	['left button down'] = true,
    ['right button down'] = true,
    ['left button up'] = true,
    ['right button up'] = true,
    ['middle button down'] = true,
    ['middle button up'] = true,
    ['scroll'] = true,
    ['x button down'] = true,
    ['x button up'] = true,
	['grab'] = true,
	['drop'] = true,
}

local block_mouse_event = {
	[1] = false, -- 2
	[2] = false,
	[4] = false, -- 5
	[5] = false,
	[6] = false, -- 7
	[7] = false,
	[10] = false,
	[11] = false, -- 12
	[12] = false,
}

local type_to_block = {
	2,
	[4] = 5,
	[6] = 7,
	[11] = 12,
}

local mouse_object_tree
local carried_object
local click = setmetatable({}, {__mode = 'k'})

do
	local windower_settings = windower.get_windower_settings()
	
	local smallest_dimension = math.min(windower_settings.x_res, windower_settings.y_res)
	local depth_determining_factor = 0
	
	while smallest_dimension > 1 do
		depth_determining_factor = depth_determining_factor + 1
		smallest_dimension = smallest_dimension/2
	end
		
	mouse_object_tree = quadtree.new(
		windower_settings.x_res, -- w
		windower_settings.y_res, -- h
		0,						 -- x
		0,						 -- y
		0,						 -- depth
		1,						 -- max
		depth_determining_factor,-- max_depth
		nil						 -- last_node
	)
	
end

local function iterate_over_events(object, event, ...)
	local it = object:events(event)
	if not it then return end
	
	for fn in it() do
		fn(...)
	end
end

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

local object_with_focus

local function iterate_over_hits(type, qt, x, y, delta, s)
	local new_focus
	local possible_hits = qt:get_point_collision(x, y)
	
	for object in possible_hits() do
		if object:visible() and object:hover(x, y) then
			local bail

			s[object] = true
			
			-- create focus change events
			if type == 0 and object._can_take_focus then -- and object ~= object_with_focus then -- new_focus is only focused if not s[owf]
				new_focus = object
			end

			-- create click events
			local click_event
			if type_to_block[type] then
				click[object] = click[object] or {}
				click[object].type = type
				click[object].clock = os.clock()
			elseif type == (click[object] and click[object].type or 0) + 1 then
				if os.clock() - click[object].clock < .2 then -- I pulled 0.2 out of a hat
					-- this is a click
					click_event = type == 2 and 'left click'
						or type == 5 and 'right click'
						or type == 7 and 'middle click'
						or type == 12 and 'x button click'
					
					click[object].type = nil
				end
			end	

			if click_event then
				bail = call_events(object, click_event, x, y, delta)
			end
			
			bail = call_events(object, click_types[type], x, y, delta) or bail
			-- block events
			if bail then
				block_mouse_event[type] = true
				
				local paired_click = type_to_block[type]
				
				if paired_click then
					block_mouse_event[paired_click] = true
				end
				
				break
			end
		end
	end
	
	return new_focus, bail
end

function widget_listener(type, x, y, delta, blocked)
	-- bail out if another addon has handled the event
	if blocked then return end
	
	-- create drag events
	if carried_object then
		if type == 0 then
			local it = carried_object:events('drag', x, y)
			
			local bail = false
			
			if it then
				for fn in it do
					bail = fn(x, y)
					if bail then break end
				end
			end
			
			if not bail then
				local contact_point = carried_object._contact_point
				--local obj = carried_object._group or carried_object

				--obj:pos(x - contact_point[1], y + contact_point[2])
				carried_object:pos(x - contact_point[1], y + contact_point[2])
			end
			
			block_mouse_event[0] = true
		elseif type == 2 then -- default: left button up drops object
			if mouse_object_tree:contains(carried_object) then
				widgets.drop(carried_object, mouse_object_tree)
			else
				widgets.put_down(carried_object)
			end
			
			block_mouse_event[2] = true
		end
	end
	
	-- find the object and call events
	local s = {} -- need a table to see if object_with_focus is still hit.
	local new_focus, bail = iterate_over_hits(type, mouse_object_tree, x, y, delta, s)
		
	if object_with_focus then
		if not s[object_with_focus] then
			local old_focus = object_with_focus
			
			object_with_focus = new_focus
			-- create focus change event
			call_events(old_focus, 'focus change', false)
			
			if new_focus then
				call_events(new_focus, 'focus change', true)
			end
		end	
	elseif new_focus then
		object_with_focus = new_focus
		call_events(object_with_focus, 'focus change', true)
	end
	
	if block_mouse_event[type] then
		block_mouse_event[type] = false
		
		return true
	end
end

function widgets.track(object, x1, x2, y1, y2)
	mouse_object_tree:track(object, x1, x2, y1, y2)
end

function widgets.do_not_track(object)
	mouse_object_tree:do_not_track(object)
end

function widgets.update_object(object, x1, x2, y1, y2, qt)
	(qt or mouse_object_tree):update(object, x1, x2, y1, y2)
end

function widgets.pick_up(object, x, y)
	if carried_object then
		widgets.drop(carried_object)
	end

	object._contact_point = {x - object:pos_x(), y - object:pos_y()}
	carried_object = object
end

function widgets.grab(object, x, y)
	widgets.pick_up(object, x, y)
	call_events(object, 'grab')
end

function widgets.put_down(object)
	carried_object = false
	object._contact_point = nil
	call_events(object, 'drop')
end

function widgets.drop(object, tree)
	local x1, y1 = object:pos()
	local x2, y2 = x1 + object:width(), y1 + object:height()

	widgets.update_object(object, x1, x2, y1, y2, tree)
	widgets.put_down(object)
end

function widgets.allow_focus(object)
	object._can_take_focus = true
end

function widgets.tracking(object)
	return mouse_object_tree:contains(object)
end

function widgets.get_carried_object()
	return carried_object
end

function widgets.get_object_with_focus()
	return object_with_focus
end

function widgets.assign_focus(object)
	if object_with_focus then
		call_events(object_with_focus, 'focus change', false)
	end

	object_with_focus = object
	
	if object then
		call_events(object, 'focus change', true)
	end
end

return widgets
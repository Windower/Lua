if windower.ffxi.get_info().logged_in then
	local player = windower.ffxi.get_player()
	local player_mob = windower.ffxi.get_mob_by_index(player.index)
	
	pc = {
		id = player.id,
		index = player.index,
		pos = {x = player_mob.x, y = player_mob.y}
	}
	
	target = windower.ffxi.get_mob_by_target('st')
		or windower.ffxi.get_mob_by_target('t')
		or {index = 0, hpp = 0}
else
	pc = {}
	target = {index = 0, hpp = 0}
end

alliance = {parties.new(), parties.new(), parties.new()}

alliance_lookup = {}

help_text = [[Nostrum command list.
help: Prints a list of these commands in the console.
refresh(r): Compares the macro's current party structures to
 - the alliance structure in memory.
visible(v): Toggles the macro's visibility.
overlay(o) <name>: Loads a new overlay style.
send(s) <name>: Requires 'send' addon. Sends commands to the
 - character whose name is provided. If no name is provided,
 - send will reset and commands will be sent to the character
 - with Nostrum loaded.]]

--[[
	Wrap object creation and deletion functions:
		Overlay is loaded/unloaded on log-in/log-out/load (potentially frequently).
		
		Track prim/text object names and delete them if the overlay author forgets to.
		
		Visibility wrapped for addon command 'visible'. Ignore object methods and hide
		them at windower's level, then restore them to the state in bucket.
		
		Widgets need to be destroyed as well (meta will keep a reference to them
		even if the sandbox is destroyed). If the quadtree is tracking them, they
		must be removed or the quadtree will become very large.
		Could create a function to dump the contents of meta(4t) and delete the tree?
--]]

bucket = {}

for _, cat in pairs({'text', 'prim'}) do
	local t = {}
	bucket[cat] = t
	
	local bin = windower[cat]
	local create = bin.create
	local visibility = bin.set_visibility
	local delete = bin.delete
	
	windower[cat].create = function(name)
		create(name)
		t[name] = false
	end
	
	windower[cat].set_visibility = function(name, visible)
		visibility(name, visible)
		t[name] = visible
	end
	
	windower[cat].delete = function(name)
		delete(name)
		t[name] = nil
	end
	
	windower[cat].rawset_visibility = visibility
end

bucket.widgets = {}

for _, cat in pairs({
		'simple_buttons', 'windows', 'buttons',
		'scroll_text', 'sliders', 'scroll_menu',
		'groups', 'grids', 'texts', 'prims',
	}) do
	
	local class = _G[cat]
	local new = class.new
	local destroy = class.destroy
	
	class.new = function(...)
		local obj = new(...) 
		bucket.widgets[obj] = true
		
		return obj
	end
	
	class.destroy = function(obj)
		if widgets.tracking(obj) then
			widgets.do_not_track(obj)
		end

		destroy(obj)
		bucket.widgets[obj] = nil
	end
end

local function generate_access_to_table(n)
	local party = alliance[n]
	
	return function(t, k)
		local id = party[k]
		
		if not id then 
			print('No player at position ' .. tostring(k))
			return
		end
		
		local lookup = alliance_lookup[id]
		local player = readonly(lookup)
		
		-- the buffs key will be writeable, but the table will be protected
		-- Not great.
		rawset(player, 'buffs', readonly(lookup.buffs))
		
		return player
	end
end

function build_a_sandbox(overlay_name)
	sandbox = {
		pairs = pairs,
		ipairs = ipairs,
		assert = assert,
		error = error,
		next = next,
		pcall = pcall,
		print = print,
		select = select,
		setmetatable = setmetatable,
		getmetatable = getmetatable,
		tonumber = tonumber,
		tostring = tostring,
		type = type,
		unpack = unpack,
		xpcall = xpcall,
	}

	sandbox.alliance = readonly({
		setmetatable({}, {__index = generate_access_to_table(1)}),
		setmetatable({}, {__index = generate_access_to_table(2)}),
		setmetatable({}, {__index = generate_access_to_table(3)}),
	})

	for i = 1, 3 do
		sandbox.alliance[i].count = function() return alliance[i]:count() end
	end

	sandbox.addon_state = readonly(nostrum.state)
	sandbox.overlay = {}
	sandbox.windower_settings = windower.get_windower_settings()
	sandbox.player = readonly(pc)
	sandbox.register_event = nostrum.register_event
	sandbox.unregister_event = nostrum.unregister_event
	sandbox.get_zone = function() return windower.ffxi.get_info().zone end

	sandbox.target = readonly(target)

	-- a (very) limited version of require
	-- prevents require from altering Nostrum's global table

	sandbox.overlay_path = '%soverlays/%s/':format(windower.addon_path, overlay_name)
	sandbox.addon_path = windower.addon_path
		
	sandbox.require = function(file)
		local fn, err = loadfile(
			'%s/%s.lua'
			:format(sandbox.overlay_path, file)
		)
		
		if fn then
			setfenv(fn, sandbox)
			return fn()
		else
			print(err)
		end
	end

	sandbox._G = sandbox

	-- available libraries
	sandbox.S, sandbox.T, sandbox.L = S, T, L

	for _, lib in ipairs({
		'config', 'simple_buttons', 'windows', 'scroll_menu', 'scroll_text',
		'sliders', 'widgets', 'buttons', 'groups', 'grids', 'texts', 'prims',
		'_addon', 'list', 'set', 'table', 'coroutine', 'string', 'math',
		'io', 'os', 'json', 'files'
		}) do
		
		local t = {}
		sandbox[lib] = t
		
		for s, fn in pairs(_G[lib]) do
			t[s] = fn
		end
	end

	sandbox.res = res -- too huge to copy, doesn't really need to be protected anyway:
end
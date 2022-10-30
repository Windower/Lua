_addon.name    = 'linuxfix'
_addon.version = '0.5.0'
_addon.author = 'Rubenator,Surik,BeYoNDLiFe'

--[[
	Do not bother using this if you are on Windows.

	This addon will need to be autoloaded via your init.

	This code has only been tested with fairly standard en-US keyboards.

	This addon restores full keyboard functionality in Windower with newer versions of Wine and bypasses the need to build your own version of Wine with a specific commit reverted.
	It also remaps Windows key bindings and makes them functional again with the exception of bindings with multiple modifiers such as %^!1 (Ctrl+Super+Alt+1). The listbinds command is only capable of returning a single modifier and thus they cannot be remapped correctly.
	It reads and parses the content of the 'listbinds' command anytime it runs and forwards the keys as appropriate to the client. It also hides the output of this command to avoid console spam.
	It's not a fix since it doesn't actually repair the original issue of the keybinds using raw keyboard input but it does work nicely as a workaround.

	When there are a left and right version of a key such as lctrl and rctrl windower sends the lctrl dik even when the right key has been pressed. This also applies to enter and numpadenter. 
	While the correct keys are in the table below, windower will just use the left version.

	For lack of a better method of keeping the keybinds up to date, the list is refreshed every time you press a key. This was done because Gearswap files frequently rebind keys between jobs.
	Since this caused significant lag, a limit was placed so it could not run more than once per second. This limit can be modified using the 'check_rate' variable.
	The binds are also now added to a table and don't have to be parsed everytime you press a key which has reduced overhead as well.

	Big shoutout and thanks to Rubenator, he took the awful code Surik and BeYoNDLiFe gave him and made it so much better.
]]--

check_rate = 1

require('luau')
mods = S{}
keybinds = {}
last_state = T{}
local dik_lookup = T{[-1]='sysrq', [1]='escape', [2]='1', [3]='2', [4]='3', [5]='4', [6]='5', [7]='6', [8]='7', [9]='8', [10]='9', [11]='0', [12]='-', [13]='=', [14]='backspace', [15]='tab', [16]='q', [17]='w', [18]='e', [19]='r', [20]='t', [21]='y', [22]='u', [23]='i', [24]='o', [25]='p', [26]='[', [27]=']', [28]='enter', [30]='a', [31]='s', [32]='d', [33]='f', [34]='g', [35]='h', [36]='j', [37]='k', [38]='l', [39]="\\;", [40]="'", [41]='`',  [43]='\\\\', [44]='z', [45]='x', [46]='c', [47]='v', [48]='b', [49]='n', [50]='m', [51]=',', [52]='.', [53]='/', [54]='rshift', [55]='numpad*', [57]='space', [58]='capslock', [59]='f1', [60]='f2', [61]='f3', [62]='f4', [63]='f5', [64]='f6', [65]='f7', [66]='f8', [67]='f9', [68]='f10', [69]='numlock', [70]='scrolllock', [71]='numpad7', [72]='numpad8', [73]='numpad9', [74]='numpad-', [75]='numpad4', [76]='numpad5', [77]='numpad6', [78]='numpad+', [79]='numpad1', [80]='numpad2', [81]='numpad3', [82]='numpad0', [83]='numpad.', [86]='oem_102', [87]='f11', [88]='f12', [100]='f13', [101]='f14', [102]='f15', [112]='kana', [115]='abnt_c1', [121]='convert', [123]='noconvert', [125]='yen', [126]='abnt_c2', [141]='numpadequals', [145]='at', [146]='colon', [147]='underline', [148]='kanji', [149]='stop', [150]='ax', [151]='unlabeled', [153]='nexttrack', [156]='numpadenter', [157]='rctrl', [160]='mute', [161]='calculator', [162]='playpause', [164]='mediastop', [174]='volumedown', [176]='volumeup', [178]='webhome', [179]='numpadcomma', [181]='numpad/', [183]='sysrq', [184]='rmenu', [197]='pause', [199]='home', [200]='up', [201]='pageup', [203]='left', [205]='right', [207]='end', [208]='down', [209]='pagedown', [210]='insert', [211]='delete', [220]='rwin', [222]='power', [223]='sleep', [227]='wake', [229]='websearch', [230]='webfavorites', [231]='webrefresh', [232]='webstop', [233]='', [234]='webback', [235]='mycomputer', [236]='mail', [237]='mediaselect'}
local mod_lookup = T{[29]='Ctrl', [42]='Shift', [56]='Alt', [219]='Win', [221]='Apps'}
key_lookup = T{}
name_lookup = T{}
last_update = nil
do 
	key_lookup:update(dik_lookup:map(function(name) return {name=name} end))
	key_lookup:update(mod_lookup:map(function(name) return {name=name, mod=true} end))
	for dik, data in pairs(key_lookup) do
		name_lookup[data.name] = {mod=data.mod, dik=dik}
	end
end

windower.register_event('keyboard',function(dik,pressed)
	if pressed == last_state[dik] then return end
	last_state[dik] = pressed
	local key_data = key_lookup[dik]
	if not key_data then return end
	if key_data.mod then
		if pressed then
			mods:add(key_data.name)
		else
			mods:remove(key_data.name)
		end
		send_key_state(key_data, pressed)
	elseif pressed then
		if not last_update or os.clock() - last_update > check_rate then
			windower.send_command('listbinds')
		end
		local command = check_bind(key_data)
		if command then
			windower.send_command(command)
		else
			send_key_state(key_data, pressed)
		end
	else
		send_key_state(key_data, pressed)
	end
end)

function check_bind(key_data)
	local binds = keybinds[key_data.name]
	if not binds then return false end
	local info = windower.ffxi.get_info()
	local chat_open = info and info.chat_open
	--if chat_open == nil then return false end
	binds = binds:filter(function(bind)
		return (bind.chat_state == nil or chat_open and bind.chat_state == 'ChatOnly' or not chat_open) and (bind.mods:length() == bind.mods:intersection(mods):length())
	end)
	local number_of_binds = binds:length()
	if number_of_binds == 0 then
		return false
	else
		return binds:first().command
	end
end

function send_key_state(key_data, pressed)
	windower.send_command('setkey %s %s':format(key_data.name, pressed and "down" or "up"))
end

windower.register_event('incoming text', function(original, modified, color, color_m, blocked)
	if color ~= 141 then return end
	if ListBinds then
		if original == '===== Done Listing Currently Bound Keys =====' then
			ListBinds = false
			for _,binds in pairs(new_keybinds) do
				binds:sort(function(a,b) return a.mods:length() > b.mods:length() end)
			end
			keybinds = new_keybinds
		else
			add_bind(original)
		end
		return true
	elseif original == '===== Listing Currently Bound Keys =====' then
		last_update = os.clock()
		new_keybinds = {}
		ListBinds = true
		return true
	end
end)

local chat_states = {['(NoChat)']='NoChat', ['(ChatOnly)']='ChatOnly'}
function add_bind(original)
	local bind, command = original:match('^([^:]*): (.*)$')
	if not bind or not command then return end
	bind = bind:gsub('^%-', 'minus'):gsub('%-%-', '-minus')
	parts = bind:split('-'):map(string.gsub-{'minus', '-'})
	local chat_state, key
	local mods = S{}
	for _,part in pairs(parts) do
		if chat_states[part] then
			chat_state = chat_states[part]
		elseif part ~= '' then
			local key_data = name_lookup[part]
			if key_data then
				if key_data.mod then
					mods:add(part)
				else
					key = part
				end
			end
		end
	end
	if not new_keybinds[key] then
		new_keybinds[key] = L{}
	end
	new_keybinds[key]:append({key=key, mods=mods, chat_state=chat_state, command=command})
end

windower.send_command('listbinds')

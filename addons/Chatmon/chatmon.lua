--Copyright 2022 Carl Lewis

--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is furnished
--to do so, subject to the following conditions:

--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.

--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
--INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
--HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
--OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
--SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

_addon.name = 'Chatmon'
_addon.version = '1.0'
_addon.author = 'Xabis/Aurum (Asura)'
_addon.commands = {'chatmon','cm'}

require('strings')
require('chat')
require('lists')
require('sets')
require('tables')
local files = require('files')
local packets = require('packets')
local settings = require('settings')

--------------------------------------------------------------------------------
-- internal config
--------------------------------------------------------------------------------
CONFIG_FILE = "data/ChatMon.xml"
CHANNEL_GENERAL = 207 -- channel for general messages from chatmon
CHANNEL_RESULTS = 141 -- channel for displaying results/data
CHANNEL_BLOCKED = 160 -- channel for displaying messages blocked by a filter

--------------------------------------------------------------------------------
-- globals
--------------------------------------------------------------------------------
config = nil
lastplay = 0
soundinterval = 0
showchannels = false
showblocks = false
talk_channels = S{0,1,4,5,26,27}
last_chat = T{}
player = {
	id = (windower.ffxi.get_player() or {}).id,
	name = (windower.ffxi.get_player() or {}).name,
}
settings_map = T{
	SoundInterval = {vtype = "number", desc = "Number of seconds that must elapse before another sound may play."},
	TellSound = {vtype = "sound", desc = "A sound to play when receiving a tell."},
	TalkSound = {vtype = "sound", desc = "A sound to play when your player name appears in select channels"},
	InviteSound = {vtype = "sound", desc = "A sound to play when receiving a party invitation."},
	EmoteSound = {vtype = "sound", desc = "A sound to play when you are the target of an emote."},
	ExamineSound = {vtype = "sound", desc = "A sound to play when you are being examined by another player."},
}
channel_map = T{
	say = 1,
	shout = 2,
	yell = 11,
	party = 5,
	linkshell = 6,
	linkshell2 = 213,
	tell = 12,
	emote = 7,
	examine = 208,
	readies = 110,
	wearoff = 191,
	casting = 50,
}
filter_map = T{
	-- These are chat modes not channel ids
	shout = 1,
	yell = 26,
	tell = 3,
}

--------------------------------------------------------------------------------
-- helpers
--------------------------------------------------------------------------------

-- converts a from/notfrom channel into an index
function getchannel(value, col, strict)
	if col == nil then
		col = channel_map
	end
	value = value:lower()
	if col[value] then
		return col[value]
	elseif tonumber(value) ~= nil then
		if (strict and not col:contains(value)) then
			return nil
		end
		return tonumber(value)
	end
	return nil
end

-- converts a channel list into a lookup table
function expandchannels(list, col)
	local t = {}
	local written = false
	
	if (list) then
		local items = list:split("|")
		for key, value in ipairs(items) do
			local channel = getchannel(value, col)
			if channel ~= nil then
				t[channel] = true
				written = true
			end
		end
	end

	if (written) then
		return t
	end
end

-- builds lookup tables for channels to reduce processing
function expandtriggers()
	for key, value in ipairs(config.triggers) do
		value.include = expandchannels(value.from)
		value.exclude = expandchannels(value.notfrom)
	end
	for key, value in ipairs(config.filters) do
		value.include = expandchannels(value.from, filter_map)
	end
end

-- translates a sound file
function translateSoundFile(name)
	local normname = name:lower()
	if normname == "tell" then
		return "INCOMINGTELL.wav"
	elseif normname == "examine" then
		return "INCOMINGEXAM.wav"
	elseif normname == "emote" then
		return "INCOMINGEMOT.wav"
	elseif normname == "talk" then
		return "INCOMINGTALK.wav"
	elseif normname == "invite" then
		return "INCOMINGINVI.wav"
	elseif normname:endswith(".wav") then
		return name
	end
	return name .. ".wav"
end

-- resolves a sound file
function resolveSound(sound)
	sound = translateSoundFile(sound)
	if windower.file_exists(windower.addon_path .. "sounds\\" .. sound) then
		return windower.addon_path .. "sounds\\" .. sound
	elseif windower.file_exists(sound) then
		return sound
	end
	return nil
end

-- plays a sound, limited by configured delay
function playSound(sound)
	local file = resolveSound(sound)
	if file then
		local current = os.clock()
		if (current-soundinterval >= lastplay) then
			windower.play_sound(file)
			lastplay = current
		end
	end
end

-- checks audio trigger rules on a text message
function checkTriggers(channel, message)
	for key, value in ipairs(config.triggers) do
		if not value.exclude or not value.exclude[channel] then
			if not value.include or value.include[channel] then
				if not value.notmatch or not windower.wc_match(message, value.notmatch) then
					if value.match and windower.wc_match(message, value.match) then
						playSound(value.sound)
						-- windower cant play more than one sound at a time, so it doenst make sense to keep looking
						return
					end
				end
			end
		end
	end
end

-- formats a trigger for display
function formatTrigger(trigger)
	local text = ""
	if trigger.from then
		text = trigger.from
	else
		text = "All"
	end
	text = text .. ":" .. trigger.match

	if (trigger.notmatch or trigger.notfrom) then
		if not trigger.notfrom then
			text = text .. " - exclude from: " .. trigger.notmatch
		elseif not trigger.notmatch then
			text = text .. " - exclude match: " .. trigger.notfrom
		else
			text = text .. " - exclude: " .. trigger.notfrom .. ":" .. trigger.notmatch
		end
	end

	return text
end

-- formats a filter for display
function formatFilter(filter)
	local text = ""
	if filter.from then
		text = filter.from
	else
		text = "All"
	end
	text = text .. ":" .. filter.value
	if (filter.mode == "regex") then
		text = text .. " (regex)"
	end
	return text
end

-- Remove a trigger by its index or a by a search pattern
function removeTrigger(pattern)
	-- Remove based on index or pattern
	local removed = L{}
	if tonumber(pattern) ~= nil then
		local item = config:removeTriggerByIndex(tonumber(pattern))
		if item then
			removed:append(item)
		end
	else
		removed = config:removeTriggerByPattern(pattern)
	end

	-- Echo back the result
	if (removed.n > 0) then
		windower.add_to_chat(CHANNEL_RESULTS, "Removed triggers:")
		for key, value in ipairs(removed) do
			local attrs = getAttributeTable(value)
			windower.add_to_chat(CHANNEL_RESULTS, formatTrigger(attrs))
		end
	else
		print("No triggers matched your search pattern.")
	end
end

-- Remove a filter by its index or a by a search pattern
function removeFilter(pattern)
	-- Remove based on index or pattern
	local removed = L{}
	if tonumber(pattern) ~= nil then
		local item = config:removeFilterByIndex(tonumber(pattern))
		if item then
			removed:append(item)
		end
	else
		removed = config:removeFilterByPattern(pattern)
	end

	-- Echo back the result
	if (removed.n > 0) then
		windower.add_to_chat(CHANNEL_RESULTS, "Removed filters:")
		for key, value in ipairs(removed) do
			local dict = getChildrenTable(value)
			windower.add_to_chat(CHANNEL_RESULTS, formatFilter(dict))
		end
	else
		print("No filters matched your search pattern.")
	end
end

-- validates a channel list
function validateChannels(list, col, strict)
	local valid = true
	local invalid = L{}
	if (list) then
		local items = list:split("|")
		if (items.n > 0) then
			for key, value in ipairs(items) do
				if (getchannel(value, col, strict) == nil) then
					invalid:append(value)
					valid = false
				end
			end
		else
			valid = false
		end
	else
		valid = false
	end

	return valid, invalid
end

basic_config = [[
<?xml version="1.0" ?>
<ChatMon>
	<settings
		TellSound="Tell"
		ExamineSound="Examine"
		EmoteSound="Emote"
		TalkSound="Talk"
		InviteSound="Invite"
		SoundInterval="5"
	/>
</ChatMon>
]]

-- Initialize/reload the settings
function loadSettings()
	if (config == nil) then
		local fConfig = files.new(CONFIG_FILE)
		if not fConfig:exists() then
			print("Chatmon: No configuration found; creating an empty one.")
			fConfig:create()
			fConfig:write(basic_config)
			print("Chatmon: See data/Chatmon-Example.xml for a ready to use example loadout.")
		end
		config = settings:load(fConfig)
	else
		config:reload()
	end
	
	-- cache lookup tables
	expandtriggers()
	if (config.settings.SoundInterval) then
		local newinterval = tonumber(config.settings.SoundInterval)
		if (newinterval ~= nil) then
			soundinterval = newinterval
		end
	end
end

--------------------------------------------------------------------------------
-- Init/Events
--------------------------------------------------------------------------------
loadSettings()

windower.register_event('incoming text', function(original, modified, original_mode, modified_mode, blocked)
	if not blocked then
		local converted = original:strip_format()
		checkTriggers(original_mode, converted)
		if showchannels then
			return "%s:%s":format(original_mode, original), original_mode
		end
	end
end)

windower.register_event('addon command',function (...)
	local command = L{...}
	local action = command[1]

	if action == "showchannels" or action == "sc" then
		-- TOGGLE SHOW CHANNELS command
		showchannels = not showchannels
		if showchannels then
			windower.add_to_chat(CHANNEL_GENERAL, "Chatmon: Channel ids will now prefix all incoming text.")
		else
			windower.add_to_chat(CHANNEL_GENERAL, "Chatmon: Channel ids will no longer be prefixed.")
		end
	elseif action == "showblocks" or action == "sb" then
		-- TOGGLE SHOW BLOCKS command
		showblocks = not showblocks
		if showblocks then
			windower.add_to_chat(CHANNEL_GENERAL, "Chatmon: Blocked text will be marked and echoed.")
		else
			windower.add_to_chat(CHANNEL_GENERAL, "Chatmon: Blocked text will be no longer be visible.")
		end
	elseif action == "test" then
		-- TEST MATCH command
		if command.n == 4 then
			local mtype = command[2]:lower()
			if mtype == "regex" then
				if windower.regex.match(command[3], command[4]) then
					print("matched")
				else
					print("no match")
				end
			elseif mtype == "match" then
				if windower.wc_match(command[3], command[4]) then
					print("matched")
				else
					print("no match")
				end
			else
				print("Valid modes: match and regex")
			end
		else
			print("Tests if a pattern is a match with some text")
			print("format: test match|regex <text> <pattern>")
		end
	elseif action == "play" or action == "p" then
		-- PLAY command
		if command[2] then
			local resolved = resolveSound(command[2])
			if resolved then
				windower.play_sound(resolved)
			else
				print("Sound cannot be located.")
			end
		else
			print("Enter sound file to play/test.")
		end
	elseif action == "reload" or action == "r" then
		-- RELOAD command
		loadSettings()
		print("Settings reloaded.")
	elseif action == "setting" or action == "s" then
		-- SETTINGS command
		local subaction = command[2]
		if subaction == "list" or subaction == "l" then
			-- LIST setting command
			windower.add_to_chat(CHANNEL_RESULTS, "Current Settings:")
			for key, value in pairs(config.settings) do
				windower.add_to_chat(CHANNEL_RESULTS, "%s: %s":format(key, value))
			end
		elseif subaction == "remove" or subaction == "r" then
			-- REMOVE setting command
			local name = command[3]
			if name then
				if config.settings[name] then
					config:changeSetting(name, nil)
					print("Setting removed.")

					-- Special consideration if sound interval is being removed
					if name == "SoundInterval" then
						soundinterval = 0
					end
				else
					print("Setting does not exist.")
				end
			else
				print("Format: remove <name>")
				print("Names are case-sensitive.")
			end
		elseif subaction == "set" or subaction == "s" then
			-- SET setting command
			if command.n == 4 then
				local name = command[3]
				local value = command[4]
				-- Validate setting
				local vitem = settings_map[name]
				if vitem then
					local vtype = vitem.vtype
					if vtype == "number" then
						-- Convert number and check
						local test = tonumber(value)
						if test == nil then
							print("Setting must be a valid number.")
							return
						end
					elseif vtype == "sound" then
						-- Attempt to resolve the sound and check
						if resolveSound(value) == nil then
							print("Invalid sound.")
							print("  This is relative to the addon 'sounds' folder location.")
							print("  If the .wav extention is missing, it will be added automatically.")
							return
						end
					elseif vtype ~= "string" then
						-- If a bad type is mapped, then reject. This should never happen.
						print("Internal error: setting mapped to unknown validation type.")
						return
					end
					config:changeSetting(name, value)
					
					-- Special consideration if sound interval is being updated
					if name == "SoundInterval" then
						soundinterval = tonumber(value)
					end
				else
					-- Setting is not in the validation list; reject
					local keys = settings_map:keyset()
					print("Invalid setting name.")
					print("Valid names: " .. keys:format("oxford", "(none)"))
				end
			else
				-- Not enough arguments; display help
				local keys = settings_map:keyset()
				print("Format: set <name> <value>")
				print("Valid settings:")
				for k, v in pairs(settings_map) do
					print("%s: %s":format(k, v.desc))
				end
			end
		else
			print("Settings commands:")
			print("  set: Adds or Updates a setting value")
			print("  list: Dump all current settings to the chat")
			print("  remove: Removes a setting")
		end
	elseif action == "trigger" or action == "t" then
		local subaction = command[2]
		if subaction == "list" or subaction == "l" then
			-- LIST trigger command
			windower.add_to_chat(CHANNEL_RESULTS, "Currently loaded triggers:")
			for key, value in ipairs(config.triggers) do
				windower.add_to_chat(CHANNEL_RESULTS, "%s %s":format(key, formatTrigger(value)))
			end
		elseif subaction == "remove" or subaction == "r" then
			-- REMOVE trigger command
			local pattern = command[3]
			if pattern then
				removeTrigger(pattern)
			else
				print("Enter a number to remove by index, or a text query to search and remove multiples.")
			end
		elseif subaction == "add" or subaction == "a" then
			-- ADD trigger command
			local valid = false
			local newtrigger = {
				match = nil,
				sound = nil
			}

			-- parse params
			if (command.n > 3 and command.n < 11 and command.n % 2 == 0) then
				newtrigger.match = command[3]
				newtrigger.sound = command[command.n]
				valid = true
				
				-- Validate sound
				if resolveSound(newtrigger.sound) == nil then
					print("Invalid sound: " .. newtrigger.sound)
					print("  This is relative to the addon 'sounds' folder location.")
					print("  If the .wav extention is missing, it will be added automatically.")
					valid = false
				end
				
				-- Extract and validate additional options
				if command.n > 4 then
					local invalidoptions = L{}
					local invalidchannels = L{}
					
					for i=4, command.n-1, 2 do
						local key = command[i]
						local value = command[i+1]
						
						if (key == "nm") then
							-- Not Match
							newtrigger.notmatch = value
						elseif (key == "f") then
							-- From
							local result, rejected = validateChannels(value)
							if (result) then
								newtrigger.from = value
							else
								invalidchannels:append("from: " .. rejected:format("oxford", "(none)"))
								valid = false
							end
						elseif (key == "nf") then
							-- Not From
							local result, rejected = validateChannels(value)
							if (result) then
								newtrigger.notfrom = value
							else
								invalidchannels:append("notfrom: " .. rejected:format("oxford", "(none)"))
								valid = false
							end
						else
							invalidoptions:append(key)
							valid = false
						end
					end
					if invalidchannels.n > 0 then
						local keys = channel_map:keyset()
						print("One or more channels are invalid:")
						print("  " .. invalidchannels:format("oxford", "(none)"))
						print("  The channel list may only contain numbers and/or built-in named shortcuts.")
						print("  Valid shortcuts: " .. keys:format("oxford", "(none)"))
					end
					if invalidoptions.n > 0 then
						print("Invalid option provided: " .. invalidoptions:format("oxford", "(none)"))
						print("  Valid options: nm, f, and nf")
					end
				end
			else
				print("Format:")
				print("  add pattern [f channels] [nm pattern] [nf channels] sound")
				print("  pattern: match pattern (REQUIRED)")
				print("  nm: Exclude pattern")
				print("  f: Restrict to one or more channels")
				print("  nf: Exclude one or more channels")
				print("  sound: WAV file to play; Extention optional. (REQUIRED)")
				print("Example:")
				print("  cm trigger add \"*Bad Breath*\" f Readies stun")
			end
			if valid then
				-- add trigger to the config, save, and reflush tables
				if config:addTrigger(newtrigger) then
					-- expansion cache is required to be rebuilt after a flush
					expandtriggers()
					windower.add_to_chat(CHANNEL_RESULTS, "Trigger added: %s":format(formatTrigger(newtrigger)))
				end
			end
		else
			print("Trigger commands:")
			print("  add: Add a new audio trigger")
			print("  list: Dump all triggers to the chat")
			print("  remove: Removes a single trigger by either its numerical index, or a search query to remove multiples")
		end
	elseif action == "filter" or action == "f" then
		local subaction = command[2]
		if subaction == "list" or subaction == "l" then
			-- LIST filter command
			windower.add_to_chat(CHANNEL_RESULTS, "Currently loaded filters:")
			for key, value in ipairs(config.filters) do
				windower.add_to_chat(CHANNEL_RESULTS, "%s %s":format(key, formatFilter(value)))
			end
		elseif subaction == "remove" or subaction == "r" then
			-- REMOVE filter command
			local pattern = command[3]
			if pattern then
				removeFilter(pattern)
			else
				print("Enter a number to remove by index, or a text query to search and remove multiples.")
			end
		elseif subaction == "grab" or subaction == "g" then
			if (command.n > 2 and command.n < 5) then
				local name = command[3]
				local message = last_chat[name:lower()]
				
				-- direct lookup failed. lets do a partial match instead
				if not message then
					for k, v in pairs(last_chat) do
						if string.find(k, name) then
							message = v
						end
					end
				end
				
				-- message was found, lets add it as a filter
				if message then
					local newfilter = {
						value = escapeHex(message), -- escape binary chars
					}
					
					-- Extract and validate additional options
					if command.n == 4 then
						local channels = command[4]:lower()
						local result, rejected = validateChannels(channels, filter_map, true)
						if (result) then
							newfilter.from = channels
						else
							local keys = filter_map:keyset()
							print("One or more channels are invalid:")
							print("  " .. rejected:format("oxford", "(none)"))
							print("  The channel list may only contain supported mode numbers and/or built-in named shortcuts.")
							print("  Valid shortcuts: " .. keys:format("oxford", "(none)"))
							return
						end
					end
					
					-- add filter to the config, save, and reflush tables
					if config:addFilter(newfilter) then
						-- expansion cache is required to be rebuilt after a flush
						expandtriggers()
						windower.add_to_chat(CHANNEL_RESULTS, "Filter added: %s":format(formatFilter(newfilter)))
					end
				else
					print("Player "..name.." could not be found.")
				end
			else
				print("Format:")
				print("  grab Playername [channels]")
				print("  Playername: Name of the player to grab last message from. May be a partial name.")
				print("  channels: Restrict to one or more channels. OPTIONAL")
				print("Examples:")
				print("  cm filter grab Thatgilseller")
			end
		elseif subaction == "add" or subaction == "a" then
			-- ADD filter command
			local valid = false
			local newfilter = {
				value = nil,
			}

			-- parse params
			if (command.n > 3 and command.n < 6) then
				--add match|regex pattern [channels]
				newfilter.mode = command[3]:lower()
				newfilter.value = command[4]
				valid = true
				
				-- Validate mode
				if (newfilter.mode ~= "match" and newfilter.mode ~= "regex") then
					print("Invalid mode specified. Valid options are: match and regex.")
					valid = false
				end

				-- Extract and validate additional options
				if command.n == 5 then
					local channels = command[5]:lower()
					local result, rejected = validateChannels(channels, filter_map, true)
					if (result) then
						newfilter.from = channels
					else
						local keys = filter_map:keyset()
						print("One or more channels are invalid:")
						print("  " .. rejected:format("oxford", "(none)"))
						print("  The channel list may only contain supported mode numbers and/or built-in named shortcuts.")
						print("  Valid shortcuts: " .. keys:format("oxford", "(none)"))
						valid = false
					end
				end
			else
				print("Format:")
				print("  add match|regex pattern [channels]")
				print("  match|regex: If match, then matching uses wc_match rules. If regex, then uses regular expressions")
				print("  pattern: The search pattern to filter incoming text")
				print("  channels: Restrict to one or more channels. OPTIONAL")
				print("Examples:")
				print("  cm filter add match \"*buy my gil*\" Yell|Shout")
				print("  cm filter add regex \"[0-9]+m\" Yell")
			end
			if valid then
				-- add filter to the config, save, and reflush tables
				if config:addFilter(newfilter) then
					-- expansion cache is required to be rebuilt after a flush
					expandtriggers()
					windower.add_to_chat(CHANNEL_RESULTS, "Filter added: %s":format(formatFilter(newfilter)))
				end
			end
		else
			print("Filter commands:")
			print("  add: Add a new chat filter")
			print("  grab: Adds a new filter using the last message sent by the specified player")
			print("  list: Dump all filters to the chat")
			print("  remove: Removes a single filter by either its numerical index, or a search query to remove multiples")
		end
	else
		print("Commands:")
		print("  reload: Reload settings file")
		print("  trigger: Manipulate audio triggers")
		print("  filter: Manipulate chat filters")
		print("  setting: Change a chatmon program option")
		print("  showchannels: Inject channel as a prefix to all received text (toggle)")
		print("  showblocks: Text blocked by a filter will be echoed in the log for debugging purposes (toggle)")
		print("  test: Utility to test pattern matching")
		print("  play: Utility to test if a sound is valid")
	end
end)

windower.register_event('incoming chunk', function(id,data)
	if id == 0x017 then
		local chat = packets.parse('incoming', data)
		local mode = chat['Mode']
		local sender = chat['Sender Name']
		local message = windower.convert_auto_trans(chat['Message']):lower()
		
		-- Filter incoming text from shout/tell/yell
		if mode == 1 or mode == 3 or mode == 26 then
			-- process filters
			if config.filters.n > 0 then
				for key, value in ipairs(config.filters) do
					if not value.include or value.include[mode] then
						if value.mode == "regex" then
							-- Regular expression
							if windower.regex.match(message, value.value) then
								if showblocks then
									windower.add_to_chat(CHANNEL_BLOCKED, "Blocked: %s: %s":format(sender, message))
								end
								return true
							end
						else
							-- Windower wc_match
							if windower.wc_match(message, value.value) then
								if showblocks then
									windower.add_to_chat(CHANNEL_BLOCKED, "Blocked: %s: %s":format(sender, message))
								end
								return true
							end
						end
					end
				end
			end
			
			-- capture last text sent from each player, for use in the filter grab feature 
			last_chat[sender:lower()] = chat['Message']
		end
		
		-- Special case audio alerts
		if mode == 3 and sender ~= player.name then
			if (config.settings.TellSound) then
				playSound(config.settings.TellSound)
			end
		elseif talk_channels:contains(mode) and message:contains(player.name:lower()) then
			if (config.settings.TalkSound) then
				playSound(config.settings.TalkSound)
			end
		end
	elseif id == 0x0DC then
		if (config.settings.InviteSound) then
			playSound(config.settings.InviteSound)
		end
	end
end)

windower.register_event('emote', function(emote_id,sender_id,target_id)
	if target_id == player.id and sender_id ~= player.id then
		if (config.settings.EmoteSound) then
			playSound(config.settings.EmoteSound)
		end
	end
end)

windower.register_event('examined', function(sender_name,sender_index)
	if sender_name ~= player.name then
		if (config.settings.ExamineSound) then
			playSound(config.settings.ExamineSound)
		end
	end
end)

windower.register_event('login', function(name)
	player.id = windower.ffxi.get_player().id
	player.name = name
end)
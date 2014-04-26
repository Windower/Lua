--[[
widescantool v1.20140425

Copyright (c) 2014, Mujihina
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of enternity nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mujihina BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]


_addon.name    = 'widescantool'
_addon.author  = 'Mujihina'
_addon.version = '1.20140424'
_addon.command = 'widescantool'
_addon.commands = {'wst'}


require ('luau')
config = require ('config')
packets = require ('packets')
-- zone names
zones = require ('resources').zones
-- file with mob NPCs and full names
mob_names = require ('mob_names')

-- Defaults 
defaults = {}
defaults.global = {}
defaults.global.alerts = S{}
defaults.global.filters = S{}
defaults.area = {}
defaults.area.alerts = T{}
defaults.area.filters = T{}
defaults.filter_pets = true
-- most common mob pet names
pet_filters = S{"'s bat", "'s leech", "'s bats", "'s elemental", "'s spider", "'s tiger", "'s bee", "'s beetle", "'s rabbit"}


-- Global vars
-- Load previous settings
settings = config.load(defaults)
combined_alerts = {}
combined_filters = {}
zone_name = ""
zone_id = ""

enable_mode = true

-- Save settings
function save_settings()
	update_area_info()
	config.save(settings)
end

-- Change settings back to default
function reset_to_default()
	enable_mode = true
	settings:reassign(defaults)
	config.save(settings, 'all')
	windower.add_to_chat (167, 'wst: All current and saved settings have been cleared')
end

-- Show syntax
function show_syntax()
	windower.add_to_chat (200, 'wst: Syntax is:')
	windower.add_to_chat (207, 'wst: \'wst lg\': List Global settings')
	windower.add_to_chat (207, 'wst: \'wst la\': List settings for current Area')
	windower.add_to_chat (207, 'wst: \'wst lc\': List the combined (global+area) filters/alerts currently being applied')
	windower.add_to_chat (207, 'wst: \'wst laaf\': List All Area Filters')
	windower.add_to_chat (207, 'wst: \'wst laaa\': List All Area Alerts')
	windower.add_to_chat (207, 'wst: \'wst agf <name or pattern>\': Add Global Filter')
	windower.add_to_chat (207, 'wst: \'wst rgf <name or pattern>\': Remove Global Filter')
	windower.add_to_chat (207, 'wst: \'wst aga <name or pattern>\': Add Global Alert')
	windower.add_to_chat (207, 'wst: \'wst rga <name or pattern>\': Remove Global Alert')
	windower.add_to_chat (207, 'wst: \'wst aaf <name or pattern>\': Add Area Filter')
	windower.add_to_chat (207, 'wst: \'wst raf <name or pattern>\': Remove Area Filter')
	windower.add_to_chat (207, 'wst: \'wst aaa <name or pattern>\': Add Area Alert')
	windower.add_to_chat (207, 'wst: \'wst raa <name or pattern>\': Remove Area Alert')
	windower.add_to_chat (207, 'wst: \'wst defaults\': Reset to default settings')
	windower.add_to_chat (207, 'wst: \'wst toggle\': Enable/Disable all filters/alerts temporarily')
	windower.add_to_chat (207, 'wst: \'wst pet\': Enable/Disable filtering of common mob pets')
end

-- Parse and process commands
function wst_command (cmd, ...)
	if (not cmd or cmd == 'help' or cmd == 'h') then
		show_syntax()
		return
	end
      	
	-- Force a zone update. Mostly for debugging.
	if (cmd == 'u') then update_area_info() return end
	
	local args = L{...}
	
	-- Set to defaults
	if (cmd == 'defaults') then
		reset_to_default()
		return
	end
	
	-- Toggle enable mode
	if (cmd == 'toggle') then
		enable_mode = not enable_mode
		if (enable_mode) then
			windower.add_to_chat (167, 'wst: filters/alerts have been re-enabled')
		else
			windower.add_to_chat (167, 'wst: filters/alerts are temporarily disabled')
		end
		return
	end

	-- Toggle pet filter
	if (cmd == 'pet') then
		settings.filter_pets = not settings.filter_pets
		save_settings()
		if (settings.filter_pets) then
			windower.add_to_chat (167, 'wst pet: filtering of common mob pets has been re-enabled')
		else
			windower.add_to_chat (167, 'wst pet: filtering of common mob pets has been disabled')
		end
		update_area_info()
		return
	end
	
	-- List All Global settings
	if (cmd == 'lg') then
		windower.add_to_chat (207, 'wst lg: Global filters: %s':format(settings.global.filters:tostring()))
		windower.add_to_chat (207, 'wst lg: Global alerts: %s':format(settings.global.alerts:tostring()))
		return
	end
	
	-- List combined settings
	if (cmd == 'lc') then
		windower.add_to_chat (207, 'wst lc: combined filters applied to %s: %s':format(zone_name, combined_filters:tostring()))
		windower.add_to_chat (207, 'wst lc: combined alerts applied to %s: %s':format(zone_name, combined_alerts:tostring()))
		return
	end
	
	-- List All settings in current area
	if (cmd == 'la') then
		if (settings.area.filters:containskey(zone_id)) then
			windower.add_to_chat (207, 'wst lr: Filters for \"%s\": %s':format (zone_name, settings.area.filters[zone_id]:tostring()))
		else
			windower.add_to_chat (207, 'wst lr: Filters for \"%s\": {}':format (zone_name))
		end
		if (settings.area.alerts:containskey(zone_id)) then
			windower.add_to_chat (207, 'wst lr: Alerts for \"%s\": %s':format (zone_name, settings.area.alerts[zone_id]:tostring()))
		else
			windower.add_to_chat (207, 'wst lr: Alerts for \"%s\": {}':format (zone_name))
		end
		return
	end
	
	-- List All Area Filters
	if (cmd == 'laaf') then
		windower.add_to_chat (200, 'wst larf: Listing ALL area Filters')
		for i,_ in pairs (settings.area.filters) do
			local area_name = zones[i].name
			windower.add_to_chat (207, 'wst larf: Filters for \"%s\": %s':format(area_name, settings.area.filters[i]:tostring()))
		end
		return
	end
	
	-- List All Area Alerts
	if (cmd == 'laaa') then
		windower.add_to_chat (200, 'wst lara: Listing ALL area Alerts')
		for i,_ in pairs (settings.area.alerts) do
			local area_name = zones[i].name
			windower.add_to_chat (207, 'wst lara: Alerts for \"%s\": %s':format(area_name, settings.area.alerts[i]:tostring()))
		end
		return
	end
	
	-- Need more args from here on
	if (args:length() < 1) then
		show_syntax()
		return
	end
	
	-- Name or pattern to use
	-- concat for multi word names, remove ',' and '"', remove extra spaces
	local input = args:concat(' '):lower():stripchars(',"'):spaces_collapse()
	
	-- only accept patterns with a-z, A-Z,0-9, spaces, "'", "-" and "."
	if (input == nil or not windower.regex.match(input, "^[a-zA-Z0-9 '-.]+$")) then
		windower.add_to_chat (167, "wst: Rejecting pattern. Invalid characters in pattern")
		return
	end
	
	local pattern = "%s":format(input)
	
	-- Add Global Filter
	if (cmd == 'agf') then
		windower.add_to_chat (200, 'wst agf: Adding: \"%s\" to Global Filters':format(pattern))
		settings.global.filters:add("%s":format(pattern))
		windower.add_to_chat (207, 'wst agf: Current global filters: %s':format(settings.global.filters:tostring()))
		save_settings()
		return
	end
	-- Remove Global Filter
	if (cmd == 'rgf') then
		windower.add_to_chat (200, 'wst rgf: Removing \"%s\" from Global Filters':format(pattern))
		settings.global.filters:remove("%s":format(pattern))
		windower.add_to_chat (207, 'wst rgf: Current global filters: %s':format(settings.global.filters:tostring()))
		save_settings()
		return
	end
	-- Add Global Alert
	if (cmd == 'aga') then
		windower.add_to_chat (200, 'wst aga: Adding: \"%s\" to Global Alerts':format(pattern))
		settings.global.alerts:add("%s":format(pattern))
		windower.add_to_chat (207, 'wst aga: Current global alerts: %s':format(settings.global.alerts:tostring()))
		save_settings()
		return
	end
	-- Remove Global Alert
	if (cmd == 'rga') then
		windower.add_to_chat (200, 'wst rga: Removing \"%s\" from Global Alerts':format(pattern))
		settings.global.alerts:remove("%s":format(pattern))
		windower.add_to_chat (207, 'wst rga: Current global alerts: %s':format(settings.global.alerts:tostring()))
		save_settings()
		return
	end
	-- Add Area Filter
	if (cmd == 'aaf') then
		windower.add_to_chat (200, 'wst arf: Adding: \"%s\" to area Filters for %s':format(pattern, zone_name))
		if (not settings.area.filters:containskey(zone_id)) then
			settings.area.filters[zone_id] = S{}
		end
		settings.area.filters[zone_id]:add("%s":format(pattern))
		windower.add_to_chat (207, 'wst arf: Current filters for \"%s\": %s':format(zone_name, settings.area.filters[zone_id]:tostring()))
		save_settings()
		return
	end
	-- Remove Area Filter
	if (cmd == 'raf') then
		windower.add_to_chat (200, 'wst rrf: Removing: \"%s\" from area Filters for %s':format(pattern, zone_name))
		if (settings.area.filters:containskey(zone_id)) then
			settings.area.filters[zone_id]:remove("%s":format(pattern))
			windower.add_to_chat (207, 'wst rrf: Current filters for \"%s\": %s':format(zone_name, settings.area.filters[zone_id]:tostring()))
			save_settings()
		end
		return
	end
	-- Add Area Alert
	if (cmd == 'aaa') then
		windower.add_to_chat (200, 'wst ara: Adding: \"%s\" to area Alerts for %s':format(pattern, zone_name))
		if (not settings.area.alerts:containskey(zone_id)) then
			settings.area.alerts[zone_id] = S{}
		end
		settings.area.alerts[zone_id]:add("%s":format(pattern))
		windower.add_to_chat (207, 'wst ara: Current alerts for \"%s\": %s':format(zone_name,settings.area.alerts[zone_id]:tostring()))
		save_settings()
		return
	end
	-- Remove Area Alert
	if (cmd == 'raa') then
		windower.add_to_chat(200, 'wst rra: Removing: \"%s\" from area Alerts for %s':format(pattern, zone_name))
		if (settings.area.alerts:containskey(zone_id)) then
			settings.area.alerts[zone_id]:remove("%s":format(pattern))
			windower.add_to_chat (207, 'wst rra: Current alerts for \"%s\": %s':format(zone_name,settings.area.alerts[zone_id]:tostring()))
			save_settings()
		end
		return
	end
	
	-- Show Syntax
	show_syntax()
end

function update_area_info()
	zone_id = windower.ffxi.get_info().zone
	zone_name = zones[windower.ffxi.get_info().zone].name
	
	combined_alerts = settings.global.alerts
	combined_filters = settings.global.filters
	
	if (settings.area.alerts:containskey(zone_id)) then
		combined_alerts = combined_alerts:union(settings.area.alerts[zone_id])
	end
	if (settings.area.filters:containskey(zone_id)) then
		combined_filters = combined_filters:union(settings.area.filters[zone_id])
	end
	if (settings.filter_pets) then
		combined_filters = combined_filters:union(pet_filters)
	end
end

-- Process incoming packets
function wst_process_packets (id, original, modified, injected, blocked)
	-- Process widescan replies
	if (enable_mode and id==0xF4) then
		local p = packets.incoming(id, original)
		local short_name = p['Name']
		local index = p['Index']
		local ID = 0x01000000 + (4096 * zone_id) + index
		local official_name = mob_names[ID]
		local name_to_match = official_name or short_name;
		
		if (name_to_match == nil) then return end
		name_to_match = name_to_match:lower()			
			
		-- Process filters
		for i,_ in pairs (combined_filters) do
			if (name_to_match:match("%s":format(i))) then
				return true
			end
		end
		
		-- Process alerts
		for i,_ in pairs (combined_alerts) do
			if (name_to_match:match("%s":format(i))) then
				windower.add_to_chat(167, 'wst alert: %s detected!!':format(official_name))
				return
			end
		end
	end
end

-- Register callbacks
windower.register_event ('addon command', wst_command)
windower.register_event ('incoming chunk', wst_process_packets)
windower.register_event ('zone change', update_area_info)
windower.register_event ('load', update_area_info:cond(function() return windower.ffxi.get_info().logged_in end))

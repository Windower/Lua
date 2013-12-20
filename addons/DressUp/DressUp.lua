-- Copyright (c) 2013, Cairthenn
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of DressUp nor the
      -- names of its contributors may be used to endorse or promote products
      -- derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL Cairthenn BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'DressUp'
_addon.author = 'Cairthenn'
_addon.version = '0.95'
_addon.commands = {'DressUp','du'}

--Libs
packets = require('packets')
config = require('config')
file = require('filehelper')
require('luau')

--DressUp files


require('helper_functions')
require('static_variables')
models = {}
require('head')
require('body')
require('hands')
require('legs')
require('feet')

windower.register_event('load',function ()
	settings = config.load(defaults)
	print_blink_settings("global")
	zone_reset = 2
	keyset = {}
	for k,v in pairs(models) do
	keyset[k] = {}
		i = 0
		for sub_k,sub_v in pairs(v) do
			i = i + 1
			keyset[k][i] = sub_k
		end
	end
end)

-- Allows for the model to be restored to desired settings after zoning if blink prevention is on:
windower.register_event('outgoing chunk',function (id, data) if id == 0x5e then zone_reset = 0 end end)

windower.register_event('incoming chunk',function (id, data)
	if id == 0x51 then
		parsed_self = packets.parse("incoming",id,data)

		local self = T{}
		self["Header"] =  string.sub(data,1,4)
		self["Face"] =    string.sub(data,5,5)
		self["Race"] =    string.sub(data,6,6)
		self["Head"] =    string.sub(data,7,8)
		self["Body"] =    string.sub(data,9,10)
		self["Hands"] =   string.sub(data,11,12)
		self["Legs"] =    string.sub(data,13,14)
		self["Feet"] =    string.sub(data,15,16)
		self["Main"] =    string.sub(data,17,18)
		self["Sub"] =     string.sub(data,19,20)
		self["Ranged"] =  string.sub(data,21,22)
		self["unknown"] = string.sub(data,23,24)
		
		for k,v in pairs(parsed_self) do
			if T{"Face","Race","Head","Body","Hands","Legs","Feet","Main","Sub","Ranged"}:contains(k) and v ~= 0 then
				if settings.self[k:lower()] and settings.self[k:lower()] > 0 then
					self[k] = Int2LE(settings.self[k:lower()],k)
					return_packet = true
				elseif table.containskey(settings.replacements[k:lower()],tostring(v)) then
					self[k] = Int2LE(settings.replacements[k:lower()][tostring(v)],k)
					return_packet = true
				end
			end
		end
			
		self_Build =  self["Header"]..self["Face"]..self["Race"]..self["Head"]..self["Body"]..self["Hands"]..
					  self["Legs"]..self["Feet"]..self["Main"]..self["Sub"]..self["Ranged"]..self["unknown"]
			
		if do_blink_logic("self_special") then
			if zone_reset > 1 then
				self_Build = true
			else
				zone_reset = zone_reset + 1
			end
		end
		-- Model ID 0xFFFF in ranged slot signifies a monster. This prevents undesired results.
		if parsed_self["Ranged"] ~= 65535 then
			return self_Build
		end
	elseif id == 0x00d then
		local return_packet = false
			parsed_pc = packets.parse("incoming",id,data)
		
			local pc = T{}
			pc["Header"] = string.sub(data,1,4)
			pc["Begin"] =  string.sub(data,5,68)
			pc["Face"] =   string.sub(data,69,69)
			pc["Race"] =   string.sub(data,70,70)
			pc["Head"] =   string.sub(data,71,72)
			pc["Body"] =   string.sub(data,73,74)
			pc["Hands"] =  string.sub(data,75,76)
			pc["Legs"] =   string.sub(data,77,78)
			pc["Feet"] =   string.sub(data,79,80)
			pc["Main"] =   string.sub(data,81,82)
			pc["Sub"] =    string.sub(data,83,84)
			pc["Ranged"] = string.sub(data,85,86)
			pc["End"] =    string.sub(data,87)		
			
			character = windower.ffxi.get_mob_by_index(parsed_pc["Index"])
			
			-- Name is used to check for custom model settings, blink_type is similar but passes arguments to blink logic.
			
			if character then
				if windower.ffxi.get_player().follow_index == character.index then
					blink_type = "follow"
				elseif table.contains(make_party_ids(),parsed_pc["ID"]) then
					blink_type = "party"
				else
					blink_type = "others"
				end
				
				if character.name == windower.ffxi.get_player().name then
					name = "self"
					blink_type = "self"
				elseif settings[character.name:lower()] then
					name = character.name:lower()
				else
					name = "others"
				end
			else
				name = "others"
			end
			
			
			for k,v in pairs(parsed_pc) do
				if T{"Face","Race","Head","Body","Hands","Legs","Feet","Main","Sub","Ranged"}:contains(k) and v ~= 0 then
					if settings[name][k:lower()] and settings[name][k:lower()] > 0 then
						pc[k] = Int2LE(settings[name][k:lower()],k)
						return_packet = true
					elseif table.containskey(settings.replacements[k:lower()],tostring(v)) then
						pc[k] = Int2LE(settings.replacements[k:lower()][tostring(v)],k)
						return_packet = true
					end
				end
			end
			
			pc_Build = pc["Header"]..pc["Begin"]..pc["Face"]..pc["Race"]..pc["Head"]..pc["Body"]..pc["Hands"]..
			           pc["Legs"]..pc["Feet"]..pc["Main"]..pc["Sub"]..pc["Ranged"]..pc["End"]
	
			
			--Begin blinking region
			if not blink_type then
				blink_type = "others"
			end
			
			if settings.blinking["all"]["target"] or settings.blinking["all"]["always"] or settings.blinking["all"]["combat"] then
				if character then
					if table.contains(model_mask,parsed_pc["Mask"]) then
						if settings.blinking["all"]["always"] then
							pc_Build = true
							return_packet = true
						elseif settings.blinking["all"]["combat"] and windower.ffxi.get_player().in_combat then
							pc_Build = true
							return_packet = true
						elseif settings.blinking["all"]["target"] and windower.ffxi.get_player().target_index == character.index then
							pc_Build = true
							return_packet = true
						end
					end
				end
			end
			if settings.blinking[blink_type]["target"] or settings.blinking[blink_type]["always"] or settings.blinking[blink_type]["combat"] then
				if character then
					if table.contains(model_mask,parsed_pc["Mask"]) then
						if settings.blinking[blink_type]["always"] and do_blink_logic("always") then
							pc_Build = true
							return_packet = true
						elseif settings.blinking[blink_type]["combat"] and do_blink_logic("combat") then
							pc_Build = true
							return_packet = true
						elseif settings.blinking[blink_type]["target"] and do_blink_logic("target",character.index) then
							pc_Build = true
							return_packet = true
						end
					end
				end
			end
			
			--End blinking region
			
			-- Prevents superfluous returning of the PC Update packet by only doing so if the requirements are flagged
			if return_packet then
				if parsed_pc["Ranged"] ~= 65535 then
					return pc_Build
				end
			end
	end
end
)

windower.register_event('addon command', function (...)
	local args = {...};
	if #args < 1 then
		return
	end
	if args[1] then
		if args[1]:lower() == "help" then
			print(helptext)
		elseif T{"self","others","player"}:contains(args[1]:lower())  then
			du_type = args[1]:lower()
				if du_type == "player" then
					offset = 1
					du_type = args[2]:lower()
					if not settings[du_type] then
						settings[du_type] = {}
					end
				else
					offset = 0
				end
			if args[2+offset] then
				selection = args[2+offset]:lower()
			end
			if T{"head","body","hands","legs","feet","main","sub","ranged","race","face"}:contains(selection) then	
				if selection == "race" then
					if args[3+offset] then 
						if table.containskey(_races,args[3+offset]:lower()) then
							if args[3+offset]:lower() == "galka" or args[3+offset]:lower() == "mithra" then
								settings[du_type]["race"] = _races[args[3+offset]:lower()]
							else
								if args[4+offset] then
									if T{"male","female","m","f"}:contains(args[4+offset]:lower()) then
										settings[du_type]["race"] = _races[args[3+offset]:lower()][args[4+offset]:lower()]
									else
										error("Specify male or female.")
									end
								else
									error("Specify male or female.")
								end
							end
						elseif T{0,1,2,3,4,5,6,7,8}:contains(tonumber(args[3+offset])) then
							settings[du_type]["race"] = tonumber(args[3+offset])
						else
							error("That is not a valid selection.")
						end
					else
						error("Specify a race.")
					end
				elseif selection == "face" then
					if args[3+offset] then 
						if table.containskey(_faces,args[3+offset]:lower()) then
							settings[du_type]["face"] = _faces[args[3+offset]:lower()]
						elseif T{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,29,30}:contains(tonumber(args[3+offset])) then
							settings[du_type]["face"] = tonumber(args[3+offset])
						else
							error("That is not a valid selection.")
						end
					else
						error("Specify a face.")
					end
				elseif args[3+offset] then
					if tonumber(args[3+offset]) then
						item_id = tonumber(args[3+offset])
					else
						item_id = get_item_id(args[3+offset]:lower(),selection)
					end
							if item_id then 
								if table.containskey(models[selection],item_id) then
									if models[selection][item_id] == ' ' then 
										error("That item has not been identified.")
									else
										settings[du_type][selection] = models[selection][item_id].model
									end
								else
									error("That is not the correct item type.")
								end
							else
								error("Item not recognized.")
							end
				else
					error("No item entered.")
				end
			else
				error("That is not a valid selection.")
			end
		elseif args[1]:lower() == "replace" then
			item_ids = {}
			model_ids = {}
			if args[2] then
				selection = args[2]:lower()
			else
				error("Specify something to replace.")
			end
			if T{"head","body","hands","legs","feet","main","sub","ranged","race","face"}:contains(selection) then	
				if selection == "race" then	
					if args[3] then 
						if table.containskey(_races,args[3]:lower()) then                           			
							if args[3]:lower() == "galka" or args[3]:lower() == "mithra" then     			
								model_ids[1] = _races[args[3]:lower()]                              			
								if args[4] then
									if table.containskey(_races,args[4]:lower()) then
										if args[4]:lower() == "galka" or args[4]:lower() == "mithra" then 
											model_ids[2] = _races[args[4]:lower()]
											settings.replacements.race[tostring(model_ids[1])] = model_ids[2]
										elseif args[5] then
											if T{"male","female","m","f"}:contains(args[5]:lower()) then
												model_ids[2] = _races[args[4]:lower()][args[5]:lower()]
												settings.replacements.race[tostring(model_ids[1])] = model_ids[2]
											else
												error("Specify male or female for second race.")
											end
										else
											error("Specify male or female for second race.")
										end
									else
										error("Replacement race not recognized.")
									end
								else
									error("Replacement race not specified.")
								end
							elseif args[4] then
								if T{"male","female","m","f"}:contains(args[4]:lower()) then
									model_ids[1] = _races[args[3]:lower()][args[4]:lower()]
									if args[5] then
										if table.containskey(_races,args[5]:lower()) then
											if args[5]:lower() == "galka" or args[5]:lower() == "mithra" then 
												model_ids[2] = _races[args[5]:lower()]
												settings.replacements.race[model_ids[1]] = model_ids[2]
											elseif args[6] then
												if T{"male","female","m","f"}:contains(args[6]:lower()) then
													model_ids[2] = _races[args[5]:lower()][args[6]:lower()]
													settings.replacements.race[tostring(model_ids[1])] = model_ids[2]
												else
													error("Specify male or female for second race.")
												end
											else
												error("Specify male or female for second race.")
											end
										else
											error("Replacement race not recognized.")
										end
									else
										error("Replacement race not specified.")
									end
								else
									error("Specify male or female for first race.")
								end
							else
									error("Specify male or female for first race.")
							end
						elseif T{1,2,3,4,5,6,7,8}:contains(tonumber(args[3])) then
							model_ids[1] = tonumber(args[3])
								if args[4] then
									if T{1,2,3,4,5,6,7,8}:contains(tonumber(args[4])) then
										model_ids[2] = tonumber(args[4])
										settings.replacements.race[tostring(model_ids[1])] = model_ids[2]
									else
										error("That is not a valid selection for the second race.")
									end
								else
									error("Replacement race not specified.")
								end
						else
							error("That is not a valid selection for the first race.")
						end
					else
						error("Specify a first race.")
					end
				elseif selection == "face" then
					if args[3] then 
						if table.containskey(_faces,args[3]:lower()) then
							model_ids[1] = _faces[args[3]:lower()]
							if args[4] then
								if table.containskey(_faces,args[4]:lower()) then
									model_ids[2] = _faces[args[4]:lower()]
									settings.replacements.face[tostring(model_ids[1])] = model_ids[2]
								else
									error("That is not a valid selection for the first second face.")
								end
							else
								error("Specify a replacement face.")
							end
						elseif T{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,29,30}:contains(tonumber(args[3])) then
							model_ids[1] = tonumber(args[3])
							if args[4] then
								if T{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,29,30}:contains(tonumber(args[4])) then
									model_ids[2] = tonumber(args[4])
									settings.replacements.face[tostring(model_ids[1])] = model_ids[2]
								else
									error("That is not a valid selection for the first second face.")
								end
							else
								error("Specify a replacement face.")
							end
						else
							error("That is not a valid selection for the first face.")
						end
					else
						error("Specify a first face.")
					end
				elseif args[3] then
					if tonumber(args[3]) then
						item_ids[1] = tonumber(args[3])
					else
						item_ids[1] = get_item_id(args[3]:lower(),selection)
					end
					if args[4] then
						if tonumber(args[4]) then
							item_ids[2] = tonumber(args[4])
						else
							item_ids[2] = get_item_id(args[4]:lower(),selection)
						end
					else
						error("Specify a replacement item.")
						return
					end
							if item_ids[1] and item_ids[2] then
								for k,v in pairs(item_ids) do
									if table.containskey(models[selection],item_ids[k]) then
										if models[selection][item_ids[k]] == ' ' then 
											error("Item not identified: "..k)
											return
										else
											models[k] = models[selection][item_ids[k]].model
										end
									else
										error("Item "..k.." is not the correct item type.")
										return
									end
								end
							elseif not item_ids[1] then
								error("First item not recognized.")
							else
								error("Second item not recognized.")
							end
						if models[1] and models[2] then
							settings.replacements[selection][tostring(models[1])] = models[2]
						end
				else
					error("No item entered.")
				end
			else
				error("That is not a valid selection.")
			end
		elseif args[1]:lower() == "clear" then
			if args[2] then
				if T{"replace","self","others","player"}:contains(args[2]:lower()) then
					clear_type = args[2]:lower()
					if clear_type == "replace" then
						if args[3] then
							if T{"face","race","head","body","hands","legs","feet","main","sub","ranged"}:contains(args[3]:lower()) then
								if args[4] then
									if settings.replacements[args[3]:lower()][args[4]] then
										settings.replacements[args[3]:lower()][args[4]] = nil
									else
										error("Invalid selection.")
									end
								else
									settings.replacements[args[3]:lower()] = {}
								end
							else
								error("Invalid selection.")
							end
						else
							settings.replacements = { face = {}, race = {}, head = {}, body = {}, hands = {}, 
													legs = {}, feet = {}, main = {}, sub = {}, ranged = {} }
						end
					else
						if clear_type == "player" then
							offset = 1
							if args[3] then
								clear_type = args[3]:lower()
							else 
								error("Specify a player to clear.") 
								return 
							end
						else 
							offset = 0	
						end
					
						if args[3+offset] then
							if T{"face","race","head","body","hands","legs","feet","main","sub","ranged"}:contains(args[3+offset]:lower()) then
								settings[clear_type][args[3+offset]] = nil
							else 
								error("Invalid selection.")
							end
						else
							if settings[clear_type] then
								settings[clear_type] = {}
							else
								error("No settings exist for the selection.")
							end
						end
					end
				else
					error("Valid selections for clear are 'replace', 'self', 'others', and 'player'.")
				end
			else
				error("Valid selections for clear are 'replace', 'self', 'others', and 'player'.")
			end
		elseif T{"blinking","bmn","blinkmenot"}:contains(args[1]:lower()) then
			if not args[2] or args[2]:lower() == "settings" then
				print_blink_settings("global")
			elseif args[2] and T{"self","others","party","all","follow"}:contains(args[2]:lower()) and args[3] and T{"target","always","combat","all"}:contains(args[3]:lower()) then
				if args[4] and T{"off","on"}:contains(args[4]:lower()) then
					if args[4]:lower() == "on" then
						blink_bool = true
					else
						blink_bool = false
					end
					if args[3]:lower() == "all" then 
						settings.blinking[args[2]]["target"] = blink_bool
						settings.blinking[args[2]]["always"] = blink_bool
						settings.blinking[args[2]]["combat"] = blink_bool
					else
						settings.blinking[args[2]][args[3]] = blink_bool
					end
					print_blink_settings(args[2]:lower())
				else
					if args[3]:lower() == "all" then 
						error("Specify [on/off] if using all.")
					else
						settings.blinking[args[2]][args[3]] = not settings.blinking[args[2]][args[3]]
						print_blink_settings(args[2]:lower())
					end
				end
			else
				error("Invalid selections for blinking.")
			end
		elseif args[1]:lower() == "debug" then	
			if args[2] and T{"face","race","head","body","hands","legs","feet","main","sub","ranged"}:contains(args[2]:lower()) then
				if args[3] then
					settings.self[args[2]:lower()] = tonumber(args[3])
				end
			end
		elseif args[1]:lower() == "unload" then
			windower.send_command('lua unload dressup')
		end
	end
	config.save(settings,windower.ffxi.get_player().name)
end)

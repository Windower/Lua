--[[

Copyright © 2016, Sammeh of Quetzalcoatl
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Snub nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sammeh BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]


_addon.name = 'Snub'
_addon.author = 'Sammeh'
_addon.version = '1.8'
_addon.command = 'snub'

require 'tables'
require 'sets'
require 'strings'
require 'actions'
require 'pack'
require 'logger'
require 'chat'
config = require('config')

packets = require('packets')
files = require 'files'
res = require 'resources'

debugmode = 0

-- Version History
-- 1.0 release
-- 1.1 Added long-name additions.
-- 1.2 Added snubbing of 'Throw Away' chat spam if it matches a snubbed item.  Parses chat log which is kind of ugly, but functional. If you throw away multiple of an item - depending on how SE spelled the plurality I'm trying my best to catch it.  
-- 1.3 Added //snub import  (Imports DROP list from Treasury XML)
-- 1.4 Moving snub to chat log exclusive vs packets.
-- 1.5 Added in ROE  and EXP/CP Chain Filter     //snub roe    and  //snub exp
-- 1.6 Changed snub import.  //snub import passlist  (Pass list)  or //snub import droplist
-- 1.7 Bug fixes (Error on startup when no character loaded, and snub list since adding ROE/EXP snubs)
-- 1.8 Apparently negelected to realize I put ROE/EXP snub as a local variable on startup and not global so it wasn't saving in later functions.. Fixed.


-- Create config file
if windower.ffxi.get_player() then 
 local self = windower.ffxi.get_player()
 custom_snub_file = files.new('snub_'..self.name..'.lua')
 if custom_snub_file:exists() then
   windower.add_to_chat(2,'Snub: Loading File: snub_'..self.name..'.lua')
 else
   windower.add_to_chat(2,'Snub: New Character Detected, Creating file: snub_'..self.name..'.lua')
   snub = T{}
   custom_snub_file:write('return ' .. T(snub):tovstring())
 end
custom_snubs = require('snub_'..self.name)
end

if custom_snubs then 
	roeblock = custom_snubs["roeblock"] 
	expblock = custom_snubs["expblock"] 
end

-- Treasury Addon Search / Use for Import
treasury_found = 0
treasury_config_file = files.new('../Treasury/data/settings.xml')
if treasury_config_file:exists() then
	treasury_found = 1
end


-- Watch for Items to Snub
windower.register_event('incoming text', function(original, modified, original_mode, modified_mode, blocked)
	-- print(original,original_mode)
    if blocked or text == '' then
        return
    end
	if (original_mode == 121 or original_mode == 127) and original:match(string.char(0x1e, 0x02)) then
		local itemraw = original:split(string.char(0x1e, 0x02))
		itemraw = itemraw[2]:split(string.char(0x01))
		local current_item = itemraw[1]:strip_format():lower()
		current_item = string.sub(current_item,0,-2)  -- stripping off any bad formatting.
		
		local resitem = validate(current_item)
		
		if not resitem then 
			local current_item_plural = string.sub(current_item,0,-2) -- truncating the 's' in plural drops - probably better way but haven't found it and try again.
			resitem = validate(current_item_plural)
		end
		
		if resitem then 
			local customsnubitem = search_snubs(resitem.id)
			if customsnubitem then
				if debugmode == 1 then 
					if original_mode == 121 then 
						if original:match("find") then 
							windower.add_to_chat(10,"Snub: Found String:"..current_item)
						elseif original:match("obtain") then
							windower.add_to_chat(10,"Snub: Obtain String:"..current_item)
						elseif original:match("throw away") then
							windower.add_to_chat(10,"Snub: Throw Away String:"..current_item)
						else 
							return false
						end
					elseif original_mode == 127 then
						windower.add_to_chat(10,"Snub: Obtained:"..current_item)
					end
				end
				return true
			end
		else
			if debugmode == 1 then
				windower.add_to_chat(10,"Snub: Item not found in Windower resources database. Item: "..current_item)
			end
		end
	elseif original_mode == 127 and (original:match("Records of Eminence") or original:match("Progress:") or original:match("This objective may be repeated")) then -- ROE Matching
		if roeblock then
			if debugmode == 1 then 
				windower.add_to_chat(10,"Snub: ROE Message:"..original)
			end
			return true
		end
	elseif original_mode == 131 and (original:match("Limit chain") or original:match("Capacity chain") or original:match("limit points") or original:match("capacity points")) then  -- EXP/CP Messages	
	    if expblock then
			if debugmode == 1 then 
				windower.add_to_chat(10,"Snub: EXP/CP Message:"..original)
			end
			return true
		end
	end
end)



windower.register_event('addon command', function(...)
	local args = T{...}
	local cmd = args[1]
	args:remove(1)
	local item = table.concat(args," "):lower()
	local snubitem = validate(item)
	if cmd == "add" then
		if snubitem then
			windower.add_to_chat(10,"Snubbing Item: "..snubitem.en)
			if custom_snubs[snubitem.id] then
				windower.add_to_chat(10,item.." is already added.")
			else 
				custom_snubs[snubitem.id] = {id=snubitem.id, en=snubitem.en}
			end
		else
			windower.add_to_chat(10,"Could not find Item: "..item)
		end
		custom_snub_file:write('return ' .. T(custom_snubs):tovstring())
	elseif cmd == "remove" then
		if snubitem then
			if custom_snubs[snubitem.id] then
				windower.add_to_chat(10,"Removing Snub Item: "..snubitem.en)
				remove_snub(snubitem.id)
			else
				windower.add_to_chat(10,"Item was not in Snub List: "..snubitem.en)
			end
		else
			windower.add_to_chat(10,"Could not find Item: "..item)
		end
	elseif cmd == "print" or cmd == "list" then
		print_snubs()
	elseif cmd == "help" then
		windower.add_to_chat(10,"Snub Params:  ")
		windower.add_to_chat(10,"//snub add \"Item\"              -- Adds an item to ignore list")
		windower.add_to_chat(10,"//snub remove \"Item\"           -- Removes an item to ignore list")
		windower.add_to_chat(10,"//snub print (or) list           -- Prints ignore list")
		windower.add_to_chat(10,"//snub roe                       -- Turns on/off ROE Filter")
		windower.add_to_chat(10,"//snub exp                       -- Turns on/off EXP Filter")
		windower.add_to_chat(10,"//snub import passlist|droplist  -- Imports Treasury Addon List - Caution freezes a moment")
		windower.add_to_chat(10,"//snub debug                     -- Debugs an ignore")
	elseif cmd == "import" then
		import_treasury(item)
	elseif cmd == "debug" then
		if debugmode == 0 then
			debugmode = 1
			windower.add_to_chat(10,"Snub: DEBUGGING ON")
		elseif debugmode == 1 then
			debugmode = 0
			windower.add_to_chat(10,"Snub: DEBUGGING OFF")
		end
	elseif cmd == "roeblock" or cmd == "roe" then
		if roeblock then
			windower.add_to_chat(10,"Snub: Turning OFF ROE Progress Filter")
			custom_snubs["roeblock"] = nil
		else
			windower.add_to_chat(10,"Snub: Turning ON ROE Progress Filter")
			custom_snubs["roeblock"] = "1"
		end
		roeblock = custom_snubs["roeblock"]
		custom_snub_file:write('return ' .. T(custom_snubs):tovstring())
	elseif cmd == "expblock" or cmd == "exp" then
	    if expblock then
			windower.add_to_chat(10,"Snub: Turning OFF EXP/CP Filter")
			custom_snubs["expblock"] = nil
		else
			windower.add_to_chat(10,"Snub: Turning ON EXP/CP Filter")
			custom_snubs["expblock"] = "1"
		end
		expblock = custom_snubs["expblock"]
		custom_snub_file:write('return ' .. T(custom_snubs):tovstring())
	end
end)

-- Search custom_snub table for Snubs
function search_snubs(id)
	for index,snubitem in pairs(custom_snubs) do
		if snubitem then 
			if snubitem ~= "1" then 
				if snubitem.id == id then
					return true
				end
			end
		end
	end
end

-- Remove Snubbed items from Table.
function remove_snub(id)
	custom_snubs[id] = nil
end


--- Print List of Snubs
function print_snubs()
	windower.add_to_chat(10,"----Snubbed Items----")
	for index,snubitem in pairs(custom_snubs) do
		local currentsnub = res.items[index]
		if currentsnub then
			windower.add_to_chat(10,currentsnub.en)
		end
	end
end


-- Validate Item is in Resources
function validate(item)
   for i,v in pairs(res.items) do
	 if string.lower(v.en) == item or string.lower(v.enl) == item then
		return v
	 end
	end
end

-- Import Treasury
function import_treasury(list)
	if not list:match("droplist") and not list:match("passlist") then
		print(list)
		windower.add_to_chat(2,"Snub: Import Syntax Error: Must be: //snub import passlist (or) //snub import droplist'")
	else
	if treasury_found == 1 then
		windower.add_to_chat(2,"Snub: Found Treasury File! Importing - this may freeze a couple seconds!")
		windower.add_to_chat(2,"Snub: Please note this is an Additive Import.  Not a Merge or Replace.")
		treasury_data = config.load('../Treasury/data/settings.xml')
		if treasury_data then 
			local treasury_drops = T{}
			if list:match("droplist") then 
				treasury_drops = treasury_data.drop:split( "," )
			end
			if list:match("passlist") then
				treasury_drops = treasury_data.pass:split( "," )
			end
			for index,value in pairs(treasury_drops) do
				if index ~= 'n' then 
					local value_lower = value:lower()
					local snubitem = validate(value_lower)
					if snubitem then
						if debugmode == 1 then 
							windower.add_to_chat(10,"Snubbing Item: "..snubitem.en)
						end
						if custom_snubs[snubitem.id] then
							if debugmode == 1 then
								windower.add_to_chat(10,value.." is already added.")
							end
						else 
							custom_snubs[snubitem.id] = {id=snubitem.id, en=snubitem.en}
						end
					else
						windower.add_to_chat(10,"Could not find snub item: "..value_lower..".")
					end
					custom_snub_file:write('return ' .. T(custom_snubs):tovstring())
				else
					windower.add_to_chat(10,"Snub: Imported "..value.." item(s).")
				end
			end
		end
	else 
		windower.add_to_chat(2,"Snub: Could not find Treasury File!")
	end
	end
end



windower.register_event('job change', function()
	
end)

windower.register_event('login', function()
	windower.send_command('lua r snub')    
end)

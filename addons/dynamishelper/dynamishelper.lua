--Copyright (c) 2013, Krizz
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--	* Redistributions of source code must retain the above copyright
--  	notice, this list of conditions and the following disclaimer.
--	* Redistributions in binary form must reproduce the above copyright
--  	notice, this list of conditions and the following disclaimer in the
--  	documentation and/or other materials provided with the distribution.
--	* Neither the name of Dynamis Helper nor the
--  	names of its contributors may be used to endorse or promote products
--  	derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL KRIZZ BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--Features
-- Stagger timer
-- Currency tracker
-- Proc identifier
-- Lot currency

_addon = _addon or {}
_addon.name = 'DynamisHelper'
_addon.version = 1.0

local config = require 'config'

-- Variables
Currency = {"ordelle bronzepiece","montiont silverpiece","one byne bill","100 byne bill","tukuku whiteshell", "lungo-nango jadeshell"}
StaggerCount = 0
goodzone = "no"
timer = "off"
tracker = "off"
proc = "off"
trposx = 1000
trposy = 250
pposx = 900
pposy = 250

local settings_file = 'data\\settings.xml'
if settings_file ~= '' then
 	local settings = config.load(settings_file)
 		timer = settings['timer']
 		tracker = settings['tracker']
 		trposx = settings['trposx']
 		trposy = settings['trposy']
 		proc = settings['proc']
 		pposx = settings['pposx']
 		pposy = settings['pposy']
end

for i=1, #Currency do
     Currency[Currency[i]] = 0
end

function event_load()
--	write('event_load function')
	send_command('alias dh lua c dynamishelper')
 	player = get_player()['name']
	proc = 'off'
 	write('Dynamis Helper loaded.  Author: Bahamut.Krizz')
 	initializebox()
end

function event_addon_command(...)
--	 write('event_addon_command function')
	local params = {...};
 	if #params < 1 then
		return
	end
	if params[1] then
 		if params[1]:lower() == "help" then
   			write('dh help : Shows help message')
  			write('dh timer [on/off] : Displays a timer each time a mob is staggered.')
   			write('dh tracker [on/off/reset/pos x y] : Tracks the amount of currency obtained.')
			--   write('dh proc [on/off] : Displays the current proc for the mob in dreamland zones')
   			write('dh ll create : Creates and loads a light luggage profile that will automatically lot all currency.')
		elseif params[1]:lower() == "timer" then
   			if params[2]:lower() == "on" or params[2]:lower() == "off" then
    				timer = params[2]
   			else write("Invalid timer option.")
   			end
		elseif params[1]:lower() == "tracker" then
   			if params[2]:lower() == "on" then
    				tracker = "on"
    				tb_set_visibility('dynamis_box',true)
      				write('Tracker enabled')
   			elseif params[2]:lower() == "off" then
    				tracker = "off"
    				tb_set_visibility('dynamis_box',false)
    				write('Tracker disabled')
   			elseif params[2]:lower() == "reset" then
	 			for i=1, #Currency do
     				Currency[Currency[i]] = 0
     			end
      			obtainedf()
      			initializebox()
      			write('Tracker reset')
		   	elseif params[2]:lower() == "pos" then
    				if params[3] then
     					trposx, trposy = tonumber(params[3]), tonumber(params[4])
     					obtainedf()
     					initializebox()
    				end		
    	    		else write("Invalid tracker option.")
    		end
	  	elseif params[1]:lower() == "ll" then
   			if params[2]:lower() == "create" then
	    			player = get_player()['name']
    				io.open(lua_base_path..'../../plugins/ll/dynamis-'..player..'.txt',"w"):write('if item is then lot'):close()
    				send_command('ll profile dynamis-'..player..'.txt')
   				else write("Invalid light luggage option.")
   			end
   		elseif params[1]:lower() == "proc" then
   			write('This feature is currently in progress.')
   		end
 	end
 end

function event_incoming_text(original, new, color)
--	write('event_incoming_text function')
	if timer == 'on' then
  		a,b,fiend = string.find(original,"%w+'s attack staggers the (%w+)%!")
   		if fiend == 'fiend' then
			StaggerCount = StaggerCount + 1
    		send_command('timers c '..StaggerCount..' 30 down')
    		return new, color
    	end
	end
 	if tracker == 'on' then
 		a,b,item = string.find(original,"%w+ obtains an? ..(%w+ %w+ %w+)..\46")
 		if item == nil then
 			a,b,item = string.find(original,"%w+ obtains an? ..(%w+%-%w+ %w+)..\46")
 	 		if item == nil then
 				a,b,item = string.find(original,"%w+ obtains an? ..(%w+ %w+)..\46")
 			end
 		end
 		if item ~= nil then
 		item = item:lower()
 			for i=1, #Currency do
				if item == Currency[i] then
   					Currency[Currency[i]] = Currency[Currency[i]] + 1
   				end
 			end
 		end
 	    obtainedf()
    	initializebox()
 	end
 	return new, color
end

function obtainedf()
 	obtained = ""
 	for i=1,#Currency do
   			obtained = (obtained..Currency[i]..': '..Currency[Currency[i]]..' \n')
 	end
end

function initializebox()
--	write('initializebox function')
	if obtained ~= nil and tracker == "on" then
 		tb_create('dynamis_box')
 		tb_set_bg_color('dynamis_box',200,30,30,30)
 		tb_set_color('dynamis_box',255,200,200,200)
		tb_set_location('dynamis_box',trposx,trposy)
 		tb_set_visibility('dynamis_box',true)
 		tb_set_bg_visibility('dynamis_box',1)
 		tb_set_font('dynamis_box','Arial',12)
 		tb_set_text('dynamis_box',' Currency obtained:  \n'..obtained);
 	end
end


function event_unload()
 	send_command("unalias dh")
 	tb_delete('dynamis_box')
end
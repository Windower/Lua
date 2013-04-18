--Copyright (c) 2013, Thomas Rogers / Balloon - Cerberus and Krizz
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of cellhelp nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL THOMAS ROGERS OR KRIZZ BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon = _addon or {}
_addon.name = 'cellhelp'
_addon.version = 0.1


local config = require 'config'


require 'tablehelper'
require 'stringhelper'
require 'mathhelper'
require 'logger'
require 'actionhelper'
-----------------------------

local settingtab = nil
local settings_file = 'data\\settings.xml'
local settingtab = config.load(settings_file)
if settingtab == nil then
	write('No settings file found. Ensure you have a file at data\\settings.xml')
end
--variables
	lotorder = ''
	set = "set1"
	mode = "lot"
	posx = 1000
	posy = 250
	if settingtab['posx'] ~= nil then
		posx = settingtab['posx']
		posy = settingtab['posy']
	end	
	itemcount = 0
	salvage_cell_name = {
		'incus cell','castellanus cell','undulatus cell','cumulus cell','radiatus cell','virga cell','cirrocumulus cell','stratus cell','duplicatus cell','opacus cell', 'praecipitatio cell', 'humilus cell','spissatus cell', 'pannus cell', 'fractus cell','congestus cell',  'nimbus cell', 'velum cell','pileus cell', 'mediocris cell'
	}
	salvage_cell_name_short = {
		'incus','castellanus','undulatus','cumulus','radiatus','virga','cirrocumulus','stratus','duplicatus','opacus', 'praecipitatio', 'humilus','spissatus', 'pannus', 'fractus','congestus','nimbus','velum','pileus', 'mediocris', 'alex'
	}
	salvage_cell_ident = { 
		'Weapons and Shields', 'Head and Neck', 'Ranged and Ammo', 'Body', 'Hand', 'Earring and Ring', 'Back and Waist', 'Legs and Feet', 'Support Job','Job and Weaponskill', 'Magic', 'HP', 'MP', 'STR', 'DEX', 'VIT', 'AGI', 'INT', 'MND', 'CHR'
	} 
	cells_id = { 
		'5365','5366','5371','5367','5368','5372','5370','5369','5373','5374','5375','5383','5384','5376','5377','5378','5379','5380','5381','5382','2488,5735,5736'
	}
	cell_lots ={
		'incus','castellanus','undulatus','cumulus','radiatus','virga','cirrocumulus','stratus','duplicatus','opacus', 'praecipitatio', 'humilus','spissatus', 'pannus', 'fractus','congestus','nimbus','velum','pileus', 'mediocris','alex'
	}
	players = {'player1', 'player2', 'player3', 'player4'}


function settings_create()
--	get player's name
	player = get_player()['name']
--	dynamic players from settings
	for i=1, #players do
		playernumber = players[i]
		players[players[i]] = settingtab[set][playernumber]['name']
		if players[players[i]] == player then
			player_num = players[i]
		end
	end

--  set lot positions
	for i=1, #salvage_cell_name_short  do 
			if salvage_cell_name_short[i] ~= nil then
	    		item = salvage_cell_name_short[i]
	    		cell_lots[item] = settingtab[set][item][player_num]
	    	end
	end
--	Populate lot order
	orderlots()
	
end

function event_addon_command(...)
	local params = {...};
	if #params < 1 then
		return
	end
	if params[1] then
		if params[1]:lower() == "help" then
			write('ch help : Shows help message')
			write('ch pos <x> <y> : Positions the list')
			write('ch hide : Hides the box')
			write('ch show : Shows the box')
			write('ch set [set id] : Loads set from settings file. Default is set1')
			write('ch mode [lots/nolots] : If mode is changed to nolots, ll will not lot cells automatically.')
		elseif params[1]:lower() == "pos" then
			if params[3] then
				local posx, posy = tonumber(params[2]), tonumber(params[3])
				tb_set_location('salvage_box', posx, posy)
			end
		elseif params[1]:lower() == "start" then
			initialize()
		elseif params[1]:lower() == "hide" then
			tb_set_visibility('salvage_box', false)
		elseif params[1]:lower() == "show" then
			tb_set_visibility('salvage_box', true)
		elseif params[1]:lower() == "set" then
			if params[2] then
				set = params[2]:lower()
				--Set variables from settings file
				settings_create()
				--Populate lot order
				orderlots()
				--Populate initial LL
				lightluggage()
				send_command('ll profile salvage-'..player..'.txt')
				initialize()
			end
		elseif params[1]:lower() == "mode" then
			if params[2] == "lots" then
				mode = params[2]:lower()
				write('Mode changed to: Cast lots')
				lightluggage()
			elseif params[2] == "nolots" then
				mode = params[2]:lower()
				write('Mode changed to: Do not cast lots')
				lightluggage()
			else write('Invalid mode option')
			end
		end			
	end
end

function event_load()
	send_command('alias ch lua c cellhelp')
	player = get_player()['name']
	write('CellHelp loaded.  CellHelp Authors: Cerberus.Balloon and Bahamut.Krizz')
	mode = settingtab["mode"]
	--Initial lot setting
	settings_create()
	--Populate initial LL
	lightluggage()
	send_command('ll profile salvage-'..player..'.txt')
	initialize()
end 

function event_login()
	player = get_player()['name']

end

function orderlots()
	lotorder = ""
--	for i,v in pairs(cell_lots) do write(i..' - '..v) end
	for i=1, #salvage_cell_name_short  do 
		if salvage_cell_name_short[i] ~= 'alex' and cell_lots[salvage_cell_name_short[i]] ~= 0 then
			item = salvage_cell_name_short[i]
			lotorder = (lotorder..item..': '..cell_lots[item]..' \n')
	    elseif salvage_cell_name_short[i] == 'alex' and cell_lots[salvage_cell_name_short[i]] ~= 0 then
	    	item = salvage_cell_name_short[i]
	    	lotorder = (lotorder..item..' \n')
	    end
	end
		--Temporary Item Counter to see if items are registering with filter.
		lotorder = (lotorder.."\n Item Counter: "..itemcount)
end

function lightluggage()
	llprofile = ""
	ll_lots = ""
	ll_pass = ""
	for i=1, #salvage_cell_name_short  do 
		if salvage_cell_name_short[i] ~= nil then
			if cell_lots[salvage_cell_name_short[i]] == 1 and mode == "lots" then
	   		ll_lots = (ll_lots..cells_id[i]..',')
	   		elseif cell_lots[salvage_cell_name_short[i]] == 0 then
	   			if salvage_cell_name_short[i] ~= "alex" then
			   		ll_pass = (ll_pass..cells_id[i]..',')
			   	end
	   		end
	   	end
	end
	llprofile = (llprofile..'if item is '..ll_lots..' then lot \n')
	llprofile = (llprofile..'if item is '..ll_pass..' then pass \n')
	
	if settingtab[set][player_num]['pass'] ~= 0 then
		llprofile = (llprofile.."if item is "..settingtab[set][player_num]['pass'].." then pass \n")
	end
	if settingtab[set][player_num]['lot'] ~= 0 then
		llprofile = (llprofile.."if item is "..settingtab[set][player_num]['lot'].." then lot \n")
	end
	
	io.open(lua_base_path..'../../plugins/ll/salvage-'..player..'.txt',"w"):write(llprofile):close()
end

function initialize()
	tb_create('salvage_box')
	tb_set_bg_color('salvage_box',200,30,30,30)
	tb_set_color('salvage_box',255,200,200,200)
	tb_set_location('salvage_box',posx,posy)
	tb_set_visibility('salvage_box',1)
	tb_set_bg_visibility('salvage_box',1)
	tb_set_font('salvage_box','Arial',12)
	tb_set_text('salvage_box',' Lot order:  \n'..lotorder);
end


function event_incoming_text(original, new, color)
	a,b,name,cell = string.find(original,'(%w+) obtains an? ..(%w+) cell..\46')
	if cell ~= nil then
		if name == player then
			cell_lots[cell] = 0
			itemcount = itemcount + 1
		elseif name ~= player and cell_lots[cell] > 1 then
			cell_lots[cell] = cell_lots[cell] - 1
		end
		-- Populate lot order	
		orderlots()
		-- Update lightluggage
		lightluggage()
		-- Update textbox
		initialize()
		return new, color
	end
	
	a,b,cell2 = string.find(original,'You find an? ..(%w+)..')
	if cell2 ~= nil then
		if cell_lots[cell2] ~= 0 and cell_lots[cell2] ~= nil then
			new = 'You find a '..string.char(31,158)..cell2..' cell.'..string.char(31,167)..' /Need/'
		end
		return new, color
	end
end	

function event_unload()
	tb_delete('salvage_box')

	send_command('unalias ch2')
end 
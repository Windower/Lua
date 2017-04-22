--Copyright (c) 2013, Krizz, Skyrant
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
-- Zone Timer
-- Time extention tracker
-- Stagger timer
-- Currency tracker
-- Proc identifier
-- Light Luggage Profile

_addon.name = 'DynamisHelper'
_addon.author = 'Krizz, Skyrant'
_addon.commands = {'DynamisHelper','dh'}
_addon.version = '2.2'

config = require('config')
texts = require('texts')
res = require('resources')

ProcZones = res.zones:english(string.startswith-{'Dynamis'}):keyset()

-------------------------------------------------------------------------------
-- Define default values ------------------------------------------------------
-------------------------------------------------------------------------------
defaults = T{}
defaults.text_R = 255
defaults.text_G = 255
defaults.text_B = 255
defaults.Wind_R = 0
defaults.Wind_G = 255
defaults.Wind_B = 0
defaults.Bast_R = 0
defaults.Bast_G = 0
defaults.Bast_B = 255
defaults.Sand_R = 255
defaults.Sand_G = 0
defaults.Sand_B = 0
defaults.pos_x = 0
defaults.pos_y = 0
defaults.font_size = 11
defaults.bg_alpha = 255
defaults.timer = true
defaults.tracker = true
defaults.trposx = 0
defaults.trposy = 0
defaults.proc = true
defaults.pposx = 0
defaults.pposy = 0

-------------------------------------------------------------------------------
-- Load defaults from settings.xml --------------------------------------------
-------------------------------------------------------------------------------
settings = config.load(defaults)

-- upgrade to new settings file if old settings still exist -------------------
if settings.trposx and settings.trposy then
	-- copy position from old config to new one
   	settings.pos_x = settings.trposx
   	settings.pos_y = settings.trposy
	-- delete old settings here ---------------------------------------------------
	config.save(settings, 'all')
end


windurst_col = "\\cs("..tostring(settings.Wind_R)..","..tostring(settings.Wind_G)..","..tostring(settings.Wind_B)..")"
bastok_col = "\\cs("..tostring(settings.Bast_R)..","..tostring(settings.Bast_G)..","..tostring(settings.Bast_B)..")"
sandoria_col = "\\cs("..tostring(settings.Sand_R)..","..tostring(settings.Sand_G)..","..tostring(settings.Sand_B)..")"
neutral_col = "\\cs(128,128,128)"
time_col = "\\cs(255,255,0)"

StaggerCount = 0
current_mob = "unknown"
current_proc = "unknown"
currenttime = 0
obj_time = 0
end_time = 0

image = texts.new("image")

texts.color(image,settings.text_R,settings.text_G,settings.text_B)
texts.size(image,settings.font_size)
texts.pos_x(image,settings.pos_x)
texts.pos_y(image,settings.pos_y)
texts.bg_alpha(image,settings.bg_alpha)



-------------------------------------------------------------------------------
-- Initialize the Currency array. We need this to keep track of the drops -----
-------------------------------------------------------------------------------
function init_currency()
	Currency = {"Ordelle Bronzepiece","Montiont Silverpiece","One Byne Bill",
				"One Hundred Byne Bill","Tukuku Whiteshell","Lungo-Nango Jadeshell",
				"Forgotten Thought","Forgotten Hope","Forgotten Touch","Forgotten Journey","Forgotten Step"}
	for i=1, #Currency do
    	 Currency[Currency[i]] = 0
	end
	obj_time = 0
end
init_currency()

-------------------------------------------------------------------------------
-- Initialize the time Granules array. Keeps track of the time extensions -----
-------------------------------------------------------------------------------
function init_granules()
	Granules = {"Crimson granules of time","Azure granules of time","Amber granules of time",
				"Alabaster granules of time","Obsidian granules of time"}
	for i=1, #Granules do
		Granules[Granules[i]] = 0
	end
end
init_granules()

-------------------------------------------------------------------------------
-- Refresh the on screen messages ---------------------------------------------
-------------------------------------------------------------------------------
function refresh()
	body = time_col.."Time remaining    "..os.date('!%H:%M:%S', obj_time).."\\cr\n------------------------------------"
	if settings.proc then
		if current_mob ~= "unknown" then
			body = body.."\n Current proc for \n "..current_mob.."\n is "..current_proc.." "
		else
			body = body.."\n Waiting for target... "
		end
	end
	if settings.tracker then
		if settings.proc then
			body = body.."\n------------------------------------"
		end
		for i=1, #Currency do
			if Currency[i] == "Ordelle Bronzepiece" or Currency[i] == "Montiont Silverpiece" then
				body = body.."\n "..sandoria_col..Currency[i]..": "..Currency[Currency[i]].." \\cr"
			elseif Currency[i] == "One Byne Bill" or Currency[i] == "One Hundred Byne Bill" then
				body = body.."\n "..bastok_col..Currency[i]..": "..Currency[Currency[i]].." \\cr"
			elseif Currency[i] == "Tukuku Whiteshell" or Currency[i] == "Lungo-Nango Jadeshell" then
				body = body.."\n "..windurst_col..Currency[i]..": "..Currency[Currency[i]].." \\cr"
			else
				body = body.."\n "..neutral_col..Currency[i]..": "..Currency[Currency[i]].." "
			end
		end
	end
	if settings.tracker or settings.proc then
		footer = "\\cr\n------------------------------------"
	else 
		footer = "\\cr"
	end
	for i=1, #Granules do
		if Granules[Granules[i]] == 0 then
			footer = footer.."\n "..Granules[i].." "
		end
	end
	texts.text(image,body..footer)
end
refresh()

-------------------------------------------------------------------------------
-- Register a prerendere event for the display refresh ------------------------
-------------------------------------------------------------------------------
windower.register_event('prerender', function()
    if obj_time < 1 then return end
    if obj_time ~= (end_time - os.time()) then
        obj_time = end_time - os.time()
        refresh()
    end
end)

-------------------------------------------------------------------------------
-- Did we enter a Dynamis Zone? -----------------------------------------------
-------------------------------------------------------------------------------
windower.register_event('zone change', function(zone)
    image:hide()
    header = "Waiting for currency drops..."
    init_currency()
    if ProcZones:contains(windower.ffxi.get_info().zone) then
    	obj_time = 3600
    	end_time = os.time() + obj_time
        image:show()
    end
end)

image:hide()
-------------------------------------------------------------------------------
-- Check if we are in Dynamis and show the overlay ----------------------------
-------------------------------------------------------------------------------
if ProcZones:contains(windower.ffxi.get_info().zone) then
    image:show()
end
-------------------------------------------------------------------------------
-- 186	Dynamis - Bastok ------------------------------------------------------
-- 134	Dynamis - Beaucedine --------------------------------------------------
--  40	Dynamis - Buburimu ----------------------------------------------------
-- 188	Dynamis - Jeuno -------------------------------------------------------
--  41	Dynamis - Qufim -------------------------------------------------------
-- 185	Dynamis - San d'Oria --------------------------------------------------
--  42	Dynamis - Tavnazia ----------------------------------------------------
--  39	Dynamis - Valkurm -----------------------------------------------------
-- 187	Dynamis - Windurst ----------------------------------------------------
-- 135	Dynamis - Xarcabard ---------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Get the player name for light luggage profile ------------------------------
-------------------------------------------------------------------------------
windower.register_event('load', 'login', function()
    if windower.ffxi.get_info().logged_in then
        player = windower.ffxi.get_player().name
        obtained = nil
    end
end)

-------------------------------------------------------------------------------
-- Parse the chat messages for drops, staggers and time extensions ------------
-------------------------------------------------------------------------------
windower.register_event('incoming text',function (original, new, color)
	a,b,fiend = string.find(original,"%w+'s attack staggers the (%w+)%!")
   	if settings.timer then
   		if fiend == 'fiend' then
			StaggerCount = StaggerCount + 1
			a,b,mob_timers = string.find(current_mob,"%w+ (%w+)")
    		windower.send_command('timers c "'..mob_timers..'" 30 down stun')
    		return new, color
    	end
    end
   	if string.find(original,"Your stay in Dynamis has been extended by %d+ minutes.") then
    	end_time = end_time + (tonumber(original:match("%d+")) * 60)
    	refresh()
   	end
	a,b,item = string.find(original,"Obtained key item: ..(%w+ %w+ %w+ %w+)..\46")
	if item ~= nil then
		item = item:lower()
		for i=1, #Granules do
			if item == Granules[i]:lower() then
				Granules[Granules[i]] = 1
			end
		end
	end
   	a,b,item = string.find(original,"%w+ obtains an? ..(%w+ %w+ %w+ %w+)..\46")
   	if item == nil then
   		a,b,item = string.find(original,"%w+ obtains an? ..(%w+ %w+ %w+)..\46")
   		if item == nil then
    		a,b,item = string.find(original,"%w+ obtains an? ..(%w+%-%w+ %w+)..\46")
    		if item == nil then
    			a,b,item = string.find(original,"%w+ obtains an? ..(%w+ %w+)..\46")
    		end
   		end
  	end
 	if item ~= nil then
 		item = item:lower()
 		for i=1, #Currency do
			if item == Currency[i]:lower() then
   				Currency[Currency[i]] = Currency[Currency[i]] + 1
   			end
 		end
 	end
    refresh()
 	return new, color
end)

-------------------------------------------------------------------------------
-- Register target change event to get the monster name -----------------------
-------------------------------------------------------------------------------
windower.register_event('target change', function(targ_id)
	if targ_id ~= 0 then
        mob = windower.ffxi.get_mob_by_index(targ_id)
        current_mob = mob.name
        setproc()
    end
end)

-------------------------------------------------------------------------------
-- Find the proc for the monster based on time or job -------------------------
-------------------------------------------------------------------------------
function setproc()
	current_proc = "unknown"
    local currenttime = windower.ffxi.get_info().time
 	if currenttime >= 0*60 and currenttime < 8*60 then
  		window = 'morning'
 	elseif currenttime >= 8*60 and currenttime < 16*60 then
  		window = 'day'
	elseif currenttime >= 16*60 and currenttime <= 24*60 then
  		window = 'night'
 	end

 	for i=1, #proctype do
  		for j=1, #staggers[window][proctype[i]] do
 			if current_mob == staggers[window][proctype[i]][j] then
				current_proc = proctype[i]
 			end
 		end
 	end
 	if current_proc == 'ja' then
 		current_proc = 'Job Ability'
 	elseif current_proc == 'magic' then
 		current_proc = 'Magic'
 	elseif current_proc == 'ws' then
 		current_proc = 'Weapon Skill'
 	end
	refresh()
end

-------------------------------------------------------------------------------
-- Process options and save settings ------------------------------------------
-------------------------------------------------------------------------------
windower.register_event('addon command',function (...)
	local params = {...}
	if #params < 1 then
		return
	end
	if params[1] == "visible" then
		if texts.visible(image) then
			image:hide()
		else
			image:show()
		end
	elseif params[1]:lower() == "help" then
		windower.add_to_chat(159,'\nDynamisHelper v2.0')
		windower.add_to_chat(158,'dh visible: toggle addon display.')
		windower.add_to_chat(158,'dh font size: change the font size. ['..tostring(settings.font_size)..']')
		windower.add_to_chat(158,'dh position pos_x pos_y: position of addon window in pixels. [X='..tostring(settings.pos_x)..' Y='..tostring(settings.pos_y)..']')
		windower.add_to_chat(158,'dh opacity bg_alpha: opacity (0-255) of the background. ['..tostring(settings.bg_alpha)..']')
		-- compatibility commands ---------------------------------------------
		windower.add_to_chat(158,'dh timer [on/off] : Displays a timer each time a mob is staggered. ['..tostring(settings.timer)..']')
		windower.add_to_chat(158,'dh tracker [on/off/reset] : Tracks the amount of currency obtained. ['..tostring(settings.tracker)..']')
		windower.add_to_chat(158,'dh proc [on/off] : Displays the current proc for the targeted mob. ['..tostring(settings.proc)..']')
		windower.add_to_chat(158,'dh ll create: Creates a light luggage profile to lot all dynamis currency.')
		-----------------------------------------------------------------------
		windower.add_to_chat(158,'dh save: save your current settings.')
  	elseif params[1]:lower() == "font" then
  		if params[2] then
  			texts.size(image,params[2])
  			settings.font_size = params[2]
  		else
  			windower.add_to_chat(158,'dh font size: change the font size.')
  		end
  	elseif params[1]:lower() == "position" then
  		if params[3] then
  			texts.pos_x(image,params[2])
			texts.pos_y(image,params[3])
			settings.pos_x = params[2]
			settings.pos_y = params[3]
  		else
  			windower.add_to_chat(158,'dh pos [pos_x][pos_y] : position of addon window in pixels from the top left of the screen.')
  		end
	elseif params[1]:lower() == "opacity" then
		if params[2] then
			texts.bg_alpha(image,params[2])
			settings.bg_alpha = params[2]
		else
			windower.add_to_chat(158,'dh opacity [0-255] : transparency of addon window.')
		end
	-- compatibility commands ---------------------------------------------
	elseif params[1]:lower() == "timer" then
		if params[2]:lower() == "on" then 
			settings.timer = true 
		elseif params[2]:lower() == "off" then 
			settings.timer = false
		else
			windower.add_to_chat(158,'dh timer [on/off] : Displays a timer each time a mob is staggered.')
		end
	elseif params[1]:lower() == "tracker" then
		if params[2]:lower() == "on" then
			settings.tracker = true
			refresh()
			image:show()
		elseif params[2]:lower() == "off" then
			settings.tracker = false
			refresh()
		elseif params[2]:lower() == "reset" then
			init_currency()
			refresh()
--		elseif  params[2]:lower() == "pos" then
--			if params[4] then
--				settings.trposx, settings.trposy = tonumber(params[3]), tonumber(params[4])
--			end
		else
			windower.add_to_chat(158,'dh proc [on/off] : Displays the current proc for the targeted mob.')
		end
	elseif params[1]:lower() == "proc" then
		if params[2]:lower() == "on" then
			settings.proc = true
			refresh()
			image:show()
		elseif params[2]:lower() == "off" then
			settings.proc = false
			refresh()
--		elseif  params[2]:lower() == "pos" then
--			if params[4] then
--				settings.pposx, settings.pposy = tonumber(params[3]), tonumber(params[4])
--			end
--		else
			windower.add_to_chat(158,'dh tracker [on/off/reset] : Tracks the amount of currency obtained.')
		end
	elseif params[1]:lower() == "ll" then
   		if params[2]:lower() == "create" then
    		player = windower.ffxi.get_player()['name']
    		io.open(windower.addon_path..'../../plugins/ll/dynamis-'..player..'.txt',"w"):write('if item is 1452, 1453, 1455, 1456, 1449, 1450 then lot'):close()
    		windower.send_command('ll profile dynamis-'..player..'.txt')
   		else 
   			windower.add_to_chat(158,'dh ll create: Creates a light luggage profile to lot all dynamis currency.')
   		end
   	-- End of compatibility commands---------------------------------------
   	elseif params[1]:lower() == "save" then
   		config.save(settings, 'all')
   	else
		windower.add_to_chat(159,'\nDynamisHelper v2.0')
		windower.add_to_chat(159,"Timer:"..tostring(settings.timer).." Tracker:"..tostring(settings.tracker).." Proc:"..tostring(settings.proc).." Position: X="..tostring(settings.pos_x).." Y="..tostring(settings.pos_y).." Font Size:"..tostring(settings.font_size))
		windower.add_to_chat(158,'dh visible: toggle addon display.')
		windower.add_to_chat(158,'dh font size: change the font size.')
		windower.add_to_chat(158,'dh position pos_x pos_y: position of addon window in pixels from the top left of the screen.')
		windower.add_to_chat(158,'dh opacity bg_alpha: opacity (0-255) of the background.')
		windower.add_to_chat(158,'dh timer [on/off] : Displays a timer each time a mob is staggered.')
		windower.add_to_chat(158,'dh tracker [on/off/reset/pos x y] : Tracks the amount of currency obtained.')
		windower.add_to_chat(158,'dh proc [on/off/pos x y] : Displays the current proc for the targeted mob.')
		windower.add_to_chat(158,'dh ll create: Creates a light luggage profile to lot all dynamis currency.')
	end
end)

-------------------------------------------------------------------------------
-- Data and Arrays ------------------------------------------------------------
-------------------------------------------------------------------------------
proctype = {"ja","magic","ws","random","none"}
-------------------------------------------------------------------------------
-- Enemy Stagger Array based on time > stagger > name -------------------------
-------------------------------------------------------------------------------
staggers = T{}
staggers['morning'] = T{}
staggers['morning']['ja'] = {	"Kindred Thief", "Kindred Beastmaster", "Kindred Monk", "Kindred Ninja", "Kindred Ranger",
								"Duke Gomory", "Marquis Andras", "Marquis Gamygyn", "Count Raum", "Marquis Cimeries", "Marquis Caim", "Baron Avnas", 
							 	"Hydra Thief", "Hydra Beastmaster", "Hydra Monk", "Hydra Ninja", "Hydra Ranger", 
							 	"Vanguard Backstabber", "Vanguard Grappler", "Vanguard Hawker", "Vanguard Pillager", "Vanguard Predator", "Voidstreaker Butchnotch", "Steelshank Kratzvatz", 
							 	"Vanguard Beasttender", "Vanguard Kusa", "Vanguard Mason", "Vanguard Militant", "Vanguard Purloiner",  "Ko'Dho Cannonball", 
							 	"Vanguard Assassin", "Vanguard Liberator", "Vanguard Ogresoother", "Vanguard Salvager", "Vanguard Sentinel", "Wuu Qoho the Razorclaw", "Tee Zaksa the Ceaseless", 
							 	"Vanguard Ambusher", "Vanguard Hitman", "Vanguard Pathfinder", "Vanguard Pit", "Vanguard Welldigger",
							 	"Bandrix Rockjaw", "Lurklox Dhalmelneck", "Trailblix Goatmug", "Kikklix Longlegs", "Snypestix Eaglebeak", "Jabkix Pigeonpecs", "Blazox Boneybod", "Bootrix Jaggedelbow", "Mobpix Mucousmouth", "Prowlox Barrelbelly", "Slystix Megapeepers", "Feralox Honeylips", 
							 	"Bordox Kittyback", "Droprix Granitepalms", "Routsix Rubbertendon", "Slinkix Trufflesniff", "Swypestix Tigershins",
							 	"Nightmare Crawler", "Nightmare Raven", "Nightmare Uragnite", 
							 	"Nightmare Fly", "Nightmare Flytrap", "Nightmare Funguar", 
							 	"Nightmare Gaylas", "Nightmare Kraken", "Nightmare Roc", 
							 	"Nightmare Hornet", "Nightmare Bugard", 
							 	"Woodnix Shrillwhistle", "Hamfist Gukhbuk", "Lyncean Juwgneg", "Va'Rhu Bodysnatcher", "Doo Peku the Fleetfoot",
							 	"Nant'ina", "Antaeus"}

staggers['morning']['magic'] = {"Kindred White Mage", "Kindred Bard", "Kindred Summoner", "Kindred Black Mage", "Kindred Red Mage", 
								"Duke Berith", "Marquis Decarabia", "Prince Seere", "Marquis Orias", "Marquis Nebiros", "Duke Haures",
								"Hydra White Mage", "Hydra Bard", "Hydra Summoner", "Hydra Black Mage", "Hydra Red Mage", 
								"Vanguard Amputator", "Vanguard Bugler", "Vanguard Dollmaster", "Vanguard Mesmerizer", "Vanguard Vexer", "Soulsender Fugbrag", "Reapertongue Gadgquok", "Battlechoir Gitchfotch", 
								"Vanguard Constable", "Vanguard Minstrel", "Vanguard Protector", "Vanguard Thaumaturge", "Vanguard Undertaker", "Gi'Pha Manameister", "Gu'Nhi Noondozer", "Ra'Gho Darkfount", "Va'Zhe Pummelsong",  
								"Vanguard Chanter", "Vanguard Oracle", "Vanguard Prelate", "Vanguard Priest", "Vanguard Visionary", "Loo Hepe the Eyepiercer", "Xoo Kaza the Solemn", "Haa Pevi the Stentorian", "Xuu Bhoqa the Enigma", "Fuu Tzapo the Blessed", "Naa Yixo the Stillrage", 
								"Vanguard Alchemist", "Vanguard Enchanter", "Vanguard Maestro", "Vanguard Necromancer", "Vanguard Shaman", 
								"Elixmix Hooknose", "Gabblox Magpietongue", "Hermitrix Toothrot", "Humnox Drumbelly", "Morgmox Moldnoggin", "Mortilox Wartpaws", "Distilix Stickytoes", "Jabbrox Grannyguise", "Quicktrix Hexhands", "Wilywox Tenderpalm",
								"Ascetox Ratgums", "Brewnix Bittypupils", "Gibberox Pimplebeak", "Morblox Stubthumbs", "Whistrix Toadthroat", 
								"Nightmare Bunny", "Nightmare Eft", "Nightmare Mandragora", 
								"Nightmare Hippogryph", "Nightmare Sabotender", "Nightmare Sheep", 
								"Nightmare Snoll", "Nightmare Stirge", "Nightmare Weapon",
								"Nightmare Makara", "Nightmare Cluster", 
								"Gosspix Blabblerlips", "Flamecaller Zoeqdoq", "Gi'Bhe Fleshfeaster", "Ree Nata the Melomanic", "Baa Dava the Bibliophage", 
								"Aitvaras" }

staggers['morning']['ws'] = {	"Kindred Paladin", "Kindred Warrior", "Kindred Samurai", "Kindred Dragoon", "Kindred Dark Knight", 
								"Count Zaebos", "Duke Scox", "Marquis Sabnak", "King Zagan", "Count Haagenti", 
								"Hydra Paladin", "Hydra Warrior", "Hydra Samurai", "Hydra Dragoon", "Hydra Dark Knight", 
								"Vanguard Footsoldier", "Vanguard Gutslasher", "Vanguard Impaler", "Vanguard Neckchopper", "Vanguard Trooper", "Wyrmgnasher Bjakdek", "Bladerunner Rokgevok", "Bloodfist Voshgrosh", "Spellspear Djokvukk", 
								"Vanguard Defender", "Vanguard Drakekeeper", "Vanguard Hatamoto", "Vanguard Vigilante", "Vanguard Vindicator", "Ze'Vho Fallsplitter", "Zo'Pha Forgesoul", "Bu'Bho Truesteel", 
								"Vanguard Exemplar", "Vanguard Inciter", "Vanguard Partisan", "Vanguard Persecutor", "Vanguard Skirmisher", "Maa Febi the Steadfast", "Muu Febi the Steadfast", 
								"Vanguard Armorer", "Vanguard Dragontamer", "Vanguard Ronin", "Vanguard Smithy",
								"Buffrix Eargone", "Cloktix Longnail", "Sparkspox Sweatbrow", "Ticktox Beadyeyes", "Tufflix Loglimbs", "Wyrmwix Snakespecs", "Karashix Swollenskull", "Smeltix Thickhide", "Wasabix Callusdigit", "Anvilix Sootwrists", "Scruffix Shaggychest", "Tymexox Ninefingers", "Scourquix Scaleskin",
								"Draklix Scalecrust", "Moltenox Stubthumbs", "Ruffbix Jumbolobes", "Shisox Widebrow", "Tocktix Thinlids",
								"Nightmare Crab", "Nightmare Dhalmel", "Nightmare Scorpion", 
								"Nightmare Goobbue", "Nightmare Manticore", "Nightmare Treant", 
								"Nightmare Diremite", "Nightmare Tiger", "Nightmare Raptor", 
								"Nightmare Leech", "Nightmare Worm", 
								"Shamblix Rottenheart", "Elvaansticker Bxafraff", "Qu'Pho Bloodspiller", "Te'Zha Ironclad", "Koo Rahi the Levinblade", 
								"Barong", "Alklha", "Stihi", "Fairy Ring", "Stcemqestcint", "Stringes", "Suttung" }

staggers['morning']['random'] = {"Nightmare Taurus"}
staggers['morning']['none'] = {"Animated Claymore", "Animated Dagger", "Animated Great Axe", "Animated Gun", "Animated Hammer", "Animated Horn", "Animated Kunai", "Animated Knuckles", "Animated Longbow", "Animated Longsword", "Animated Scythe", "Animated Shield", "Animated Spear", "Animated Staff", "Animated Tabar", "Animated Tachi", "Fire Pukis", "Petro Pukis", "Poison Pukis", "Wind Pukis", "Kindred's Vouivre", "Kindred's Wyvern", "Kindred's Avatar", "Vanguard Eye", "Prototype Eye", "Nebiros's Avatar", "Haagenti's Avatar", "Caim's Vouivre", "Andras's Vouivre", "Adamantking Effigy", "Avatar Icon", "Goblin Replica", "Serjeant Tombstone", "Zagan's Wyvern", "Hydra's Hound", "Hydra's Wyvern", "Hydra's Avatar", "Rearguard Eye", "Adamantking Effigy", "Adamantking Image", "Avatar Icon", "Avatar Idol", "Effigy Prototype", "Goblin Replica", "Goblin Statue", "Icon Prototype", "Manifest Icon", "Manifest Icon", "Prototype Eye", "Serjeant Tombstone", "Statue Prototype", "Tombstone Prototype", "Vanguard Eye", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Crow", "Vanguard's Hecteyes", "Vanguard's Scorpion", "Vanguard's Slime", "Vanguard's Wyvern", "Vanguard's Wyvern", "Vanguard's Wyvern", "Vanguard's Wyvern", "Warchief Tombstone"}

staggers['day'] = T{}
staggers['day']['ja'] = {		"Kindred Thief", "Kindred Beastmaster", "Kindred Monk", "Kindred Ninja", "Kindred Ranger",
								"Duke Gomory", "Marquis Andras", "Marquis Gamygyn", "Count Raum", "Marquis Cimeries", "Marquis Caim", "Baron Avnas", 
							 	"Hydra Thief", "Hydra Beastmaster", "Hydra Monk", "Hydra Ninja", "Hydra Ranger", 
							 	"Vanguard Backstabber", "Vanguard Grappler", "Vanguard Hawker", "Vanguard Pillager", "Vanguard Predator", "Voidstreaker Butchnotch", "Steelshank Kratzvatz", 
							 	"Vanguard Beasttender", "Vanguard Kusa", "Vanguard Mason", "Vanguard Militant", "Vanguard Purloiner",  "Ko'Dho Cannonball", 
							 	"Vanguard Assassin", "Vanguard Liberator", "Vanguard Ogresoother", "Vanguard Salvager", "Vanguard Sentinel", "Wuu Qoho the Razorclaw", "Tee Zaksa the Ceaseless", 
							 	"Vanguard Ambusher", "Vanguard Hitman", "Vanguard Pathfinder", "Vanguard Pit", "Vanguard Welldigger",
							 	"Bandrix Rockjaw", "Lurklox Dhalmelneck", "Trailblix Goatmug", "Kikklix Longlegs", "Snypestix Eaglebeak", "Jabkix Pigeonpecs", "Blazox Boneybod", "Bootrix Jaggedelbow", "Mobpix Mucousmouth", "Prowlox Barrelbelly", "Slystix Megapeepers", "Feralox Honeylips", 
							 	"Bordox Kittyback", "Droprix Granitepalms", "Routsix Rubbertendon", "Slinkix Trufflesniff", "Swypestix Tigershins",
								"Nightmare Bunny", "Nightmare Eft", "Nightmare Mandragora", 
								"Nightmare Hippogryph", "Nightmare Sabotender", "Nightmare Sheep", 
								"Nightmare Snoll", "Nightmare Stirge", "Nightmare Weapon",
								"Nightmare Makara", "Nightmare Cluster", 
							 	"Woodnix Shrillwhistle", "Hamfist Gukhbuk", "Lyncean Juwgneg", "Va'Rhu Bodysnatcher", "Doo Peku the Fleetfoot",
							 	"Nant'ina", "Antaeus"}

staggers['day']['magic'] = {	"Kindred White Mage", "Kindred Bard", "Kindred Summoner", "Kindred Black Mage", "Kindred Red Mage", 
								"Duke Berith", "Marquis Decarabia", "Prince Seere", "Marquis Orias", "Marquis Nebiros", "Duke Haures",
								"Hydra White Mage", "Hydra Bard", "Hydra Summoner", "Hydra Black Mage", "Hydra Red Mage", 
								"Vanguard Amputator", "Vanguard Bugler", "Vanguard Dollmaster", "Vanguard Mesmerizer", "Vanguard Vexer", "Soulsender Fugbrag", "Reapertongue Gadgquok", "Battlechoir Gitchfotch", 
								"Vanguard Constable", "Vanguard Minstrel", "Vanguard Protector", "Vanguard Thaumaturge", "Vanguard Undertaker", "Gi'Pha Manameister", "Gu'Nhi Noondozer", "Ra'Gho Darkfount", "Va'Zhe Pummelsong",  
								"Vanguard Chanter", "Vanguard Oracle", "Vanguard Prelate", "Vanguard Priest", "Vanguard Visionary", "Loo Hepe the Eyepiercer", "Xoo Kaza the Solemn", "Haa Pevi the Stentorian", "Xuu Bhoqa the Enigma", "Fuu Tzapo the Blessed", "Naa Yixo the Stillrage", 
								"Vanguard Alchemist", "Vanguard Enchanter", "Vanguard Maestro", "Vanguard Necromancer", "Vanguard Shaman", 
								"Elixmix Hooknose", "Gabblox Magpietongue", "Hermitrix Toothrot", "Humnox Drumbelly", "Morgmox Moldnoggin", "Mortilox Wartpaws", "Distilix Stickytoes", "Jabbrox Grannyguise", "Quicktrix Hexhands", "Wilywox Tenderpalm",
								"Ascetox Ratgums", "Brewnix Bittypupils", "Gibberox Pimplebeak", "Morblox Stubthumbs", "Whistrix Toadthroat", 
								"Nightmare Crab", "Nightmare Dhalmel", "Nightmare Scorpion", 
								"Nightmare Goobbue", "Nightmare Manticore", "Nightmare Treant", 
								"Nightmare Diremite", "Nightmare Tiger", "Nightmare Raptor", 
								"Nightmare Leech", "Nightmare Worm" ,
								"Gosspix Blabblerlips", "Flamecaller Zoeqdoq", "Gi'Bhe Fleshfeaster", "Ree Nata the Melomanic", "Baa Dava the Bibliophage", 
								"Aitvaras" }

staggers['day']['ws'] =  {		"Kindred Paladin", "Kindred Warrior", "Kindred Samurai", "Kindred Dragoon", "Kindred Dark Knight", 
								"Count Zaebos", "Duke Scox", "Marquis Sabnak", "King Zagan", "Count Haagenti", 
								"Hydra Paladin", "Hydra Warrior", "Hydra Samurai", "Hydra Dragoon", "Hydra Dark Knight", 
								"Vanguard Footsoldier", "Vanguard Gutslasher", "Vanguard Impaler", "Vanguard Neckchopper", "Vanguard Trooper", "Wyrmgnasher Bjakdek", "Bladerunner Rokgevok", "Bloodfist Voshgrosh", "Spellspear Djokvukk", 
								"Vanguard Defender", "Vanguard Drakekeeper", "Vanguard Hatamoto", "Vanguard Vigilante", "Vanguard Vindicator", "Ze'Vho Fallsplitter", "Zo'Pha Forgesoul", "Bu'Bho Truesteel", 
								"Vanguard Exemplar", "Vanguard Inciter", "Vanguard Partisan", "Vanguard Persecutor", "Vanguard Skirmisher", "Maa Febi the Steadfast", "Muu Febi the Steadfast", 
								"Vanguard Armorer", "Vanguard Dragontamer", "Vanguard Ronin", "Vanguard Smithy",
								"Buffrix Eargone", "Cloktix Longnail", "Sparkspox Sweatbrow", "Ticktox Beadyeyes", "Tufflix Loglimbs", "Wyrmwix Snakespecs", "Karashix Swollenskull", "Smeltix Thickhide", "Wasabix Callusdigit", "Anvilix Sootwrists", "Scruffix Shaggychest", "Tymexox Ninefingers", "Scourquix Scaleskin",
								"Draklix Scalecrust", "Moltenox Stubthumbs", "Ruffbix Jumbolobes", "Shisox Widebrow", "Tocktix Thinlids",
							 	"Nightmare Crawler", "Nightmare Raven", "Nightmare Uragnite", 
							 	"Nightmare Fly", "Nightmare Flytrap", "Nightmare Funguar", 
							 	"Nightmare Gaylas", "Nightmare Kraken", "Nightmare Roc", 
							 	"Nightmare Hornet", "Nightmare Bugard", 
								"Shamblix Rottenheart", "Elvaansticker Bxafraff", "Qu'Pho Bloodspiller", "Te'Zha Ironclad", "Koo Rahi the Levinblade", 
								"Barong", "Alklha", "Stihi", "Fairy Ring", "Stcemqestcint", "Stringes", "Suttung" }

staggers['day']['random'] = {"Nightmare Taurus"}
staggers['day']['none'] = {"Animated Claymore", "Animated Dagger", "Animated Great Axe", "Animated Gun", "Animated Hammer", "Animated Horn", "Animated Kunai", "Animated Knuckles", "Animated Longbow", "Animated Longsword", "Animated Scythe", "Animated Shield", "Animated Spear", "Animated Staff", "Animated Tabar", "Animated Tachi", "Fire Pukis", "Petro Pukis", "Poison Pukis", "Wind Pukis", "Kindred's Vouivre", "Kindred's Wyvern", "Kindred's Avatar", "Vanguard Eye", "Prototype Eye", "Nebiros's Avatar", "Haagenti's Avatar", "Caim's Vouivre", "Andras's Vouivre", "Adamantking Effigy", "Avatar Icon", "Goblin Replica", "Serjeant Tombstone", "Zagan's Wyvern", "Hydra's Hound", "Hydra's Wyvern", "Hydra's Avatar", "Rearguard Eye", "Adamantking Effigy", "Adamantking Image", "Avatar Icon", "Avatar Idol", "Effigy Prototype", "Goblin Replica", "Goblin Statue", "Icon Prototype", "Manifest Icon", "Manifest Icon", "Prototype Eye", "Serjeant Tombstone", "Statue Prototype", "Tombstone Prototype", "Vanguard Eye", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Crow", "Vanguard's Hecteyes", "Vanguard's Scorpion", "Vanguard's Slime", "Vanguard's Wyvern", "Vanguard's Wyvern", "Vanguard's Wyvern", "Vanguard's Wyvern", "Warchief Tombstone"}

staggers['night'] = T{}
staggers['night']['ja'] = {		"Kindred Thief", "Kindred Beastmaster", "Kindred Monk", "Kindred Ninja", "Kindred Ranger",
								"Duke Gomory", "Marquis Andras", "Marquis Gamygyn", "Count Raum", "Marquis Cimeries", "Marquis Caim", "Baron Avnas", 
							 	"Hydra Thief", "Hydra Beastmaster", "Hydra Monk", "Hydra Ninja", "Hydra Ranger", 
							 	"Vanguard Backstabber", "Vanguard Grappler", "Vanguard Hawker", "Vanguard Pillager", "Vanguard Predator", "Voidstreaker Butchnotch", "Steelshank Kratzvatz", 
							 	"Vanguard Beasttender", "Vanguard Kusa", "Vanguard Mason", "Vanguard Militant", "Vanguard Purloiner",  "Ko'Dho Cannonball", 
							 	"Vanguard Assassin", "Vanguard Liberator", "Vanguard Ogresoother", "Vanguard Salvager", "Vanguard Sentinel", "Wuu Qoho the Razorclaw", "Tee Zaksa the Ceaseless", 
							 	"Vanguard Ambusher", "Vanguard Hitman", "Vanguard Pathfinder", "Vanguard Pit", "Vanguard Welldigger",
							 	"Bandrix Rockjaw", "Lurklox Dhalmelneck", "Trailblix Goatmug", "Kikklix Longlegs", "Snypestix Eaglebeak", "Jabkix Pigeonpecs", "Blazox Boneybod", "Bootrix Jaggedelbow", "Mobpix Mucousmouth", "Prowlox Barrelbelly", "Slystix Megapeepers", "Feralox Honeylips", 
							 	"Bordox Kittyback", "Droprix Granitepalms", "Routsix Rubbertendon", "Slinkix Trufflesniff", "Swypestix Tigershins",
								"Nightmare Crab", "Nightmare Dhalmel", "Nightmare Scorpion", 
								"Nightmare Goobbue", "Nightmare Manticore", "Nightmare Treant", 
								"Nightmare Diremite", "Nightmare Tiger", "Nightmare Raptor", 
								"Nightmare Leech", "Nightmare Worm", 
							 	"Woodnix Shrillwhistle", "Hamfist Gukhbuk", "Lyncean Juwgneg", "Va'Rhu Bodysnatcher", "Doo Peku the Fleetfoot",
							 	"Nant'ina", "Antaeus"}

staggers['night']['magic'] = {	"Kindred White Mage", "Kindred Bard", "Kindred Summoner", "Kindred Black Mage", "Kindred Red Mage", 
								"Duke Berith", "Marquis Decarabia", "Prince Seere", "Marquis Orias", "Marquis Nebiros", "Duke Haures",
								"Hydra White Mage", "Hydra Bard", "Hydra Summoner", "Hydra Black Mage", "Hydra Red Mage", 
								"Vanguard Amputator", "Vanguard Bugler", "Vanguard Dollmaster", "Vanguard Mesmerizer", "Vanguard Vexer", "Soulsender Fugbrag", "Reapertongue Gadgquok", "Battlechoir Gitchfotch", 
								"Vanguard Constable", "Vanguard Minstrel", "Vanguard Protector", "Vanguard Thaumaturge", "Vanguard Undertaker", "Gi'Pha Manameister", "Gu'Nhi Noondozer", "Ra'Gho Darkfount", "Va'Zhe Pummelsong",  
								"Vanguard Chanter", "Vanguard Oracle", "Vanguard Prelate", "Vanguard Priest", "Vanguard Visionary", "Loo Hepe the Eyepiercer", "Xoo Kaza the Solemn", "Haa Pevi the Stentorian", "Xuu Bhoqa the Enigma", "Fuu Tzapo the Blessed", "Naa Yixo the Stillrage", 
								"Vanguard Alchemist", "Vanguard Enchanter", "Vanguard Maestro", "Vanguard Necromancer", "Vanguard Shaman", 
								"Elixmix Hooknose", "Gabblox Magpietongue", "Hermitrix Toothrot", "Humnox Drumbelly", "Morgmox Moldnoggin", "Mortilox Wartpaws", "Distilix Stickytoes", "Jabbrox Grannyguise", "Quicktrix Hexhands", "Wilywox Tenderpalm",
								"Ascetox Ratgums", "Brewnix Bittypupils", "Gibberox Pimplebeak", "Morblox Stubthumbs", "Whistrix Toadthroat", 
							 	"Nightmare Crawler", "Nightmare Raven", "Nightmare Uragnite", 
							 	"Nightmare Fly", "Nightmare Flytrap", "Nightmare Funguar", 
							 	"Nightmare Gaylas", "Nightmare Kraken", "Nightmare Roc", 
							 	"Nightmare Hornet", "Nightmare Bugard", 
								"Gosspix Blabblerlips", "Flamecaller Zoeqdoq", "Gi'Bhe Fleshfeaster", "Ree Nata the Melomanic", "Baa Dava the Bibliophage", 
								"Aitvaras" }

staggers['night']['ws'] =  {	"Kindred Paladin", "Kindred Warrior", "Kindred Samurai", "Kindred Dragoon", "Kindred Dark Knight", 
								"Count Zaebos", "Duke Scox", "Marquis Sabnak", "King Zagan", "Count Haagenti", 
								"Hydra Paladin", "Hydra Warrior", "Hydra Samurai", "Hydra Dragoon", "Hydra Dark Knight", 
								"Vanguard Footsoldier", "Vanguard Gutslasher", "Vanguard Impaler", "Vanguard Neckchopper", "Vanguard Trooper", "Wyrmgnasher Bjakdek", "Bladerunner Rokgevok", "Bloodfist Voshgrosh", "Spellspear Djokvukk", 
								"Vanguard Defender", "Vanguard Drakekeeper", "Vanguard Hatamoto", "Vanguard Vigilante", "Vanguard Vindicator", "Ze'Vho Fallsplitter", "Zo'Pha Forgesoul", "Bu'Bho Truesteel", 
								"Vanguard Exemplar", "Vanguard Inciter", "Vanguard Partisan", "Vanguard Persecutor", "Vanguard Skirmisher", "Maa Febi the Steadfast", "Muu Febi the Steadfast", 
								"Vanguard Armorer", "Vanguard Dragontamer", "Vanguard Ronin", "Vanguard Smithy",
								"Buffrix Eargone", "Cloktix Longnail", "Sparkspox Sweatbrow", "Ticktox Beadyeyes", "Tufflix Loglimbs", "Wyrmwix Snakespecs", "Karashix Swollenskull", "Smeltix Thickhide", "Wasabix Callusdigit", "Anvilix Sootwrists", "Scruffix Shaggychest", "Tymexox Ninefingers", "Scourquix Scaleskin",
								"Draklix Scalecrust", "Moltenox Stubthumbs", "Ruffbix Jumbolobes", "Shisox Widebrow", "Tocktix Thinlids",
								"Nightmare Bunny", "Nightmare Eft", "Nightmare Mandragora", 
								"Nightmare Hippogryph", "Nightmare Sabotender", "Nightmare Sheep", 
								"Nightmare Snoll", "Nightmare Stirge", "Nightmare Weapon",
								"Nightmare Makara", "Nightmare Cluster", 
								"Shamblix Rottenheart", "Elvaansticker Bxafraff", "Qu'Pho Bloodspiller", "Te'Zha Ironclad", "Koo Rahi the Levinblade", 
								"Barong", "Alklha", "Stihi", "Fairy Ring", "Stcemqestcint", "Stringes", "Suttung" }
staggers['night']['random'] = {"Nightmare Taurus"}
staggers['night']['none'] = {"Animated Claymore", "Animated Dagger", "Animated Great Axe", "Animated Gun", "Animated Hammer", "Animated Horn", "Animated Kunai", "Animated Knuckles", "Animated Longbow", "Animated Longsword", "Animated Scythe", "Animated Shield", "Animated Spear", "Animated Staff", "Animated Tabar", "Animated Tachi", "Fire Pukis", "Petro Pukis", "Poison Pukis", "Wind Pukis", "Kindred's Vouivre", "Kindred's Wyvern", "Kindred's Avatar", "Vanguard Eye", "Prototype Eye", "Nebiros's Avatar", "Haagenti's Avatar", "Caim's Vouivre", "Andras's Vouivre", "Adamantking Effigy", "Avatar Icon", "Goblin Replica", "Serjeant Tombstone", "Zagan's Wyvern", "Hydra's Hound", "Hydra's Wyvern", "Hydra's Avatar", "Rearguard Eye", "Adamantking Effigy", "Adamantking Image", "Avatar Icon", "Avatar Idol", "Effigy Prototype", "Goblin Replica", "Goblin Statue", "Icon Prototype", "Manifest Icon", "Manifest Icon", "Prototype Eye", "Serjeant Tombstone", "Statue Prototype", "Tombstone Prototype", "Vanguard Eye", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Crow", "Vanguard's Hecteyes", "Vanguard's Scorpion", "Vanguard's Slime", "Vanguard's Wyvern", "Vanguard's Wyvern", "Vanguard's Wyvern", "Vanguard's Wyvern", "Warchief Tombstone"}

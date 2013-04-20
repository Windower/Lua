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
staggers = T{'morning','day','night'}
staggers['morning'] = T{}
staggers['morning']['ja'] = {"Nightmare Bugard", "Nightmare Crawler", "Nightmare Fly", "Nightmare Flytrap", "Nightmare Funguar", "Nightmare Gaylas", "Nightmare Hornet", "Nightmare Kraken", "Nightmare Raven", "Nightmare Roc", "Nightmare Uragnite", "Vanguard Ambusher", "Vanguard Assassin", "Vanguard Beasttender", "Vanguard Footsoldier", "Vanguard Gutslasher", "Vanguard Hitman", "Vanguard Impaler", "Vanguard Kusa", "Vanguard Liberator", "Vanguard Mason", "Vanguard Militant", "Vanguard Neckchopper", "Vanguard Ogresoother", "Vanguard Pathfinder", "Vanguard Pitfighter", "Vanguard Purloiner", "Vanguard Salvager","Vanguard Sentinel","Vanguard Trooper","Vanguard Welldigger"}
staggers['morning']['magic'] = {"Nightmare Bunny", "Nightmare Cluster", "Nightmare Eft", "Nightmare Hippogryph", "Nightmare Makara", "Nightmare Mandragora", "Nightmare Sabotender", "Nightmare Sheep", "Nightmare Snoll", "Nightmare Stirge", "Nightmare Weapon", "Vanguard Alchemist", "Vanguard Amputator", "Vanguard Bugler", "Vanguard Chanter", "Vanguard Constable", "Vanguard Dollmaster", "Vanguard Enchanter", "Vanguard Maestro", "Vanguard Mesmerizer", "Vanguard Minstrel", "Vanguard Necromancer", "Vanguard Oracle", "Vanguard Prelate", "Vanguard Priest", "Vanguard Protector", "Vanguard Shaman", "Vanguard Thaumaturge", "Vanguard Undertaker", "Vanguard Vexer", "Vanguard Visionary"}
staggers['morning']['ws'] = {"Nightmare Crab", "Nightmare Dhalmel", "Nightmare Diremite", "Nightmare Goobbue", "Nightmare Leech", "Nightmare Manticore", "Nightmare Raptor", "Nightmare Scorpion", "Nightmare Tiger", "Nightmare Treant", "Nightmare Worm", "Vanguard Armorer", "Vanguard Backstabber", "Vanguard Defender", "Vanguard Dragontamer", "Vanguard Drakekeeper", "Vanguard Exemplar", "Vanguard Grappler", "Vanguard Hatamoto", "Vanguard Hawker", "Vanguard Inciter", "Vanguard Partisan", "Vanguard Persecutor", "Vanguard Pillager", "Vanguard Predator", "Vanguard Ronin", "Vanguard Skirmisher", "Vanguard Smithy", "Vanguard Tinkerer", "Vanguard Vigilante", "Vanguard Vindicator"}
staggers['morning']['random'] = {"Aitvaras", "Alklha", "Antaeus", "Anvilix Sootwrists", "Apocalyptic Beast", "Arch Antaeus", "Arch Apocalyptic Beast", "Arch Christelle", "Arch Goblin Golem", "Arch Gu'Dha Effigy", "Arch Overlord Tombstone", "Arch Tzee Xicu Idol", "Baa Dava the Bibliophage", "Bandrix Rockjaw", "Barong", "Battlechoir Gitchfotch", "Bladeburner Rokgevok", "Blazox Boneybod", "Bloodfist Voshgrosh", "Bootrix Jaggedelbow", "Bu'Bho Truesteel", "Buffrix Eargone", "Cirrate Christelle", "Cloktix Longnail", "Diabolos Club", "Diabolos Diamond", "Diabolos Heart", "Diabolos Letum", "Diabolos Nox", "Diabolos Somnus", "Diabolos Spade", "Diabolos Umbra", "Distilix Stickytoes", "Doo Peku the Fleetfoot", "Elixmix Hooknose", "Elvaansticker Bxafraff", "Eremix Snottynostril", "Fairy Ring", "Feralox Honeylips", "Feralox's Slime", "Flamecaller Zoeqdoq", "Fuu Tzapo the Blessed", "Gabblox Magpietongue", "Gi'Bhe Fleshfeaster", "Gi'Pha Manameister", "Goblin Golem", "Gosspix Blabblerlips", "Gu'Dha Effigy", "Gu'Nhi Noondozer", "Haa Pevi the Stentorian", "Hamfist Gukhbuk", "Hermitrix Toothrot", "Humnox Drumbelly", "Jabbrox Grannyguise", "Jabkix Pigeonpec", "Karashix Swollenskull", "Kikklix Longlegs", "Ko'Dho Cannonball", "Koo Rahi the Levinblade", "Loo Hepe the Eyepiercer", "Lost Aitvaras", "Lost Alklha", "Lost Barong", "Lost Fairy Ring", "Lost Nant'ina", "Lost Scolopendra", "Lost Stcemqestcint", "Lost Stihi", "Lost Stringes", "Lost Suttung", "Lurklox Dhalmelneck", "Lyncean Juwgneg", "Maa Febi the Steadfast", "Mobpix Mucousmouth", "Morgmox Moldnoggin", "Mortilox Wartpaws", "Muu Febi the Steadfast", "Naa Yixo the Stillrage", "Nant'ina", "Nightmare Taurus", "Overlord's Tombstone", "Prowlox Barrelbelly", "Quicktrix Hexhands", "Qu'Pho Bloodspiller", "Ra'Gho Darkfount", "Ra'Gho's Avatar", "Reapertongue Gadgquok", "Ree Nata the Melomanic", "Rutrix Hamgams", "Scolopendra", "Scourquix Scaleskin", "Scourquix's Wyvern", "Scruffix Shaggychest", "Shamblix Rottenheart", "Slystix Megapeepers", "Smeltix Thickhide", "Snypestix Eaglebeak", "Soulsender Fugbrag", "Sparkspox Sweatbrow", "Spellspear Djokvukk", "Stcemqestcint", "Steelshank Kratzvatz", "Stihi", "Stringes", "Suttung", "Tee Zaksa the Ceaseless", "Te'Zha Ironclad", "Ticktox Beadyeyes", "Trailblix Goatmug", "Tufflix Loglimbs", "", "Tymexox Ninefingers", "Tzee Xicu Idol", "Va'Rhu Bodysnatcher", "Va'Zhe Pummelsong", "Voidstreaker Butchnotch", "Wasabix Callusdigit", "Wilywox Tenderpalm", "Woodnix Shrillwhistle", "Wuu Qoho the Razorclaw", "Wyrmgnasher Bjakdek", "Wyrmwix Snakespecs", "Xoo Kaza the Solemn", "Xuu Bhoqa the Enigma", "Ze'Vho Fallsplitter", "Zo'Pha Forgesoul"}
staggers['morning']['none'] = {"Adamantking Effigy", "Adamantking Image", "Avatar Icon", "Avatar Idol", "Effigy Prototype", "Goblin Replica", "Goblin Statue", "Icon Prototype", "Manifest Icon", "Manifest Icon", "Prototype Eye", "Serjeant Tombstone", "Statue Prototype", "Tombstone Prototype", "Vanguard Eye", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Crow", "", "Vanguard's Hecteyes", "Vanguard's Scorpion", "Vanguard's Slime", "Vanguard's Wyvern", "Vanguard's Wyvern", "Vanguard's Wyvern", "Vanguard's Wyvern", "Warchief Tombstone"}
staggers['day'] = T{}
staggers['day']['ja'] = {"Nightmare Bunny", "Nightmare Cluster", "Nightmare Eft", "Nightmare Hippogryph", "Nightmare Makara", "Nightmare Mandragora", "Nightmare Sabotender", "Nightmare Sheep", "Nightmare Snoll", "Nightmare Stirge", "Nightmare Weapon", "Vanguard Alchemist", "Vanguard Amputator", "Vanguard Bugler", "Vanguard Chanter", "Vanguard Constable", "Vanguard Dollmaster", "Vanguard Enchanter", "Vanguard Maestro", "Vanguard Mesmerizer", "Vanguard Minstrel", "Vanguard Necromancer", "Vanguard Oracle", "Vanguard Prelate", "Vanguard Priest", "Vanguard Protector", "Vanguard Shaman", "Vanguard Thaumaturge", "Vanguard Undertaker", "Vanguard Vexer", "Vanguard Visionary"}
staggers['day']['magic'] = {"Nightmare Crab", "Nightmare Dhalmel", "Nightmare Diremite", "Nightmare Goobbue", "Nightmare Leech", "Nightmare Manticore", "Nightmare Raptor", "Nightmare Scorpion", "Nightmare Tiger", "Nightmare Treant", "Nightmare Worm", "Vanguard Armorer", "Vanguard Backstabber", "Vanguard Defender", "Vanguard Dragontamer", "Vanguard Drakekeeper", "Vanguard Exemplar", "Vanguard Grappler", "Vanguard Hatamoto", "Vanguard Hawker", "Vanguard Inciter", "Vanguard Partisan", "Vanguard Persecutor", "Vanguard Pillager", "Vanguard Predator", "Vanguard Ronin", "Vanguard Skirmisher", "Vanguard Smithy", "Vanguard Tinkerer", "Vanguard Vigilante", "Vanguard Vindicator"}
staggers['day']['ws'] = {"Nightmare Bugard", "Nightmare Crawler", "Nightmare Fly", "Nightmare Flytrap", "Nightmare Funguar", "Nightmare Gaylas", "Nightmare Hornet", "Nightmare Kraken", "Nightmare Raven", "Nightmare Roc", "Nightmare Uragnite", "Vanguard Ambusher", "Vanguard Assassin", "Vanguard Beasttender", "Vanguard Footsoldier", "Vanguard Gutslasher", "Vanguard Hitman", "Vanguard Impaler", "Vanguard Kusa", "Vanguard Liberator", "Vanguard Mason", "Vanguard Militant", "Vanguard Neckchopper", "Vanguard Ogresoother", "Vanguard Pathfinder", "Vanguard Pitfighter", "Vanguard Purloiner", "Vanguard Salvager", "Vanguard Sentinel", "Vanguard Trooper", "Vanguard Welldigger"}
staggers['day']['random'] = {"Aitvaras", "Alklha", "Antaeus", "Anvilix Sootwrists", "Apocalyptic Beast", "Arch Antaeus", "Arch Apocalyptic Beast", "Arch Christelle", "Arch Goblin Golem", "Arch Gu'Dha Effigy", "Arch Overlord Tombstone", "Arch Tzee Xicu Idol", "Baa Dava the Bibliophage", "Bandrix Rockjaw", "Barong", "Battlechoir Gitchfotch", "Bladeburner Rokgevok", "Blazox Boneybod", "Bloodfist Voshgrosh", "Bootrix Jaggedelbow", "Bu'Bho Truesteel", "Buffrix Eargone", "Cirrate Christelle", "Cloktix Longnail", "Diabolos Club", "Diabolos Diamond", "Diabolos Heart", "Diabolos Letum", "Diabolos Nox", "Diabolos Somnus", "Diabolos Spade", "Diabolos Umbra", "Distilix Stickytoes", "Doo Peku the Fleetfoot", "Elixmix Hooknose", "Elvaansticker Bxafraff", "Eremix Snottynostril", "Fairy Ring", "Feralox Honeylips", "Feralox's Slime", "Flamecaller Zoeqdoq", "Fuu Tzapo the Blessed", "Gabblox Magpietongue", "Gi'Bhe Fleshfeaster", "Gi'Pha Manameister", "Goblin Golem", "Gosspix Blabblerlips", "Gu'Dha Effigy", "Gu'Nhi Noondozer", "Haa Pevi the Stentorian", "Hamfist Gukhbuk", "Hermitrix Toothrot", "Humnox Drumbelly", "Jabbrox Grannyguise", "Jabkix Pigeonpec", "Karashix Swollenskull", "Kikklix Longlegs", "Ko'Dho Cannonball", "Koo Rahi the Levinblade", "Loo Hepe the Eyepiercer", "Lost Aitvaras", "Lost Alklha", "Lost Barong", "Lost Fairy Ring", "Lost Nant'ina", "Lost Scolopendra", "Lost Stcemqestcint", "Lost Stihi", "Lost Stringes", "Lost Suttung", "Lurklox Dhalmelneck", "Lyncean Juwgneg", "Maa Febi the Steadfast", "Mobpix Mucousmouth", "Morgmox Moldnoggin", "Mortilox Wartpaws", "Muu Febi the Steadfast", "Naa Yixo the Stillrage", "Nant'ina", "Nightmare Taurus", "Overlord's Tombstone", "Prowlox Barrelbelly", "Quicktrix Hexhands", "Qu'Pho Bloodspiller", "Ra'Gho Darkfount", "Ra'Gho's Avatar", "Reapertongue Gadgquok", "Ree Nata the Melomanic", "Rutrix Hamgams", "Scolopendra", "Scourquix Scaleskin", "Scourquix's Wyvern", "Scruffix Shaggychest", "Shamblix Rottenheart", "Slystix Megapeepers", "Smeltix Thickhide", "Snypestix Eaglebeak", "Soulsender Fugbrag", "Sparkspox Sweatbrow", "Spellspear Djokvukk", "Stcemqestcint", "Steelshank Kratzvatz", "Stihi", "Stringes", "Suttung", "Tee Zaksa the Ceaseless", "Te'Zha Ironclad", "Ticktox Beadyeyes", "Trailblix Goatmug", "Tufflix Loglimbs", "", "Tymexox Ninefingers", "Tzee Xicu Idol", "Va'Rhu Bodysnatcher", "Va'Zhe Pummelsong", "Voidstreaker Butchnotch", "Wasabix Callusdigit", "Wilywox Tenderpalm", "Woodnix Shrillwhistle", "Wuu Qoho the Razorclaw", "Wyrmgnasher Bjakdek", "Wyrmwix Snakespecs", "Xoo Kaza the Solemn", "Xuu Bhoqa the Enigma", "Ze'Vho Fallsplitter", "Zo'Pha Forgesoul"}
staggers['day']['none'] = {"Adamantking Effigy", "Adamantking Image", "Avatar Icon", "Avatar Idol", "Effigy Prototype", "Goblin Replica", "Goblin Statue", "Icon Prototype", "Manifest Icon", "Manifest Icon", "Prototype Eye", "Serjeant Tombstone", "Statue Prototype", "Tombstone Prototype", "Vanguard Eye", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Crow", "", "Vanguard's Hecteyes", "Vanguard's Scorpion", "Vanguard's Slime", "Vanguard's Wyvern", "Vanguard's Wyvern", "Vanguard's Wyvern", "Vanguard's Wyvern", "Warchief Tombstone"}
staggers['night'] = T{}
staggers['night']['ja'] = {"Nightmare Crab", "Nightmare Dhalmel", "Nightmare Diremite", "Nightmare Goobbue", "Nightmare Leech", "Nightmare Manticore", "Nightmare Raptor", "Nightmare Scorpion", "Nightmare Tiger", "Nightmare Treant", "Nightmare Worm", "Vanguard Armorer", "Vanguard Backstabber", "Vanguard Defender", "Vanguard Dragontamer", "Vanguard Drakekeeper", "Vanguard Exemplar", "Vanguard Grappler", "Vanguard Hatamoto", "Vanguard Hawker", "Vanguard Inciter", "Vanguard Partisan", "Vanguard Persecutor", "Vanguard Pillager", "Vanguard Predator", "Vanguard Ronin", "Vanguard Skirmisher", "Vanguard Smithy", "Vanguard Tinkerer", "Vanguard Vigilante", "Vanguard Vindicator"}
staggers['night']['magic'] = {"Nightmare Bugard", "Nightmare Crawler", "Nightmare Fly", "Nightmare Flytrap", "Nightmare Funguar", "Nightmare Gaylas", "Nightmare Hornet", "Nightmare Kraken", "Nightmare Raven", "Nightmare Roc", "Nightmare Uragnite", "Vanguard Ambusher", "Vanguard Assassin", "Vanguard Beasttender", "Vanguard Footsoldier", "Vanguard Gutslasher", "Vanguard Hitman", "Vanguard Impaler", "Vanguard Kusa", "Vanguard Liberator", "Vanguard Mason", "Vanguard Militant", "Vanguard Neckchopper", "Vanguard Ogresoother", "Vanguard Pathfinder", "Vanguard Pitfighter", "Vanguard Purloiner", "Vanguard Salvager", "Vanguard Sentinel", "Vanguard Trooper", "Vanguard Welldigger"}
staggers['night']['ws'] = {"Nightmare Bunny", "Nightmare Cluster", "Nightmare Eft", "Nightmare Hippogryph", "Nightmare Makara", "Nightmare Mandragora", "Nightmare Sabotender", "Nightmare Sheep", "Nightmare Snoll", "Nightmare Stirge", "Nightmare Weapon", "Vanguard Alchemist", "Vanguard Amputator", "Vanguard Bugler", "Vanguard Chanter", "Vanguard Constable", "Vanguard Dollmaster", "Vanguard Enchanter", "Vanguard Maestro", "Vanguard Mesmerizer", "Vanguard Minstrel", "Vanguard Necromancer", "Vanguard Oracle", "Vanguard Prelate", "Vanguard Priest", "Vanguard Protector", "Vanguard Shaman", "Vanguard Thaumaturge", "Vanguard Undertaker", "Vanguard Vexer", "Vanguard Visionary"}
staggers['night']['random'] = {"Aitvaras", "Alklha", "Antaeus", "Anvilix Sootwrists", "Apocalyptic Beast", "Arch Antaeus", "Arch Apocalyptic Beast", "Arch Christelle", "Arch Goblin Golem", "Arch Gu'Dha Effigy", "Arch Overlord Tombstone", "Arch Tzee Xicu Idol", "Baa Dava the Bibliophage", "Bandrix Rockjaw", "Barong", "Battlechoir Gitchfotch", "Bladeburner Rokgevok", "Blazox Boneybod", "Bloodfist Voshgrosh", "Bootrix Jaggedelbow", "Bu'Bho Truesteel", "Buffrix Eargone", "Cirrate Christelle", "Cloktix Longnail", "Diabolos Club", "Diabolos Diamond", "Diabolos Heart", "Diabolos Letum", "Diabolos Nox", "Diabolos Somnus", "Diabolos Spade", "Diabolos Umbra", "Distilix Stickytoes", "Doo Peku the Fleetfoot", "Elixmix Hooknose", "Elvaansticker Bxafraff", "Eremix Snottynostril", "Fairy Ring", "Feralox Honeylips", "Feralox's Slime", "Flamecaller Zoeqdoq", "Fuu Tzapo the Blessed", "Gabblox Magpietongue", "Gi'Bhe Fleshfeaster", "Gi'Pha Manameister", "Goblin Golem", "Gosspix Blabblerlips", "Gu'Dha Effigy", "Gu'Nhi Noondozer", "Haa Pevi the Stentorian", "Hamfist Gukhbuk", "Hermitrix Toothrot", "Humnox Drumbelly", "Jabbrox Grannyguise", "Jabkix Pigeonpec", "Karashix Swollenskull", "Kikklix Longlegs", "Ko'Dho Cannonball", "Koo Rahi the Levinblade", "Loo Hepe the Eyepiercer", "Lost Aitvaras", "Lost Alklha", "Lost Barong", "Lost Fairy Ring", "Lost Nant'ina", "Lost Scolopendra", "Lost Stcemqestcint", "Lost Stihi", "Lost Stringes", "Lost Suttung", "Lurklox Dhalmelneck", "Lyncean Juwgneg", "Maa Febi the Steadfast", "Mobpix Mucousmouth", "Morgmox Moldnoggin", "Mortilox Wartpaws", "Muu Febi the Steadfast", "Naa Yixo the Stillrage", "Nant'ina", "Nightmare Taurus", "Overlord's Tombstone", "Prowlox Barrelbelly", "Quicktrix Hexhands", "Qu'Pho Bloodspiller", "Ra'Gho Darkfount", "Ra'Gho's Avatar", "Reapertongue Gadgquok", "Ree Nata the Melomanic", "Rutrix Hamgams", "Scolopendra", "Scourquix Scaleskin", "Scourquix's Wyvern", "Scruffix Shaggychest", "Shamblix Rottenheart", "Slystix Megapeepers", "Smeltix Thickhide", "Snypestix Eaglebeak", "Soulsender Fugbrag", "Sparkspox Sweatbrow", "Spellspear Djokvukk", "Stcemqestcint", "Steelshank Kratzvatz", "Stihi", "Stringes", "Suttung", "Tee Zaksa the Ceaseless", "Te'Zha Ironclad", "Ticktox Beadyeyes", "Trailblix Goatmug", "Tufflix Loglimbs", "", "Tymexox Ninefingers", "Tzee Xicu Idol", "Va'Rhu Bodysnatcher", "Va'Zhe Pummelsong", "Voidstreaker Butchnotch", "Wasabix Callusdigit", "Wilywox Tenderpalm", "Woodnix Shrillwhistle", "Wuu Qoho the Razorclaw", "Wyrmgnasher Bjakdek", "Wyrmwix Snakespecs", "Xoo Kaza the Solemn", "Xuu Bhoqa the Enigma", "Ze'Vho Fallsplitter", "Zo'Pha Forgesoul"}
staggers['night']['none'] = {"Adamantking Effigy", "Adamantking Image", "Avatar Icon", "Avatar Idol", "Effigy Prototype", "Goblin Replica", "Goblin Statue", "Icon Prototype", "Manifest Icon", "Manifest Icon", "Prototype Eye", "Serjeant Tombstone", "Statue Prototype", "Tombstone Prototype", "Vanguard Eye", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Avatar", "Vanguard's Crow", "", "Vanguard's Hecteyes", "Vanguard's Scorpion", "Vanguard's Slime", "Vanguard's Wyvern", "Vanguard's Wyvern", "Vanguard's Wyvern", "Vanguard's Wyvern", "Warchief Tombstone"}
Currency = {"Ordelle Bronzepiece","Montiont Silverpiece", "One Byne Bill","One Hundred Byne Bill","Tukuku Whiteshell", "Lungo-Nango Jadeshell"}
ProcZones = {"Dynamis - San d'Oria","Dynamis - Windurst","Dynamis - Bastok","Dynamis - Jeuno","Dynamis - Beaucedine","Dynamis - Xarcabard","Dynamis - Valkurm","Dynamis - Buburimu","Dynamis - Qufim","Dynamis - Tavnazia"}
proctype = {"ja","magic","ws","random","none"}
StaggerCount = 0
current_proc = "lolidk"
currentime = 0
goodzone = "no"
timer = "off"
tracker = "off"
proc = "off"
trposx = 1000
trposy = 250
pposx = 800
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
 	obtained = nil
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
			write('dh proc [on/off/pos x y] : Displays the current proc for the targeted mob.')
   			write('dh ll create : Creates and loads a light luggage profile that will automatically lot all currency.')
		elseif params[1]:lower() == "timer" then
   			if params[2]:lower() == "on" or params[2]:lower() == "off" then
    				timer = params[2]
   			else write("Invalid timer option.")
   			end
		elseif params[1]:lower() == "tracker" then
   			if params[2]:lower() == "on" then
    			tracker = "on"
				initializebox()
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
    				io.open(lua_base_path..'../../plugins/ll/dynamis-'..player..'.txt',"w"):write('if item is 1452, 1453, 1455, 1456, 1449, 1450 then lot'):close()
    				send_command('ll profile dynamis-'..player..'.txt')
   				else write("Invalid light luggage option.")
   			end
   			elseif params[1]:lower() == "proc" then
   			trposx, trposy = tonumber(params[3]), tonumber(params[4])
   			if params[2]:lower() == "on" then
   					proc = params[2]
   					write('Proc feature enabled.')
   			elseif params[2]:lower() == "off" then
    				proc = params[2]
    				tb_set_visibility('proc_box',false)
    				write('Proc feature disabled.')
    		elseif params[2]:lower() == "pos" then
   					pposx, pposy = tonumber(params[3]), tonumber(params[4])
   					initializeproc()
   			end
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
 		obtainedf()
    	initializebox()
 	end
 	return new, color
end

function obtainedf()
--	write('obtainedf function')
 	obtained = ""
 	for i=1,#Currency do
   			obtained = (obtained..Currency[i]..': '..Currency[Currency[i]]..' \n ')
 	end
end

function checkzone()
--	write('checkzone function')
	goodzone = 'no'
	currentzone = get_ffxi_info()['zone']:lower()
	for i=1, #ProcZones do
		if currentzone == ProcZones[i]:lower() then
			goodzone = 'yes'
		end
	end
	if goodzone == 'no' then
		tb_set_visibility('proc_box',false)
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
 		tb_set_bg_visibility('dynamis_box',true)
 		tb_set_font('dynamis_box','Arial',12)
 		tb_set_text('dynamis_box',' Currency obtained:  \n '..obtained);
 	end
end


function event_time_change(...)
	if proc == 'on' then
		currenttime = get_ffxi_info()['time']
 	end
end

function event_target_change(targ_id)
--	write('event_target_change function')
	checkzone()
	if proc == 'on' then
		if targ_id ~= 0 then
			mob = get_mob_by_index(targ_id)['name']
  			setproc()
  		end
 	end
end

function setproc()
--	write('setproc function')
	current_proc = 'lolidk'
	if currenttime == nil or currenttime == '' or currenttime == nil then
		currenttime = get_ffxi_info()['time']
	end
 	if currenttime >= 00.00 and currenttime < 08.00 then
  		window = 'morning'
 	elseif currenttime >= 08.00 and currenttime < 16.00 then
  		window = 'day'
	elseif currenttime >= 16.00 and currenttime <= 23.59 then
  		window = 'night'
 	end
-- 	write(window)
 	--figure out the stupid mob's proc
 	for i=1, #proctype do
  		for j=1, #staggers[window][proctype[i]] do
 			if mob == staggers[window][proctype[i]][j] then
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
	initializeproc()
end

function initializeproc()
--		write('initializeproc function')
--	if current_proc ~= nil then
		tb_create('proc_box')
	 	tb_set_bg_color('proc_box',200,30,30,30)
	 	tb_set_color('proc_box',255,200,200,200)
	 	tb_set_location('proc_box',pposx,pposy)
	 	if goodzone == 'yes' and proc == 'on' then
	 	 	tb_set_visibility('proc_box', true)
	 	end
	 	tb_set_bg_visibility('proc_box',1)
	 	tb_set_font('proc_box','Arial',12)
	 	tb_set_text('proc_box',' Current proc for \n '..mob..'\n is '..current_proc);
	 	if proc == "off" then
	 		tb_set_visibility('proc_box', false)
	 	end
--	 	write(proc)
--	 end
end

function event_unload()
 	send_command("unalias dh")
 	tb_delete('dynamis_box')
 	tb_delete('proc_box')
end
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

_addon.name = 'DynamisHelper'
_addon.author = 'Krizz, maintainer: Skyrant'
_addon.commands = {'DynamisHelper','dh'}
_addon.version = '1.0.2.0'

require('strings')
require('sets')
config = require('config')
res = require('resources')

-- Variables
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

Currency = {"Ordelle Bronzepiece", "Montiont Silverpiece", "One Byne Bill","One Hundred Byne Bill","Tukuku Whiteshell", "Lungo-Nango Jadeshell", "Forgotten Thought", "Forgotten Hope", "Forgotten Touch", "Forgotten Journey", "Forgotten Step"}
ProcZones = res.zones:english(string.startswith-{'Dynamis'}):keyset()
proctype = {"ja","magic","ws","random","none"}
StaggerCount = 0
current_proc = "lolidk"
currentime = 0
goodzone = false
timer = "off"
tracker = "off"
proc = "off"
trposx = 1000
trposy = 250
pposx = 800
pposy = 250

settings = config.load()
timer = settings['timer']
tracker = settings['tracker']
trposx = settings['trposx']
trposy = settings['trposy']
proc = settings['proc']
pposx = settings['pposx']
pposy = settings['pposy']

for i=1, #Currency do
     Currency[Currency[i]] = 0
end

windower.register_event('load', 'login', function()
    if windower.ffxi.get_info().logged_in then
        player = windower.ffxi.get_player().name
        obtained = nil
        initializebox()
    end
end)

windower.register_event('addon command',function (...)
--	 print('event_addon_command function')
	local params = {...};
	if #params < 1 then
		return	end
		if params[1] then
			if params[1]:lower() == "help" then
   				print('dh help : Shows help message')
  				print('dh timer [on/off] : Displays a timer each time a mob is staggered.')
   				print('dh tracker [on/off/reset/pos x y] : Tracks the amount of currency obtained.')
				print('dh proc [on/off/pos x y] : Displays the current proc for the targeted mob.')
   				print('dh ll create : Creates and loads a light luggage profile that will automatically lot all currency.')
   				--print(goodzone)
   				--print(ProcZones)
			elseif params[1]:lower() == "timer" then
   				if params[2]:lower() == "on" or params[2]:lower() == "off" then
    				timer = params[2]
					print('Timer feature is '..timer)
   				else print("Invalid timer option.")
   			end
		elseif params[1]:lower() == "tracker" then
   			if params[2]:lower() == "on" then
    			tracker = "on"
				initializebox()
				windower.text.set_visibility('dynamis_box',true)
    			print('Tracker enabled')
   			elseif params[2]:lower() == "off" then
    			tracker = "off"
    			windower.text.set_visibility('dynamis_box',false)
    			print('Tracker disabled')
   			elseif params[2]:lower() == "reset" then
				for i=1, #Currency do
     				Currency[Currency[i]] = 0
     			end
      			obtainedf()
     	 		initializebox()
      			print('Tracker reset')
   			elseif params[2]:lower() == "pos" then
    			if params[3] then
     				trposx, trposy = tonumber(params[3]), tonumber(params[4])
     				obtainedf()
     				initializebox()
    			else print("Invalid tracker option.")
    			end
    		end
  		elseif params[1]:lower() == "ll" then
   			if params[2]:lower() == "create" then
    			player = windower.ffxi.get_player()['name']
    			io.open(windower.addon_path..'../../plugins/ll/dynamis-'..player..'.txt',"w"):write('if item is 1452, 1453, 1455, 1456, 1449, 1450 then lot'):close()
    			windower.send_command('ll profile dynamis-'..player..'.txt')
   			else print("Invalid light luggage option.")
   			end
  	 elseif params[1]:lower() == "proc" then
   			if params[2]:lower() == "on" then
   				proc = params[2]
   				print('Proc feature enabled.')
   			elseif params[2]:lower() == "off" then
   		 		proc = params[2]
    			windower.text.set_visibility('proc_box',false)
    			print('Proc feature disabled.')
    		elseif params[2]:lower() == "pos" then
   				pposx, pposy = tonumber(params[3]), tonumber(params[4])
   				initializeproc()
   			end
		end
	end
end)


windower.register_event('incoming text',function (original, new, color)
--	print('event_incoming_text function')
	if timer == 'on' then
  		a,b,fiend = string.find(original,"%w+'s attack staggers the (%w+)%!")
   		if fiend == 'fiend' then
			StaggerCount = StaggerCount + 1
    		windower.send_command('timers c '..StaggerCount..' 30 down')
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
-- 		a,b,item = string.find(original,"%w+ obtains an? ..(.*)..\46")
 		if item ~= nil then
 			item = item:lower()
 			for i=1, #Currency do
				if item == Currency[i]:lower() then
   					Currency[Currency[i]] = Currency[Currency[i]] + 1
   				end
 			end
 			obtainedf()
 		end
    	initializebox()
 	end
 	return new, color
end)

function obtainedf()
	obtained = nil
 	for i=1,#Currency do
 		if Currency[Currency[i]] ~= 0 then
  			if obtained == nil then
  				obtained = " "
  			end
   			obtained = (obtained..Currency[i]..': '..Currency[Currency[i]]..' \n ')
 		end
 	end
end

windower.register_event('zone change', function(id)
	goodzone = ProcZones:contains(id)
	if not goodzone then
		windower.text.set_visibility('proc_box', false)
	end
end)

function initializebox()
	if obtained ~= nil and tracker == "on" then
 		windower.text.create('dynamis_box')
 		windower.text.set_bg_color('dynamis_box',200,30,30,30)
 		windower.text.set_color('dynamis_box',255,200,200,200)
		windower.text.set_location('dynamis_box',trposx,trposy)
 		windower.text.set_visibility('dynamis_box',true)
 		windower.text.set_bg_visibility('dynamis_box',true)
 		windower.text.set_font('dynamis_box','Arial',12)
 		windower.text.set_text('dynamis_box',obtained);
 	end
end

windower.register_event('target change', function(targ_id)
	--goodzone = ProcZones:contains(windower.ffxi.get_info().zone)
	if goodzone and proc == 'on' and targ_id ~= 0 then
        mob = windower.ffxi.get_mob_by_index(targ_id)['name']
        setproc()
 	end

 	--print(ProcZones:contains(windower.ffxi.get_info().zone))

end)

function setproc()
	current_proc = 'lolidk'
    local currenttime = windower.ffxi.get_info().time
 	if currenttime >= 0*60 and currenttime < 8*60 then
  		window = 'morning'
 	elseif currenttime >= 8*60 and currenttime < 16*60 then
  		window = 'day'
	elseif currenttime >= 16*60 and currenttime <= 24*60 then
  		window = 'night'
 	end
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
--		print('initializeproc function')
		windower.text.create('proc_box')
	 	windower.text.set_bg_color('proc_box',200,30,30,30)
	 	windower.text.set_color('proc_box',255,200,200,200)
	 	windower.text.set_location('proc_box',pposx,pposy)
	 	if proc == 'on' then
	 	 	windower.text.set_visibility('proc_box', true)
	 	end
	 	windower.text.set_bg_visibility('proc_box',1)
	 	windower.text.set_font('proc_box','Arial',12)
	 	windower.text.set_text('proc_box',' Current proc for \n '..mob..'\n is '..current_proc);
	 	if proc == "off" then
	 		windower.text.set_visibility('proc_box', false)
	 	end
end

windower.register_event('unload',function ()
 	windower.text.delete('dynamis_box')
 	windower.text.delete('proc_box')
end)

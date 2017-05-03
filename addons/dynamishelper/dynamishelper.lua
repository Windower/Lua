--Copyright © 2013, Krizz, Skyrant
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--  * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--  * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--  * Neither the name of Dynamis Helper nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

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
_addon.version = '2.3'

config = require('config')
texts = require('texts')
res = require('resources')

ProcZones = res.zones:english(string.startswith-{'Dynamis'}):keyset()

-------------------------------------------------------------------------------
-- Define default values ------------------------------------------------------
-------------------------------------------------------------------------------
defaults = T{}
defaults.window = {}

-------------------------------------------------------------------------------
-- Load defaults from settings.xml --------------------------------------------
-------------------------------------------------------------------------------
settings = config.load(defaults)

-- upgrade to new settings file if old settings still exist -------------------
if settings.trposx and settings.trposy then
    -- copy position from old config to new one
    settings.window.pos.x = settings.trposx
    settings.window.pos.y = settings.trposy
    -- delete old settings here -----------------------------------------------
    config.save(settings, 'all')
end

Green = "\\cs(0,255,0)"
Red = "\\cs(255,0,0)"
Yellow = "\\cs(255,255,0)"

current_mob = nil
current_proc = nil
obj_time = 0
end_time = 0

window = texts.new(" ",settings.window,settings)
w = T{}

-------------------------------------------------------------------------------
-- Initialize the Currency array. We need this to keep track of the drops -----
-------------------------------------------------------------------------------
function init_currency()
    Currency = T{"Ordelle Bronzepiece","Montiont Silverpiece","One Byne Bill",
                "One Hundred Byne Bill","Tukuku Whiteshell","Lungo-Nango Jadeshell",
                "Forgotten Thought","Forgotten Hope","Forgotten Touch","Forgotten Journey","Forgotten Step"}
    for i=1, #Currency do
        w[Currency[i]] = 0
    end
end
init_currency()

-------------------------------------------------------------------------------
-- Initialize the time Granules array. Keeps track of the time extensions -----
-------------------------------------------------------------------------------
function init_granules()
    Granules = T{"Crimson granules of time","Azure granules of time","Amber granules of time",
                "Alabaster granules of time","Obsidian granules of time"}
    for i=1, #Granules do
        w[Granules[i]] = 0
    end
end
init_granules()

-------------------------------------------------------------------------------
-- The on screen window structure ---------------------------------------------
-------------------------------------------------------------------------------
function init_window()
    local showCurrencyDivider = false
    window.text(window,Yellow.."Time remaining: ${time|initializing...}")
    window.appendline(window,"\\cr————————————————————")
    window.appendline(window,"${current_mob|(unknown)}\n"..Green.."${current_proc|(none)}")
    window.appendline(window,"\\cr————————————————————")
    for i=1, #Currency do
        if w[Currency[i]] > 0 then
            showCurrencyDivider = true
            if Currency[i] == "Ordelle Bronzepiece" or Currency[i] == "Montiont Silverpiece" then
                window.appendline(window,Currency[i]..": ${"..Currency[i].."|0}")
            elseif Currency[i] == "One Byne Bill" or Currency[i] == "One Hundred Byne Bill" then
                window.appendline(window,Currency[i]..": ${"..Currency[i].."|0}")
            elseif Currency[i] == "Tukuku Whiteshell" or Currency[i] == "Lungo-Nango Jadeshell" then
                window.appendline(window,Currency[i]..": ${"..Currency[i].."|0}")
            else
                window.appendline(window,"\\cr"..Currency[i]..": ${"..Currency[i].."|0}")
            end
        end
    end
    if showCurrencyDivider then
        window.appendline(window,"\\cr————————————————————")
    end
    for i=1, #Granules do
        if(w[Granules[i]] == 1) then
            window.appendline(window,Green..Granules[i])
        else
            window.appendline(window,Red..Granules[i])
        end
    end
end
init_window()

-------------------------------------------------------------------------------
-- Register a prerendere event for the display refresh ------------------------
-------------------------------------------------------------------------------
windower.register_event('prerender', function()
    if obj_time < 1 then return end
    if obj_time ~= (end_time - os.time()) then
        obj_time = end_time - os.time()
        w.time = os.date('!%H:%M:%S', obj_time)
        window:update(w)
    end
end)
-------------------------------------------------------------------------------
-- Did we enter a Dynamis Zone? -----------------------------------------------
-------------------------------------------------------------------------------
windower.register_event('zone change', function(zone)
    if ProcZones:contains(windower.ffxi.get_info().zone) then
        init_currency()
        window:show()
    else
        window:hide()
    end
end)

window:hide()

-------------------------------------------------------------------------------
-- Check if we are in Dynamis and show the overlay ----------------------------
-------------------------------------------------------------------------------
if ProcZones:contains(windower.ffxi.get_info().zone) then
    window:show()
end
-------------------------------------------------------------------------------
-- 186  Dynamis - Bastok ------------------------------------------------------
-- 134  Dynamis - Beaucedine --------------------------------------------------
--  40  Dynamis - Buburimu ----------------------------------------------------
-- 188  Dynamis - Jeuno -------------------------------------------------------
--  41  Dynamis - Qufim -------------------------------------------------------
-- 185  Dynamis - San d'Oria --------------------------------------------------
--  42  Dynamis - Tavnazia ----------------------------------------------------
--  39  Dynamis - Valkurm -----------------------------------------------------
-- 187  Dynamis - Windurst ----------------------------------------------------
-- 135  Dynamis - Xarcabard ---------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Get the player name for light luggage profile ------------------------------
-------------------------------------------------------------------------------
windower.register_event('load', 'login', function()
    if windower.ffxi.get_info().logged_in then
        player = windower.ffxi.get_player().name
    end
end)

-------------------------------------------------------------------------------
-- Parse the chat messages for drops, staggers and time extensions ------------
-------------------------------------------------------------------------------
windower.register_event('incoming text',function (original, new, color)
    local time = nil
    local item = nil
    local fiend = original:match("%w+'s attack staggers the (%w+)%!")
    if settings.timer then
        if fiend == 'fiend' then
            windower.send_command('timers c "'..current_mob..'" 30 down stun')
            return new, color
        end
    end
    if string.find(original,"remaining in Dynamis.") then
        obj_time = (tonumber(original:match("%d+")) * 60)
        end_time = os.time() + obj_time
    end
    if string.find(original,"will be expelled from Dynamis") then
        obj_time = (tonumber(original:match("%d+")) * 60)
        end_time = os.time() + obj_time
    end
    if string.find(original,"Your stay in Dynamis has been extended by %d+ minutes.") then
        end_time = end_time + (tonumber(original:match("%d+")) * 60)
        w.time = os.date('!%H:%M:%S', end_time)
    end
    item = original:match("Obtained key item: ..(%w+ %w+ %w+ %w+)..\46")
    if item ~= nil then
        item = item:lower()
        for i=1, #Granules do
            if item == Granules[i]:lower() then
                w[Granules[i]] = 1
                init_window()
            end
        end
    end
    item = original:match("%w+ obtains an? ..(%w+ %w+ %w+ %w+)..\46")
    --a,b,item = string.find(original,"%w+ obtains an? ..(%w+ %w+ %w+ %w+)..\46")
    if item == nil then
        item = original:match("%w+ obtains an? ..(%w+ %w+ %w+)..\46")
        --a,b,item = string.find(original,"%w+ obtains an? ..(%w+ %w+ %w+)..\46")
        if item == nil then
            item = original:match("%w+ obtains an? ..(%w+%-%w+ %w+)..\46")
            --a,b,item = string.find(original,"%w+ obtains an? ..(%w+%-%w+ %w+)..\46")
            if item == nil then
                item = original:match("%w+ obtains an? ..(%w+ %w+)..\46")
                --a,b,item = string.find(original,"%w+ obtains an? ..(%w+ %w+)..\46")
            end
        end
    end
    if item ~= nil then
        item = item:lower()
        for i=1, #Currency do
            if item == Currency[i]:lower() then
            w[Currency[i]] = w[Currency[i]] + 1
            init_window()
            end
        end
    end
    return new, color
end)

-------------------------------------------------------------------------------
-- Register target change event to get the monster name -----------------------
-------------------------------------------------------------------------------
windower.register_event('target change', function(targ_id)
    current_mob = nil
    current_proc = nil
    if targ_id ~= 0 then
        mob = windower.ffxi.get_mob_by_index(targ_id)
        current_mob = mob.name
        w.current_mob = current_mob
        setproc()
    end
end)

-------------------------------------------------------------------------------
-- Find the proc for the monster based on time or job -------------------------
-------------------------------------------------------------------------------
function setproc()
    local currenttime = windower.ffxi.get_info().time
    local window
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
        w.current_proc = 'Job Ability'
    elseif current_proc == 'magic' then
        w.current_proc = 'Magic'
    elseif current_proc == 'ws' then
        w.current_proc = 'Weapon Skill'
    end
end

-------------------------------------------------------------------------------
-- Print the help Information -------------------------------------------------
-------------------------------------------------------------------------------
help = T{
size = "Usage: dh size [font size] - Your current size is %u pixel",
font = "Usage: dh font [font name] - You are currently using %q",
opacity = "Usage: dh opacity [0-100]%% - Opacity is currently at %u%%",
padding = "Usage: dh padding [size] - Padding is currently %u pixels",
bgcolor = "Usage: dh bgcolor [Red] [Green] [Blue] - Background color - Example: 255 0 0 is red",
stroke = "Usage: dh stroke [width] - Stroke width is currently %u pixels",
stopacity = "Usage: dh stopacity [0-100]%% - Stroke opacity is currently at %u%%",
stcolor = "Usage: dh stcolor [Red] [Green] [Blue] - Stroke color - Example: 255 0 0 is red",
posx = "Usage: dh posx [x] - Current window position is x=%u",
posy = "Usage: dh posy [y] - Current window position is y=%u",
ll = "Usage: dh ll create: Creates a light luggage profile to lot all dynamis currency.'"
}

function printHelp(command,val)
    if not command and not val then
        windower.add_to_chat(159,'\nDynamisHelper v2.0')
        windower.add_to_chat(159,'dh size [number]: Change the font size.')
        windower.add_to_chat(159,'dh font [Arial, Tahoma, Times "Open Sans" ...]: Change the font.')
        windower.add_to_chat(159,'dh posx [pixel]: Position on the X axis in pixel.')
        windower.add_to_chat(159,'dh posy [pixel]: Position on the Y axis in pixel.')
        windower.add_to_chat(159,'dh bgcolor [Red] [Green] [Blue] - Background color - Example: 255 0 0 is red')
        windower.add_to_chat(159,'dh opacity bg_alpha: Opacity (0-255) of the background.')
        windower.add_to_chat(159,'dh visible: Toggle addon window.')
        windower.add_to_chat(159,'dh bold: Toggle bold text.')
        windower.add_to_chat(159,'dh padding [size]: Padding of the text window.')
        windower.add_to_chat(159,'dh stroke [width]: Stroke width of the text.')
        windower.add_to_chat(159,'dh stopacity [0-100]%: Stroke opacity.')
        windower.add_to_chat(159,'dh stcolor [Red] [Green] [Blue] - Stroke color - Example: 255 0 0 is red')

        -- compatibility commands ---------------------------------------------
        windower.add_to_chat(159,'dh ll create: Creates a light luggage profile to lot all dynamis currency.')
        -----------------------------------------------------------------------
        windower.add_to_chat(159,'dh save: save your current settings.')
    else
        local m = string.format(help[command],val)
        windower.add_to_chat(159,'\nDynamisHelper v2.0')
        windower.add_to_chat(159,m)
    end
end

-------------------------------------------------------------------------------
-- Process options and save settings ------------------------------------------
-------------------------------------------------------------------------------
windower.register_event('addon command',function (...)
    local params = {...}
    if #params < 1 then
        printHelp()
        return
    end
    local command = table.remove(params, 1)
    local options = params
    if command:lower() == "help" then
        printHelp()
        return
    elseif command:lower() == "visible" then
        if window:visible() then
            window:hide()
        else
            window:show()
        end
    elseif command:lower() == "size" then
        if options[1] and tonumber(options[1]) then
            window:size(options[1])
            config.save(settings, 'all')
        else
            printHelp(command,settings.window.text.size)
        end
    elseif command:lower() == "font" then
        if options[1] then
            window:font(options[1])
            config.save(settings, 'all')
        else
            printHelp(command,settings.window.text.font)
        end
    elseif command:lower() == "posx" then
        if options[1] then
            window:pos_x(options[1])
            config.save(settings, 'all')
        else
            printHelp(command,window:pos_x())
        end
    elseif command:lower() == "posy" then
        if options[1] then
            window:pos_y(options[1])
            config.save(settings, 'all')
        else
            printHelp(command,window:pos_y())
        end
    elseif command:lower() == "opacity" then
        if options[1] and tonumber(options[1]) then
            local opacity = math.abs(tonumber(options[1]))
            if opacity > 100 then opacity = 100 end
            window:bg_transparency(opacity/100)
            config.save(settings, 'all')
        else
            printHelp(command,window:bg_transparency()*100)
        end
    elseif command:lower() == "padding" then
        if options[1] then
            window:pad(options[1])
            config.save(settings, 'all')
        else
            printHelp(command,window:pad())
        end
    elseif command:lower() == "bold" then
        if window:bold() then
            window:bold(false)
            config.save(settings, 'all')
        else
            window:bold(true)
            config.save(settings, 'all')
        end
    elseif command:lower() == "bgcolor" then
        if options[3] then
            window:bg_color(options[1],options[2],options[3])
            config.save(settings, 'all')
        else
            printHelp(command,"")
        end
    elseif command:lower() == "stroke" then
        if options[1] and tonumber(options[1]) then
            window:stroke_width(options[1])
            config.save(settings, 'all')
        else
            printHelp(command,window:stroke_width())
        end
    elseif command:lower() == "stopacity" then
        if options[1] and tonumber(options[1]) then
            local stopacity = math.abs(tonumber(options[1]))
            if stopacity > 100 then stopacity = 100 end
            window:stroke_transparency(stopacity/100)
            config.save(settings, 'all')
        else
            printHelp(command,window:stroke_transparency()*100)
        end
    elseif command:lower() == "stcolor" then
        if options[3] then
            window:stroke_color(options[1],options[2],options[3])
            config.save(settings, 'all')
        else
            printHelp(command,"")
        end
    elseif command:lower() == "ll" then
        if options[1] and options[1]:lower() == "create" then
            player = windower.ffxi.get_player()['name']
            io.open(windower.addon_path..'../../plugins/ll/dynamis-'..player..'.txt',"w"):write('if item is 1452, 1453, 1455, 1456, 1449, 1450 then lot'):close()
            windower.send_command('ll profile dynamis-'..player..'.txt')
        else
            printHelp(command,"none")
        end
    -- End of compatibility commands---------------------------------------
    elseif command:lower() == "save" then
        config.save(settings, 'all')
    else
        printHelp()
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
staggers['morning']['ja'] = {   "Kindred Thief", "Kindred Beastmaster", "Kindred Monk", "Kindred Ninja", "Kindred Ranger",
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

staggers['morning']['ws'] = {   "Kindred Paladin", "Kindred Warrior", "Kindred Samurai", "Kindred Dragoon", "Kindred Dark Knight",
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
staggers['day']['ja'] = {       "Kindred Thief", "Kindred Beastmaster", "Kindred Monk", "Kindred Ninja", "Kindred Ranger",
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

staggers['day']['magic'] = {    "Kindred White Mage", "Kindred Bard", "Kindred Summoner", "Kindred Black Mage", "Kindred Red Mage",
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
                                "Nightmare Leech", "Nightmare Worm",
                                "Gosspix Blabblerlips", "Flamecaller Zoeqdoq", "Gi'Bhe Fleshfeaster", "Ree Nata the Melomanic", "Baa Dava the Bibliophage",
                                "Aitvaras" }

staggers['day']['ws'] =  {      "Kindred Paladin", "Kindred Warrior", "Kindred Samurai", "Kindred Dragoon", "Kindred Dark Knight",
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
staggers['night']['ja'] = {     "Kindred Thief", "Kindred Beastmaster", "Kindred Monk", "Kindred Ninja", "Kindred Ranger",
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

staggers['night']['magic'] = {  "Kindred White Mage", "Kindred Bard", "Kindred Summoner", "Kindred Black Mage", "Kindred Red Mage",
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

staggers['night']['ws'] =  {    "Kindred Paladin", "Kindred Warrior", "Kindred Samurai", "Kindred Dragoon", "Kindred Dark Knight",
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

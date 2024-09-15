--[[ 
Copyright © 2024, Staticvoid(Shaw)
All rights reserved.
Redistribution and use in source and binary forms, without
modification, is permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Gallionaire nor the
      names of its author may be used to endorse or promote products
      derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Staticvoid BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

--[[
    Gallimaufry Tracker addon for Windower 4
    Tracks gallimaufry earned in Sortie per run, total held and displays it on screen
    with messages and sound effects at gallimaufry thresholds.
    More to come!
]]


_addon.name = 'Gallionaire'
_addon.author = 'Staticvoid(Shaw)'
_addon.version = '1.3'
_addon.commands = {'Gallionaire', 'ga'}

require('tables')

require('chat')

require('logger')

require('functions')

require('strings')

packets = require('packets')

files = require('files')

config = require('config')

res = require('resources')

local texts = require('texts')

----------------------------------------------------------------------------------------
local addon_path = windower.addon_path

-- Paths to the sound files within the waves folder
local sound_paths = {
    outstanding = addon_path .. 'data/waves/30.wav',
    a_minor = addon_path .. 'data/waves/a_minor.wav',
    ohhh = addon_path .. 'data/waves/ohhh.wav',
    jo2 = addon_path .. 'data/waves/jo2.wav',
    jo3 = addon_path .. 'data/waves/jo3.wav',
    jo4 = addon_path .. 'data/waves/jo4.wav',
    toasty = addon_path .. 'data/waves/toasty.wav',
}

-----------------------------------------------------------------------------------------
myself = windower.ffxi.get_player().name

function initialization()
    update_on_zone = true
    start_up = true
	previous_gallimaufry = 0
	earned_gallimaufry = 0
    coroutine.schedule(induct_data,0.5)
end

function induct_data()
    if not windower.ffxi.get_info().logged_in then
        return
    end
    local packet = packets.new('outgoing', 0x115, {})
    packets.inject(packet)
end

initialization()

local last_update_time = 0
local update_interval = 5 -- might want to adjust this 

windower.register_event('incoming chunk',function(id, org, modi, is_injected, is_blocked)
    if is_injected or id ~= 0x118 then return end
    local current_time = os.clock()
    if current_time - last_update_time < update_interval then
        return
    end
    
    local p = packets.parse('incoming', org)
    local new_gallimaufry = p["Gallimaufry"]

    if start_up then
        previous_gallimaufry = new_gallimaufry
        start_up = false
    elseif new_gallimaufry ~= previous_gallimaufry then
        earned_gallimaufry = earned_gallimaufry + (new_gallimaufry - previous_gallimaufry)
        previous_gallimaufry = new_gallimaufry
        update_display()
    end
    last_update_time = current_time
end)


-- Display settings
local settings = config.load({
    pos = {x = 301, y = -5},
    bg = {alpha = 255, red = 0, green = 0, blue = 40},
    text = {size = 10, font = 'Comic Sans MS', red = 255, green = 255, blue = 255},
    padding = 1,
    gallimaufry_record = 0,
    --gallimaufryGoal = 2500000
})
	--gallimaufryGoal = settings.gallimaufryGoal
-- UI elements
local display = texts.new('', settings, settings)
display:pos(settings.pos.x, settings.pos.y)


local player_name = windower.ffxi.get_info().logged_in and windower.ffxi.get_player().name
local gallimaufry_record = settings.gallimaufry_record
local in_sortie_zone = false
local thresholds = {10000, 20000, 30000, 40000, 50000, 60000}

-- Function to display inspirational message at milestones and play sounds
last_threshold = 0

function display_message(earned_gallimaufry)
    if toggle_sound then
		if earned_gallimaufry >= 60000 and last_threshold < 60000 then
			windower.add_to_chat(200, '60,000! You\'re a Gallimonster!')
			windower.play_sound(sound_paths.outstanding)
			last_threshold = 60000
		elseif earned_gallimaufry >= 50000 and last_threshold < 50000 then
			windower.add_to_chat(200, '50,000! Incredible!')
			windower.play_sound(sound_paths.a_minor)
			last_threshold = 50000
		elseif earned_gallimaufry >= 40000 and last_threshold < 40000 then
			windower.add_to_chat(200, '40,000, Let\'s go!')
			windower.play_sound(sound_paths.a_minor)
			last_threshold = 40000
		elseif earned_gallimaufry >= 30000 and last_threshold < 30000 then
			windower.add_to_chat(200, "30,000 good work.")
			last_threshold = 30000
		elseif earned_gallimaufry >= 20000 and last_threshold < 20000 then
			windower.add_to_chat(200, '20,000 Keep up the pace!')
			last_threshold = 20000
		elseif earned_gallimaufry >= 10000 and last_threshold < 10000 then
			windower.add_to_chat(200, '10,000. Nice.')
			last_threshold = 10000
		end
	end
end
-- Function to interpolate between colors
local function interpolate_color(start_color, end_color, fraction)
    local red = start_color.red + (end_color.red - start_color.red) * fraction
    local green = start_color.green + (end_color.green - start_color.green) * fraction
    local blue = start_color.blue + (end_color.blue - start_color.blue) * fraction
    return {red = red, green = green, blue = blue}
end

-- Function to determine the interpolated color based on gallimaufry count
local function determine_color(gallimaufry)
    local thresholds = {
        {value = 0, color = {red = 255, green = 0, blue = 0}},       -- Red
        {value = 20000, color = {red = 255, green = 165, blue = 0}}, -- Orange
        {value = 30000, color = {red = 255, green = 255, blue = 0}}, -- Yellow
        {value = 40000, color = {red = 0, green = 255, blue = 0}},   -- Green
        {value = 50000, color = {red = 0, green = 0, blue = 255}},   -- Blue
        {value = 60000, color = {red = 140, green = 0, blue = 140}}  -- Purple
    }

    for i = 1, #thresholds - 1 do
        local current = thresholds[i]
        local next = thresholds[i + 1]

        if gallimaufry >= current.value and gallimaufry < next.value then
            local fraction = (gallimaufry - current.value) / (next.value - current.value)
            return interpolate_color(current.color, next.color, fraction)
        end
    end

    -- If gallimaufry goes further we maintain the last color (purple)
    return thresholds[#thresholds].color
end
function format_with_commas(amount)
    local formatted = tostring(amount):reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return formatted:sub(1,1) == "," and formatted:sub(2) or formatted
end

local shard_metal_ids = {
    A = { shard = 9906, metal = 9918 },  
    B = { shard = 9907, metal = 9919 },
    C = { shard = 9908, metal = 9920 },
    D = { shard = 9909, metal = 9921 },
    E = { shard = 9910, metal = 9922 },
    F = { shard = 9911, metal = 9923 },
    G = { shard = 9912, metal = 9924 },
    H = { shard = 9913, metal = 9925 },
}


local function has_item(item_id)
    local temp_items = windower.ffxi.get_items(0) 
    for _, item in ipairs(temp_items) do
        if item.id == item_id then
            return true
        end
    end
    return false
end

-- Function to generate the display string for the shards and metals
local function get_sector_display()
    local display_str = ""
    local displayed_keys = { "A", "B", "C", "D", "E", "F", "G", "H" }
    for _, sector in ipairs(displayed_keys) do
        local ids = shard_metal_ids[sector]
        local shard_color = has_item(ids.shard) and "\\cs(0,255,0)√\\cr" or " "
        local metal_color = has_item(ids.metal) and "\\cs(0,255,0)√\\cr" or " "
        display_str = display_str .. sector .. ":" .. shard_color .."|".. metal_color .. " "
    end
    return display_str
end

function update_display()

		
        -- Determine the color for earned_gallimaufry based on its value
        local color = determine_color(earned_gallimaufry)
        
        -- Format the text with earned_gallimaufry in a specific color
         local shard_metal_display = get_sector_display()
		local text = string.format(
        'Gallimaufry: %s   |   Instance Record: %s   |   \\cs(%d,%d,%d)Instance Gallimaufry:  %s\\cr  |  Shard/Metal  %s  ',
        format_with_commas(previous_gallimaufry),
        format_with_commas(gallimaufry_record),
        color.red, color.green, color.blue,
        format_with_commas(earned_gallimaufry),
        shard_metal_display
    )
        -------------  ***    Fonts   Verdana   Impact    Lucida Console    Verdana and impact were close 2nd and 3rd
        -- white
        display:color(255, 255, 255)
        
        -- Update display with formatted text
        display:text(text)
        
        display_message(earned_gallimaufry)

end


math.randomseed(os.time())

local function generate_random_number(min,max)
    return math.random(min, max)
end
--[[
	 text we want to listen for and associated soundclips,  using this dictionary table structure; one can define as many scenarios as desired.
	 this is setup for the MB setup, but could be modified to include the melee method, just copy these dictionary lines and add the weaponskills you are likely to 
	 hit the hardest with.
]]
local scenarios = {
    stonemaxdmg = {words = {myself, '99999','Stone','damage'}, sound = sound_paths.jo3, sound2 = sound_paths.jo2},
	firemaxdmg = {words = {myself, '99999','Fire','damage'}, sound = sound_paths.toasty},
	--icemaxdmg = {words = {myself, '99999','Blizza'}, sound = sound_paths.jo3, sound2 = sound_paths.ohhh},
	maxdmg = {words = {myself, '99999','damage'}, sound = sound_paths.ohhh, sound2 = sound_paths.jo2, sound3 = sound_paths.jo4},
	--thundermaxdmg = {words = {myself, '99999', 'Thund'}, sound = sound_paths.ohhh, sound2 = sound_paths.jo2, sound3 = sound_paths.jo4},
	--aeromaxdmg = {words = {myself, '99999', 'Aero'}, sound = sound_paths.ohhh, sound2 = sound_paths.jo2, sound3 = sound_paths.jo4},
	--watermaxdmg = {words = {myself, '99999', 'Water'}, sound = sound_paths.ohhh, sound2 = sound_paths.jo2, sound3 = sound_paths.jo4},
	
	--tester = {words = {myself, 'Savage Blade'}, sound = sound_paths.jo3, sound2 = sound_paths.ohhh},

}

-- Function to check if all target words are present in the text
local function contains_all_words(text, words)
    for _, word in ipairs(words) do
        if not string.find(text:lower(), word:lower()) then
            return false
        end
    end
    return true
end

windower.register_event('incoming text', function(original, modified, original_mode, modified_mode)
    if toggle_sound then--and (zone_id == 275 or zone_id == 133 or zone_id == 189) 
		for _, data in pairs(scenarios) do
			if contains_all_words(original, data.words) then
				randomNumber = generate_random_number(1,18)
				if randomNumber <= 6 then
				windower.play_sound(data.sound)
				elseif randomNumber > 6 and randomNumber <= 12 then
					if data.sound2 then
				windower.play_sound(data.sound2)
					else
				windower.play_sound(data.sound)
					end
				elseif randomNumber >= 13 and randomNumber <= 18 then
					if data.sound3 then
				windower.play_sound(data.sound3)
					else
				windower.play_sound(data.sound2)
					end
				end
				break
			end
		end
	end
    local text,mode = modified, tonumber(original_mode)
	if string.find(text, _addon.name) or (not string.find(text, 'metal') or string.find(text, 'shard')) then
    update_display()
    coroutine.sleep(2)
    return
	end

    if mode ~= 121 and mode ~= 148 then
        return
    end

    if string.find(text,_addon.name) or not string.find(text,'gallimaufry') then
      induct_data()
	  coroutine.sleep(2)
	  return
    end

end)
	toggle_sound = true
    toggle_sound = settings.toggle_sound
-- Function to toggle the sound
local function toggleSound()
     toggle_sound = not toggle_sound
    if toggle_sound then
        windower.add_to_chat(207, "Sound effects are now ON.")
		settings.toggle_sound = true
    else
        windower.add_to_chat(207, "Sound effects are now OFF.")
		settings.toggle_sound = false
    end

	config.save(settings)
end

windower.register_event('login', function(name)
    player_name = name
end)

-- Commands
windower.register_event('addon command', function(...)
    local args = {...}
--[[
    if args[1] == 'setgoal' and tonumber(args[2]) then
        local new_goal = tonumber(args[2])
        gallimaufryGoal = new_goal
        settings.gallimaufryGoal = new_goal
        config.save(settings)
        windower.add_to_chat(207, 'Gallimaufry goal set to ' .. new_goal)
        update_display()
]]
    if args[1] == 'reset' then
        earned_gallimaufry = 0
        update_display()
	elseif args[1] == 'reload' or args[1] == 'r' then
        windower.send_command('lua r gallionaire')
	elseif args[1] == 'save' or args[1] == 's' then
        save_record()
    elseif args[1] == 'togglesound' or args[1] == 'ts' then
        toggleSound()
    elseif args[1] == 'show' then
        display:show()
    elseif args[1] == 'hide' then
        display:hide()
	elseif args[1] == 'help' then
        windower.add_to_chat(200,'Gallionaire help:')
        windower.add_to_chat(200,'Commands: \n//ga reset\n//ga save / s\n//ga toggle / t\n//ga reload / r ')
        --windower.add_to_chat(200,'setgoal #####: changes the gallimaufry goal amount')
        windower.add_to_chat(200,'reset : sets the earned gallimaufry to 0 ')
        windower.add_to_chat(200,'save / s: saves earned to Record if greater #')
		windower.add_to_chat(200,'togglesound / ts: toggle sound fx off & on (default On).')
		windower.add_to_chat(200,'show makes the display visible (default).')
		windower.add_to_chat(200,'hide: hides the display box')
		windower.add_to_chat(200,'reload / r: reloads addon.')
        windower.add_to_chat(200,'Enjoy!')
    end
end)

-- Save the highest record when the addon is unloaded or the player zones out
function save_record()
    if earned_gallimaufry > 1 and earned_gallimaufry > gallimaufry_record then
        gallimaufry_record = earned_gallimaufry
        settings.gallimaufry_record = gallimaufry_record
        config.save(settings)
    end
	coroutine.sleep(1)
	if gallimaufry_record >= earned_gallimaufry then
		windower.send_command('ga reset')
	end
	update_display()
end


update_display()

    zone_id = windower.ffxi.get_info().zone
local function check_zone()

    if zone_id == 275 or zone_id == 133 or zone_id == 189 then 
		in_sortie_zone = true
		coroutine.schedule(function()
		   update_display()
       end, 2) 

    else
		save_record()
		in_sortie_zone = false
		coroutine.schedule(function()
        end, 1) 
    end
end

windower.register_event('unload', save_record)

windower.register_event('zone change', function(new_id, old_id)
	if new_id == 275 or new_id == 133 or new_id == 189 then
	coroutine.sleep(4)
	last_threshold = 0
	windower.send_command('ga reset')
	end
	if old_id == 275 or old_id == 133 or old_id == 189 then
	coroutine.sleep(3)
	log('Total haul: '..earned_gallimaufry)
	save_record()
	end
end)

windower.register_event('load', function()
notice('Welcome to Gallionaire \n//ga help  for a list of commands.')
		display:show()
		update_display()
        coroutine.schedule(function()
            check_zone()
        end , 1)
end)

function display_updatinator()
	local currentzone = windower.ffxi.get_info()['zone']
	while(currentzone == 275 or currentzone == 133 or currentzone == 189) do

		update_display()
		coroutine.sleep(5)
	end 
end
display_updatinator()
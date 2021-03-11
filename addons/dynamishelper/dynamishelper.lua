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
_addon.version = '2.0'

config = require('config')
texts = require('texts')
res = require('resources')
require('statics')

-- Dynamis Zones
-- 186  Dynamis - Bastok
-- 134  Dynamis - Beaucedine
--  40  Dynamis - Buburimu
-- 188  Dynamis - Jeuno
--  41  Dynamis - Qufim
-- 185  Dynamis - San d'Oria
--  42  Dynamis - Tavnazia
--  39  Dynamis - Valkurm
-- 187  Dynamis - Windurst
-- 135  Dynamis - Xarcabard
proc_zones = res.zones:english(string.startswith-{'Dynamis'}):keyset()

defaults = T{}
defaults.window = {}
defaults.window.pos = {}

settings = config.load(defaults)

-- Convert settings to new style
if settings.trposx and settings.trposy then
    settings.window.pos.x = settings.trposx
    settings.window.pos.y = settings.trposy
    config.save(settings)
end

green = "\\cs(0,255,0)"
red = "\\cs(255,0,0)"
yellow = "\\cs(255,255,0)"

current_mob = nil
current_proc = nil
time_remaining_in_seconds = 0
end_time = 0

window = texts.new(" ",settings.window,settings)
window:hide()
state = {}

function init_currency()
    for currency in currencies:it() do
        state[currency] = 0
    end
end
init_currency()

function init_granules()
    for granule in granules:it() do
        state[granule] = 0
    end
end
init_granules()

function init_window()
    local showCurrenciesDivider = false
    window:text(yellow .. 'Time remaining: ${time|initializing...}')
    window:appendline('\\cr————————————————————')
    window:appendline('${current_mob|(unknown)}\n' .. green .. '${current_proc|(none)}')
    window:appendline('\\cr————————————————————')
    for currency in currencies:it() do
        if state[currency] > 0 then
            showCurrenciesDivider = true
            if currency == 'Ordelle Bronzepiece' or currency == 'Montiont Silverpiece' then
                window:appendline(currency .. ': ${' .. currency .. '|0}')
            elseif currency == 'One Byne Bill' or currency == 'One Hundred Byne Bill' then
                window:appendline(currency .. ': ${' .. currency .. '|0}')
            elseif currency == 'Tukuku Whiteshell' or currency == 'Lungo-Nango Jadeshell' then
                window:appendline(currency .. ': ${' .. currency .. '|0}')
            else
                window:appendline('\\cr' .. currency .. ': ${' .. currency .. '|0}')
            end
        end
    end
    if showCurrenciesDivider then
        window.appendline(window,'\\cr————————————————————')
    end
    for granule in granules:it() do
        if(state[granule] == 1) then
            window.appendline(window, green..granule)
        else
            window.appendline(window, red..granule)
        end
    end
end
init_window()

windower.register_event('prerender', function()
    if time_remaining_in_seconds < 1 or time_remaining_in_seconds == end_time - os.time() then
        return
    end

    time_remaining_in_seconds = end_time - os.time()
    state.time = os.date('!%H:%M:%S', time_remaining_in_seconds)
    window:update(state)
end)

windower.register_event('zone change', function(zone)
    if proc_zones:contains(zone) then
        init_currency()
        init_granules()
        window:show()
    else
        window:hide()
    end
end)

if proc_zones:contains(windower.ffxi.get_info().zone) then
    window:show()
end

windower.register_event('load', 'login', function()
    if windower.ffxi.get_info().logged_in then
        player = windower.ffxi.get_player().name
    end
end)

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
    if original:endswith('You have %d+ minutes (Earth time) remaining in Dynamis.') then
        time_remaining_in_seconds = tonumber(original:match('%d+')) * 60
        end_time = os.time() + time_remaining_in_seconds
        state.time = os.date('!%H:%M:%S', end_time)
    end
    if original:match('will be expelled from Dynamis in %d+ minutes') then
        time_remaining_in_seconds = tonumber(original:match('%d+')) * 60
        end_time = os.time() + time_remaining_in_seconds
        state.time = os.date('!%H:%M:%S', end_time)
    end
    if original:match('Your stay in Dynamis has been extended by %d+ minutes.') then
        time_remaining_in_seconds = time_remaining_in_seconds + (tonumber(original:match('%d+')) * 60)
        end_time = end_time + time_remaining_in_seconds
        state.time = os.date('!%H:%M:%S', end_time)
    end
    item = original:match('Obtained key item: ..(%w+ %w+ %w+ %w+)..\46')
    if item ~= nil then
        for granule in granules:it() do
            if item == granule:lower() then
                state[granule] = 1
                init_window()
            end
        end
    end
    item = original:match('%w+ obtains an? ..(%w+ %w+ %w+ %w+)..\46')
    if item == nil then
        item = original:match('%w+ obtains an? ..(%w+ %w+ %w+)..\46')
        if item == nil then
            item = original:match('%w+ obtains an? ..(%w+%-%w+ %w+)..\46')
            if item == nil then
                item = original:match('%w+ obtains an? ..(%w+ %w+)..\46')
            end
        end
    end
    if item ~= nil then
        for currency in currencies:it() do
            if item == currency:lower() then
                state[currency] = state[currency] + 1
                init_window()
            end
        end
    end
    return new, color
end)

windower.register_event('target change', function(targ_index)
    current_mob = nil
    current_proc = nil
    if targ_index ~= 0 then
        mob = windower.ffxi.get_mob_by_index(targ_index)
        current_mob = mob.name
        state.current_mob = current_mob
        setproc()
    end
end)

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

    for i=1, #proc_types do
        for j=1, #staggers[window][proc_types[i]] do
            if current_mob == staggers[window][proc_types[i]][j] then
                current_proc = proc_types[i]
            end
        end
    end
    if current_proc == 'ja' then
        state.current_proc = 'Job Ability'
    elseif current_proc == 'magic' then
        state.current_proc = 'Magic'
    elseif current_proc == 'ws' then
        state.current_proc = 'Weapon Skill'
    end
end

help = {
    size = 'Usage: dh size [font size] - Your current size is %u pixel',
    font = 'Usage: dh font [font name] - You are currently using %q',
    opacity = 'Usage: dh opacity [0-100]%% - Opacity is currently at %u%%',
    padding = 'Usage: dh padding [size] - Padding is currently %u pixels',
    bgcolor = 'Usage: dh bgcolor [red] [green] [Blue] - Background color - Example: 255 0 0 is red',
    stroke = 'Usage: dh stroke [width] - Stroke width is currently %u pixels',
    stopacity = 'Usage: dh stopacity [0-100]%% - Stroke opacity is currently at %u%%',
    stcolor = 'Usage: dh stcolor [red] [green] [Blue] - Stroke color - Example: 255 0 0 is red',
    posx = 'Usage: dh posx [x] - Current window position is x=%u',
    posy = 'Usage: dh posy [y] - Current window position is y=%u',
}

function printHelp(command,val)
    if not command and not val then
        windower.add_to_chat(159,'DynamisHelper v' .. tostring(_addon.version))
        windower.add_to_chat(159,'dh size [number]: Change the font size.')
        windower.add_to_chat(159,'dh font [Arial, Tahoma, Times "Open Sans" ...]: Change the font.')
        windower.add_to_chat(159,'dh posx [pixel]: Position on the X axis in pixel.')
        windower.add_to_chat(159,'dh posy [pixel]: Position on the Y axis in pixel.')
        windower.add_to_chat(159,'dh bgcolor [red] [green] [Blue] - Background color - Example: 255 0 0 is red')
        windower.add_to_chat(159,'dh opacity bg_alpha: Opacity (0-255) of the background.')
        windower.add_to_chat(159,'dh visible: Toggle addon window.')
        windower.add_to_chat(159,'dh bold: Toggle bold text.')
        windower.add_to_chat(159,'dh padding [size]: Padding of the text window.')
        windower.add_to_chat(159,'dh stroke [width]: Stroke width of the text.')
        windower.add_to_chat(159,'dh stopacity [0-100]%: Stroke opacity.')
        windower.add_to_chat(159,'dh stcolor [red] [green] [Blue] - Stroke color - Example: 255 0 0 is red')

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

windower.register_event('addon command',function (command, ...)
    command = command and command:lower() or 'help'
    local options = {...}
    if command == 'help' then
        printHelp()
        return
    elseif command == 'visible' then
        if window:visible() then
            window:hide()
        else
            window:show()
        end
    elseif command == 'size' then
        if options[1] and tonumber(options[1]) then
            window:size(options[1])
            config.save(settings, 'all')
        else
            printHelp(command,settings.window.text.size)
        end
    elseif command == 'font' then
        if options[1] then
            window:font(options[1])
            config.save(settings, 'all')
        else
            printHelp(command,settings.window.text.font)
        end
    elseif command == 'posx' and tonumber(options[1])  then
        if options[1] then
            window:pos_x(options[1])
            config.save(settings, 'all')
        else
            printHelp(command,window:pos_x())
        end
    elseif command == 'posy' and tonumber(options[1])  then
        if options[1] then
            window:pos_y(options[1])
            config.save(settings, 'all')
        else
            printHelp(command,window:pos_y())
        end
    elseif command == 'opacity' then
        if options[1] and tonumber(options[1]) then
            local opacity = math.abs(tonumber(options[1]))
            if opacity > 100 then opacity = 100 end
            window:bg_transparency(opacity/100)
            config.save(settings, 'all')
        else
            printHelp(command,window:bg_transparency()*100)
        end
    elseif command == 'padding' and tonumber(options[1])  then
        if options[1] then
            window:pad(options[1])
            config.save(settings, 'all')
        else
            printHelp(command,window:pad())
        end
    elseif command == 'bold' then
        if window:bold() then
            window:bold(false)
            config.save(settings, 'all')
        else
            window:bold(true)
            config.save(settings, 'all')
        end
    elseif command == 'bgcolor' then
        if options[3] then
            window:bg_color(options[1],options[2],options[3])
            config.save(settings, 'all')
        else
            printHelp(command,'')
        end
    elseif command == 'stroke' then
        if options[1] and tonumber(options[1]) then
            window:stroke_width(options[1])
            config.save(settings, 'all')
        else
            printHelp(command,window:stroke_width())
        end
    elseif command == 'stopacity' then
        if options[1] and tonumber(options[1]) then
            local stopacity = math.abs(tonumber(options[1]))
            if stopacity > 100 then stopacity = 100 end
            window:stroke_transparency(stopacity/100)
            config.save(settings, 'all')
        else
            printHelp(command,window:stroke_transparency()*100)
        end
    elseif command == 'stcolor' then
        if options[3] then
            window:stroke_color(options[1],options[2],options[3])
            config.save(settings, 'all')
        else
            printHelp(command,'')
        end
    -- End of compatibility commands---------------------------------------
    elseif command == 'save' then
        config.save(settings)
    else
        printHelp()
    end
end)

-- Copyright © 2013-2016, Omnys of Valefor
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of Gametime nor the
      -- names of its contributors may be used to endorse or promote products
      -- derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL OMNYS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'gametime'
_addon.author = 'Omnys'
_addon.version = '0.6'
_addon.commands = {'gametime','gt'}

require('chat')
require('logger')
require('strings')
require('maths')
require('tables')

texts = require('texts')
config = require('config')
res = require('resources')

visible = false

local gt = {}
gt.delimiter = ' '
gt.days = {}
gt.days[1] = {}
gt.days[1][1] = 'Firesday'
gt.days[1][2] = 'Fi '
gt.days[1][10] = '(255, 0, 0)'
gt.days[1][3] = 'Fire '
--Mini mode
gt.days[1][4] = '° '

gt.days[2] = {}
gt.days[2][1] = 'Earthsday'
gt.days[2][2] = 'Ea '
gt.days[2][10] = '(255, 225, 0)'
gt.days[2][3] = 'Earth '
--Mini mode
gt.days[2][4] = '° '

gt.days[3] = {}
gt.days[3][1] = 'Watersday'
gt.days[3][2] = 'Wa '
gt.days[3][10] = '(100, 100, 255)'
gt.days[3][3] = 'Water '
--Mini mode
gt.days[3][4] = '° '

gt.days[4] = {}
gt.days[4][1] = 'Windsday'
gt.days[4][2] = 'Wi '
gt.days[4][10] = '(0, 255, 0)'
gt.days[4][3] = 'Wind '
--Mini mode
gt.days[4][4] = '° '

gt.days[5] = {}
gt.days[5][1] = 'Iceday'
gt.days[5][2] = 'Ic '
gt.days[5][10] = '(150, 200, 255)'
gt.days[5][3] = 'Ice '
--Mini mode
gt.days[5][4] = '° '

gt.days[6] = {}
gt.days[6][1] = 'Lightningday'
gt.days[6][2] = 'Lg '
gt.days[6][10] = '(255, 128, 128)'
gt.days[6][3] = 'Lightning '
--Mini mode
gt.days[6][4] = '° '

gt.days[7] = {}
gt.days[7][1] = 'Lightsday'
gt.days[7][2] = 'Lt '
gt.days[7][10] = '(255, 255, 255)'
gt.days[7][3] = 'Light '
--Mini mode
gt.days[7][4] = '° '

gt.days[8] = {}
gt.days[8][1] = 'Darksday'
gt.days[8][2] = 'Dk '
gt.days[8][10] = '(128, 128, 128)'
gt.days[8][3] = 'Dark '
--Mini mode
gt.days[8][4] = '° '

gt.WeekReport = ''
gt.MoonPct = ''
gt.MoonPhase = ''

defaults = {}
defaults.saved = 0
defaults.mode = 1
defaults.zero = false
defaults.time = {}
defaults.time.pos = {}
defaults.time.pos.x = 0 -- left
defaults.time.pos.y = 0 -- top
defaults.time.text = {}
defaults.time.text.alpha = 255
defaults.time.text.red = 255
defaults.time.text.green = 255
defaults.time.text.blue = 255
defaults.time.text.size = 12
defaults.time.text.font = 'Consolas'
defaults.time.bg = {}
defaults.time.bg.alpha = 25
defaults.time.bg.red = 100
defaults.time.bg.green = 100
defaults.time.bg.blue = 100
defaults.time.bg.visible = true

defaults.days = {}
defaults.days.pos = {}
defaults.days.pos.x = 100
defaults.days.pos.y = 0 -- top
defaults.days.text = {}
defaults.days.text.alpha = 255
defaults.days.text.size = 12
defaults.days.text.font = 'Consolas'
defaults.days.bg = {}
defaults.days.bg.alpha = 100
defaults.days.bg.red = 0
defaults.days.bg.green = 0
defaults.days.bg.blue = 0
defaults.days.axis = 'horizontal'
defaults.numdays = 8
defaults.moon = {}
defaults.alert = true
settings = config.load(defaults)


Cycles = T{}
Cycles.selbina = T{}
Cycles.selbina.rname = "Ships between Mhaura and Selbina"
Cycles.selbina.route = T{}
Cycles.selbina.route[1] = "Arrives in Mhaura and Selbina|22:40"
Cycles.selbina.route[2] = "Arrives in Mhaura and Selbina|6:40"
Cycles.selbina.route[3] = "Arrives in Mhaura and Selbina|14:40"

Cycles.bibiki = T{}
Cycles.bibiki.rname = "Ship departing Bibiki Bay for Purgonorgo Isle"
Cycles.bibiki.route = T{}
Cycles.bibiki.route[1] = "Arrives in Bibiki|4:50"
Cycles.bibiki.route[2] = "Arrives in Bibiki|16:50"

Cycles.nashmau = T{}
Cycles.nashmau.rname = "Aht Urhgan / Nashmau Ship"
Cycles.nashmau.route = T{}
Cycles.nashmau.route[1] = "Arrives in Whitegate and Nashmau|05:00"
Cycles.nashmau.route[2] = "Arrives in Whitegate and Nashmau|13:00"
Cycles.nashmau.route[3] = "Arrives in Whitegate and Nashmau|21:00"

Cycles.whitegate = T{}
Cycles.whitegate.rname = "Aht Urhgan / whitegate Ship"
Cycles.whitegate.route = T{}
Cycles.whitegate.route[1] = "Arrives in Whitegate and Mhaura|10:40"
Cycles.whitegate.route[2] = "Arrives in Whitegate and Mhaura|18:40"
Cycles.whitegate.route[3] = "Arrives in Whitegate and Mhaura|2:40"

Cycles.windurst = T{}
Cycles.windurst.rname = "Ship between Windurst and Jeuno"
Cycles.windurst.route = T{}
Cycles.windurst.route[1] = "Arrives in Windurst|4:47"
Cycles.windurst.route[2] = "Arrives in Jeuno|7:41"
Cycles.windurst.route[3] = "Arrives in Windurst|10:47"
Cycles.windurst.route[4] = "Arrives in Jeuno|13:41"
Cycles.windurst.route[5] = "Arrives in Windurst|16:47"
Cycles.windurst.route[6] = "Arrives in Jeuno|19:41"
Cycles.windurst.route[7] = "Arrives in Windurst|22:47"
Cycles.windurst.route[8] = "Arrives in Jeuno|1:41"

Cycles.bastok = T{}
Cycles.bastok.rname = "Ship between Bastok and Jeuno"
Cycles.bastok.route = T{}
Cycles.bastok.route[1] = "Arrives in Bastok|0:13"
Cycles.bastok.route[2] = "Arrives in Jeuno|3:11"
Cycles.bastok.route[3] = "Arrives in Bastok|6:13"
Cycles.bastok.route[4] = "Arrives in Jeuno|9:11"
Cycles.bastok.route[5] = "Arrives in Bastok|12:13"
Cycles.bastok.route[6] = "Arrives in Jeuno|15:11"
Cycles.bastok.route[7] = "Arrives in Bastok|18:13"
Cycles.bastok.route[8] = "Arrives in Jeuno|21:41"

Cycles.sandy = T{}
Cycles.sandy.rname = "Ship between San d'Oria and Jeuno"
Cycles.sandy.route = T{}
Cycles.sandy.route[1] = "Arrives in San d'Oria|7:10"
Cycles.sandy.route[2] = "Arrives in Jeuno|6:11"
Cycles.sandy.route[3] = "Arrives in San d'Oria|9:10"
Cycles.sandy.route[4] = "Arrives in Jeuno|12:11"
Cycles.sandy.route[5] = "Arrives in San d'Oria|15:10"
Cycles.sandy.route[6] = "Arrives in Jeuno|18:11"
Cycles.sandy.route[7] = "Arrives in San d'Oria|21:10"
Cycles.sandy.route[8] = "Arrives in Jeuno|00:41"

Cycles.kazham = T{}
Cycles.kazham.rname = "Ship between Kazham and Jeuno"
Cycles.kazham.route = T{}
Cycles.kazham.route[1] = "Arrives in Kazham|1:48"
Cycles.kazham.route[2] = "Arrives in Jeuno|4:49"
Cycles.kazham.route[3] = "Arrives in Kazham|7:48"
Cycles.kazham.route[4] = "Arrives in Jeuno|10:49"
Cycles.kazham.route[5] = "Arrives in Kazham|13:48"
Cycles.kazham.route[6] = "Arrives in Jeuno|14:49"
Cycles.kazham.route[7] = "Arrives in Kazham|19:48"
Cycles.kazham.route[8] = "Arrives in Jeuno|20:49"

gt.gtt = texts.new('', settings.time)
gt.gtd = texts.new('', settings.days)

config.register(settings, function()
    if settings.days.axis == 'horizontal' then
        gt.delimiter = ' '
    else
        gt.delimiter = '\n'
    end

    if settings.zero then
        gt.gtt:text('${hours|XX|%.2d}:${minutes|XX|%.2d}')
    else
        gt.gtt:text('${hours|XX}:${minutes|XX|%.2d}')
    end
    gt.gtd:text('${day|} ${MoonPhase|Unknown} (${MoonPct|-}%); ${WeekReport|}')

    if settings.numdays > 0 and settings.numdays < 9 then
        gt.numdays = settings.numdays
    else
        gt.numdays = 8
    end
    

    gt.gtd:text('${day|} ${MoonPhase|Unknown} (${MoonPct|-}%); ${WeekReport|}')
    local info = windower.ffxi.get_info()
    if info.logged_in then
        day_change(info.day)

        gt.gtt:show()
        gt.gtd:show()
    end
end)

function getroutes(route)
    for ckey, cval in pairs(Cycles) do
        if route == nil or ckey == route then
            log('\30\02'..Cycles[ckey].rname..' (shortcode: //gt route '..ckey..')')
            for ri = 1, #Cycles[ckey].route do
                ro = Cycles[ckey].route[ri]:split('|')
                rtime = timeconvert(ro[2])
                rdelay = math.round(rtime-gt.dectime,2)
                if rdelay < 0 then rdelay = rdelay + 24 end
                rdelay = 2.4 * rdelay
                log(ro[1]..' @ '..ro[2]..'  \30\02Arrival in '..(timeconvert2(rdelay))..'')
            end
        end
    end
end

function default_settings()
    settings:save('all')
end

windower.register_event('time change', function(new, old)
    gt.hours = (new / 60):floor()
    gt.minutes = new % 60
    gt.gtt:update(gt)
end)

function timeconvert(basetime)
    basetable = basetime:split(':')
    return basetable[1]..'.'..math.round(basetable[2] * (100/60))
end

function timeconvert2(basetime)
    basetable = tostring(basetime):split('.')
    return basetable[1]..':'..tostring(math.round(tostring(basetable[2]):slice(1,2) / (100/60))):zfill(2)
end

function moon_change()
    local info = windower.ffxi.get_info()
    gt.MoonPhase = res.moon_phases[info.moon_phase].english
    gt.MoonPct = info.moon
    gt.gtd:update(gt)
end

function day_change(day)
    day = res.days[day].english
    if (day == 'Firesday') then
        dlist = {'1','2','3','4','5','6','7','8'}
    elseif (day == 'Earthsday') then
        dlist = {'2','3','4','5','6','7','8','1'}
    elseif (day == 'Watersday') then
        dlist = {'3','4','5','6','7','8','1','2'}
    elseif (day == 'Windsday') then
        dlist = {'4','5','6','7','8','1','2','3'}
    elseif (day == 'Iceday') then
        dlist = {'5','6','7','8','1','2','3','4'}
    elseif (day == 'Lightningsday') then
        dlist = {'6','7','8','1','2','3','4','5'}
    elseif (day == 'Lightsday') then
        dlist = {'7','8','1','2','3','4','5','6'}
    elseif (day == 'Darksday') then
        dlist = {'8','1','2','3','4','5','6','7'}
    end
    
    dpos = 0
    daystring = ''
    while dpos < gt.numdays do
        dpos = dpos + 1
        dval = dlist[dpos]
        daystring = ''..daystring..gt.delimiter..' \\cs'..gt.days[(dval+0)][10]..gt.days[(dval+0)][settings.mode]
    end
    
    gt.day = day    
    gt.WeekReport = daystring
    gt.gtd:update(gt)
    moon_change()
end

function tolog()
    if settings.alert == true then
        log('Day: '..gt.day..'; Moon: '..gt.MoonPhase..' ('..gt.MoonPct..'%);')
    end
end

windower.register_event('day change', moon_change .. day_change)

windower.register_event('moon change', moon_change)

windower.register_event('addon command', function (...)
    local args    = T{...}:map(string.lower)
    if args[1] == nil or args[1] == "help" then
        log('Use //gametime or //gt as follows:')
        log('Positioning:')
        log('//gt [timex/timey/daysx/daysy] <pos> :: example: //gt timex 125')
        log('//gt [time/days] reset :: example: //gt days reset')
        
        log('Text features:')
        log('//gt timeSize <size> :: example: //gt timeSize 10')
        log('//gt timeFont <fontName> :: example: //gt timeFont Verdana')
        log('//gt daySize <size> :: example: //gt daySize 10')
        log('//gt dayFont <fontName> :: example: //gt dayFont Verdana')
        
        log('Visibility:')
        log('//gt [time/days] [show/hide] :: example //gt time hide')
        log('//gt axis [horizontal/vertical] :: week display axis')
        log('//gt [time/days] alpha 1-255. :: Sets the transparency. Lowest numbers = more transparent.')
        log('//gt mode 1-4 :: Fullday; Abbreviated; Element names; Compact')
        
        log('Routes:')
        log('//gt route :: Displays route names.')
        log('//gt route [route name] :: Displays arrival time for route.')
        
        log('Misc:')
        log('//gt zero [on/off] :: Displays the time with leading zeros. 04:05 instead of 4:05')
        log('//gt days [1-8] :: Limits the number of days displayed')
        log('//gt alert :: Toggle display in chat log for day and moon changes')
        log('Remember to //gt save when you\'re happy with your settings.')
    elseif args[1] == 'routes' or args[1] == 'route' then
        if args[2] == nil then
            local ckeys = ''
            for ckey, cval in pairs(Cycles) do
                ckeys = ckeys..', '..ckey
            end
            ckeys = ckeys:slice(3,#ckeys)
            log('Use //gt route [shortcode] ('..ckeys..')')
        else
            getroutes(args[2])
        end
    
    
    
    ---CLI Arguments for Time font Size
    elseif args[1] == 'timeSize' then
            gt.gtt:size(tonumber(args[2]))    
            
    ---CLI Arguments for Time font type
    elseif args[1] == 'timeFont' then
        gt.gtt:font(args[2])    
            
    ---CLI Arguments for Day font Size
    elseif args[1] == 'daySize' then
        gt.gtd:size(tonumber(args[2]))                
    
    ---CLI Arguments for Day font type
    elseif args[1] == 'dayFont' then
        gt.gtd:font(args[2])    
    
    elseif args[1] == 'timex' then
        gt.gtt:pos_x(tonumber(args[2]))
        
    elseif args[1] == 'timey' then
        gt.gtt:pos_y(tonumber(args[2]))
        
    elseif args[1] == 'daysx' then
        gt.gtd:pos_x(tonumber(args[2]))
        
    elseif args[1] == 'daysy' then
        gt.gtd:pos_y(tonumber(args[2]))
        
    elseif args[1] == 'alert' then
        settings.alert = (settings.alert == false)
        gt.alert = settings.alert
        log('Show alerts in log when day / moon-phase changes: '..tostring(settings.alert))
        tolog()
    
    elseif args[1] == 'time' then
        if args[2] == 'alpha' then
            inalpha = tostring(args[3]):zfill(3)
            inalpha = inalpha+0
            if (inalpha > 0 and inalpha < 256) then
                gt.gtt:alpha(inalpha)
                log('Time transparency set to '..inalpha..' ('..math.round(100-(inalpha/2.55),0)..'%).')
            end
        elseif args[2] == 'x' or args[2] == 'posx' then
            windower.send_command('gt timex '..args[3])
        elseif args[2] == 'y' or args[2] == 'posy' then
            windower.send_command('gt timey '..args[3])
        elseif args[2] == 'hide' then
            gt.gtt:hide()
            log('Time display hidden.')
        elseif args[2] == 'reset' then
            gt.gtt:pos(0,0)
        else
            gt.gtt:show()
            log('Showing time display.')
        end
    elseif args[1] == 'days' then
        if args[2] == 'alpha' then
            inalpha = tostring(args[3]):zfill(3)
            inalpha = inalpha+0
            if (inalpha > 0 and inalpha < 256) then
                gt.gtd:alpha(inalpha)
                log('Day transparency set to '..inalpha..' ('..math.round(100-(inalpha/2.55),0)..'%).')
            end
        elseif tonumber(args[2]) > 0 and tonumber(args[2]) < 9 then
            gt.numdays = tonumber(args[2])
            settings.numdays = tonumber(args[2])
            day_change(windower.ffxi.get_info().day)
        elseif args[2] == 'x' or args[2] == 'posx' then
            windower.send_command('gt daysx '..args[3])
        elseif args[2] == 'y' or args[2] == 'posy' then
            windower.send_command('gt daysy '..args[3])
        elseif args[2] == 'hide' then
            gt.gtd:hide()
            log('Day display hidden.')
        elseif args[2] == 'reset' then
            gt.gtd:pos(0,0)
        else
            gt.gtd:show()
            log('Showing day display.')
        end
    elseif args[1] == 'axis' then
        if args[2] == 'vertical' then
            gt.delimiter = "\n"
        log('Week display axis set to vertical.')
        else
            gt.delimiter = " "
        log('Week display axis set to horizontal.')
        end
        day_change(windower.ffxi.get_info().day)
    elseif args[1] == 'mode' then
        inmode = args[2]:zfill(1)
        inmode = inmode+0
        if inmode > 4 then
            return
        else
            settings.mode = inmode
            log('mode updated')
        end
        day_change(windower.ffxi.get_info().day)
    elseif args[1] == 'zero' then
        if args[2] == 'on' then
            settings.zero = true
            config.save(settings)
            log('zero padding enabled.')
        elseif args[2] == 'off' then
            settings.zero = false
            config.save(settings)
            log('zero padding disabled.')
        end
    elseif args[1] == 'save' then
        config.save(settings, 'all')
        log('Settings saved.')
    end
end)

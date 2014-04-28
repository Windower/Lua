-- Point Watch

texts = require 'texts'
config = require 'config'
require 'sets'
res = require 'resources'

_addon.name = 'PointWatch'
_addon.author = 'Byrth'
_addon.version = 0.042314
_addon.command = 'pw'

if not windower.dir_exists('data') then
    windower.create_dir('data')
end

default_settings = {
    strings = {
        default = "xp.current..'/'..xp.tnl..'XP   '..lp.current..'/'..lp.tnm..'LP ['..lp.number_of_merits..']   XP/hr:'..string.format('%.1f',math.floor(xp.rate/100)/10)..'k   '..cp.current..'/'..cp.tnjp..'CP ['..cp.number_of_job_points..']   CP/hr:'..string.format('%.1f',math.floor(cp.rate/100)/10)..'k'",
        dynamis = "xp.current..'/'..xp.tnl..'XP   '..lp.current..'/'..lp.tnm..'LP ['..lp.number_of_merits..']   XP/hr:'..string.format('%.1f',math.floor(xp.rate/100)/10)..'k   '..cp.current..'/'..cp.tnjp..'CP ['..cp.number_of_job_points..']   '..dynamis.KIs..'  '..dynamis.time_remaining"
        },
    text_box_settings = {
        pos = {
            x = 0,
            y = 0,
        },
        bg = {
            alpha = 255,
            red = 0,
            green = 0,
            blue = 0,
            visible = true
        },
        flags = {
            right = false,
            bottom = false,
            bold = false,
            italic = false
        },
        padding = 0,
        text = {
            size = 12,
            font = 'Consolas',
            fonts = {},
            alpha = 255,
            red = 255,
            green = 255,
            blue = 255
        }
    }
}


settings = config.load('data\\settings.xml',default_settings)
config.save(settings)

box = texts.new('${current_string}',settings.text_box_settings)
box.current_string = ''
box:show()
approved_commands = S{'show','hide','pos','pos_x','pos_y','font','size','pad','color','alpha','transparency','bg_color','bg_alpha','bg_transparency'}
city_table = {Crimson=10,Azure=10,Amber=10,Alabaster=15,Obsidian=15}
other_table = {Crimson=10,Azure=10,Amber=10,Alabaster=10,Obsidian=20}
dynamis_map = {[185]=city_table,[186]=city_table,[187]=city_table,[188]=city_table,
    [134]=other_table,[135]=other_table,[39]=other_table,[40]=other_table,[41]=other_table,[42]=other_table}

function initialize()
    cp = {
        registry = {},
        current = 0, -- Not implemented
        rate = 0,
        total = 0,
        tnjp = 30000,
        number_of_job_points = 0 -- Not implemented
    }

    
    xp = {
        registry = {},
        total = 0,
        rate = 0,
        current = 0,
        tnl = 0
    }
    
    lp = {
        current = 0,
        tnm = 10000,
        number_of_merits = 0
    }
    
    sparks = {
        current = 0,
        maximum = 50000,
    }
    
    
    local info = windower.ffxi.get_info()
    
    frame_count = 0
    
    dynamis = {
        KIs = '',
        _KIs = {},
        entry_time = 0,
        time_limit = 0,
        zone = 0,
    }
    if info.logged_in and res.zones[info.zone].english:sub(1,7) == 'Dynamis' then
        cur_func = loadstring("current_string = "..settings.strings.dynamis)
        setfenv(cur_func,_G)
        dynamis.entry_time = os.clock()
        dynamis.zone = info.zone
        error(123,'Loading PointWatch in Dynamis results in an inaccurate timer. Number of KIs is displayed.')
    elseif info.logged_in then
        cur_func = loadstring("current_string = "..settings.strings.default)
        setfenv(cur_func,_G)
    end
    
end

initialize()


windower.register_event('incoming chunk',function(id,org,modi,is_injected,is_blocked)
    if is_injected then return end
    if id == 0x2D then
        local val = str2bytes(org:sub(0x11,0x14))
        local msg = str2bytes(org:sub(0x19,0x20))%1024
        local t = os.clock()
        if msg == 718 then
            cp.registry[t] = (cp.registry[t] or 0) + val
            cp.total = cp.total + val
        elseif msg == 8 or msg == 105 or msg == 371 or msg == 372 then
            xp.registry[t] = (xp.registry[t] or 0) + val
            xp.total = xp.total + val
            xp.current = xp.current + val
            if xp.current > xp.tnl and xp.tnl ~= 56000 then
                xp.current = xp.current - xp.tnl
                -- I have capped all jobs, but I assume that a 0x61 packet is sent after you
                --  level up, which will update the TNL and make this adjustment meaningless.
            elseif xp.current > xp.tnl then
                lp.current = lp.current + xp.current - xp.tnl + 1
            end
        end
        update_box()
    elseif id == 0x55 then
        if org:byte(0x85) == 3 then
            local dyna_KIs = math.floor((org:byte(6)%64)/2) -- 5 bits (32, 16, 8, 4, and 2 originally -> shifted to 16, 8, 4, 2, and 1)
            dynamis._KIs = {
                ['Crimson'] = dyna_KIs%2 == 1,
                ['Azure'] = math.floor(dyna_KIs/2)%2 == 1,
                ['Amber'] = math.floor(dyna_KIs/4)%2 == 1,
                ['Alabaster'] = math.floor(dyna_KIs/8)%2 == 1,
                ['Obsidian'] = math.floor(dyna_KIs/16) == 1,
            }
            if dynamis_map[dynamis.zone] then
                dynamis.time_limit = 3600
                for KI,TE in pairs(dynamis_map[dynamis.zone]) do
                    if dynamis._KIs[KI] then
                        dynamis.time_limit = dynamis.time_limit + TE*60
                    end
                end
                update_box()
            end
        end
    elseif id == 0x61 then
        xp.current = org:byte(0x11)+org:byte(0x12)*256
        xp.tnl = org:byte(0x13)+org:byte(0x14)*256
    elseif id == 0x63 and org:byte(5) == 2 then
        lp.current = org:byte(9)+org:byte(10)*256
        lp.number_of_merits = org:byte(11)%64
    elseif id == 0x63 and org:byte(5) == 5 then
        local offset = windower.ffxi.get_player().main_job_id*4+13 -- So WAR (ID==1) starts at byte 17
        cp.current = org:byte(offset)+org:byte(offset+1)*256
        cp.number_of_job_points = org:byte(offset+2)
    elseif id == 0x110 then
        sparks.current = org:byte(5)+org:byte(6)*256
    end
end)

windower.register_event('zone change',function(new,old)
    if res.zones[new].english:sub(1,7) == 'Dynamis' then
        dynamis.entry_time = os.clock()
        dynamis.time_limit = 3600
        dynamis.zone = new
        cur_func = loadstring("current_string = "..settings.strings.dynamis)
    else
        dynamis.entry_time = 0
        dynamis.time_limit = 0
        dynamis.zone = 0
        cur_func = loadstring("current_string = "..settings.strings.default)
    end
end)

windower.register_event('addon command',function(...)
    local commands = {...}
    local first_cmd = table.remove(commands,1)
    if approved_commands[first_cmd] then
        local tab = {}
        for i,v in pairs(commands) do
            tab[i] = tonumber(v) or v
        end
        texts[first_cmd](box,unpack(tab))
        settings.text_box_settings = box._settings
        config.save(settings)
    elseif first_cmd == 'reload' then
        windower.send_command('lua r pointwatch')
    elseif first_cmd == 'unload' then
        windower.send_command('lua u pointwatch')
    elseif first_cmd == 'reset' then
        initialize()
    elseif first_cmd == 'eval' then
        assert(loadstring(table.concat(commands, ' ')))()
    end
end)

windower.register_event('prerender',function()
    if frame_count%30 == 0 and box:visible() then
        update_box()
    end
    frame_count = frame_count + 1
end)

function update_box()
    if not windower.ffxi.get_info().logged_in or not windower.ffxi.get_player() then return end
    cp.rate = analyze_points_table(cp.registry)
    xp.rate = analyze_points_table(xp.registry)
    if dynamis.entry_time ~= 0 and dynamis.entry_time+dynamis.time_limit-os.clock() > 0 then
        dynamis.time_remaining = os.date('%H:%M:%S',dynamis.entry_time+dynamis.time_limit-os.clock()+18000)
        dynamis.KIs = X_or_O(dynamis._KIs.Crimson)..X_or_O(dynamis._KIs.Azure)..X_or_O(dynamis._KIs.Amber)..X_or_O(dynamis._KIs.Alabaster)..X_or_O(dynamis._KIs.Obsidian)
    else
        dynamis.time_remaining = 0
        dynamis.KIs = ''
    end
    assert(cur_func)()
    if box.current_string ~= current_string then
        box.current_string = current_string
    end
end

function X_or_O(bool)
    if bool then return 'O' else return 'X' end
end

function analyze_points_table(tab)
    local t = os.clock()
    local running_total = 0
    local maximum_timestamp = 29
    for ts,points in pairs(tab) do
        local time_diff = t - ts
        if t - ts > 600 then
            tab[ts] = nil
        else
            running_total = running_total + points
            if time_diff > maximum_timestamp then
                maximum_timestamp = time_diff
            end
        end
    end
    
    local rate
    if maximum_timestamp == 29 then
        rate = 0
    else
        rate = math.floor((running_total/maximum_timestamp)*3600)
    end
    
    return rate
end

function str2bytes(str)
    local num = 0
    while str ~= '' do
        local len = #str
        num = num*256 + str:byte(len)
        if len == 1 then
            break
        else
            str = str:sub(1,len-1)
        end
    end
    return num
end
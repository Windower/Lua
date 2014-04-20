-- Point Watch

texts = require 'texts'
config = require 'config'
require 'sets'
res = require 'resources'

_addon.name = 'PointWatch'
_addon.author = 'Byrth'
_addon.version = 0.04202014
_addon.command = 'pw'

if not windower.dir_exists('data') then
    windower.create_dir('data')
end

default_settings = {}
default_settings.pos = {}
default_settings.pos.x = 0
default_settings.pos.y = 0
default_settings.bg = {}
default_settings.bg.alpha = 255
default_settings.bg.red = 0
default_settings.bg.green = 0
default_settings.bg.blue = 0
default_settings.bg.visible = true
default_settings.flags = {}
default_settings.flags.right = false
default_settings.flags.bottom = false
default_settings.flags.bold = false
default_settings.flags.italic = false
default_settings.padding = 0
default_settings.text = {}
default_settings.text.size = 12
default_settings.text.font = 'Consolas'
default_settings.text.fonts = {}
default_settings.text.alpha = 255
default_settings.text.red = 255
default_settings.text.green = 255
default_settings.text.blue = 255


settings = config.load('data\\settings.xml',default_settings)
config.save(settings)

box = texts.new('****PointWatch****',settings)
box:show()
approved_commands = S{'show','hide','pos','pos_x','pos_y','font','size','pad','color','alpha','transparency','bg_color','bg_alpha','bg_transparency'}
city_table = {Crimson=10,Azure=10,Amber=10,Alabaster=15,Obsidian=15}
other_table = {Crimson=10,Azure=10,Amber=10,Alabaster=10,Obsidian=20}
dynamis_map = {[185]=city_table,[186]=city_table,[187]=city_table,[188]=city_table,
    [134]=other_table,[135]=other_table,[39]=other_table,[40]=other_table,[41]=other_table,[42]=other_table}

function initialize()
    cp = {}
    cp.registry = {}
    cp.total = 0

    
    xp = {}
    xp.registry = {}
    xp.total = 0
    
    
    local info = windower.ffxi.get_info()
    
    frame_count = 0
    
    dynamis = {}
    dynamis.KIs = {}
    dynamis.entry_time = 0
    dynamis.time_limit = 0
    dynamis.zone = 0
    dynamis.static = false
    if info.logged_in and res.zones[info.zone].english:sub(1,7) == 'Dynamis' then
        dynamis.static = true
        dynamis.zone = info.zone
        error(123,'Loading PointWatch in Dynamis results in an inaccurate timer. Number of KIs is displayed.')
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
        end
        update_box()
    elseif id == 0x55 then
        local packet_id = org:byte(5)
        if packet_id == 7 then
            local dyna_KIs = math.floor((org:byte(6)%64)/2) -- 5 bits (32, 16, 8, 4, and 2 originally -> shifted to 16, 8, 4, 2, and 1)
            dynamis.KIs = {
                ['Crimson'] = dyna_KIs%2 == 1,
                ['Azure'] = math.floor(dyna_KIs/2)%2 == 1,
                ['Amber'] = math.floor(dyna_KIs/4)%2 == 1,
                ['Alabaster'] = math.floor(dyna_KIs/8)%2 == 1,
                ['Obsidian'] = math.floor(dyna_KIs/16) == 1,
            }
            if dynamis_map[dynamis.zone] then
                dynamis.time_limit = 3600
                for KI,TE in pairs(dynamis_map[dynamis.zone]) do
                    if dynamis.KIs[KI] then
                        dynamis.time_limit = dynamis.time_limit + TE*60
                    end
                end
                update_box()
            end
        end
    end
end)

windower.register_event('zone change',function(new,old)
    if res.zones[new].english:sub(1,7) == 'Dynamis' then
        dynamis.entry_time = os.clock()
        dynamis.time_limit = 3600
        dynamis.zone = new
    else
        dynamis.entry_time = 0
        dynamis.time_limit = 0
        dynamis.zone = 0
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
        config.save(box._settings)
    elseif first_cmd == 'reload' then
        windower.send_command('lua r pointwatch')
    elseif first_cmd == 'unload' then
        windower.send_command('lua u pointwatch')
    elseif first_cmd == 'reset' then
        initialize()
--    elseif first_cmd == 'eval' then
--        assert(loadstring(table.concat(commands, ' ')))()
    end
end)

windower.register_event('prerender',function()
    if frame_count%30 == 0 and box:visible() then
        update_box()
    end
    frame_count = frame_count + 1
end)

function update_box()
    local cp_rate = analyze_points_table(cp.registry)
    local xp_rate = analyze_points_table(xp.registry)
    box:clear()
    box:appendline('CP Total: '..cp.total)
    box:appendline('CP /hour: '..cp_rate)
    box:appendline('XP Total: '..xp.total)
    box:appendline('XP /hour: '..xp_rate)
    if dynamis.entry_time ~= 0 and dynamis.entry_time+dynamis.time_limit-os.clock() > 0 then
        box:appendline('Time Rem: '..os.date('%H:%M:%S',dynamis.entry_time+dynamis.time_limit-os.clock()+18000))
    end
    if dynamis.static or dynamis.entry_time ~= 0 then
        box:appendline('Dyna KIs: '..X_or_O(dynamis.KIs.Crimson)..X_or_O(dynamis.KIs.Azure)..X_or_O(dynamis.KIs.Amber)..X_or_O(dynamis.KIs.Alabaster)..X_or_O(dynamis.KIs.Obsidian))
    end
    box:update()
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
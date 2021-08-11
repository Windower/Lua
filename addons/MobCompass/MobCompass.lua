_addon.name = 'MobCompass'
_addon.version = '2.1.0'

local primitives = require 'libs/primitives'
local config = require 'config'
local math = require 'math'

local hidden = primitives.hidden

-- Draw the compass. Long live wingdings.
local labels
local prims = {}
do
    local function new(text, size, font)
        local p = primitives.new('text')
        p('set_text', text)
        p('set_font_size', size)
        p('set_font', font or 'Wingdings')

        return p
    end
    
    local big_circle = new('l', 111) -- Draw first. It needs to be in the background.
    
    for i = 4, 16, 4 do -- s e n w
        prims[i] = new('', 33)
    end

    local char = string.char
    prims[4]('set_text', 'Ú')
    prims[8]('set_text', 'Ø')
    prims[12]('set_text', 'Ù')
    prims[16]('set_text', '×')
    
    for i = 1, 15, 2 do -- wsw ssw sse ese ene nne nnw wnw
        prims[i] = new('l', 6)
    end

    for i = 2, 14, 4 do -- sw se ne nw
        prims[i] = new('w', 20)
    end
    
    prims[17] = big_circle
    big_circle('set_color', 100, 0, 0, 0)
    prims[18] = new('l', 53)
    prims[18]('set_color', 88, 88, 88, 165)
    prims[19] = new('S', 15, 'Consolas') -- initialize to S (see below)
    labels = new(
        '       Crit\n\n\n\nMB               Att\n\n\n\n        Acc',
        10,
        'Consolas'
    )
    prims[20] = labels
end

-- Position the compass.
local settings = config.load({
    x_pos = 0,
    y_pos = 0
})
local x_pos, y_pos = settings.x_pos, settings.y_pos
local function pos(x, y)
    local offsets = {
        18, 63; --wsw
        19, 60; --sw
        30, 77; --ssw
        29, 58; --s
        62, 77; --sse
        64, 60; --se
        75, 63; --ese
        62, 29; --e
        75, 34; --ene
        64, 17; --ne
        62, 21; --nne
        29, 0; --n
        30, 21; --nnw
        19, 17; -- nw
        18, 34; --wnw
        0, 29; --w
        -8, -27; --big circle
        22, 14; --little circle
        32, 40; --faceplate number
        -22, -18; --labels
    }
    for i = 1, #prims do
        prims[i]('set_position', offsets[2*(i-1)+1] + x, offsets[2*i] + y)
    end
end

config.register(settings, function(t)
    pos(t.x_pos, t.y_pos)
end)

local target
local player_index
primitives.low_level_visibility(false)
do
    local mob = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')
    if mob then
        target = mob.index
    end
end
do
    if windower.ffxi.get_info().logged_in then
        if target then
            primitives.low_level_visibility(true)
        end
        local player = windower.ffxi.get_player()
        player_index = player.index
        labels('set_visibility', player.main_job_id == 21 or player.sub_job_id == 21) -- The labels are only useful for geomancer.
    end
end

-- Hide the compass if there is no target or the player is the target.
windower.register_event('target change', function(n)
    target = n
    if n == 0 or n == player_index then
        if not hidden() then
            primitives.low_level_visibility(false)
        end
    elseif hidden() then
        primitives.low_level_visibility(true)
    end
end)

local directions = {
    ' S ', 'SSE', 'S E', 'ESE',
    ' E ', 'ENE', 'N E', 'NNE',
    ' N ', 'NNW', 'N W', 'WNW',
    ' W ', 'WSW', 'S W', 'SSW',
}
local atan2 = math.atan2
local ceil = math.ceil
local pi = math.pi

-- Pick some initial values.
local last_cardinal_index = 1
local last_relative_index = 1
prims[1]('set_color', 255, 255, 0, 0)

windower.register_event('prerender', function()
    if hidden() then return end
    local player = windower.ffxi.get_mob_by_index(player_index)
    if not player then return end
    local mob = windower.ffxi.get_mob_by_index(target)
    local x, y = player.x - mob.x, player.y - mob.y
    local angle = atan2(y, x)
    local cardinal_index = (ceil(8*angle/pi - 0.5) + 7)%16 + 1 -- Add 8 to make indexing more convenient.
    if cardinal_index ~= last_cardinal_index then
        prims[last_cardinal_index]('set_color', 255, 255, 255, 255)
        prims[cardinal_index]('set_color', 255, 255, 0, 0)
        last_cardinal_index = cardinal_index
    end
    local heading = angle + mob.facing -- The value for facing uses ccw -, cw + (the opposite of atan2).
    local relative_index = (ceil(8*heading/pi + 0.5) + 7)%16 + 1 -- It's +0.5 here because I typed the directions out of order.
    if relative_index ~= last_relative_index then
        prims[19]('set_text', directions[relative_index])
        last_relative_index = relative_index
    end
end)

-- Mouse input
local drag_and_drop = false
local drag_x = 0
local drag_y = 0
windower.register_event('mouse', function(type, x, y, _, blocked)
    if (blocked or hidden()) and not drag_and_drop then return end
    if type == 0 then
        if drag_and_drop then
            pos(x-drag_x, y-drag_y)
        end
    elseif type == 1 then
        if (x-x_pos-45)^2 + (y-y_pos-45)^2 < 2025 then
            drag_and_drop = true
            drag_x = x-x_pos
            drag_y = y-y_pos
            return true
        end
    elseif type == 2 then
        if drag_and_drop then
            x_pos, y_pos = x-drag_x, y-drag_y
            settings.x_pos = x_pos
            settings.y_pos = y_pos
            config.save(settings)
            drag_and_drop = false
            return true
        end
    end
end)

windower.register_event('job change', function(main, sub)
    labels('set_visibility', main == 21 or sub == 21)
end)

windower.register_event('login', function()
	primitives.low_level_visibility(false)
    player_index = windower.ffxi.get_player().index
end)

windower.register_event('zone change', function()
    player_index = windower.ffxi.get_player().index
	if not windower.ffxi.get_mob_by_target('st') and not windower.ffxi.get_mob_by_target('t') then
		primitives.low_level_visibility(false) -- libs/primitives is going to switch it to true... switch it back
	end
end)

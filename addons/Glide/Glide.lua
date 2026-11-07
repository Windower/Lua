_addon.name = 'Glide'
_addon.author = 'Staticvoid'
_addon.version = '1.1.2'
_addon.commands = {'Glide'}

local res = require('resources')
local config = require('config')
local texts = require('texts')

local display = windower.get_windower_settings()
local _data = {}
_data.move_threshold = 1.00 
_data.last_shot_pos = nil
_data.player_id = nil
_data.hover_stacks = 0
_data.last_target_id = nil
_data.last_stack_valid = false
_data.last_update = nil
_data.distance = 0
_data.last_display_state = nil
_data.text_visible = false
_data.logged_in = true
_data.next_velocity_check = os.time()

local defaults = {}
defaults.main = {}
defaults.main.pos = {
    x = math.floor(display.ui_x_res / 2.05),
    y = display.ui_y_res / 1.4
}
defaults.main.text = {
        size = 12,
        font = 'Comic Sans MS',
        red = 185,
        green = 200,
        blue = 210,
        alpha = 255,
        stroke = {
            alpha = 255,
            red = 0,
            green = 0,
            blue = 0,
            width = 2,
            padding = 1
        }
    }
defaults.main.bg = {
    alpha = 125,
    red = 100,
    green = 0,
    blue = 0
}

local settings = config.load(defaults)

local distance_text = texts.new(
    '  ${glide}\n[${stacks|00}] ${color}${value||%.2f}${suffix}\\cr',
    settings.main
)

local function update_distance_text(distance)
    if not _data.logged_in then
        return
    end

    _data.distance = _data.distance or 0

    if _data.hover_stacks == 0 then
        _data.distance = 0
    end

    local value = math.min(_data.distance, 20)
    local suffix = _data.distance >= 20 and '+' or ''

    local color = _data.distance >= _data.move_threshold and '\\cs(0,200,0)' or '\\cs(185,200,210)'

    local formatted_distance = string.format('%.2f', value)

    local current_state = table.concat({
        formatted_distance,
        tostring(_data.hover_stacks),
        suffix,
        color
    }, '|')

    if current_state == _data.last_display_state then
        return
    end

    _data.last_display_state = current_state

    distance_text.glide = '\\cs(225,215,50)Glide™\\cr'
    distance_text.stacks = _data.hover_stacks
    distance_text.value = value
    distance_text.suffix = suffix
    distance_text.color = color

    distance_text:update()

    if not _data.text_visible then
        distance_text:show()
        _data.text_visible = true
    end
end

local function is_ranged_weaponskill(ws_id)
    if not ws_id then
        return false
    end

    local ws = res.weapon_skills[ws_id]
    if not ws then
        return false
    end

    return ws.skill == 25 or ws.skill == 26
end

local function has_hover_shot()
    local player = windower.ffxi.get_player()
    if not player or not player.buffs then
        return false
    end

    for _, buff_id in ipairs(player.buffs) do
        if buff_id == 628 then
            return true
        end
    end

    return false
end

local function has_velocity_shot()
    local player = windower.ffxi.get_player()
    if not player or not player.buffs then
        return false
    end

    for _, buff_id in ipairs(player.buffs) do
        if buff_id == 371 then
            return true
        end
    end

    return false
end

local function check_for_pulse(mob)
    local mob = windower.ffxi.get_mob_by_id(mob)
    if mob and mob.hpp == 0 then
        _data.hover_stacks = 0
        _data.last_shot_pos = nil
        _data.last_target_id = nil
    end
end

windower.register_event('zone change', function(new, old)
    _data.hover_stacks = 0
    _data.last_shot_pos = nil
    _data.last_target_id = nil
end)

windower.register_event('load', function()
    local player = windower.ffxi.get_player()

    if player then
        _data.player_id = player.id
    end

    update_distance_text(0)
    windower.add_to_chat(207, 'Glide loaded.')
end)

windower.register_event('prerender', function()

    if not _data.logged_in or not _data.player_id then
        return
    end

    if _data.last_shot_pos then

        local player = windower.ffxi.get_mob_by_id(_data.player_id)

        if player then

            if player.status == 4 then
                _data.last_shot_pos = nil
                _data.last_stack_valid = false
                _data.last_update = false
                _data.distance = 0
                update_distance_text(0)
                return
            end

            local dx = player.x - _data.last_shot_pos.x
            local dy = player.y - _data.last_shot_pos.y

            _data.distance = math.sqrt(dx * dx + dy * dy)

            _data.last_stack_valid = (_data.distance >= _data.move_threshold)
            _data.last_update = false

            update_distance_text(_data.distance)
        end

    elseif not _data.last_update then

        _data.last_update = true
        _data.distance = 0

        update_distance_text(0)
    end
end)

-- Look at various things of concern related to hover shot.
windower.register_event('action', function(act)
    if not _data.logged_in then
        return
    end

    local player = windower.ffxi.get_mob_by_id(_data.player_id)

    if act.actor_id ~= _data.player_id then
        return
    end
    -- If a JA is used make sure its not hover shot.
    if act.category == 6 then
        -- First, look for Hover Shot activation.
        for _, target in ipairs(act.targets) do
            for _, action in ipairs(target.actions) do
                if action.message == 100 and action.param == 628 then
                    _data.hover_stacks = 0
                    _data.last_target_id = nil
                    return
                end
            end
        end
    end

    -- We only care about ranged attacks, weaponskills and Eagle Eye Shot.
    if act.category ~= 2 and act.category ~= 3 then
        return
    end

    -- Only count stacks while Hover Shot is active; If it is not go no further with processing.
    if not has_hover_shot() then
        _data.hover_stacks = 0
        _data.last_target_id = nil
        _data.last_shot_pos = nil
        local player_main_job = windower.ffxi.get_player().main_job
        if player_main_job == 'RNG' then
            if act.category == 2 or act.category == 3 then
                windower.add_to_chat(207,'Hover Shot is not activated.')
            end
        end
        return
    end

    -- Make Velocity Shot check periodic so we aren't looking at it every action.
    if os.time() > _data.next_velocity_check then
        _data.next_velocity_check = os.time() + 15
        -- Velocity Shot check.
        if not has_velocity_shot() then
            windower.add_to_chat(207,'Velocity Shot is not activated.')
        end
    end

    for _, target in ipairs(act.targets) do
        for _, action in ipairs(target.actions) do

            -- This is a weaponskill, make sure it is Archery/Marksmanship.
            if act.category == 3 then
                local ws_id = act.param
                if not is_ranged_weaponskill(ws_id) then
                    if ws_id ~= 26 then   -- If it isn't a ranged WS, make sure it isn't Eagle Eye Shot.
                        return
                    end
                end
            end

            if action.message then

                -- ¡Mira a ver si esta muerto!
                    check_for_pulse:schedule(1,target.id)

                -- Cuando cambiamos objetivo.
                if _data.last_target_id and target.id ~= _data.last_target_id then
                    _data.hover_stacks = 0
                end

                if _data.last_stack_valid then
                    _data.hover_stacks = math.min(_data.hover_stacks + 1, 25)
                else
                    _data.hover_stacks = 1
                end

                _data.last_target_id = target.id
                _data.last_shot_pos = {x = player.x, y = player.y}
                return
            end
        end
    end
end)

windower.register_event('login', function()
    _data.logged_in = true

    local player = windower.ffxi.get_player()
    _data.player_id = player and player.id or nil

    _data.last_display_state = nil
    _data.last_update = false
end)

windower.register_event('logout', function()
    _data.logged_in = false
end)
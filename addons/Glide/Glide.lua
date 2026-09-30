_addon.name = 'Glide'
_addon.author = 'Staticvoid'
_addon.version = '1.1.1'
_addon.commands = {'Glide'}

local res = require('resources')
local config = require('config')
local texts = require('texts')

local move_threshold = 1.00 
local last_shot_pos = nil
local player_id = nil
local hover_stacks = 0
local last_target_id = nil
local last_stack_valid = false
local last_update = nil
local distance = 0
local logged_in = true
local next_velocity_check = os.time()
local display = windower.get_windower_settings()
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
    if not logged_in then
        return
    end
    distance_text.glide = '\\cs(225,215,50)Glide™\\cr'
    distance_text.stacks = hover_stacks

    if hover_stacks == 0 then
        distance = 0
    end

    if distance >= 20 then
        distance_text.value = 20
        distance_text.suffix = '+'
    else
        distance_text.value = distance or 0
        distance_text.suffix = ''
    end

    if distance >= move_threshold then
        distance_text.color = '\\cs(0,200,0)'
    else
        distance_text.color = '\\cs(185,200,210)'
    end

    distance_text:update()
    distance_text:show()
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
        hover_stacks = 0
        last_shot_pos = nil
        last_target_id = nil
    end
end

windower.register_event('zone change', function(new, old)
    hover_stacks = 0
    last_shot_pos = nil
    last_target_id = nil
end)

windower.register_event('load', function()
    player_id = windower.ffxi.get_player().id
    update_distance_text(0)
    windower.add_to_chat(207, 'Glide loaded.')
end)

windower.register_event('prerender', function()
    if last_shot_pos then
        local player = windower.ffxi.get_mob_by_id(player_id)
        if player then
            if player.status == 4 then
                last_shot_pos = nil
                return
            end
            local dx = player.x - last_shot_pos.x
            local dy = player.y - last_shot_pos.y
            distance = math.sqrt(dx * dx + dy * dy)
            last_stack_valid = (distance >= 1.0)
            last_update = false
            update_distance_text(distance)
        end
    elseif not last_update then
        last_update = true
        update_distance_text(0)
    end
end)

-- look at various things of concern related to hover shot.
windower.register_event('action', function(act)
    if not logged_in then
        return
    end

    local player = windower.ffxi.get_mob_by_id(player_id)

    if act.actor_id ~= player_id then
        return
    end
    -- If a JA is used make sure its not hover shot.
    if act.category == 6 then
        -- First, look for Hover Shot activation.
        for _, target in ipairs(act.targets) do
            for _, action in ipairs(target.actions) do
                if action.message == 100 and action.param == 628 then
                    hover_stacks = 0
                    last_target_id = nil
                    return
                end
            end
        end
    end

    -- We only care about ranged attacks, weaponskills and Eagle Eye Shot.
    if act.category ~= 2 and act.category ~= 3 then
        return
    end

    -- Only count stacks while Hover Shot is active.
    if not has_hover_shot() then
        hover_stacks = 0
        last_target_id = nil
        last_shot_pos = nil
        local player_main_job = windower.ffxi.get_player().main_job
        if player_main_job == 'RNG' then
            if act.category == 2 or act.category == 3 then
                windower.add_to_chat(207,'Hover Shot is not activated.')
            end
        end
        return
    end

    -- Make Velocity Shot check periodic so we aren't looking at it every action.
    if os.time() > next_velocity_check then
        next_velocity_check = os.time() + 15
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
                if last_target_id and target.id ~= last_target_id then
                    hover_stacks = 0
                end

                if last_stack_valid then
                    hover_stacks = math.min(hover_stacks + 1, 25)
                else
                    hover_stacks = 1
                end

                last_target_id = target.id
                last_shot_pos = {x = player.x, y = player.y}
                return
            end
        end
    end
end)

windower.register_event('login', function()
    logged_in = true
end)

windower.register_event('logout', function()
    logged_in = false
end)
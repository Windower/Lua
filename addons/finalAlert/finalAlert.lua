--[[
Copyright © 2022, Godchain
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of finalAlert nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Godchain BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = "finalAlert"
_addon.author = "Godchain (Asura)"
_addon.version = "1.4"
_addon.commands = {"finalAlert", "fa"}

config = require("config")
texts = require("texts")
res = require("resources")

caption = texts.new({})

background_ability = "background_ability"
background_magic = "background_magic"
background_interrupt = "background_interrupt"
background_emphasize = "background_emphasize"

-- Timing
showing = false
last_trigger = 0

-- IDs
weapon_skill_category = 7
magic_category = 8
interrupt_id = 28787

defaults = {}
defaults.x_position = windower.get_windower_settings().x_res / 2
defaults.y_position = 100
defaults.background_size = "regular"
defaults.emphasize = S {}
defaults.trigger_duration = 3
defaults.sounds = "on"

settings = config.load(defaults)

windower.register_event(
    "load",
    function()
        create_backgrounds(settings.x_position - 250, settings.y_position)
        caption:bg_visible(false)
        caption:bold(true)
    end
)

windower.register_event(
    "postrender",
    function()
        if showing then
            local x, y = caption:extents()
            local x_offset = settings.x_position - x / 2
            local y_offset =
                settings.background_size == "regular" and settings.y_position + 10 or settings.y_position + 3
            caption:pos(x_offset, y_offset)
            if os.time() - last_trigger > settings.trigger_duration then
                hide_caption()
            end
        else
        end
    end
)

windower.register_event(
    "addon command",
    function(cmd, ...)
        local args = L {...}

        if not cmd or cmd == "help" then
            local bullet = windower.to_shift_jis("» ")
            print("=== Usage Examples ===")
            print(bullet .. "//fa test ws")
            print("Shows a test alert (accepts 'ws' for TP moves, 'ma' for magic, 'int' for interrupts).")
            print(bullet .. "//fa emphasize Firaga VI")
            print("Toggles emphasis for "Firaga VI" (plays a different sound).")
            print(bullet .. "//fa pos 960 200")
            print("Moves the display to 960 X (horizontal) and 200 Y (vertical).")
            print(bullet .. "//fa size small")
            print("Sets the display size to small (accepts 'regular' and 'small').")
            print(bullet .. "//fa duration 5")
            print("Sets the display duration to 5 seconds.")
            print(bullet .. "//fa sounds off")
            print("Turns off sounds except for emphasized abilities (accepts 'on' and 'off').")
        elseif cmd == "test" then
            if args[1] == "ws" then
                show_caption("Self-Destruct", "ws")
            elseif args[1] == "ma" then
                show_caption("Tornado II", "ma")
            elseif args[1] == "int" then
                show_caption("Interrupted!", "int")
            else
                print('Please specify "ws", "ma" or "int".')
            end
        elseif cmd == "emphasize" then
            local estring = args:concat(" "):gsub("%s+", ""):lower()
            local verb = settings.emphasize:contains(estring) and "Removed" or "Added"
            print("Emphasize: " .. verb .. ' "' .. args:concat(" ") .. '".')

            if settings.emphasize:contains(estring) then
                settings.emphasize:remove(estring)
            else
                settings.emphasize:add(estring)
            end

            settings:save()
        elseif cmd == "pos" then
            local x = tonumber(args[1])
            local y = tonumber(args[2])

            if type(x) == "number" and type(y) == "number" then
                settings.x_position = x
                settings.y_position = y
                settings:save()
                refresh_backgrounds()
                print("Moved display to: " .. args[1] .. ", " .. args[2])
            else
                print("Please specify x and y coordinates.")
            end
        elseif cmd == "size" then
            local size = args[1]

            if size == "small" or size == "regular" then
                settings.background_size = size
                settings:save()
                refresh_backgrounds()
                print("Display size set to " .. size .. ".")
            else
                print('Please specify "small" or "regular" for the size.')
            end
        elseif cmd == "duration" then
            local duration = tonumber(args[1])

            if type(duration) == "number" and duration > 0 then
                settings.trigger_duration = duration
                print("Display duration set to " .. duration .. " secs.")
            else
                print("Please specify a positive number.")
            end
        elseif cmd == "sounds" then
            local state = args[1]

            if state == "on" or state == "off" then
                settings.sounds = state
                settings:save()
                print("Sounds have been turned " .. state .. ".")
            else
                print('Please specify "on" or "off" for sounds.')
            end
        else
            print("Unrecognized command.")
        end
    end
)

windower.register_event(
    "action",
    function(act)
        local target
        local t = windower.ffxi.get_mob_by_target("t")
        local bt = windower.ffxi.get_mob_by_target("bt")

        if t and t.is_npc and not t.in_party and not t.in_alliance then
            target = t.id
        elseif bt then
            target = bt.id
        else
            return
        end

        if act.category == weapon_skill_category and act.actor_id == target then
            local skill_name =
                res.monster_abilities[act.targets[1].actions[1].param] and
                res.monster_abilities[act.targets[1].actions[1].param].name or
                "???"

            if act.param == interrupt_id then
                skill_name = "Interrupted!"
                show_caption(skill_name, "int")
            else
                show_caption(skill_name, "ws")
            end
        elseif act.category == magic_category and act.actor_id == target then
            local spell_name =
                res.spells[act.targets[1].actions[1].param] and res.spells[act.targets[1].actions[1].param].name or
                "???"

            if act.param == interrupt_id then
                spell_name = "Interrupted!"
                show_caption(spell_name, "int")
            else
                show_caption(spell_name, "ma")
            end
        end
    end
)

function refresh_backgrounds()
    create_backgrounds(settings.x_position - 250, settings.y_position)
end

function create_backgrounds(x, y)
    windower.prim.create(background_ability)
    windower.prim.set_fit_to_texture(background_ability, true)
    windower.prim.set_texture(
        background_ability,
        windower.addon_path .. "images/" .. settings.background_size .. "/background_ability.png"
    )
    windower.prim.set_position(background_ability, x, y)
    windower.prim.set_visibility(background_ability, false)

    windower.prim.create(background_magic)
    windower.prim.set_fit_to_texture(background_magic, true)
    windower.prim.set_texture(
        background_magic,
        windower.addon_path .. "images/" .. settings.background_size .. "/background_magic.png"
    )
    windower.prim.set_position(background_magic, x, y)
    windower.prim.set_visibility(background_magic, false)

    windower.prim.create(background_interrupt)
    windower.prim.set_fit_to_texture(background_interrupt, true)
    windower.prim.set_texture(
        background_interrupt,
        windower.addon_path .. "images/" .. settings.background_size .. "/background_interrupt.png"
    )
    windower.prim.set_position(background_interrupt, x, y)
    windower.prim.set_visibility(background_interrupt, false)

    windower.prim.create(background_emphasize)
    windower.prim.set_fit_to_texture(background_emphasize, true)
    windower.prim.set_texture(
        background_emphasize,
        windower.addon_path .. "images/" .. settings.background_size .. "/background_emphasize.png"
    )
    windower.prim.set_position(background_emphasize, x, y)
    windower.prim.set_visibility(background_emphasize, false)
end

function show_caption(text, type)
    local event_type

    hide_caption()
    showing = true
    caption:text(text)
    caption:show()

    if (type == "ws") then
        event_type = "ability"
        windower.prim.set_visibility(background_ability, true)
    elseif (type == "ma") then
        event_type = "magic"
        windower.prim.set_visibility(background_magic, true)
    elseif (type == "int") then
        event_type = "interrupt"
        windower.prim.set_visibility(background_interrupt, true)
    end

    if (settings.emphasize:contains(text:gsub("%s+", ""):lower())) then
        windower.play_sound(windower.addon_path .. "sounds/emphasize.wav")
        windower.prim.set_visibility(background_emphasize, true)
    elseif (settings.sounds == "on") then
        windower.play_sound(windower.addon_path .. "sounds/" .. event_type .. "_alert.wav")
    end

    last_trigger = os.time()
end

function hide_caption()
    showing = false
    caption:hide()
    windower.prim.set_visibility(background_ability, false)
    windower.prim.set_visibility(background_magic, false)
    windower.prim.set_visibility(background_interrupt, false)
    windower.prim.set_visibility(background_emphasize, false)
end

function print(str)
    windower.add_to_chat(207, str)
end

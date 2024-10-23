_addon = {}
_addon.name = 'chatmon'
_addon.version = '1.0.0'
_addon.author = 'WindowerDevTeam'
_addon.commands = {'chatmon'}

require('sets')
require('strings')
local config = require('config')
local chat_res = require('resources').chat
local plugin_settings = require('depercate_plugin')
local get_triggers = require('get_triggers')

local defaults = {
    DisableOnFocus=false,
    SoundInterval=5,
}
local settings = config.load(plugin_settings or defaults)

local triggers = {}
local function load_triggers(name)
    triggers = get_triggers.by_name(name)
end
windower.register_event('login', load_triggers)

local function on_load()
    local player = windower.ffxi.get_player()
    if player then
        load_triggers(player.name)
    end
end
windower.register_event('load', on_load)

local last_sound = 0
local function play_sound(sound)
    if (os.time() - last_sound >= settings.SoundInterval) then
        last_sound = os.time();
        if(windower.file_exists(windower.addon_path .. "/data/sounds/" .. sound)) then
            windower.play_sound(windower.addon_path .. "/data/sounds/" .. sound)
        elseif (windower.file_exists(sound)) then
            windower.play_sound(sound)
        end
    end
end

local function check_triggers(from, text)
    if (windower.has_focus() and settings.DisableOnFocus) then
        return
    end

    for _, trigger in ipairs(triggers) do
        if trigger.match == '<name>' then -- this is done to have parity with the old plugin.
            local player_name = windower.ffxi.get_player().name:lower()
            trigger.match = "* " .. player_name .. "|"
                                 .. player_name .. " *|*\""
                                 .. player_name .. "\"*|*("
                                 .. player_name .. ")*|"
                                 .. player_name .. "|* "
                                 .. player_name .. " *|* "
                                 .. player_name .. "? *|* "
                                 .. player_name .. "?|"
                                 .. player_name .. "? *|"
                                 .. player_name .. "?|*<"
                                 .. player_name .. ">*"
        end
        if trigger.from[from] and not trigger.notFrom[from] and windower.wc_match(text, trigger.match) and not windower.wc_match(text, trigger.notMatch) then
            play_sound(trigger.sound)
            return
        end
    end
end

local function chat_handler(message, _, mode)
    check_triggers(chat_res[mode].name, message)
end
windower.register_event('chat message', chat_handler)

local function examine_handler(name)
    check_triggers('examine', name)
end
windower.register_event('examined', examine_handler)

local function invite_handler(name)
    check_triggers('invite', name)
end
windower.register_event('party invite', invite_handler)

local function emote_handler(_, sender_id, target_id)
    local player_id = windower.ffxi.get_player().id
    if (player_id ~= target_id) then
        return
    end

    local sender_name = windower.ffxi.get_mob_by_id(sender_id).name
    check_triggers('emote', sender_name)
end
windower.register_event('emote', emote_handler)

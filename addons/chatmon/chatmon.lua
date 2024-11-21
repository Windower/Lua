_addon = {}
_addon.name = 'chatmon'
_addon.version = '1.0.5'
_addon.author = 'WindowerDevTeam'
_addon.commands = {'chatmon'}

require('sets')
require('strings')
local config = require('config')
local chat_res = require('resources').chat
local plugin_settings = require('deprecate_plugin')
local get_triggers = require('get_triggers')

windower.create_dir(windower.addon_path .. '/data/sounds/')

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
    if os.time() - last_sound >= settings.SoundInterval then
        last_sound = os.time();
        if windower.file_exists(windower.addon_path .. '/sounds/' .. sound) then
            windower.play_sound(windower.addon_path .. '/sounds/' .. sound)
        elseif windower.file_exists(windower.addon_path .. '/data/sounds/' .. sound) then
            windower.play_sound(windower.addon_path .. '/data/sounds/' .. sound)
        elseif windower.file_exists(sound) then
            windower.play_sound(sound)
        end
    end
end

local function check_triggers(from, text, sender)
    if windower.has_focus() and settings.DisableOnFocus then
        return
    end

    text = windower.convert_auto_trans(text)
    local event = {from = from, text = text, sender = sender or ''}
    for _, trigger in ipairs(triggers) do
        if trigger:check(event) then
            play_sound(trigger.sound)
            return
        end
    end
end

local function chat_handler(message, sender, mode)
    local chat_mode = chat_res[mode]

    if chat_mode == nil then
        print(string.format('Chatmon error: unknown chat mode = %d', mode))
        print(string.format('  msg = %s', message))
        return
    end

    if chat_mode.name == 'emote' then -- emote triggers check match against the sender name not message text.
        return
    end

    check_triggers(chat_res[mode].name, message, sender)
end
windower.register_event('chat message', chat_handler)

local function incoming_text_handler(original)
    check_triggers('all', original)
end
windower.register_event('incoming text', incoming_text_handler)

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

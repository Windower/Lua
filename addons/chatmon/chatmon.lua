--[[
Copyright © 2024, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of chatmon nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon = {}
_addon.name = 'chatmon'
_addon.version = '1.1.4'
_addon.author = 'WindowerDevTeam'
_addon.commands = {'chatmon'}

require('sets')
require('chat')
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
    text = text:strip_colors()
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

--[[
Copyright © 2015, Seth VanHeulen
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

_addon.name = 'visiblefavor'
_addon.version = '1.0.0'
_addon.command = 'visiblefavor'
_addon.commands = {'vf'}
_addon.author = 'Seth VanHeulen (Acacia@Odin)'

config = require('config')
require('pack')

model_to_effect = {
    [0x10] = 0x66, -- Carbuncle
    [0x11] = 0x67, -- Fenrir
    [0x12] = 0x60, -- Ifrit
    [0x13] = 0x63, -- Titan
    [0x14] = 0x65, -- Leviathan
    [0x15] = 0x62, -- Garuda
    [0x16] = 0x61, -- Shiva
    [0x17] = 0x64, -- Ramuh
    [0x19] = 0x67, -- Diabolos
    [0x1c] = 0x66, -- Cait Sith
}

refresh = true
pet_index = 0
favor_buff = false

defaults = {}
defaults.enabled = true
defaults.display_mode = 'favor'
defaults.effect_mode = 'debuff'

settings = config.load(defaults)

function check_incoming_chunk(id, original, modified, injected, blocked)
    if id == 0x037 then
        refresh = true
    elseif settings.enabled and id == 0x00E then
        if refresh and settings.display_mode ~= 'all' then
            local player = windower.ffxi.get_player()
            pet_index = windower.ffxi.get_mob_by_index(player.index).pet_index
            if settings.display_mode == 'favor' then
                for _,buff_id in pairs(player.buffs) do
                    if buff_id == 431 then
                        favor_buff = true
                        break
                    end
                    favor_buff = false
                end
            end
        end
        local npc_index = original:unpack('H', 9)
        if settings.display_mode == 'all' or settings.display_mode == 'self' and pet_index == npc_index or settings.display_mode == 'favor' and favor_buff and pet_index == npc_index then
            local npc_model = original:unpack('H', 0x33)
            if model_to_effect[npc_model] then
                local effect = model_to_effect[npc_model]
                if settings.effect_mode == 'debuff' then
                    effect = effect + 8
                end
                return modified:sub(1, 38) .. string.char(effect) .. modified:sub(40)
            end
        end
    end
end

function visiblefavor_command(...)
    local arg = {...}
    if #arg == 1 and arg[1]:lower() == 'toggle' then
        settings.enabled = not settings.enabled
    elseif #arg == 1 and arg[1]:lower() == 'on' then
        settings.enabled = true
    elseif #arg == 1 and arg[1]:lower() == 'off' then
        settings.enabled = false
    elseif #arg == 2 and arg[1]:lower() == 'display' and arg[2]:lower() == 'all' then
        settings.display_mode = 'all'
    elseif #arg == 2 and arg[1]:lower() == 'display' and arg[2]:lower() == 'self' then
        settings.display_mode = 'self'
    elseif #arg == 2 and arg[1]:lower() == 'display' and arg[2]:lower() == 'favor' then
        settings.display_mode = 'favor'
    elseif #arg == 2 and arg[1]:lower() == 'effect' and arg[2]:lower() == 'buff' then
        settings.effect_mode = 'buff'
    elseif #arg == 2 and arg[1]:lower() == 'effect' and arg[2]:lower() == 'debuff' then
        settings.effect_mode = 'debuff'
    else
        windower.add_to_chat(167, 'Command usage:')
        windower.add_to_chat(167, '    vf toggle/on/off')
        windower.add_to_chat(167, '    vf display all/self/favor')
        windower.add_to_chat(167, '    vf effect buff/debuff')
        return
    end
    windower.add_to_chat(207, 'visiblefavor: enable = %s, display = \31\200%s\30\1, effect = \31\200%s\30\1':format(settings.enabled and '\31\204yes\30\1' or '\31\167no\30\1', settings.display_mode, settings.effect_mode))
    settings:save()
end

windower.register_event('incoming chunk', check_incoming_chunk)
windower.register_event('addon command', visiblefavor_command)

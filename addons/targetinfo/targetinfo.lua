_addon.name = 'TargetInfo'
_addon.author = 'Arcon'
_addon.version = '1.0.1.2'
_addon.language = 'English'

require('luau')
texts = require('texts')

-- Config

defaults = {}
defaults.ShowHexID = true
defaults.ShowFullID = true
defaults.ShowSpeed = true
defaults.ShowTargetName = false
defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 0
defaults.display.pos.y = 0
defaults.display.bg = {}
defaults.display.bg.red = 0
defaults.display.bg.green = 0
defaults.display.bg.blue = 0
defaults.display.bg.alpha = 102
defaults.display.text = {}
defaults.display.text.font = 'Consolas'
defaults.display.text.red = 255
defaults.display.text.green = 255
defaults.display.text.blue = 255
defaults.display.text.alpha = 255
defaults.display.text.size = 12

settings = config.load(defaults)
settings:save()

text_box = texts.new(settings.display, settings)

-- Constructor

initialize = function(text, settings)
    local properties = L{}
    if settings.ShowFullID then
        properties:append('ID:            ${full|-|%08s}')
    end
    if settings.ShowHexID then
        properties:append('Hex ID:             ${hex|-|%.3X}')
    end
    if settings.ShowSpeed then
        properties:append('Speed:           ${speed|-}')
    end
    if settings.ShowTargetName then
        properties:append('${target_label} ${target_name||%15s}')
    end

    text:clear()
    text:append(properties:concat('\n'))
end

text_box:register_event('reload', initialize)

-- Events

windower.register_event('prerender', function()
    local remove = S{}
    local mob = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t')
    if mob and mob.id > 0 then
        local player = windower.ffxi.get_player()
        local mobclaim = windower.ffxi.get_mob_by_id(mob.claim_id)
        local target = windower.ffxi.get_mob_by_index(mob.target_index)
        local info = {}
        info.hex = mob.index
        info.full = mob.id
        local speed = (mob.status == 5 or mob.status == 85) and (100 * (mob.movement_speed / 4)):round(2) or (100 * (mob.movement_speed / 5 - 1)):round(2)
        info.speed = (
            speed > 0 and
                '\\cs(0,255,0)' .. ('+' .. speed):lpad(' ', 5)
            or speed < 0 and
                '\\cs(255,0,0)' .. speed:string():lpad(' ', 5)
            or
                '\\cs(102,102,102)' .. ('+' .. speed):lpad(' ', 5)) .. '%\\cr'
        if mob.id == player.id then
            info.target_label = 'Target:'
            info.target_name = mob.name
        elseif mobclaim and mobclaim.id > 0 then
            info.target_label = 'Claim: '
            info.target_name = mobclaim and mobclaim.name or nil
        elseif target and target.id > 0 then
            info.target_label = 'Target:'
            info.target_name = target and target.name or nil
        else
            remove:add('target_label')
            remove:add('target_name')
        end
        text_box:update(info)
        text_box:show()
        for entry in remove:it() do
            text_box[entry] = nil
        end
    else
        text_box:hide()
    end
end)

--[[
Copyright © 2013-2017, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

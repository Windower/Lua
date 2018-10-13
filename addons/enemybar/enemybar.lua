--[[
Copyright © 2015, Mike McKee
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of enemybar nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mike McKee BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

_addon.name = 'enemybar'
_addon.author = 'mmckee,akaden'
_addon.version = '1.1.0'
_addon.language = 'English'

config = require('config')
images = require('images')
texts = require('texts')
table = require('table')
require 'bars'
require 'actionTracking'

player_id = 0
debug_string = ''

windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in then
        player_id = windower.ffxi.get_player().id
    end
end)

defaults = {}
defaults.target_bar = {}
defaults.target_bar.pos = {x=650,y=750}
defaults.target_bar.width = 600
defaults.target_bar.color = {alpha=255,red=255,green=0,blue=0}
defaults.target_bar.font = 'Arial'
defaults.target_bar.font_size = 14
defaults.target_bar.show_target_icon = false
defaults.target_bar.show_target = false
defaults.target_bar.show_action = false
defaults.target_bar.show_dist = false
defaults.subtarget_bar = {}
defaults.subtarget_bar.pos = {x=680,y=700}
defaults.subtarget_bar.width = 300
defaults.subtarget_bar.color = {alpha=255,red=0,green=0,blue=255}
defaults.subtarget_bar.font = 'Arial'
defaults.subtarget_bar.font_size = 12
defaults.subtarget_bar.show_target_icon = false
defaults.subtarget_bar.show_target = false
defaults.subtarget_bar.show_action = false
defaults.subtarget_bar.show_dist = false
defaults.aggro_bar = {}
defaults.aggro_bar.pos = {x=350,y=550}
defaults.aggro_bar.width = 180
defaults.aggro_bar.color = {alpha=255,red=0,green=150,blue=50}
defaults.aggro_bar.font = 'Arial'
defaults.aggro_bar.font_size = 9
defaults.aggro_bar.show_target_icon = true
defaults.aggro_bar.show_target = true
defaults.aggro_bar.show_action = true
defaults.aggro_bar.show_dist = true
defaults.aggro_bar.count = 6
defaults.aggro_bar.show_aggro = false

settings = config.load(defaults)

config.save(settings)

local target_bar = bars.new(nil, settings.target_bar)
local subtarget_bar = bars.new(nil, settings.subtarget_bar)

function generate_agro_bars(settings)
  local l = {}
  for i = 1, settings.count do
    l[i] = bars.new(nil, settings)
    settings.pos.y = settings.pos.y + 27
  end
  return l
end
local aggro_bars = generate_agro_bars(settings.aggro_bar)

windower.register_event('prerender', function()
  update_bar(target_bar, windower.ffxi.get_mob_by_target('t'))
  update_bar(subtarget_bar, windower.ffxi.get_mob_by_target('st'))

  if settings.aggro_bar.show_aggro then
    local e_bar_i = 1
    for k,v in pairs(tracked_enmity) do
      if e_bar_i > settings.aggro_bar.count then
        break
      end
      local bar = aggro_bars[e_bar_i]
      target = windower.ffxi.get_mob_by_id(k)
      update_bar(bar, target)
      e_bar_i = e_bar_i + 1
    end

    for i=e_bar_i, settings.aggro_bar.count do
        local bar = aggro_bars[i]
        if bar then
          bars.hide(bar)
        end
    end
  end
end)
windower.register_event('prerender', clean_tracked_actions)
windower.register_event('incoming chunk', handle_action_packet)
windower.register_event('zone change', reset_tracked_actions)

windower.register_event('logout', function(...)
    -- This is a super cheap fix, but it works. 
    windower.send_command("input //lua r enemybar");        
end)



check_claim = function(claim_id)
    if player_id == claim_id then
        return true
    else
        for i = 1, 5, 1 do
            member = windower.ffxi.get_mob_by_target('p'..i)
            if member == nil then
                -- do nothing
            elseif member.id == claim_id then 
                return true
            end
        end
    end
    return false
end


function get_tint_by_target(target)
  if target.hpp == 0 then
       return {red=155, green=155, blue=155}
    elseif check_claim(target.claim_id) then
       return {red=255, green=180, blue=180}
    elseif target.in_party == true and target.id ~= player_id then
       return {red=102, green=255, blue=255}
    elseif target.is_npc == false then
       return {red=255, green=255, blue=255}
    elseif target.claim_id == 0 then
       return {red=230, green=230, blue=138} 
    elseif target.claim_id ~= 0 then
       return {red=153, green=102, blue=255}
    end  
end

function  update_bar(bar, target)
    if target ~= nil then   
      bars.show(bar)

      local dist = get_distance(windower.ffxi.get_mob_by_target('me'), target)

      local t = windower.ffxi.get_mob_by_target('t')
      local st = windower.ffxi.get_mob_by_target('st')
      local target_type = nil
      if t and t.id == target.id then 
        target_type = 1
      elseif st and st.id == target.id then
        target_type = 2
      end
      bars.update_target(bar, target.name, target.hpp, dist, target_type)

      local action = tracked_actions[target.id]
      if action and not action.complete then
          bars.update_action(bar, action.ability.en, '')
      else
          bars.update_action(bar, nil, '')
      end

      local enmity_target = tracked_enmity[target.id]
      if enmity_target and enmity_target.pc then
        bars.update_enmity(bar, enmity_target.pc.name, get_tint_by_target(enmity_target.pc))
      else
        bars.update_enmity(bar, nil)
      end

      bars.set_name_color(bar, get_tint_by_target(target))
    else
      bars.hide(bar)
    end
end

function get_distance(player, target)
  local dx = player.x-target.x
  local dy = player.y-target.y
  return math.sqrt(dx*dx + dy*dy)
end
--[[
Copyright (c) 2013, Ricky Gall
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of <addon name> nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]


_addon.name = 'OhShi'
_addon.version = '2.55'
_addon.author = 'Nitrous (Shiva)'
_addon.command = 'ohshi'

--Requiring libraries used in this addon
--These should be saved in addons/libs
require('logger')
require('tables')
require('strings')
require('sets')
config = require('config')
files = require('files')
chat = require('chat')
texts = require('texts')
res = require('resources')
require('default_settings')
require('text_handling')
require('helper_functions')

--This function is called when the addon loads. Defines aliases and 
--registers functions, as well as filling the resource tables.
windower.register_event('load', initText)

--Used when the addon is unloaded to save settings.
windower.register_event('unload',function()
    settings:update(ohShi_tb._settings)
    settings:save('all')
end)

function saveSettings()
    addText('OhShi Settings Updated')
    settings:save('all')
end

--This function is used to process addon commands
--like //ohshi help and the like.
windower.register_event('addon command', function(...)
    local args = T{...}
    if args[1] == nil then args[1] = 'help' end
    if args[1] ~= nil then
        local comm = table.remove(args,1):lower()
        
        if S{'showrolls','selfrolls'}:contains(comm) then
            settings[comm] = not settings[comm]
            settings.staggeronly = false
            if comm == 'selfrolls' and not settings.showrolls then
                settings.showrolls = true
            elseif comm == 'showrolls' and settings.selfrolls then
                settings.selfrolls = false
            end
            print('OhShi Showrolls:', settings.showrolls)
            print('OhShi Selfrolls:', settings.selfrolls)
            settings:save('all')
        elseif comm == "staggeronly" then
            settings.staggeronly = not settings.sstaggeronly
            print('OhShi Stagger Only mode:', settings.staggeronly)
        elseif comm == 'duration' then
            if tonumber(args[1]) then
                settings.duration = tonumber(args[1])
                print('OhShi Duration:',settings.duration)
                saveSettings()
            end
        elseif S{'trackon','trackoff'}:contains(comm) then
            local typ = ''
            if S{'abyssea','dangerous','legion','meebles','other','voidwatch'}:contains(args[1]) then
                typ = table.remove(args,1):lower()
            else
                typ = 'other'
            end
            local list = args:concat(' '):capitalize()
            if comm == 'trackon' then
                if not settings.moblist[typ]:find(string.imatch-{list}) then
                    settings.moblist[typ]:add(list)
                    notice(list..' added to '..typ..' table.')
                end
            else
                if settings.moblist[typ]:find(string.imatch-{list}) then
                    settings.moblist[typ]:remove(settings.moblist[typ]:find(string.imatch-{list}))
                    notice(list..' removed from '..typ..' table.')
                end
            end
            settings:save('all')
        elseif S{'spellon','spelloff','wson','wsoff'}:contains(comm) then
            local typ = ''
            if S{'spellon','spelloff'}:contains(comm) then
                typ = 'spells'
            else
                typ = 'weaponskills'
            end
            local list = args:concat(' '):capitalize()
            if comm:find('on$') then
                if not settings.dangerwords[typ]:find(string.imatch-{list..'$'}) then
                    settings.dangerwords[typ]:add(list)
                    notice(list..' added to '..typ..' table.')
                end
            else
                if settings.dangerwords[typ]:find(string.imatch-{list..'$'}) then
                    settings.dangerwords[typ]:remove(settings.dangerwords[typ]:find(string.imatch-{list..'$'}))
                    notice(list..' removed from '..typ..' table.')
                end
            end
            settings:save('all')
        elseif S{'fonttype','fontsize','pos','bgcolor','txtcolor'}:contains(comm) then
                if comm == 'fonttype' then ohShi_tb:font(args[1] or nil)
            elseif comm == 'fontsize' then ohShi_tb:size(args[1] or nil)
            elseif comm == 'pos' then ohShi_tb:pos(args[1] or nil,args[2] or nil)
            elseif comm == 'bgcolor' then ohShi_tb:bgcolor(args[1] or nil,args[2] or nil,args[3] or nil)
            elseif comm == 'txtcolor' then ohShi_tb:color(args[1] or nil,args[2] or nil,args[3] or nil)
            end
            settings:update(ohShi_tb._settings)
            settings.bg.alpha = nil
            settings.padding = nil
            settings.text.alpha = nil
            settings.text.content = nil
            settings.visible = nil
            saveSettings()
        elseif comm == 'clear' then
            tracking:clear()
            textUpdate()
        elseif S{'show','hide','settings'}:contains(comm) then
            if comm == 'show' then 
                ohShi_tb:text('ohShi showing for settings')
                ohShi_tb:show()
            elseif comm == 'hide' then 
                settings:update(ohShi_tb._settings)
                settings.bg.alpha = nil
                settings.padding = nil
                settings.text.alpha = nil
                settings.text.content = nil
                settings.visible = nil
                textUpdate()
                ohShi_tb:hide()
                settings:save('all')
            elseif comm == 'settings' then 
                windower.add_to_chat(207,'OhShi - Current Textbox Settings')
                windower.add_to_chat(207,'  BG:   R: '..settings.bg.red..'  G: '..settings.bg.green..'  B: '..settings.bg.blue)
                windower.add_to_chat(207,'  Font: '..settings.text.font..'  Size: '..settings.text.size)
                windower.add_to_chat(207,'  Text: R: '..settings.text.red..'  G: '..settings.text.green..'  B: '..settings.text.blue)
                windower.add_to_chat(207,'  Pos:  X: '..settings.pos.x..'  Y: '..settings.pos.y)
            end
        else
            local helptext = [[OhShi - Command List:
  1. help - Brings up this menu.
  2. showrolls | selfrolls - Show corsair rolls in tracker | only own rolls.
  3. staggeronly - Only show voidwatch stagger notices.
  4. track(on/off) [abyssea/dangerous/legion/meebles/other/voidwatch] <name> 
     - Begin or stop tracking <type (default: other)> of mob named <name>.
  5. spell/ws(on/off) <name> - Start or stop watching for <name> spell|ws.
  6. clear - Clears the textbox and the tracking table (use if textbox locks up)
  The following all correspond to the tracker:
    fonttype <name> | fontsize <size> | pos <x> <y> - can also click/drag
    bgcolor <r> <g> <b> | txtcolor <r> <g> <b>
    duration <time> - Changes the duration things appear in tracker.
    settings - shows current textbox settings
    show/hide - toggles visibility of the tracker so you can make changes.]]
            for _, line in ipairs(helptext:split('\n')) do
                windower.add_to_chat(207, line..chat.controls.reset)
            end
        end
    end
end)

--This event happens when an action packet is received.
windower.register_event('action', function(act)
    local curact = T(act)
    local actor = T{}
    actor.id = curact.actor_id
    if windower.ffxi.get_mob_by_id(actor.id) then
        actor.name = windower.ffxi.get_mob_by_id(actor.id).name
    else
        return
    end
    local extparam = curact.param
    local targets = curact.targets
    local party = T(windower.ffxi.get_party())
    local typ = ''
    local danger = false
    local player = T(windower.ffxi.get_player())
    
    if not settings.staggeronly then
        if settings.showrolls and curact.category == 6 and res.job_abilities[extparam].type == 'CorsairRoll' then
            local allyroller = false
            local selfroll = false
            for pt,member in pairs(party) do
                if type(member) == 'table' and member.name == actor.name then
                    allyroller = true
                    break
                end
            end
            if allyroller or selfroll then
                if actor.id == player.id then selfroll = true end
                if settings.selfrolls and not selfroll then return end
                addText(actor.name, 'roll', extparam, targets[1].actions[1].param)
            end
        elseif isMob(actor.id) and S{7,8}:contains(curact.category) and extparam ~= 28787 then
            local inact = targets[1].actions[1]
            if curact.category == 8 then typ = 'spell'
            else typ = 'ws' end
            if (mCheck(actor.name) or dCheck(typ,inact.param)) and inact.message ~= 0 then
                addText(actor.name, typ, inact.param, mDanger(actor.name), dCheck(typ,inact.param))
            end
        end
    end
end)

--Catches statuses wearing on mobs you applied them to
windower.register_event('action message',function(actor_id, target_id, actor_index, target_index, message_id, param_1, param_2, param_3)
    if not settings.staggeronly then
        local actor = T(windower.ffxi.get_mob_by_id(actor_id))
        local player = T(windower.ffxi.get_player())
        local target = T(windower.ffxi.get_mob_by_id(target_id))
        if S{204,205,206}:contains(message_id) and isMob(target_id) then
            if actor.id == player.id then
                if mCheck(target.name) then
                    if message_id == 204 then
                        addText(target.name .. ' is no longer ' .. res.buffs[param_1].english_log)
                    elseif message_id == 205 then
                        addText(target.name .. ' gains the effect of ' .. res.buffs[param_1].english_log)
                    else
                        addText(target.name .. ' ' .. res.buffs[param_1].english_log .. ' effect wears off.')
                    end
                end
            end
        end
    end
end)

--This event happens whenever text is incoming to the chatlog
windower.register_event('incoming text', function(old,new,color,newcolor)
    if string.find(old,'(%w+)\'s attack devastates the fiend%p') then
        addText('devastates',string.find(old,'(%w+)\'s attack devastates the fiend%p'))
    elseif string.find(old,'Blue: (%d+)%% / Red: (%d+)%%') then
        addText('bluered',string.find(old,'Blue: (%d+)%% / Red: (%d+)%%'))
    elseif string.find(old,'Blue: (%d+)') then
        addText('blue',string.find(old,'Blue: (%d+)'))
    elseif string.find(old,'Red: (%d+)') then
        addText('red',string.find(old,'Red: (%d+)'))
    elseif string.find(old,'The fiend appears(.*)vulnerable to ([%w%s]+)!') then
        addText('vulnerable',string.find(old,'The fiend appears(.*)vulnerable to ([%w%s]+)!'))
    elseif string.find(old,'(%w+) is the key to victory!') then
        addText('victory',string.find(old,'(%w+) is the key to victory'))
    end
end) 

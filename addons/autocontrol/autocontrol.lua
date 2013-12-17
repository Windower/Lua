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



_addon.name = 'autocontrol'
_addon.version = '0.21'
_addon.author = 'Nitrous (Shiva)'
_addon.commands = {'autocontrol','acon'}

require 'tablehelper'
require 'stringhelper'
require 'logger'
require 'sets'
res = require 'resources'
config = require 'config'
files = require 'filehelper'
defaults = T{}
defaults.bg = {}
defaults.bg.red = 0
defaults.bg.blue = 0
defaults.bg.green = 0
defaults.pos = {}
defaults.pos.x = 400
defaults.pos.y = 300
defaults.text = {}
defaults.text.red = 255
defaults.text.green = 255
defaults.text.blue = 255
defaults.text.font = 'Consolas'
defaults.text.size = 10
defaults.autosets = T{}
defaults.autosets.default = T{ }
    
settings = config.load(defaults)
settings:save()

require 'maneuver'


function initialize()
    petlessZones = S{50,235,234,224,284,233,70,257,251,14,242,250,226,245,
                     237,249,131,53,252,231,236,246,232,240,247,243,223,248,230,
                     26,71,244,239,238,241,256,257}
    mjob_id = windower.ffxi.get_player()['main_job_id']
    atts = res.items:category('General')
    decay = 1
    for key,_ in pairs(heat) do
        heat[key] = 0
        Burden_tb[key] = 0
        Burden_tb['time'..key] = 0 
    end
    if windower.ffxi.get_mob_by_id(windower.ffxi.get_player()['id'])['pet_index'] ~= 0 then 
        running = 1
        text_update_loop('start')
        Burden_tb:show()
    end
end

windower.register_event('load', function()
    if windower.ffxi.get_info()['logged_in'] then
        initialize()
    end
end)

windower.register_event('login', function()
    initialize()
end)

windower.register_event('logout', function()
    text_update_loop('stop')
end)

windower.register_event('unload', function()
    text_update_loop('stop')
end)

function attach_set(autoset)
    if windower.ffxi.get_player()['main_job_id'] ~= 18 then return nil end
    if settings.autosets[autoset] == nil then return end
    if settings.autosets[autoset]:equals(get_current_autoset()) then
        log('The '..autoset..' set is already equipped.')
        return
    end
    if windower.ffxi.get_mob_by_id(windower.ffxi.get_player()['id'])['pet_index'] ~= 0 then 
        if windower.ffxi.get_ability_recasts()[208] == 0 then
            windower.send_command('input /pet "Deactivate" <me>')
            log('Deactivating '..windower.ffxi.get_mjob_data()['name']..'.')
            windower.send_command('@wait 2;lua i autocontrol attach_set '..autoset)
        else
            local var = windower.ffxi.get_ability_recasts()[208]
            if var ~= nil then
                error('Deactivate on cooldown wait '..((var * 1) / 60)..' seconds and try again')
            end
        end
    else
        windower.ffxi.reset_attachments()
        log('Starting to equip '..autoset..' to '..windower.ffxi.get_mjob_data()['name']..'.')
        set_attachments_from_autoset(autoset, 'head')
    end
end

function set_attachments_from_autoset(autoset,slot)
    if slot == 'head' then
        local tempHead = settings.autosets[autoset]['head']
        if tempHead ~= nil then
            for id = 8193, 8198 do
                if atts[id] ~= nil then
                    if atts[id]['english'] == tempHead then
                        windower.ffxi.set_attachment(id)
                        break
                    end
                end
            end
        end
        windower.send_command('@wait .5;lua i autocontrol set_attachments_from_autoset '..autoset..' frame')
    elseif slot == 'frame' then
        local tempFrame = settings.autosets[autoset]['frame']
        if tempFrame ~= nil then
            for id = 8224, 8227 do
                if atts[id] ~= nil then
                    if atts[id]['english'] == tempFrame then
                        windower.ffxi.set_attachment(id)
                        break
                    end
                end
            end
        end
        windower.send_command('@wait .5;lua i autocontrol set_attachments_from_autoset '..autoset..' 1')
    else
        local islot
        if tonumber(slot) < 10 then 
            islot = '0'..slot
        else islot = slot end
        local tempname = settings.autosets[autoset]['slot'..islot]
        if tempname ~= nil then
            for id = 8449, 8680 do
                if atts[id] ~= nil then
                    if atts[id]['english'] == tempname then
                        windower.ffxi.set_attachment(id, tonumber(slot))
                        break
                    end
                end
            end
        end
    
        if tonumber(slot) < 12 then
            windower.send_command('@wait .5;lua i autocontrol set_attachments_from_autoset '..autoset..' '..slot+1)
        else
            log(windower.ffxi.get_mjob_data()['name']..' has been equipped with the '..autoset..' set.')
            if petlessZones:contains(windower.ffxi.get_info()['zone_id']) then 
                return
            else
                if windower.ffxi.get_ability_recasts()[205] == 0 then
                    windower.send_command('input /ja "Activate" <me>')
                else
                    log('Unable to reactivate. Activate timer was not ready.')
                end
            end
        end
    end
end

function get_current_autoset()
    if windower.ffxi.get_player()['main_job_id'] == 18 then
        local autoTable = T{}
        local tmpTable = T{}
        local tmpTable = T(windower.ffxi.get_mjob_data()['attachments'])
        local i,id
        for i = 1, #tmpTable do
            local t = ''
            if tonumber(tmpTable[i]) ~= 0 then 
                if i < 10 then t = '0' end
                autoTable['slot'..t..i] = atts[tonumber(tmpTable[i])+8448]['english']
            end
        end
        local headnum = windower.ffxi.get_mjob_data()['head']
        local framenum = windower.ffxi.get_mjob_data()['frame']
        autoTable['head'] = atts[headnum+8192]['english']
        autoTable['frame'] = atts[framenum+8223]['english']
        return autoTable
    end
end

function save_set(setname)
    if setname == 'default' then 
        error('Please choose a name other than default.') 
        return 
    end
    local curAuto = T(get_current_autoset())
    settings.autosets[setname] = curAuto
    settings:save()
    notice('Set '..setname..' saved.')
end

function get_autoset_list()
    log("Listing sets:")
    for key,_ in pairs(settings.autosets) do
        if key ~= 'default' then
            local it = 0
            for i = 1, #settings.autosets[key] do
                it = it + 1
            end
            log("\t"..key..': '..(settings.autosets[key]:length()-2)..' attachments.')
        end
    end
end

function get_autoset_content(autoset)
    log('Getting '..autoset..'\'s attachment list:')
    settings.autosets[autoset]:vprint()
end

windower.register_event("addon command", function(...)
    if windower.ffxi.get_player()['main_job_id'] ~= 18 then
        error('You are not on Puppetmaster.')
        return nil 
    end
    local args = T{...}
    if args ~= nil then
        local comm = table.remove(args,1):lower()
        
        if comm == 'save' then
            if args[1] ~= nil then
                save_set(args[1])
            end
        elseif comm == 'add' then
            if args[2] ~= nil then
                local slot = table.remove(args,1)
                local attach = args:sconcat()
                add_attachment(attach,slot)
            end
        elseif comm == 'equipset' then
            if args[1] ~= nil then
                attach_set(args[1])
            end
        elseif comm == 'setlist' then
            get_autoset_list()
        elseif comm == 'attlist' then
            if args[1] ~= nil then
                get_autoset_content(args[1])
            end
        elseif comm == 'list' then
            get_current_autoset():vprint()
        elseif S{'fonttype','fontsize','pos','bgcolor','txtcolor'}:contains(comm) then
                if comm == 'fonttype' then Burden_tb:font(args[1] or nil)
            elseif comm == 'fontsize' then Burden_tb:size(args[1] or nil)
            elseif comm == 'pos' then Burden_tb:pos(args[1] or nil,args[2] or nil)
            elseif comm == 'bgcolor' then Burden_tb:bgcolor(args[1] or nil,args[2] or nil,args[3] or nil)
            elseif comm == 'txtcolor' then Burden_tb:color(args[1] or nil,args[2] or nil,args[3] or nil)
            end
            settings:update(Burden_tb._settings)
            settings.bg.alpha = nil
            settings.padding = nil
            settings.text.alpha = nil
            settings.text.content = nil
            settings.visible = nil
            settings:save()
        elseif comm == 'show' then Burden_tb:show()
        elseif comm == 'hide' then Burden_tb:hide()
        elseif comm == 'settings' then 
            log('BG: R: '..settings.bg.red..' G: '..settings.bg.green..' B: '..settings.bg.blue)
            log('Font: '..settings.text.font..' Size: '..settings.text.size)
            log('Text: R: '..settings.text.red..' G: '..settings.text.green..' B: '..settings.text.blue)
            log('Position: X: '..settings.pos.x..' Y: '..settings.pos.y)
        else
            local helptext = [[Autosets command list:
     1. help - Brings up this menu.
     2. setlist - list all saved automaton sets.
     3. saveset <setname> - saves <setname> to your settings.
     4. equipset <setname> - equips <setname> to your automaton.
     5. attlist <setname> - gets the attachment list for <setname>
     6. list - gets the list of currently equipped attachments.
The following all correspond to the burden tracker:
     fonttype <name> | fontsize <size> | pos <x> <y>
     bgcolor <r> <g> <b> | txtcolor <r> <g> <b>
     settings - shows current settings
     show/hide - toggles visibility of the tracker so you can make changes.]]
            for _, line in ipairs(helptext:split('\n')) do
                windower.add_to_chat(207, line..chat.colorcontrols.reset)
            end
        end
    end
end)

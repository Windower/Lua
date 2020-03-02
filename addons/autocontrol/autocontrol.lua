--[[
Copyright © 2013-2014, Ricky Gall
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
_addon.version = '1.02'
_addon.author = 'Nitrous (Shiva)'
_addon.commands = {'autocontrol','acon'}

require('tables')
require('strings')
require('logger')
require('sets')
res = require('resources')
config = require('config')
files = require('files')
chat = require('chat')

defaults = {}
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
defaults.AutoActivate = true
defaults.AutoDeusExAutomata = false
defaults.maneuvertimers = true
defaults.burdentracker = true

settings = config.load(defaults)

require('maneuver') -- has to be loaded after settings are parsed.

recast_ids = {}
recast_ids.deactivate = res.job_abilities:with('english', 'Deactivate').recast_id
recast_ids.activate = res.job_abilities:with('english', 'Activate').recast_id
recast_ids.deusex = res.job_abilities:with('english', 'Deus Ex Automata').recast_id

petlessZones = S{50,235,234,224,284,233,70,257,251,14,242,250,226,245,
                 237,249,131,53,252,231,236,246,232,240,247,243,223,248,230,
                 26,71,244,239,238,241,256,257}

function initialize()
    local player = windower.ffxi.get_player()
    if not player then
        windower.send_command('@wait 5;lua i autocontrol initialize')
        return
    end

    mjob_id = player.main_job_id
    atts = res.items:category('Automaton')
    decay = 1
    for key,_ in pairs(heat) do
        heat[key] = 0
        Burden_tb[key] = 0
        Burden_tb['time' .. key] = 0 
    end
    if mjob_id == 18 then
        if player.pet_index then 
            running = 1
            text_update_loop('start')
            if settings.burdentracker then
              Burden_tb:show()
            end
        end
    end
end

windower.register_event('load', 'login', initialize)

windower.register_event('logout', 'unload', text_update_loop:prepare('stop'))

function attach_set(autoset)
    if windower.ffxi.get_player().main_job_id ~= 18 or not settings.autosets[autoset] then
        return
    end
    if settings.autosets[autoset]:map(string.lower):equals(get_current_autoset():map(string.lower)) then
        log('The '..autoset..' set is already equipped.')
        return
    end

    local playermob = windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id)
    if playermob.pet_index and playermob.pet_index ~= 0 then 
        local recast = windower.ffxi.get_ability_recasts()[recast_ids.deactivate]
        if recast == 0 then
            windower.send_command('input /pet "Deactivate" <me>')
            log('Deactivating ' .. windower.ffxi.get_mjob_data().name .. '.')
            windower.send_command('@wait 2;lua i autocontrol attach_set '..autoset)
        elseif recast then
            error('Deactivate on cooldown wait ' .. (recast / 60) .. ' seconds and try again')
        end
    else
        windower.ffxi.reset_attachments()
        log('Starting to equip '..autoset..' to '..windower.ffxi.get_mjob_data().name..'.')
        set_attachments_from_autoset(autoset, 'head')
    end
end

function set_attachments_from_autoset(autoset,slot)
    if slot == 'head' then
        local tempHead = settings.autosets[autoset].head:lower()
        if tempHead then
            for att in atts:it() do
                if att.name:lower() == tempHead and att.id > 5000 then
                    windower.ffxi.set_attachment(att.id)
                    break
                end
            end
        end
        coroutine.schedule(set_attachments_from_autoset:prepare(autoset, 'frame'), 0.5)
    elseif slot == 'frame' then
        local tempFrame = settings.autosets[autoset].frame:lower()
        if tempFrame then
            for att in atts:it() do
                if att.name:lower() == tempFrame and att.id > 5000 then
                    windower.ffxi.set_attachment(att.id)
                    break
                end
            end
        end
        coroutine.schedule(set_attachments_from_autoset:prepare(autoset, '1'), 0.5)
    else
        local tempname = settings.autosets[autoset]['slot' .. tostring(slot):zfill(2)]:lower()
        if tempname then
            for att in atts:it() do
                if att.name:lower() == tempname and att.id > 5000 then
                    windower.ffxi.set_attachment(att.id, tonumber(slot))
                    break
                end
            end
        end
    
        if tonumber(slot) < 12 then
            coroutine.schedule(set_attachments_from_autoset:prepare(autoset, slot + 1), 0.5)
        else
            log(windower.ffxi.get_mjob_data().name..' has been equipped with the '..autoset..' set.')
            if petlessZones:contains(windower.ffxi.get_info().zone) then 
                return
            else
                local recasts = windower.ffxi.get_ability_recasts()
                if settings.AutoActivate and recasts[recast_ids.activate] == 0 then
                    windower.send_command('input /ja "Activate" <me>')
                elseif settings.AutoDeusExAutomata and recasts[recast_ids.deusex] == 0 then
                    log('Activate is down, using Deus Ex Automata instead.')
                    windower.send_command('input /ja "Deus Ex Automata" <me>')
                elseif settings.AutoActivate and settings.AutoDeusExAutomata then
                    log('Activate and Deus Ex Automata timers were not ready.')
                elseif settings.AutoActivate then
                    log('Activate timer was not ready.')
                elseif settings.AutoDeusExAutomata then
                    log('Deus Ex Automata timer was not ready.')
                end
            end
        end
    end
end

function get_current_autoset()
    if windower.ffxi.get_player().main_job_id == 18 then
        local autoTable = T{}
        local mjob_data = windower.ffxi.get_mjob_data()
        local tmpTable = mjob_data.attachments
        for i = 1, 12 do
            local t = ''
            if tmpTable[i] then
                if i < 10 then
                    t = '0'
                end
                autoTable['slot' .. tostring(i):zfill(2)] = atts[tmpTable[i]].name:lower()
            end
        end
        autoTable.head = atts[mjob_data.head].name:lower()
        autoTable.frame = atts[mjob_data.frame].name:lower()
        return autoTable
    end
end

function save_set(setname)
    if setname == 'default' then 
        error('Please choose a name other than default.') 
        return 
    end

    settings.autosets[setname] = get_current_autoset()
    config.save(settings, 'all')
    notice('Set '..setname..' saved.')
end

function get_autoset_list()
    log('Listing sets:')
    for key,_ in pairs(settings.autosets) do
        if key ~= 'default' then
            log('\t' .. key .. ': ' .. (settings.autosets[key]:length()-2) .. ' attachments.')
        end
    end
end

function get_autoset_content(autoset)
    log('Getting '..autoset..'\'s attachment list:')
    settings.autosets[autoset]:vprint()
end

windower.register_event('addon command', function(comm, ...)
    if windower.ffxi.get_player().main_job_id ~= 18 then
        error('You are not on Puppetmaster.')
        return
    end

    local args = L{...}
    comm = comm or 'help'
        
    if comm == 'saveset' then
        if args[1] then
            save_set(args[1])
        end
    elseif comm == 'add' then
        if args[2] then
            local slot = table.remove(args,1)
            local attach = args:sconcat()
            add_attachment(attach,slot)
        end
    elseif comm == 'equipset' then
        if args[1] then
            attach_set(args[1])
        end
    elseif comm == 'setlist' then
        get_autoset_list()
    elseif comm == 'attlist' then
        if args[1] then
            get_autoset_content(args[1])
        end
    elseif comm == 'list' then
        get_current_autoset():vprint()
    elseif comm == "maneuvertimers" or comm == "mt" then
        maneuvertimers = not maneuvertimers
    elseif S{'fonttype','fontsize','pos','bgcolor','txtcolor'}:contains(comm) then
            if comm == 'fonttype' then Burden_tb:font(args[1])
        elseif comm == 'fontsize' then Burden_tb:size(args[1])
        elseif comm == 'pos' then Burden_tb:pos(args[1], args[2])
        elseif comm == 'bgcolor' then Burden_tb:bgcolor(args[1], args[2], args[3])
        elseif comm == 'txtcolor' then Burden_tb:color(args[1], args[2], args[3])
        end
        config.save(settings, 'all')
    elseif comm == 'show' then Burden_tb:show()
    elseif comm == 'hide' then Burden_tb:hide()
    elseif comm == 'settings' then 
        log('BG: R: '..settings.bg.red..' G: '..settings.bg.green..' B: '..settings.bg.blue)
        log('Font: '..settings.text.font..' Size: '..settings.text.size)
        log('Text: R: '..settings.text.red..' G: '..settings.text.green..' B: '..settings.text.blue)
        log('Position: X: '..settings.pos.x..' Y: '..settings.pos.y)
    else
        log('Autosets command list:')
        log('  1. help - Brings up this menu.')
        log('  2. setlist - list all saved automaton sets.')
        log('  3. saveset <setname> - saves <setname> to your settings.')
        log('  4. equipset <setname> - equips <setname> to your automaton.')
        log('  5. attlist <setname> - gets the attachment list for <setname>')
        log('  6. list - gets the list of currently equipped attachments.')
        log('  7. maneuvertimers - Toggles showing maneuver timers on/off.')
        log('The following all correspond to the burden tracker:')
        log('  fonttype <name> | fontsize <size> | pos <x> <y>')
        log('  bgcolor <r> <g> <b> | txtcolor <r> <g> <b>')
        log('  settings - shows current settings')
        log('  show/hide - toggles visibility of the tracker so you can make changes.')
    end
end)

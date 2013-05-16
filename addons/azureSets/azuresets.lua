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
    * Neither the name of azureSets nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL The Addon's Contributors BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon = {}
_addon.name = 'AzureSets'
_addon.version = '1.15'

require 'tablehelper'
require 'stringhelper'
require 'logger'
local config = require 'config'
local files = require 'filehelper'
local defaults = T{}
defaults.assimilation = 0
defaults.spellsets = T{}
defaults.spellsets.default = T{ }
defaults.spellsets.vw1 = T{slot01='Firespit', slot02='Heat Breath', slot03='Thermal Pulse', slot04='Blastbomb',
slot05='Infrasonics', slot06='Frost Breath', slot07='Ice Break', slot08='Cold Wave',
slot09='Sandspin', slot10='Magnetite Cloud', slot11='Cimicine Discharge', slot12='Bad Breath', 
slot13='Acrid Stream', slot14='Maelstrom', slot15='Corrosive Ooze', slot16='Cursed Sphere', 
slot17='Awful Eye'
}
defaults.spellsets.vw2 = T{slot01='Hecatomb Wave', slot02='Mysterious Light', slot03='Leafstorm', slot04='Reaving Wind',
slot05='Temporal Shift', slot06='Mind Blast', slot07='Blitzstrahl', slot08='Charged Whisker',
slot09='Blank Gaze', slot10='Radiant Breath', slot11='Light of Penance', slot12='Actinic Burst',
slot13='Death Ray', slot14='Eyes On Me', slot15='Sandspray'
}
defaults.language = 'english'

function initialize()
    get_current_spellset()
end

function event_load()
    send_command('alias azureset lua c azureSets')
    send_command('alias aset lua c azureSets')
    log('Version '.._addon.version..' loaded! Use //aset help to get a list of commands.')
    speFile = files.new('data/bluespells.xml')
    spells = T{}
    spells = parse_resources(speFile:readlines())
    settings = config.load(defaults,true)
    initialize()
end

function event_login()
    initialize()
end

function event_logout()
    player = nil
end

function event_unload()
    notice('Saving settings and unloading.')
    settings:save('all')
    send_command('unalias azureset')
    send_command('unalias aset')
end

function event_job_change(mjob_id, mjob, mjob_lvl, sjob_id, sjob, sjob_lvl)
    if mjob_id == 16 then
        initialize()
    end
end

function set_spells(spellset)
    if get_player()['main_job_id'] ~= 16 --[[and get_player()['sub_job_id'] ~= 16]] then return nil end
    if settings.spellsets[spellset] == nil then return end
    if settings.spellsets[spellset]:equals(get_current_spellset()) then
        log(spellset..' was already equipped.')
        return
    end
    reset_blue_magic_spells()
    log('Starting to set '..spellset..'.')
    set_spells_from_spellset(spellset,1)
    return
end

function set_spells_from_spellset(spellset,slot)
    local islot
    if tonumber(slot) < 10 then 
        islot = '0'..slot
    else islot = slot end
    local tempname = settings.spellsets[spellset]['slot'..islot]
    if tempname ~= nil then
        for id = 1, #spells do
            if spells[id][settings['language']:lower()] == tempname then
                set_blue_magic_spell(spells[id]['index'], tonumber(slot))
                break
            end
        end
    end
    if tonumber(slot) < 20 then
        send_command('@wait .5;lua i azuresets set_spells_from_spellset '..spellset..' '..slot+1)
    else
        log(spellset..' was equipped.')
        send_command('timers c "Blue Magic Cooldown" 60 up')
    end
    
end

function set_single_spell(spell,slot)
    if get_player()['main_job_id'] ~= 16 --[[and get_player()['sub_job_id'] ~= 16]] then return nil end
    
    local tmpTable = T(get_current_spellset())
    for key,val in pairs(tmpTable) do
        if tmpTable[key] == spell then 
            error('That spell is already set.')
            return
        end
    end
    if tonumber(slot) < 10 then slot = '0'..slot end
    --insert spell add code here
    for id = 1, #spells do
        if spells[id][settings['language']:lower()] == spell then
            --This is where single spell setting code goes.
            --Need to set by spell index rather than name.
            set_blue_magic_spell(spells[id]['index'], tonumber(slot))
            send_command('timers c "Blue Magic Cooldown" 60 up')
            tmpTable['slot'..slot] = spell
        end
    end
    tmpTable = nil
end

function get_current_spellset()
    if get_player()['main_job_id'] ~= 16 --[[and get_player()['sub_job_id'] ~= 16]] then return nil end
    local spellTable = T{}
    local tmpTable = T{}
    if get_player()['main_job_id'] == 16 then
        local tmpTable = T(get_mjob_data()['spells'])
        local i,id
        for i = 1, #tmpTable do
            local t = ''
            if tonumber(tmpTable[i]) ~= 512 then
                for id = 1, #spells do
                    if tonumber(tmpTable[i]) == tonumber(spells[id]['index']) then
                        if i < 10 then t = '0' end
                        spellTable['slot'..t..i] = spells[id][settings['language']:lower()]
                        break
                    end
                end
            end
        end
    end
    return spellTable
end

--[[ Not yet implemented
function remove_one_spell(spell)
    if get_player()['main_job_id'] ~= 16 and get_player()['sub_job_id'] ~= 16 then return nil end
    local st,en,loc
    local tmpTable = T(get_current_spellset())
    for key,val in pairs(tmpTable) do
        if tmpTable[key] == spell then 
            st,en,loc = string.find(key,'slot(%d+)')
        end
    end
    --insert spell add code here
    for id = 1, #spells do
        if spells[id][settings['language']:lower()] == spell then
            --This is where single spell removing code goes.
            --Need to remove by spell index rather than name.
            log('Removing '..spell..' from slot '..tonumber(loc)..'.')
            tmpTable['slot'..loc] = nil
        end
    end
    tmpTable:vprint()
    tmpTable = nil
end
]]

function remove_all_spells(trigger)
    reset_blue_magic_spells()
    notice('All spells removed.')
end

function save_set(setname)
    if setname == 'default' then 
        error('Please choose a name other than default.') 
        return 
    end
    local curSpells = T(get_current_spellset())
    settings.spellsets[setname] = curSpells
    settings:save('all')
    notice('Set '..setname..' saved.')
end

function get_spellset_list()
    log("Listing sets:")
    for key,_ in pairs(settings.spellsets) do
        if key ~= 'default' then
            local it = 0
            for i = 1, #settings.spellsets[key] do
                it = it + 1
            end
            log("\t"..key..' '..settings.spellsets[key]:length()..' spells.')
        end
    end
end

function get_spellset_content(spellset)
    log('Getting '..spellset..'\'s spell list:')
    settings.spellsets[spellset]:vprint()
end

function event_addon_command(...)
    if get_player()['main_job_id'] ~= 16 --[[and get_player()['sub_job_id'] ~= 16]] then
        error('You are not on (main) Blue Mage.')
        return nil 
    end
    local args = T{...}
    if args ~= nil then
        local comm = table.remove(args,1):lower()
        if comm == 'removeall' then
            remove_all_spells('trigger')
        --[[elseif comm == 'remove' then
            local combined = table.concat(args,' ')
            for id = 1, #spells do
                if spells[id][settings['language']:lower()] == combined then
                    remove_one_spell(combined)
                    break
                end
                if id == #spells then
                    error('The spell '..combined..' does not exist.')
                end
            end]]
        elseif comm == 'add' then
            if args[2] ~= nil then
                local slot = table.remove(args,1)
                local spell = args:sconcat()
                set_single_spell(spell,slot)
            end
        elseif comm == 'save' then
            if args[1] ~= nil then
                save_set(args[1])
            end
            
        elseif comm == 'spellset' then
            if args[1] ~= nil then
                set_spells(args[1])
            end
        elseif comm == 'currentlist' then
            get_current_spellset():vprint()
        elseif comm == 'setlist' then
            get_spellset_list()
        elseif comm == 'spelllist' then
            if args[1] ~= nil then
                get_spellset_content(args[1])
            end
        elseif comm == 'help' then
            log('Version '.._addon.version..' loaded! You have access to the following commands with the //aset alias:')
            log(' 1. removeall - Unsets all spells.')
            log(' 2. spellset <setname> -- Set (setname)\'s spells.')
            log(' 3. add <slot> <spell> -- Set (spell) to slot (slot (number)).')
            log(' 4. save <setname> -- Saves current spellset as (setname)')
            log(' 5. currentlist -- Lists currently set spells.')
            log(' 6. setlist -- Lists all spellsets.')
            log(' 7. spelllist <setname> -- List spells in (setname)')
            log(' 8. help --Shows this menu.')
        end
    end
end

function parse_resources(lines_file)
    local completed_table = T{}
    local counter = 0
    for i in ipairs(lines_file) do
        local str = tostring(lines_file[i])
        local g,h,typ,key = string.find(str,'<(%w+) id="(%d+)" ')
        if typ == 's' then
            g,h,key = string.find(str,'index="(%d+)" ')
        end
        if key ~=nil then
            completed_table[tonumber(key)] = T{}
            local q = 1
            while q <= str:len() do
                local a,b,ind,val = string.find(str,'(%w+)="(.-)"',q)
                if ind~=nil then
                    completed_table[tonumber(key)][ind] = T
                    completed_table[tonumber(key)][ind] = val:gsub('&quot;','\42'):gsub('&apos;','\39')
                    q = b+1
                else
                    q = str:len()+1
                end
            end
            --[[local k,v,english = string.find(str,'>([^<]+)</')
            if english~=nil then
                completed_table[tonumber(key)][ind] = T{}
                completed_table[tonumber(key)]['english']=english
            end]]
        end
    end
    return completed_table
end.

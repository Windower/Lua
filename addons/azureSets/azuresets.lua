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

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 'AS IS' AND
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

_addon.name = 'AzureSets'
_addon.version = '1.25'
_addon.author = 'Nitrous (Shiva)'
_addon.commands = {'aset', 'azuresets', 'asets'}

require('tables')
require('strings')
require('logger')
local config = require('config')
local res = require('resources')
local chat = require('chat')
local spells = res.spells:type('BlueMagic')

local defaults = {}
defaults.setmode = 'PreserveTraits'
defaults.setspeed = 0.65
defaults.spellsets = {}
defaults.spellsets.default = T{}
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

local settings = config.load(defaults)
local BLU_JOB_ID = 16

local currentSpellSet = nil
local bluJobLevel = nil
local bluPointsMax = nil
local bluSlots = nil
local get_blu_job_data = nil
local language = windower.ffxi.get_info().language:lower()

local spellsLookup = {}
for spell in spells:it() do
    spellsLookup[spell.english] = spell
    spellsLookup[spell.english:lower()] = spell
    spellsLookup[spell.japanese] = spell
end

function initialize()
    local player = windower.ffxi.get_player()
    local is_blu = player and (player.main_job_id == BLU_JOB_ID or player.sub_job_id == BLU_JOB_ID)
    local logged_in = windower.ffxi.get_info()

    if is_blu and logged_in then
        update_blu_info()
        update_current_spellset()
    end
end

windower.register_event('load', 'login', 'job change', initialize)

function update_blu_info(player)
    player = player or windower.ffxi.get_player()
    if player.main_job_id == BLU_JOB_ID then
        bluJobLevel = player.main_job_level

        if bluJobLevel > 70 then
            bluSlots = 20
        else
            bluSlots = (math.floor((bluJobLevel + 9) / 10) * 2) + 4
        end
        
        bluPointsMax = (math.floor((bluJobLevel + 9) / 10) * 5) + 5
        if bluJobLevel >= 75 then
            bluPointsMax = bluPointsMax + player.merits.assimilation
            if bluJobLevel == 99 then
                bluPointsMax = bluPointsMax + player.job_points.blu.blue_magic_point_bonus
            end
        end

        get_blu_job_data = windower.ffxi.get_mjob_data
    elseif player.sub_job_id == BLU_JOB_ID then
        bluJobLevel = player.sub_job_level
        bluSlots = (math.floor((bluJobLevel + 9) / 10) * 2) + 4
        bluPointsMax = (math.floor((bluJobLevel + 9) / 10) * 5) + 5
        get_blu_job_data = windower.ffxi.get_sjob_data
    else
        bluJobLevel = nil
        bluSlots = nil
        bluPointsMax = nil
        get_blu_job_data = nil
    end
end

function set_spells(spellset, setmode)
    if not bluJobLevel then
        error('You are not a Blue Mage.')
        return
    end
    if settings.spellsets[spellset] == nil then
        error('Set not defined: '..spellset)
        return
    end
    if is_spellset_equipped(settings.spellsets[spellset]) then
        log(spellset..' was already equipped.')
        return
    end

    log('Starting to set '..spellset..'.')
    if setmode:lower() == 'clearfirst' then
        remove_all_spells()
        set_spells_from_spellset:schedule(settings.setspeed, spellset, 'add')
    elseif setmode:lower() == 'preservetraits' then
        set_spells_from_spellset(spellset, 'remove')
    else
        error('Unexpected setmode: '..setmode)
    end
end

function is_spellset_equipped(spellset)
    return S(spellset):map(string.lower) == S(update_current_spellset())
end

function set_spells_from_spellset(spellset, setPhase)
    local setToSet = settings.spellsets[spellset]
    update_current_spellset()

    if setPhase == 'remove' then
        -- Remove Phase
        for k, v in pairs(currentSpellSet) do
            if not setToSet:contains(v:lower()) then
                setSlot = k
                local slotToRemove = tonumber(k:sub(5, k:len()))

                windower.ffxi.remove_blue_magic_spell(slotToRemove)
                set_spells_from_spellset:schedule(settings.setspeed, spellset, 'remove')
                return
            end
        end
    end
    -- Did not find spell to remove. Start set phase
    -- Find empty slot:
    local slotToSetTo
    for i = 1, 20 do
        local slotName = 'slot%02u':format(i)
        if currentSpellSet[slotName] == nil then
            slotToSetTo = i
            break
        end
    end

    if slotToSetTo ~= nil then
        -- We found an empty slot. Find a spell to set.
        for k, v in pairs(setToSet) do
            if not currentSpellSet:contains(v:lower()) then
                local spellID = find_spell_id_by_name(v)
                if spellID ~= nil then
                    local verified = verify_and_set_spell(spellID, tonumber(slotToSetTo))
                    if verified then
                        set_spells_from_spellset:schedule(settings.setspeed, spellset, 'add')
                    end
                    return
                end
            end
        end
    end

    -- Unable to find any spells to set. Must be complete.
    log(spellset..' has been equipped.')
    windower.send_command('@timers c "Blue Magic Cooldown" 60 up')
end

function find_spell_id_by_name(spellname)
    local spell = spellsLookup[spellname:lower()]
    if spell and spell.id then
        return spell.id
    end
end

function set_single_spell(setspell, slot)
    update_current_spellset()
    for key, val in pairs(currentSpellSet) do
        if currentSpellSet[key]:lower() == setspell then
            error('That spell is already set.')
            return
        end
    end
    if tonumber(slot) < 10 then slot = '0'..slot end
    --insert spell add code here
    local spellId = find_spell_id_by_name(setspell)
    local verified = verify_and_set_spell(spellId, tonumber(slot))
    if verified then
        windower.send_command('@timers c "Blue Magic Cooldown" 60 up')
        currentSpellSet['slot'..slot] = setspell
    end
end

function update_current_spellset(player)
    currentSpellSet = T(get_blu_job_data().spells)
    -- Returns all values but 512
    :filter(function(id) return id ~= 512 end)
    -- Transforms them from IDs to lowercase names
    :map(function(id) return spells[id].name:lower() end)
    -- Transform the keys from numeric x or xx to string 'slot0x' or 'slotxx'
    :key_map(function(slot) return 'slot%02u':format(slot) end)
    return currentSpellSet
end

function remove_all_spells(trigger)
    windower.ffxi.reset_blue_magic_spells()
    notice('All spells removed.')
end

function save_set(setname)
    if setname == 'default' then
        error('Please choose a name other than default.')
        return
    end
    update_current_spellset()
    settings.spellsets[setname] = currentSpellSet
    settings:save('all')
    notice('Set '..setname..' saved.')
end

function delete_set(setname)
    if settings.spellsets[setname] == nil then
        error('Please choose an existing spellset.')
        return
    end    
    settings.spellsets[setname] = nil
    settings:save('all')
    notice('Deleted '..setname..'.')
end

function get_spellset_list()
    log('Listing sets:')
    for key,_ in pairs(settings.spellsets) do
        if key ~= 'default' then
            local it = 0
            for i = 1, #settings.spellsets[key] do
                it = it + 1
            end
            log('\t'..key..' '..settings.spellsets[key]:length()..' spells.')
        end
    end
end

function get_spellset_content(spellset)
    log('Getting '..spellset..'\'s spell list:')
    settings.spellsets[spellset]:print()
end

function verify_and_set_spell(id, slot)
    local spell = spells[id]
    if not spell then
        error('Spell named not found')
        return false
    end
    if bluJobLevel and spell.levels and spell.levels[BLU_JOB_ID] and spell.levels[BLU_JOB_ID] > bluJobLevel then
        error('Blue Mage Level too low to set spell')
        return false
    end
    if not have_enough_points_to_add_spell(id) then
        error('Cannot set spell, ran out of blue magic points')
        return false
    end
    if slot > bluSlots then
        error('Slot ' .. tostring(slot) .. ' unavailable')
        return false
    end

    windower.ffxi.set_blue_magic_spell(id, slot)
    return true
end

function have_enough_points_to_add_spell(spellId)
    local spell = spells[spellId]
    if not spell or not spell.blu_points then
        return nil
    end
    return spell.blu_points + current_total_points_spent() <= bluPointsMax
end

function current_total_points_spent()
    local total = 0
    for _, spellId in pairs(get_blu_job_data().spells) do
        local spell = spells[spellId]
        if spell and spell.blu_points then
            total = total + spell.blu_points
        end
    end
    return total
end

windower.register_event('addon command', function(...)
    initialize()
    if not bluJobLevel then
        error('You are not a Blue Mage.')
        return nil
    end
    local args = T{...}
    if args ~= nil then
        local comm = table.remove(args, 1):lower()
        if comm == 'removeall' then
            remove_all_spells('trigger')
        elseif comm == 'add' then
            if args[2] ~= nil then
                local slot = table.remove(args, 1)
                local spell = args:sconcat()
                set_single_spell(spell:lower(), slot)
            end
        elseif comm == 'save' then
            if args[1] ~= nil then
                save_set(args[1])
            end
        elseif comm == 'delete' then
            if args[1] ~= nil then
                delete_set(args[1])
            end
        elseif comm == 'spellset' or comm == 'set' then
            if args[1] ~= nil then
                set_spells(args[1], args[2] or settings.setmode)
            end
        elseif comm == 'currentlist' then
            update_current_spellset():print()
        elseif comm == 'setlist' then
            get_spellset_list()
        elseif comm == 'spelllist' then
            if args[1] ~= nil then
                get_spellset_content(args[1])
            end
        elseif comm == 'help' then
            local helptext = [[AzureSets - Command List:')
1. removeall - Unsets all spells.
2. spellset <setname> [ClearFirst|PreserveTraits] -- Set (setname)'s spells,
    optional parameter: ClearFirst or PreserveTraits: overrides
    setting to clear spells first or remove individually,
    preserving traits where possible. Default: use settings or
    preservetraits if settings not configured.
3. set <setname> (clearfirst|preservetraits) -- Same as spellset
4. add <slot> <spell> -- Set (spell) to slot (slot (number)).
5. save <setname> -- Saves current spellset as (setname).
6. delete <setname> -- Delete (setname) spellset.
7. currentlist -- Lists currently set spells.
8. setlist -- Lists all spellsets.
9. spelllist <setname> -- List spells in (setname)
10. help --Shows this menu.]]
            for _, line in ipairs(helptext:split('\n')) do
                windower.add_to_chat(207, line..chat.controls.reset)
            end
        end
    end
end)

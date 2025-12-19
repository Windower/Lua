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


_addon.name = 'AzureSets'
_addon.version = '1.24.3'
_addon.author = 'Nitrous (Shiva), Gojito (Leviathan - Subjob Support)'
_addon.commands = {'aset','azuresets','asets'}

require('tables')
require('strings')
require('logger')
config = require('config')
files = require('files')
res = require('resources')
chat = require('chat')

defaults = {}
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

-- Subjob-specific spell sets (limited to 16 slots)
defaults.spellsets.sub_default = T{}

settings = config.load(defaults)

-- Constants
local BLU_JOB_ID = 16
local MAIN_JOB_SLOTS = 20
local SUB_JOB_SLOTS = 16  -- Subjob BLU gets 16 spell slots

-------------------------------------------------------------------------------
-- Helper Functions for Main/Sub Job Detection
-------------------------------------------------------------------------------

-- Returns true if the player has BLU as either main or sub job
function has_blu_access()
    local player = windower.ffxi.get_player()
    if not player then return false end
    return player.main_job_id == BLU_JOB_ID or player.sub_job_id == BLU_JOB_ID
end

-- Returns true if BLU is the main job
function is_main_blu()
    local player = windower.ffxi.get_player()
    if not player then return false end
    return player.main_job_id == BLU_JOB_ID
end

-- Returns true if BLU is the sub job (and not main)
function is_sub_blu()
    local player = windower.ffxi.get_player()
    if not player then return false end
    return player.main_job_id ~= BLU_JOB_ID and player.sub_job_id == BLU_JOB_ID
end

-- Returns the maximum number of spell slots available
function get_max_slots()
    if is_main_blu() then
        return MAIN_JOB_SLOTS
    elseif is_sub_blu() then
        return SUB_JOB_SLOTS
    end
    return 0
end

-- Returns descriptive string for current BLU job status
function get_blu_status()
    if is_main_blu() then
        return "main"
    elseif is_sub_blu() then
        return "sub"
    end
    return "none"
end

-------------------------------------------------------------------------------
-- Core Functions
-------------------------------------------------------------------------------

function initialize()
    spells = res.spells:type('BlueMagic')
    get_current_spellset()
end

windower.register_event('load', initialize:cond(function() return windower.ffxi.get_info().logged_in end))

windower.register_event('login', initialize)

-- Initialize when changing to BLU as main OR when subjob changes to BLU
windower.register_event('job change', function(main_job, main_job_level, sub_job, sub_job_level)
    if main_job == BLU_JOB_ID or sub_job == BLU_JOB_ID then
        initialize()
    end
end)

function set_spells(spellset, setmode)
    if not has_blu_access() then
        error('You do not have Blue Mage as main or sub job.')
        return
    end
    if settings.spellsets[spellset] == nil then
        error('Set not defined: '..spellset)
        return
    end
    
    -- Validate spell count for subjob
    local max_slots = get_max_slots()
    local spellset_size = settings.spellsets[spellset]:length()
    
    if is_sub_blu() and spellset_size > max_slots then
        notice('Warning: Spellset "'..spellset..'" has '..spellset_size..' spells, but sub BLU only supports '..max_slots..' slots.')
        notice('Only the first '..max_slots..' spells will be set.')
    end
    
    if is_spellset_equipped(settings.spellsets[spellset]) then
        log(spellset..' was already equipped.')
        return
    end

    local job_type = get_blu_status()
    log('Starting to set '..spellset..' ('..job_type..' BLU).')
    
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
    local current = get_current_spellset()
    if not current then return false end
    return S(spellset):map(string.lower) == S(current)
end

function set_spells_from_spellset(spellset, setPhase)
    local setToSet = settings.spellsets[spellset]
    local currentSet = get_current_spellset()
    local max_slots = get_max_slots()

    if setPhase == 'remove' then
        -- Remove Phase
        for k,v in pairs(currentSet) do
            if not setToSet:contains(v:lower()) then
                -- Safely extract slot number from key
                local slotToRemove = nil
                if type(k) == 'string' and k:sub(1, 4) == 'slot' then
                    slotToRemove = tonumber(k:sub(5))
                end
                
                if slotToRemove then
                    windower.ffxi.remove_blue_magic_spell(slotToRemove)
                    set_spells_from_spellset:schedule(settings.setspeed, spellset, 'remove')
                    return
                end
            end
        end
    end
    
    -- Did not find spell to remove. Start set phase
    -- Find empty slot (respecting max_slots for subjob)
    local slotToSetTo
    for i = 1, max_slots do
        local slotName = 'slot%02u':format(i)
        if currentSet[slotName] == nil then
            slotToSetTo = i
            break
        end
    end

    if slotToSetTo ~= nil then
        -- We found an empty slot. Find a spell to set.
        for k,v in pairs(setToSet) do
            -- Skip spells beyond max slot count for subjob
            -- Safely extract slot number from key (e.g., "slot01" -> 1)
            local slotNum = nil
            if type(k) == 'string' and k:sub(1, 4) == 'slot' then
                slotNum = tonumber(k:sub(5))
            end
            
            -- Only process if we have a valid slot number within range
            if slotNum and slotNum <= max_slots and not currentSet:contains(v:lower()) then
                if v ~= nil then
                    local spellID = find_spell_id_by_name(v)
                    if spellID ~= nil then
                        -- Verify spell is available at current level for subjob
                        if is_sub_blu() and not can_set_spell_as_sub(spellID) then
                            notice('Skipping '..v..' - not available at sub job level.')
                        else
                            windower.ffxi.set_blue_magic_spell(spellID, tonumber(slotToSetTo))
                            set_spells_from_spellset:schedule(settings.setspeed, spellset, 'add')
                            return
                        end
                    end
                end
            end
        end
    end

    -- Unable to find any spells to set. Must be complete.
    local job_type = get_blu_status()
    log(spellset..' has been equipped ('..job_type..' BLU).')
    windower.send_command('@timers c "Blue Magic Cooldown" 60 up')
end

-- Check if a spell can be set as subjob BLU (based on spell level vs sub job level)
-- The spell.levels table is keyed by job ID and contains the required level for that job
function can_set_spell_as_sub(spellID)
    local spell = spells[spellID]
    if not spell then return false end
    
    local player = windower.ffxi.get_player()
    if not player then return false end
    
    -- Subjob level is capped at half main job level (max 99/2 = 49)
    local sub_level = player.sub_job_level or 0
    
    -- spell.levels is a table: { [job_id] = required_level, ... }
    -- If levels table doesn't exist or doesn't have BLU entry, assume level 1
    if not spell.levels then return true end
    
    local spell_level = spell.levels[BLU_JOB_ID]
    if spell_level == nil then 
        -- BLU not in levels table - this shouldn't happen for BLU spells
        -- but if it does, allow it
        return true 
    end
    
    return sub_level >= spell_level
end

function find_spell_id_by_name(spellname)
    for spell in spells:it() do
        if spell['english']:lower() == spellname:lower() then
            return spell['id']
        end
    end
    return nil
end

function set_single_spell(setspell, slot)
    if not has_blu_access() then
        error('You do not have Blue Mage as main or sub job.')
        return nil
    end
    
    local max_slots = get_max_slots()
    if tonumber(slot) > max_slots then
        error('Slot '..slot..' exceeds maximum available slots ('..max_slots..') for '..get_blu_status()..' BLU.')
        return
    end

    local tmpTable = get_current_spellset()
    if not tmpTable then
        error('Unable to get current spell set.')
        return
    end
    for key,val in pairs(tmpTable) do
        if val and val:lower() == setspell then
            error('That spell is already set.')
            return
        end
    end
    if tonumber(slot) < 10 then slot = '0'..slot end
    
    for spell in spells:it() do
        if spell['english']:lower() == setspell then
            -- Check if spell is available at current level for subjob
            if is_sub_blu() and not can_set_spell_as_sub(spell['id']) then
                error('Spell "'..spell['english']..'" requires a higher BLU level than your sub job.')
                return
            end
            
            windower.ffxi.set_blue_magic_spell(spell['id'], tonumber(slot))
            windower.send_command('@timers c "Blue Magic Cooldown" 60 up')
            tmpTable['slot'..slot] = setspell
        end
    end
    tmpTable = nil
end

function get_current_spellset()
    if not has_blu_access() then return T{} end
    
    -- Use appropriate data source based on main vs sub job
    local job_data
    if is_main_blu() then
        job_data = windower.ffxi.get_mjob_data()
    else
        job_data = windower.ffxi.get_sjob_data()
    end
    
    -- Safety check: ensure we got valid job data
    if not job_data or not job_data.spells then return T{} end
    
    local spell_data = job_data.spells
    local max_slots = get_max_slots()
    local result = T{}
    
    -- Manually iterate to avoid chained filter/map nil issues
    for slot, id in pairs(spell_data) do
        -- Validate slot is a number and within range
        if type(slot) == 'number' and slot >= 1 and slot <= max_slots then
            -- Skip empty slots (512 is the empty indicator)
            if id ~= 512 then
                -- Safely get spell name
                local spell = spells[id]
                if spell and spell.english then
                    local slotName = 'slot%02u':format(slot)
                    result[slotName] = spell.english:lower()
                end
            end
        end
    end
    
    return result
end

function remove_all_spells(trigger)
    if not has_blu_access() then
        error('You do not have Blue Mage as main or sub job.')
        return
    end
    windower.ffxi.reset_blue_magic_spells()
    notice('All spells removed ('..get_blu_status()..' BLU).')
end

function save_set(setname)
    if setname == 'default' then
        error('Please choose a name other than default.')
        return
    end
    local curSpells = get_current_spellset()
    if not curSpells then
        error('Unable to get current spell set.')
        return
    end
    settings.spellsets[setname] = curSpells
    settings:save('all')
    
    local job_type = get_blu_status()
    local spell_count = curSpells:length()
    notice('Set '..setname..' saved ('..spell_count..' spells, '..job_type..' BLU).')
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
    log("Listing sets:")
    local max_slots = get_max_slots()
    local job_type = get_blu_status()
    
    for key,_ in pairs(settings.spellsets) do
        if key ~= 'default' then
            local spell_count = settings.spellsets[key]:length()
            local warning = ''
            if is_sub_blu() and spell_count > max_slots then
                warning = ' [!exceeds sub limit]'
            end
            log("\t"..key..' '..spell_count..' spells.'..warning)
        end
    end
    
    if has_blu_access() then
        log('Current mode: '..job_type..' BLU ('..max_slots..' slots available)')
    end
end

function get_spellset_content(spellset)
    if not settings.spellsets[spellset] then
        error('Spellset "'..spellset..'" not found.')
        return
    end
    log('Getting '..spellset..'\'s spell list:')
    settings.spellsets[spellset]:print()
end

-- Display current status
function show_status()
    if not has_blu_access() then
        log('You do not have Blue Mage as main or sub job.')
        return
    end
    
    local job_type = get_blu_status()
    local max_slots = get_max_slots()
    local current = get_current_spellset()
    local used_slots = current and current:length() or 0
    
    log('AzureSets Status:')
    log('  Job Mode: '..job_type..' BLU')
    log('  Available Slots: '..max_slots)
    log('  Used Slots: '..used_slots)
end

windower.register_event('addon command', function(...)
    if not has_blu_access() then
        error('You do not have Blue Mage as main or sub job.')
        return nil
    end
    local args = T{...}
    if args ~= nil then
        local comm = table.remove(args,1):lower()
        if comm == 'removeall' then
            remove_all_spells('trigger')
        elseif comm == 'add' then
            if args[2] ~= nil then
                local slot = table.remove(args,1)
                local spell = args:sconcat()
                set_single_spell(spell:lower(),slot)
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
            local current = get_current_spellset()
            if current and current:length() > 0 then
                current:print()
            else
                log('No spells currently set.')
            end
        elseif comm == 'setlist' then
            get_spellset_list()
        elseif comm == 'spelllist' then
            if args[1] ~= nil then
                get_spellset_content(args[1])
            end
        elseif comm == 'status' then
            show_status()
        elseif comm == 'help' then
            local helptext = [[AzureSets v1.24 - Command List (Now with Subjob Support!):
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
            8. setlist -- Lists all spellsets (marks sets exceeding sub BLU limit).
            9. spelllist <setname> -- List spells in (setname)
            10. status -- Shows current BLU mode (main/sub) and slot availability.
            11. help -- Shows this menu.
            
            Note: When using BLU as subjob, only 16 spell slots are available
            and spells requiring higher BLU levels will be skipped.]]
            for _, line in ipairs(helptext:split('\n')) do
                windower.add_to_chat(207, line..chat.controls.reset)
            end
        end
    end
end)

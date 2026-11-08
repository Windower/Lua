--[[
Copyright (c) 2013, 2026, Ricky Gall
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
_addon.version = '1.26'
_addon.author = 'Nitrous (Shiva), Gol-exe'
_addon.commands = {'aset','azuresets','asets'}

require('tables')
require('strings')
require('logger')
local config = require('config')
local res = require('resources')
local chat = require('chat')
local spells = res.spells:type('BlueMagic')

local defaults = {}
defaults.setmode = 'PreserveTraits'
defaults.setspeed = 0
defaults.setjitter = 0.15
defaults.replace = true
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
local EMPTY_SLOT = 512
local POLL_INTERVAL = 0.1
local CONFIRM_TIMEOUT = 3
local MAX_TRIES = 2

local currentSpellSet
local bluJobLevel
local bluPointsMax
local bluSlots
local get_blu_job_data
local applying
local lastChangeSent = -math.huge

math.randomseed(os.time())

local spellsLookup = {}
for spell in spells:it() do
    spellsLookup[spell.english] = spell
    spellsLookup[spell.english:lower()] = spell
    spellsLookup[spell.japanese] = spell
end

-- The game abbreviates some spell names; accept the full names too.
local fullNames = {
    ['quadratic continuum'] = 'quad. continuum',
    ['winds of promyvion'] = 'winds of promy.',
    ["everyone's grudge"] = 'evryone. grudge',
    ['everyones grudge'] = 'evryone. grudge',
    ['orcish counterstance'] = 'o. counterstance',
    ['natural meditation'] = 'nat. meditation',
    ['tempestuous upheaval'] = 'tem. upheaval',
    ['atramentous libations'] = 'atra. libations',
}
for full, short in pairs(fullNames) do
    spellsLookup[full] = spellsLookup[short]
end

function initialize()
    local player = windower.ffxi.get_player()
    if not player then return end

    update_blu_info(player)

    if bluJobLevel then
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

function find_spellset(spellset)
    if settings.spellsets[spellset] then return spellset end
    if settings.spellsets[spellset:lower()] then return spellset:lower() end
end

function set_spells(spellset, setmode)
    if not bluJobLevel then
        error('You are not a Blue Mage.')
        return
    end
    local name = find_spellset(spellset)
    if not name then
        error('Set not defined: '..spellset)
        return
    end
    setmode = setmode:lower()
    if setmode ~= 'clearfirst' and setmode ~= 'preservetraits' then
        error('Unexpected setmode: '..setmode)
        return
    end

    local current = current_spell_ids()
    if not current then
        error('Could not read your set spells, try again in a moment.')
        return
    end
    local run = new_run(name)
    run.clearFirst = setmode == 'clearfirst'

    -- Wait for any change the stopped set already sent, so both don't change the same slot.
    local previous = applying
    applying = nil
    if is_busy(previous) then
        log('Stopped setting '..previous.name..'.')
        run.changes = previous.changes -- its changes still need the cooldown timer
        if previous.pending then
            local p = previous.pending
            run.pending = {kind = 'previous', clears = p.clears, slot = p.slot, from = p.from, sent = p.sent}
        end
    end

    if not run.pending and is_spellset_equipped(run, current) then
        log(name..' was already equipped.')
        report_skipped(run)
        end_run(run)
        return
    end

    warn_if_spellset_too_big(run)
    applying = run

    local toAdd, toRemove = count_changes(run, current)
    log('Setting '..name..': '..toAdd..' to add, '..toRemove..' to remove.')
    if run.pending then
        poll_change:schedule(POLL_INTERVAL, run)
    elseif setspeed_wait() > 0 then
        set_spells_from_spellset:schedule(setspeed_wait(), run)
    else
        set_spells_from_spellset(run)
    end
end

function setspeed_wait()
    return math.max(0, settings.setspeed - (os.clock() - lastChangeSent))
end

-- A run that hasn't stepped in a while (e.g. it errored out) no longer counts as busy.
function is_busy(run)
    run = run or applying
    return run ~= nil and os.clock() - run.lastStep < CONFIRM_TIMEOUT + settings.setspeed + settings.setjitter + 5
end

function stop_spellset()
    if not applying then
        log('Not setting a spellset.')
        return
    end
    log('Stopped setting '..applying.name..'.')
    end_run(applying)
end

function end_run(run)
    applying = nil
    if run.changes > 0 or run.pending then
        windower.send_command('@timers c "Blue Magic Cooldown" 60 up')
    end
end

function spellset_names(spellset)
    local set = settings.spellsets[spellset]
    local slots = {}
    for slot in pairs(set) do
        slots[#slots + 1] = slot
    end
    local function number(slot) return tonumber(tostring(slot):match('%d+')) or math.huge end
    table.sort(slots, function(a, b)
        if number(a) ~= number(b) then return number(a) < number(b) end
        return tostring(a) < tostring(b)
    end)

    local names = {}
    for _, slot in ipairs(slots) do
        names[#names + 1] = tostring(set[slot]):lower()
    end
    return names
end

function new_run(spellset)
    local run = {name = spellset, targets = {}, wanted = {}, skipped = {}, skipOrder = {}, attempts = {},
        replaceFailed = {}, replaceFailures = 0, changes = 0, started = os.clock(), lastStep = os.clock()}
    local learned = windower.ffxi.get_spells()
    for _, name in ipairs(spellset_names(spellset)) do
        local spell = spellsLookup[name]
        local problem = spell_problem(spell, learned)
        if problem then
            skip_spell(run, spell and spell.id or name, problem)
        elseif not run.wanted[spell.id] then
            run.targets[#run.targets + 1] = spell.id
            run.wanted[spell.id] = true
        end
    end
    return run
end

function is_spellset_equipped(run, current)
    local count = 0
    for _, id in pairs(current) do
        if not run.wanted[id] then return false end
        count = count + 1
    end
    return count == #run.targets
end

function count_changes(run, current)
    local set = {}
    for _, id in pairs(current) do
        set[id] = true
    end
    local toAdd, toRemove = 0, 0
    for _, id in ipairs(run.targets) do
        if not set[id] then toAdd = toAdd + 1 end
    end
    for _, id in pairs(current) do
        if not run.wanted[id] then toRemove = toRemove + 1 end
    end
    return toAdd, toRemove
end

function warn_if_spellset_too_big(run)
    local points = 0
    for _, id in ipairs(run.targets) do
        points = points + spell_points(id)
    end
    if #run.targets > bluSlots then
        warning(run.name..' has '..#run.targets..' spells, but you only have '..bluSlots..' slots.')
    end
    if points > bluPointsMax then
        warning(run.name..' needs '..points..' points, but you only have '..bluPointsMax..'.')
    end
end

function set_spells_from_spellset(run)
    if applying ~= run then return end
    if not bluJobLevel then
        applying = nil
        error('No longer a Blue Mage, stopped setting '..run.name..'.')
        return
    end
    run.lastStep = os.clock()

    local current = current_spell_ids()
    if not current then
        set_spells_from_spellset:schedule(POLL_INTERVAL, run)
        return
    end

    if run.clearFirst and not run.cleared then
        run.cleared = true
        if next(current) ~= nil then
            remove_all_spells()
            wait_for_change(run, 'clear')
            return
        end
    end

    local isSet = {}
    for _, id in pairs(current) do
        isSet[id] = true
    end
    local points = current_total_points_spent()

    local missing = {}
    for _, id in ipairs(run.targets) do
        if not isSet[id] and not run.skipped[id] then
            missing[#missing + 1] = id
        end
    end
    local unwanted = {}
    for slot = 1, 20 do
        if current[slot] and not run.wanted[current[slot]] then
            unwanted[#unwanted + 1] = slot
        end
    end
    -- Find empty slot:
    local emptySlot
    for slot = 1, bluSlots do
        if current[slot] == nil then
            emptySlot = slot
            break
        end
    end

    if emptySlot and #unwanted > 0 then
        -- We found an empty slot. Find a spell to set.
        for _, id in ipairs(missing) do
            if (run.attempts[id] or 0) < MAX_TRIES and points + spell_points(id) <= bluPointsMax then
                set_spell(run, id, emptySlot, current, 'add')
                return
            end
        end
    end

    if settings.replace and not run.noReplace then
        for _, id in ipairs(missing) do
            if (run.attempts[id] or 0) < MAX_TRIES and not run.replaceFailed[id] then
                for _, slot in ipairs(unwanted) do
                    if points - spell_points(current[slot]) + spell_points(id) <= bluPointsMax then
                        set_spell(run, id, slot, current, 'replace')
                        return
                    end
                end
            end
        end
    end

    if #unwanted > 0 then
        -- Remove Phase
        local slot = unwanted[1]
        local key = 'remove'..slot
        if (run.attempts[key] or 0) >= MAX_TRIES then
            end_run(run)
            error('Could not remove '..spells[current[slot]].name..', stopped setting '..run.name..'.')
            return
        end
        run.attempts[key] = (run.attempts[key] or 0) + 1
        windower.ffxi.remove_blue_magic_spell(slot)
        wait_for_change(run, 'remove', slot, current)
        return
    end

    -- Did not find spell to remove. Start set phase
    -- Nothing is removed from here on, so a spell that doesn't fit now never will.
    for _, id in ipairs(missing) do
        local problem
        if (run.attempts[id] or 0) >= MAX_TRIES then
            problem = 'not accepted by the game'
        elseif points + spell_points(id) > bluPointsMax then
            problem = 'not enough points'
        elseif not emptySlot then
            problem = 'out of slots'
        end

        if problem then
            skip_spell(run, id, problem)
        else
            set_spell(run, id, emptySlot, current, 'add')
            return
        end
    end

    -- Unable to find any spells to set. Must be complete.
    finish_spellset(run)
end

function set_spell(run, id, slot, current, kind)
    run.attempts[id] = (run.attempts[id] or 0) + 1
    windower.ffxi.set_blue_magic_spell(id, slot)
    wait_for_change(run, kind, slot, current, id)
end

function wait_for_change(run, kind, slot, before, id)
    lastChangeSent = os.clock()
    run.pending = {kind = kind, clears = kind == 'clear', slot = slot, id = id, from = before and before[slot],
        sent = lastChangeSent}
    poll_change:schedule(POLL_INTERVAL, run)
end

function poll_change(run)
    if applying ~= run then return end
    run.lastStep = os.clock()

    local pending = run.pending
    local current = current_spell_ids()
    local changed
    if not current then
        changed = false
    elseif pending.clears then
        changed = next(current) == nil
    else
        changed = current[pending.slot] ~= pending.from
    end

    if not changed and os.clock() - pending.sent < CONFIRM_TIMEOUT then
        poll_change:schedule(POLL_INTERVAL, run)
        return
    end

    run.pending = nil
    if changed then
        run.changes = run.changes + 1
    else
        if pending.kind == 'clear' then
            end_run(run)
            error('Spells were not cleared, stopped setting '..run.name..'.')
            return
        elseif pending.kind == 'replace' then
            -- Not the spell's fault yet: set it normally later. After two spells fail, stop replacing.
            run.attempts[pending.id] = run.attempts[pending.id] - 1
            run.replaceFailed[pending.id] = true
            run.replaceFailures = run.replaceFailures + 1
        end
        if run.replaceFailures == 2 and not run.noReplace then
            run.noReplace = true
            warning('Replacing a spell in place did not work; removing and setting separately instead. '
                ..'Set <replace> to false in settings to always do that.')
        end
    end
    set_spells_from_spellset:schedule(setspeed_wait() + math.random() * settings.setjitter, run)
end

function skip_spell(run, key, reason)
    run.skipped[key] = reason
    run.skipOrder[#run.skipOrder + 1] = key
end

function finish_spellset(run)
    end_run(run)
    if run.changes > 0 then
        log(run.name..' has been equipped ('..'%.1f':format(os.clock() - run.started)..'s).')
    else
        log(run.name..' was already equipped.')
    end
    report_skipped(run)
end

function report_skipped(run)
    local skipped = {}
    local reasons = {}
    for _, key in ipairs(run.skipOrder) do
        local reason = run.skipped[key]
        if not skipped[reason] then
            skipped[reason] = {}
            reasons[#reasons + 1] = reason
        end
        local spell = spells[key]
        table.insert(skipped[reason], spell and spell.name or key)
    end
    if #reasons > 0 then
        local parts = {}
        for _, reason in ipairs(reasons) do
            parts[#parts + 1] = table.concat(skipped[reason], ', ')..' ('..reason..')'
        end
        warning('Skipped: '..table.concat(parts, '; '))
    end
end

function spell_problem(spell, learned)
    if not spell then
        return 'unknown spell'
    end
    if not spell.blu_points then
        return 'cannot be set'
    end
    if learned and not learned[spell.id] then
        return 'not learned'
    end
    if spell.levels and spell.levels[BLU_JOB_ID] and spell.levels[BLU_JOB_ID] > bluJobLevel then
        return 'level too low'
    end
end

function find_spell_id_by_name(spellname)
    local spell = spellsLookup[spellname:lower()]
    if spell and spell.id then
        return spell.id
    end
end

function set_single_spell(setspell, slot)
    if is_busy() then
        error('Already setting '..applying.name..', please wait (or //aset stop).')
        return
    end
    update_current_spellset()
    for _, name in pairs(currentSpellSet) do
        if name == setspell then
            error('That spell is already set.')
            return
        end
    end
    slot = '%02u':format(tonumber(slot))
    --insert spell add code here
    local spellId = find_spell_id_by_name(setspell)
    local verified = verify_and_set_spell(spellId, tonumber(slot))
    if verified then
        windower.send_command('@timers c "Blue Magic Cooldown" 60 up')
        currentSpellSet['slot'..slot] = setspell
    end
end

function current_spell_ids()
    local data = get_blu_job_data and get_blu_job_data()
    return data and data.spells and T(data.spells):filter(function(id) return id ~= EMPTY_SLOT and id ~= 0 end)
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

function remove_all_spells()
    windower.ffxi.reset_blue_magic_spells()
    notice('All spells removed.')
end

function save_set(setname)
    if setname:lower() == 'default' then
        error('Please choose a name other than default.')
        return
    end
    local existing = find_spellset(setname)
    setname = existing or setname
    update_current_spellset()
    settings.spellsets[setname] = currentSpellSet
    settings:save('all')
    notice((existing and 'Overwrote ' or 'Saved ')..setname..'.')

    local key = spellset_key(setname)
    local same = {}
    for _, other in ipairs(spellset_list()) do
        if other ~= setname and spellset_key(other) == key then
            same[#same + 1] = other
        end
    end
    if #same > 0 then
        notice(setname..' has the same spells as '..table.concat(same, ', ')..'.')
    end
end

function spellset_list()
    local names = {}
    for key in pairs(settings.spellsets) do
        if key ~= 'default' then
            names[#names + 1] = key
        end
    end
    table.sort(names)
    return names
end

function spellset_key(spellset)
    local keys = {}
    for _, name in ipairs(spellset_names(spellset)) do
        local spell = spellsLookup[name]
        keys[#keys + 1] = spell and tostring(spell.id) or name
    end
    table.sort(keys)
    return table.concat(keys, ',')
end

function inspect_spellset(spellset, learned)
    local count, points = 0, 0
    local problems, byProblem = {}, {}
    for _, name in ipairs(spellset_names(spellset)) do
        local spell = spellsLookup[name]
        if spell and spell.blu_points then
            count = count + 1
            points = points + spell.blu_points
        end
        local problem = spell_problem(spell, learned)
        if problem then
            if not byProblem[problem] then
                byProblem[problem] = {}
                problems[#problems + 1] = problem
            end
            table.insert(byProblem[problem], spell and spell.name or name)
        end
    end

    local issues = {}
    for _, problem in ipairs(problems) do
        issues[#issues + 1] = table.concat(byProblem[problem], ', ')..' ('..problem..')'
    end
    if count > bluSlots then
        issues[#issues + 1] = 'needs '..count..' slots, you have '..bluSlots
    end
    if points > bluPointsMax then
        issues[#issues + 1] = 'needs '..points..' points, you have '..bluPointsMax
    end
    return count, points, issues
end

function check_spellsets(spellset)
    local names = spellset_list()
    if spellset then
        local name = find_spellset(spellset)
        if name == nil then
            error('Set not defined: '..spellset)
            return
        end
        names = {name}
    end

    local learned = windower.ffxi.get_spells()
    local found = false
    for _, name in ipairs(names) do
        local _, _, issues = inspect_spellset(name, learned)
        if #issues > 0 then
            found = true
            warning(name..': '..table.concat(issues, '; '))
        end
    end
    if not found then
        log(spellset and names[1]..' looks fine.' or 'All sets look fine.')
    end
end

function delete_set(setname)
    local name = find_spellset(setname)
    if name == nil then
        error('Please choose an existing spellset.')
        return
    end
    settings.spellsets[name] = nil
    settings:save('all')
    notice('Deleted '..name..'.')
end

function get_spellset_list()
    log('Listing sets:')
    local learned = windower.ffxi.get_spells()
    for _, name in ipairs(spellset_list()) do
        local count, points, issues = inspect_spellset(name, learned)
        local line = '\t'..name..': '..count..' spells, '..points..' points'
        if #issues > 0 then
            line = line..' - has problems, see //aset check '..name
        end
        log(line)
    end
end

function get_spellset_content(spellset)
    local name = find_spellset(spellset)
    if name == nil then
        error('Set not defined: '..spellset)
        return
    end
    local learned = windower.ffxi.get_spells()
    local count, points = inspect_spellset(name, learned)
    log(name..': '..count..'/'..bluSlots..' slots, '..points..'/'..bluPointsMax..' points')
    for i, spellName in ipairs(spellset_names(name)) do
        local spell = spellsLookup[spellName]
        local line = '\t'..i..'. '..(spell and spell.name or spellName)
        if spell and spell.blu_points then
            line = line..' ('..spell.blu_points..')'
        end
        local problem = spell_problem(spell, learned)
        if problem then
            line = line..' - '..problem
        end
        log(line)
    end
end

function spell_points(id)
    local spell = id and spells[id]
    return spell and spell.blu_points or 0
end

function verify_and_set_spell(id, slot)
    local spell = spells[id]
    if not spell then
        error('Spell named not found')
        return false
    end
    if not windower.ffxi.get_spells()[id] then
        error('Spell not learned')
        return false
    end
    if bluJobLevel and spell.levels and spell.levels[BLU_JOB_ID] and spell.levels[BLU_JOB_ID] > bluJobLevel then
        error('Blue Mage Level too low to set spell')
        return false
    end
    if not have_enough_points_to_add_spell(id, slot) then
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

function have_enough_points_to_add_spell(spellId, slot)
    local spell = spells[spellId]
    if not spell or not spell.blu_points then
        return nil
    end
    return spell.blu_points + current_total_points_spent() - spell_points(get_blu_job_data().spells[slot]) <= bluPointsMax
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
    local args = T{...}
    local comm = (table.remove(args, 1) or 'help'):lower()
    if comm == 'stop' then
        stop_spellset()
        return
    end
    if not bluJobLevel then
        error('You are not a Blue Mage.')
        return nil
    end
    if comm == 'removeall' then
        if is_busy() then
            log('Stopped setting '..applying.name..'.')
            end_run(applying)
        end
        applying = nil
        remove_all_spells()
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
    elseif comm == 'check' then
        check_spellsets(args[1])
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
        local helptext = [[AzureSets - Command List:
1. removeall - Unsets all spells (and stops a spellset being set).
2. spellset <setname> [ClearFirst|PreserveTraits] -- Set (setname)'s spells,
    optional parameter: ClearFirst or PreserveTraits: overrides
    setting to clear spells first or remove individually,
    preserving traits where possible. Default: use settings or
    preservetraits if settings not configured. Takes over from
    a spellset still being set.
3. set <setname> (clearfirst|preservetraits) -- Same as spellset
4. add <slot> <spell> -- Set (spell) to slot (slot (number)).
5. save <setname> -- Saves current spellset as (setname).
6. delete <setname> -- Delete (setname) spellset.
7. currentlist -- Lists currently set spells.
8. setlist -- Lists all spellsets with their spells and points.
9. spelllist <setname> -- List spells in (setname), with points and problems.
10. stop -- Stops setting the spellset currently being set.
11. check [setname] -- Lists spells that can't be set, in (setname) or all sets.
12. help --Shows this menu.]]
        for _, line in ipairs(helptext:split('\n')) do
            windower.add_to_chat(207, line..chat.controls.reset)
        end
    end
end)

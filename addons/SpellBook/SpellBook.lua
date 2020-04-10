_addon.name     = 'SpellBook'
_addon.author   = 'SigilBaram'
_addon.version  = '1.0.1'
_addon.commands = {'spellbook','spbk'}

require('tables')
res = require('resources')

spell_types = {
    whitemagic  = { type = 'WhiteMagic',    readable = 'White Magic spells' },
    blackmagic  = { type = 'BlackMagic',    readable = 'Black Magic spells' },
    songs       = { type = 'BardSong',      readable = 'Bard songs' },
    ninjutsu    = { type = 'Ninjutsu',      readable = 'Ninjutsu' },
    summoning   = { type = 'SummonerPact',  readable = 'Summoning spells' },
    bluemagic   = { type = 'BlueMagic',     readable = 'Blue Magic spells' },
    geomancy    = { type = 'Geomancy',      readable = 'Geomancy spells' },
    trusts      = { type = 'Trust',         readable = 'Trusts'},
    all         = { type = 'all',           readable = 'spells of all types'}
}

windower.register_event('addon command', function (command, ...)
    local args = L{...}
    local jobs = build_job_list()

    command = command and command:lower() or 'current'

    if command == 'help' then
        display_help()
    elseif command == 'current' then
        local player = windower.ffxi.get_player()
        spells_by_current(player)
    elseif command == 'main' then
        local player = windower.ffxi.get_player()
        local level = player.main_job_level
        local job_points = player.job_points[player.main_job:lower()].jp_spent
        if job_points > 99 then
            level = job_points
        end
        level = args[1] or level
        if level == 'all' then
            level = 1500
        end
        level = tonumber(level)
        if level then
            spells_by_job(player.main_job_id, level)
        else
            invalid_input()
        end
    elseif command == 'sub' then
        local player = windower.ffxi.get_player()
        if not player.sub_job then
            windower.add_to_chat(7, "You don't have a subjob equipped.")
            return
        end
        local level = args[1] or player.sub_job_level
        if level == 'all' then
            level = 1500
        end
        level = tonumber(level)
        if level then
            spells_by_job(player.sub_job_id, level)
        else
            invalid_input()
        end
    elseif spell_types[command] then
        if args[1] == 'all' then
            local player = windower.ffxi.get_player()
            spells_by_type(player, spell_types[command], false)
        elseif args[1] == nil then
            local player = windower.ffxi.get_player()
            spells_by_type(player, spell_types[command], true)
        else
            invalid_input()
        end
    elseif jobs[command] then
        local job = jobs[command]
        local player = windower.ffxi.get_player()
        local level = args[1] or player.jobs[res.jobs[job].english_short]
        if level == 'all' then
            level = 1500
        end
        level = tonumber(level)
        if level then
            spells_by_job(job, level)
        else
            invalid_input()
        end
    else
        invalid_input()
    end
end)

--------------------------------------------------------------------------------
--Name: build_job_list
--------------------------------------------------------------------------------
--Returns:
---- (table) list of jobs with short name as the key and id as the value
--------------------------------------------------------------------------------
function build_job_list()
    local jobs = {}
    for id,val in pairs(res.jobs) do
        jobs[val.english_short:lower()] = id
    end
    return jobs
end

--------------------------------------------------------------------------------
--Name: invalid_input
---- Display an error message for invalid input.
--------------------------------------------------------------------------------
function invalid_input()
    windower.add_to_chat(7, 'Invalid input. See //spbk help.')
end

--------------------------------------------------------------------------------
--Name: display_help
-- Display help text for the addon.
--------------------------------------------------------------------------------
function display_help()
    windower.add_to_chat(7, _addon.name .. ' version ' .. _addon.version)
    windower.add_to_chat(7, 'Spent jp can be specified for spells learned from Gifts by entering a value of 100-1500.')
    windower.add_to_chat(7, 'Spells are never given as Gifts for less than 100 jp and values under 100 are treated as level.')
    windower.add_to_chat(7, '//spbk help -- Show this help text.')
    windower.add_to_chat(7, '//spbk [current] -- Show learnable spells based on current main and sub job and level/jp.')
    windower.add_to_chat(7, '//spbk <main|sub> [<level|spent jp|all>] -- Show missing spells for current main or sub job. Defaults to the job\'s current level/jp.')
    windower.add_to_chat(7, '//spbk <job> [<level|spent jp|all>] -- Show missings spells for specified job and level. Defaults to the job\'s level/jp.')
    windower.add_to_chat(7, '//spbk <category> [all] -- Show learnable spells by category. Limited to spells which are learnable, unless all is added after the category.')
    windower.add_to_chat(7, 'Categories: whitemagic, blackmagic, songs, ninjustu, summoning, bluemagic, geomancy, trusts, all (Trusts are not included in all)')
end

--------------------------------------------------------------------------------
--Name: is_learnable
--Args:
---- player (table): player object from windower.ffxi.get_player()
---- spell (table): a spell from resources.spells
--------------------------------------------------------------------------------
--Returns:
---- (bool) true if player has a job that is high enough level to learn spell
--------------------------------------------------------------------------------
function is_learnable(player, spell)
    local player_levels = player.jobs
    for job,level in pairs(spell.levels) do
        if player_levels[res.jobs[job].english_short] >= level then
            return true
        end
    end
    return false
end

--------------------------------------------------------------------------------
--Name: format_spell
-- Formats a spell as the spell's name followed by a list of jobs and levels
-- which would qualify to learn that spell.
--Args:
---- spell (table): a spell from resources.spells
--------------------------------------------------------------------------------
--Returns:
---- (string) the formatted string
--------------------------------------------------------------------------------
function format_spell(spell)
    local format

    if spell.type ~= 'Trust' then
        local jobs = T{}
        local levels = T{}
        for job_id,_ in pairs(spell.levels) do
            jobs:append(job_id)
        end
        jobs:sort()
        for _,job_id in ipairs(jobs) do
            if spell.levels[job_id] <= 99 then
                levels:append(res.jobs[job_id].english_short .. ' Lv.' ..
                    tostring(spell.levels[job_id]))
            else
                levels:append(res.jobs[job_id].english_short .. ' Jp.' ..
                    tostring(spell.levels[job_id]))
            end
        end
        format = levels:concat(' / ')
    else
        format = ' ( Trust )'
    end
    return string.format('%-20s %s', spell.english, format)
end

--------------------------------------------------------------------------------
--Name: spells_by_type
-- List spells of a given type, i.e. white magic.
--Args:
---- player (T): player object from windower.ffxi.get_player()
---- spell_type (table): one of the types from spell_types global
---- learnable_only (bool): if true then the output is limited to spell for
----     which the player has a job that is high enough level
--------------------------------------------------------------------------------
function spells_by_type(player, spell_type, learnable_only)
    local missing_spells = T{}
    local player_spells = windower.ffxi.get_spells()
    local spell_count = 0

    for spell_id,spell in pairs(res.spells) do
        if ((spell_type.type == 'all' and spell.type ~= 'Trust') or
            spell.type == spell_type.type) and
            not table.empty(spell.levels) and
            not player_spells[spell_id] and
            (is_learnable(player, spell) or not learnable_only) and
            not (spell_type.type == 'Trust' and spell.name:match('.*%(UC%)')) and
            not spell.unlearnable then

            missing_spells:append(format_spell(spell))
            spell_count = spell_count + 1
        end
    end

    if learnable_only then
        windower.add_to_chat(7, string.format('Showing learnable %s.',
            spell_type.readable))
    else
        windower.add_to_chat(7, string.format('Showing all missing %s.',
            spell_type.readable))
    end

    if not missing_spells:empty() then
        missing_spells:sort()
        for _,spell in ipairs(missing_spells) do
            windower.add_to_chat(7, spell)
        end
        if learnable_only then
            windower.add_to_chat(7,string.format(
                'List Complete. You are missing %d learnable %s.',
                spell_count, spell_type.readable))
        else
            windower.add_to_chat(7,string.format(
                'List Complete. You are missing %d %s.',
                spell_count, spell_type.readable))
        end
    else
        if learnable_only then
            windower.add_to_chat(7,string.format(
                'Congratulations! You know all currently learnable %s.',
                spell_type.readable))
        else
            windower.add_to_chat(7,string.format(
                'Congratulations! You know all %s.',
                spell_type.readable))
        end
    end
end

--------------------------------------------------------------------------------
--Name: spells_by_job
-- List unknown spells by job.
--Args:
---- job (int): the job's id
---- level_cap (int): the max level/jp required by listed spells
--------------------------------------------------------------------------------
function spells_by_job(job, level_cap)
    local missing_spells = T{}
    local player_spells = windower.ffxi.get_spells()
    local spell_count = 0

    for spell_id,spell in pairs(res.spells) do
        local spell_level = spell.levels[job]
        if spell_level and spell_level <= level_cap and
            spell.type ~= 'Trust' and not player_spells[spell_id] and
            not spell.unlearnable then

            missing_spells[spell_level] = missing_spells[spell_level] or T{}
            missing_spells[spell_level]:append(spell.english)
            spell_count = spell_count + 1
        end
    end

    if not missing_spells:empty() then
        if level_cap > 99 then
            windower.add_to_chat(7, string.format(
                'Showing missing spells for %s up to %d spent job points.',
                res.jobs[job].en, level_cap))
        else
            windower.add_to_chat(7, string.format(
                'Showing missing spells for %s up to level %d.',
                res.jobs[job].en, level_cap))
        end

        for level=1,level_cap do
            if missing_spells[level] then
                missing_spells[level]:sort()
                if level > 99 then
                    windower.add_to_chat(7,
                        level .. 'jp: ' .. missing_spells[level]:concat(', '))
                else
                    windower.add_to_chat(7,
                        level .. ': ' .. missing_spells[level]:concat(', '))
                end
            end
        end
        if level_cap > 99 then
            windower.add_to_chat(7, string.format(
                'List Complete. You are missing %d %s spells up to %d spent job points.',
                spell_count, res.jobs[job].en, level_cap))
        else
            windower.add_to_chat(7, string.format(
                'List Complete. You are missing %d %s spells up to level %d.',
                spell_count, res.jobs[job].en, level_cap))
        end
    else
        if level_cap >= 1500 then
            windower.add_to_chat(7,string.format(
                'Congratulations! You know all spells for %s.',
                res.jobs[job].en))
        elseif level_cap > 99 then
            windower.add_to_chat(7,string.format(
                'Congratulations! You know all spells for %s up to %d spent job points!',
                res.jobs[job].en, level_cap))
        else
            windower.add_to_chat(7,string.format(
                'Congratulations! You know all spells for %s up to level %d!',
                res.jobs[job].en, level_cap))
        end
    end
end

--------------------------------------------------------------------------------
--Name: spells_by_current
-- Show missing spells for the current main and sub jobs.
--Args:
---- player (T): player object from windower.ffxi.get_player()
--------------------------------------------------------------------------------
function spells_by_current(player)
    local missing_spells = T{}
    local player_spells = windower.ffxi.get_spells()
    local spell_count = 0


    local main_job_level = player.main_job_level
    local main_job_jp = player.job_points[player.main_job:lower()].jp_spent

    local main_level
    local sub_level

    -- If the player has over 99 spend jp, then switch to treating JP as level.
    if main_job_jp > 99 then
        main_job_level = main_job_jp
    end

    for spell_id,spell in pairs(res.spells) do
        local main_level = spell.levels[player.main_job_id]
        local sub_level = spell.levels[player.sub_job_id]
        local spell_level = nil


        if main_level and main_level > main_job_level then
            main_level = nil
        end
        if sub_level and sub_level > player.sub_job_level then
            sub_level = nil
        end

        if main_level and sub_level then
            spell_level = math.min(main_level, sub_level)
        else
            spell_level = spell_level or main_level or sub_level
        end

        if spell_level and spell.type ~= 'Trust' and
            not player_spells[spell_id] and not spell.unlearnable then

            missing_spells:append(format_spell(spell))
            spell_count = spell_count + 1
        end
    end

    if not missing_spells:empty() then
        if main_job_jp > 0 then
            if player.sub_job then
                windower.add_to_chat(7, string.format('Showing learnable spells for %s%d with %d spent job points and %s%d.',
                    player.main_job, player.main_job_level,
                    player.job_points[player.main_job:lower()].jp_spent,
                    player.sub_job, player.sub_job_level))
            else
                windower.add_to_chat(7, string.format('Showing learnable spells for %s%d with %d spent job points.',
                    player.main_job, player.main_job_level,
                    player.job_points[player.main_job:lower()].jp_spent))
            end
        else
            if player.sub_job then
                windower.add_to_chat(7, string.format('Showing learnable spells for %s%d/%s%d.',
                    player.main_job, player.main_job_level,
                    player.sub_job, player.sub_job_level))
            else
                windower.add_to_chat(7, string.format('Showing learnable spells for %s%d.',
                    player.main_job, player.main_job_level))
            end
        end

        missing_spells:sort()
        for _,spell in ipairs(missing_spells) do
            windower.add_to_chat(7, spell)
        end
        if player.sub_job then
            windower.add_to_chat(7, string.format('List Complete. You are missing %d learnable spells for %s%d/%s%d.',
                spell_count,
                player.main_job, player.main_job_level,
                player.sub_job, player.sub_job_level))
        else
            windower.add_to_chat(7, string.format('List Complete. You are missing %d learnable spells for %s%d.',
                spell_count,
                player.main_job, player.main_job_level))
        end
    else
        if player.sub_job then
            windower.add_to_chat(7,  string.format('Congratulations! You know all learnable spells for %s%d/%s%d!',
                player.main_job, player.main_job_level,
                player.sub_job, player.sub_job_level))
        else
            windower.add_to_chat(7,  string.format('Congratulations! You know all learnable spells for %s%d!',
                player.main_job, player.main_job_level))
        end
    end
end

--[[
Copyright © 2018, John S Hobart
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of SpellBook nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL John S Hobart BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

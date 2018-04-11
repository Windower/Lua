_addon.name     = 'SpellBook'
_addon.author   = 'SigilBaram'
_addon.version  = '0.0.1'
_addon.commands  = {'spellbook','spbk'}

require('tables')
res = require('resources')

spell_types = {
    whitemagic= { type = 'WhiteMagic', readable = 'White Magic spells' },
    blackmagic= { type = 'BlackMagic', readable = 'Black Magic spells' },
    songs=      { type = 'BardSong', readable = 'Bard songs' },
    ninjutsu=   { type = 'Ninjutsu', readable = 'Ninjutsu' },
    summoning=  { type = 'SummonerPact', readable = 'Summoning spells' },
    bluemagic=  { type = 'BlueMagic',  readable = 'Blue Magic spells' },
    geomancy=   { type = 'Geomancy', readable = 'Geomancy spells' },
    trusts=     { type = 'Trust', readable = 'Trusts'},
    all=        { type = 'all', readable = 'spells of all types'}
}

windower.register_event('addon command', function (command, ...)
    local args = L{...}
    local player = windower.ffxi.get_player()
    local jobs = build_job_list()

    command = command and command:lower()

    if command == 'help' then
        display_help()
    elseif command == nil or command == 'current' then
        spells_by_current()
    elseif command == 'main' then
        local level = args[1] or player.main_job_level
        if level == 'all' or tonumber(level) ~= nil then
            if level == 'all' then
                level = 1500
            end
            level = tonumber(level)
            spells_by_job(player.main_job_id, tonumber(level))
        else
            invalid_input()
        end
    elseif command == 'sub' then
        local level = args[1] or player.sub_job_level
        if level == 'all' or tonumber(level) ~= nil then
            spells_by_job(player.sub_job_id, tonumber(level))
        else
            invalid_input()
        end
    elseif spell_types[command] then
        if args[1] == 'all' then
            spells_by_type(spell_types[command], false)
        else
            spells_by_type(spell_types[command], true)
        end
    elseif jobs[command] then
        local job = jobs[command]
        local level = args[1] or player.jobs[res.jobs[job].ens]
        if level == 'all' then
            level = 1500
        end
        spells_by_job(job, tonumber(level))
    else
        invalid_input()
    end
end)

--[[
Builds a list of jobs with short name as the key and id as the value, for
reading in user input.
--]]
function build_job_list()
    local jobs = {}
    for id,val in pairs(res.jobs) do
        jobs[val.ens:lower()] = id
    end
    return jobs
end

-- Display an error message for invalid input.
function invalid_input()
    windower.add_to_chat(7, 'Invalid input. See //spbk help.')
end

-- Display help text for the addon.
function display_help()
    windower.add_to_chat(7, _addon.name .. ' version ' .. _addon.version)
    windower.add_to_chat(7, '//spbk help -- show this help text')
    windower.add_to_chat(7, '//spbk [current] -- Shows learnable spells based on current main and sub job and level.')
    windower.add_to_chat(7, '//spbk <main|sub> [<level|all>] -- Show missing spells for current main or sub job. Defaults to the job\'s current level.')
    windower.add_to_chat(7, '//spbk <job> [<level|all>] -- Show missings spells for specified job and level. Defaults to the job\'s level.')
    windower.add_to_chat(7, '//spbk <category> [all] -- Show learnable spells by category. Limited to spells which are learnable, unless all is added after the category.')
    windower.add_to_chat(7, 'Categories: whitemagic, blackmagic, songs, ninjustu, summoning, bluemagic, geomancy, trusts, all (Trusts are not included in all)')
end

--[[
Returns true if the player has any jobs which is high enough level to learn
the given spell.
--]]
function is_learnable(spell)
    local player_levels = windower.ffxi.get_player().jobs
    for job,level in pairs(spell.levels) do
        if player_levels[res.jobs[job].ens] >= level then
            return true
        end
    end
    return false
end

--[[
Formats a spell as the spell's name followed by a list of jobs and levels
which would qualify to learn that spell.
--]]
function format_spell(spell)
    local format = string.format('%-20s',spell.en)

    if spell.type ~= 'Trust' then
        local levels = T{}
        for job_id,level in pairs(spell.levels) do
            if level <= 99 then
                levels:append(res.jobs[job_id].ens .. ' ' .. tostring(level))
            else
                levels:append(res.jobs[job_id].ens .. ' ' .. tostring(level) .. 'jp')
            end
        end
        format = format .. ' ( ' .. levels:concat(', ') .. ' )'
    else
        format = format .. ' ( Trust )'
    end
    return format
end

--[[
Show missing spells of a given type. If learnable is true, then the
results will be limited to spells for which the player has a job at a
level required to learn the spell.
--]]
function spells_by_type(spell_type, learnable_only)
    local missing_spells = T{}
    local player_spells = windower.ffxi.get_spells()
    local spell_count = 0

    for spell_id,spell in pairs(res.spells) do
        if ((spell_type.type == 'all' and spell.type ~= 'Trust') or
            spell.type == spell_type.type) and next(spell.levels) ~= nill and
            not player_spells[spell_id] and (is_learnable(spell) or
            not learnable_only) and not spell.unlearnable then

            missing_spells:append(format_spell(spell))
            spell_count = spell_count + 1
        end
    end

    if learnable_only then
        windower.add_to_chat(7, 'Showing learnable ' ..
            spell_type.readable .. '.')
    else
        windower.add_to_chat(7, 'Showing all missing ' ..
            spell_type.readable .. '.')
    end

    if next(missing_spells) ~= nil then
        missing_spells:sort()
        for _,spell in ipairs(missing_spells) do
            windower.add_to_chat(7, spell)
        end
        if learnable_only then
            windower.add_to_chat(7,
                'List Complete. You are missing ' ..
                tostring(spell_count) .. ' learnable ' ..
                spell_type.readable .. '.')
        else
            windower.add_to_chat(7,
                'List Complete. You are missing ' ..
                tostring(spell_count) .. ' ' .. spell_type.readable .. '.')
        end
    else
        if learnable_only then
            windower.add_to_chat(7,
                'Congratulations! You know all currently learnable ' ..
                spell_type.readable .. '.')
        else
            windower.add_to_chat(7, 'Congratulations! You know all ' ..
                spell_type.readable .. '.')
        end
    end
end

--[[
List unkown spells for a specific job (by id), up to an optional level.
If no level_cap is given then the maximum is used.
--]]
function spells_by_job(job, level_cap)
    local missing_spells = T{}
    local player_spells = windower.ffxi.get_spells()
    local spell_count = 0

    level_cap = tonumber(level_cap) or 1500

    for spell_id,spell in pairs(res.spells) do
        local spell_level = spell.levels[job]
        if spell_level and spell_level <= level_cap and
            spell.type ~= 'Trust' and not player_spells[spell_id] and
            not spell.unlearnable then

            missing_spells[spell_level] = missing_spells[spell_level] or T{}
            missing_spells[spell_level]:append(spell.en)
            spell_count = spell_count + 1
        end
    end

    if next(missing_spells) ~= nil then
        if level_cap > 99 then
            windower.add_to_chat(7,
                string.format('Showing missing spells for %s up to level %s.',
                res.jobs[job].en, level_cap))
        else
            windower.add_to_chat(7,
                string.format('Showing missing spells for %s up to %sjp.',
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
        windower.add_to_chat(7, 'List Complete. You are missing ' ..
            tostring(spell_count) .. ' ' .. res.jobs[job].en .. ' spells.')
    else
        if level_cap >= 1500 then
            windower.add_to_chat(7,
                'Congratulations! You know all spells for ' ..
                res.jobs[job].en .. '.')
        else
            if level_cap > 99 then
                windower.add_to_chat(7,
                    'Congratulations! You know all spells for ' ..
                    res.jobs[job].en .. ' up to ' ..
                    tostring(level_cap) .. 'jp.')
            else
                windower.add_to_chat(7,
                    'Congratulations! You know all spells for ' ..
                    res.jobs[job].en .. ' up to level ' ..
                    tostring(level_cap) .. '.')
            end
        end
    end
end

-- Show missing spells for the current main and sub jobs.
function spells_by_current()
    local missing_spells = T{}
    local player = windower.ffxi.get_player()
    local player_spells = windower.ffxi.get_spells()
    local spell_count = 0


    local main_job_level = player.main_job_level
    local main_job_jp = player.job_points[player.main_job:lower()].jp_spent

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
        if sub_level and sub_level> player.sub_job_level then
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

    if next(missing_spells) ~= nil then
        windower.add_to_chat(7, string.format('Showing learnable spells for %s%d/%s%d.',
            player.main_job:lower(), player.main_job_level,
            player.sub_job:lower(), player.sub_job_level))

        missing_spells:sort()
        for _,spell in ipairs(missing_spells) do
            windower.add_to_chat(7, spell)
        end
        windower.add_to_chat(7, string.format('List Complete. You are missing %d spells for %s%d/%s%d.',
            spell_count, player.main_job:lower(), player.main_job_level,
            player.sub_job:lower(), player.sub_job_level))
    else
        windower.add_to_chat(7,  string.format('Congratulations! You know all spells for %s%d/%s%d!',
            player.main_job:lower(), player.main_job_level,
            player.sub_job:lower(), player.sub_job_level))
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
DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

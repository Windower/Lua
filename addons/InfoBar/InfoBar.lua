--[[Copyright © 2017, Kenshi
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of InfoBar nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL KENSHI BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.name = 'Infobar'
_addon.author = 'Kenshi'
_addon.version = '1.0'
_addon.commands = {'ib', 'infobar'}

config = require('config')
texts = require('texts')
require('vectors')
res = require('resources')
require('sqlite3')

defaults = {}
defaults.NoTarget = "${name} (${main_job}${main_job_level}/${sub_job}${sub_job_level}) (${x},${y},${z})"
defaults.TargetPC = "${name}"
defaults.TargetNPC = "${name}"
defaults.TargetMOB = "${name}"
defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 0
defaults.display.pos.y = 0
defaults.display.bg = {}
defaults.display.bg.red = 0
defaults.display.bg.green = 0
defaults.display.bg.blue = 0
defaults.display.bg.alpha = 102
defaults.display.text = {}
defaults.display.text.font = 'Consolas'
defaults.display.text.red = 255
defaults.display.text.green = 255
defaults.display.text.blue = 255
defaults.display.text.alpha = 255
defaults.display.text.size = 12

settings = config.load(defaults)

box = texts.new("", settings.display, settings)

local infobar = {}
infobar.new_line = '\n'

windower.register_event('load',function()
    db = sqlite3.open(windower.addon_path..'\database.db')
    notesdb = sqlite3.open(windower.addon_path..'/notes.db')
    notesdb:exec('CREATE TABLE notes')
    notesdb:exec('CREATE TABLE notes(name, note)')
    if not windower.ffxi.get_info().logged_in then return end
    local target = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_player()
    get_target(target.index)
end)

windower.register_event('unload',function()
    db:close()
    notesdb:close()
end)

function getDegrees()
    local target = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('me')
    local target_heading = V{}.from_radian(target.facing)
    local angleInDegrees = (math.atan2(target_heading[1], target_heading[2]) * (180 / math.pi))
    local Degrees = angleInDegrees % 360
    return math.floor(Degrees)
end

function DegreesToDirection(Degrees)
    local direction = (Degrees <= 11.25 and Degrees >= 0 and 'N') or
        (Degrees <= 360 and Degrees > (11.25 * 31) and 'N') or
        (Degrees <= (11.25 * 3) and Degrees > 11.25 and 'NNE') or
        (Degrees <= (11.25 * 5) and Degrees > (11.25 * 3) and 'NE') or
        (Degrees <= (11.25 * 7) and Degrees > (11.25 * 5) and 'NEE') or
        (Degrees <= (11.25 * 9) and Degrees > (11.25 * 7) and 'E') or
        (Degrees <= (11.25 * 11) and Degrees > (11.25 * 9) and 'SEE') or
        (Degrees <= (11.25 * 13) and Degrees > (11.25 * 11) and 'SE') or
        (Degrees <= (11.25 * 15) and Degrees > (11.25 * 13) and 'SSE') or
        (Degrees <= (11.25 * 17) and Degrees > (11.25 * 15) and 'S') or
        (Degrees <= (11.25 * 19) and Degrees > (11.25 * 17) and 'SSW') or
        (Degrees <= (11.25 * 21) and Degrees > (11.25 * 19) and 'SW') or
        (Degrees <= (11.25 * 23) and Degrees > (11.25 * 21) and 'SWW') or
        (Degrees <= (11.25 * 25) and Degrees > (11.25 * 23) and 'W') or
        (Degrees <= (11.25 * 27) and Degrees > (11.25 * 25) and 'NWW') or
        (Degrees <= (11.25 * 29) and Degrees > (11.25 * 27) and 'NW') or
        (Degrees <= (11.25 * 31) and Degrees > (11.25 * 29) and 'NNW')
	return direction
end

function get_db(target, zones, level)
    local query = 'SELECT * FROM "monster" WHERE name = "'..target..'" AND zone = "'..zones..'"'
    local MOB_infobar = {}
    
    if db:isopen() and query then
        for id,name,family,job,zone,isaggressive,islinking,isnm,isfishing,levelmin,levelmax,sight,sound,magic,lowhp,healing,ts,th,scent,weakness,resistances,immunities,drops,stolen,spawn,spawntime in db:urows(query) do
            if name == target and zone == zones then
                MOB_infobar.family = family or ''
                MOB_infobar.job = job or ''
                MOB_infobar.levelrange = levelmin and levelmax and levelmin.."-"..levelmax or ''
                MOB_infobar.weakness = weakness or ''
                MOB_infobar.resistances = resistances or ''
                MOB_infobar.immunities = immunities or ''
                MOB_infobar.drops = drops or ''
                MOB_infobar.stolen = stolen or ''
                MOB_infobar.spawns = spawn or ''
                MOB_infobar.spawntime = spawntime or ''
                if isaggressive == 1 then
                    MOB_infobar.isagressive = 'A'
                    if (level - tonumber(levelmax)) <= 10 then
                        box:bold(true)
                    else
                        box:bold(false)
                    end
                else
                    MOB_infobar.isagressive = 'NA'
                end
                MOB_infobar.islinking = islinking == 1 and 'L' or 'NL'
                MOB_infobar.isnm = isnm == 1 and 'NM' or 'No NM'
                MOB_infobar.isfishing = isfishing == 1 and 'F' or 'NF'
                MOB_infobar.detect = (sight == 1 and 'S' or '')..
                    (sight == 1 and sound == 1 and ',H' or sound == 1 and 'H' or '')..
                    ((sight == 1 or sound == 1) and magic == 1 and ',M' or magic == 1 and 'M' or '')..
                    ((sight == 1 or sound == 1 or magic == 1) and lowhp == 1 and ',HP' or lowhp == 1 and 'HP' or '')..
                    ((sight == 1 or sound == 1 or magic == 1 and lowhp == 1) and healing == 1 and ',R' or healing == 1 and 'R' or '')..
                    ((sight == 1 or sound == 1 or magic == 1 and lowhp == 1 and healing == 1) and ts == 1 and ',TS' or ts == 1 and 'TS' or '')..
                    ((sight == 1 or sound == 1 or magic == 1 and lowhp == 1 and healing == 1 and ts == 1) and th == 1 and ',TH' or th == 1 and 'TH' or '')..
                    ((sight == 1 or sound == 1 or magic == 1 and lowhp == 1 and healing == 1 and ts == 1 and th == 1) and scent == 1 and ',Sc' or scent == 1 and 'Sc' or '')
            else
                box:bold(false)
                for i,v in pairs(MOB_infobar) do
                    v = ''
                end
            end
        end
    else
        box:bold(false)
        for i,v in pairs(MOB_infobar) do
            v = ''
        end
    end
    box:update(MOB_infobar)
end

function get_notes(target)
    local query = 'SELECT * FROM "notes" WHERE name = "'..target..'"'
    if notesdb:isopen() and query then
        for name, note in notesdb:urows(query) do
            if name == target then
                return note or nil
            end
        end
    end
end

function get_target(index)
    local player = windower.ffxi.get_player()
    local target = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t') or player
    infobar.name = target.name
    infobar.id = target.id
    infobar.index = target.index
    infobar.notes = get_notes(target.name)
    if index == 0 or index == player.index then
        infobar.main_job = player.main_job
        infobar.main_job_level = player.main_job_level
        infobar.sub_job = player.sub_job
        infobar.sub_job_level = player.sub_job_level
        box:color(255,255,255)
        box:bold(false)
        box:text(settings.NoTarget)
    else
        if target.spawn_type == 13 or target.spawn_type == 14 or target.spawn_type == 9 or target.spawn_type == 1 then
            box:bold(false)
            if target.spawn_type == 1 then
                box:color(255,255,255)
            else
                box:color(128,255,255)
            end
            box:text(settings.TargetPC)
        elseif target.spawn_type == 2 or target.spawn_type == 34 then
            box:color(128,255,128)
            box:text(settings.TargetNPC)
            box:bold(false)
        elseif target.spawn_type == 16 then
            local zone = res.zones[windower.ffxi.get_info().zone].name
            box:color(255,255,128)
            box:text(settings.TargetMOB)
            get_db(target.name, zone, player.main_job_level)
        end
    end
    box:update(infobar)
end

windower.register_event('incoming chunk',function(id,org,modi,is_injected,is_blocked)
    if id == 0xB then
        zoning_bool = true
    elseif id == 0xA and zoning_bool then
        zoning_bool = false
    end
end)

windower.register_event('prerender', function()
    local info = windower.ffxi.get_info()
    
    if not info.logged_in or not windower.ffxi.get_player() or zoning_bool then
        box:hide()
        return
    end
    
    infobar.game_moon = res.moon_phases[info.moon_phase].name
    infobar.game_moon_pct = info.moon..'%'
    infobar.zone_name = res.zones[info.zone].name
    
    local pos = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('me')
    if not pos then return end
    infobar.x = string.format('%0.3f', pos.x)
    infobar.y = string.format('%0.3f', pos.y)
    infobar.z = string.format('%0.3f', pos.z)
    infobar.facing = tostring(getDegrees())..'°'
    infobar.facing_dir = DegreesToDirection(getDegrees())
    
    box:update(infobar)
    box:show()
end)

windower.register_event('target change', get_target)
windower.register_event('job change', function()
    get_target(windower.ffxi.get_player().index)
end)

windower.register_event('time change', function(new, old)
    local alchemy = new >= 8*60 and new <= 23*60 and 'Open' or 'Closed'
    infobar.alchemy = alchemy == "Closed" and '\\cs(255,0,0)'..alchemy..'\\cr' or '\\cs(0,255,0)'..alchemy..'\\cr'
    local bonecraft = new >= 8*60 and new <= 23*60 and 'Open' or 'Closed'
    infobar.bonecraft = bonecraft == "Closed" and '\\cs(255,0,0)'..bonecraft..'\\cr' or '\\cs(0,255,0)'..bonecraft..'\\cr'
    local clothcraft = new >= 6*60 and new <= 21*60 and 'Open' or 'Closed'
    infobar.clothcraft = clothcraft == "Closed" and '\\cs(255,0,0)'..clothcraft..'\\cr' or '\\cs(0,255,0)'..clothcraft..'\\cr'
    local cooking = new >= 5*60 and new <= 20*60 and 'Open' or 'Closed'
    infobar.cooking = cooking == "Closed" and '\\cs(255,0,0)'..cooking..'\\cr' or '\\cs(0,255,0)'..cooking..'\\cr'
    local fishing = new >= 3*60 and new <= 18*60 and 'Open' or 'Closed'
    infobar.fishing = fishing == "Closed" and '\\cs(255,0,0)'..fishing..'\\cr' or '\\cs(0,255,0)'..fishing..'\\cr'
    local goldsmithing = new >= 8*60 and new <= 23*60 and 'Open' or 'Closed'
    infobar.goldsmithing = goldsmithing == "Closed" and '\\cs(255,0,0)'..goldsmithing..'\\cr' or '\\cs(0,255,0)'..goldsmithing..'\\cr'
    local leathercraft = new >= 3*60 and new <= 18*60 and 'Open' or 'Closed'
    infobar.leathercraft = leathercraft == "Closed" and '\\cs(255,0,0)'..leathercraft..'\\cr' or '\\cs(0,255,0)'..leathercraft..'\\cr'
    local smithing = new >= 8*60 and new <= 23*60 and 'Open' or 'Closed'
    infobar.smithing = smithing == "Closed" and '\\cs(255,0,0)'..smithing..'\\cr' or '\\cs(0,255,0)'..smithing..'\\cr'
    local woodworking = new >= 6*60 and new <= 21*60 and 'Open' or 'Closed'
    infobar.woodworking = woodworking == "Closed" and '\\cs(255,0,0)'..woodworking..'\\cr' or '\\cs(0,255,0)'..woodworking..'\\cr'
    box:update(infobar)
end)

windower.register_event('addon command', function(...)
    local args = T{...}
    if args[1] then
        if args[1]:lower() == 'help' then
            windower.add_to_chat(207,"Infobar Commands:")
            windower.add_to_chat(207,"//ib|infobar notes add 'string'")
            windower.add_to_chat(207,"//ib|infobar notes delete")
        elseif args[1]:lower() == 'notes' then
            local target = windower.ffxi.get_mob_by_target('t')
            local tname = string.gsub(target.name, ' ', '_')
            if not args[2] then
                windower.add_to_chat(207,"Second argument not specified, use '//ib|infobar help' for info.")
            elseif args[2]:lower() == 'add' then
                if not target then windower.add_to_chat(207,"No target selected") return end
                for i,v in pairs(args) do args[i]=windower.convert_auto_trans(args[i]) end
                local str = table.concat(args," ",3)
                notesdb:exec('delete from notes where name = "'..target.name..'"') --deleting previous notes
                notesdb:exec('insert into notes values ("'..target.name..'","'..str..'")')
                get_target(target.index)
            elseif args[2]:lower() == 'delete' then
                if not target then windower.add_to_chat(207,"No target selected") return end
                notesdb:exec('delete from notes where name = "'..target.name..'"')
                get_target(target.index)
            else
                windower.add_to_chat(207,"Second argument wrong, use '//ib|infobar help' for info.")
            end
        else
            windower.add_to_chat(207,"First argument wrong, use '//ib|infobar help' for info.")
        end
    else
        windower.add_to_chat(207,"First argument not specified, use '//ib|infobar help' for info.")
    end
end)

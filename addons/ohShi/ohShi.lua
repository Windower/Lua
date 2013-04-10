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

_addon = {}
_addon.name = 'OhShi'
_addon.version = '2.15'

--Requiring libraries used in this addon
--These should be saved in addons/libs
require 'tablehelper'
require 'stringhelper'
require 'logger'
local config = require 'config'
local files = require 'filehelper'

--Declaring default settings
local defaults = T{}
defaults.bggreen = 0                
defaults.posx = 300                    
defaults.bgalpha = 200            
defaults.textsize = 12            
defaults.posy = 300                    
defaults.textfont = 'Arial'        
defaults.textred = 255            
defaults.textgreen = 255        
defaults.staggeronly = false
defaults.bgred = 0                    
defaults.textblue = 255            
defaults.duration = 7            
defaults.bgblue = 0    
defaults.moblist = T{}
defaults.moblist['voidwatch'] = T{"Qilin", "Celaeno", "Morta", "Bismarck", "Ig-Alima", "Kalasutrax", "Ocythoe", "Gaunab", "Hahava", "Cherufe", "Botulus Rex", "Taweret", "Agathos", "Goji", "Gugalanna", "Gasha", "Giltine", "Mellonia", "Kaggen", "Akvan", "Pil", "Belphoebe", "Kholomodumo", "Aello", "Uptala", "Sarbaz", "Shah", "Wazir", "Asb", "Rukh", "Provenance Watcher"}
defaults.moblist['abyssea'] = T{"Alfard", "Orthrus", "Carabosse", "Glavoid", "Isgebind"}
defaults.moblist['legion'] = T{"Veiled", "Lofty", "Soaring", "Mired", "Paramount"}
defaults.moblist['meebles'] = T{"Goldwing", "Silagilith", "Surtr", "Dreyruk", "Samursk", "Umagrhk", "Izyx", "Grannus", "Svaha", "Melisseus"}
defaults.moblist['other'] = T{"Tiamat", "Khimaira", "Khrysokhimaira", "Cerberus", "Dvergr", "Bloodthirsty", "Hydra", "Enraged", "Odin"}
defaults.moblist['dangerous'] = T{"Provenance Watcher", "Apademak"}
defaults.dangerwords = T{}
defaults.dangerwords['weaponskills'] = T{"Zantetsuken", "Geirrothr", "Astral Flow", "Chainspell", "Beastruction", "Mandible Massacre", "Oblivion's Mantle", "Divesting Gale", "Frog", "Danse", "Raksha Stance", "Yama's", "Ballistic Kick", "Eradicator", "Arm Cannon", "Gorge", "Extreme Purgitation", "Slimy Proposal", "Rancid Reflux", "Provenance Watcher starts", "Pawn's Penumbra", "Gates", "Fulmination", "Nerve", "Thundris"}
defaults.dangerwords['spells'] = T{"Death", "Meteor", "Kaustra", "Breakga", "Thundaga IV", "Thundaja", "Firaga IV", "Firaja", "Aeroga IV", "Aeroja", "Blizzaga IV", "Blizzaja", "Stonega IV", "Stoneja"}
settings = config.load(defaults)
--This function is called when the addon loads. It is used to
--create all the tables used and populate them. There are also
--file checks in case settings or moblist.xml are deleted. This
--is also where the file objects for resources files are created.
function event_load()
    notice('Version '.._addon.version..' Loaded. Type //ohshi help for list of commands.')
    tracking = {}
    prims = {}
    spells = {}
    jobAbilities = {}
    mobAbilities = {}
    speFName = '../../plugins/resources/spells.xml'
    jaFName = '../../plugins/resources/abils.xml'
    maFName = '../libs/resources/mabils.xml'
    speFile = files.new(speFName)
    jaFile = files.new(jaFName)
    maFile = files.new(maFName)
    settings:save()
    -- Parse the resources and fill tables with the info.
    spells = parse_resources(speFile:readlines())
    jobAbilities = parse_resources(jaFile:readlines())
    mobAbilities = parse_resources(maFile:readlines())
    send_command('alias ohShi lua c ohshi') --For addon commands
    send_command('wait 1;ohshi create')
    deleteoldsettings()
end

--Used when the addon is unloaded to save settings and
--delete the textbox used
function event_unload()
    unloadtype = unloadtype or 'one'
    ohShi_delete()
end

--This function is used to process addon commands
--like //ohshi help and the like.
function event_addon_command(...)
    local args = {...}
    if args[1] ~= nil then
        comm = args[1]:lower()
        local list,td,utm,tm = ''
        if comm == 'help' then
            notice('Version '.._addon.version..' loaded! You have access to the following commands with the //ohshi alias:')
            notice(' 1. bgcolor <alpha> <red> <green> <blue> --Sets the color of the box.')
            notice(' 2. text <red> <green> <blue> --Sets text color.')
            notice(' 2. font <size> <name> --Sets text font and size.')
            notice(' 3. pos <posx> <posy> --Sets position of box.')
            notice(' 4. duration <seconds> --Sets the timeout on the notices.')
            notice(' 5. track <vw/legion/other/abyssea/meebles/dangerous> <mobname> --Adds mob to the tracking list.')
            notice(' -- Using dangerous will cause every tp move/spell to flash the warning.')
            notice(' 6. untrack <vw/legion/other/abyssea/meebles/dangerous> <mobname> --Removes mob from the tracking list.')
            notice(' 7. danger <spell/ws> <dangerword> --Adds danger word to list.')
            notice(' 8. staggeronly --Toggles stagger only mode.')
            notice(' 9. unload <all/one> Save settings all(global) or one(character) and close ohShi.')
            notice('10. help --Shows this menu.')
        elseif comm == 'create' then
            ohShi_SetUp()
        elseif comm == 'unload' then
            unloadtype = args[2] or 'one'
            send_command('lua u ohshi')
        elseif comm == 'bgcolor' then
            if args[5] ~= nil then
                tb_set_bg_color('ohShi',args[2],args[3],args[4],args[5])
                settings['bgalpha'] = tonumber(args[2])
                settings['bgred'] = tonumber(args[3])
                settings['bggreen'] = tonumber(args[4])
                settings['bgblue'] = tonumber(args[5])
                notice('Background color changed.')
                ohShi_Flash()
            else
                error('Improper syntax please use //ohshi help to get a list of commands.')
            end
        elseif comm == 'pos' then
            if args[2] ~= nil and args[3]~= nil then
                tb_set_location('ohShi',args[2],args[3])
                settings['posx'] = tonumber(args[2])
                settings['posy'] = tonumber(args[3])
                notice('Position changed posx: '..args[2].." posy: "..args[3])
                ohShi_Flash()
            else
                error('Improper syntax please use //ohshi help to get a list of commands.')
            end
        elseif comm == 'text' then
            if args[4] ~= nil then
                tb_set_color('ohShi',255,args[2],args[3],args[4])
                settings['textred'] = tonumber(args[2])
                settings['textgreen'] = tonumber(args[3])
                settings['textblue'] = tonumber(args[4])
                notice('Text color changed.')
                ohShi_Flash()
            else
                error('Improper syntax please use //ohshi help to get a list of commands.')
            end
        elseif comm == 'font' then
            if args[3] ~= nil then
                local font = ''
                local p
                for p = 3, #args do
                    font = font..args[p]
                    if p < #args then font = font..' ' end
                end
                settings['textfont'] = font
                settings['textsize'] = tonumber(args[2])
                tb_set_font('ohShi',font,args[2])
                notice('Font changed size: '..args[2]..' font: '..font)
                ohShi_Flash()
            else
                error('Improper syntax please use //ohshi help to get a list of commands.')
            end
        elseif comm == 'duration' then
            if args[2] ~= nil then
                settings['duration'] = tonumber(args[2])
                notice('Duration: '..args[2])
                tracking[#tracking+1] = ' ohShi settings updated. '
                ohShi_refresh()
                send_command('wait '..args[2]..';ohShi timeout 1')
            else
                error('Improper syntax please use //ohshi help to get a list of commands.')
            end
        elseif comm == 'track' then
            if args[3] ~= nil then
                if args[2] == 'vw' then
                    tm = 'voidwatch'
                elseif args[2] == 'legion' then
                    tm = 'legion'
                elseif args[2] == 'other' then
                    tm = 'other'
                elseif args[2] == 'meebles' then
                    tm = 'meebles'
                elseif args[2] == 'abyssea' then
                    tm = 'abyssea'
                elseif args[2] == 'dangerous' then
                    tm = 'dangerous'
                end
                if tm ~= nil then
                    local q
                    for q = 3, #args do
                        list = list..args[q]
                        if q < #args then list = list..' ' end
                    end
                    if not settings.moblist[tm]:contains(list) then
                        settings.moblist[tm]:append(list)
                        notice('Now tracking '..tm..' mob '..list)
                    else
                        error('Already tracking '..tm..' mob '..list)
                    end
                    tm = nil
                else
                    error('Improper Syntax: //ohShi track <vw/legion/other/abyssea/meebles> <mobname>')
                end
            else
                error('Improper syntax please use //ohshi help to get a list of commands.')
            end
        elseif comm == 'untrack' then
            if args[3] ~= nil then
                if args[2] == 'vw' then
                    utm = 'voidwatch'
                elseif args[2] == 'legion' then
                    utm = 'legion'
                elseif args[2] == 'other' then
                    utm = 'other'
                elseif args[2] == 'meebles' then
                    utm = 'meebles'
                elseif args[2] == 'abyssea' then
                    utm = 'abyssea'
                elseif args[2] == 'dangerous' then
                    utm = 'dangerous'
                end
                if utm ~= nil then
                    local q
                    for q = 3, #args do
                        list = list..args[q]
                        if q < #args then list = list..' ' end
                    end
                    if settings.moblist[utm]:contains(list) then
                        settings.moblist[utm]:delete(list)
                        notice('No longer tracking '..utm..' mob '..list)
                    else
                        error('You were not tracking '..tm..' mob '..list)
                    end
                    utm = nil
                else
                    error('Improper Syntax: //ohShi untrack <vw/legion/other/abyssea/meebles> <mobname>')
                end
            else
                error('Improper syntax please use //ohshi help to get a list of commands.')
            end
        elseif comm == 'danger' then
            if args[3] ~= nil then 
                if args[2] == 'spell' then
                    td = 'spells'
                elseif args[2] == 'ws' then
                    td = 'weaponskills'
                end
                if td ~= nil then
                    local r
                    for r = 3, #args do
                        list = list..args[r]
                        if r < #args then list = list..' ' end
                    end
                    if not settings.dangerwords[td]:contains(list) then
                        settings.dangerwords[td]:append(list)
                        notice('Now tracking '..td..' spell '..list)
                    else
                        error('Already tracking '..td..' spell '..list)
                    end
                else
                    error('Proper Syntax: //ohShi danger <spell/ws> <dangerword>')
                end
            else
                error('Improper syntax please use //ohshi help to get a list of commands.')
            end
        elseif comm == 'warnoff' then
            table.remove(prims,1)
            prim_delete(args[2])
        elseif comm == 'timeout' then
            if args[2] == nil then
                table.remove(tracking,1)
                ohShi_refresh()
            else
                for q = 1, #tracking do
                    if tracking[q] ==  ' ohShi settings updated. ' or tracking[q] == ' ohShi initialized. ' then
                        table.remove(tracking,q)
                        ohShi_refresh()
                    end
                end
            end
        elseif comm == 'staggeronly' then
                settings['staggeronly'] = not settings.staggeronly
                notice('Stagger only mode: '..tostring(settings.staggeronly))
        else
            error('Improper syntax please use //ohshi help to get a list of commands.')
            return
        end
    end
end

--Set up the tracker text box
function ohShi_SetUp()
    tb_create('ohShi')
    if settings ~= nil then
        tb_set_bg_color('ohShi',settings['bgalpha'],settings['bgred'],settings['bggreen'],settings['bgblue'])
        tb_set_bg_visibility('ohShi',true)
        tb_set_color('ohShi',255,settings['textred'],settings['textgreen'],settings['textblue'])
        tb_set_font('ohShi',settings['textfont'],settings['textsize'])
        tb_set_location('ohShi',settings['posx'],settings['posy'])
        tb_set_visibility('ohShi',true)
    end
    ohShi_Flash(' ohShi initialized. ')
end

--Flashes the ohShi text whenever you change a setting related to
--the textbox
function ohShi_Flash(str)
    str = str or ' ohShi settings updated. '
    local where = #tracking + 1
    tracking[where] = str
    ohShi_refresh()
    send_command('wait 2;ohShi timeout '..where)
    str = nil
end
--Function to refresh the list to keep it up to date.

function ohShi_refresh()
    local text = ''
    for inc = 1, #tracking do
        text = text..tracking[inc]
        if inc < #tracking then
            text = text..'\n'
        end
    end
    tb_set_text('ohShi',text)
end

--Clean up for when the addon is unloading
function ohShi_delete()
    notice('Closing and saving settings.')
    --settings = config.load(settings)
    if unloadtype == 'all' then
        settings:save('all')
    else
        settings:save()
    end
    local h
    if prims ~= nil then
        for h = 1, #prims do
            prim_delete(prims[h])
        end
    end
    tb_delete('ohShi')
    send_command('unalias ohShi')
end

--This function checks the string sent to it against your mob list
--returns true if it's found and false if not.
function mobcheck(tr)
    local category,names,inc
    for category,names in pairs(settings.moblist) do
        for inc = 1, #settings.moblist[category] do
            local beg,endi,cap = string.find(tr:lower(),'('..settings.moblist[category][inc]:lower()..')')
            if cap ~= nil then
                if category == 'dangerous' then
                    color2 = '\\cs(255,100,100)'
                    cres = '\\cr'
                    fi = true
                end
            return true
            end
        end
    end
    return false
end

--This function checks the string sent to it against your danger list
--returns true if it's found and false if not.
function dangercheck(ts)
    local category,names,inc
    for category,names in pairs(settings.dangerwords) do
        for inc = 1, #settings.dangerwords[category] do
            local beg,endi,cap = string.find(ts:lower(),'('..settings.dangerwords[category][inc]:lower()..')')
            if cap ~= nil then
                return true
            end
        end
    end
    return false
end

--This event happens when an action packet is received.
function event_action(act)
    local color2 = '' -- set the color back to 0 in case it carried over
    local cres = '' -- set reset back to 0 in case it carried over
    local fi = false
    local doanyway = 0
    --Make sure the stagger only mode isn't on
    if not settings.staggeronly then
        --Category 6 is job abilities. This portion of the function gets the
        --job ability name by taking the ja_id and checking it against the
        --job abilities table. After making sure the ability used is a cor roll
        --it puts the roll and total in the tracker.
        if act['category'] == 6 then
            if jobAbilities[tonumber(act['param'])]['type'] == 'CorsairRoll' then
                local party = get_party()
                local rolling = jobAbilities[tonumber(act['param'])]['english']
                local roller = get_mob_by_id(act['actor_id'])['name']
                local allyroller = false
                for pt,member in pairs(party) do
                    if member['name'] == roller then
                        allyroller = true
                        break
                    end
                end
                if allyroller then
                    local total = act['targets'][1]['actions'][1]['param']
                    tracking[#tracking+1] = ' '..roller..'\'s '..rolling..' Total: '..total..' '
                    ohShi_refresh()
                    send_command('wait '..settings['duration']..';ohShi timeout')
                end
            end
        end
        
        --Category 7 is weapon skill readying for players and npcs. The following
        --gets the ability id of the tp move being used and (after subtracting 256
        --due to it being offset, compares it against the abilities table. Then checks
        --it against your danger words and the user against your moblist.
        if act['category'] == 7 and isMob(tonumber(act['actor_id'])) then
            local num = tonumber(act['targets'][1]['actions'][1]['param']) - 256
            if num < 1 then return end
            local wesk = mobAbilities[num]['english']
            if dangercheck(wesk) then
                color2 = '\\cs(255,100,100)'
                cres = '\\cr'
                fi = true
                doanyway = 1
            end
            local mobName = get_mob_by_id(act['actor_id'])['name']
            if mobcheck(mobName) or doanyway == 1 then
                tracking[#tracking+1] = ' '..color2..mobName..' readies '..wesk..'.'..cres..' '
                ohShi_refresh()
                send_command('wait '..settings['duration']..';ohShi timeout')
                if fi then flashimage() end
            end
        end
        
        --Category 8 is spell casting
        if act['category'] == 8 and tonumber(act['targets'][1]['actions'][1]['message']) ~= 16 and isMob(tonumber(act['actor_id'])) then
            local num = tonumber(act['targets'][1]['actions'][1]['param'])
            if num <= 0 then return end
            --Get the name of the spell by taking the spell id and going through the spells table
            local spell = spells[num]['english']
            --Check spell against danger words.
            if dangercheck(spell) then
                color2 = '\\cs(255,100,100)'
                cres = '\\cr'
                fi = true
                doanyway = 1
            end
            --Getting mob's name and check it against your mob list.
            --And then if it checks out add it to the tracker.
            local mobName = get_mob_by_id(act['actor_id'])['name']
            if mobcheck(mobName) or doanyway == 1 then
                tracking[#tracking+1] = ' '..color2..mobName..' is casting '..spell..'.'..cres..' '
                ohShi_refresh()
                send_command('wait '..settings['duration']..';ohShi timeout')
                if fi then flashimage() end
            end
        end
        
        --This is used in tracking treasure hunter procs.
        if act['targets'][1]['actions'][1]['has_add_effect'] and isMob(tonumber(act['targets'][1]['id'])) then
            if act['targets'][1]['actions'][1]['add_effect_message'] == 603 then
                local thmob = get_mob_by_id(act['targets'][1]['id'])['name']
                local thlev = act['targets'][1]['actions'][1]['add_effect_param']
                tracking[#tracking+1] = ' '..thmob..'\'s Treasure Hunter:'..thlev..' '
                ohShi_refresh()
                send_command('wait '..settings['duration']..';ohShi timeout')
                if fi then flashimage() end
            end
        end
    end
end

--This event happens whenever text s incoming tot he chatlog
function event_incoming_text(old,new,color)
    --<mob> is no longer stunned.
    local start3,end3,mobname3,debuff1 = string.find(old,'([%w%s]+) is no longer (%w+)%p')
    --<mob> <gains/receives> the effect of <buff/debuff>
    local start4,end4,mobname4,gr,debuff2 = string.find(old,'([%w%s]+) (%w+) the effect of ([%w%s]+)')
    --<mob>'s <buff/debuff> effect wears off
    local start5,end5,mobname5,buff1 = string.find(old,'([%w%s]+)\'s (%w+) effect wears off%p')
    --<player>'s attack devastates the fiend
    local start6,end6,player1 = string.find(old,'(%w+)\'s attack devastates the fiend%p')
    --The following 3 are used for light tracking only blue/red are tracked
    local start7,end7,blue1,red1 = string.find(old,'Blue: (%d+)%% / Red: (%d+)%%')
    local start8,end8,blue2 = string.find(old,'Blue: (%d+)')
    local start9,end9,red2 = string.find(old,'Red: (%d+)')
    --This is for weakness tracking
    local starta3,enda3,type1,skill = string.find(old,'The fiend appears(.*)vulnerable to ([%w%s]+)!')
    text = ''
    color2 = ''
    cres = ''
    fi = false
    if not settings.staggeronly then
        if mobname3 ~= nil then
            if mobcheck(mobname3) then line = " "..mobname3..' is no longer '..debuff1..'. ' end
        end
        
        if mobname4 ~= nil then
            if mobcheck(mobname4) then line = " "..mobname4..' '..gr..' the effect of '..debuff2..'. ' end
        end
        
        if mobname5 ~= nil then
            if mobcheck(mobname5) then line = " "..mobname5..'\'s '..buff1..' effect wears off. ' end
        end
    end
    if blue2 ~= nil and blue1 == nil then
        line = " "..'Blue: '..blue2..'% '
    elseif red2 ~= nil and blue1 == nil then
        line = " "..'Red: '..red2..'% '
    elseif blue1 ~= nil then
        line = " "..'Blue: '..blue1..'% / Red: '..red1..'% '
    end
    
    if player1 ~= nil then
        line = " "..player1..'\'s attack devastates the fiend. '
    end
    
    if type1 ~= nil then
        if type1 == ' highly ' then
            color2 = '\\cs(255,100,100)'
            cres = '\\cr'
            type2 = ' 3!!!'
        elseif type1 == ' extremely ' then
            color2 = '\\cs(255,255,100)'
            cres = '\\cr'
            type2 = ' 5!!!!!'
        else
            color2 = '\\cs(255,255,255)'
            cres = '\\cr'
            type2 = ' 1!'
        end
        line = " "..color2..skill..type2..cres..' '
    end
    
    if line ~= nil then
        tracking[#tracking+1] = line
        ohShi_refresh()
        send_command('wait '..settings['duration']..';ohShi timeout')
        if fi then flashimage() end
    end
    color2 = nil
    cres = nil
    type2 = nil
    line = nil
    return new,color
end

--This function is used to flash the warning image
--when a danger tp/spell is used.
function flashimage()
    local name = 'ohShi'..tostring(math.random(10000000,99999999))
    prims[#prims+1] = name
    prim_create(name)
    prim_set_color(name,255,255,255,255)
    prim_set_fit_to_texture(name,false)
    prim_set_texture(name,lua_base_path..'data/warning.png')
    prim_set_repeat(name,1,1)
    prim_set_visibility(name,true)
    prim_set_position(name,settings['posx']-30,settings['posy']-10)
    prim_set_size(name,30,30)
    send_command('wait '..settings['duration']..';ohShi warnoff '..name)
end

--Check if the actor is actually an npc rather than a player
function isMob(id)
    return get_mob_by_id(id)['is_npc']
end

--This function is used to parse the windower resources
--to fill tables with ability/spell names/ids.
--Created by Byrth
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
                    if ind~='id' and ind~='index' then
                        completed_table[tonumber(key)][ind] = T{}
                        completed_table[tonumber(key)][ind] = val:gsub('&quot;','\42'):gsub('&apos;','\39')
                    end
                    q = b+1
                else
                    q = str:len()+1
                end
            end
            local k,v,english = string.find(str,'>([^<]+)</')
            if english~=nil then
                completed_table[tonumber(key)][ind] = T{}
                completed_table[tonumber(key)]['english']=english
            end
        end
    end
    return completed_table
end


--This function is only used to delete old unused settings files
function deleteoldsettings()
    local path = lua_base_path..'data/'
    local do1,err1 = os.remove(path..'ohshi-settings.xml')
    local do2,err2 = os.remove(path..'ohshi-moblist.xml')
    local do3,err3 = os.remove(path..'moblist.xml')
    if not do1 then end
    if not do2 then end
    if not do3 then end
end

--This function was made by Byrth. It's used to split strings
--at a specific character and store them in a table
function split(msg, match)
    if msg == nil then return '' end
    local length = msg:len()
    local splitarr = {}
    local u = 1
    while u <= length do
        local nextanch = msg:find(match,u)
        if nextanch ~= nil then
            splitarr[#splitarr+1] = msg:sub(u,nextanch-match:len())
            if nextanch~=length then
                u = nextanch+match:len()
            else
                u = length
            end
        else
            splitarr[#splitarr+1] = msg:sub(u,length)
            u = length+1
        end
    end
    return splitarr
end

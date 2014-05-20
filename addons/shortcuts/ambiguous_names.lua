--Copyright (c) 2013, Byrthnoth
--All rights reserved.
 
--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:
 
-- * Redistributions of source code must retain the above copyright
-- notice, this list of conditions and the following disclaimer.
-- * Redistributions in binary form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
-- * Neither the name of <addon name> nor the
-- names of its contributors may be used to endorse or promote products
-- derived from this software without specific prior written permission.
 
--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 
 
-- For handling ambiguous spells and abilities
 
function smn_unsub(player_array,IDs,info)
    local abils = windower.ffxi.get_abilities().job_abilities
    if player_array['main_job_id'] == 15 and abils[IDs.abil_ID] then
        return 'job_abilities'
    end
    return 'spells'
end
 
function smn_sub(player_array,IDs,info) -- Determines ambiguous black magic that can be subbed. Defaults to black magic
    local abils = windower.ffxi.get_abilities().job_abilities
    if player_array.main_job_id == 15 and not (info:contains(player_array.sub_job_id)) and abils[IDs.abil_ID] then
        return 'job_abilities' -- Returns the SMN ability if it's a SMN main without a sub that has access to the spell
    elseif (player_array.main_job_id == 15 and (info:contains(player_array.sub_job_id))) or (player_array.sub_job_id == 15 and (info:contains(player_array.main_job_id))) then
        local pet_array = windower.ffxi.get_mob_by_target('pet')
        local known_spells = windower.ffxi.get_spells()
        if not pet_array and known_spells[IDs.spell_ID] then return 'spells' end
        local recasts = windower.ffxi.get_ability_recasts().job_abilities
        if (info:contains(pet_array.name) and info:contains('Ward') and recasts[174]<=10) or (info:contains(pet_array.name) and info:contains('Rage') and recasts[173]<=10) then
            return 'job_abilities' -- Returns the SMN ability if it's a SMN main with an appropriate avatar summoned and the BP timer is up.
        else
            return 'spells'
        end
    end
    return 'spells' -- Returns a spell in every other case.
end

function blu_unsub(player_array,IDs,info) -- Determines ambiguous blue magic that cannot be subbed. Defaults to spells on BLU.
    local race = windower.ffxi.get_mob_by_id(player_array.id).race
    if IDs.mob_ID and race then
        if race == 0 then 
            return 'monster_abilities'
        end
    end
    local known_spells = windower.ffxi.get_spells()
    if player_array.main_job_id == 16 and IDs.spell_ID and known_spells[IDs.spell_ID] then -- and player_array['main_job_level'] >= info then
        return 'spells'
    end
    if IDs.ws_ID then
        return 'weapon_skills'
    end
    return 'job_abilities'
end

function abil_mob(player_array,IDs,info) -- Determines ambiguity between monster TP moves and abilities
    local race = windower.ffxi.get_mob_by_id(player_array.id).race
    if IDs.mob_ID and race then
        local abils = windower.ffxi.get_abilities().job_abilities
        local recasts = S(windower.ffxi.get_ability_recasts().job_abilities)
        if abils[IDs.abil_ID] and recasts[res.job_abilities[abil_ID].recast_id] <= 10 then
            return 'job_abilities'
        elseif race == 0 then
            return 'monster_abilities'
        end
    end
    return 'job_abilities'
end

function magic_mob(player_array,IDs,info) -- Determines ambiguity between monster TP moves and magic
    local race = windower.ffxi.get_mob_by_id(player_array.id).race
    if IDs.mob_ID and race then
        if race == 0 then 
            return 'monster_abilities'
        end
    end
    return 'spells'
end
 
function blu_sub(player_array,IDs,info) -- Determines ambiguous blue magic that can be subbed. Defaults to BST ability
    local race = windower.ffxi.get_mob_by_id(player_array.id).race
    if IDs.mob_ID and race then
        if race == 0 then 
            return 'monster_abilities'
        end
    end
    local abils = windower.ffxi.get_abilities().job_abilities
    if player_array['main_job_id'] == 9 and player_array['sub_job_id'] ~= 16 then
        return 'job_abilities' -- Returns the BST ability if it's BST/not-BLU using the spell
    elseif player_array['main_job_id'] == 9 and player_array['sub_job_id'] == 16 and abils[IDs.abil_ID] then
        local recasts = windower.ffxi.get_ability_recasts().job_abilities
        if pet_array.tp >= 100 and recasts[255] <= 5400 then -- If your pet has TP and Ready's recast is less than 1.5 minutes
            return 'job_abilities'
        else
            return 'spells'
        end
    end
    return 'spells'
end
 
 
ambig_names = {
sleepgaii={absolute=true,spell_ID=274},
darkarts={absolute=true,abil_ID=232},
slowga={absolute=true,abil_ID=580},
hastega={absolute=true,abil_ID=595},
slice={absolute=true,ws_ID=96},
netherspikes={absolute=true,ws_ID=241},
carnalnightmare={absolute=true,ws_ID=242},
aegisschism={absolute=true,ws_ID=243},
dancingchains={absolute=true,ws_ID=244},
photosynthesis={absolute=true,mob_ID=324},
petribreath={absolute=true,mob_ID=269},
epoxyspread={absolute=true,mob_ID=1319},
mucusspread={absolute=true,mob_ID=1317},
fluidspread={absolute=true,mob_ID=431},
fluidtoss={absolute=true,mob_ID=432},
balefulgaze={absolute=true,mob_ID=370},

fireiv={{spell_ID=147,abil_ID=549},funct=smn_unsub,info=60},
stoneiv={{spell_ID=162,abil_ID=565},funct=smn_unsub,info=60},
wateriv={{spell_ID=172,abil_ID=581},funct=smn_unsub,info=60},
aeroiv={{spell_ID=157,abil_ID=597},funct=smn_unsub,info=60},
blizzardiv={{spell_ID=152,abil_ID=613},funct=smn_unsub,info=60},
thunderiv={{spell_ID=167,abil_ID=629},funct=smn_unsub,info=60},
thunderstorm={{spell_ID=117,abil_ID=631},funct=smn_unsub,info=75},
 
dreamflower={{spell_ID=678,abil_ID=676,mob_ID=301},funct=blu_unsub,info=87},
frostbreath={{spell_ID=608,abil_ID=647,mob_ID=377},funct=blu_unsub,info=66},
infrasonics={{spell_ID=610,abil_ID=687,mob_ID=372},funct=blu_unsub,info=65},
mneedles={{spell_ID=595,abil_ID=699,mob_ID=322},funct=blu_unsub,info=62},
filamentedhold={{spell_ID=548,abil_ID=729,mob_ID=364},funct=blu_unsub,info=52},
suddenlunge={{spell_ID=692,abil_ID=736,mob_ID=2178},funct=blu_unsub,info=95},
spiralspin={{spell_ID=652,abil_ID=737,mob_ID=2181},funct=blu_unsub,info=60},
chargedwhisker={{spell_ID=680,abil_ID=746},mob_ID=483,funct=blu_unsub,info=88},
corrosiveooze={{spell_ID=651,abil_ID=748},funct=blu_unsub,info=66},
fantod={{spell_ID=674,abil_ID=752},funct=blu_unsub,info=85},
hardenshell={{spell_ID=737,abil_ID=754,mob_ID=807},funct=blu_unsub,info=95},
barbedcrescent={{spell_ID=699,ws_ID=245},funct=blu_unsub,99,info=99},
dimensionaldeath={{spell_ID=589,ws_ID=255},funct=blu_unsub,info=60},
 
footkick={{spell_ID=577,abil_ID=672,mob_ID=257},funct=blu_sub},
headbutt={{spell_ID=623,abil_ID=675,mob_ID=300},funct=blu_sub},
queasyshroom={{spell_ID=599,abil_ID=702,mob_ID=310},funct=blu_sub},
sheepsong={{spell_ID=584,abil_ID=692,mob_ID=264},funct=blu_sub},
wildoats={{spell_ID=603,abil_ID=677,mob_ID=302},funct=blu_sub},
clawcyclone={{spell_ID=522,abil_ID=682,mob_ID=273},funct=blu_sub},
metallicbody={{spell_ID=637,abil_ID=697},funct=blu_sub},
powerattack={{spell_ID=551,abil_ID=707,mob_ID=338},funct=blu_sub},
cursedsphere={{spell_ID=544,abil_ID=712,mob_ID=659},funct=blu_sub},
mandibularbite={{spell_ID=543,abil_ID=717,mob_ID=279},funct=blu_sub},
soporific={{spell_ID=598,abil_ID=718,mob_ID=434},funct=blu_sub},
geistwall={{spell_ID=605,abil_ID=721,mob_ID=516},funct=blu_sub},
chaoticeye={{spell_ID=582,abil_ID=730,mob_ID=653},funct=blu_sub},
wildcarrot={{spell_ID=578,abil_ID=735,mob_ID=323},funct=blu_sub},
jettatura={{spell_ID=575,abil_ID=750},funct=blu_sub},

dustcloud={{abil_ID=673,mob_ID=258},funct=abil_mob},
whirlclaws={{abil_ID=674,mob_ID=259},funct=abil_mob},
lambchop={{abil_ID=689,mob_ID=260},funct=abil_mob},
rage={{abil_ID=690,mob_ID=261},funct=abil_mob},
sheepcharge={{abil_ID=691,mob_ID=262},funct=abil_mob},
roar={{abil_ID=680,mob_ID=270},funct=abil_mob},
razorfang={{abil_ID=681,mob_ID=271},funct=abil_mob},
sandblast={{abil_ID=714,mob_ID=275},funct=abil_mob},
sandpit={{abil_ID=715,mob_ID=276},funct=abil_mob},
venomspray={{abil_ID=716,mob_ID=277},funct=abil_mob},
berserk={{abil_ID=31,mob_ID=286},funct=abil_mob,info=true},
leafdagger={{abil_ID=678,mob_ID=305},funct=abil_mob},
scream={{abil_ID=679,mob_ID=306},funct=abil_mob},
frogkick={{abil_ID=700,mob_ID=308},funct=abil_mob},
spore={{abil_ID=701,mob_ID=309},funct=abil_mob},
numbshroom={{abil_ID=703,mob_ID=311},funct=abil_mob},
shakeshroom={{abil_ID=704,mob_ID=312},funct=abil_mob},
silencegas={{abil_ID=705,mob_ID=314},funct=abil_mob},
darkspore={{abil_ID=706,mob_ID=315},funct=abil_mob},
needleshot={{abil_ID=698,mob_ID=321},funct=abil_mob},
hifreqfield={{abil_ID=708,mob_ID=339},funct=abil_mob},
rhinoattack={{abil_ID=109,mob_ID=340},funct=abil_mob},
rhinoguard={{abil_ID=710,mob_ID=341},funct=abil_mob},
spoil={{abil_ID=711,mob_ID=343},funct=abil_mob},
doubleclaw={{abil_ID=726,mob_ID=362},funct=abil_mob},
grapple={{abil_ID=727,mob_ID=363},funct=abil_mob},
spinningtop={{abil_ID=728,mob_ID=365},funct=abil_mob},
tailblow={{abil_ID=683,mob_ID=366},funct=abil_mob},
fireball={{abil_ID=684,mob_ID=367},funct=abil_mob},
blockhead={{abil_ID=685,mob_ID=368},funct=abil_mob},
braincrush={{abil_ID=686,mob_ID=369},funct=abil_mob},
secretion={{abil_ID=688,mob_ID=371},funct=abil_mob},
ripperfang={{abil_ID=744,mob_ID=372},funct=abil_mob},
chomprush={{abil_ID=745,mob_ID=379},funct=abil_mob},
scythetail={{abil_ID=743,mob_ID=380},funct=abil_mob},
palsypollen={{abil_ID=720,mob_ID=435},funct=abil_mob},
gloeosuccus={{abil_ID=719,mob_ID=436},funct=abil_mob},
toxicspit={{abil_ID=725,mob_ID=515},funct=abil_mob},
numbingnoise={{abil_ID=722,mob_ID=517},funct=abil_mob},
nimblesnap={{abil_ID=723,mob_ID=518},funct=abil_mob},
cyclotail={{abil_ID=724,mob_ID=519},funct=abil_mob},
shockwave={{abil_ID=820,mob_ID=631},funct=abil_mob},
blaster={{abil_ID=731,mob_ID=652},funct=abil_mob},
venom={{abil_ID=713,mob_ID=660},funct=abil_mob},
snowcloud={{abil_ID=734,mob_ID=661},funct=abil_mob},
tortoisestomp={{abil_ID=753,mob_ID=806},funct=abil_mob},
aquabreath={{abil_ID=755,mob_ID=809},funct=abil_mob},
noisomepowder={{abil_ID=738,mob_ID=2179},funct=abil_mob},
sensillablades={{abil_ID=761,mob_ID=2946},funct=abil_mob},
tegminabuffet={{abil_ID=762,mob_ID=2947},funct=abil_mob},
wingslap={{abil_ID=756,mob_ID=1714},funct=abil_mob},
beaklunge={{abil_ID=757,mob_ID=1715},funct=abil_mob},
scissorguard={{abil_ID=696,mob_ID=445},funct=abil_mob},
intimidate={{abil_ID=758,mob_ID=449},funct=abil_mob},
recoildive={{abil_ID=759,mob_ID=641},funct=abil_mob},
purulentooze={{abil_ID=747,mob_ID=2184},funct=abil_mob},
waterwall={{abil_ID=760,mob_ID=453},funct=abil_mob},
suction={{abil_ID=732,mob_ID=414},funct=abil_mob},
acidmist={{abil_ID=740,mob_ID=415},funct=abil_mob},
sandbreath={{abil_ID=649,mob_ID=416},funct=abil_mob},
drainkiss={{abil_ID=733,mob_ID=417},funct=abil_mob},
tpdrainkiss={{abil_ID=741,mob_ID=420},funct=abil_mob},
bigscissors={{abil_ID=695,mob_ID=444},funct=abil_mob},
bubbleshower={{abil_ID=693,mob_ID=442},funct=abil_mob},
bubblecurtain={{abil_ID=694,mob_ID=443},funct=abil_mob},
chokebreath={{abil_ID=751,mob_ID=579},funct=abil_mob},
backheel={{abil_ID=749,mob_ID=519},funct=abil_mob},

ramcharge={{spell_ID=585,mob_ID=266},funct=magic_mob},
healingbreeze={{spell_ID=581,mob_ID=287},funct=magic_mob},
blankgaze={{spell_ID=592,mob_ID=292},funct=magic_mob},
magicfruit={{spell_ID=593,mob_ID=295},funct=magic_mob},
pineconebomb={{spell_ID=596,mob_ID=297},funct=magic_mob},
leafstorm={{spell_ID=663,mob_ID=298},funct=magic_mob},
badbreath={{spell_ID=604,mob_ID=319},funct=magic_mob},
pollen={{spell_ID=549,mob_ID=335},funct=magic_mob},
finalsting={{spell_ID=665,mob_ID=336},funct=magic_mob},
poisonbreath={{spell_ID=536,mob_ID=345},funct=magic_mob},
cocoon={{spell_ID=547,mob_ID=346},funct=magic_mob},
deathscissors={{spell_ID=554,mob_ID=353},funct=magic_mob},
thunderbolt={{spell_ID=736,mob_ID=378},funct=magic_mob},
awfuleye={{spell_ID=606,mob_ID=386},funct=magic_mob},
lowing={{spell_ID=588,mob_ID=497},funct=magic_mob},
uppercut={{spell_ID=594,mob_ID=584},funct=magic_mob},
sproutsmack={{spell_ID=597,mob_ID=687},funct=magic_mob},
heatbreath={{spell_ID=591,mob_ID=800},funct=magic_mob},
sickleslash={{spell_ID=545,mob_ID=810},funct=magic_mob},
barriertusk={{spell_ID=685,mob_ID=1703},funct=magic_mob},
voracioustrunk={{spell_ID=579,mob_ID=1707},funct=magic_mob},
gatesofhades={{spell_ID=739,mob_ID=1790},funct=magic_mob},
thermalpulse={{spell_ID=675,mob_ID=1817},funct=magic_mob},
cannonball={{spell_ID=643,mob_ID=1818},funct=magic_mob},
exuviation={{spell_ID=645,mob_ID=1955},funct=magic_mob},
demoralizingroar={{spell_ID=659,mob_ID=2101},funct=magic_mob},
regurgitation={{spell_ID=648,mob_ID=2153},funct=magic_mob},
deltathrust={{spell_ID=682,mob_ID=2154},funct=magic_mob},
cimicinedischarge={{spell_ID=660,mob_ID=2161},funct=magic_mob},
seedspray={{spell_ID=650,mob_ID=2163},funct=magic_mob},
pleniluneembrace={{spell_ID=658,mob_ID=2173},funct=magic_mob},
asuranclaws={{spell_ID=653,mob_ID=2176},funct=magic_mob},


feathertickle={{spell_ID=573,mob_ID=1701},funct=magic_mob},
yawn={{spell_ID=576,mob_ID=1713},funct=magic_mob},
maelstrom={{spell_ID=515,mob_ID=462},funct=magic_mob},
reavingwind={{spell_ID=684,mob_ID=2431},funct=magic_mob},
digest={{spell_ID=542,mob_ID=433},funct=magic_mob},
amplification={{spell_ID=642,mob_ID=1821},funct=magic_mob},
helldive={{spell_ID=567,mob_ID=622},funct=magic_mob},
featherbarrier={{spell_ID=574,mob_ID=402},funct=magic_mob},
deathray={{spell_ID=522,mob_ID=437},funct=magic_mob},
soundblast={{spell_ID=572,mob_ID=410},funct=magic_mob},
foulwaters={{spell_ID=705,mob_ID=2974},funct=magic_mob},
retinalglare={{spell_ID=707,mob_ID=3030},funct=magic_mob},
venomshell={{spell_ID=513,mob_ID=505},funct=magic_mob},
amorphicspikes={{spell_ID=697,mob_ID=1824},funct=magic_mob},
screwdriver={{spell_ID=519,mob_ID=452},funct=magic_mob},
meteor={{spell_ID=218,mob_ID=634},funct=magic_mob},
blooddrain={{spell_ID=570,mob_ID=394},funct=magic_mob},
jetstream={{spell_ID=569,mob_ID=395},funct=magic_mob},
regeneration={{spell_ID=664,mob_ID=418},funct=magic_mob},
mpdrainkiss={{spell_ID=521,mob_ID=421},funct=magic_mob},
natmeditation={{spell_ID=700,mob_ID=2945},funct=magic_mob},



 
raiseii={{spell_ID=13,abil_ID=525},funct=smn_sub,info=T{4,'Cait Sith','Ward'}},
reraiseii={{spell_ID=141,abil_ID=526},funct=smn_sub,info=T{4,'Cait Sith','Ward'}},
sleepga={{spell_ID=273,abil_ID=611},funct=smn_sub,info=T{4,'Shiva','Ward'}},
stoneii={{spell_ID=160,abil_ID=561},funct=smn_sub,info=T{4,5,8,20,21,'Titan','Rage'}},
waterii={{spell_ID=170,abil_ID=577},funct=smn_sub,info=T{4,5,8,20,21,'Leviathan','Rage'}},
fireii={{spell_ID=145,abil_ID=545},funct=smn_sub,info=T{4,5,8,20,21,'Ifrit','Rage'}},
aeroii={{spell_ID=155,abil_ID=593},funct=smn_sub,info=T{4,5,8,20,21,'Garuda','Rage'}},
blizzardii={{spell_ID=150,abil_ID=609},funct=smn_sub,info=T{4,5,8,20,21,'Shiva','Rage'}},
thunderii={{spell_ID=165,abil_ID=625},funct=smn_sub,info=T{4,5,8,20,21,'Ramuh','Rage'}}
}
 
function ambig(key)
    local abil_type
    if ambig_names[key] == nil then -- If there is no entry for the ambiguous command...
        print('Shortcuts Bug: '..tostring(key))
        return
    end
    
    local commands = get_available_commands()
    local slugged_commands = make_slugged_command_list(commands)
    
    if slugged_commands[key] and slugged_commands[key].type ~= 'Ambiguous' then 
    -- If the current usage is unambiguous because only one ability is available then...
        if slugged_commands[key].type == 'spells' then
            return commands.magic[slugged_commands[key].id],slugged_commands[key].type
        else
            return commands.abilities[slugged_commands[key].id],slugged_commands[key].type
        end
    else  -- Otherwise it's actually ambiguous, so run the associated function and pass the known information.
        abil_type=ambig_names[key]['funct'](windower.ffxi.get_player(),ambig_names[key].spell_ID,ambig_names[key].abil_ID,ambig_names[key].mob_ID,ambig_names[key].info,ambig_names[key].mob_ID)
        if abil_type == 'job_abilities' then
            return res.abilities[ambig_names[key].abil_ID],abil_type
        elseif abil_type == 'spells' then
            return res.spells[ambig_names[key].spell_ID],abil_type
        elseif abil_type == 'monster_abilities' then
--            if res.abilities[ambig_names[key].mob_ID].prefix ~= '/monsterskill' then res.abilities[ambig_names[key].mob_ID].prefix = '/monsterskill' end
            return res.abilities[ambig_names[key].mob_ID],abil_type
        end
    end
    return '',''
end



-----------------------------------------------------------------------------------
--Name: get_available_commands()
--Args:
---- none
-----------------------------------------------------------------------------------
--Returns:
---- A table containing the currently available command names
-----------------------------------------------------------------------------------
function get_available_commands()
    local player = windower.ffxi.get_player()
    local valid_abilities = {spells = {},abilities = {}}
    if not player then return valid_abilities end
    
    for i,v in pairs(windower.ffxi.get_spells()) do
        if v and ((res.spells[i].levels[player.main_job_id] and res.spells[i].levels[player.main_job_id] <= player.main_job_level) or (res.spells[i].levels[player.sub_job_id] and res.spells[i].levels[player.sub_job_id] <= player.sub_job_level)) then
            valid_abilities.spells[i] = res.spells[i]
        end
    end
    
    for typ,tab in pairs(windower.ffxi.get_abilities()) do
        if tab then
            for _,id in pairs(tab) do
                valid_abilities[typ][ind] = tab[ind]
            end
        end
    end
    
    local mjob = windower.ffxi.get_mjob_data()
    if mjob and mjob.species_id and res.monstrosity[mjob.species_id] then
        for i,v in pairs(res.monstrosity[mjob.species_id].tp_moves) do
            if player.main_job_level >= v then
                valid_abilities.monster_abilities[i] = res.monster_abilities[i]
            end
        end
    end
    return valid_abilities
end



-----------------------------------------------------------------------------------
--Name: make_slugged_command_list(commands)
--Args:
---- commands : a table generated by get_available_commands()
-----------------------------------------------------------------------------------
--Returns:
---- A table mapping the currently available command names to their IDs
-----------------------------------------------------------------------------------
function make_slugged_command_list(commands)
    local slugged_commands = {}
    for i,v in pairs(commands.abilities) do
        if slugged_commands[stripped] then
            slugged_commands[stripped] = {type='Ambiguous'}
        elseif i < 1024 then
            slugged_commands[strip(v[language])] = {type='job_abilities',id=i}
        else
            slugged_commands[strip(v[language])] = {type='monster_abilities',id=i}
        end
    end
    for i,v in pairs(commands.magic) do
        local stripped = strip(v[language])
        if slugged_commands[stripped] then
            slugged_commands[stripped] = {type='Ambiguous'}
        else
            slugged_commands[stripped] = {type='spells',id=i}
        end
    end
    return slugged_commands
end





if logging then -- Prints out unhandled ambiguous cases, sort of a pre-emptive line 260 warning.
    f = io.open('../addons/shortcuts/data/'..tostring(os.clock())..'_unhandled_duplicates.log','w+')
    
    for i,v in pairs(validabils) do
        if v.typ == 'ambig_names' then
            if ambig_names[i] == nil then
                f:write(tostring(i)..'\n\n')
            end
        end
    end
    f:close()
end
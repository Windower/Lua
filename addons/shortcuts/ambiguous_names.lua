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
 
function smn_unsub(player_array,spell_ID,abil_ID,mob_ID,info)
    local abils = windower.ffxi.get_abilities()
    if player_array['main_job_id'] == 15 and abils[abil_ID] then --and player_array['main_job_level'] >= info and windower.ffxi.get_mob_by_target('pet') then
        return 'Ability'
    end
    return 'Magic'
end
 
function smn_sub(player_array,spell_ID,abil_ID,mob_ID,info) -- Determines ambiguous black magic that can be subbed. Defaults to black magic
    local abils = windower.ffxi.get_abilities()
    if player_array.main_job_id == 15 and not (info:contains(player_array.sub_job_id)) and abils[abil_ID] then
        return 'Ability' -- Returns the SMN ability if it's a SMN main without a sub that has access to the spell
    elseif (player_array.main_job_id == 15 and (info:contains(player_array.sub_job_id))) or (player_array.sub_job_id == 15 and (info:contains(player_array.main_job_id))) then
        local pet_array = windower.ffxi.get_mob_by_target('pet')
        local known_spells = windower.ffxi.get_spells()
        if not pet_array and known_spells[spell_ID] then return 'Magic' end
        local recasts = windower.ffxi.get_ability_recasts()
        if (info:contains(pet_array.name) and info:contains('Ward') and recasts[174]<=10) or (info:contains(pet_array.name) and info:contains('Rage') and recasts[173]<=10) then
            return 'Ability' -- Returns the SMN ability if it's a SMN main with an appropriate avatar summoned and the BP timer is up.
        else
            return 'Magic'
        end
    end
    return 'Magic' -- Returns a spell in every other case.
end

function blu_unsub(player_array,spell_ID,abil_ID,mob_ID,info) -- Determines ambiguous blue magic that cannot be subbed. Defaults to spells on BLU.
    local race = windower.ffxi.get_mob_by_id(player_array.id).race
    if mob_ID and race then
        if race == 0 then 
            return 'Monster'
        end
    end
    local known_spells = windower.ffxi.get_spells()
    if player_array.main_job_id == 16 and spell_ID and known_spells[spell_ID] then -- and player_array['main_job_level'] >= info then
        return 'Magic'
    end
    return 'Ability'
end

function abil_mob(player_array,spell_ID,abil_ID,mob_ID,info) -- Determines ambiguity between monster TP moves and abilities
    local race = windower.ffxi.get_mob_by_id(player_array.id).race
    if mob_ID and race then
        local abils = windower.ffxi.get_abilities()
        local recasts = windower.ffxi.get_ability_recasts()
        if abils[abil_ID] and recasts[res.abilities[abil_ID].recast_id] <= 10 then
            return 'Ability'
        elseif race == 0 then
            return 'Monster'
        end
    end
    return 'Ability'
end

function magic_mob(player_array,spell_ID,abil_ID,mob_ID,info) -- Determines ambiguity between monster TP moves and magic
    local race = windower.ffxi.get_mob_by_id(player_array.id).race
    if mob_ID and race then
        if race == 0 then 
            return 'Monster'
        end
    end
    return 'Magic'
end
 
function blu_sub(player_array,spell_ID,abil_ID,mob_ID,info) -- Determines ambiguous blue magic that can be subbed. Defaults to BST ability
    local race = windower.ffxi.get_mob_by_id(player_array.id).race
    if mob_ID and race then
        if race == 0 then 
            return 'Monster'
        end
    end
    local abils = windower.ffxi.get_abilities()
    if player_array['main_job_id'] == 9 and player_array['sub_job_id'] ~= 16 then
        return 'Ability' -- Returns the BST ability if it's BST/not-BLU using the spell
    elseif player_array['main_job_id'] == 9 and player_array['sub_job_id'] == 16 and abils[abil_ID] then
        local recasts = windower.ffxi.get_ability_recasts()
        if pet_array.tp >= 100 and recasts[255] <= 5400 then -- If your pet has TP and Ready's recast is less than 1.5 minutes
            return 'Ability'
        else
            return 'Magic'
        end
    end
    return 'Magic'
end
 
 
ambig_names = {
sleepgaii={absolute=true,spell_ID=274},
darkarts={absolute=true,abil_ID=232},
slowga={absolute=true,abil_ID=580},
hastega={absolute=true,abil_ID=595},
slice={absolute=true,abil_ID=864},
netherspikes={absolute=true,abil_ID=1009},
carnalnightmare={absolute=true,abil_ID=1010},
aegisschism={absolute=true,abil_ID=1011},
dancingchains={absolute=true,abil_ID=1012},
photosynthesis={absolute=true,mob_ID=1092},
petribreath={absolute=true,mob_ID=1037},
epoxyspread={absolute=true,mob_ID=2087},
mucusspread={absolute=true,mob_ID=2085},
fluidspread={absolute=true,mob_ID=1199},
fluidtoss={absolute=true,mob_ID=1200},
balefulgaze={absolute=true,mob_ID=1138},

fireiv={spell_ID=147,abil_ID=549,funct=smn_unsub,info=60},
stoneiv={spell_ID=162,abil_ID=565,funct=smn_unsub,info=60},
wateriv={spell_ID=172,abil_ID=581,funct=smn_unsub,info=60},
aeroiv={spell_ID=157,abil_ID=597,funct=smn_unsub,info=60},
blizzardiv={spell_ID=152,abil_ID=613,funct=smn_unsub,info=60},
thunderiv={spell_ID=167,abil_ID=629,funct=smn_unsub,info=60},
thunderstorm={spell_ID=117,abil_ID=631,funct=smn_unsub,info=75},
 
dreamflower={spell_ID=678,abil_ID=676,mob_ID=1069,funct=blu_unsub,info=87},
frostbreath={spell_ID=608,abil_ID=647,mob_ID=1145,funct=blu_unsub,info=66},
infrasonics={spell_ID=610,abil_ID=687,mob_ID=1140,funct=blu_unsub,info=65},
mneedles={spell_ID=595,abil_ID=699,mob_ID=1090,funct=blu_unsub,info=62},
filamentedhold={spell_ID=548,abil_ID=729,mob_ID=1132,funct=blu_unsub,info=52},
suddenlunge={spell_ID=692,abil_ID=736,mob_ID=2946,funct=blu_unsub,info=95},
spiralspin={spell_ID=652,abil_ID=737,mob_ID=2949,funct=blu_unsub,info=60},
chargedwhisker={spell_ID=680,abil_ID=746,mob_ID=1251,funct=blu_unsub,info=88},
corrosiveooze={spell_ID=651,abil_ID=748,funct=blu_unsub,info=66},
fantod={spell_ID=674,abil_ID=752,funct=blu_unsub,info=85},
hardenshell={spell_ID=737,abil_ID=754,mob_ID=1575,funct=blu_unsub,info=95},
barbedcrescent={spell_ID=699,abil_ID=1013,funct=blu_unsub,99,info=99},
dimensionaldeath={spell_ID=589,abil_ID=1023,funct=blu_unsub,info=60},
 
footkick={spell_ID=577,abil_ID=672,mob_ID=1025,funct=blu_sub},
headbutt={spell_ID=623,abil_ID=675,mob_ID=1068,funct=blu_sub},
queasyshroom={spell_ID=599,abil_ID=702,mob_ID=1078,funct=blu_sub},
sheepsong={spell_ID=584,abil_ID=692,mob_ID=1032,funct=blu_sub},
wildoats={spell_ID=603,abil_ID=677,mob_ID=1070,funct=blu_sub},
clawcyclone={spell_ID=522,abil_ID=682,mob_ID=1041,funct=blu_sub},
metallicbody={spell_ID=637,abil_ID=697,funct=blu_sub},
powerattack={spell_ID=551,abil_ID=707,mob_ID=1106,funct=blu_sub},
cursedsphere={spell_ID=544,abil_ID=712,mob_ID=1427,funct=blu_sub},
mandibularbite={spell_ID=543,abil_ID=717,mob_ID=1047,funct=blu_sub},
soporific={spell_ID=598,abil_ID=718,mob_ID=1202,funct=blu_sub},
geistwall={spell_ID=605,abil_ID=721,mob_ID=1284,funct=blu_sub},
chaoticeye={spell_ID=582,abil_ID=730,mob_ID=1421,funct=blu_sub},
wildcarrot={spell_ID=578,abil_ID=735,mob_ID=1091,funct=blu_sub},
jettatura={spell_ID=575,abil_ID=750,funct=blu_sub},

rage={abil_ID=690,mob_ID=1029,funct=abil_mob},
dustcloud={abil_ID=673,mob_ID=1026,funct=abil_mob},
whirlclaws={abil_ID=674,mob_ID=1027,funct=abil_mob},
lambchop={abil_ID=689,mob_ID=1028,funct=abil_mob},
sheepcharge={abil_ID=691,mob_ID=1030,funct=abil_mob},
roar={abil_ID=680,mob_ID=1038,funct=abil_mob},
razorfang={abil_ID=681,mob_ID=1039,funct=abil_mob},
sandblast={abil_ID=714,mob_ID=1043,funct=abil_mob},
sandpit={abil_ID=715,mob_ID=1044,funct=abil_mob},
venomspray={abil_ID=716,mob_ID=1045,funct=abil_mob},
berserk={abil_ID=31,mob_ID=1054,funct=abil_mob,info=true},
leafdagger={abil_ID=678,mob_ID=1073,funct=abil_mob},
scream={abil_ID=679,mob_ID=1074,funct=abil_mob},
frogkick={abil_ID=700,mob_ID=1076,funct=abil_mob},
spore={abil_ID=701,mob_ID=1077,funct=abil_mob},
numbshroom={abil_ID=703,mob_ID=1079,funct=abil_mob},
shakeshroom={abil_ID=704,mob_ID=1080,funct=abil_mob},
silencegas={abil_ID=705,mob_ID=1082,funct=abil_mob},
darkspore={abil_ID=706,mob_ID=1083,funct=abil_mob},
needleshot={abil_ID=698,mob_ID=1089,funct=abil_mob},
hifreqfield={abil_ID=708,mob_ID=1107,funct=abil_mob},
rhinoattack={abil_ID=109,mob_ID=1108,funct=abil_mob},
rhinoguard={abil_ID=710,mob_ID=1109,funct=abil_mob},
spoil={abil_ID=711,mob_ID=1111,funct=abil_mob},
doubleclaw={abil_ID=726,mob_ID=1130,funct=abil_mob},
grapple={abil_ID=727,mob_ID=1131,funct=abil_mob},
spinningtop={abil_ID=728,mob_ID=1133,funct=abil_mob},
tailblow={abil_ID=683,mob_ID=1134,funct=abil_mob},
fireball={abil_ID=684,mob_ID=1135,funct=abil_mob},
blockhead={abil_ID=685,mob_ID=1136,funct=abil_mob},
braincrush={abil_ID=686,mob_ID=1137,funct=abil_mob},
secretion={abil_ID=688,mob_ID=1141,funct=abil_mob},
ripperfang={abil_ID=744,mob_ID=1142,funct=abil_mob},
chomprush={abil_ID=745,mob_ID=1147,funct=abil_mob},
scythetail={abil_ID=743,mob_ID=1148,funct=abil_mob},
palsypollen={abil_ID=720,mob_ID=1203,funct=abil_mob},
gloeosuccus={abil_ID=719,mob_ID=1204,funct=abil_mob},
toxicspit={abil_ID=725,mob_ID=1283,funct=abil_mob},
numbingnoise={abil_ID=722,mob_ID=1285,funct=abil_mob},
nimblesnap={abil_ID=723,mob_ID=1286,funct=abil_mob},
cyclotail={abil_ID=724,mob_ID=1287,funct=abil_mob},
shockwave={abil_ID=820,mob_ID=1399,funct=abil_mob},
blaster={abil_ID=731,mob_ID=1420,funct=abil_mob},
venom={abil_ID=713,mob_ID=1428,funct=abil_mob},
snowcloud={abil_ID=734,mob_ID=1429,funct=abil_mob},
tortoisestomp={abil_ID=753,mob_ID=1574,funct=abil_mob},
aquabreath={abil_ID=755,mob_ID=1577,funct=abil_mob},
noisomepowder={abil_ID=738,mob_ID=2947,funct=abil_mob},
sensillablades={abil_ID=761,mob_ID=3714,funct=abil_mob},
tegminabuffet={abil_ID=762,mob_ID=3715,funct=abil_mob},
wingslap={abil_ID=756,mob_ID=2482,funct=abil_mob},
beaklunge={abil_ID=757,mob_ID=2483,funct=abil_mob},
scissorguard={abil_ID=696,mob_ID=1213,funct=abil_mob},
intimidate={abil_ID=758,mob_ID=1217,funct=abil_mob},
recoildive={abil_ID=759,mob_ID=1409,funct=abil_mob},
purulentooze={abil_ID=747,mob_ID=2952,funct=abil_mob},
waterwall={abil_ID=760,mob_ID=1221,funct=abil_mob},
suction={abil_ID=732,mob_ID=1182,funct=abil_mob},
acidmist={abil_ID=740,mob_ID=1183,funct=abil_mob},
sandbreath={abil_ID=649,mob_ID=1184,funct=abil_mob},
drainkiss={abil_ID=733,mob_ID=1185,funct=abil_mob},
tpdrainkiss={abil_ID=741,mob_ID=1188,funct=abil_mob},
bigscissors={abil_ID=695,mob_ID=1212,funct=abil_mob},
bubbleshower={abil_ID=693,mob_ID=1210,funct=abil_mob},
bubblecurtain={abil_ID=694,mob_ID=1211,funct=abil_mob},
chokebreath={abil_ID=751,mob_ID=1347,funct=abil_mob},
backheel={abil_ID=749,mob_ID=1287,funct=abil_mob},
bubblecurtain={abil_ID=694,mob_ID=1211,funct=abil_mob},

ramcharge={spell_ID=585,mob_ID=1034,funct=magic_mob},
healingbreeze={spell_ID=581,mob_ID=1055,funct=magic_mob},
blankgaze={spell_ID=592,mob_ID=1060,funct=magic_mob},
magicfruit={spell_ID=593,mob_ID=1063,funct=magic_mob},
pineconebomb={spell_ID=596,mob_ID=1065,funct=magic_mob},
leafstorm={spell_ID=663,mob_ID=1066,funct=magic_mob},
badbreath={spell_ID=604,mob_ID=1087,funct=magic_mob},
pollen={spell_ID=549,mob_ID=1103,funct=magic_mob},
finalsting={spell_ID=665,mob_ID=1104,funct=magic_mob},
poisonbreath={spell_ID=536,mob_ID=1113,funct=magic_mob},
cocoon={spell_ID=547,mob_ID=1114,funct=magic_mob},
deathscissors={spell_ID=554,mob_ID=1121,funct=magic_mob},
thunderbolt={spell_ID=736,mob_ID=1146,funct=magic_mob},
awfuleye={spell_ID=606,mob_ID=1154,funct=magic_mob},
lowing={spell_ID=588,mob_ID=1265,funct=magic_mob},
uppercut={spell_ID=594,mob_ID=1352,funct=magic_mob},
sproutsmack={spell_ID=597,mob_ID=1455,funct=magic_mob},
heatbreath={spell_ID=591,mob_ID=1568,funct=magic_mob},
sickleslash={spell_ID=545,mob_ID=1578,funct=magic_mob},
barriertusk={spell_ID=685,mob_ID=2471,funct=magic_mob},
voracioustrunk={spell_ID=579,mob_ID=2475,funct=magic_mob},
gatesofhades={spell_ID=739,mob_ID=2558,funct=magic_mob},
thermalpulse={spell_ID=675,mob_ID=2585,funct=magic_mob},
cannonball={spell_ID=643,mob_ID=2586,funct=magic_mob},
exuviation={spell_ID=645,mob_ID=2723,funct=magic_mob},
demoralizingroar={spell_ID=659,mob_ID=2869,funct=magic_mob},
regurgitation={spell_ID=648,mob_ID=2921,funct=magic_mob},
deltathrust={spell_ID=682,mob_ID=2922,funct=magic_mob},
cimicinedischarge={spell_ID=660,mob_ID=2929,funct=magic_mob},
seedspray={spell_ID=650,mob_ID=2931,funct=magic_mob},
pleniluneembrace={spell_ID=658,mob_ID=2941,funct=magic_mob},
asuranclaws={spell_ID=653,mob_ID=2944,funct=magic_mob},


feathertickle={spell_ID=573,mob_ID=2469,funct=magic_mob},
yawn={spell_ID=576,mob_ID=2481,funct=magic_mob},
maelstrom={spell_ID=515,mob_ID=1230,funct=magic_mob},
reavingwind={spell_ID=684,mob_ID=3199,funct=magic_mob},
digest={spell_ID=542,mob_ID=1201,funct=magic_mob},
amplification={spell_ID=642,mob_ID=2589,funct=magic_mob},
helldive={spell_ID=567,mob_ID=1390,funct=magic_mob},
featherbarrier={spell_ID=574,mob_ID=1170,funct=magic_mob},
deathray={spell_ID=522,mob_ID=1205,funct=magic_mob},
soundblast={spell_ID=572,mob_ID=1178,funct=magic_mob},
foulwaters={spell_ID=705,mob_ID=3742,funct=magic_mob},
retinalglare={spell_ID=707,mob_ID=3798,funct=magic_mob},
venomshell={spell_ID=513,mob_ID=1273,funct=magic_mob},
amorphicspikes={spell_ID=697,mob_ID=2592,funct=magic_mob},
screwdriver={spell_ID=519,mob_ID=1220,funct=magic_mob},
meteor={spell_ID=218,mob_ID=1402,funct=magic_mob},
mpdrainkiss={spell_ID=521,mob_ID=1189,funct=magic_mob},
natmeditation={spell_ID=700,mob_ID=3713,funct=magic_mob},
blooddrain={spell_ID=570,mob_ID=1162,funct=magic_mob},
jetstream={spell_ID=569,mob_ID=1163,funct=magic_mob},
regeneration={spell_ID=664,mob_ID=1186,funct=magic_mob},



 
raiseii={spell_ID=13,abil_ID=525,funct=smn_sub,info=T{4,'Cait Sith','Ward'}},
reraiseii={spell_ID=141,abil_ID=526,funct=smn_sub,info=T{4,'Cait Sith','Ward'}},
sleepga={spell_ID=273,abil_ID=611,funct=smn_sub,info=T{4,'Shiva','Ward'}},
stoneii={spell_ID=160,abil_ID=561,funct=smn_sub,info=T{4,5,8,20,21,'Titan','Rage'}},
waterii={spell_ID=170,abil_ID=577,funct=smn_sub,info=T{4,5,8,20,21,'Leviathan','Rage'}},
fireii={spell_ID=145,abil_ID=545,funct=smn_sub,info=T{4,5,8,20,21,'Ifrit','Rage'}},
aeroii={spell_ID=155,abil_ID=593,funct=smn_sub,info=T{4,5,8,20,21,'Garuda','Rage'}},
blizzardii={spell_ID=150,abil_ID=609,funct=smn_sub,info=T{4,5,8,20,21,'Shiva','Rage'}},
thunderii={spell_ID=165,abil_ID=625,funct=smn_sub,info=T{4,5,8,20,21,'Ramuh','Rage'}}
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
        if slugged_commands[key].type == 'Magic' then
            return commands.Magic[slugged_commands[key].id],slugged_commands[key].type
        else
            return commands.Abilities[slugged_commands[key].id],slugged_commands[key].type
        end
    else  -- Otherwise it's actually ambiguous, so run the associated function and pass the known information.
        abil_type=ambig_names[key]['funct'](windower.ffxi.get_player(),ambig_names[key].spell_ID,ambig_names[key].abil_ID,ambig_names[key].mob_ID,ambig_names[key].info,ambig_names[key].mob_ID)
        if abil_type == 'Ability' then
            return res.abilities[ambig_names[key].abil_ID],abil_type
        elseif abil_type == 'Magic' then
            return res.spells[ambig_names[key].spell_ID],abil_type
        elseif abil_type == 'Monster' then
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
    local valid_abilities = {Magic = {},Abilities = {}}
    if not player then return valid_abilities end
    
    for i,v in pairs(windower.ffxi.get_spells()) do
        if v and ((res.spells[i].levels[player.main_job_id] and res.spells[i].levels[player.main_job_id] <= player.main_job_level) or (res.spells[i].levels[player.sub_job_id] and res.spells[i].levels[player.sub_job_id] <= player.sub_job_level)) then
            valid_abilities.Magic[i] = res.spells[i]
        end
    end
    
    for i,v in pairs(windower.ffxi.get_abilities()) do
        if v then
            valid_abilities.Abilities[i] = res.abilities[i]
        end
    end
    
    local mjob = windower.ffxi.get_mjob_data()
    if mjob and mjob.species_id and res.items[mjob.species_id + 61440] then
        for i,v in pairs(res.items[mjob.species_id + 61440].tp_moves) do
            if player.main_job_level >= v then
                valid_abilities.Abilities[i] = res.abilities[i+768]
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
    for i,v in pairs(commands.Abilities) do
        if slugged_commands[stripped] then
            slugged_commands[stripped] = {type='Ambiguous'}
        elseif i < 1024 then
            slugged_commands[strip(v[language])] = {type='Ability',id=i}
        else
            slugged_commands[strip(v[language])] = {type='Monster',id=i}
        end
    end
    for i,v in pairs(commands.Magic) do
        local stripped = strip(v[language])
        if slugged_commands[stripped] then
            slugged_commands[stripped] = {type='Ambiguous'}
        else
            slugged_commands[stripped] = {type='Magic',id=i}
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
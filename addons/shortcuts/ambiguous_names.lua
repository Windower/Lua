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
    if player_array['main_job_id'] == 15 and abils[IDs.job_abilities] then
        return 'job_abilities'
    end
    return 'spells'
end
 
function smn_sub(player_array,IDs,info) -- Determines ambiguous black magic that can be subbed. Defaults to black magic
    local abils = windower.ffxi.get_abilities().job_abilities
    if player_array.main_job_id == 15 and not (info:contains(player_array.sub_job_id)) and abils[IDs.job_abilities] then
        return 'job_abilities' -- Returns the SMN ability if it's a SMN main without a sub that has access to the spell
    elseif (player_array.main_job_id == 15 and (info:contains(player_array.sub_job_id))) or (player_array.sub_job_id == 15 and (info:contains(player_array.main_job_id))) then
        local pet_array = windower.ffxi.get_mob_by_target('pet')
        local known_spells = windower.ffxi.get_spells()
        if not pet_array and known_spells[IDs.spells] then return 'spells' end
        local recasts = windower.ffxi.get_ability_recasts()
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
    if IDs.monster_abilities and race then
        if race == 0 then 
            return 'monster_abilities'
        end
    end
    local known_spells = windower.ffxi.get_spells()
    if player_array.main_job_id == 16 and IDs.spells and known_spells[IDs.spells] then -- and player_array['main_job_level'] >= info then
        return 'spells'
    end
    if IDs.weapon_skills then
        return 'weapon_skills'
    end
    return 'job_abilities'
end

function abil_mob(player_array,IDs,info) -- Determines ambiguity between monster TP moves and abilities
    local race = windower.ffxi.get_mob_by_id(player_array.id).race
    if IDs.monster_abilities and race then
        local abils = windower.ffxi.get_abilities().job_abilities
        local recasts = windower.ffxi.get_ability_recasts()
        if abils[IDs.job_abilities] and recasts[res.job_abilities[IDs.job_abilities].recast_id] <= 10 then
            return 'job_abilities'
        elseif race == 0 then
            return 'monster_abilities'
        end
    end
    return 'job_abilities'
end

function magic_mob(player_array,IDs,info) -- Determines ambiguity between monster TP moves and magic
    local race = windower.ffxi.get_mob_by_id(player_array.id).race
    if IDs.monster_abilities and race then
        if race == 0 then 
            return 'monster_abilities'
        end
    end
    return 'spells'
end
 
function blu_sub(player_array,IDs,info) -- Determines ambiguous blue magic that can be subbed. Defaults to BST ability
    local race = windower.ffxi.get_mob_by_id(player_array.id).race
    if IDs.monster_abilities and race then
        if race == 0 then 
            return 'monster_abilities'
        end
    end
    local abils = windower.ffxi.get_abilities().job_abilities
    if player_array['main_job_id'] == 9 and player_array['sub_job_id'] ~= 16 then
        return 'job_abilities' -- Returns the BST ability if it's BST/not-BLU using the spell
    elseif player_array['main_job_id'] == 9 and player_array['sub_job_id'] == 16 and abils[IDs.job_abilities] then
        local recasts = windower.ffxi.get_ability_recasts()
        if pet_array.tp >= 100 and recasts[255] <= 5400 then -- If your pet has TP and Ready's recast is less than 1.5 minutes
            return 'job_abilities'
        else
            return 'spells'
        end
    end
    return 'spells'
end
 
 
ambig_names = {
    sleepgaii={absolute=true,spells=274},
    darkarts={absolute=true,job_abilities=232},
    slowga={absolute=true,job_abilities=580},
    hastega={absolute=true,job_abilities=595},
    slice={absolute=true,weapon_skills=96},
    netherspikes={absolute=true,weapon_skills=241},
    carnalnightmare={absolute=true,weapon_skills=242},
    aegisschism={absolute=true,weapon_skills=243},
    dancingchains={absolute=true,weapon_skills=244},
    photosynthesis={absolute=true,monster_abilities=324},
    petribreath={absolute=true,monster_abilities=269},
    epoxyspread={absolute=true,monster_abilities=1319},
    mucusspread={absolute=true,monster_abilities=1317},
    fluidspread={absolute=true,monster_abilities=431},
    fluidtoss={absolute=true,monster_abilities=432},
    balefulgaze={absolute=true,monster_abilities=370},
    wingwhirl={absolute=true,monster_abilities=1717},
    frigidshuffle={absolute=true,monster_abilities=1716},

    fireiv={IDs={spells=147,job_abilities=549},funct=smn_unsub,info=60},
    stoneiv={IDs={spells=162,job_abilities=565},funct=smn_unsub,info=60},
    wateriv={IDs={spells=172,job_abilities=581},funct=smn_unsub,info=60},
    aeroiv={IDs={spells=157,job_abilities=597},funct=smn_unsub,info=60},
    blizzardiv={IDs={spells=152,job_abilities=613},funct=smn_unsub,info=60},
    thunderiv={IDs={spells=167,job_abilities=629},funct=smn_unsub,info=60},
    thunderstorm={IDs={spells=117,job_abilities=631},funct=smn_unsub,info=75},
     
    dreamflower={IDs={spells=678,job_abilities=676,monster_abilities=301},funct=blu_unsub,info=87},
    frostbreath={IDs={spells=608,job_abilities=647,monster_abilities=377},funct=blu_unsub,info=66},
    infrasonics={IDs={spells=610,job_abilities=687,monster_abilities=372},funct=blu_unsub,info=65},
    mneedles={IDs={spells=595,job_abilities=699,monster_abilities=322},funct=blu_unsub,info=62},
    filamentedhold={IDs={spells=548,job_abilities=729,monster_abilities=364},funct=blu_unsub,info=52},
    suddenlunge={IDs={spells=692,job_abilities=736,monster_abilities=2178},funct=blu_unsub,info=95},
    spiralspin={IDs={spells=652,job_abilities=737,monster_abilities=2181},funct=blu_unsub,info=60},
    chargedwhisker={IDs={spells=680,job_abilities=746},monster_abilities=483,funct=blu_unsub,info=88},
    corrosiveooze={IDs={spells=651,job_abilities=748},funct=blu_unsub,info=66},
    fantod={IDs={spells=674,job_abilities=752},funct=blu_unsub,info=85},
    hardenshell={IDs={spells=737,job_abilities=754,monster_abilities=807},funct=blu_unsub,info=95},
    barbedcrescent={IDs={spells=699,weapon_skills=245},funct=blu_unsub,99,info=99},
    dimensionaldeath={IDs={spells=589,weapon_skills=255},funct=blu_unsub,info=60},
    tourbillion={IDs={spells=740,monster_abilities=2024},funct=blu_unsub,info=97},
    subzerosmash={IDs={spells=654,monster_abilities=2436},funct=blu_unsub,info=72},
    pyricbulwark={IDs={spells=741,monster_abilities=1831},funct=blu_unsub,info=98},
     
    footkick={IDs={spells=577,job_abilities=672,monster_abilities=257},funct=blu_sub},
    headbutt={IDs={spells=623,job_abilities=675,monster_abilities=300},funct=blu_sub},
    queasyshroom={IDs={spells=599,job_abilities=702,monster_abilities=310},funct=blu_sub},
    sheepsong={IDs={spells=584,job_abilities=692,monster_abilities=264},funct=blu_sub},
    wildoats={IDs={spells=603,job_abilities=677,monster_abilities=302},funct=blu_sub},
    clawcyclone={IDs={spells=522,job_abilities=682,monster_abilities=273},funct=blu_sub},
    metallicbody={IDs={spells=637,job_abilities=697},funct=blu_sub},
    powerattack={IDs={spells=551,job_abilities=707,monster_abilities=338},funct=blu_sub},
    cursedsphere={IDs={spells=544,job_abilities=712,monster_abilities=659},funct=blu_sub},
    mandibularbite={IDs={spells=543,job_abilities=717,monster_abilities=279},funct=blu_sub},
    soporific={IDs={spells=598,job_abilities=718,monster_abilities=434},funct=blu_sub},
    geistwall={IDs={spells=605,job_abilities=721,monster_abilities=516},funct=blu_sub},
    chaoticeye={IDs={spells=582,job_abilities=730,monster_abilities=653},funct=blu_sub},
    wildcarrot={IDs={spells=578,job_abilities=735,monster_abilities=323},funct=blu_sub},
    jettatura={IDs={spells=575,job_abilities=750},funct=blu_sub},

    dustcloud={IDs={job_abilities=673,monster_abilities=258},funct=abil_mob},
    whirlclaws={IDs={job_abilities=674,monster_abilities=259},funct=abil_mob},
    lambchop={IDs={job_abilities=689,monster_abilities=260},funct=abil_mob},
    rage={IDs={job_abilities=690,monster_abilities=261},funct=abil_mob},
    sheepcharge={IDs={job_abilities=691,monster_abilities=262},funct=abil_mob},
    roar={IDs={job_abilities=680,monster_abilities=270},funct=abil_mob},
    razorfang={IDs={job_abilities=681,monster_abilities=271},funct=abil_mob},
    sandblast={IDs={job_abilities=714,monster_abilities=275},funct=abil_mob},
    sandpit={IDs={job_abilities=715,monster_abilities=276},funct=abil_mob},
    venomspray={IDs={job_abilities=716,monster_abilities=277},funct=abil_mob},
    berserk={IDs={job_abilities=31,monster_abilities=286},funct=abil_mob,info=true},
    leafdagger={IDs={job_abilities=678,monster_abilities=305},funct=abil_mob},
    scream={IDs={job_abilities=679,monster_abilities=306},funct=abil_mob},
    frogkick={IDs={job_abilities=700,monster_abilities=308},funct=abil_mob},
    spore={IDs={job_abilities=701,monster_abilities=309},funct=abil_mob},
    numbshroom={IDs={job_abilities=703,monster_abilities=311},funct=abil_mob},
    shakeshroom={IDs={job_abilities=704,monster_abilities=312},funct=abil_mob},
    silencegas={IDs={job_abilities=705,monster_abilities=314},funct=abil_mob},
    darkspore={IDs={job_abilities=706,monster_abilities=315},funct=abil_mob},
    needleshot={IDs={job_abilities=698,monster_abilities=321},funct=abil_mob},
    hifreqfield={IDs={job_abilities=708,monster_abilities=339},funct=abil_mob},
    rhinoattack={IDs={job_abilities=109,monster_abilities=340},funct=abil_mob},
    rhinoguard={IDs={job_abilities=710,monster_abilities=341},funct=abil_mob},
    spoil={IDs={job_abilities=711,monster_abilities=343},funct=abil_mob},
    doubleclaw={IDs={job_abilities=726,monster_abilities=362},funct=abil_mob},
    grapple={IDs={job_abilities=727,monster_abilities=363},funct=abil_mob},
    spinningtop={IDs={job_abilities=728,monster_abilities=365},funct=abil_mob},
    tailblow={IDs={job_abilities=683,monster_abilities=366},funct=abil_mob},
    fireball={IDs={job_abilities=684,monster_abilities=367},funct=abil_mob},
    blockhead={IDs={job_abilities=685,monster_abilities=368},funct=abil_mob},
    braincrush={IDs={job_abilities=686,monster_abilities=369},funct=abil_mob},
    secretion={IDs={job_abilities=688,monster_abilities=371},funct=abil_mob},
    ripperfang={IDs={job_abilities=744,monster_abilities=372},funct=abil_mob},
    chomprush={IDs={job_abilities=745,monster_abilities=379},funct=abil_mob},
    scythetail={IDs={job_abilities=743,monster_abilities=380},funct=abil_mob},
    palsypollen={IDs={job_abilities=720,monster_abilities=435},funct=abil_mob},
    gloeosuccus={IDs={job_abilities=719,monster_abilities=436},funct=abil_mob},
    toxicspit={IDs={job_abilities=725,monster_abilities=515},funct=abil_mob},
    numbingnoise={IDs={job_abilities=722,monster_abilities=517},funct=abil_mob},
    nimblesnap={IDs={job_abilities=723,monster_abilities=518},funct=abil_mob},
    cyclotail={IDs={job_abilities=724,monster_abilities=519},funct=abil_mob},
    shockwave={IDs={job_abilities=820,monster_abilities=631},funct=abil_mob},
    blaster={IDs={job_abilities=731,monster_abilities=652},funct=abil_mob},
    venom={IDs={job_abilities=713,monster_abilities=660},funct=abil_mob},
    snowcloud={IDs={job_abilities=734,monster_abilities=661},funct=abil_mob},
    tortoisestomp={IDs={job_abilities=753,monster_abilities=806},funct=abil_mob},
    aquabreath={IDs={job_abilities=755,monster_abilities=809},funct=abil_mob},
    noisomepowder={IDs={job_abilities=738,monster_abilities=2179},funct=abil_mob},
    sensillablades={IDs={job_abilities=761,monster_abilities=2946},funct=abil_mob},
    tegminabuffet={IDs={job_abilities=762,monster_abilities=2947},funct=abil_mob},
    wingslap={IDs={job_abilities=756,monster_abilities=1714},funct=abil_mob},
    beaklunge={IDs={job_abilities=757,monster_abilities=1715},funct=abil_mob},
    scissorguard={IDs={job_abilities=696,monster_abilities=445},funct=abil_mob},
    intimidate={IDs={job_abilities=758,monster_abilities=449},funct=abil_mob},
    recoildive={IDs={job_abilities=759,monster_abilities=641},funct=abil_mob},
    purulentooze={IDs={job_abilities=747,monster_abilities=2184},funct=abil_mob},
    waterwall={IDs={job_abilities=760,monster_abilities=453},funct=abil_mob},
    suction={IDs={job_abilities=732,monster_abilities=414},funct=abil_mob},
    acidmist={IDs={job_abilities=740,monster_abilities=415},funct=abil_mob},
    sandbreath={IDs={job_abilities=649,monster_abilities=416},funct=abil_mob},
    drainkiss={IDs={job_abilities=733,monster_abilities=417},funct=abil_mob},
    tpdrainkiss={IDs={job_abilities=741,monster_abilities=420},funct=abil_mob},
    bigscissors={IDs={job_abilities=695,monster_abilities=444},funct=abil_mob},
    bubbleshower={IDs={job_abilities=693,monster_abilities=442},funct=abil_mob},
    bubblecurtain={IDs={job_abilities=694,monster_abilities=443},funct=abil_mob},
    chokebreath={IDs={job_abilities=751,monster_abilities=579},funct=abil_mob},
    backheel={IDs={job_abilities=749,monster_abilities=519},funct=abil_mob},

    ramcharge={IDs={spells=585,monster_abilities=266},funct=magic_mob},
    healingbreeze={IDs={spells=581,monster_abilities=287},funct=magic_mob},
    blankgaze={IDs={spells=592,monster_abilities=292},funct=magic_mob},
    magicfruit={IDs={spells=593,monster_abilities=295},funct=magic_mob},
    pineconebomb={IDs={spells=596,monster_abilities=297},funct=magic_mob},
    leafstorm={IDs={spells=663,monster_abilities=298},funct=magic_mob},
    badbreath={IDs={spells=604,monster_abilities=319},funct=magic_mob},
    pollen={IDs={spells=549,monster_abilities=335},funct=magic_mob},
    finalsting={IDs={spells=665,monster_abilities=336},funct=magic_mob},
    poisonbreath={IDs={spells=536,monster_abilities=345},funct=magic_mob},
    cocoon={IDs={spells=547,monster_abilities=346},funct=magic_mob},
    deathscissors={IDs={spells=554,monster_abilities=353},funct=magic_mob},
    thunderbolt={IDs={spells=736,monster_abilities=378},funct=magic_mob},
    awfuleye={IDs={spells=606,monster_abilities=386},funct=magic_mob},
    lowing={IDs={spells=588,monster_abilities=497},funct=magic_mob},
    uppercut={IDs={spells=594,monster_abilities=584},funct=magic_mob},
    sproutsmack={IDs={spells=597,monster_abilities=687},funct=magic_mob},
    heatbreath={IDs={spells=591,monster_abilities=800},funct=magic_mob},
    sickleslash={IDs={spells=545,monster_abilities=810},funct=magic_mob},
    barriertusk={IDs={spells=685,monster_abilities=1703},funct=magic_mob},
    voracioustrunk={IDs={spells=579,monster_abilities=1707},funct=magic_mob},
    gatesofhades={IDs={spells=739,monster_abilities=1790},funct=magic_mob},
    thermalpulse={IDs={spells=675,monster_abilities=1817},funct=magic_mob},
    cannonball={IDs={spells=643,monster_abilities=1818},funct=magic_mob},
    exuviation={IDs={spells=645,monster_abilities=1955},funct=magic_mob},
    demoralizingroar={IDs={spells=659,monster_abilities=2101},funct=magic_mob},
    regurgitation={IDs={spells=648,monster_abilities=2153},funct=magic_mob},
    deltathrust={IDs={spells=682,monster_abilities=2154},funct=magic_mob},
    cimicinedischarge={IDs={spells=660,monster_abilities=2161},funct=magic_mob},
    seedspray={IDs={spells=650,monster_abilities=2163},funct=magic_mob},
    pleniluneembrace={IDs={spells=658,monster_abilities=2173},funct=magic_mob},
    asuranclaws={IDs={spells=653,monster_abilities=2176},funct=magic_mob},


    feathertickle={IDs={spells=573,monster_abilities=1701},funct=magic_mob},
    yawn={IDs={spells=576,monster_abilities=1713},funct=magic_mob},
    maelstrom={IDs={spells=515,monster_abilities=462},funct=magic_mob},
    reavingwind={IDs={spells=684,monster_abilities=2431},funct=magic_mob},
    digest={IDs={spells=542,monster_abilities=433},funct=magic_mob},
    amplification={IDs={spells=642,monster_abilities=1821},funct=magic_mob},
    helldive={IDs={spells=567,monster_abilities=622},funct=magic_mob},
    featherbarrier={IDs={spells=574,monster_abilities=402},funct=magic_mob},
    deathray={IDs={spells=522,monster_abilities=437},funct=magic_mob},
    soundblast={IDs={spells=572,monster_abilities=410},funct=magic_mob},
    foulwaters={IDs={spells=705,monster_abilities=2974},funct=magic_mob},
    retinalglare={IDs={spells=707,monster_abilities=3030},funct=magic_mob},
    venomshell={IDs={spells=513,monster_abilities=505},funct=magic_mob},
    amorphicspikes={IDs={spells=697,monster_abilities=1824},funct=magic_mob},
    screwdriver={IDs={spells=519,monster_abilities=452},funct=magic_mob},
    meteor={IDs={spells=218,monster_abilities=634},funct=magic_mob},
    blooddrain={IDs={spells=570,monster_abilities=394},funct=magic_mob},
    jetstream={IDs={spells=569,monster_abilities=395},funct=magic_mob},
    regeneration={IDs={spells=664,monster_abilities=418},funct=magic_mob},
    mpdrainkiss={IDs={spells=521,monster_abilities=421},funct=magic_mob},
    natmeditation={IDs={spells=700,monster_abilities=2945},funct=magic_mob},



     
    raiseii={IDs={spells=13,job_abilities=525},funct=smn_sub,info=T{4,'Cait Sith','Ward'}},
    reraiseii={IDs={spells=141,job_abilities=526},funct=smn_sub,info=T{4,'Cait Sith','Ward'}},
    sleepga={IDs={spells=273,job_abilities=611},funct=smn_sub,info=T{4,'Shiva','Ward'}},
    stoneii={IDs={spells=160,job_abilities=561},funct=smn_sub,info=T{4,5,8,20,21,'Titan','Rage'}},
    waterii={IDs={spells=170,job_abilities=577},funct=smn_sub,info=T{4,5,8,20,21,'Leviathan','Rage'}},
    fireii={IDs={spells=145,job_abilities=545},funct=smn_sub,info=T{4,5,8,20,21,'Ifrit','Rage'}},
    aeroii={IDs={spells=155,job_abilities=593},funct=smn_sub,info=T{4,5,8,20,21,'Garuda','Rage'}},
    blizzardii={IDs={spells=150,job_abilities=609},funct=smn_sub,info=T{4,5,8,20,21,'Shiva','Rage'}},
    thunderii={IDs={spells=165,job_abilities=625},funct=smn_sub,info=T{4,5,8,20,21,'Ramuh','Rage'}}
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
        return commands[slugged_commands[key].type][slugged_commands[key].id],slugged_commands[key].type
    else  -- Otherwise it's actually ambiguous, so run the associated function and pass the known information.
        abil_type=ambig_names[key]['funct'](windower.ffxi.get_player(),ambig_names[key].IDs,ambig_names[key].info,ambig_names[key].monster_abilities)
        if res[abil_type] then
            return res[abil_type][ambig_names[key].IDs[abil_type]]
        else
            print('This should not be hit: '..tostring(abil_type))
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
    local valid_abilities = {spells = {},job_abilities = {},weapon_skills = {}, monster_abilities = {}}
    if not player then return valid_abilities end
    
    for i,v in pairs(windower.ffxi.get_spells()) do
        if v and ((res.spells[i].levels[player.main_job_id] and res.spells[i].levels[player.main_job_id] <= player.main_job_level) or (res.spells[i].levels[player.sub_job_id] and res.spells[i].levels[player.sub_job_id] <= player.sub_job_level)) then
            valid_abilities.spells[i] = res.spells[i]
        end
    end
    
    for typ,tab in pairs(windower.ffxi.get_abilities()) do
        if tab and typ ~= 'job_traits' then 
            for _,ind in pairs(tab) do
                valid_abilities[typ][ind] = res[typ][ind]
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
    for typ,tab in pairs(commands) do
        for ind,r_line in pairs(tab) do
            local stripped = strip(r_line[language])
            if slugged_commands[stripped] then
                slugged_commands[stripped] = {type='Ambiguous'}
            else
                slugged_commands[stripped] = {type=typ,id=ind}
            end
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
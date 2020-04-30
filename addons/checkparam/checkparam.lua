--[[
Copyright © 2018, from20020516
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.
    * Neither the name of checkparam nor the
        names of its contributors may be used to endorse or promote products
        derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL from20020516 BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.name = 'Checkparam'
_addon.author = 'from20020516 & Kigen'
_addon.version = '1.3'
_addon.commands = {'cp','checkparam'}

require('logger')
res = require('resources')
extdata = require('extdata')
config = require('config')
packets = require('packets')
require('math')

defaults = {
    WAR = 'store tp|double attack|triple attack|quadruple attack|weapon skill damage',
    MNK = 'store tp|double attack|triple attack|quadruple attack|martial arts|subtle blow',
    WHM = 'cure potency|cure potency ii|fast cast|quick cast|cure spellcasting time|enmity|healing magic casting time|divine benison|damage taken|physical damage taken|magic damage taken',
    BLM = 'magic attack bonus|magic burst damage|magic burst damage ii|int|magic accuracy|magic damage|fast cast|elemental magic casting time',
    RDM = 'magic attack bonus|magic burst damage|magic burst damage ii|magic accuracy|fast cast|quick cast|enfeebling magic skill|enhancing magic skill|store tp|dual wield',
    THF = 'store tp|double attack|triple attack|quadruple attack|dual wield|critical hit rate|critical hit damage|haste|weapon skill damage|steal|sneak attack|trick attack',
    PLD = 'enmity|damage taken|physical damage taken|magic damage taken|spell interruption rate|phalanx|cure potency|fastcast',
    DRK = 'store tp|double attack|triple attack|quadruple attack|weapon skill damage',
    BST = 'pet: double attack|pet: magic attack bonus|pet: damage taken',
    BRD = 'all songs|song effect duration|fast cast|song spellcasting time|singing skill|wind skill|string skill',
    RNG = 'store tp|snapshot|rapid shot|weapon skill damage',
    SAM = 'store tp|double attack|triple attack|quadruple attack|weapon skill damage',
    NIN = 'store tp|double attack|triple attack|quadruple attack|subtle blow',
    DRG = 'store tp|double attack|triple attack|quadruple attack|weapon skill damage',
    SMN = 'physical damage taken|magic damage taken|pet: physical damage taken|pet: magic damage taken|blood pact delay|blood pact delay ii|blood pact damage|avatar perpetuation cost|pet: magic attack bonus|pet: attack|pet: double attack|pet: accuracy|pet: magic accuracy|summoning magic skill|pet: blood pact damage|pet: magic damage',
    BLU = 'physical damage taken|magic damage taken|haste|dual wield|store tp|double attack|triple attack|quadruple attack|critical hit rate|critical hit damage|weapon skill damage|fast cast|magic attack bonus|magic accuracy|cure potency',
    COR = 'physical damage taken|magic damage taken|haste|dual wield|store tp|snapshot|rapid shot|fast cast|cure potency|magic accuracy|magic attack bonus|magic damage|weapon skill damage',
    PUP = 'pet: hp|pet: damage taken|pet: regen|martial arts|store tp|double attack|triple attack|quadruple attack',
    DNC = 'store tp|double attack|triple attack|quadruple attack',
    SCH = 'magic attack bonus|magic burst damage|magic burst damage ii|magic accuracy|magic damage|fast cast|elemental magic casting time|cure potency|enh mag eff dur|enhancing magic effect duration',
    GEO = 'pet: regen|pet: damage taken|indicolure effect duration|fast cast|magic evasion|handbell skill|geomancy skill|geomancy',
    RUN = 'enmity|damage taken|physical damage taken|magic damage taken|spell interruption rate|phalanx|inquartata|fastcast',
    levelfilter = 99,
}
settings = config.load(defaults)

tbl = {}

windower.register_event('addon command',function(arg)
    local items = windower.ffxi.get_items
    for i=0,#res.slots do
        local slot = windower.regex.replace(string.lower(res.slots[i].english),' ','_')
        local gear_set = items().equipment
        local gear = items(gear_set[slot..'_bag'],gear_set[slot])
        if gear_set[slot] > 0 then
            get_text(gear.id,gear.extdata)
        end
    end
    local my = windower.ffxi.get_player()
    show_results(my.name,my.main_job,my.sub_job)
end)

windower.register_event('incoming chunk',function(id,data)
    if id == 0x0C9 then
        local p = packets.parse('incoming',data)
        if p['Type'] == 3 then
            local count = p['Count']
            if count == 1 then
                get_text(p['Item'],p['ExtData'])
            else
                for i=1,count do
                    get_text(p['Item '..i],p['ExtData '..i])
                end
            end
        elseif p['Type'] == 1 then
            local t = windower.ffxi.get_mob_by_index(p['Target Index'])
            local mjob = res.jobs[p['Main Job']].english_short
            local sjob = res.jobs[p['Sub Job']].english_short
            if p['Main Job Level'] >= settings.levelfilter then
                show_results(t.name,mjob,sjob)
            else
                tbl = {}
                if mjob == 'NON' then
                    error('The target is in /anon state.')
                end
            end
        end
    end
end)

function get_text(id,data)
    config.reload(settings)
    local descriptions = res.item_descriptions[id]
    local helptext = descriptions and descriptions.english or '' --for 'vanilla' items. e.g. Moonshade Earring
    local stats = windower.regex.split(helptext,'(Pet|Avatar|Automaton|Wyvern|Luopan): ')
    for i,v in ipairs(windower.regex.split(stats[1],'\n')) do
        split_text(id,v)
    end
    if stats[2] then
        stats[2] = stats[2]:trim()
        split_text(id,stats[2],'pet: ')
    end
    local ext = extdata.decode({id=id,extdata=data})
    if ext.augments then
        for i,v in ipairs(ext.augments) do
            local stats = windower.regex.split(v,'(Pet|Avatar|Automaton|Wyvern|Luopan): ')
            if stats[2] then
                stats[2] = stats[2]:trim()
                split_text(id,stats[2],'pet: ')
            else
                split_text(id,v)
            end
        end
    end
    if enhanced[id] then
        local stats = enhanced[id]:gsub('([+-:][0-9]+)',',%1'):split(',')
        tbl[stats[1]] = tonumber(stats[2]) + (tbl[stats[1]] or 0)
        if settings.debugmode then
            log(id,res.items[id].english,stats[1],stats[2],tbl[stats[1]])
        end
    end
    tbl.sets = tbl.sets or {}
    table.insert(tbl.sets,id)
end

function split_text(id,text,arg)
    for key,value in string.gmatch(text,'/?([%D]-):?([%+%-]?[0-9]+)%%?%s?') do
        local key = windower.regex.replace(string.lower(key),'(\\"|\\.|\\s$)','')
        local key = integrate[key] or key
        local key = arg and arg..key or key
        if key == "blood pact damage" then
            key = "pet: blood pact damage"
        elseif key == "pet: damage taken" then
            tbl['pet: physical damage taken'] = tonumber(value)+(tbl['pet: physical damage taken'] or 0)
            tbl['pet: magic damage taken'] = tonumber(value)+(tbl['pet: magic damage taken'] or 0)
        elseif key == "damage taken" then
            tbl['physical damage taken'] = tonumber(value)+(tbl['physical damage taken'] or 0)
            tbl['magic damage taken'] = tonumber(value)+(tbl['magic damage taken'] or 0)
            tbl['breath damage taken'] = tonumber(value)+(tbl['breath damage taken'] or 0)
        else
            tbl[key] = tonumber(value)+(tbl[key] or 0)
        end
        if settings.debugmode then
            log(id,res.items[id].english,key,value,tbl[key])
        end
    end
end

function show_results(name,mjob,sjob)
    local count = {}
    for key,value in pairs(combination) do
        for _,id in pairs(tbl.sets) do
            if value.item[id] then
                count[key] = (count[key] or 0)+1
            end
        end
        if count[key] and count[key] > 1 then
            for stat,multi in pairs(value.stats) do
                tbl[stat] = (tbl[stat] or 0)+multi*math.min((count[key]+value.type),5)
            end
        end
    end
    local stats = settings[mjob]
    local head = '<'..mjob..'/'..(sjob or '')..'>'
    windower.add_to_chat(160,string.color(name,1,160)..': '..string.color(head,160,160))
    for index,key in ipairs(windower.regex.split(stats,'[|]')) do
        -- WA for blood pact damage showing when it is converted to pet: blood pact damage
        -- WA for damage taken showing when it is converted to physical/magic damage taken
        key = string.lower(key)
        if key ~= 'blood pact damage' and key ~= 'damage taken' then
            local value = tbl[key]
            local color = {value and 1 or 160,value and 166 or 160, 106, 205, 61}
            local stat_cap = caps[key]
            local output_string = ' ['..string.color(key,color[1],160)..']'
            if stat_cap == nil or value == nil then
                output_string = output_string..' '..string.color(tostring(value),color[2],160)
            elseif value == stat_cap then
                output_string = output_string..' '..string.color(tostring(value),color[3],160)..'/'..string.color(tostring(stat_cap),155,160)
            elseif math.abs(value) > math.abs(stat_cap) then
                output_string = output_string..' '..string.color(tostring(value),color[4],160)..'/'..string.color(tostring(stat_cap),155,160)
            else
                output_string = output_string..' '..string.color(tostring(value),color[5],160)..'/'..string.color(tostring(stat_cap),155,160)
            end
            windower.add_to_chat(160,output_string)
        end
    end
    tbl = {}
end

integrate = {
    --[[integrate same property.information needed for development. @from20020516]]
    ['quad atk'] = 'quadruple attack',
    ['quad attack'] = 'quadruple attack',
    ['triple atk'] = 'triple attack',
    ['double atk'] = 'double attack',
    ['dblatk'] = 'double attack',
    ['blood pact ability delay'] = 'blood pact delay',
    ['blood pact ability delay ii'] = 'blood pact delay ii',
    ['blood pact ab del ii'] = 'blood pact delay ii',
    ['blood pact recast time ii'] = 'blood pact delay ii',
    ['blood pact dmg'] = 'blood pact damage',
    ['enhancing magic duration'] = 'enhancing magic effect duration',
    ['eva'] = 'evasion',
    ['indicolure spell duration'] = 'indicolure effect duration',
    ['indi eff dur'] = 'indicolure effect duration',
    ['mag eva'] = 'magic evasion',
    ['magic atk bonus'] = 'magic attack bonus',
    ['magatkbns'] = 'magic attack bonus',
    ['mag atk bonus'] = 'magic attack bonus',
    ['mag acc'] = 'magic accuracy',
    ['m acc'] = 'magic accuracy',
    ['r acc'] = 'ranged accuracy',
    ['magic burst dmg'] = 'magic burst damage',
    ['mag dmg'] = 'magic damage',
    ['crithit rate'] = 'critical hit rate',
    ['phys dmg taken'] = 'physical damage taken',
    ['occ. quickens spellcasting']="quick cast",
    ['occassionally quickens spellcasting']="quick cast",
    ['song duration']="song effect duration",
}
enhanced = {
    [10392] = 'cursna+10', --Malison Medallion
    [10393] = 'cursna+15', --Debilis Medallion
    [10394] = 'fast cast+5', --Orunmila's Torque
    [10469] = 'fast cast+10', --Eirene's Manteel
    [10752] = 'fast cast+2', --Prolix Ring
    [10790] = 'cursna+10', --Ephedra Ring
    [10791] = 'cursna+15', --Haoma's Ring
    [10802] = 'fast cast+5', --Majorelle Shield
    [10806] = 'potency of cure effects received+15', --Adamas
    [10826] = 'fast cast+3', --Witful Belt
    [10838] = 'dual wield+5', --Patentia Sash
    [11000] = 'fast cast+3', --Swith Cape
    [11001] = 'fast cast+4', --Swith Cape +1
    [11037] = 'stoneskin+10', --Earthcry Earring
    [11051] = 'increases resistance to all status ailments+5', --Hearty Earring
    [11544] = 'fast cast+1', --Veela Cape
    [11602] = 'martial arts+10', --Cirque Necklace
    [11603] = 'dual wield+3', --Charis Necklace
    [11615] = 'fast cast+5', --Orison Locket
    [11707] = 'fast cast+2', --Estq. Earring
    [11711] = 'rewards+2', --Ferine Earring
    [11715] = 'dual wield+1', --Iga Mimikazari
    [11722] = 'sublimation+1', --Savant's Earring
    [11732] = 'dual wield+5', --Nusku's Sash
    [11734] = 'martial arts+10', --Shaolin Belt
    [11735] = 'snapshot+3', --Impulse Belt
    [11753] = 'aquaveil+1', --Emphatikos Rope
    [11775] = 'occult acumen+20', --Oneiros Rope
    [11856] = 'fast cast+10', --Anhur Robe
    [13177] = 'stoneskin+30', --Stone Gorget
    [14739] = 'dual wield+5', --Suppanomimi
    [14812] = 'fast cast+2', --Loquac. Earring
    [14813] = 'double attack+5', --Brutal Earring
    [15857] = 'drain and aspir potency+5', --Excelsis Ring
    [15960] = 'stoneskin+20', --Siegel Sash
    [15962] = 'magic burst damage+5', --Static Earring
    [16209] = 'snapshot+5', --Navarch's Mantle
    [19062] = 'divine benison+1', --Yagrush80
    [19082] = 'divine benison+2', --Yagrush85
    [19260] = 'dual wield+3', --Raider's Bmrng.
    [19614] = 'divine benison+3', --Yagrush90
    [19712] = 'divine benison+3', --Yagrush95
    [19821] = 'divine benison+3', --Yagrush99
    [19950] = 'divine benison+3', --Yagrush99+
    [20509] = 'counter+14', --Spharai119AG
    [20511] = 'martial arts+55', --Kenkonken119AG
    [21062] = 'divine benison+3', --Yagrush119
    [21063] = 'divine benison+3', --Yagrush119+
    [21078] = 'divine benison+3', --Yagrush119AG
    [21201] = 'fast cast+2', --Atinian Staff +1
    [27279] = 'physical damage taken-6', --Eri. Leg Guards
    [27280] = 'physical damage taken-7', --Eri. Leg Guards +1
    [21699] = 'potency of cure effects received+10', --Nibiru Faussar
    [27768] = 'fast cast+5', --Cizin Helm
    [27775] = 'fast cast+10', --Nahtirah Hat
    [28054] = 'fast cast+7', --Gendewitha Gages
    [28058] = 'snapshot+4', --Manibozho Gloves
    [28184] = 'fast cast+5', --Orvail Pants +1
    [28197] = 'snapshot+9', --Nahtirah Trousers
    [28206] = 'fast cast+10', --Geomancy Pants
    [28335] = 'cursna+10', --Gende. Galoshes
    [28459] = 'potency of cure effects received+5', --Chuq'aba Belt
    [28484] = 'cure potency+3', --Nourish Earring
    [28485] = 'cure potency+5', --Nourish Earring +1
    [28577] = 'potency of cure effects received+5', --Kunaji Ring
    [28582] = 'magic burst damage+5', --Locus Ring
    [28619] = 'cursna+15', --Mending Cape
    [28631] = 'elemental siphon+30', --Conveyance Cape
    [28637] = 'fast cast+7', --Lifestream Cape
    [11618] = 'song effect duration+10', -- Aoidos' Matinee
    [20629] = 'song effect duration+5', -- Legato Dagger
}
combination={
    ['af']={item=S{
        23040,23041,23042,23043,23044,23045,23046,23047,23048,23049,23050,23051,23052,23053,23055,23056,23057,23058,23059,23060,23061,23062,
        23107,23108,23109,23110,23111,23112,23113,23114,23115,23116,23117,23118,23119,23120,23122,23123,23124,23125,23126,23127,23128,23129,
        23174,23175,23176,23177,23178,23179,23180,23181,23182,23183,23184,23185,23186,23187,23189,23190,23191,23192,23193,23194,23195,23196,
        23241,23242,23243,23244,23245,23246,23247,23248,23249,23250,23251,23252,23253,23254,23256,23257,23258,23259,23260,23261,23262,23263,
        23308,23309,23310,23311,23312,23313,23314,23315,23316,23317,23318,23319,23320,23321,23323,23324,23325,23326,23327,23328,23329,23330,
        23375,23376,23377,23378,23379,23380,23381,23382,23383,23384,23385,23386,23387,23388,23390,23391,23392,23393,23394,23395,23396,23397,
        23442,23443,23444,23445,23446,23447,23448,23449,23450,23451,23452,23453,23454,23455,23457,23458,23459,23460,23461,23462,23463,23464,
        23509,23510,23511,23512,23513,23514,23515,23516,23517,23518,23519,23520,23521,23522,23524,23525,23526,23527,23528,23529,23530,23531,
        23576,23577,23578,23579,23580,23581,23582,23583,23584,23585,23586,23587,23588,23589,23591,23592,23593,23594,23595,23596,23597,23598,
        23643,23644,23645,23646,23647,23648,23649,23650,23651,23652,23653,23654,23655,23656,23658,23659,23660,23661,23662,23663,23664,23665,
        26085,26191},stats={['accuracy']=15,['magic accuracy']=15,['ranged accuracy']=15},type=-1},
    ['af_smn']={item=S{23054,23121,23188,23255,23322,23389,23456,23523,23590,23657,26342},
        stats={['pet: accuracy']=15,['pet: magic accuracy']=15,['pet: ranged accuracy']=15},type=-1},
    ['adhemar']={item=S{25614,25687,27118,27303,27474},stats={['critical hit rate']=2},type=0},
    ['amalric']={item=S{25616,25689,27120,27305,27476},stats={['magic attack bonus']=10},type=0},
    ['apogee']={item=S{26677,26853,27029,27205,27381},stats={['pet: blood pact damage']=2},type=0},
    ['argosy']={item=S{26673,26849,27025,27201,27377},stats={['double attack']=2},type=0},
    ['emicho']={item=S{25610,25683,27114,27299,27470},stats={['double attack']=2},type=0},
    ['carmine']={item=S{26679,26855,27031,27207,27383},stats={['accuracy']=10},type=0},
    ['kaykaus']={item=S{25618,25691,27122,27307,27478},stats={['cure potency ii']=2},type=0},
    ['lustratio']={item=S{26669,26845,27021,27197,27373},stats={['weapon skill damage']=2},type=0},
    ['rao']={item=S{26675,26851,27027,27203,27379},stats={['matial arts']=2},type=0},
    ['ryuo']={item=S{25612,25685,27116,27301,27472},stats={['attack']=10},type=0},
    ['souveran']={item=S{26671,26847,27023,27199,27375},stats={['damage taken']=2},type=0},
    ['ayanmo']={item=S{25572,25795,25833,25884,25951},stats={['str']=8,['vit']=8,['mnd']=8},type=-1},
    ['flamma']={item=S{25569,25797,25835,25886,25953},stats={['str']=8,['dex']=8,['vit']=8},type=-1},
    ['mallquis']={item=S{25571,25799,25837,25888,25955},stats={['vit']=8,['int']=8,['mnd']=8},type=-1},
    ['Mummu']={item=S{25570,25798,25836,25887,25954},stats={['dex']=8,['agi']=8,['chr']=8},type=-1},
    ['tali\'ah']={item=S{25573,25796,25834,25885,25952},stats={['vit']=8,['dex']=8,['chr']=8},type=-1},
    ['Hizamaru']={item=S{25576,25792,25830,25881,25948},stats={['counter']=2},type=-1},
    ['Inyanga']={item=S{25577,25793,25831,25882,25949},stats={['refresh']=1},type=-1},
    ['jhakri']={item=S{25578,25794,25832,25883,25950},stats={['fast cast']=3},type=-1},
    ['meghanada']={item=S{25575,25791,25829,25880,25947},stats={['regen']=3},type=-1},
    ['Sulevia\'s']={item=S{25574,25790,25828,25879,25946},stats={['subtle blow']=5},type=-1},
    ['BladeFlashEarrings']={item=S{28520,28521},stats={['double attack']=7},type=-1},
    ['HeartDudgeonEarrings']={item=S{28522,28523},stats={['dual wield']=7},type=-1}
}

caps={
    ['haste']=25,
    ['subtle blow']=50,
    ['cure potency']=50,
    ['potency of cure effects received']=30,
    ['quick cast']=10,
    ['physical damage taken']=-50,
    ['magic damage taken']=-50,
    ['breath damage taken']=-50,
    ['pet: physical damage taken']=-87.5,
    ['pet: magic damage taken']=-87.5,
    ['pet: haste']=25,
    ['magic burst damage']=40,
    ['blood pact delay']=-15,
    ['blood pact delay ii']=-15,
    ['save tp']=500,
    ['fast cast']=80,
    ['reward']=50
}

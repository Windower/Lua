--Copyright (c) 2013, Byrthnoth
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

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

-- Convert the spells and job abilities into a referenceable list of aliases --
    
unify_prefix = {['/ma'] = '/ma', ['/magic']='/ma',['/jobability'] = '/ja',['/ja']='/ja',['/item']='/item',['/song']='/ma',
    ['/so']='/ma',['/ninjutsu']='/ma',['/pet']='/pet',['/weaponskill']='/ws',['/ws']='/ws',['/ra']='/ra',['/rangedattack']='/ra',
    ['/nin']='/ma',['/throw']='/ra',['/range']='/ra',['/shoot']='/ra',['/monsterskill']='/ms',['/ms']='/ms',['/unknown']='/trig',
    ['/trigger']='/trig',['/echo']='/echo',['/pet']='/ja',['Mon']='Monster '}
    
validabils = {}
validabils['english'] = {['/ma'] = {}, ['/ja'] = {}, ['/ws'] = {}, ['/item'] = {}, ['/ra'] = {}, ['/ms'] = {}, ['/pet'] = {}, ['/trig'] = {}, ['/echo'] = {}}
validabils['french'] = {['/ma'] = {}, ['/ja'] = {}, ['/ws'] = {}, ['/item'] = {}, ['/ra'] = {}, ['/ms'] = {}, ['/pet'] = {}, ['/trig'] = {}, ['/echo'] = {}}
validabils['german'] = {['/ma'] = {}, ['/ja'] = {}, ['/ws'] = {}, ['/item'] = {}, ['/ra'] = {}, ['/ms'] = {}, ['/pet'] = {}, ['/trig'] = {}, ['/echo'] = {}}
validabils['japanese'] = {['/ma'] = {}, ['/ja'] = {}, ['/ws'] = {}, ['/item'] = {}, ['/ra'] = {}, ['/ms'] = {}, ['/pet'] = {}, ['/trig'] = {}, ['/echo'] = {}}

function make_abil(abil,lang,t,i)
    if not abil[lang] or not abil.prefix then return end
    local sp = abil[lang]:lower()
    local pref = unify_prefix[abil.prefix:lower()]
    
    validabils[lang][pref][sp] = i
end

function make_entry(v,typ,i)
    make_abil(v,'english',typ,i)
    make_abil(v,'german',typ,i)
    make_abil(v,'french',typ,i)
    make_abil(v,'japanese',typ,i)
end

for i,v in pairs(res.spells) do
    if not T{363,364}:contains(i) then
        make_entry(v,'Magic',i)
    end
end

for i,v in pairs(res.abilities) do
    make_entry(v,'Ability',i)
end

for i,v in pairs(res.items) do
    if v.targets and table.length(v.targets) ~= 0 then
        make_entry(v,'Item',i)
    end
end
    
default_slot_map = T{'sub','range','ammo','head','body','hands','legs','feet','neck','waist',
    'left_ear', 'right_ear', 'left_ring', 'right_ring','back'}
default_slot_map[0]= 'main'

command_list = {['/ja']='Ability',['/jobability']='Ability',['/so']='Magic',['/song']='Magic',['/ma']='Magic',['/magic']='Magic',['/nin']='Magic',['/ninjutsu']='Magic',
    ['/ra']='Ranged Attack',['/range']='Ranged Attack',['/throw']='Ranged Attack',['/shoot']='Ranged Attack',['/ms']='Ability',['/monsterskill']='Ability',
    ['/ws']='Ability',['/weaponskill']='Ability',['/item']='Item',['/pet']='Ability',['Monster']='Monster Move'}

category_map = T{'Melee Swing','Ranged Attack','Weapon Skill','Magic','Item','Ability','Weapon Skill','Magic','Item','None','TP Move','Ranged Attack','Pet','Ability','Ability'}

jobs = {WAR=0x00000002,MNK=0x00000004,WHM=0x00000008,BLM=0x00000010,RDM=0x00000020,THF=0x00000040,PLD=0x00000080,DRK=0x00000100,BST=0x00000200,BRD=0x00000400,
RNG=0x00000800,SAM=0x00001000,NIN=0x00002000,DRG=0x00004000,SMN=0x00008000,BLU=0x00010000,COR=0x00020000,PUP=0x00040000,DNC=0x00080000,SCH=0x00100000,GEO=0x00200000,
RUN=0x00400000,NONE=0x100000000}

mob_table_races = {[0]='Precomposed NPC',[1]='HumeM',[2]='HumeF',[3]='ElvaanM',[4]='ElvaanF',
    [5]='TaruM',[6]='TaruF',[7]='Mithra',[8]='Galka',[29]='ChildMithra',[30]='Child_E_H_F',
    [31]='Child_E_H_M',[32]='ChocoboRounsey',[33]='ChocoboDestrier',[34]='ChocoboPalfrey',
    [35]='ChocoboCourser',[36]='ChocoboJennet'}
    
dat_races = {['Precomposed NPC']=0x10000,HumeM=0x0002,HumeF=0x0004,ElvaanM=0x0008,ElvaanF=0x0010,
    TaruM=0x0020,TaruF=0x0040,Mithra=0x0080,Galka=0x0100,['Child_E_H_M']=0x10000,['ChocoboRounsey']=0x10000,
    ['ChocoboDestrier']=0x10000,['ChocoboPalfrey']=0x10000,['ChocoboCourser']=0x10000,['ChocoboJennet']=0x10000}
    
dat_slots = {0x0002,0x0004,0x0008,0x0010,0x0020,0x0040,0x0080,0x0100,0x0200,0x0400,0x0800,0x1000,0x2000,0x4000,0x8000}
dat_slots[0] = 0x0001

default_equip_order = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}

jas = {false,false,false,false,false,true,false,false,false,false,false,false,false,true,true,false}--6,14,15}
readies = {false,false,false,false,false,false,true,true,true,false,false,true,false,false,false,false}--{7,8,9,12}
uses = {false,true,true,true,true,false,false,false,false,false,true,false,true,false,false,false}--{2,3,4,5,11,13}
unable_to_use = T{17,18,55,56,87,88,89,90,104,191,308,313,325,410,428,561,574,579,580,581,661,665,
    12,16,34,35,40,47,48,49,71,72,76,78,84,91,92,94,95,96,106,111,128,154,155,190,192,193,198,
    199,215,216,217,218,219,220,233,246,247,307,315,316,328,337,338,346,347,348,349,356,411,443,444,
    445,446,514,516,517,518,523,524,525,547,568,569,575,649,660,662,666,700,701,62} -- Probably don't need some of these (event action)

-- 192 : param_1 = Ability ID
-- 17 : no information
-- 34 : param_1 = Spell index
pass_through_targs = {['<t>']=true,['<me>']=true,['<ft>']=true,['<scan>']=true,['<bt>']=true,['<lastst>']=true,
    ['<r>']=true,['<pet>']=true,['<p0>']=true,['<p1>']=true,['<p2>']=true,['<p3>']=true,['<p4>']=true,
    ['<p5>']=true,['<a10>']=true,['<a11>']=true,['<a12>']=true,['<a13>']=true,['<a14>']=true,['<a15>']=true,
    ['<a20>']=true,['<a21>']=true,['<a22>']=true,['<a23>']=true,['<a24>']=true,['<a25>']=true,['<st>']=true,
    ['<stnpc>']=true,['<stal>']=true,['<stpc>']=true,['<stpt>']=true}

avatar_element = {Ifrit='Fire',Titan='Earth',Leviathan='Water',Garuda='Wind',Shiva='Ice',Ramuh='Lightning',Carbuncle='Light',
    Diabolos='Dark',Fenrir='Dark',['Fire Elemental']='Fire',['Earth Elemental']='Earth',['Water Elemental']='Water',
    ['Wind Elemental']='Wind',['Ice Elemental']='Ice',['Lightning Elemental']='Lightning',['Light Elemental']='Light',
    ['Dark Elemental']='Dark'}
encumbrance_map = {0x79,0x7F,0x7F,0x7A,0x7B,0x7C,0x7D,0x7D,0x7A,0x7E,0x80,0x80,0x80,0x80,0x7E}
encumbrance_map[0] = 0x79 -- Slots mapped onto encumbrance byte values.

addendum_white = {[14]="Poisona",[15]="Paralyna",[16]="Blindna",[17]="Silena",[18]="Stona",[19]="Viruna",[20]="Cursna",
    [143]="Erase",[13]="Raise II",[140]="Raise III",[141]="Reraise II",[142]="Reraise III",[135]="Reraise"}
    
addendum_black = {[253]="Sleep",[259]="Sleep II",[260]="Dispel",[162]="Stone IV",[163]="Stone V",[167]="Thunder IV",
    [168]="Thunder V",[157]="Aero IV",[158]="Aero V",[152]="Blizzard IV",[153]="Blizzard V",[147]="Fire IV",[148]="Fire V",
    [172]="Water IV",[173]="Water V",[255]="Break"}

-- _globals --
user_data_table = {
    __newindex = function(tab, key, val)
            rawset(tab, user_key_filter(key), val)
        end,

    __index = function(tab, key)
        return rawget(tab, user_key_filter(key))
    end
    }
    
eq_data_table = {
    __newindex = function(tab, key, val)
            rawset(tab, slot_map[user_key_filter(key)], newtab)
        end,

    __index = function(tab, key)
        return rawget(tab, slot_map[user_key_filter(key)])
    end
    }
    
slot_map = make_user_table()
short_slot_map = make_user_table()

slot_map.main = 0
slot_map.sub = 1
slot_map.range = 2
slot_map.ranged = 2
slot_map.ammo = 3
slot_map.head = 4
slot_map.body = 5
slot_map.hands = 6
slot_map.legs = 7
slot_map.feet = 8
slot_map.neck = 9
slot_map.waist = 10
slot_map.ear1 = 11
slot_map.ear2 = 12
slot_map.left_ear = 11
slot_map.right_ear = 12
slot_map.learring = 11
slot_map.rearring = 12
slot_map.lear = 11
slot_map.rear = 12
slot_map.left_ring = 13
slot_map.right_ring = 14
slot_map.lring = 13
slot_map.rring = 14
slot_map.ring1 = 13
slot_map.ring2 = 14
slot_map.back = 15

short_slot_map.main = 0
short_slot_map.sub = 1
short_slot_map.range = 2
short_slot_map.ammo = 3
short_slot_map.head = 4
short_slot_map.body = 5
short_slot_map.hands = 6
short_slot_map.legs = 7
short_slot_map.feet = 8
short_slot_map.neck = 9
short_slot_map.waist = 10
short_slot_map.left_ear = 11
short_slot_map.right_ear = 12
short_slot_map.left_ring = 13
short_slot_map.right_ring = 14
short_slot_map.back = 15



_global = make_user_table()
_global.cast_delay = 0
_global.cancel_spell = false
_global.midaction = false
_global.pet_midaction = false
_global.current_event = 'None'

_settings = {}
_settings.debug_mode = false
_settings.demo_mode = false
_settings.show_swaps = false

_ExtraData = {
        player = {},
        spell = {},
        alliance = {},
        pet = {},
        fellow = {},
        world = {in_mog_house = false},
    }

last_PC_update = ''
gearswap_disabled = false
sent_out_equip = {}
not_sent_out_equip = {}
limbo_equip = {}
command_registry = {}
equip_list = {}
equip_order = {}
world = make_user_table()
buffactive = make_user_table()
player = make_user_table()
alliance = make_user_table()
player.equipment = make_user_table()
pet = make_user_table()
pet.isvalid = false
fellow = make_user_table()
fellow.isvalid = false
st_targs = {['<st>']=true,['<stpc>']=true,['<stal>']=true,['<stnpc>']=true,['<stpt>']=true}
current_job_file = nil
disable_table = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false}
outgoing_action_category_table = {['/ma']=3,['/ws']=7,['/ja']=9,['/ra']=16,['/ms']=25}
disable_table[0] = false
encumbrance_table = table.reassign({},disable_table)
registered_user_events = {}
empty = {name="empty"}
outgoing_packet_table = {}
tool_map = {
        ['Katon: Ichi'] = 'Uchitake',
        ['Katon: Ni'] = 'Uchitake',
        ['Katon: San'] = 'Uchitake',
        ['Hyoton: Ichi'] = 'Tsurara',
        ['Hyoton: Ni'] = 'Tsurara',
        ['Hyoton: San'] = 'Tsurara',
        ['Huton: Ichi'] = 'Kawahori-ogi',
        ['Huton: Ni'] = 'Kawahori-ogi',
        ['Huton: San'] = 'Kawahori-ogi',
        ['Doton: Ichi'] = 'Makibishi',
        ['Doton: Ni'] = 'Makibishi',
        ['Doton: San'] = 'Makibishi',
        ['Raiton: Ichi'] = 'Hiraishin',
        ['Raiton: Ni'] = 'Hiraishin',
        ['Raiton: San'] = 'Hiraishin',
        ['Suiton: Ichi'] = 'Mizu-deppo',
        ['Suiton: Ni'] = 'Mizu-deppo',
        ['Suiton: San'] = 'Mizu-deppo',
        ['Utsusemi: Ichi'] = 'Shihei',
        ['Utsusemi: Ni'] = 'Shihei',
        ['Utsusemi: San'] = 'Shihei',
        ['Jubaku: Ichi'] = 'Jusatsu',
        ['Jubaku: Ni'] = 'Jusatsu',
        ['Jubaku: San'] = 'Jusatsu',
        ['Hojo: Ichi'] = 'Kaginawa',
        ['Hojo: Ni'] = 'Kaginawa',
        ['Hojo: San'] = 'Kaginawa',
        ['Kurayami: Ichi'] = 'Sairui-ran',
        ['Kurayami: Ni'] = 'Sairui-ran',
        ['Kurayami: San'] = 'Sairui-ran',
        ['Dokumori: Ichi'] = 'Kodoku',
        ['Dokumori: Ni'] = 'Kodoku',
        ['Dokumori: San'] = 'Kodoku',
        ['Tonko: Ichi'] = 'Shinobi-tabi',
        ['Tonko: Ni'] = 'Shinobi-tabi',
        ['Tonko: San'] = 'Shinobi-tabi',
        ['Monomi: Ichi'] = 'Sanjaku-tenugui',
        ['Monomi: Ni'] = 'Sanjaku-tenugui',
        ['Aisha: Ichi'] = 'Soshi',
        ['Myoshu: Ichi'] = 'Kabenro',
        ['Yurin: Ichi'] = 'Jinko',
        ['Migawari: Ichi'] = 'Mokujin',
        ['Kakka: Ichi'] = 'Ryuno'
    }


universal_tool_map = {
        ['Katon: Ichi'] = 'Inoshishinofuda',
        ['Katon: Ni'] = 'Inoshishinofuda',
        ['Katon: San'] = 'Inoshishinofuda',
        ['Hyoton: Ichi'] = 'Inoshishinofuda',
        ['Hyoton: Ni'] = 'Inoshishinofuda',
        ['Hyoton: San'] = 'Inoshishinofuda',
        ['Huton: Ichi'] = 'Inoshishinofuda',
        ['Huton: Ni'] = 'Inoshishinofuda',
        ['Huton: San'] = 'Inoshishinofuda',
        ['Doton: Ichi'] = 'Inoshishinofuda',
        ['Doton: Ni'] = 'Inoshishinofuda',
        ['Doton: San'] = 'Inoshishinofuda',
        ['Raiton: Ichi'] = 'Inoshishinofuda',
        ['Raiton: Ni'] = 'Inoshishinofuda',
        ['Raiton: San'] = 'Inoshishinofuda',
        ['Suiton: Ichi'] = 'Inoshishinofuda',
        ['Suiton: Ni'] = 'Inoshishinofuda',
        ['Suiton: San'] = 'Inoshishinofuda',
        ['Utsusemi: Ichi'] = 'Shikanofuda',
        ['Utsusemi: Ni'] = 'Shikanofuda',
        ['Utsusemi: San'] = 'Shikanofuda',
        ['Jubaku: Ichi'] = 'Chonofuda',
        ['Jubaku: Ni'] = 'Chonofuda',
        ['Jubaku: San'] = 'Chonofuda',
        ['Hojo: Ichi'] = 'Chonofuda',
        ['Hojo: Ni'] = 'Chonofuda',
        ['Hojo: San'] = 'Chonofuda',
        ['Kurayami: Ichi'] = 'Chonofuda',
        ['Kurayami: Ni'] = 'Chonofuda',
        ['Kurayami: San'] = 'Chonofuda',
        ['Dokumori: Ichi'] = 'Chonofuda',
        ['Dokumori: Ni'] = 'Chonofuda',
        ['Dokumori: San'] = 'Chonofuda',
        ['Tonko: Ichi'] = 'Shikanofuda',
        ['Tonko: Ni'] = 'Shikanofuda',
        ['Tonko: San'] = 'Shikanofuda',
        ['Monomi: Ichi'] = 'Shikanofuda',
        ['Aisha: Ichi'] = 'Chonofuda',
        ['Myoshu: Ichi'] = 'Shikanofuda',
        ['Yurin: Ichi'] = 'Chonofuda',
        ['Migawari: Ichi'] = 'Shikanofuda',
        ['Kakka: Ichi'] = 'Shikanofuda'
    }


--persistant_sequence = {}  ---------------------- TEMPORARY TO INVESTIGATE LAG ISSUES IN DELVE
--persistant_sequence[0] = true
--prev_ID = 0
--cur_ID = 0
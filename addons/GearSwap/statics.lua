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


speFile = file.new('../../plugins/resources/spells.xml')
jaFile = file.new('../../plugins/resources/abils.xml')
statusFile = file.new('../../plugins/resources/status.xml')
dialogFile = file.new('../../addons/libs/resources/dialog4.xml')
r_mabilsFile = file.new('../../addons/libs/resources/mabils.xml')
r_itemsGFile = file.new('../../plugins/resources/items_general.xml')
r_itemsAFile = file.new('../../plugins/resources/items_armor.xml')
r_itemsWFile = file.new('../../plugins/resources/items_weapons.xml')

r_abilities = parse_resources(jaFile:readlines())
r_spells = parse_resources(speFile:readlines())
r_status = parse_resources(statusFile:readlines())
dialog = parse_resources(dialogFile:readlines())
r_mabils = parse_resources(r_mabilsFile:readlines())


-- Convert the spells and job abilities into a referenceable list of aliases --
	
unify_prefix = {['/ma'] = '/ma', ['/magic']='/ma',['/jobability'] = '/ja',['/ja']='/ja',['/item']='/item',['/song']='/ma',
	['/so']='/ma',['/ninjutsu']='/ma',['/pet']='/pet',['/weaponskill']='/ws',['/ws']='/ws',['/ra']='/ra',['/rangedattack']='/ra',
	['/nin']='/ma',['/throw']='/ra',['/range']='/ra',['/shoot']='/ra',['/monsterskill']='/ms',['/ms']='/ms',['/unknown']='/trig',
	['/trigger']='/trig',['/echo']='/echo'}
	
validabils = {}
validabils['english'] = {['/ma'] = {}, ['/ja'] = {}, ['/ws'] = {}, ['/item'] = {}, ['/ra'] = {}, ['/ms'] = {}, ['/pet'] = {}, ['/trig'] = {}, ['/echo'] = {}}
validabils['french'] = {['/ma'] = {}, ['/ja'] = {}, ['/ws'] = {}, ['/item'] = {}, ['/ra'] = {}, ['/ms'] = {}, ['/pet'] = {}, ['/trig'] = {}, ['/echo'] = {}}
validabils['german'] = {['/ma'] = {}, ['/ja'] = {}, ['/ws'] = {}, ['/item'] = {}, ['/ra'] = {}, ['/ms'] = {}, ['/pet'] = {}, ['/trig'] = {}, ['/echo'] = {}}
validabils['japanese'] = {['/ma'] = {}, ['/ja'] = {}, ['/ws'] = {}, ['/item'] = {}, ['/ra'] = {}, ['/ms'] = {}, ['/pet'] = {}, ['/trig'] = {}, ['/echo'] = {}}

function make_abil(abil,lang,t,i)
	if not abil[lang] or not abil.prefix then return end
	local sp = abil[lang]:lower()
	if not unify_prefix[abil.prefix:lower()] then
		print(abil.prefix:lower())
	end
	local pref = unify_prefix[abil.prefix:lower()]
	
	validabils[lang][pref][sp] = i
end

function make_entry(v,typ,i)
	if not v.targets then v.targets = 'None' end
	v.validtarget = {Self=false,Player=false,Party=false,Ally=false,NPC=false,Enemy=false}
	
	local potential_targets
	
	if tonumber(v.targets) then -- TEMPORARY FIX UNTIL THE RESOURCES ARE CORRECTED
		potential_targets = {}
	else
		potential_targets = v.targets:split(', ')
	end
	
	for n,m in ipairs(potential_targets) do
		v.validtarget[m] = true
	end
	if not v.tpcost or v.tpcost == -1 then v.tpcost = 0 end
	if not v.mpcost or v.mpcost == -1 then v.mpcost = 0 end
	if not v.prefix then
		if debugging >= 1 then
			windower.add_to_chat(8,'GearSwap (Debug Mode): '..i..' of type '..typ..' lacks a prefix')
		end
		if typ == 'Magic' then v.prefix = '/ma'
		elseif typ == 'Ability' then v.prefix = '/ja'
		end
	end
	if not v.element then v.element = 'None' end
	if not v.type then v.type = typ end
	if not v.recast then v.recast = 0 end
	if not v.casttime then v.casttime = 0 end
	if not v.skill then v.skill = typ end
	
	make_abil(v,'english',typ,i)
	make_abil(v,'german',typ,i)
	make_abil(v,'french',typ,i)
	make_abil(v,'japanese',typ,i)
	
	return v
end

for i,v in pairs(r_spells) do
	r_spells[i] = make_entry(v,'Magic',i)
end

for i,v in pairs(r_abilities) do
	r_abilities[i] = make_entry(v,'Ability',i)
end

-- Item processing --
r_items = table.range(65535)
r_items:update(parse_resources(r_itemsGFile:readlines()))
r_items:update(parse_resources(r_itemsAFile:readlines()))
r_items:update(parse_resources(r_itemsWFile:readlines()))

for i,v in pairs(r_items) do
	if type(v) == 'table' and v.targets ~= 'None' then
		v.prefix = '/item'
		r_items[i] = make_entry(v,'Item',i)
	end
end
	
default_slot_map = T{'sub','range','ammo','head','body','hands','legs','feet','neck','waist',
	'left_ear', 'right_ear', 'left_ring', 'right_ring','back'}
default_slot_map[0]= 'main'

command_list = {['/ja']='Ability',['/jobability']='Ability',['/so']='Magic',['/song']='Magic',['/ma']='Magic',['/magic']='Magic',['/nin']='Magic',['/ninjutsu']='Magic',
	['/ra']='Ranged Attack',['/range']='Ranged Attack',['/throw']='Ranged Attack',['/shoot']='Ranged Attack',['/ms']='Ability',['/monsterskill']='Ability',
	['/ws']='Ability',['/weaponskill']='Ability',['/item']='Item',['/pet']='Ability'}

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

dat_slots_map={[1]='main',[2]='sub',[3]='main',[4] = 'range',[8]='ammo',[16]='head',[32]='body',
	[64]='hands',[128]='legs',[256]='feet',[512]='neck',[1024]='waist',[2048]='left_ear',[4096]='right_ear',
	[6144]='left_ear',[8192]='left_ring',[16384]='right_ring',[24576]='left_ring',[32768]='back'}

default_equip_order = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}

jas = {false,false,false,false,false,true,false,false,false,false,false,false,false,true,true,false}--6,14,15}
readies = {false,false,false,false,false,false,true,true,true,false,false,true,false,false,false,false}--{7,8,9,12}
uses = {false,true,true,true,true,false,false,false,false,false,true,false,true,false,false,false}--{2,3,4,5,11,13}
unable_to_use = T{17,18,55,56,87,88,89,90,104,191,308,313,325,410,428,561,574,579,580,581,661,665,
	4,5,12,16,34,35,40,47,48,49,71,72,76,78,84,91,92,94,95,96,106,111,128,154,155,190,192,193,198,
	199,215,216,217,218,219,220,233,246,247,307,315,316,328,337,338,346,347,348,349,356,411,443,444,
	445,446,514,516,517,518,523,524,525,547,568,569,575,649,660,662,666,700,701} -- Probably don't need some of these (event action)
pass_through_targs = T{'<t>','<me>','<ft>','<scan>','<bt>','<lastst>','<r>','<pet>','<p0>','<p1>','<p2>','<p3>','<p4>',
	'<p5>','<a10>','<a11>','<a12>','<a13>','<a14>','<a15>','<a20>','<a21>','<a22>','<a23>','<a24>','<a25>','<stnpc>',
	'<stal>','<stpc>','<stpt>'}
avatar_element = {Ifrit='Fire',Titan='Earth',Leviathan='Water',Garuda='Wind',Shiva='Ice',Ramuh='Thunder',Carbuncle='Light',
	Diabolos='Dark',Fenrir='Dark',['Fire Elemental']='Fire',['Earth Elemental']='Earth',['Water Elemental']='Water',
	['Wind Elemental']='Wind',['Ice Elemental']='Ice',['Lightning Elemental']='Thunder',['Light Elemental']='Light',
	['Dark Elemental']='Dark'}
encumbrance_map = {0x79,0x7F,0x7F,0x7A,0x7B,0x7C,0x7D,0x7D,0x7A,0x7E,0x80,0x80,0x80,0x80,0x7E}
encumbrance_map[0] = 0x79 -- Slots mapped onto encumbrance byte values.

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
_global.storedtarget = ''
_global.verify_equip = false
_global.cancel_spell = false
_global.debug_mode = false
_global.show_swaps = false
_global.midaction = false
_global.current_event = 'None'

gearSwap_disabled = false
sent_out_equip = T{}
not_sent_out_equip = T{}
out_arr = {}
equip_list = {}
equip_order = {}
action_sent = false
world = make_user_table()
buffactive = make_user_table()
player = make_user_table()
alliance = make_user_table()
player.equipment = setmetatable({}, eq_data_table)
pet = make_user_table()
pet.isvalid = false
fellow = make_user_table()
fellow.isvalid = false
st_flag = false
current_job_file = nil
disable_table = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false}
disable_table[0] = false
encumbrance_table = table.reassign({},disable_table)
registered_user_events = {}
empty = {name="empty"}
persistent_spell = {}


--persistant_sequence = {}  ---------------------- TEMPORARY TO INVESTIGATE LAG ISSUES IN DELVE
--persistant_sequence[0] = true
--prev_ID = 0
--cur_ID = 0
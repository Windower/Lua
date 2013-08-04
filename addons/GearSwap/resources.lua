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
validabils = {}
validabils['english'] = T{}
validabils['french'] = T{}
validabils['german'] = T{}
validabils['japanese'] = T{}

function make_abil(abil,lang,t,i)
	if not abil[lang] then return end
	local temptab = validabils[lang]
	local sp = abil[lang]:lower()
	if not rawget(temptab,sp) then
		temptab[sp] = {}
	end
	temptab[sp][t] = i
end

for i,v in pairs(r_spells) do
	v['validtarget'] = {Self=false,Player=false,Party=false,Ally=false,NPC=false,Enemy=false}
	local potential_targets = split(v['targets'],', ')
	for n,m in pairs(potential_targets) do
		v['validtarget'][m] = true
	end
	if not v.tpcost or v.tpcost == -1 then v.tpcost = 0 end
	if not v.mpcost or v.mpcost == -1 then v.mpcost = 0 end
	
	make_abil(v,'english','Magic',i)
	make_abil(v,'german','Magic',i)
	make_abil(v,'french','Magic',i)
	make_abil(v,'japanese','Magic',i)
	if v['alias'] then
		local struck = split(v['alias'],'|')
		for n,m in pairs(struck) do
			make_abil(m,'english','Magic',i)
			make_abil(m,'german','Magic',i)
			make_abil(m,'french','Magic',i)
			make_abil(m,'japanese','Magic',i)
		end
	end
end

for i,v in pairs(r_abilities) do
	v['validtarget'] = {Self=false,Player=false,Party=false,Ally=false,NPC=false,Enemy=false}
	local potential_targets = split(v['targets'],', ')
	for n,m in pairs(potential_targets) do
		v['validtarget'][m] = true
	end
	if not v.tpcost or v.tpcost == -1 then v.tpcost = 0 end
	if not v.mpcost or v.mpcost == -1 then v.mpcost = 0 end
	
	make_abil(v,'english','Ability',i)
	make_abil(v,'german','Ability',i)
	make_abil(v,'french','Ability',i)
	make_abil(v,'japanese','Ability',i)
--	if v['alias'] then
--		local struck = split(v['alias'],'|')
--		for n,m in pairs(struck) do
--			make_abil(m,'english','Ability',i)
--			make_abil(m,'german','Ability',i)
--			make_abil(m,'french','Ability',i)
--			make_abil(m,'japanese','Ability',i)
--		end
--	end
end

-- Item processing --
r_items = table.range(65535)
r_items:update(parse_resources(r_itemsGFile:readlines()))
r_items:update(parse_resources(r_itemsAFile:readlines()))
r_items:update(parse_resources(r_itemsWFile:readlines()))
item_names = {}
item_names['english'] = T{}
item_names['german'] = T{}
item_names['french'] = T{}
item_names['japanese'] = T{}

for i,v in pairs(r_items) do
	if type(v) == 'table' then
		v.prefix = '/item'
		v.element = 'None'
		v.type = 'Item'
		v.validtarget = {Self=true,Player=true,Party=true,Ally=true,NPC=true,Enemy=true}
		v.targets = "Self, Player, Party, Ally, NPC, Enemy"
		v.mpcost = 0
		v.tpcost = 0
		v.recast = 0
		v.casttime = 0
		v.skill = 'Item'
		
		make_abil(v,'english','Item',i)
		make_abil(v,'german','Item',i)
		make_abil(v,'french','Item',i)
		make_abil(v,'japanese','Item',i)
	end
end

slot_map = T{main=0,sub=1,range=2,ammo=3,head=4,body=5,hands=6,legs=7,feet=8, neck=9, waist=10,
	ear1=11, ear2=12, left_ear=11, right_ear=12, learring=11, rearring=12, lear=11, rear=12,
	left_ring=13, right_ring=14, lring=13, rring=14, ring1=13, ring2=14, back=15}

short_slot_map = T{main=0,sub=1,range=2,ammo=3,head=4,body=5,hands=6,legs=7,feet=8, neck=9, waist=10,
	left_ear=11, right_ear=12, left_ring=13, right_ring=14, back=15}
	
default_slot_map = T{'sub','range','ammo','head','body','hands','legs','feet','neck','waist',
	'left_ear', 'right_ear', 'left_ring', 'right_ring','back'}
default_slot_map[0]= 'main'

command_list = {['/ja']='Ability',['/jobability']='Ability',['/so']='Magic',['/song']='Magic',['/ma']='Magic',['/magic']='Magic',['/nin']='Magic',['/ninjutsu']='Magic',
	['/ra']='Ranged Attack',['/range']='Ranged Attack',['/throw']='Ranged Attack',['/shoot']='Ranged Attack',['/ms']='Ability',['/monsterskill']='Ability',
	['/ws']='Ability',['/weaponskill']='Ability',['/item']='Item',['/pet']='Ability'}

ranged_line = {name='Ranged Attack',english='Ranged Attack',prefix='/range',element='None',targets='Enemy',skill='Ability',mpcost=0,
	tpcost=0,casttime=0,recast=0,validtarget={Self=false,Player=false,Party=false,Ally=false,NPC=false,Enemy=true}}

category_map = T{'Melee Swing','Ranged Attack','Weapon Skill','Magic','Item','Ability','Weapon Skill','Magic','Item','None','TP Move','Ranged Attack','Pet','Ability','Ability'}

jobs = {WAR=0x00000002,MNK=0x00000004,WHM=0x00000008,BLM=0x00000010,RDM=0x00000020,THF=0x00000040,PLD=0x00000080,DRK=0x00000100,BST=0x00000200,BRD=0x00000400,
RNG=0x00000800,SAM=0x00001000,NIN=0x00002000,DRG=0x00004000,SMN=0x00008000,BLU=0x00010000,COR=0x00020000,PUP=0x00040000,DNC=0x00080000,SCH=0x00100000,GEO=0x00200000,RUN=0x00400000}

mob_table_races = {[0]='Precomposed NPC',[1]='HumeM',[2]='HumeF',[3]='ElvaanM',[4]='ElvaanF',
	[5]='TaruM',[6]='TaruF',[7]='Mithra',[8]='Galka',[29]='ChildMithra',[30]='Child_E_H_F',
	[31]='Child_E_H_M',[32]='ChocoboRounsey',[33]='ChocoboDestrier',[34]='ChocoboPalfrey',
	[35]='ChocoboCourser',[36]='ChocoboJennet'}
dat_races = {HumeM=0x0002,HumeF=0x0004,ElvaanM=0x0008,ElvaanF=0x0010,TaruM=0x0020,TaruF=0x0040,Mithra=0x0080,Galka=0x0100}

jas = {false,false,false,false,false,true,false,false,false,false,false,false,false,true,true,false}--6,14,15}
readies = {false,false,false,false,false,false,true,true,true,false,false,true,false,false,false,false}--{7,8,9,12}
uses = {false,true,true,true,true,false,false,false,false,false,false,false,true,false,false,false}--{2,3,4,5,13}
unable_to_use = T{17,18,55,56,87,88,89,90,104,191,308,313,325,410,428,561,574,579,580,581,661,665,4,5,12,16,34,35,40,47,48,49,71,72,76,78,84,91,92,94,95,96,106,111,128,154,155,190,192,193,198,199,215,216,217,218,219,220,233,246,247,307,315,316,328,337,338,346,347,348,349,356,411,443,444,445,446,514,516,517,518,524,525,547,568,569,575,649,660,662,666} -- Probably don't need some of these (event action)
pass_through_targs = T{'<t>','<me>','<ft>','<scan>','<bt>','<lastst>','<r>','<pet>','<p0>','<p1>','<p2>','<p3>','<p4>',
	'<p5>','<a10>','<a11>','<a12>','<a13>','<a14>','<a15>','<a20>','<a21>','<a22>','<a23>','<a24>','<a25>'}
st_targs = T{'<stnpc>','<stal>','<stpc>','<stpt>'}
avatar_element = {Ifrit='Fire',Titan='Earth',Leviathan='Water',Garuda='Wind',Shiva='Ice',Ramuh='Thunder',Carbuncle='Light',
	Diabolos='Dark',Fenrir='Dark',['Fire Elemental']='Fire',['Earth Elemental']='Earth',['Water Elemental']='Water',
	['Wind Elemental']='Wind',['Ice Elemental']='Ice',['Lightning Elemental']='Thunder',['Light Elemental']='Light',
	['Dark Elemental']='Dark'}

-- _globals --
_global = {}
_global.cast_delay = 0
_global.storedtarget = ''
_global.verify_equip = false
_global.cancel_spell = false
_global.debug_mode = false
_global.show_swaps = false

gearswap_disabled = false
midaction = false
sent_out_equip = {}
equip_list = {}
lastbyte = 0x0000
action_sent = false
world = {}
buffactive = {}
player = {}
alliance = {}
player.equipment = {}
pet = {isvalid=false}
st_flag = false
current_job_file = nil


persistant_sequence = {}  ---------------------- TEMPORARY TO INVESTIGATE LAG ISSUES IN DELVE
persistant_sequence[0] = true
prev_ID = 0
cur_ID = 0
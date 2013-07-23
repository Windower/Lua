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
 
function smn_unsub(player_array,info)
	if player_array['main_job_id'] == 15 and player_array['main_job_level'] >= info then
		return 'Ability'
	end
	return 'Magic'
end
 
function smn_sub(player_array,info) -- Determines ambiguous black magic that can be subbed. Defaults to black magic
	if player_array['main_job_id'] == 15 and not (info:contains(player_array['sub_job_id'])) then
		return 'Ability' -- Returns the SMN ability if it's a SMN main without a sub that has access to the spell
	elseif player_array['main_job_id'] == 15 and (info:contains(player_array['sub_job_id'])) then
		local pet_array = get_mob_by_index(get_mob_by_id(player_array.id)['pet_index'])
		local recasts = get_ability_recasts()
		if info:contains(pet_array['name']) and info:contains('Ward') and recasts[174]<=10 then
			return 'Ability' -- Returns the SMN ability if it's a SMN main with an appropriate avatar summoned.
		elseif info:contains(pet_array['name']) and info:contains('Rage') and recasts[173]<=10 then
			return 'Ability'
		else
			return 'Magic'
		end
	end
	return 'Magic' -- Returns a spell in every other case.
end
 
function blu_unsub(player_array,info) -- Determines ambiguous blue magic that can be subbed. Defaults to spells if the level is high enough.
	if player_array['main_job_id'] == 16 and player_array['main_job_level'] >= info then
		return 'Magic'
	end
	return 'Ability'
end
 
function blu_sub(player_array,info) -- Determines ambiguous blue magic that can be subbed. Defaults to BST ability
	if player_array['main_job_id'] == 9 and player_array['sub_job_id'] ~= 16 then
		return 'Ability' -- Returns the BST ability if it's BST/not-BLU using the spell
	elseif player_array['main_job_id'] == 9 and player_array['sub_job_id'] == 16 and player_array['pet_index']~=0 then
		local pet_array = get_mob_by_index(get_mob_by_id(player_array.id)['pet_index'])
		local recasts = get_ability_recasts()
		if pet_array['tp'] then -- Temp fix until pet TP is added.
			if pet_array['tp'] >= 100 and recasts[255] <= 5400 then -- If your pet has TP and Ready's recast is less than 1.5 minutes
				return 'Ability'
			else
				return 'Magic'
			end
		else
			return 'Ability'
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

berserk={absolute=true,abil_ID=31},
 
fireiv={absolute=false,spell_ID=147,abil_ID=549,funct=smn_unsub,info=60},
stoneiv={absolute=false,spell_ID=162,abil_ID=565,funct=smn_unsub,info=60},
wateriv={absolute=false,spell_ID=172,abil_ID=581,funct=smn_unsub,info=60},
aeroiv={absolute=false,spell_ID=157,abil_ID=597,funct=smn_unsub,info=60},
blizzardiv={absolute=false,spell_ID=152,abil_ID=613,funct=smn_unsub,info=60},
thunderiv={absolute=false,spell_ID=167,abil_ID=629,funct=smn_unsub,info=60},
thunderstorm={absolute=false,spell_ID=117,abil_ID=631,funct=smn_unsub,info=75},
 
frostbreath={absolute=false,spell_ID=610,abil_ID=647,funct=blu_unsub,info=66},
dreamflower={absolute=false,spell_ID=709,abil_ID=676,funct=blu_unsub,info=87},
infrasonics={absolute=false,spell_ID=609,abil_ID=687,funct=blu_unsub,info=65},
['1000needles']={absolute=false,spell_ID=683,abil_ID=699,funct=blu_unsub,info=62},
filamentedhold={absolute=false,spell_ID=640,abil_ID=729,funct=blu_unsub,info=52},
suddenlunge={absolute=false,spell_ID=559,abil_ID=736,funct=blu_unsub,info=95},
spiralspin={absolute=false,spell_ID=535,abil_ID=737,funct=blu_unsub,info=60},
chargedwhisker={absolute=false,spell_ID=655,abil_ID=746,funct=blu_unsub,info=88},
corrosiveooze={absolute=false,spell_ID=666,abil_ID=748,funct=blu_unsub,info=66},
fantod={absolute=false,spell_ID=601,abil_ID=752,funct=blu_unsub,info=85},
hardenshell={absolute=false,spell_ID=748,abil_ID=754,funct=blu_unsub,info=95},
 
barbedcrescent={absolute=false,spell_ID=699,abil_ID=1013,funct=blu_unsub,99,info=99},
dimensionaldeath={absolute=false,spell_ID=589,abil_ID=1023,funct=blu_unsub,info=60},
 
footkick={absolute=false,spell_ID=612,abil_ID=672,funct=blu_sub},
headbutt={absolute=false,spell_ID=518,abil_ID=675,funct=blu_sub},
wildoats={absolute=false,spell_ID=515,abil_ID=677,funct=blu_sub},
clawcyclone={absolute=false,spell_ID=522,abil_ID=682,funct=blu_sub},
sheepsong={absolute=false,spell_ID=677,abil_ID=692,funct=blu_sub},
metallicbody={absolute=false,spell_ID=637,abil_ID=697,funct=blu_sub},
queasyshroom={absolute=false,spell_ID=516,abil_ID=702,funct=blu_sub},
powerattack={absolute=false,spell_ID=513,abil_ID=707,funct=blu_sub},
cursedsphere={absolute=false,spell_ID=661,abil_ID=712,funct=blu_sub},
mandibularbite={absolute=false,spell_ID=531,abil_ID=717,funct=blu_sub},
soporific={absolute=false,spell_ID=697,abil_ID=718,funct=blu_sub},
geistwall={absolute=false,spell_ID=701,abil_ID=721,funct=blu_sub},
chaoticeye={absolute=false,spell_ID=617,abil_ID=730,funct=blu_sub},
wildcarrot={absolute=false,spell_ID=678,abil_ID=735,funct=blu_sub},
jettatura={absolute=false,spell_ID=703,abil_ID=750,funct=blu_sub},
 
sleepga={absolute=false,spell_ID=273,abil_ID=611,funct=smn_sub,info=T{4,'Shiva','Ward'}},
stoneii={absolute=false,spell_ID=160,abil_ID=561,funct=smn_sub,info=T{4,5,8,20,21,'Titan','Rage'}},
waterii={absolute=false,spell_ID=170,abil_ID=577,funct=smn_sub,info=T{4,5,8,20,21,'Leviathan','Rage'}},
fireii={absolute=false,spell_ID=145,abil_ID=545,funct=smn_sub,info=T{4,5,8,20,21,'Ifrit','Rage'}},
aeroii={absolute=false,spell_ID=155,abil_ID=593,funct=smn_sub,info=T{4,5,8,20,21,'Garuda','Rage'}},
blizzardii={absolute=false,spell_ID=150,abil_ID=609,funct=smn_sub,info=T{4,5,8,20,21,'Shiva','Rage'}},
thunderii={absolute=false,spell_ID=165,abil_ID=625,funct=smn_sub,info=T{4,5,8,20,21,'Ramuh','Rage'}}
}
 
function ambig(key)
	local abil_type
	if ambig_names[key] == nil then
		write('Shortcuts Bug: '..tostring(key))
		return
	end
	if ambig_names[key].absolute then
		if ambig_names[key].spell_ID then return r_spells[ambig_names[key].spell_ID]
		elseif ambig_names[key].abil_ID then return r_abilities[ambig_names[key].abil_ID]
		end
	else
		abil_type=ambig_names[key]['funct'](get_player(),ambig_names[key].info)
		if abil_type == 'Ability' then
			return r_abilities[ambig_names[key].abil_ID],abil_type
		elseif abil_type == 'Magic' then
			return r_spells[ambig_names[key].spell_ID],abil_type
		end
	end
	return '',''
end
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

r_abilities = parse_resources(jaFile:readlines())
r_spells = parse_resources(speFile:readlines())


-- Convert the spells and job abilities into a referenceable list of aliases --
validabils = T{}

if logging then
	f = io.open('../addons/shortcuts/data/'..tostring(os.clock())..'_all_duplicates.log','w+')
	counter = 0
end


-----------------------------------------------------------------------------------
--Name: make_abil()
--Args:
---- abil (string): ability name to be stripped
---- t (string): type of ability (Magic or Ability)
---- i (number): index id
-----------------------------------------------------------------------------------
--Returns:
---- Nothing, adds a new line to validabils or modifies it.
-----------------------------------------------------------------------------------
function make_abil(abil,t,i)
	if abil:sub(1,1) == '#' or string.find(abil:lower(),'magic'..string.char(0x40)) then return end
	ind = strip(abil)
	if not rawget(validabils,ind) or (rawget(validabils,ind).typ == t and rawget(validabils,ind).index == i) then
		validabils[ind] = {}
		validabils[ind].typ = t
		validabils[ind].index = i
	else
--		write(tostring(validabils[ind]))
		if logging then
			f:write('Original: '..tostring(abil)..' '..tostring(validabils[ind].typ)..' '..tostring(validabils[ind].index)..'\nSecondary: '..tostring(abil)..' '..tostring(t)..' '..tostring(i)..'\n\n')
			counter = counter +1
		end
		validabils[ind] = {}
		validabils[ind].typ = 'ambig_names'
		validabils[ind].index = ind
	end
end


-- Iterate through spells.xml and make validabils.
for i,v in pairs(r_spells) do
	v['validtarget'] = {Self=false,Player=false,Party=false,Ally=false,NPC=false,Enemy=false}
	local potential_targets = split(v['targets'],', ')
	for n,m in pairs(potential_targets) do
		v['validtarget'][m] = true
	end
	
	make_abil(v['english'],'r_spells',i)
	if v['alias'] then
		local struck = split(v['alias'],'|')
		for n,m in pairs(struck) do
			make_abil(m,'r_spells',i)
		end
	end
end

-- Iterate through abils.xml and make validabils.
for i,v in pairs(r_abilities) do
	v['validtarget'] = {Self=false,Player=false,Party=false,Ally=false,NPC=false,Enemy=false}
	local potential_targets = split(v['targets'],', ')
	for n,m in pairs(potential_targets) do
		v['validtarget'][m] = true
	end
	
	make_abil(v['english'],'r_abilities',i)
	if v['alias'] then
		local struck = split(v['alias'],'|')
		for n,m in pairs(struck) do
			make_abil(m,'r_abilities',i)
		end
	end
end

if logging then
	f:write('Counter: '..tostring(counter))
	f:close()
end

--f = io.open('../addons/pr/data/'..tostring(os.clock())..'.log','w+')
--for i,v in pairs(validabils) do
--	f:write(tostring(i)..' '..tostring(v)..'\n')
--end

-- Constants used in the rest of the addon.

-- List of valid prefixes to be interpreted. The values currently have no use.
command_list = {['/ja']='Ability',['/jobability']='Ability',['/so']='Magic',['/song']='Magic',['/ma']='Magic',['/magic']='Magic',['/nin']='Magic',['/ninjutsu']='Magic',
	['/ra']='Ranged Attack',['/range']='Ranged Attack',['/throw']='Ranged Attack',['/shoot']='Ranged Attack',['/monsterskill']='Ability',['/ms']='Ability',
	['/ws']='Weapon Skill',['/weaponskill']='Weapon Skill',['/item']='Ability',['/pet']='Ability'}

-- List of other commands that might use name completion.
command2_list = {['/kick']=true,['/assist']=true,['/alliancecmd']=T{'kick','add','leader','breakup','leave','looter'},['/partycmd']=T{'kick','add','leader','breakup','leave','looter'},
	['/acmd']=T{'kick','add','leader','breakup','leave','looter'},['/pcmd']=T{'kick','add','leader','breakup','leave','looter'},
	['/wave']=T{'motion'},['/poke']=T{'motion'},['/dance']=T{'motion'},['/dance1']=T{'motion'},['/dance2']=T{'motion'},['/dance3']=T{'motion'},['/dance4']=T{'motion'},['/amazed']=T{'motion'},
	['/angry']=T{'motion'},['/bell']=T{'motion'},['/bellsw']=T{'motion'},['/blush']=T{'motion'},['/bow']=T{'motion'},['/cheer']=T{'motion'},['/clap']=T{'motion'},['/comfort']=T{'motion'},['/cry']=T{'motion'},
	['/disgusted']=T{'motion'},['/doze']=T{'motion'},['/doubt']=T{'motion'},['/huh']=T{'motion'},['/farewell']=T{'motion'},['/goodbye']=T{'motion'},['/fume']=T{'motion'},['/grin']=T{'motion'},['/hurray']=T{'motion'},
	['/joy']=T{'motion'},['/kneel']=T{'motion'},['/laugh']=T{'motion'},['/muted']=T{'motion'},['/kneel']=T{'motion'},['/laugh']=T{'motion'},['/no']=T{'motion'},['/nod']=T{'motion'},['/yes']=T{'motion'},
	['/panic']=T{'motion'},['/point']=T{'motion'},['/praise']=T{'motion'},['/psych']=T{'motion'},['/salute']=T{'motion'},['/shocked']=T{'motion'},['/sigh']=T{'motion'},['/sit']=T{'motion'},['/slap']=T{'motion'},
	['/smile']=T{'motion'},['/stagger']=T{'motion'},['/stare']=T{'motion'},['/sulk']=T{'motion'},['/surprised']=T{'motion'},['/think']=T{'motion'},['/toss']=T{'motion'},['/upset']=T{'motion'},['/welcome']=T{'motion'},
	['/check']=true,['/c']=true,['/breaklinkshell']=true,['/target']=true,['/ta']=true,['/ra']=true,['/targetnpc']=true,['/follow']=true}

-- List of commands to be ignored
ignore_list = {['/equip']=true,['/raw']=true,['/fish']=true,['/dig']=true,['/range']=true,['/map']=true,['/hide']=true}

-- Targets to ignore and just pass through
pass_through_targs = T{'<t>','<me>','<ft>','<scan>','<bt>','<lastst>','<r>','<pet>','<p0>','<p1>','<p2>','<p3>','<p4>',
	'<p5>','<a10>','<a11>','<a12>','<a13>','<a14>','<a15>','<a20>','<a21>','<a22>','<a23>','<a24>','<a25>','<stpc>','<stal>','<stnpc>','<stpt>'}

targ_reps = {t='<t>',me='<me>',ft='<ft>',scan='<scan>',bt='<bt>',lastst='<lastst>',r='<r>',pet='<pet>',p0='<p0>',p1='<p1>',p2='<p2>',p3='<p3>',p4='<p4>',
	p5='<p5>',a10='<a10>',a11='<a11>',a12='<a12>',a13='<a13>',a14='<a14>',a15='<a15>',a20='<a20>',a21='<a21>',a22='<a22>',a23='<a23>',a24='<a24>',a25='<a25>',
	stpc='<stpc>',stal='<stal>',stnpc='<stnpc>',stpt='<stpt>'}
	
language = 'english' -- get_ffxi_info()['language']:lower()
known_spells = windower.ffxi.get_spells()
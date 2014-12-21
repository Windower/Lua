--Copyright (c) 2014, Byrthnoth
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation andor other materials provided with the distribution.
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
validabils = {}

--f = io.open('..addonsprdata'..tostring(os.clock())..'.log','w+')
--for i,v in pairs(validabils) do
--	f:write(tostring(i)..' '..tostring(v)..'\n')
--end

-- Constants used in the rest of the addon.

-- List of valid prefixes to be interpreted. The values currently have no use.
command_list = {['ja']='job_abilities',['jobability']='job_abilities',['so']='spells',['song']='spells',['ma']='spells',['magic']='spells',['nin']='spells',['ninjutsu']='spells',
	['ra']='Ranged Attack',['range']='Ranged Attack',['throw']='Ranged Attack',['shoot']='Ranged Attack',['monsterskill']='monster_abilities',['ms']='monster_abilities',
	['ws']='weapon_skills',['weaponskill']='weapon_skills',['item']='Ability',['pet']='job_abilities'}
    
in_game_res_commands = {['ja']='/ja',['jobability']='/ja',['pet']='/ja',
    ['so']='/ma',['song']='/ma',['ma']='/ma',['magic']='/ma',['nin']='/ma',['ninjutsu']='/ma',
    ['monsterskill']='/ms',['ms']='/ms',['ws']='/ws',['weaponskill']='/ws',
	['ra']='/ra',['range']='/ra',['throw']='/ra',['shoot']='/ra'}

-- List of other commands that might use name completion.
command2_list = {['kick']=true,['assist']=true,['alliancecmd']=T{'kick','add','leader','breakup','leave','looter'},['partycmd']=T{'kick','add','leader','breakup','leave','looter'},
	['acmd']=T{'kick','add','leader','breakup','leave','looter'},['pcmd']=T{'kick','add','leader','breakup','leave','looter'},
	['wave']=T{'motion'},['poke']=T{'motion'},['dance']=T{'motion'},['dance1']=T{'motion'},['dance2']=T{'motion'},['dance3']=T{'motion'},['dance4']=T{'motion'},['amazed']=T{'motion'},
	['angry']=T{'motion'},['bell']=T{'motion'},['bellsw']=T{'motion'},['blush']=T{'motion'},['bow']=T{'motion'},['cheer']=T{'motion'},['clap']=T{'motion'},['comfort']=T{'motion'},['cry']=T{'motion'},
	['disgusted']=T{'motion'},['doze']=T{'motion'},['doubt']=T{'motion'},['huh']=T{'motion'},['farewell']=T{'motion'},['goodbye']=T{'motion'},['fume']=T{'motion'},['grin']=T{'motion'},['hurray']=T{'motion'},
	['joy']=T{'motion'},['kneel']=T{'motion'},['laugh']=T{'motion'},['muted']=T{'motion'},['kneel']=T{'motion'},['laugh']=T{'motion'},['no']=T{'motion'},['nod']=T{'motion'},['yes']=T{'motion'},
	['panic']=T{'motion'},['point']=T{'motion'},['praise']=T{'motion'},['psych']=T{'motion'},['salute']=T{'motion'},['shocked']=T{'motion'},['sigh']=T{'motion'},['sit']=T{'motion'},['slap']=T{'motion'},
	['smile']=T{'motion'},['stagger']=T{'motion'},['stare']=T{'motion'},['sulk']=T{'motion'},['surprised']=T{'motion'},['think']=T{'motion'},['toss']=T{'motion'},['upset']=T{'motion'},['welcome']=T{'motion'},
	['check']=true,['c']=true,['checkparam']=true,['breaklinkshell']=true,['target']=true,['ta']=true,['ra']=true,['targetnpc']=true,['follow']=true}
	
unhandled_list = {['p']=true,['s']=true,['sh']=true,['yell']=true,['echo']=true,['t']=true,['l']=true}

-- List of commands to be ignored
ignore_list = {['equip']=true,['raw']=true,['fish']=true,['dig']=true,['range']=true,['map']=true,['hide']=true,['attackoff']=true,['quest']=true}

-- Targets to ignore and just pass through
pass_through_targs = T{'<t>','<me>','<ft>','<scan>','<bt>','<lastst>','<r>','<pet>','<p0>','<p1>','<p2>','<p3>','<p4>',
	'<p5>','<a10>','<a11>','<a12>','<a13>','<a14>','<a15>','<a20>','<a21>','<a22>','<a23>','<a24>','<a25>'}

st_targs = T{'<st>','<stpc>','<stal>','<stnpc>','<stpt>'}

targ_reps = {t='<t>',me='<me>',ft='<ft>',scan='<scan>',bt='<bt>',lastst='<lastst>',r='<r>',pet='<pet>',p0='<p0>',p1='<p1>',p2='<p2>',p3='<p3>',p4='<p4>',
	p5='<p5>',a10='<a10>',a11='<a11>',a12='<a12>',a13='<a13>',a14='<a14>',a15='<a15>',a20='<a20>',a21='<a21>',a22='<a22>',a23='<a23>',a24='<a24>',a25='<a25>',
	st='<st>',stpc='<stpc>',stal='<stal>',stnpc='<stnpc>',stpt='<stpt>'}
	
language = 'english' -- windower.ffxi.get_info()['language']:lower()


-----------------------------------------------------------------------------------
--Name: make_abil()
--Args:
---- ind (string): stripped ability name
---- t (string): type of ability (Magic or Ability)
---- i (number): index id
-----------------------------------------------------------------------------------
--Returns:
---- Nothing, adds a new line to validabils or modifies it.
-----------------------------------------------------------------------------------
function make_abil(ind,res,id)
    validabils[ind] = validabils[ind] or L{}
    validabils[ind]:append({res=res,id=id})
end

-- Iterate through resources and make validabils.
function validabils_it(resource)
    for id,v in pairs(res[resource]) do
        if (not v.monster_level and v.prefix) or (v.monster_level and v.monster_level ~= -1 and v.ja:sub(1,1) ~= '#' ) then
        -- Monster Abilities contains a large number of player-usable moves (but not monstrosity-usable). This excludes them.
            make_abil(strip(v.english),resource,id)
        end
    end
end

validabils_it('spells')
validabils_it('job_abilities')
validabils_it('weapon_skills')
validabils_it('monster_abilities')
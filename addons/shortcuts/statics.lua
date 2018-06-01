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

-- List of valid prefixes to be interpreted with the resources. The values currently have no use.
command_list = {['ja']='job_abilities',['jobability']='job_abilities',['so']='spells',['song']='spells',['ma']='spells',['magic']='spells',['nin']='spells',['ninjutsu']='spells',
	['ra']='Ranged Attack',['range']='Ranged Attack',['throw']='Ranged Attack',['shoot']='Ranged Attack',['monsterskill']='monster_abilities',['ms']='monster_abilities',
	['ws']='weapon_skills',['weaponskill']='weapon_skills',['item']='Ability',['pet']='job_abilities',['mo']='mounts',['mount']='mounts'}
    
in_game_res_commands = {['ja']='/ja',['jobability']='/ja',['pet']='/ja',
    ['so']='/ma',['song']='/ma',['ma']='/ma',['magic']='/ma',['nin']='/ma',['ninjutsu']='/ma',
    ['monsterskill']='/ms',['ms']='/ms',['ws']='/ws',['weaponskill']='/ws',
	['ra']='/ra',['range']='/ra',['throw']='/ra',['shoot']='/ra',['mount']='/mo',['mo']='/mo'}

-- List of other commands that might use name completion.
local No_targets = {['Player']=false,['Enemy']=false,['Party']=false,['Ally']=false,['NPC']=false,['Self']=false,['Corpse']=false}
local All_targets = {['Player']=true,['Enemy']=true,['Party']=true,['Ally']=true,['NPC']=true,['Self']=true,['Corpse']=true}
local PC_targets = {['Player']=true,['Enemy']=false,['Party']=true,['Ally']=true,['NPC']=false,['Self']=true,['Corpse']=true}
local Party_targets = {['Player']=false,['Enemy']=false,['Party']=true,['Ally']=false,['NPC']=false,['Self']=true,['Corpse']=true}
local Alliance_targets = {['Player']=false,['Enemy']=false,['Party']=false,['Ally']=true,['NPC']=false,['Self']=true,['Corpse']=true}
local BST_targets = {['Player']=true,['Enemy']=false,['Party']=false,['Ally']=false,['NPC']=false,['Self']=true,['Corpse']=false}

local function new_cmd_entry(default_targets,subcommands)
    local rettab = table.reassign({},default_targets)
    if subcommands then
        rettab.args = subcommands
    end
    return rettab
end

local emote_table = new_cmd_entry(All_targets,{motion=true})

command2_list = {
    --['kick']=true, --Is this actually a command?
    ['assist']=All_targets,
    ['alliancecmd']=new_cmd_entry(No_targets,{
            kick=Alliance_targets,
            add=PC_targets,
            leader=Alliance_targets,
            breakup=true,
            leave=true,
            looter=Alliance_targets}),
    ['partycmd']=new_cmd_entry(No_targets,{
            kick=Party_targets,
            add=PC_targets,
            leader=Party_targets,
            breakup=true,
            leave=true,
            looter=Party_targets}),
    ['acmd']=new_cmd_entry(No_targets,{
            kick=Alliance_targets,
            add=PC_targets,
            leader=Alliance_targets,
            breakup=true,
            leave=true,
            looter=Alliance_targets}),
    ['pcmd']=new_cmd_entry(No_targets,{
            kick=Party_targets,
            add=PC_targets,
            leader=Party_targets,
            breakup=true,
            leave=true,
            looter=Party_targets}),
	['wave']=emote_table,
    ['poke']=emote_table,
    ['dance']=emote_table,
    ['dance1']=emote_table,
    ['dance2']=emote_table,
    ['dance3']=emote_table,
    ['dance4']=emote_table,
    ['amazed']=emote_table,
	['angry']=emote_table,
    ['bell']=emote_table,
    ['bellsw']=emote_table,
    ['blush']=emote_table,
    ['bow']=emote_table,
    ['cheer']=emote_table,
    ['clap']=emote_table,
    ['comfort']=emote_table,
    ['cry']=emote_table,
	['disgusted']=emote_table,
    ['doze']=emote_table,
    ['doubt']=emote_table,
    ['huh']=emote_table,
    ['farewell']=emote_table,
    ['goodbye']=emote_table,
    ['fume']=emote_table,
    ['grin']=emote_table,
    ['hurray']=emote_table,
	['joy']=emote_table,
    ['kneel']=emote_table,
    ['laugh']=emote_table,
    ['muted']=emote_table,
    ['kneel']=emote_table,
    ['laugh']=emote_table,
    ['no']=emote_table,
    ['nod']=emote_table,
    ['yes']=emote_table,
	['panic']=emote_table,
    ['point']=emote_table,
    ['praise']=emote_table,
    ['psych']=emote_table,
    ['salute']=emote_table,
    ['shocked']=emote_table,
    ['sigh']=emote_table,
    ['sit']=emote_table,
    ['slap']=emote_table,
	['smile']=emote_table,
    ['stagger']=emote_table,
    ['stare']=emote_table,
    ['sulk']=emote_table,
    ['surprised']=emote_table,
    ['think']=emote_table,
    ['toss']=emote_table,
    ['upset']=emote_table,
    ['welcome']=emote_table,
	['check']=new_cmd_entry(PC_targets),
    ['c']=new_cmd_entry(PC_targets),
    ['checkparam']=new_cmd_entry({['Player']=false,['Enemy']=false,['Party']=false,['Ally']=false,['NPC']=false,['Self']=true,['Corpse']=false},{}), -- Blank table forces it into the second processing stream, which lets it default to <me>
    ['target']=new_cmd_entry(PC_targets),
    ['ta']=new_cmd_entry(PC_targets),
    ['ra']=new_cmd_entry({['Player']=false,['Enemy']=true,['Party']=false,['Ally']=false,['NPC']=false,['Self']=false,['Corpse']=false}),
    ['follow']=new_cmd_entry(All_targets),
    ['recruit']=new_cmd_entry(PC_targets),
    ['rec']=new_cmd_entry(PC_targets),
    ['retr']=new_cmd_entry(Party_targets,{all=No_targets}),
    ['returntrust']=new_cmd_entry(Party_targets,{all=No_targets}),
    ['refa']=new_cmd_entry(Party_targets,{all=No_targets}),
    ['returnfaith']=new_cmd_entry(Party_targets,{all=No_targets}),
    ['bstpet']=new_cmd_entry(No_targets,{['1']=BST_targets,['2']=BST_targets,['3']=BST_targets,['4']=BST_targets,['5']=BST_targets,['6']=BST_targets,['7']=BST_targets}),
    }
	
unhandled_list = {['p']=true,['s']=true,['sh']=true,['yell']=true,['echo']=true,['t']=true,['l']=true,['breaklinkshell']=true}

-- List of commands to be ignored
ignore_list = {['equip']=true,['raw']=true,['fish']=true,['dig']=true,['range']=true,['map']=true,['hide']=true,['jump']=true,['attackoff']=true,['quest']=true,['recruitlist']=true,['rlist']=true,['statustimer']=true}

-- Targets to ignore and just pass through
pass_through_targs = T{'<t>','<me>','<ft>','<scan>','<bt>','<lastst>','<r>','<pet>','<p0>','<p1>','<p2>','<p3>','<p4>',
	'<p5>','<a10>','<a11>','<a12>','<a13>','<a14>','<a15>','<a20>','<a21>','<a22>','<a23>','<a24>','<a25>','<focust>'}

st_targs = T{'<st>','<stpc>','<stal>','<stnpc>','<stpt>'}

targ_reps = {t='<t>',me='<me>',ft='<ft>',scan='<scan>',bt='<bt>',lastst='<lastst>',r='<r>',pet='<pet>',p0='<p0>',p1='<p1>',p2='<p2>',p3='<p3>',p4='<p4>',
	p5='<p5>',a10='<a10>',a11='<a11>',a12='<a12>',a13='<a13>',a14='<a14>',a15='<a15>',a20='<a20>',a21='<a21>',a22='<a22>',a23='<a23>',a24='<a24>',a25='<a25>',
	st='<st>',stpc='<stpc>',stal='<stal>',stnpc='<stnpc>',stpt='<stpt>',focust='<focust>'}
	
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
validabils_it('mounts')
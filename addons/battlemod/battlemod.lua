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
file = require 'filehelper'
config = require 'config'
require 'tablehelper'
require 'event_action'
require 'generic_helpers'

function event_load()
	debugging = false
	allow = true
	prevline = ''

	color_arr = {}
	filter = {}
	line_full = 'Full line is not loading'
	line_noactor = 'No Actor line is not loading'
	line_nonumber = 'No Number line is not loading'
	line_aoebuff = 'AoE Buff line is not loading'
	line_roll = 'Roll line is not loading'
	skillchain_arr = {'Light:','Darkness:','Gravitation:','Fragmentation:','Distortion:','Fusion:','Compression:','Liquefaction:','Induration:','Reverberation:','Transfixion:','Scission:','Detonation:','Impaction:'}
	ratings_arr = {'TW','EP','DC','EM','T','VT','IT'}
    send_command('alias bm lua c battlemod cmd')
	blocked_colors = T{20,21,22,23,24,25,26,28,29,31,32,33,35,36,40,41,42,43,44,50,51,52,56,57,59,60,69,64,65,67,69,81,85,90,91,100,101,102,104,105,106,110,111,112,114,122,163,164,168,171,175,177,183,185,186,191}
	passed_messages = T{4,5,6,17,18,20,34,35,36,48,64,78,87,88,89,90,116,154,170,171,172,173,174,175,176,177,178,191,192,198,204,206,217,218,234,249,313,328,350,531,558,561,575,601,609,610,611,612,613,614,615,616,617,618,619,620,625,626,627,628,629,630,631,632,633,634,635,636,643}
	agg_messages = T{75,93,116,131,134,144,146,148,150,206,230,236,237,319,364,414,420,422,424,425,426,570,668}
	color_redundant = T{26,33,41,71,72,89,94,109,114,164,173,181,184,186,70,84,104,127,128,129,130,131,132,133,134,135,136,137,138,139,140,64,86,91,106,111,175,178,183,81,101,16,65,87,92,107,112,174,176,182,82,102,67,68,69,170,189,15,208,18,25,32,40,163,185,23,24,27,34,35,42,43,162,165,187,188,30,31,14,205,144,145,146,147,148,149,150,151,152,153,190,13,9,253,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,284,285,286,287,292,293,294,295,300,301,301,303,308,309,310,311,316,317,318,319,324,325,326,327,332,333,334,335,340,341,342,343,344,345,346,347,348,349,350,351,355,357,358,360,361,363,366,369,372,374,375,378,381,384,395,406,409,412,415,416,418,421,424,437,450,453,456,458,459,462,479,490,493,496,499,500,502,505,507,508,10,51,52,55,58,62,66,80,83,85,88,90,93,100,103,105,108,110,113,122,168,169,171,172,177,179,180,12,11}
	black_colors = T{352,354,356,388,390,400,402,430,432,442,444,472,474,484,486}
	
	speFile = file.new('../../plugins/resources/spells.xml')
	jaFile = file.new('../../plugins/resources/abils.xml')
	statusFile = file.new('../../plugins/resources/status.xml')
	dialogFile = file.new('../../addons/libs/resources/dialog4.xml')
	mabilsFile = file.new('../../addons/libs/resources/mabils.xml')
	itemsGFile = file.new('../../plugins/resources/items_general.xml')
	itemsAFile = file.new('../../plugins/resources/items_armor.xml')
	itemsWFile = file.new('../../plugins/resources/items_weapons.xml')
	
	jobabilities = parse_resources(jaFile:readlines())
	spells = parse_resources(speFile:readlines())
	statuses = parse_resources(statusFile:readlines())
	dialog = parse_resources(dialogFile:readlines())
	mabils = parse_resources(mabilsFile:readlines())
	statuses = parse_resources(statusFile:readlines())
	items = parse_resources(itemsGFile:readlines())
	
	for i,v in pairs(parse_resources(itemsAFile:readlines())) do
		items[i]=v
	end
	for i,v in pairs(parse_resources(itemsWFile:readlines())) do
		items[i]=v
	end
		
	options_load()
	collectgarbage()
end

function options_load()
	local settingsFile = file.new('data/settings.xml',true)
	local filterFile=file.new('data/filters/filters.xml',true)
	local colorsFile=file.new('data/colors.xml',true)
	
	if not file.exists('data/settings.xml') then
		settingsFile:write([[
<?xml version="1.0" ?>
<!-- For the output customization lines, ${actor} denotes a value to be replaced. The options are actor, number, abil, and target.
	 Options for other modes are either "true" or "false". Other values will not be interpreted.-->
<settings>
	<global>
		<condensebattle>true</condensebattle>
		<condensebuffs>true</condensebuffs>
		<cancelmulti>true</cancelmulti>
		<oxford>true</oxford>
		<commamode>false</commamode>
		<supersilence>true</supersilence>
		<targetnumber>true</targetnumber>
		
		
		<line_full>[${actor}] ${number} ${abil} ¨ ${target}</line_full>
		<line_noactor>${abil} ${number} ¨ ${target}</line_noactor>
		<line_nonumber>[${actor}] ${abil} ¨ ${target}</line_nonumber>
		<line_aoebuff>${actor} ${abil} ¨ ${target} (${status})</line_aoebuff>
		<line_roll>${actor} ${abil} ¨ ${target} ª ${number}</line_roll>
	</global>
</settings>
]])
		write('Default settings xml file created')
	end
	
	local settingtab = config.load('data/settings.xml',true)
	for i,v in pairs(settingtab) do
		_G[i] = v
	end
	local tempplayer = get_player()
	if tempplayer~=nil then
		filterload(tempplayer['main_job'])
	else
		if not file.exists('data/filters/filters.xml') then
			filterFile:write([[
<?xml version="1.0" ?>
<!-- Filters are customizable based on the action user. So if you filter other pets, you're going
     to eliminate all messages initiated by everyone's pet but your own.
     True means "filter this"
     False means "don't filter this"
	 
	 Generally, the outer tag is the actor and the inner tag is the action.
	 If the monster is the actor, then the inner tag is the target and the tag beyond that is the action.-->
<settings>
    <global>
        <me> <!-- You're doing something -->
            <melee>false</melee>
            <ranged>false</ranged>
            <damage>false</damage>
            <healing>false</healing>
            <misses>false</misses>
            <readies>false</readies>
            <casting>false</casting>
            <all>false</all>
        </me>
        <party> <!-- A party member is doing something -->
            <melee>false</melee>
            <ranged>false</ranged>
            <damage>false</damage>
            <healing>false</healing>
            <misses>false</misses>
            <readies>false</readies>
            <casting>false</casting>
            <all>false</all>
        </party>
        <alliance> <!-- An alliance member is doing something -->
            <melee>false</melee>
            <ranged>false</ranged>
            <damage>false</damage>
            <healing>false</healing>
            <misses>false</misses>
            <readies>false</readies>
            <casting>false</casting>
            <all>false</all>
        </alliance>
        <others> <!-- Some guy nearby is doing something -->
            <melee>false</melee>
            <ranged>false</ranged>
            <damage>false</damage>
            <healing>false</healing>
            <misses>false</misses>
            <readies>false</readies>
            <casting>false</casting>
            <all>false</all>
        </others>
        <my_pet> <!-- Your pet is doing something -->
            <melee>false</melee>
            <ranged>false</ranged>
            <damage>false</damage>
            <healing>false</healing>
            <misses>false</misses>
            <readies>false</readies>
            <casting>false</casting>
            <all>false</all>
        </my_pet>
        <other_pets> <!-- Someone else's pet is doing something -->
            <melee>false</melee>
            <ranged>false</ranged>
            <damage>false</damage>
            <healing>false</healing>
            <misses>false</misses>
            <readies>false</readies>
            <casting>false</casting>
            <all>false</all>
        </other_pets>
		
		
        <monsters> <!-- Monster is doing something with one of the below targets -->
			<me> <!-- He's targeting you! -->
				<melee>false</melee>
				<ranged>false</ranged>
				<damage>false</damage>
				<healing>false</healing>
				<misses>false</misses>
				<readies>false</readies>
				<casting>false</casting>
				<all>false</all>
			</me>
			<party> <!-- He's targeting a party member -->
				<melee>false</melee>
				<ranged>false</ranged>
				<damage>false</damage>
				<healing>false</healing>
				<misses>false</misses>
				<readies>false</readies>
				<casting>false</casting>
				<all>false</all>
			</party>
			<alliance> <!-- He's targeting an alliance member -->
				<melee>false</melee>
				<ranged>false</ranged>
				<damage>false</damage>
				<healing>false</healing>
				<misses>false</misses>
				<readies>false</readies>
				<casting>false</casting>
				<all>false</all>
			</alliance>
			<others> <!-- He's targeting some guy nearby -->
				<melee>false</melee>
				<ranged>false</ranged>
				<damage>false</damage>
				<healing>false</healing>
				<misses>false</misses>
				<readies>false</readies>
				<casting>false</casting>
				<all>false</all>
			</others>
			<my_pet> <!-- He's targeting your pet -->
				<melee>false</melee>
				<ranged>false</ranged>
				<damage>false</damage>
				<healing>false</healing>
				<misses>false</misses>
				<readies>false</readies>
				<casting>false</casting>
				<all>false</all>
			</my_pet>
			<other_pets> <!-- He's targeting someone else's pet -->
				<melee>false</melee>
				<ranged>false</ranged>
				<damage>false</damage>
				<healing>false</healing>
				<misses>false</misses>
				<readies>false</readies>
				<casting>false</casting>
				<all>false</all>
			</other_pets>
			
			<monsters> <!-- He's targeting himself or another monster -->
				<melee>false</melee>
				<ranged>false</ranged>
				<damage>false</damage>
				<healing>false</healing>
				<misses>false</misses>
				<readies>false</readies>
				<casting>false</casting>
				<all>false</all>
			</monsters>
        </monsters>
    </global>
</settings>
]])
			write('Default filters xml file created')
		end
		filter = config.load('data/filters/filters.xml',true)
	end
	
	if not file.exists('data/colors.xml') then
		colorsFile:write([[
<? xml version="1.0" ?>
<!-- Colors are customizable based on party / alliance position. Use the colortest command to view the available colors.
	 If you wish for a color to be unchanged from its normal color, set it to 0. -->
<settings>
	<global>
		<mob>69</mob>
		<other>8</other>
		
		<p0>501</p0>
		<p1>204</p1>
		<p2>410</p2>
		<p3>492</p3>
		<p4>259</p4>
		<p5>260</p5>
		
		<a10>205</a10>
		<a11>359</a11>
		<a12>167</a12>
		<a13>038</a13>
		<a14>125</a14>
		<a15>185</a15>
		
		<a20>429</a20>
		<a21>257</a21>
		<a22>200</a22>
		<a23>481</a23>
		<a24>483</a24>
		<a25>208</a25>
		
		<mobdmg>0</mobdmg>
		<mydmg>0</mydmg>
		<partydmg>0</partydmg>
		<allydmg>0</allydmg>
		<otherdmg>0</otherdmg>
		
		<spellcol>0</spellcol>
		<abilcol>0</abilcol>
		<wscol>0</wscol>
		<mobwscol>0</mobwscol>
		<statuscol>0</statuscol>
		<itemcol>256</itemcol>
	</global>
</settings>
]])
		write('Default colors xml file created')
	end
	
	local colortab = config.load('data/colors.xml',true)
	for i,v in pairs(colortab) do
		color_arr[i] = colconv(v,i)
	end
		
	add_to_chat(12,'Battlemod settings have been loaded!')
end

function event_job_change(mjob_id,mjob,mjob_lvl,sjob_id,sjob,sjob_lvl)
	filterload(mjob)
end

function filterload(job)	
	if file.exists('data/filters/filters-'..job..'.xml') then
		filter = config.load('data/filters/filters-'..job..'.xml',true)
		write('Loaded '..job..' filters')
	else
		filter = config.load('data/filters/filters.xml',true)
		write('Loaded default filters')
	end
end

function event_login(name)
	send_command('wait 10;bm reload')
end

function colconv(str,key)
	-- Used in the options_load() function
	local out
	strnum = tonumber(str)
	if strnum >= 256 and strnum < 509 then
		strnum = strnum - 254
		out = string.char(0x1E,strnum)
	elseif strnum >0 then
		out = string.char(0x1F,strnum)
	elseif strnum == 0 then
		out = string.char(0x1E,0x01)
	else
		write('You have an invalid color '..key)
		out = string.char(0x1F,1)
	end
	return out
end

function event_addon_command(...)
    local term = table.concat({...}, ' ')
    local splitarr = split(term,' ')
	if splitarr[1] == 'cmd' then
		if splitarr[2] ~= nil then
			if splitarr[2]:lower() == 'commamode' then
				commamode = not commamode
				add_to_chat(121,'Comma Mode flipped! - '..tostring(commamode))
			elseif splitarr[2]:lower() == 'oxford' then
				oxford = not oxford
				add_to_chat(121,'Oxford Mode flipped! - '..tostring(oxford))
			elseif splitarr[2]:lower() == 'targetnumber' then
				targetnumber = not targetnumber
				add_to_chat(121,'Target Number flipped! - '..tostring(targetnumber))
			elseif splitarr[2]:lower() == 'cancelmulti' then
				cancelmulti = not cancelmulti
				add_to_chat(121,'Multi-canceling flipped! - '..tostring(cancelmulti))
			elseif splitarr[2]:lower() == 'reload' then
				options_load()
			elseif splitarr[2]:lower() == 'unload' then
				send_command('lua u battlemod')
			elseif splitarr[2]:lower() == 'condensebattle' then
				condensebattle = not condensebattle
				add_to_chat(121,'Condensed Battle text flipped! - '..tostring(condensebattle))
			elseif splitarr[2]:lower() == 'condensebuffs' then
				condensebuffs = not condensebuffs
				add_to_chat(121,'Condensed Buffs text flipped! - '..tostring(condensebuffs))
			elseif splitarr[2]:lower() == 'cg' then
				collectgarbage()
			elseif splitarr[2]:lower() == 'colortest' then
				local counter = 0
				local line = ''
				for n = 1, 509 do
					if not color_redundant:contains(n) and not black_colors:contains(n) then
						if n <= 255 then
							loc_col = string.char(0x1F, n)
						else
							loc_col = string.char(0x1E, n - 254)
						end
						line = line..loc_col..string.format('%03d ', n)
						counter = counter + 1
					end
					if counter == 16 or n == 509 then
						add_to_chat(1, line)
						counter = 0
						line = ''
					end
				end
				add_to_chat(122,'Colors Tested!')
			elseif splitarr[2]:lower() == 'help' then
				write('Battlemod has 10 commands')
				write(' 1. help --- shows this menu')
				write(' 2. colortest --- Shows the 509 possible colors for use with the settings file')
				write(' 3. reload --- Reloads the settings file')
				write('Big Toggles:')
				write(' 4. condensebuffs --- Condenses Area of Effect buffs, Default = True')
				write(' 5. condensebattle --- Condenses battle logs according to your settings file, Default = True')
				write(' 6. cancelmulti --- Cancles multiple consecutive identical lines, Default = True')
				write('Sub Toggles:')
				write(' 7. oxford --- Toggle use of oxford comma, Default = True')
				write(' 8. commamode --- Toggle comma-only mode, Default = False')
				write(' 9. targetnumber --- Toggle target number display, Default = True')
			end
		end
	else
		if splitarr[1] == 'flip' then
			_G[splitarr[2]] = not _G[splitarr[2]]
			if splitarr[2] == 'allow' then
				prevline = ''
			end
		end
	end
end

function event_incoming_text(original, modified, color)
	local redcol = color%256
	
	if blocked_colors:contains(redcol) then
		if original:sub(1,4) ~= string.char(0x1F,0xFE,0x1E,0x01) then
			return '',color
		end
	end
	
	if redcol == 121 or redcol == 123 then
		if original == prevline and cancelmulti then
			a,b = string.find(original,'You buy ')
			g,b = string.find(original,'You were unable to buy ')
			h,b = string.find(original,' seems like a ')
			f,b = string.find(original,'You sell ')
			e,b = string.find(original,'%w+ synthesized ')
			c,b = string.find(original,' bought ')
			d,b = string.find(original,'You find a ')
			if a==nil and c==nil and d==nil and e==nil and f==nil and h==nil and g==nil then
				modified = ''
				if allow then
					send_command('wait 5;lua c battlemod flip allow')
					allow = false
				end
			end
		else
			prevline = original
		end
	end
	
	return modified,color
end

function event_action_message(actor_id,index,actor_target_index,target_target_index,message_id,param_1,param_2,param_3)
    -- Consider a way to condense "Wears off" messages?
	if passed_messages:contains(message_id) then
		local status,actor,target,spell,skill,number,number2
		local actor_table = get_mob_by_id(actor_id)
		local target_table = get_mob_by_id(index)
		local party_table = get_party()
		
		local actor = actor_table['name']
		local target = target_table['name']
		
		if message_id > 169 and message_id <179 then
			if param_1 == 4294967296 then
				skill = 'too weak to be worthwhile.'
				if debugging then
					write(param_1..' '..param_2..' '..param_3)
				end
			else
				skill = 'like level '..param_1
			end
			if debugging then write(param_1..'   '..param_2..'   '..param_3) end
		end
		
		if message_id == 558 then
			number = param_1
			number2 = param_2
		end
		
		if param_1 ~= 0 then
			status = nf(statuses[param_1],'english')
			spell = nf(spells[param_1],'english')
		end
		
		if status == nil then status = '' else
			status = color_arr['statuscol']..status..string.char(0x1E,0x01)
		end
		if spell == nil then spell = '' else
			spell = color_arr['spellcol']..spell..string.char(0x1E,0x01)
		end
		if target == nil then target = '' else
			target = namecol(target,target_table,party_table)
		end
		if actor == nil then actor = '' else
			actor = namecol(actor,actor_table,party_table)
		end
		if skill == nil then skill = '' else
			skill = color_arr['abilcol']..skill..string.char(0x1E,0x01)
		end
		
		local outstr = dialog[message_id]['english']:gsub('$\123actor\125',actor or ''):gsub('$\123status\125',status or ''):gsub('$\123target\125',target or ''):gsub('$\123spell\125',spell or ''):gsub('$\123skill\125',skill or ''):gsub('$\123number\125',number or ''):gsub('$\123number2\125',number2 or ''):gsub('$\123lb\125','\7')
		add_to_chat(dialog[message_id]['color'],string.char(0x1F,0xFE,0x1E,0x01)..outstr..string.char(127,49))
	elseif message_id == 16 or message_id == 62 or message_id == 251 then
	-- Message 16 is "casting is interrupted" :: This is redundant with event_action, so I'm ignoring it.
	-- 62 is "fails to activate" but it is color 121 so I cannot block it because I would also accidentally block a lot of system messages. Thus I have to ignore it.
	-- Message 251 is "about to wear off" but it is color 123 so I cannot block it because I would also block "you failed to swap that gear, idiot!" messages. Thus I have to ignore it.
	elseif message_id == 202 then
		if debugging then write('debug_EAM#'..message_id..': '..dialog[message_id]['english']..' '..param_1..'   '..param_2..'   '..param_3) end
	elseif debugging then 
		write('debug_EAM#'..message_id..': '..dialog[message_id]['english'])
	end
end

function event_unload()
	send_command('unalias bm')
end
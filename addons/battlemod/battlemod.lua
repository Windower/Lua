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


-- Libs --
file = require 'filehelper'
config = require 'config'
require 'tablehelper'

-- Battlemod Files --
require 'event_action'
require 'generic_helpers'

function event_load()
	version = '2.15'
	block_equip = false
	block_cannot = false
	prevline = ''

	color_arr = {}
	filter = {}
	wearing = {}
	line_full = '[${actor}] ${number} ${abil} '..string.char(129,168)..' ${target}'
	line_noactor = '${abil} ${number} '..string.char(129,168)..' ${target}'
	line_nonumber = '[${actor}] ${abil} '..string.char(129,168)..' ${target}'
	line_noabil = 'AOE ${number} '..string.char(129,168)..' ${target}'
	line_aoebuff = '${actor} ${abil} '..string.char(129,168)..' ${target} (${status})'
	line_roll = '${actor} ${abil} '..string.char(129,168)..'${target}'..string.char(129,170)..' ${number}'
	skillchain_arr = {'Light:','Darkness:','Gravitation:','Fragmentation:','Distortion:','Fusion:','Compression:','Liquefaction:','Induration:','Reverberation:','Transfixion:','Scission:','Detonation:','Impaction:'}
	ratings_arr = {'TW','EP','DC','EM','T','VT','IT'}
	rcol = string.char(0x1E,0x01)
	blocked_colors = T{20,21,22,23,24,25,26,28,29,30,31,32,33,35,36,37,40,41,42,43,44,50,51,52,56,57,59,60,61,63,68,69,64,65,67,69,81,85,90,91,100,101,102,104,105,106,107,110,111,112,114,122,127,162,163,164,166,168,170,171,174,175,177,182,183,185,186,191}
	passed_messages = T{4,5,6,16,17,18,20,34,35,36,40,47,48,49,64,78,87,88,89,90,112,116,154,170,171,172,173,174,175,176,177,178,191,192,198,204,215,217,218,234,246,249,328,350,336,531,558,561,575,601,609,562,610,611,612,613,614,615,616,617,618,619,620,625,626,627,628,629,630,631,632,633,634,635,636,643,660,661,662}
	agg_messages = T{85,653,655,75,156,189,248,323,355,408,422,425,82,93,116,127,131,134,151,144,146,148,150,166,186,194,230,236,237,242,243,268,271,319,320,364,375,412,414,416,420,424,426,432,433,441,602,645,668}
	color_redundant = T{26,33,41,71,72,89,94,109,114,164,173,181,184,186,70,84,104,127,128,129,130,131,132,133,134,135,136,137,138,139,140,64,86,91,106,111,175,178,183,81,101,16,65,87,92,107,112,174,176,182,82,102,67,68,69,170,189,15,208,18,25,32,40,163,185,23,24,27,34,35,42,43,162,165,187,188,30,31,14,205,144,145,146,147,148,149,150,151,152,153,190,13,9,253,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,284,285,286,287,292,293,294,295,300,301,301,303,308,309,310,311,316,317,318,319,324,325,326,327,332,333,334,335,340,341,342,343,344,345,346,347,348,349,350,351,355,357,358,360,361,363,366,369,372,374,375,378,381,384,395,406,409,412,415,416,418,421,424,437,450,453,456,458,459,462,479,490,493,496,499,500,502,505,507,508,10,51,52,55,58,62,66,80,83,85,88,90,93,100,103,105,108,110,113,122,168,169,171,172,177,179,180,12,11,37,291} -- 37 and 291 might be unique colors, but they are not gsubbable.
	black_colors = T{352,354,356,388,390,400,402,430,432,442,444,472,474,484,486}

--	resists = {85,284}
--	immunobreaks = {653,654}
--	complete_resists = {655,656}
--	no_effects = {75,156,189,248,323,355,408,422,425,283,423,659}
--	receives = {82,116,127,131,134,151,144,146,148,150,166,186,194,230,236,237,242,243,268,271,319,320,364,375,412,414,416,420,424,426,432,433,441,602,645,668,203,205,266,270,272,277,279,280,285,145,147,149,151,267,269,278,286,287,365,415,421,427}
--	vanishes = {93,273}
	
	message_map = {}
	for n=1,700,1 do
		message_map[n] = T{}
	end
	message_map[85] = T{284} -- resist
	message_map[653] = T{654} -- immunobreak
	message_map[655] = T{656} -- complete resist
	message_map[93] = T{273} -- vanishes
--	message_map[75] =  -- no effect spell
	message_map[156] = T{156,323,422,425} -- no effect ability
--	message_map[189] = -- no effect ws
--	message_map[408] = -- no effect item
	message_map[248] = T{355} -- no ability of any kind
	message_map['No effect'] = T{283,423,659} -- generic "no effect" messages for sorting by category
	
	message_map[432] = T{433} -- Receives: Spell, Target
	message_map[82] = T{230,236,237,268,271} -- Receives: Spell, Target, Status
	
	message_map[116] = T{131,134,144,146,148,150,364,414,416,441,602,668,285,145,147,149,151,286,287,365,415,421} -- Receives: Ability, Target
	message_map[127]=T{319,320,645} -- Receives: Ability, Target, Status
	
	message_map[420]=T{424} -- Receives: Ability, Target, Status, Number
	
	message_map[375] = T{412}-- Receives: Item, Target, Status
--	message_map[166] =  -- receives additional effect
	message_map[186] = T{194,242,243}-- Receives: Weapon skill, Target, Status
	message_map['Receives'] = T{203,205,266,270,272,277,279,280,267,269,278}
	message_map[426] = T{427} -- Loses
	no_effect_map = T{248,355,189,75,408,156,0,0,0,0,189,0,189,156,156}
	receives_map = T{0,0,186,82,375,116,0,0,0,0,186,0,186,116,116}
	stat_ignore = T{66,69,70,71,444,445,446}
	
	enfeebling = T{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,155,156,157,158,159,167,168,174,175,177,186,189,192,193,194,223,259,260,261,262,263,264,298,378,379,380,386,387,388,389,390,391,392,393,394,395,396,397,398,399,400,404,448,449,450,451,452,473,540,557,558,559,560,561,562,563,564,565,566,567}
	
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
	items = table.range(65535)
	items:update(parse_resources(itemsGFile:readlines()))
	items:update(parse_resources(itemsAFile:readlines()))
	items:update(parse_resources(itemsWFile:readlines()))
	
	enLog = {}
	for i,v in pairs({0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,134,135,155,156,157,168,176,177,259,260,261,262,263,264,309,474}) do
		enLog[v] = statuses[v]['enLog']
	end
	
    send_command('alias bm lua c battlemod cmd')
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
		<condensedamage>true</condensedamage>
		<condensebattle>true</condensebattle>
		<condensebuffs>true</condensebuffs>
		<cancelmulti>true</cancelmulti>
		<oxford>true</oxford>
		<commamode>false</commamode>
		<supersilence>true</supersilence>
		<targetnumber>true</targetnumber>
		
		
		<line_full>[${actor}] ${number} ${abil} ]]..string.char(129,168)..[[ ${target}</line_full>
		<line_noactor>${abil} ${number} ]]..string.char(129,168)..[[ ${target}</line_noactor>
		<line_nonumber>[${actor}] ${abil} ]]..string.char(129,168)..[[ ${target}</line_nonumber>
		<line_noabil>AOE ${number} ]]..string.char(129,168)..[[ ${target}</line_noabil>
		<line_aoebuff>${actor} ${abil} ]]..string.char(129,168)..[[ ${target} (${status})</line_aoebuff>
		<line_roll>${actor} ${abil} ]]..string.char(129,168)..[[ ${target} ]]..string.char(129,170)..[[ ${number}</line_roll>
	</global>
</settings>
]])
		write('Default settings xml file created')
	end
	
	local settingtab = config.load('data/settings.xml',true)
	for i,v in pairs(settingtab) do
		_G[i] = v
	end
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
            <melee>false</melee>  <!-- Prevents your melee ("white") damage from appearing -->
            <ranged>false</ranged> <!-- Prevents your ranged damage from appearing -->
            <damage>false</damage> <!-- Prevents your damage from appearing -->
            <healing>false</healing> <!-- Prevents your healing from appearing -->
            <misses>false</misses> <!-- Prevents your misses from appearing -->
            <items>false</items> <!-- Prevents your "Jim used an item. Jim gains the effect of Reraise." messages from appearing -->
            <uses>false</uses> <!-- Prevents your "Jim uses an item." messages from appearing -->
            <readies>false</readies> <!-- Prevents your "Jim readies ____" messages from appearing -->
            <casting>false</casting> <!-- Prevents your "Jim begins casting ____" messages from appearing -->
            <all>false</all> <!-- Prevents all of your messages from appearing -->
        </me>
        <party> <!-- A party member is doing something -->
            <melee>false</melee>
            <ranged>false</ranged>
            <damage>false</damage>
            <healing>false</healing>
            <misses>false</misses>
            <items>false</items>
            <uses>false</uses>
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
            <items>false</items>
            <uses>false</uses>
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
            <items>false</items>
            <uses>false</uses>
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
	
	local tempplayer = get_player()
	if tempplayer then
		filterload(tempplayer['main_job'])
	else
		filterload('DEFAULT')
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
		<enfeebcol>501</enfeebcol>
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
		
	write('Battlemod v'..version..' loaded.')
end

function event_job_change(mjob_id,mjob,mjob_lvl,sjob_id,sjob,sjob_lvl)
	filterload(mjob)
end

function filterload(job)	
	if file.exists('data/filters/filters-'..job..'.xml') then
		filter = config.load('data/filters/filters-'..job..'.xml',true)
		add_to_chat(12,'Loaded '..job..' Battlemod filters')
	else
		filter = config.load('data/filters/filters.xml',true)
		add_to_chat(12,'Loaded default Battlemod filters')
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
		out = rcol
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
			elseif splitarr[2]:lower() == 'condensedamage' then
				condensedamage = not condensedamage
				add_to_chat(121,'Condensed Damage text flipped! - '..tostring(condensedamage))
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
				write(' 6. condensedamage --- Condenses damage messages within attack rounds, Default = True')
				write(' 7. cancelmulti --- Cancles multiple consecutive identical lines, Default = True')
				write('Sub Toggles:')
				write(' 8. oxford --- Toggle use of oxford comma, Default = True')
				write(' 9. commamode --- Toggle comma-only mode, Default = False')
				write(' 10. targetnumber --- Toggle target number display, Default = True')
			end
		end
	else
		if splitarr[1] == 'flip' then
			_G[splitarr[2]] = not _G[splitarr[2]]
			if splitarr[2] == 'allow' then
				prevline = ''
			end
		elseif splitarr[1] == 'wearsoff' then
			local trash = table.remove(splitarr,1)
			local stat = table.concat(splitarr,' ')
			local len = #wearing[stat]
			local targets = table.remove(wearing[stat],1)
			for i,v in pairs(wearing[stat]) do
				if i < #wearing[stat] or commamode then
					targets = targets..', '
				else
					if oxford and #wearing[stat] >2 then
						targets = targets..','
					end
					targets = targets..' and '
				end
				targets = targets..v
			end
			if targetnumber and len > 1 then
				targets = '['..len..'] '..targets
			end
			local outstr = dialog[206]['english']:gsub('$\123target\125',targets):gsub('$\123status\125',stat)
			add_to_chat(191,string.char(0x1F,191)..outstr..string.char(127,49))
			wearing[stat] = nil
		end
	end
end

function event_incoming_text(original, modified, color)
	local redcol = color%256
	
	if redcol == 127 then
		a,z = string.find(original,' corpuscules of ')
		b,z = string.find(original,' experience points')
		if a or b then
			if original:sub(1,4) ~= string.char(0x1F,0xFE,0x1E,0x01) then
				return '',color
			end
		end
	elseif blocked_colors:contains(redcol) then
		if original:sub(1,4) ~= string.char(0x1F,0xFE,0x1E,0x01) then
			return '',color
		end
	end
	
	if redcol == 121 and cancelmulti then
		a,z = string.find(original,'Equipment changed.')
		
		if a and not block_equip then
			send_command('wait 1;lua c battlemod flip block_equip')
			block_equip = true
		elseif a and block_equip then
			modified = ''
		end
	end
	
	if redcol == 123 and cancelmulti then
		a,z = string.find(original,'You were unable to change your equipped items.')
		
		if a and not block_cannot then
			send_command('wait 1;lua c battlemod flip block_cannot')
			block_cannot = true
		elseif a and block_cannot then
			modified = ''
		end
	end
	
	return modified,color
end

function event_action_message(actor_id,index,actor_target_index,target_target_index,message_id,param_1,param_2,param_3)
    -- Consider a way to condense "Wears off" messages?
	if message_id == 206 then -- Wears off messages
		local status
		local target_table = get_mob_by_id(index)
		local party_table = get_party()
		local target = target_table['name']
		
		if enfeebling:contains(param_1) then
			status = color_it(statuses[param_1]['english'],color_arr['enfeebcol'])
		else
			status = color_it(statuses[param_1]['english'],color_arr['statuscol'])
		end
		
		if not wearing[status] and not (stat_ignore:contains(param_1)) then
			wearing[status] = {}
			wearing[status][1] = namecol(target,target_table,party_table)
			send_command('wait 0.5;lua c battlemod wearsoff '..status)
		elseif not (stat_ignore:contains(param_1)) then
			wearing[status][#wearing[status]+1] = namecol(target,target_table,party_table)
		else -- This handles the stat_ignore values, which are things like Utsusemi, Sneak, Invis, etc. that you don't want to see on a delay
			wearing[status] = {}
			wearing[status][1] = namecol(target,target_table,party_table)
			send_command('lua c battlemod wearsoff '..status)
		end
	elseif passed_messages:contains(message_id) then
		local status,actor,target,spell,skill,number,number2
		local actor_table = get_mob_by_id(actor_id)
		local target_table = get_mob_by_id(index)
		local party_table = get_party()
		
		local actor = actor_table['name']
		local target = target_table['name']
		
		if message_id > 169 and message_id <179 then
			if param_1 == 4294967296 then
				skill = 'like level -1'..' ('..ratings_arr[param_2+1]..')'
			else
				skill = 'like level '..param_1..' ('..ratings_arr[param_2+1]..')'
			end
			if debugging then write(param_1..'   '..param_2..'   '..param_3) end
		end
		
		if message_id == 558  then
			number2 = param_2
		end
		number = param_1
		
		if param_1 ~= 0 then
			status = (enLog[param_1] or nf(statuses[param_1],'english'))
			spell = nf(spells[param_1],'english')
		end
		
		if status then status = color_it(status,color_arr['statuscol']) end
		if spell then spell = color_it(spell,color_arr['spellcol']) end
		if target then target = namecol(target,target_table,party_table) end
		if actor then actor = namecol(actor,actor_table,party_table) end
		if skill then skill = color_it(skill,color_arr['abilcol']) end
		
		if actor ~= nil then
			local outstr = dialog[message_id]['english']:gsub('$\123actor\125',actor or ''):gsub('$\123status\125',status or ''):gsub('$\123target\125',target or ''):gsub('$\123spell\125',spell or ''):gsub('$\123skill\125',skill or ''):gsub('$\123number\125',number or ''):gsub('$\123number2\125',number2 or ''):gsub('$\123lb\125','\7')
			add_to_chat(dialog[message_id]['color'],string.char(0x1F,0xFE,0x1E,0x01)..outstr..string.char(127,49))
		end
	elseif T{62,94,251,308,313}:contains(message_id) then
	-- 62 is "fails to activate" but it is color 121 so I cannot block it because I would also accidentally block a lot of system messages. Thus I have to ignore it.
	-- Message 251 is "about to wear off" but it is color 123 so I cannot block it because I would also block "you failed to swap that gear, idiot!" messages. Thus I have to ignore it.
	-- Message 308 is "your inventory is full" but it is color 123.
	-- Message 313 is the red "target is out of range" message but it is color 123 so I cannot block it because I would also block "you failed to swap that gear, idiot!" messages. Thus I have to ignore it.
	elseif T{38,202}:contains(message_id) then
	-- 38 is the Skill Up message, which (interestingly) uses all the number params.
	-- 202 is the Time Remaining message, which (interestingly) uses all the number params.
		if debugging then write('debug_EAM#'..message_id..': '..dialog[message_id]['english']..' '..param_1..'   '..param_2..'   '..param_3) end
	elseif debugging then 
		write('debug_EAM#'..message_id..': '..dialog[message_id]['english'])
	end
end

function event_unload()
	send_command('unalias bm')
end

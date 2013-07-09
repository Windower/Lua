--Copyright (c) 2013, Thomas Rogers
--All rights reserved.
 
--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:
 
--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--   * Neither the name of highlight nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.
 
--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL THOMAS ROGERS BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
file = require 'filehelper'
chat = require 'chat'
require 'tablehelper'
require 'stringhelper'
 
_addon = {}
_addon.name = 'Highlight'
_addon.version = '1.0' 
 
members={}
mulenames={}
modmember={}
nicknames={}
color={}
mulecolor={}
previousmentions={}
 
config = require 'config'
 
defaults = {}
defaults.p0 = 501
defaults.p1 = 204
defaults.p2 = 410
defaults.p3 = 492
defaults.p4 = 259
defaults.p5 = 260
defaults.a10 = 205
defaults.a11 = 359
defaults.a12 = 167
defaults.a13 = 038
defaults.a14 = 125
defaults.a15 = 185
defaults.a20 = 429
defaults.a21 = 257
defaults.a22 = 200
defaults.a23 = 481
defaults.a24 = 483
defaults.a25 = 208
 
 
settingdefaults = {}
settingdefaults.highlighting = 'Yes'
 
 
local symbols = require('json').read('../libs/ffxidata.json').chat.chars
 
 
function event_load()
    send_count = 0 
    called_count = 0
    send_command('alias highlight lua c highlight')
	write(_addon['name']..': Version:'.._addon['version'])
	if get_ffxi_info()['logged_in'] then
        initialize()
    end
end
 
 
function event_addon_command(...)
    
	cmd = {...}
	
	if cmd[1] ~= nil then
		
		if cmd[1]:lower() == "help" then
			write('To view your last mentions type //highlight view <last number>')
		end
		
		
		
		if cmd[1]:lower() == 'write' then
			io.open(lua_base_path..'/logs/'..player..'.txt',"a"):write('\n =='..string.sub(os.date(),0,8)..'== \n'..table.concat(previousmentions, '\n')):close()
		end
 
		
		if cmd[1]:lower() == "view" and cmd[2] == nil then 
			add_to_chat(4, "==Recent Mentions==")
			if #previousmentions > 20 then
				for i=1, 20 do
					add_to_chat(4, previousmentions[i])
				end
			else 
				for i=1, #previousmentions do
					add_to_chat(4, previousmentions[i])
				end
			end
		elseif cmd[1]:lower() == "view" and cmd[2] ~=nil then
			if tonumber(cmd[2]) > #previousmentions then
				write('Not that many mentions, type //highlight view to show them all')
			else
				add_to_chat(4, '==Last '..cmd[2]..' Mentions==')
				for i=1, tonumber(cmd[2]) do
					add_to_chat(4, previousmentions[i])
				end
			end
		end
	end
end
 
function event_login()
	settings=config.load(settingdefaults)
	send_command('wait 2; lua i highlight initialize')
end
 
function initialize()
    if file.exists('../battlemod/data/colors.xml') then
		color=config.load('../battlemod/data/colors.xml', true)
		write('Colors loaded from battlemod')
	else
		color=config.load('/data/colors.xml',defaults)
	end
		nicknames=config.load('/data/nicknames.xml')
		mules=config.load('/data/mules.xml')
		settings=config.load(settingdefaults)
 
	for i, v in pairs(nicknames) do
		nicknames[i] = string.split(v, ',')
	end
 
	player=get_player()['name']
	
	for mule, name in pairs(mules) do
		mulenames[mule]=name
	end
 
	for i,v in pairs(color) do
		color[i]= colconv(v,i)
	end
 
	for i,v in pairs(mules) do
		mulecolor[i]=colconv(v,i)
	end
	get_party_members()
end
 
 
function event_incoming_text(original, modified, color)
 
		for names in modified:gmatch('%w+') do
			for name in pairs(members) do
				modified = modified:igsub(members[name], modmember[name])
			end
			for k,v in pairs(nicknames) do
				for z=1, #v do	
					modified = modified:igsub('([^%a])'..nicknames[k][z]..'([^%a])', function (pre, app) return pre..k:capitalize()..app end):igsub('([^%a])'..nicknames[k][z]..'$', function(space) return space..k:capitalize() end)			end	
			end
			for mule, color in pairs(mulenames) do
				modified = modified:igsub(mule, mulecolor[mule]..mule:capitalize()..chat.colorcontrols.reset)
			end	
			if settings.highlighting ~= 'Yes' then
				modified = modified:gsub('%(['..string.char(0x1e, 0x1f)..'].(%w+)'..'['..string.char(0x1e, 0x1f)..'].%)(.*)', function(name, rest) return '('..name..')'..rest end)			
				modified = modified:gsub('<['..string.char(0x1e, 0x1f)..'].(%w+)'..'['..string.char(0x1e, 0x1f)..'].>(.*)', function(name, rest) return '<'..name..'>'..rest end)	
			end	
	end
		--Not rolltracker and not battlemod
		if not original:match('.* '..string.char(129,168)..'.*') and not original:match('.* '..symbols['implies']..'.*') and color ~= 4 then
			--Chat modes not empty
			if original:match('^%(.*%)') or original:match('^<.*>') or original:match('^%[%d:#%w+%]%w+(%[?%w-%]?):') then
				--Not myself
				if not original:match('^%('..player..'%)') and not original:match('^<'..player..'>') and not original:match('^'..player..' :') and not original:match('^%[%d:#%w+%]'..player..'(%[?%w-%]?):') then
					if modified:match(player) then
						table.insert(previousmentions,1,'['..string.sub(os.date(), 10).."]>> "..colconv(color)..original	)
					end
				end
			end
		end
	
	return modified
end
 
function event_incoming_chunk(id, data)
	if id == 221 then
		modmember={}
		members={}
        send_count = send_count + 1
		send_command('wait 0.1; lua i highlight get_party_members')
	end
end
 
function colconv(str,key)
	-- Used in the options_load() function. Taken from Battlemod
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
 
 
called_count = 0
function get_party_members()
    called_count = called_count + 1
    if called_count ~= send_count and send_count ~= 0 then
        return
    end
    called_count = 0
    send_count = 0
	if settings.highlighting == 'Yes' then
		for member, member_tb in pairs(get_party()) do
			if not table.containskey(mulenames, member_tb['name']:lower()) then
				members[member] = member_tb['name']
				modmember[member]=color[member]..member_tb['name']..chat.colorcontrols.reset
			end
		end
	else 
		members['p0'] = player
		modmember['p0'] = color['p0']..player..chat.colorcontrols.reset
	end	
end
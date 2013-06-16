--Copyright (c) 2013, Thomas Rogers2
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
_addon.version = '0.7' 
 
members={}
mulenames={}
modmember={}
nicknames={}
color={}
mulecolor={}

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
  	
settings=config.load('/data/settings.xml')
 
function event_load()
	player=get_player()['name']
	send_command('alias highlight lua c highlight')
	write(_addon['name']..': Version:'.._addon['version'])
	if get_ffxi_info()['logged_in'] then
        initialize()
		player=get_player()['name']
    end
end
 
function event_login()
	send_command('wait 2; lua i highlight initialize')
	player=get_player()['name']
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
		settings=config.load('/data/settings.xml')
 
	for i, v in pairs(nicknames) do
		nicknames[i] = string.split(v, ',')
	end
 
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
 
function event_chat_message(is_gm, mode, player, message)
	if mode == 3 then
		--write('INCOMING TELL!')
	end
end
 
function event_party_invite(sender_id, sender, region)
	--write('PARTY INVITATION')
end
 
function event_incoming_text(original, modified, color)
	local me_party = original:find('%('..player..'%)')
	local me_linkshell = original:find('<'..player..'>')
	local me_say = original:find(player..' :')
	local me_tell = '%w+>>'
	local other_party = original:find('%(.*%)')
	local other_linkshell = original:find('<.*>')
	local other_say = original:find('.* :')
	local not_bm = original:find('.* '..string.char(129,168)..'.*')
 
	for names in modified:gmatch('([%p]?[%w]+[%p]?)') do
	
        for name in pairs(members) do
			if original:lower():gmatch('.*'..members[name]) then
				modified = modified:igsub(members[name], modmember[name])
			end
        end
 
		for k,v in pairs(nicknames) do
			for z=1, #v do	
				modified = modified:igsub('([^%a])'..nicknames[k][z]..'([^%a])', function (pre, app) return pre..k:capitalize()..app end):igsub('([^%a])'..nicknames[k][z]..'$', function(space) return space..k:capitalize() end)			end	
		end
 
		for mule, color in pairs(mulenames) do
			--	modified = modified:igsub('([^%a])'..mule..'([^%a])', function (pre, app) return '\x1E\x01'..mulecolor[mule]..pre..mule:capitalize()..'\x1E\x01'..app end):igsub('([^%a])'..mule..'$', function(space) return '\x1E\x01'..mulecolor[mule]..space..mule:capitalize()..'\x1E\x01' end)	
			modified = modified:igsub(mule, mulecolor[mule]..mule:capitalize()..chat.colorcontrols.reset)
		end	
 
		if settings.highlighting ~= 'Yes' then
			modified = modified:gsub('%(['..string.char(0x1e, 0x1f)..'].(%w+)'..'['..string.char(0x1e, 0x1f)..'].%)(.*)', function(name, rest) return '('..name..')'..rest end)			
			modified = modified:gsub('<['..string.char(0x1e, 0x1f)..'].(%w+)'..'['..string.char(0x1e, 0x1f)..'].>(.*)', function(name, rest) return '<'..name..'>'..rest end)	
		end
	end
	if not_bm == nil then
		if other_party ~= nil or other_linkshell ~= nil then
			if me_party == nil and me_linkshell == nil and me_say == nil then
				if modified:match(player) then
					--write('YOU ARE BEING TALKED ABOUT.')
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
 
 
function get_party_members()
	if settings.highlight == 'Yes' then
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
--[[
Copyright (c) 2013, Sebastien Gomez
All rights reserved.
Troubadour songs included by Mazura of Ragnarok

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of <addon name> nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon = {}
_addon.name = 'BuffDuration'
_addon.version = '3.0'

require 'tablehelper'  -- Required for various table related features. Made by Arcon
require 'logger'       -- Made by arcon. Here for debugging purposes
require 'stringhelper' -- Required to parse the other files. Probably made by Arcon
local files = require 'filehelper'

function event_load()
	player = get_player()  -- Get the player array (Used strictly for comparing name of buffed against character name for (Self)
	items = 0
	buffs = T(get_player()['buffs']) -- Need the current buff array for perpetuance/composure Trackin.
	
	local f = files.new('../../plugins/resources/status.xml')
	local h = files.new('data/Extend.xml')
	
	if f:exists() then
		write('loaded Status.xml file correctly.')
	else
		write('Status.xml not found')
	end
	if h:exists() then
		write('loaded Extend.xml file correctly.')
	else
		write('Extend.xml not found')
	end
	lines = f:readlines()
	hlines = h:readlines()
	
	createdTimers = T{}  -- Used as a timer tracker for deletion of timers
	buffExtension = T{ 
					LightArts=1.8,
					Rasa=2.28,
				}
	--Feel free to update this buffExtension variable in case you have better composure
	--or don't have perpetuance gloves. The Light Arts and Rasa sections are only used for regen
	extendables = T { 	'Regen','Refresh','Blink','Stoneskin','Aquaveil','Haste','Phalanx','Sandstorm','Rainstorm','Windstorm','Firestorm','Hailstorm','Thunderstorm','Aurorastorm',
						'Voidstorm','Blink','Stoneskin','Aquaveil','Invisible','Deodorize','Sneak','Barfire','Barblizzard','Baraero','Barstone','Barthunder','Barwater','Barpoison','Barparalyze',
						'Barblind','Barsilence','Barpetrify','Barvirus','Reraise', 'Protect', 'Shell'}
	extenCompo = T { 	'Regen','Refresh','Blink','Stoneskin','Aquaveil','Haste','Temper','Phalanx','Sandstorm','Rainstorm','Windstorm','Firestorm','Hailstorm','Thunderstorm','Aurorastorm',
						'Voidstorm','Blink','Stoneskin','Aquaveil','Invisible','Deodorize','Sneak','Barfire','Barblizzard','Baraero','Barstone','Barthunder','Barwater','Barpoison','Barparalyze',
						'Barblind','Barsilence','Barpetrify','Barvirus','Boost VIT','Boost MND','Boost AGI','Boost CHR','Boost STR','Boost DEX','Boost INT','Enthunder','Enstone','Enaero','Enfire',
						'Enblizzard','Enwater','Enthunder II','Enstone II','Enaero II','Enfire II','Enblizzard II','Enwater II','Blaze Spikes','Ice Spikes','Shock Spikes'}
	
	
	extenTroub = T {	'Paeon', 'Ballad', 'Minne', 'Minuet', 'Madrigal', 'Prelude', 'Mambo', 'Aubade', 'Pastoral', 'Fantasia', 'Operetta', 'Capriccio', 'Round', 'Gavotte', 'March', 'Etude', 'Carol',
						'Hymnus', 'Mazurka', 'Scherzo'}
	extenMarcat = T {	'Scherzo', 'Hymnus', 'Mazurka'}
	extenSoulV = T {	'Scherzo', 'Hymnus', 'Mazurka'}
	--This table is used to check if a buff is able to be
	--extended via perpetuance or composure. If i missed one
	--feel free to add it. Keep in mind however i only look for
	--the First name of a buff, no spaces, and this does not have
	--gain, barspell, or boost-buffs. I apologize for this.
	extend = T{}
	first = 0
	t = 0
	altbuffs = false
	send_command('alias buffDuration lua c buffDuration')
end

function event_login()
	player = get_player()
	items = get_items()	
	buffs = T(get_player()['buffs'])
	for u = 1, #buffs do
		createTimer(buffs[u],player['name'])
	end
end

function event_unload()
	--The following deletes all timers created before unloading
	--Mostly used for when i was continuously reloading it.
	--but i left it in in case someone wants to unload for something
	for u = 1, #createdTimers do
		send_command('timers d "'..createdTimers[u]..'"')
	end
	send_command('unalias buffDuration')
end

function event_lose_status(id,name)
	for i in ipairs(lines) do
		x = i
		str = lines[x]
		if str ~= nil then
			str=tostring(str)
			a,b,buffid,d = string.find(str,'<b id="(%w+)" duration="(%w+)"')
			if buffid ~= nil then
				buffn = tostring(str:split('>',2)[2]:split('<',2)[1])
				if tonumber(buffid) == tonumber(id) then
					deleteTimer(1,buffn)
					break
				end
			end
		end
	end
end

function event_action_message(actor_id,target_id,actor_target_index,target_target_index,message_id,param_1,param_2,param_3)
	if message_id == 206 then 
		target = get_mob_by_id(target_id).name
		
		for i in ipairs(lines) do		-- Iterates through each line of status.xml to find buff's by ID
			x = i
			str = lines[x]
			if str ~= nil then
				str=tostring(str)
				a1,b1,buffid,duration = string.find(str,'<b id="(%w+)" duration="(%w+)"') 
				if buffid ~= nil then
					if tonumber(buffid) == tonumber(param_1) then
						buffname = tostring(str:split('>',2)[2]:split('<',2)[1])
						break
					end
				end
			end
		end
		if target == nil then
			target = 'Self'
		elseif target:lower() == player['name']:lower() then
			target = 'Self'
		else
			target = target
		end
		deleteTimer(2,buffname,target)		
	end
end

function event_action(act)
	a = act.param
	cat = act.category
	b = T(act.targets)
	c1 = T(b[1])
	d1 = T(c1.actions[1])
	e = d1.param
	
	player = get_player()
	items = get_items()	
	equip = items.equipment
	buffs = T(get_player()['buffs'])
	
	if (cat == 4) or (cat == 6) then
		mob = get_mob_by_id(act.actor_id)
		actor = mob.name
		if actor:lower() == player.name:lower() then
			for i in ipairs(lines) do		-- Iterates through each line of status.xml to find buff's by ID
				x = i
				str = lines[x]
				if str ~= nil then
					str=tostring(str)
					a1,b1,buffid,duration = string.find(str,'<b id="(%w+)" duration="(%w+)"') 
					if buffid ~= nil then
						buffname = tostring(str:split('>',2)[2]:split('<',2)[1])
						if tonumber(e) > 0 then
							if tonumber(buffid) == tonumber(e) then
								target = get_mob_by_id(c1.id).name
								--[[if target == nil then
									target = 'Self'
								elseif target:lower() == player['name']:lower() then
									target = 'Self'
								else
									target = target
								end]]
								--single buff casting (only 1 person hit)
								if act.target_count == 1 then
									target = get_mob_by_id(c1.id).name
									if target == nil then
										target = 'Self'
									elseif target:lower() == player['name']:lower() then
										target = 'Self'
									else
										target = target
									end
								elseif act.target_count > 1 then
									--write('test1 '..tostring(party.p0.name))
									target = 'AoE'								
								end
								buffs = T(get_player()['buffs'])
								addtimeM = 1
								addtimeM2 = 0
	--  ------------------------------------------------------------------------------------------------------------------------------------
	--  SCH BUFFS
								if buffs:contains(469) then
									--Check for perpetuance
									if extendables:contains(tostring(buffname)) then
										--check if buff is extendable via perpetuance
										if tonumber(items.inventory[equip['hands']].id) == tonumber(11123) then
											--check for "Savant's Bracers +2"
											addtimeM = 2.5
										elseif tonumber(items.inventory[equip['hands']].id) == tonumber(11223) then
											--check for "Savant's Bracers +1"
											addtimeM = 2.25
										else
											addtimeM = 2
										end
									end
									if tostring(buffname) == 'Regen' then
										--If spell is regen* then add lightarts to extension
										addtimeM = addtimeM * buffExtension['LightArts']
									else
										addtimeM = addtimeM
									end
								elseif tostring(buffname) == 'Regen' then
									--If spell is regen* then check for rasa or lightarts for extension
									if buffs:contains(377) then
										--Rasa
										addtimeM = buffExtension['Rasa']
									elseif buffs:contains(358) then
										--LightArts
										addtimeM = buffExtension['LightArts']
									elseif buffs:contains(401) then
										--Addendum: White 
										addtimeM = buffExtension['LightArts']
									end
	--  ------------------------------------------------------------------------------------------------------------------------------------
	--  RDM BUFFS
								elseif buffs:contains(419) then
									--Check for Composure
									if extenCompo:contains(tostring(buffname)) then
										--check if buff is extendable via composure
										if target == 'Self' then 
											--If target is self then set composure Multiplier to 3
											addtimeM = 3
										elseif target:lower() ~= player.name:lower() then
											--if target is someone else set composure multiplier bassed on +2 gear equiped at time of spell completion
											gearset = 0
											if equip['head'] ~= 0 then
												if tonumber(items.inventory[equip['head']].id) == tonumber(11068) then
													gearset = gearset + 1
												end
											end
											if equip['body'] ~= 0 then
												if tonumber(items.inventory[equip['body']].id) == tonumber(11088) then
													gearset = gearset + 1
												end
											end
											if equip['hands'] ~= 0 then
												if tonumber(items.inventory[equip['hands']].id) == tonumber(11108) then
													gearset = gearset + 1
												end
											end
											if equip['legs'] ~= 0 then
												if tonumber(items.inventory[equip['legs']].id) == tonumber(11128) then
													gearset = gearset + 1
												end
											end
											if equip['feet'] ~= 0 then
												if tonumber(items.inventory[equip['feet']].id) == tonumber(11148) then
													gearset = gearset + 1
													addtimeM2 = addtimeM2 + 0.2
												elseif tonumber(items.inventory[equip['feet']].id) == tonumber(11248) then
													addtimeM2 = addtimeM2 + 0.1
												end
											end
											if equip['back'] ~= 0 then
												if tonumber(items.inventory[equip['legs']].id) == tonumber(16204) then
													addtimeM2 = addtimeM2 + 0.1
												end
											end
											if gearset == (0 or 1) then
												addtimeM = 1
											elseif gearset == 2 then
												addtimeM = 1.1
											elseif gearset == 3 then
												addtimeM = 1.2
											elseif gearset == 4 then
												addtimeM = 1.35
											elseif gearset == 5 then
												addtimeM = 1.5
											end
										end
									end
	--  ------------------------------------------------------------------------------------------------------------------------------------
	--  BARD BUFFS
								elseif buffs:contains(348) then
									if extenTroub:contains(tostring(buffname)) then
										--Troubadour
										addtimeM = 2
										if buffs:contains(231) then
											if extenMarcat:contains(tostring(buffname)) then
												--Marcato
												addtimeM = addtime + 1.5
											end
										end
									end
								elseif buffs:contains(52) then
									if extenSoulV:contains(tostring(buffname)) then
										--Soul Voice
										addtimeM = 2
										if buffs:contains(348) then
											--Troubadour
											addtimeM = addtimeM + 2
										end
									end
								elseif buffs:contains(231) then
									if extenMarcat:contains(tostring(buffname)) then
										--Marcato
										addtimeM = 1.5
									end
								end
							duration = tonumber(duration) * (addtimeM + addtimeM2)
							if checkgear(buffid) > 0 then 
								duration = duration + tonumber(checkgear(buffid))
							end
							createTimer(tostring(buffname), tostring(target), tonumber(duration))
							end
						end
					end
				end
			end
		end
	end
end


function checkgear(id)

	items = get_items()
	equip = items.equipment
	addtime = 0
	for i in ipairs(hlines) do		-- Iterates through each line of status.xml to find buff's by ID
		x = i
		str = hlines[x]
		if str ~= nil then
			str = tostring(str)
			a,b,c,d,e,f = string.find(str,'<b id="(%w+)" gearid="(%w+)" duration="(%w+)" slot="(%w+)">') 
			if c ~= nil then
				extendid = c
				gearid = d
				addtime2 = e
				slot = f
                gearname = tostring(str:split('>',2)[2]:split('<',2)[1])
				if tonumber(extendid) == tonumber(id) then
					if equip[slot] ~= 0 then
						if tonumber(items.inventory[equip[slot] ].id) == tonumber(gearid) then
							addtime = addtime + addtime2
							return addtime
						else
							addtime = addtime
							return addtime
						end
					end
				else
					addtime = addtime
					return addtime
				end
			end
		end
	end
end

function createTimer(buffname, target, duration)

	--duration = checkgear(buffid) + duration

	if tonumber(duration) > 0 then
		send_command('timers c "'..buffname..' ('..target..')" '..duration..' down ' ..tostring(buffid):zfill(5))
		createdTimers[#createdTimers+1] = buffname..' ('..target..')'
		
	elseif tonumber(duration) == 0 then
		timer = 1
		send_command('timers c "'..buffname..' ('..target..')" '..timer..' down ' ..tostring(buffid):zfill(5))
		createdTimers[#createdTimers+1] = buffname..' ('..target..')'
	elseif tonumber(duration) == -1 then
	end
end

function deleteTimer(mode,effect,target)
	if mode == 1 then 
		-- This mode is for when a buff drops off you 
		--(the lose buff triggers faster then the chat message)
		for u = 1, #createdTimers do
			if createdTimers[u] == effect..' (Self)' then
				send_command('timers d "'..effect..' (Self)"')
				createdTimers:remove(u)
			elseif createdTimers[u] == effect..' (AoE)' then
				send_command('timers d "'..effect..' (AoE)"')
				createdTimers:remove(u)
			end
		end
	elseif mode == 2 then
		--This mode triggers when a buff drops off others.
		--It cycles through the created timers table and
		--if it finds the name of the dropped buff deletes
		--the table entry as well as removing the timer.
		if target == nil then
			target = 'Self'
		elseif target:lower() == player['name']:lower() then
			target = 'Self'
		else
			target = target
		end
		for u = 1, #createdTimers do
			if createdTimers[u] == effect..' ('..target..')' then
				send_command('timers d "'..effect..' ('..target..')"')
				createdTimers:remove(u)
			end
		end
	else
		return
	end	
end



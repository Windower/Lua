--[[
Copyright (c) 2013, Ricky Gall
All rights reserved.
Ammended by Sebastien Gomez
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
_addon.version = '2.1'

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
					Perpetuance=2.5,
					LightArts=1.8,
					Rasa=2.28,
					Composure=3,
					Troubadour=2,
					Marcato=1.5,
					SoulVoice=2,
					ComposureOthers=1,
					Enhance=1.2
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
	extenEnhan = T { 	'Regen','Refresh','Blink','Stoneskin','Aquaveil','Haste','Temper','Phalanx','Sandstorm','Rainstorm','Windstorm','Firestorm','Hailstorm','Thunderstorm','Aurorastorm',
						'Voidstorm','Blink','Stoneskin','Aquaveil','Invisible','Deodorize','Sneak','Barfire','Barblizzard','Baraero','Barstone','Barthunder','Barwater','Barpoison','Barparalyze',
						'Barblind','Barsilence','Barpetrify','Barvirus','Boost VIT','Boost MND','Boost AGI','Boost CHR','Boost STR','Boost DEX','Boost INT','Enthunder','Enstone','Enaero','Enfire',
						'Enblizzard','Enwater','Enthunder II','Enstone II','Enaero II','Enfire II','Enblizzard II','Enwater II','Blaze Spikes','Ice Spikes','Shock Spikes','Protect','Shell','Reraise'}
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

function event_addon_command(...)
    local term = table.concat({...}, ' ')
	broken = term:split(' ',4)

	--This is a very important fix added
	--because if you already had a buff and recast it
	--it would just delete and create so fast
	--that sometimes it didn't show back up
	if broken ~= nil then
		if tostring(broken[1]):lower() == 'newtimer' then
			if broken[4] == nil then
				createTimer(broken[2],broken[3])
			else
				createTimer(broken[2]..' '..broken[3],broken[4])
			end
		end
		
		if broken[1]:lower() == 'showalt' then
			altbuffs = not altbuffs
		end
	end
end

function event_gain_status(id,name)
	if id == 469 then
		--Check to gain perpetuance and add a timer
		extend['Perpetuance'] = os.clock()
	end
	if id == 348 then
		--Check to gain Troubadour and add a timer
		extend['Troubadour'] = os.clock()
	end
	first = 1
	for i in ipairs(lines) do		-- Iterates through each line of status.xml to find buff's by ID
		x = i
		str = lines[x]
		if str ~= nil then
			str=tostring(str)
			a,b,c,d = string.find(str,'<b id="(%w+)" duration="(%w+)"') 
			if c ~= nil then
				buffid = c
				duration = d
				buffname = tostring(str:split('>',2)[2]:split('<',2)[1])
				if tonumber(buffid) == tonumber(id) then
					createTimer(tostring(buffname))
					buffs = T(get_player()['buffs'])
					break
				end
			end
		end
	end
end

function check_bufflist(name)
	buffs = T(get_player()['buffs'])
	if buffs:contains(419) then
		--Check to gain Composure and add a timer
		extend['Composure'] = os.clock()
	end
	for i in ipairs(lines) do		-- Iterates through each line of status.xml to find buff's by ID
		x = i
		str = lines[x]
		if str ~= nil then
			str=tostring(str)
			a,b,c,d = string.find(str,'<b id="(%w+)" duration="(%w+)"') 
			if c ~= nil then
				buffid = c
				duration = d
				buffn = tostring(str:split('>',2)[2]:split('<',2)[1])
				if tostring(buffn) == tostring(name) then
					return true
				end
			end
		end
	end
	return false	
end

function event_lose_status(id,name)
	for i in ipairs(lines) do
		x = i
		str = lines[x]
		if str ~= nil then
			str=tostring(str)
			a,b,c,d = string.find(str,'<b id="(%w+)" duration="(%w+)"')
			if c ~= nil then
				buffid = c
				duration = d
				buffn = tostring(str:split('>',2)[2]:split('<',2)[1])
				if tonumber(buffid) == tonumber(id) and not extenTroub:contains(tostring(name)) then
					deleteTimer(1,buffn)
					send_ipc_message(buffn..' '..player['name']..' delete')
					break
				end
			end
		end
	end
end

function event_ipc_message(msg)
	if altbuffs then
		broken2 = msg:split(' ',3)
		if broken2 ~= nil then
			if broken2[3] == nil then
				if tostring(broken2[2]) ~= player['name'] then
					createTimer(broken2[1],broken2[2])
				end
			elseif broken2[3] ~= nil then
				if tostring(broken2[3]) ~= player['name'] then
					createTimer(broken2[1]..' '..broken2[2],broken2[3])
				end
			else
				if broken2[3] == nil then
					deleteTimer(2,broken2[1],broken2[2])
				elseif broken2[3] ~= nil then
					deleteTimer(2,broken2[1]..' '..broken2[2], broken2[3])
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
						if tonumber(items.inventory[equip[slot]].id) == tonumber(gearid) then
							addtime = addtime + addtime2
						else
							addtime = addtime
						end
					end
				else
					addtime = addtime
				end
			end
		end
	end
end

function createTimer(name,target)
	if check_bufflist(name) == true then
		--Check current target and if it either doesn't exist,
		--or is your current character's name, change it to self
		--otherwise keep it what it is.
		if target == nil then
			target = 'Self'
		elseif target:lower() == player['name']:lower() then
			target = 'Self'
		else
			target = target
		end
		for u = 1, #createdTimers do
			if createdTimers[u] == name..' ('..target..')' then
				--This loops through the created timers table to see if 
				--the one currently being created exists. It then proceeds
				--to delete that timer and table entry and run a createtimer
				--again. This is what causes the blinking timer you see sometimes
				--when you recast a buff. No way around it.
				send_command('timers d "'..name..' ('..target..')"')
				createdTimers:remove(u)
				send_command('wait .1;lua c buffDuration newtimer '..name..' '..target)
				return
			end
		end
		--The following checks if any gear will extend the time of the buff
		checkgear(buffid)
		--if tonumber(addtime) ~= nil and tonumber(addtime) ~= 0 then
			--duration = duration + addtime
		--else
			--timer = duration
		--end
		
		--The following section is used for extensions of buff timers
		--Perpetuance, Light Arts, Tabula Rasa, and Composure are all 
		--Checked here to figure out the time the timer should be set to.
		--If all checks fail, the timer is set to base time at the beginning
		--and 5 seconds is subtracted due to lag of the chat log.

		mod_duration = tonumber(duration) + addtime
		buffs = T(get_player()['buffs'])
		if player['main_job_id'] == 20 then
			if extendables:contains(tostring(name)) then
				if extend ~= nil then
					e = os.clock()-60
					if extend['Perpetuance'] ~= nil then
						if e < extend['Perpetuance'] then
							if target == 'Self' then
								
								if first == 1 then 
									t = 1 
								else
									t = t + 1 
								end
								if math.even(t) then
									extend['Perpetuance'] = nil
									first = 0
									t = 0
								end
							else
								extend['Perpetuance'] = nil
							end
								
							if tostring(name) == 'Regen' then
								mod_duration = mod_duration * buffExtension['LightArts'] * buffExtension['Perpetuance']
							else
								mod_duration = mod_duration * buffExtension['Perpetuance']
							end
						end
					end
				end
			elseif buffs:contains(377) then
				if tostring(name) == 'Regen' then
						mod_duration = mod_duration * buffExtension['Rasa']
				end
			elseif buffs:contains(358) then
				if tostring(name) == 'Regen' then
						mod_duration = mod_duration * buffExtension['LightArts']
				end
			end
		elseif player['main_job_id'] == 5 then
			--Get Current composure others, enhancing durations
			checkgear(1000) --Global %boost to enhancing magic
			buffExtension['Enhance'] = 1 + addtime/100
			
			checkgear(1001)
			CompGearTable={1,1.1,1.2,1.35,1.5}
			buffExtension['ComposureOthers'] = CompGearTable[addtime]
			if extenCompo:contains(tostring(name)) then
				if extend ~= nil then
					e = os.clock()-60
					if extend['Composure'] ~= nil then
						if e < extend['Composure'] then
							if target == 'Self' then
								mod_duration = mod_duration * buffExtension['Composure']
							else
								mod_duration = mod_duration * buffExtension['ComposureOthers']
							end
						end
					end
				end
			end
			if extenEnhan:contains(tostring(name)) then
				if extend ~= nil then
					mod_duration = mod_duration * buffExtension['Enhance']
				end
			end
		elseif player['main_job_id'] == 10 then
			checkgear(2000)
			mod_duration = mod_duration + addtime
			if extenTroub:contains(tostring(name)) then
				if extend ~= nil then
					e = os.clock()-80
					if extend['Troubadour'] ~= nil then
						if e < extend['Troubadour'] then
							mod_duration = mod_duration * buffExtension['Troubadour']
						end
					end
				end
			end
		end
		timer = mod_duration - 5
		--This is where the timer is actually created
		--Calls ihm's custom timer create command
		--e.g. timers c "Protect (Self)" 1800 down Protect <- last protect 
		--is what helps the timer distinguish what icon to use.
		if target == 'Self' then
			send_ipc_message(name..' '..player['name'])
		else
			send_ipc_message(name..' '..target)
		end
		if tonumber(duration) > 0 then
			send_command('timers c "'..name..' ('..target..')" '..timer..' down ' ..tostring(buffid):zfill(5))
			createdTimers[#createdTimers+1] = name..' ('..target..')'
			
		elseif tonumber(duration) == 0 then
			timer = 1
			send_command('timers c "'..name..' ('..target..')" '..timer..' down ' ..tostring(buffid):zfill(5))
			createdTimers[#createdTimers+1] = name..' ('..target..')'
		elseif tonumber(duration) == -1 then
		end
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

function event_incoming_text(old,new,color)
	--Colors 56 and 64 are for gained buffs
	--Color 191 for lost buffs. Check against
	--These colors if it doesn't match just output
	--the normal message
	if T{64,56,191,101}:contains(color) then
		--This check is to catch casted spells
		--Stores name of caster, spell cast,
		--target of the effect and the effect itself
		a,b,caster,caster_spell,target,target_effect = string.find(old,'(%w+) casts ([%w%s]+)..(%w+) gains the effect of ([%w%s]+).')
		
		--Check for buffs wearing off and store name and buff in variables
		c,d,tWear,eWear = string.find(old,'(%w+)\'s ([%w%s]+) effect wears off.')
		--Check for gain buffs only (i.e. you have filters on) and store name/buff
		e,f,tar2,eff2 = string.find(old,'(%w+) gains the effect of ([%w%s]+).')

		if a ~= nil then
			--If a isn't blank it found the message.
			--The following checks are so that you don't
			--catch buffs cast by others on others.
			--Will catch buffs cast by you or on you.
			if caster:lower() == player['name']:lower() then
				createTimer(tostring(target_effect),tostring(target))
			elseif target:lower() == player['name']:lower() then
				createTimer(tostring(target_effect),tostring(target))
			end
		elseif c ~= nil then
			--if c isn't blank it found the wear off message
			--so delete the timer
			
				if tWear:lower() == player['name']:lower() then
					deleteTimer(1,eWear,tWear)
				else
					deleteTimer(2,eWear,tWear)
				end
		elseif e ~= nil then
			--If e isn't nil you have filters off and 
			--received a buff cast by another person
			--This is just so that if you already
			--had the buff your timer will refresh.
			if tar2:lower() == player['name']:lower() then
				createTimer(eff2,tar2)
			end
		end
	end
	return new, color  -- must be here or errors will be thrown
end

-- Function made by byrth
function split(msg, match)
	local length = msg:len()
	local splitarr = {}
	local u = 1
	while u < length do
		local nextanch = msg:find(match,u)
		if nextanch ~= nil then
			splitarr[#splitarr+1] = msg:sub(u,nextanch-match:len())
			if nextanch~=length then
				u = nextanch+match:len()
			else
				u = length
			end
		else
			splitarr[#splitarr+1] = msg:sub(u,length)
			u = length
		end
	end
	return splitarr
end
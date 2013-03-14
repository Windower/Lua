--[[
Copyright (c) 2013, Ricky Gall All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    Neither the name of the organization nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
require 'tablehelper'  -- Required for various table related features. Made by Arcon
require 'logger'       -- Made by arcon. Here for debugging purposes
function event_load()
	player = get_player()  -- Get the player array (Used strictly for comparing name of buffed against character name for (Self)
	buffs = T(get_player()['buffs']) -- Need the current buff array for perpetuance/composure Tracking
	watchbuffs = {	
					Haste=180,
					Refresh=150,
					Protect=1800,
					Shell=1800,
					Regen=60,
					Phalanx=180,
					Last_Resort=180,
					Arcane_Circle=240,
					Berserk=180,
					Aggressor=180
				} 
	-- watchbuffs table can be modified be sure to follow the syntax
	-- however, because this addon looks for specific things.
	createdTimers = T{}  -- Used as a timer tracker for deletion of timers
	buffExtension = T{ 
					Perpetuance=2.5,
					LightArts=1.8,
					Rasa=2.28,
					Composure=3
				}
	--Feel free to update this buffExtension variable in case you have better composure
	--or don't have perpetuance gloves. The Light Arts and Rasa sections are only used for regen
	extendables = T { 'Regen','Refresh','Blink','Stoneskin','Aquaveil','Haste','Temper','Phalanx' }
	--This table is used to check if a buff is able to be
	--extended via perpetuance or composure. If i missed one
	--feel free to add it. Keep in mind however i only look for
	--the First name of a buff, no spaces, and this does not have
	--gain, barspell, or boost-buffs. I apologize for this.
	extend = T{}
	t = 0
end

function event_unload()
	--The following deletes all timers created before unloading
	--Mostly used for when i was continuously reloading it.
	--but i left it in in case someone wants to unload for something
	for u = 1, #createdTimers do
		send_command('timers d "'..createdTimers[u]..'"')
	end
end

function event_addon_command(arg1,arg2,arg3)
	--This is a very important fix added
	--because if you already had a buff and recast it
	--it would just delete and create so fast
	--that sometimes it didn't show back up
	if arg1 == 'newtimer' then
		createTimer(arg2,arg3)
	end
end

function event_gain_status(id,name)
	if id == 469 then
		--Check to gain perpetuance and add a timer
		extend['Perpetuance'] = os.clock()
	end
	l = split(name,' ')
	if l[2] ~= nil then 
		createTimer(l[1]..'_'..l[2])
	else 
		createTimer(name)
	end
end

function event_lose_status(id,name)
	deleteTimer(1,name)
end

function createTimer(name,target)
	if watchbuffs[name] ~= nil then
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
				send_command('wait .1;lua c bTimers newtimer '..name..' '..target)
				return
			end
		end
		
		--The following section is used for extensions of buff timers
		--Perpetuance, Light Arts, Tabula Rasa, and Composure are all 
		--Checked here to figure out the time the timer should be set to.
		--If all checks fail, the timer is set to base time at the beginning
		--and 5 seconds is subtracted due to lag of the chat log.
		if extendables:contains(name) then
			buffs = T(get_player()['buffs'])
			timer = tonumber(watchbuffs[name]) - 5
			if extend ~= nil then
				e = os.clock()-60
				if extend['Perpetuance'] ~= nil then
					if e < extend['Perpetuance'] then
						if target == 'self' then
							t = t + 1 
							if math.even(t) then
								extend['Perpetuance'] = nil
								t = 0
							end
						else
							extend['Perpetuance'] = nil
						end
							
						if name == 'Regen' then
							timer = tonumber(watchbuffs[name]) * buffExtension['LightArts'] * buffExtension['Perpetuance'] - 5
						else
							timer = tonumber(watchbuffs[name]) * buffExtension['Perpetuance'] - 5
						end
					end
				end
			elseif buffs:contains(377) then
				if name == 'Regen' then
					if player['main_job_id'] == 20 then
						timer = tonumber(watchbuffs[name]) * buffExtension['Rasa'] - 5
					end
				end
			elseif buffs:contains(358) then
				if name == 'Regen' then
					if player['main_job_id'] == 20 then
						timer = tonumber(watchbuffs[name]) * buffExtension['LightArts'] - 5
					end
				end
			elseif buffs:contains(419) then
				timer = tonumber(watchbuffs[name]) * buffExtension['Composure'] - 5
			end
		else
			timer = tonumber(watchbuffs[name]) - 5
		end
		
		--This is where the timer is actually created
		--Calls ihm's custom timer create command
		--e.g. timers c "Protect (Self)" 1800 down Protect <- last protect 
		--is what helps the timer distinguish what icon to use.
		send_command('timers c "'..name..' ('..target..')" '..timer..' down '..name)
		createdTimers[#createdTimers+1] = name..' ('..target..')'
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
		a,b,caster,caster_spell,target,target_effect = string.find(old,'(%w+) casts ([%w%s]+)..(%w+) gains the effect of (%w+).')
		
		--Check fo buffs wearing off and store name and buff in variables
		c,d,tWear,eWear = string.find(old,'(%w+)\'s ([%w%s]+) effect wears off.')
		--Check for gain buffs only (i.e. you have filters on) and store name/buff
		e,f,tar2,eff2 = string.find(old,'(%w+) gains the effect of (%w+).')
		if a ~= nil then
			--If a isn't blank it found the message.
			--The following checks are so that you don't
			--catch buffs cast by others on others.
			--Will catch buffs cast by you or on you.
			if caster:lower() == player['name']:lower() then
				createTimer(target_effect,target)
			elseif target:lower() == player['name']:lower() then
				createTimer(target_effect,target)
			end
		elseif c ~= nil then
			--if c isn't blank it found the wear off message
			--so delete the timer
				l = split(eWear,' ')
				if l[2] ~= nil then 
					deleteTimer(1,l[1]..'_'..l[2],tWear)
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
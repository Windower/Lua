--[[
Copyright (c) 2013, Ricky Gall All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    Neither the name of the organization nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
require 'tablehelper'
require 'logger'
function event_load()
	player = get_player()
	buffs = T(get_player()['buffs'])
	watchbuffs = {	
					Haste=180,
					Refresh=150,
					Protect=1800,
					Shell=1800,
					Regen=60,
					Phalanx=180
				} -- only adding a few so you can get the idea
	createdTimers = T{}
	buffExtension = T{
					Perpetuance=2.5,
					LightArts=1.8,
					Rasa=2.28,
					Composure=3
				}
	extendables = T { 'Regen','Refresh','Blink','Stoneskin','Aquaveil','Haste','Temper','Phalanx' }
	extend = T{}
end

function event_unload()
	for u = 1, #createdTimers do
		send_command('timers d "'..createdTimers[u]..'"')
	end
end

function event_addon_command(arg1,arg2,arg3)
	if arg1 == 'newtimer' then
		createTimer(arg2,arg3)
	end
end

function event_gain_status(id,name)
	if id == 469 then
		extend['Perpetuance'] = os.clock()
	end
	if id == 366 then
		extend['Accession'] = os.clock()
	end
	createTimer(name)
end

function event_lose_status(id,name)
	deleteTimer(1,name)
end

function createTimer(name,target)
	if watchbuffs[name] ~= nil then
		if target == nil then
			target = 'Self'
		elseif target:lower() == player['name']:lower() then
			target = 'Self'
		else
			target = target
		end
		for u = 1, #createdTimers do
			if createdTimers[u] == name..' ('..target..')' then
				send_command('timers d "'..name..' ('..target..')"')
				createdTimers:remove(u)
				send_command('wait .1;lua c bTimers newtimer '..name..' '..target)
				return
			end
		end
		if extendables:contains(name) then
			buffs = T(get_player()['buffs'])
			timer = tonumber(watchbuffs[name]) - 5
			if extend ~= nil then
				e = os.clock()-60
				if extend['Perpetuance'] ~= nil then
					if e < extend['Perpetuance'] then
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
			
		send_command('timers c "'..name..' ('..target..')" '..timer..' down '..name)
		createdTimers[#createdTimers+1] = name..' ('..target..')'
	end
end

function deleteTimer(mode,effect,target)
	if mode == 1 then -- This mode is for when a buff drops off you (the gain buff triggers faster then the chat message
		for u = 1, #createdTimers do
			if createdTimers[u] == effect..' (Self)' then
				send_command('timers d "'..effect..' (Self)"')
				createdTimers:remove(u)
			end
		end
	elseif mode == 2 then
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
	a,b,caster,caster_spell,target,target_effect = string.find(old,'(%w+) casts ([%w%s]+)..(%w+) gains the effect of (%w+).')
	c,d,tWear,eWear = string.find(old,'(%w+)\'s (%w+) effect wears off.')
	
	if a ~= nil then
		if caster:lower() == player['name']:lower() then
			createTimer(target_effect,target)
		end
	elseif c ~= nil then
		deleteTimer(2,eWear,tWear)
	end
	return new, color  -- must be here or crashes will ensue
end
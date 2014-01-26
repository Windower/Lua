-- Copyright (c) 2013, Andy 'Ihm' Taylor
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of <addon name> nor the
--       names of its contributors may be used to endorse or promote products
--       derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require('tables')
require('sets')

_addon.name = 'StratHelper'
_addon.author = 'Ihm'
_addon.version = '0.2.0.0'

function reinit()
	clock_current = 0
	strat_max = 0
	windower.send_command('@wait 1; lua i StratHelper strat_max_calc')
end

strat_max = 0
strat_cur = 0
strat_ids = S{215,216,217,218,219,220,221,222,234,235,240,241,242,243,316,317}
scvar_strats_current = '_SCH_Strats_Current'
scvar_strats_max = '_SCH_Strats_Max'
clock_current = 0
loop_active = false
windower.send_command('alias resetstrats lua i StratHelper reinit')

windower.register_event('load', function()
	if windower.ffxi.get_info().logged_in then
		reinit()
	end
end)

windower.register_event('unload', windower.send_command:prepare('unalias resetstrats'))

windower.register_event('action', function(act)
	if act.actor_id == windower.ffxi.get_player().id then
		if act.category == 6 then
			if act.param == 210 then
				clock_current = os.clock()
				strat_cur = strat_max
				windower.send_command('sc var set ' .. scvar_strats_current .. ' ' .. strat_cur)
			elseif strat_ids:contains(act.param) then
				strat_max_calc()
				if T(windower.ffxi.get_player().buffs):contains(377) == false then
					strat_cur = strat_cur - 1
					windower.send_command('sc var set ' .. scvar_strats_current .. ' ' .. strat_cur)
				end
				if loop_active == false then
					loop_active = true
					clock_current = os.clock()
					windower.send_command('@wait 0.5; lua i StratHelper strat_loop')
				end
			end
		end
	end
end)

windower.register_event('job change', reinit)

windower.register_event('login', reinit)

function strat_max_calc()
	local set_cur = false
	if strat_max == 0 then
		set_cur = true
	end
	if windower.ffxi.get_player().main_job == 'SCH' then
		strat_max = math.floor(((windower.ffxi.get_player().main_job_level  - 10) / 20) + 1)
	elseif windower.ffxi.get_player().sub_job == 'SCH' then
		strat_max = math.floor(((windower.ffxi.get_player().sub_job_level  - 10) / 20) + 1)
	end
	if set_cur then
		strat_cur = strat_max
		windower.send_command('sc var set ' .. scvar_strats_current .. ' ' .. strat_cur)
	end
	windower.send_command('sc var set ' .. scvar_strats_max .. ' ' .. strat_max)
end

function strat_loop()
	if (240 / strat_max) - (os.clock() - clock_current) < 0 then
		clock_current = os.clock()
		strat_cur = strat_cur + 1
		windower.send_command('sc var set ' .. scvar_strats_current .. ' ' .. strat_cur)
	end
	if strat_cur < strat_max then
		windower.send_command('@wait 0.5; lua i StratHelper strat_loop')
	else
		loop_active = false
	end
	if strat_cur > strat_max then
		strat_cur = strat_max
	end
end

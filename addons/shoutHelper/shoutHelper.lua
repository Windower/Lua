--[[
Copyright (c) 2013, Chiara De Acetis
All rights reserved.

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


_addon.name = 'shoutHelper'
_addon.version = '0.2'
_addon.commands = {'shouthelper','sh'}
_addon.author = 'Jandel'

require 'tables'
require 'strings'
require 'logger'
--local file = require 'files'
local Blackboard = require 'blackboard'
local lavagna = nil
local config = require 'config'

-- Memo: //lua load shoutHelper

-- Constructor
windower.register_event('load',function ()
	settings = config.load({
		posx = 300,
		posy = 140,
		bgtransparency = 200,
		font = 'courier',
		fontsize = 10
	})
	lavagna = Blackboard:new(settings)
end)

-- Handle addon args
windower.register_event('addon command',function (...)
    local params = {...};
	
    if #params < 1 then
        return
    end
    if params[1] then
	if params[1]:lower() == "help" then
		--Idea of helper
	    local color = '204' -- !!there is a function in scoreboard for add_to_chat
            windower.add_to_chat(color, 'SH: ShoutHelper v' .. _addon.version .. '. Author: Jandel')
            windower.add_to_chat(color, 'SH: sh help : Shows help message')
            windower.add_to_chat(color, 'SH: sh pos <x> <y> : Positions the list')
            windower.add_to_chat(color, 'SH: sh clear [<party>]: Reset list (if no party is given, it will reset all alliance).')
            --the following two line are commented because there's no function implemented
            --windower.add_to_chat(color, 'SH: sh save <filename> : Save alliance settings. If the file already exists it will overwrite it.')
            --windower.add_to_chat(color, 'SH: sh load <filename>  : Load the <filename> alliance settings.')
            windower.add_to_chat(color, "SH: sh set <party> <job1> <job2> ... : Add a job to the party. pt1 is for first party, pt2 and pt3 for second and third party. ".."Won\'t add jobs if the party list is full")
            windower.add_to_chat(color, 'SH: sh add [<job>] <player> : assign the name of that player to the corrisponding job.')
            windower.add_to_chat(color, 'SH: sh del [<party>] <job> : deletes the job from the alliance list. Party from wich delet it is optional')
            windower.add_to_chat(color, 'SH: sh rm <player>: removes the player from the alliance list')
            windower.add_to_chat(color, 'SH: sh visible : shows/hide the current alliance list')
        elseif params[1]:lower() == "pos" then
            if params[3] then
                local posx, posy = tonumber(params[2]), tonumber(params[3])
                lavagna:set_position(posx, posy)
                --TODO check this if to save settings
                if posx ~= settings.posx or posy ~= settings.posy then
                    settings.posx = posx
                    settings.posy = posy
                    settings:save()
                end
            end
        elseif params[1]:lower() == "clear" then
            lavagna:reset(params[2])
	--elseif params[1]:lower() == "save" then
            --if --[[the filename isn't legit(emplty string too)]] --then
		--error('Invalid name')
		--return
            --end
	    -- TODO function that create&save xml
	    --log('This function needs to be implemented')
	--elseif params[1]:lower() == "load" then
            --if --[[the filename isn't legit(emplty string too)] --then
		--error('Invalid name')
		--return
            --end
	    -- TODO function that load xml
	    --log('This function needs to be implemented')
	elseif params[1]:lower() == "set" then --add jobs to party list
	    local party = params[2]
	    if not party then
		error('No input given')
		return
	    end
	    if not params[3] then
		error('no jobs given')
		return
	    end
	    local jobs = {}
	    local j = 1
	    for i=3, #params do
		jobs[j] = params[i]
		j = j + 1
	    end
	    lavagna:set(party, jobs)
	elseif params[1]:lower() == "add" then --add playername to party
	    local job = params[2]
	    if not job then
		error('No input given')
		return
	    end
	    local name = params[3]
	    if not name then
                name = job
		job = nil
	    end
	    lavagna:addPlayer(job, name)
	elseif params[1]:lower() == "del" then --delete job
	    local party = params[2]
	    if not party then
		error('No input given')
		return
	    end
	    local job = nil
	    if (party and params[3]) then
		job = params[3]
	    else
		job = party
	    end
	    lavagna:deleteJob(job, party)
	elseif params[1]:lower() == "rm" then --remove player
	    if not params[2] then
		error('Missing player name')
		return
	    end
	    lavagna:rmPlayer(params[2])
	elseif params[1]:lower() == "visible" then
	    if(lavagna.visible) then
		lavagna:hide()
	    else
		lavagna:show()
	    end
	else --I don't know if leave the error message or "do nothing" (deleting else) in case the command isn't legit
	    error('Invalid command')
	end
    end
end)



-- Destructor
windower.register_event('unload',function ()
    lavagna:destroy()
end)
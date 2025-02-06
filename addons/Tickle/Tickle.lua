_addon.name = 'Tickle'
_addon.author = 'ragns'
_addon.version = '1.0.0.0'
_addon.command = 'tickle'

local texts = require('texts')
local packets = require('packets')
local config = require('config')
local res = require('resources')

local defaults = {
	pos = {
		x = -150,
		y = -175,
	},
	bg = {
		alpha = 192,
	},
	text = {
		size = 14,
	},
	flags = {
		right = true,
		bottom = true,
	},
}

local settings = config.load(defaults)

local text = texts.new('', settings)

local player_id
local status
local next
local mp

local statuses = res.statuses:map(table.get-{'english'})

windower.register_event('incoming chunk', function(id, data)
	if id ~= 0x037 and id ~= 0x0DF then
		return
	end

	local packet = packets.parse('incoming', data)
	if id == 0x037 then
		local new_status = statuses[packet['Status']]
		if new_status ~= status then
			if new_status == 'Resting' then
				next = os.clock() + 21
				text:show()
			else
				text:hide()
			end
		end
		status = new_status
	elseif id == 0x0DF then
		if packet['ID'] == player_id then
			local new_mp = packet['MP']
			if status == 'Resting' and new_mp - mp >= 12 then
				next = os.clock() + 10
			end
			mp = new_mp
		end
	end
end)

windower.register_event('prerender', function()
	if status ~= 'Resting' then
		return
	end

	local now = os.clock()
	local sec = next - now
	if sec < 0 then
		sec = 10
		next = now + sec
	end

	text:text(tostring(math.floor(sec)))
end)

windower.register_event('load', 'login', 'logout', function()
	next = 0
	mp = 0
	if windower.ffxi.get_info().logged_in then
		local player = windower.ffxi.get_player()
		player_id = player.id
		status = statuses[player.status]
		if status == 'Resting' then
			text:show()
		end
	else
		player_id = nil
		status = nil
		text:hide()
	end
end)

--[[
Copyright © 2024, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

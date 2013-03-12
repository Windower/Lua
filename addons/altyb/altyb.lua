require 'buffs'
function event_gain_status(id,name)
	for u = 1, #buffs do
		broken = split(buffs[u], ',')
		if broken[1]:lower() == name:lower() then
			if broken[3] ~= nil then
				send_command('timers c '..broken[1]..' '..broken[2]..' down spells/'..broken[3]..'.png')
			else
				send_command('timers c '..broken[1]..' '..broken[2]..' down')
			end
		end
	end
end

function split(msg, match)
	local length = msg:len()
	local splitarr = {}
	local u = 1
	while u < length do
		local nextanch = msg:find(match,u)
		if nextanch ~= nil then
			splitarr[#splitarr+1] = msg:sub(u,nextanch-1)
			if nextanch~=length then
				u = nextanch+1
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
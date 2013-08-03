--This function checks the string sent to it against your mob list
--returns true if it's found and false if not.
function mCheck(str)
    for category,_ in pairs(settings.moblist) do
        for name,_ in pairs(settings.moblist[category]) do
            if str:lower():contains(name:lower()) then
                return true
            end
        end
    end
    return false
end

--This function checks the string sent to it against your mob list
--returns true if it's found and false if not.
function mDanger(str)
    for name,_ in pairs(settings.moblist.dangerous) do
        if str:lower():contains(name:lower()) then
            return true
        end
    end
    return false
end

--This function checks the string sent to it against your danger list
--returns true if it's found and false if not.
function dCheck(typ, sid)
    if typ == 'spells' then
        if settings.dangerwords.spells:find(string.imatch-{spells[sid]}) then
            return true
        end 
    else
        local list = mAbils[sid-256]['english']
        if settings.dangerwords.weaponskills:find(string.imatch-{list}) then
            return true
        end 
    end
        
    return false
end

--Check if the actor is actually an npc rather than a player
function isMob(id)
    return get_mob_by_id(id)['is_npc']
end

--This function is used to parse the windower resources
--to fill tables with ability/spell names/ids.
--Created by Byrth
function parse_resources(lines_file)
	local ignore_fields = S{'german','french','japanese','index','recast','fr','frl','de','del','jp','jpl'}
	local completed_table = {}
	local counter = 0
	for i in ipairs(lines_file) do
		local str = tostring(lines_file[i])
		local g,h,typ,key = string.find(str,'<(%w+) id="(%d+)" ')
		if typ == 's' then
			g,h,key = string.find(str,'index="(%d+)" ')
		end
		if key ~=nil then
			completed_table[tonumber(key)]={}
			local q = 1
			while q <= str:len() do
				local a,b,ind,val = string.find(str,'(%w+)="([^"]+)"',q)
				if ind~=nil then
					if not ignore_fields[ind] then
						if val == "true" or val == "false" then
							completed_table[tonumber(key)][ind] = str2bool(val)
						else
							completed_table[tonumber(key)][ind] = val:gsub('&quot;','\42'):gsub('&apos;','\39')
						end
					end
					q = b+1
				else
					q = str:len()+1
				end
			end
			local k,v,english = string.find(str,'>([^<]+)</')
			if english~=nil then
				completed_table[tonumber(key)]['english']=english
			end
		end
	end

	return completed_table
end

--This function was made by Byrth. It's used to split strings
--at a specific character and store them in a table
function split(msg, match)
    if msg == nil then return '' end
    local length = msg:len()
    local splitarr = {}
    local u = 1
    while u <= length do
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
            u = length+1
        end
    end
    return splitarr
end
function nf(field,subfield)
	if field ~= nil then
		return field[subfield]
	else
		return nil
	end
end

function split(msg, match)
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

function parse_resources(lines_file)
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
					if val == "true" or val == "false" then
						completed_table[tonumber(key)][ind] = str2bool(val)
					else
						completed_table[tonumber(key)][ind] = val:gsub('&quot;','\42'):gsub('&apos;','\39')
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

function str2bool(input)
	-- Used in the options_load() function
	if input:lower() == 'true' then
		return true
	elseif input:lower() == 'false' then
		return false
	else
		return nil
	end
end

function bool2str(input)
	if input then
		return 'true'
	end
	return 'false'
end
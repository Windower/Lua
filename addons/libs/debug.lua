require('tablehelper')

function log(...)
	local args = T{...}
	local strtable = T(args:map(tostring))
	add_to_chat(160, strtable:concat(' '))
end

function table.print(t)
	t = T(t)
	t = t:map(tostring)
	tstr = ''
	if #t == 0 then
		first = true
		for key, val in pairs(t) do
			if(first) then
				first = false
			else
				tstr = tstr..', '
			end
			tstr = tstr..key..'='..val
		end
	else
		tstr = t:concat(', ')
	end
	log('{'..tstr..'}')
end

function table.vprint(t)
	t = T(t)
	t = t:map(tostring)
	log('{')
	if #t == 0 then
		for key, val in pairs(t) do
			log('    '..key..'='..val)
		end
	else
		for key = 1, #t do
			log('    '..t[key])
		end
	end
	log('}')
end

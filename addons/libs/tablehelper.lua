_table_meta = {__index=table}

function T(t)
	return setmetatable(t, _table_meta)
end

function table.slice(t, from, to)
	from = from or 1
	if from < 0 then
		from = from%#t+1
	end
	to = to or #t
	if to < 0 then
		to = (to-1)%#t+1
	end
	
	local res = T{}
	for i = from, to do
		res[#res+1] = t[i]
	end
	
	return res
end

function table.map(t, fn)
	local res = T{}
	if #t == 0 then
		for key, val in pairs(t) do
			res[key] = fn(val)
		end
	else
		for key = 1, #t do
			res[key] = fn(t[key])
		end
	end
	
	return res
end

function table.filter(t, fn)
	local res = T{}
	if #t == 0 then
		for key, val in pairs(t) do
			if(fn(val)) then
				res[key] = fn(val)
			end
		end
	else
		for key = 1, #t do
			if(fn(val)) then
				res[#res+1] = fn(t[key])
			end
		end
	end
	
	return res
end

function table.keyfilter(t, fn)
	local res = T{}
	if #t == 0 then
		for key, val in pairs(t) do
			if(fn(key)) then
				res[key] = fn(val)
			end
		end
	else
		for key = 1, #t do
			if(fn(key)) then
				res[#res+1] = fn(t[key])
			end
		end
	end
	
	return res
end

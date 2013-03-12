require 'mathhelper'

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
			if fn(val) then
				res[key] = val
			end
		end
	else
		for key = 1, #t do
			if fn(t[key]) then
				res[#res+1] = t[key]
			end
		end
	end
	
	return res
end

function table.keyfilter(t, fn)
	local res = T{}
	if #t == 0 then
		for key, val in pairs(t) do
			if fn(key) then
				res[key] = val
			end
		end
	else
		for key = 1, #t do
			if fn(key) then
				res[#res+1] = t[key]
			end
		end
	end
	
	return res
end

function table.reduce(t, fn, init)
	t = T(t)
	if t:isempty() then
		return init
	end
	
	acc = init
	for key, val in pairs(t) do
		if acc == nil then
			acc = val
		else
			acc = fn(acc, val)
		end
	end
	
	return acc
end

function table.any(t, fn)
	for key, val in pairs(t) do
		if(fn(val) == true) then
			return true
		end
	end
	return false
end

function table.all(t, fn)
	for key, val in pairs(t) do
		if(fn(val) ~= true) then
			return false
		end
	end
	return true
end

function table.sum(t)
	return table.reduce(t, math.sum, 0)
end

function table.mult(t)
	return table.reduce(t, math.mult, 1)
end

function table.isempty(t)
	return next(t) == nil
end

--[[
A library providing a timing feature.
]]

_libs = _libs or {}
_libs.timeit = true

local timeit = {}

-- Creates a new timer object.
function timeit.new()
	return setmetatable({t = 0}, {__index = timeit})
end

-- Starts the timer.
function timeit.start(timer)
	timer.t = os.clock()
end

-- Stops the timer and returns the time passed since the last timer:start() or timer:next().
function timeit.stop(timer)
	local tdiff = os.clock() - timer.t
	timer.t = 0
	return tdiff
end

-- Restarts the timer and returns the time passed since the last timer:start() or timer:next().
function timeit.next(timer)
	local tdiff = os.clock() - timer.t
	timer.t = os.clock()
	return tdiff
end

-- Returns the time passed since the last timer:start() or timer:next(), but keeps the timer going.
function timeit.check(timer)
	local tdiff = os.clock() - timer.t
	return tdiff
end

-- Returns the normalized time in seconds it took to perform the provided functions rep number of times, with the specified arguments.
function timeit.benchmark(rep, ...)
	_libs.functools = _libs.functools or require 'functools'
	_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
	_libs.logger = _libs.logger or require 'logger'
	
	local args = T{...}
	if type(rep) == 'function' then
		args:insert(1, rep)
		rep = 1000
	end
	
	local fns = T{}
	if type(args[2]) == 'function' then
		local i = args:find(function(arg) return type(arg) ~= 'function' end)
		if i ~= nil then
			fns = args:slice(1, i - 1)
			local fnargs = args:slice(i)
			fns = fns:map(functools.apply-{fnargs})
		else
			fns = args
		end
	else
		fns = args:chunks(2):map(function(x) return x[1]+x[2] end)
	end
	
	local single_timer = timeit.new()
	local total_timer = timeit.new()
	
	local times = T{}
	total_timer:start()
	for _, fn in ipairs(fns) do
		single_timer:start()
		for _ = 1, rep do fn() end
		times:append(single_timer:stop()/rep)
	end
	local total = total_timer:stop()
	
	local bktimes = times:copy()
	times:sort()
	
	local unit = math.floor(math.log(times:last(), 10))
	local len = math.floor(math.log(times:last()/times:first(), 10))
	local dec = math.floor(math.log(rep, 10))
	log(string.format('Ranking of provided functions (time in 10^%ds):', unit))
	local indices = times:map(table.find+{bktimes})
	local str = '#%d:\tFunction %d, execution time: %0'..(len + dec - 2)..'.'..(len + dec - 2)..'f\t%0'..(len+3)..'d%%'
	for place, i in ipairs(indices) do
		if place == 1 then
			log(string.format(str..' (reference value, always 100%%)', place, i, times[place]/10^unit, 100*times[place]/times:first()))
		else
			log(string.format(str..', ~%d%% slower than function %d', place, i, times[place]/10^unit, 100*times[place]/times:first(), math.round(100*(times[place]/times:first() - 1)), indices:first()))
		end
	end
	log(string.format('Total running time: %2.2fs', total))
	
	fns = nil
	times = nil
	collectgarbage()
	
	return bktimes
end

return timeit
--[[
A library providing a timing feature.
]]

_libs = _libs or {}
_libs.timeit = true

timeit = {}

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


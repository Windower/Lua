--[[
A library providing a timing feature.
]]

_libs = _libs or {}

require('functions')
require('tables')

local functions, table = _libs.functions, _libs.tables
local string = require('string')
local math = require('math')
local logger = require('logger')

local timeit = {}

_libs.timeit = timeit

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
            fns = fns:map(functions.apply-{fnargs})
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
    local str = '#%d:\tFunction %d, execution time: %0'..math.max(len + dec - 2, 0)..'.'..math.max(len + dec - 2, 0)..'f\t%0'..(len+3)..'d%%'
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

--[[
Copyright © 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

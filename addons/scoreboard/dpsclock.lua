-- Object to encapsulate DPS Clock functionality

local DPSClock = {
    clock = 0,
    prev_time = 0,
    active = false
}

function DPSClock:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    
    return o
end


function DPSClock:advance()
    local now = os.time()

    if self.prev_time == 0 then
        self.prev_time = now
    end

    self.clock = self.clock + (now - self.prev_time)
    self.prev_time = now

    self.active = true
end


function DPSClock:pause()
    self.active = false
    self.prev_time = 0
end


function DPSClock:is_active()
    return self.active
end

function DPSClock:reset()
    self.active = false
    self.clock = 0
    self.prev_time = 0
end


-- Convert integer seconds into a "HhMmSs" string
function DPSClock:to_string()
    local seconds = self.clock
    
    local hours = math.floor(seconds / 3600)
    seconds = seconds - hours * 3600

    local minutes = math.floor(seconds / 60)
    seconds = seconds - minutes * 60
  
    local hours_str    = hours > 0 and hours .. "h" or ""
    local minutes_str  = minutes > 0 and minutes .. "m" or ""
    local seconds_str  = seconds and seconds .. "s" or ""
	
    return hours_str .. minutes_str .. seconds_str
end

return DPSClock

--[[
Copyright (c) 2013, Jerry Hebert
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Scoreboard nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL JERRY HEBERT BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]



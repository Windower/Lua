--[[
Copyright (c) 2013, Chiara De Acetis
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of <addon name> nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- Blackboard object (wrapper to text box)
-- Manage the textbox alliance list
local Alliance = require 'Alliance'
require 'logger'

local Blackboard = {
visible = true,
settings = nil,
tb_name = 'shoutHelper',
allyName = 'Alliance'
}

function Blackboard:new(settings)
    local o = {}
    self.settings = settings
    o = {ally = Alliance:new()}
    setmetatable(o, self)
    self.__index = self
    windower.text.create(self.tb_name)
    windower.text.set_bg_color(self.tb_name, self.settings.bgtransparency, 30, 30, 30)
    windower.text.set_color(self.tb_name, 255, 225, 225, 225)
    windower.text.set_location(self.tb_name, self.settings.posx, self.settings.posy)
    windower.text.set_visibility(self.tb_name, self.visible)
    windower.text.set_bg_visibility(self.tb_name, 1)
    return o
end

function Blackboard:set_position(posx, posy)
    self.settings.posx = posx
    self.settings.posy = posy
    windower.text.set_location(self.tb_name, posx, posy)
end

function Blackboard:show()
    self.visible = true
    windower.text.set_visibility(self.tb_name, true)
end

function Blackboard:hide()
    self.visible = false
    windower.text.set_visibility(self.tb_name, false)
end

function Blackboard:set(party, jobs)
    --need to check here party format string
    local ptBool = (party == ('party1')) or (party == ('pt1')) or (party == ('1'))
    if(ptBool) then
        self.ally:setParty1(jobs)
    end
    ptBool = (party == ('party2')) or (party == ('pt2')) or (party == ('2'))
    if(ptBool) then
        self.ally:setParty2(jobs)
    end
    ptBool = (party == ('party3')) or (party == ('pt3')) or (party == ('3'))
    if(ptBool) then
        self.ally:setParty3(jobs)
    end
    self:update()
end

function Blackboard:deleteJob(job, party)
    local ptBool = (party == ('party1')) or (party == ('pt1')) or (party == ('1'))
    local party = nil
    if(ptBool) then
        party = 'party1'
    end
    ptBool = (party == ('party2')) or (party == ('pt2')) or (party == ('2'))
    if(ptBool) then
        party = 'party2'
    end
    ptBool = (party == ('party3')) or (party == ('pt3')) or (party == ('3'))
    if(ptBool) then
        party = 'party3'
    end
    self.ally:deleteJob(job, party)
    self:update()
end

function Blackboard:addPlayer(job, name)
    self.ally:addPlayer(job, name)
    self:update()
end

function Blackboard:rmPlayer(name)
    self.ally:removePlayer(name)
    self:update()
end

function Blackboard:update()
    local string = self.ally:printAlly()
    windower.text.set_text(self.tb_name, self.allyName..'\n'..string)
    if (not self.visible) then
        self:show()
    end
end

function Blackboard:reset(party)
    if not party then
        self.ally:deleteAll()
    else
        local ptBool = (party == ('party1')) or (party == ('pt1')) or (party == ('1'))
        if(ptBool) then
            party = 'party1'
        end
        ptBool = (party == ('party2')) or (party == ('pt2')) or (party == ('2'))
        if(ptBool) then
            party = 'party2'
        end
        ptBool = (party == ('party3')) or (party == ('pt3')) or (party == ('3'))
        if(ptBool) then
            party = 'party3'
        end
        self.ally:delete(party)
    end
    self:update()
end

function Blackboard:destroy()
windower.text.delete(self.tb_name)
end

return Blackboard

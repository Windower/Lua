-- Races
local races = {}

local male = string.char(0x81, 0x89)
local males = S{1,3,5,8}
local female = string.char(0x81, 0x8A)
local females = S{2,4,6,7}

local races = {}
races[0]  = {english = 'Precomposed NPC',            }
races[1]  = {english = 'Hume '..male,                }
races[2]  = {english = 'Hume '..female,              }
races[3]  = {english = 'Elvaan '..male,              }
races[4]  = {english = 'Elvaan '..female,            }
races[5]  = {english = 'Tarutaru '..male,            }
races[6]  = {english = 'Tarutaru '..female,          }
races[7]  = {english = 'Mithra',                     }
races[8]  = {english = 'Galka',                      }
races[29] = {english = 'Mithra Child',               }
races[30] = {english = 'Hume/Elvaan Child '..female, }
races[31] = {english = 'Hume/Elvaan Child '..male,   }
races[32] = {english = 'Chocobo Rounsey',            }
races[33] = {english = 'Chocobo Destrier',           }
races[34] = {english = 'Chocobo Palfrey',            }
races[35] = {english = 'Chocobo Courser',            }
races[36] = {english = 'Chocobo Jennet',             }

--[[ Compound values ]]

races.gender = function(race)
    if males[race] then
        return {english = male,                }
    elseif females[race] then
        return {english = female,              }
    end
end

races.convert = function (bits)
    local set = S{}
    
    for i=0,#races do
        if math.floor(bits%(2^(i+1))/2^i) == 1 then
            set:add(i)
        end
    end
    
    return set
end

races.get_equipment_availability = function (bits)
    if bits == 6 then
        return {english = 'Hume',              }
    elseif bits == 24 then
        return {english = 'Elvaan',            }
    elseif bits == 96 then
        return {english = 'Tarutaru',          }
    elseif bits == 510 then
        return {english = 'All races',         }
    elseif bits == 298 then
        return {english = male,                }
    elseif bits == 212 then
        return {english = female,              }
    elseif bits == 2^7 then
        return races[7]
    elseif bits == 2^8 then
        return races[8]
    end
    
    return nil
end

return races

--[[
Copyright (c) 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

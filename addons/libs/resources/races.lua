-- Races
local races = {}

local male = string.char(0x81, 0x89)
local males = S{1,3,5,8}
local female = string.char(0x81, 0x8A)
local females = S{2,4,6,7}

local races = {}
races[0]  = {english = 'Precomposed NPC',           gender = 'None',    }
races[1]  = {english = 'Hume ' .. male,             gender = male,      }
races[2]  = {english = 'Hume ' .. female,           gender = female,    }
races[3]  = {english = 'Elvaan ' .. male,           gender = male,      }
races[4]  = {english = 'Elvaan ' .. female,         gender = female,    }
races[5]  = {english = 'Tarutaru ' .. male,         gender = male,      }
races[6]  = {english = 'Tarutaru ' .. female,       gender = female,    }
races[7]  = {english = 'Mithra',                    gender = female,    }
races[8]  = {english = 'Galka',                     gender = male,      }
races[29] = {english = 'Mithra Child',              gender = female,    }
races[30] = {english = 'Elv Hume Child ' .. female, gender = female,    }
races[31] = {english = 'Elv Hume Child ' .. male,   gender = male,      }
races[32] = {english = 'Chocobo Rounsey',           gender = 'None',    }
races[33] = {english = 'Chocobo Destrier',          gender = 'None',    }
races[34] = {english = 'Chocobo Palfrey',           gender = 'None',    }
races[35] = {english = 'Chocobo Courser',           gender = 'None',    }
races[36] = {english = 'Chocobo Jennet',            gender = 'None',    }

--[[ Compound values ]]

races.item_flags = {}

--[[ Compound values ]]

-- 2^1 + 2^3 + 2^5 + 2^8
races.item_flags[298] = {english = male,                       gender = male       }
-- 2^2 + 2^4 + 2^6 + 2^7
races.item_flags[212] = {english = female,                     gender = female,    }
-- 2^1 + 2^2
races.item_flags[6]   = {english = 'Hume',                     gender = 'Both',    }
-- 2^3 + 2^4
races.item_flags[24]  = {english = 'Elvaan',                   gender = 'Both',    }
-- 2^5 + 2^6
races.item_flags[96]  = {english = 'Tarutaru',                 gender = 'Both',    }
-- 2^9 - 2
races.item_flags[510] = {english = 'All races',                gender = 'Both',    }

for key, val in pairs(races) do
    if type(key) == 'number' then
        races.item_flags[2^key] = val
    end
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

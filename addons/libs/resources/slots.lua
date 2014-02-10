-- Slots
local slots = {}

slots[0]   = {english = 'Main',             }
slots[1]   = {english = 'Sub',              }
slots[2]   = {english = 'Ranged',           }
slots[3]   = {english = 'Ammo',             }
slots[4]   = {english = 'Head',             }
slots[5]   = {english = 'Body',             }
slots[6]   = {english = 'Hands',            }
slots[7]   = {english = 'Legs',             }
slots[8]   = {english = 'Feet',             }
slots[9]   = {english = 'Neck',             }
slots[10]  = {english = 'Waist',            }
slots[11]  = {english = 'Left Ear',         }
slots[12]  = {english = 'Right Ear',        }
slots[13]  = {english = 'Left Ring',        }
slots[14]  = {english = 'Right Ring',       }
slots[15]  = {english = 'Back',             }

--[[ Compound values ]]

slots.category = {}
for key, value in pairs(slots) do
    if type(key) == 'number' then
        slots.category[key] = value
    end
end

slots.category[0]  = {english = 'Melee',    }
slots.category[1]  = slots.category[0]
slots.category[11] = {english = 'Ear',      }
slots.category[12] = slots.category[11]
slots.category[13] = {english = 'Ring',     }
slots.category[14] = slots.category[13]

return slots

--[[
Copyright (c) 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

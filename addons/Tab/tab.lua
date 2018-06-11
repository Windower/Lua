--[[
Copyright © 2018, from20020516
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of Tab nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL from20020516 BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
_addon.name = 'Tab'
_addon.author = 'from20020516'
_addon.version = '1.0'

key_flags={}

--replace input tab. validated in Japanese keyboard. please let me know if problems occur with the English keyboard.
windower.register_event('keyboard',function(dik,flags,blocked)
    key_flags[dik] = flags
    if flags and not windower.chat.is_open(true) then
        if dik == 15 and not st then --Tab
            st = key_flags[45] and '<stpc>' or '<stnpc>' --X
            windower.chat.input('/ta '..st)
            return true; --tab input blocking. it's probably broken..
        elseif dik == 1 or dik == 28 then --Esc or Enter
            st = false
        end
    end
end)

--block error message.
windower.register_event('incoming text',function(original,modified,original_mode)
    if original_mode == 123 and st then
        return true; --error message blocking when target doesn't exists.
    end
end)

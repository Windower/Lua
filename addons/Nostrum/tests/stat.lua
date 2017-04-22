--[[Copyright © 2014-2017, trv
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Nostrum nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL trv BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER I N CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.--]]

return function()
	for i = 1, 3 do
		local party = alliance[i]
		
		for j = 1, 6 do
			if party[j] then
				local lookup = alliance_lookup[party[j]]
				-- party, position, new, old
				dbg['hp change'](i, j, 9999, lookup.hp)
				dbg['mp change'](i, j, 1111, lookup.mp)
				dbg['tp change'](i, j, 200, lookup.tp)
				coroutine.sleep(0.2)
			end
		end
	end

	for k = 1, 4 do
		for i = 1, 3 do
			local party = alliance[i]
			
			for j = 1, 6 do
				if party[j] then
					local old, new = (5-k)*25+1, (5-k)*25

					dbg['hpp change'](i, j, new, old)
					dbg['mpp change'](i, j, new, old)
					coroutine.sleep(0.2)
				end
			end
		end
	end
end, [[This test will change the HP, MP, HPP, MPP, and
	TP of each player starting at p0 and ending at a15.]]

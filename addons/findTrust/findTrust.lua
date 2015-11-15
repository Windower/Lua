--Copyright © 2015, Damien Dennehy
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name    = 'findTrust'
_addon.author  = 'Zubis'
_addon.version = '1.0.0'
_addon.command = 'findTrust'

require('sets')
res = require('resources')

windower.register_event('addon command',function (...)
	missing_trust_names = {}
	
	 --Get all trusts, and all spells currently owned	 
	trust = res.spells:type('Trust'):keyset()
	trust_have = windower.ffxi.get_spells()

	--Remove trusts not owned
	for k,v in pairs(trust_have) do
		if not v then
			trust_have[k] = nil
		end
	end

	--Get missing trusts
	missing = trust - trust_have

	--Get total number of trusts
	trust_len = trust:length()
	missing_len = 0

	--Exclude UC trusts
	for spell in missing:it() do
		if not string.match(res.spells[spell].name, "(UC)") then
			missing_len = missing_len + 1
			table.insert(missing_trust_names, res.spells[spell].name)
		end
	end

	--Get total owned
	trust_owned_len = trust_len - missing_len

	--Sort missing trusts by name
	table.sort(missing_trust_names)

	--Output summary
	windower.add_to_chat(7, 'findTrust: You have ' .. trust_owned_len .. ' out of ' .. trust_len .. ' trusts. Total missing: ' .. missing_len)

	--List all missing trust names
	for i, spell in ipairs(missing_trust_names) do
	  windower.add_to_chat(7, " - Missing: " .. spell)
	end
end)
	 

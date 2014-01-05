-- Copyright (c) 2014, Cairthenn
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of InfoReplacer nor the
      -- names of its contributors may be used to endorse or promote products
      -- derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL Cairthenn BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.author = 'Cairthenn'
_addon.name = 'InfoReplacer'
_addon.version = '1.0'
_addon.command = 'inforeplacer'

require('tables')
require('strings')
require('logger')
res = require('resources')

replace = require('reps')
items = res.items

windower.register_event('addon command', function(...)
	local available = ''
	for k in pairs(_replace) do
		available = available..', '..k
	end
	log('Available replacement variable list (prefix with %): \n'..available:sub(3))
end)

windower.register_event('outgoing text', function(original,modified,blocked)
    local t_blocks = modified:psplit('%%[%w_]+',false,true)
	for k,v in pairs(t_blocks) do
        local _lower = string.lower(v)
		if v:sub(1,1) == '%' and replace[_lower:sub(2)] then
			t_blocks[k] = replace[_lower:sub(2)]() or "None"
		end
	end
	return blocked or t_blocks:concat('')
end)

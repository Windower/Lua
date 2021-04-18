--[[Copyright © 2021, Arico
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
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. --]]

_addon.name = 'Stubborn'
_addon.author = 'Arico'
_addon.version = '1'
_addon.command = 'stubborn'

require('pack')
require('strings')
require('logger')
packets = require('packets')


windower.register_event('outgoing chunk', function(id, original, modified, injected, blocked)
    if id == 0x01a then
        local p = packets.parse('outgoing', original)
        if p['Category'] == 5 and not injected then
            log('You are too stubborn to call for help! Use //stubborn to call for help.')
            return true
        end
    end
end)

windower.register_event('addon command', function(...)
    local target = windower.ffxi.get_mob_by_target("t")
    if target and target.claim_id ~= 0 then  
        local p = packets.new('outgoing', 0x1a, {
                ['Target'] = target['id'],
                ['Target Index'] = target['index'],
                ['Category'] = 5,})
        packets.inject(p)
    end
end)
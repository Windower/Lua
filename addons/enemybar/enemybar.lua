--[[
Copyright © 2015, Mike McKee
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of enemybar nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mike McKee BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

_addon.name = 'enemybar'
_addon.author = 'mmckee'
_addon.version = '1.0.2'
_addon.language = 'English'

config = require('config')
images = require('images')
texts = require('texts')
require('gui_settings')
require('targetBar')
require('subtargetBar')

player_id = 0
debug_string = ''

windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in then
        player_id = windower.ffxi.get_player().id
    end
end)

windower.register_event('prerender', render_target_bar)
windower.register_event('prerender', render_subtarget_bar)
windower.register_event('target change', target_change)

windower.register_event('logout', function(...)
    -- This is a super cheap fix, but it works. 
    windower.send_command("input //lua r enemybar");        
end)

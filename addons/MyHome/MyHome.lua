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
    * Neither the name of MyHome nor the
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
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.name = 'MyHome'
_addon.author = 'from20020516'
_addon.version = '1.0'
_addon.commands = {'myhome','mh','warp'}

require('logger')
extdata = require('extdata')

lang = string.lower(windower.ffxi.get_info().language)
item_info = {
    [1]={id=28540,japanese='デジョンリング',english='"Warp Ring"',slot=13},
    [2]={id=17040,japanese='デジョンカジェル',english='"Warp Cudgel"',slot=0},
    [3]={id=4181,japanese='呪符デジョン',english='"Instant Warp"'}}

function search_item()
    local item_array = {}
    local bags = {0,8,10,11,12} --inventory,wardrobe1-4
    local get_items = windower.ffxi.get_items
    for i=1,#bags do
        for _,item in ipairs(get_items(bags[i])) do
            if item.id > 0 then
                item_array[item.id] = item
                item_array[item.id].bag = bags[i]
            end
        end
    end
    for index,stats in pairs(item_info) do
        local item = item_array[stats.id]
        local set_equip = windower.ffxi.set_equip
        if item then
            local ext = extdata.decode(item)
            local enchant = ext.type == 'Enchanted Equipment'
            local recast = enchant and ext.charges_remaining > 0 and math.max(ext.next_use_time+18000-os.time(),0)
            local usable = recast and recast == 0
            log(stats[lang],usable and '' or recast and recast..' sec recast.')
            if usable or ext.type == 'General' then
                if enchant and item.status ~= 5 then --not equipped
                    set_equip(item.slot,stats.slot,item.bag)
                    log_flag = true
                    repeat --waiting cast delay
                        coroutine.sleep(1)
                        local ext = extdata.decode(get_items(item.bag,item.slot))
                        local delay = ext.activation_time+18000-os.time()
                        if delay > 0 then
                            log(stats[lang],delay)
                        elseif log_flag then
                            log_flag = false
                            log('Item use within 3 seconds..')
                        end
                    until ext.usable or delay > 10
                end
                windower.chat.input('/item '..windower.to_shift_jis(stats[lang])..' <me>')
                break;
            end
        else
            log('You don\'t have '..stats[lang]..'.')
        end
    end
end

windower.register_event('addon command',function()
    local player = windower.ffxi.get_player()
    local get_spells = windower.ffxi.get_spells()
    local spell = S{player.main_job_id,player.sub_job_id}[4]
        and (get_spells[261] and player.vitals.mp >= 100 and {japanese='デジョン',english='"Warp"'}
        or get_spells[262] and player.vitals.mp >= 150 and {japanese='デジョンII',english='"Warp II"'})
    if spell then
        windower.chat.input('/ma '..windower.to_shift_jis(spell[lang])..' <me>')
    else
        search_item()
    end
end)

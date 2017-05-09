--[[Copyright © 2014-2016, smd111
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
DISCLAIMED. IN NO EVENT SHALL Byrth or smd111 BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.name = 'latentchecker'
_addon.author = 'smd111'
_addon.command = 'latentchecker'
_addon.commands = {'lc'}
_addon.version = '1.1'

extdata = require 'extdata'
res = require 'resources'
bag = 'Satchel'
bag_id = 5

function validate_bag(id)
    local bag_info = windower.ffxi.get_bag_info(id)
    if bag_info.enabled and bag_info.max > bag_info.count then
        return true
    end
    return false
end

function check_space()
    if validate_bag(bag_id) then
        return bag_id
    else
        for i=5,8 do
            if validate_bag(i) then
                bag_id = i -- Update bag ID to be the bag that will work
                return bag_id
            end
        end
    end
    return false
end

function match_item(target_item,m)
    return type(m) == 'table' and m.id and res.items[m.id] and (res.items[m.id].en:lower() == target_item:lower() or res.items[m.id].enl:lower() == target_item:lower())
end


windower.register_event('addon command', function(command, ...)
    local trial_weapons = {"axe of trials","gun of trials","sword of trials","knuckles of trials","spear of trials","scythe of trials","sapara of trials",
        "bow of trials","club of trials","pole of trials","pick of trials","dagger of trials","tachi of trials","kodachi of trials","sturdy axe","burning fists",
        "werebuster","mage's staff","vorpal sword","swordbreaker","brave blade","death sickle","double axe","dancing dagger","killer bow","windslicer",
        "sasuke katana","radiant lance","scepter staff","wightslayer","quicksilver","inferno claws","main gauche","elder staff","destroyers","senjuinrikio",
        "heart snatcher","subduer","dissector","expunger","morgenstern","gravedigger","rampager","coffinmaker","gonzo-shizunori","retributor","michishiba","thyrsusstab",
        "trial wand","trial blade"}
    if command == 'run' then
        windower.add_to_chat(121,'latentchecker: Starting...')
        windower.ffxi.set_equip(0, 0, 0) -- Remove main/sub weapons
        windower.ffxi.set_equip(0, 2, 0) -- Remove ranged weapons
        coroutine.sleep(1.2)
        for _,target_item in pairs(trial_weapons) do
            if not check_space() then
                windower.add_to_chat(123,'latentchecker: not able to swap item. No available space found in bags.')
                return
            end
            
            for n,m in pairs(windower.ffxi.get_items(0)) do -- Iterate over inventory
                if match_item(target_item,m) then
                    windower.ffxi.put_item(bag_id,n)
                    coroutine.sleep(1.2)
                    windower.add_to_chat(55,'latentchecker: '..res.items[m.id].en..' has '..tostring(extdata.decode(windower.ffxi.get_items(0,n)).ws_points)..' WS points')
                    coroutine.sleep(1.2)
                    
                    if not validate_bag(0) then
                        windower.add_to_chat(123,'latentchecker: Inventory became full while running.\nlatentchecker: Stopping.')
                        return
                    end
                    for j,k in pairs(windower.ffxi.get_items(bag_id)) do
                        if match_item(target_item,k) then
                            windower.ffxi.get_item(bag_id,j)
                            break
                        end
                    end
                end
            end
        end
        windower.add_to_chat(121,'latentchecker: Done! Remember to re-dress yourself!')
    else
        print('latentchecker: My only valid command is "run", which will reset your TP.')
    end
end)

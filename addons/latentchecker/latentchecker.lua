_addon.name = 'latentchecker'
_addon.author = 'byrth,smd111'
_addon.command = 'latentchecker'
_addon.commands = {'lc'}
_addon.version = '1.0'

extdata = require 'extdata'
res = require 'resources'
bag = 'satchel'
bag_id = 5
unequip = true
function check_space()
    for i,v in pairs(res.bags) do
        if v.access == "everywhere" and v.en ~= "inventory" and windower.ffxi.get_items(v.id).max ~= windower.ffxi.get_items(v.id).count then
            bag = v.en:lower():gsub("^%l", string.upper)
            bag_id = i
            break
        end
    end
end
function find_item(target_item)
    if windower.ffxi.get_items(bag_id).max == windower.ffxi.get_items(bag_id).count then
        check_space()
    end
    for i,v in pairs(windower.ffxi.get_items().inventory) do
        if v.id and res.items[v.id] and (res.items[v.id].en:lower() == target_item:lower() or res.items[v.id].enl:lower() == target_item:lower()) then
            windower.packets.inject_outgoing(0x29,string.char(0x29,6,0,0,1,0,0,0,0,bag_id,i,0x52))
            coroutine.sleep(2)
            print('weapon skills done = '..extdata.decode(windower.ffxi.get_items().inventory[i]).ws_points)
            coroutine.sleep(2)
            get_back_item(target_item)
            break
        end
    end
end
function get_back_item(target_item)
    if windower.ffxi.get_items(0).max == windower.ffxi.get_items(0).count then
        error('Inventory became full while running.\nStoping.')
        return
    end
    for i,v in pairs(windower.ffxi.get_items()[bag:lower()]) do
        if v.id and res.items[v.id] and (res.items[v.id].en:lower() == target_item:lower() or res.items[v.id].enl:lower() == target_item:lower()) then
            windower.packets.inject_outgoing(0x29,string.char(0x29,6,0,0,1,0,0,0,bag_id,0,i,0x52))
            print('done')
            break
        end
    end
end

windower.register_event('addon command', function(command, ...)
    command = command or 'help'
    args = l{...}
    local trial_weapons = {"axe of trials","gun of trials","sword of trials","knuckles of trials","spear of trials","scythe of trials","sapara of trials",
    "bow of trials","club of trials","pole of trials ","pick of trials","dagger of trials","tachi of trials","kodachi of trials","sturdy axe","burning fists",
    "werebuster","mage's staff","vorpal sword","swordbreaker","brave blade","death sickle","double axe","dancing dagger","killer bow","windslicer","sasuke katana",
    "radiant lance","scepter staff","wightslayer","quicksilver","inferno claws","main gauche","elder staff"}
    if command == 'run' then
        print('starting')
        if unequip then
            windower.ffxi.set_equip(0, 0, 0)
        end
        for i,v in pairs(trial_weapons) do
            find_item(v)
        end
    end
end)

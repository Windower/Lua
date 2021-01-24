_addon.name = 'Drop'
_addon.author = 'Arico'
_addon.version = '1'
_addon.commands = {'drop'}


packets = require('packets')
require('luau')
res = require('resources')
require('logger')

check_inv = function(item_id)
        for k, v in pairs(windower.ffxi.get_items().inventory) do
            if type(v) == 'table' and v.id == item_id then
                return true
            end
        end
    return false
end
get_item_resource = function(item)
    for k, v in pairs(res.items) do
        if v.english:lower() == item:lower() or v.japanese:lower() == item:lower()  then
            return v
        end
    end
    return nil
end

drop_item = function(item_to_drop) 
        for k, v in pairs(windower.ffxi.get_items().inventory) do
        if type(v) == "table" then
            if v.id and v.id == item_to_drop then
                
                local drop_packet = packets.new('outgoing', 0x028, {
                    ["Count"] = v.count,
                    ["Bag"] = 0,
                    ["Inventory Index"] = k,
                })
                packets.inject(drop_packet)
                coroutine.sleep(.5)
            end
    end     
    end
end

windower.register_event('addon command', function (...)
    args = {...};
    if args[1]:lower() == 'help' then
        log('//drop <\30\02item\30\01>\nDrops a specific \30\02item\30\01. does not require quotes, capitalization, and accepts auto-translate.') 
        return
    end
    for i, v in pairs(args) do args[i]=windower.convert_auto_trans(args[i]) end --thanks Akaden
    local item_name = table.concat(args, ' ',1,#args):lower()
    
    item = get_item_resource(item_name)
    if item then
        if check_inv(item.id) then
            drop_item(item.id)
        else 
            log(('No \30\02%s\30\01 was found in your inventory.':format(item_name)))
        end
    else
        log('\30\02%s\30\01 does not exist.':format(item_name))
    end     
end)
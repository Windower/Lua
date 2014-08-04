-- Short script to generate a list of what items you have can be stored in a slip

require('luau')

local slips = require('slips')
local res   = require ('resources').items
local items = windower.ffxi.get_items()


for _,container in pairs (slips.default_storages) do
    for _,item in ipairs (items[container]) do
        if (item.id > 0) then
            for slip_id,slip_table in pairs (slips.items) do
                for _,j in ipairs (slip_table) do
                    if (j == item.id) then
                        log ("%s:%s can be stored in %s":format(container:color(259), res[item.id].name:color(258), res[slip_id].name:color(240)))
                    end
                end
            end
        end
    end
end

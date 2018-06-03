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
            ext = extdata.decode(item)
            local enchant = ext.type == 'Enchanted Equipment'
            local recast = enchant and ext.charges_remaining > 0 and math.max(ext.next_use_time+18000-os.time(),0)
            local usable = recast and recast == 0
            log(stats[lang],usable and '' or recast..' sec recast.')
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
            log(stats[lang],false)
        end
    end
end

windower.register_event('addon command',function()
    local player = windower.ffxi.get_player()
    if S{player.main_job_id,player.sub_job_id}[4] then --BLM
        local spell = {japanese='デジョンII',english='"Warp II"'}
        windower.chat.input('/ma '..windower.to_shift_jis(spell[lang])..' <me>')
    else
        search_item()
    end
end)

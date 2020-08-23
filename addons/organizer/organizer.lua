--Copyright (c) 2015, Byrthnoth and Rooks
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

res = require 'resources'
files = require 'files'
require 'pack'
Items = require 'items'
extdata = require 'extdata'
logger = require 'logger'
require 'tables'
require 'lists'
require 'functions'
config = require 'config'
slips = require 'slips'

_addon.name = 'Organizer'
_addon.author = 'Byrth, maintainer: Rooks'
_addon.version = 0.20200714
_addon.commands = {'organizer','org'}

_static = {
    bag_ids = {
        inventory=0,
        safe=1,
        storage=2,
        temporary=3,
        locker=4,
        satchel=5,
        sack=6,
        case=7,
        wardrobe=8,
        safe2=9,
        wardrobe2=10,
        wardrobe3=11,
        wardrobe4=12,
    },
    wardrobe_ids = {[8]=true,[10]=true,[11]=true,[12]=true},
    usable_bags = {1,9,4,2,5,6,7,8,10,11,12}
}

_global = {
    language = 'english',
    language_log = 'english_log',
}

_ignore_list = {}
_retain = {}
_valid_pull = {}
_valid_dump = {}

default_settings = {
    dump_bags = {['Safe']=1,['Safe2']=2,['Locker']=3,['Storage']=4},
    bag_priority = {['Safe']=1,['Safe2']=2,['Locker']=3,['Storage']=4,['Satchel']=5,['Sack']=6,['Case']=7,['Inventory']=8,['Wardrobe']=9,['Wardrobe2']=10,['Wardrobe3']=11,['Wardrobe4']=12,},
    item_delay = 0,
    ignore = {},
    retain = {
        ["moogle_slip_gear"]=false,
        ["seals"]=false,
        ["items"]=false,
        ["slips"]=false,
    },
    auto_heal = false,
    default_file='default.lua',
    verbose=false,
}

_debugging = {
    debug = {
        ['contains']=true,
        ['command']=true,
        ['find']=true,
        ['find_all']=true,
        ['items']=true,
        ['move']=true,
        ['settings']=true,
        ['stacks']=true
    },
    debug_log = 'data\\organizer-debug.log',
    enabled = false,
    warnings = false, -- This mode gives warnings about impossible item movements and crash conditions.
}

debug_log = files.new(_debugging.debug_log)

function s_to_bag(str)
    if not str and tostring(str) then return end
    for i,v in pairs(res.bags) do
        if v.en:lower():gsub(' ', '') == str:lower() then
            return v.id
        end
    end
end

windower.register_event('load',function()
    debug_log:write('Organizer loaded at '..os.date()..'\n')

    if debugging then windower.debug('load') end
    options_load()
end)

function options_load( )
    if not windower.dir_exists(windower.addon_path..'data\\') then
        org_debug("settings", "Creating data directory")
        windower.create_dir(windower.addon_path..'data\\')
        if not windower.dir_exists(windower.addon_path..'data\\') then
            org_error("unable to create data directory!")
        end
    end

    for bag_name, bag_id in pairs(_static.bag_ids) do
        if not windower.dir_exists(windower.addon_path..'data\\'..bag_name) then
            org_debug("settings", "Creating data directory for "..bag_name)
            windower.create_dir(windower.addon_path..'data\\'..bag_name)
            if not windower.dir_exists(windower.addon_path..'data\\'..bag_name) then
                org_error("unable to create"..bag_name.."directory!")
            end
        end
    end

    -- We can't just do a:
    --
    -- settings = config.load('data\\settings.xml', default_settings)
    --
    -- because the config library will try to merge them, and it will
    -- add back anything a user has removed (like items in bag_priority)

    if windower.file_exists(windower.addon_path..'data\\settings.xml') then
        org_debug("settings", "Loading settings from file")
        settings = config.load('data\\settings.xml')
    else
        org_debug("settings", "Saving default settings to file")
        settings = config.load('data\\settings.xml', default_settings)
    end

    -- Build the ignore list
    if(settings.ignore) then
        for bn,i_list in pairs(settings.ignore) do
            bag_name = bn:lower()
            _ignore_list[bag_name] = {}
            for _,ignore_name in pairs(i_list) do
                org_verbose("Adding "..ignore_name.." in the "..bag_name.." to the ignore list")
                _ignore_list[bag_name][ignore_name] = 1
            end
        end
    end

    -- Build a hard-wired pull list
    for bag_name,_ in pairs(settings.bag_priority) do
         org_verbose("Adding "..bag_name.." to the pull list")
        _valid_pull[s_to_bag(bag_name)] = 1
    end

    -- Build a hard-wired dump list
    for bag_name,_ in pairs(settings.dump_bags) do
         org_verbose("Adding "..bag_name.." to the push list")
        _valid_dump[s_to_bag(bag_name)] = 1
    end

    -- Build the retain lists
    if(settings.retain) then
        if(settings.retain.moogle_slip_gear == true) then
            org_verbose("Moogle slip gear set to retain")
            slip_lists = require('slips')
            for slip_id,slip_list in pairs(slip_lists.items) do
                for item_id in slip_list:it() do
                    _retain[item_id] = "moogle slip"
                    org_debug("settings", "Adding ("..res.items[item_id].english..') to slip retain list')
                end
            end
        end

        if(settings.retain.seals == true) then
            org_verbose("Seals set to retain")
            seals = {1126,1127,2955,2956,2957}
            for _,seal_id in pairs(seals) do
                _retain[seal_id] = "seal"
                org_debug("settings", "Adding ("..res.items[seal_id].english..') to slip retain list')
            end
        end

        if(settings.retain.items == true) then
            org_verbose("Non-equipment items set to retain")
        end
		
        if(settings.retain.slips == true) then
            org_verbose("Slips set to retain")
            for _,slips_id in pairs(slips.storages) do
                _retain[slips_id] = "slips"
                org_debug("settings", "Adding ("..res.items[slips_id].english..') to slip retain list')
            end
        end
    end

    -- Always allow inventory and wardrobe, obviously
    _valid_dump[0] = 1
    _valid_pull[0] = 1
    _valid_dump[8] = 1
    _valid_pull[8] = 1
    _valid_dump[10] = 1
    _valid_pull[10] = 1
    _valid_dump[11] = 1
    _valid_pull[11] = 1
    _valid_dump[12] = 1
    _valid_pull[12] = 1

end



windower.register_event('addon command',function(...)
    local inp = {...}
    -- get (g) = Take the passed file and move everything to its defined location.
    -- tidy (t) = Take the passed file and move everything that isn't in it out of my active inventory.
    -- organize (o) = get followed by tidy.
    local command = table.remove(inp,1):lower()
    if command == 'eval' then
        assert(loadstring(table.concat(inp,' ')))()
        return
    end

    local bag = 'all'
    if inp[1] and (_static.bag_ids[inp[1]:lower()] or inp[1]:lower() == 'all') then
        bag = table.remove(inp,1):lower()
    end

    org_debug("command", "Using '"..bag.."' as the bag target")


    file_name = table.concat(inp,' ')
    if string.length(file_name) == 0 then
        file_name = default_file_name()
    end

    if file_name:sub(-4) ~= '.lua' then
        file_name = file_name..'.lua'
    end
    org_debug("command", "Using '"..file_name.."' as the file name")


    if (command == 'g' or command == 'get') then
        org_debug("command", "Calling get with file_name '"..file_name.."' and bag '"..bag.."'")
        get(thaw(file_name, bag))
    elseif (command == 't' or command == 'tidy') then
        org_debug("command", "Calling tidy with file_name '"..file_name.."' and bag '"..bag.."'")
        tidy(thaw(file_name, bag))
    elseif (command == 'f' or command == 'freeze') then

        org_debug("command", "Calling freeze command")
        local items = Items.new(windower.ffxi.get_items(),true)
        local frozen = {}
        items[3] = nil -- Don't export temporary items
        if _static.bag_ids[bag] then
            org_debug("command", "Bag: "..bag)
            freeze(file_name,bag,items)
        else
            for bag_id,item_list in items:it() do
                org_debug("command", "Bag ID: "..bag_id)
                -- infinite loop protection
                if(frozen[bag_id]) then
                    org_warning("Tried to freeze ID #"..bag_id.." twice, aborting")
                    return
                end
                frozen[bag_id] = 1
                freeze(file_name,res.bags[bag_id].english:lower():gsub(' ', ''),items)
            end
        end
    elseif (command == 'o' or command == 'organize') then
        org_debug("command", "Calling organize command")
        organize(thaw(file_name, bag))
    end

    if settings.auto_heal and tostring(settings.auto_heal):lower() ~= 'false' then
        org_debug("command", "Automatically healing")
        windower.send_command('input /heal')
    end

    org_debug("command", "Organizer complete")

end)

function get(goal_items,current_items)
    org_verbose('Getting!')
    if goal_items then
        count = 0
        failed = 0
        current_items = current_items or Items.new()
        goal_items, current_items = clean_goal(goal_items,current_items)
        for bag_id,inv in goal_items:it() do
            for ind,item in inv:it() do
                if not item:annihilated() then
                    local start_bag, start_ind = current_items:find(item)
                    -- Table contains a list of {bag, pos, count}
                    if start_bag then
                        if not current_items:route(start_bag,start_ind,bag_id) then
                            org_warning('Unable to move item.')
                            failed = failed + 1
                        else
                            count = count + 1
                        end
                        simulate_item_delay()
                    else
                        -- Need to adapt this for stacking items somehow.
                        org_warning(res.items[item.id].english..' not found.')
                    end
                end
            end
        end
        org_verbose("Got "..count.." item(s), and failed getting "..failed.." item(s)")
    end
    return goal_items, current_items
end

function freeze(file_name,bag,items)
    org_debug("command", "Entering freeze function with bag '"..bag.."'")
    local lua_export = T{}
    local counter = 0
    for _,item_table in items[_static.bag_ids[bag]]:it() do
        counter = counter + 1
        if(counter > 80) then
            org_warning("We hit an infinite loop in freeze()! ABORT.")
            return
        end
        org_debug("command", "In freeze loop for bag '"..bag.."'")
        org_debug("command", "Processing '"..item_table.log_name.."'")

        local temp_ext,augments = extdata.decode(item_table)
        if temp_ext.augments then
            org_debug("command", "Got augments for '"..item_table.log_name.."'")
            augments = table.filter(temp_ext.augments,-functions.equals('none'))
        end
        lua_export:append({name = item_table.name,log_name=item_table.log_name,
            id=item_table.id,extdata=item_table.extdata:hex(),augments = augments,count=item_table.count})
    end
    -- Make sure we have something in the bag at all
    if lua_export[1] then
        org_verbose("Freezing "..tostring(bag)..".")
        local export_file = files.new('/data/'..bag..'/'..file_name,true)
        export_file:write('return '..lua_export:tovstring({'augments','log_name','name','id','count','extdata'}))
    else
        org_debug("command", "Got nothing, skipping '"..bag.."'")
    end
end

function tidy(goal_items,current_items,usable_bags)
    org_debug("command", "Entering tidy()")
    usable_bags = usable_bags or get_dump_bags()
    -- Move everything out of items[0] and into other inventories (defined by the passed table)
    if goal_items and goal_items[0] and goal_items[0]._info.n > 0 then
        current_items = current_items or Items.new()
        goal_items, current_items = clean_goal(goal_items,current_items)
        for index,item in current_items[0]:it() do
            if not goal_items[0]:contains(item,true) then
                org_debug("command", "Putting away "..item.log_name)
                current_items[0][index]:put_away(usable_bags)
                simulate_item_delay()
            end
        end
    end
    return goal_items, current_items
end

function organize(goal_items)
    org_message('Starting...')
    local current_items = Items.new()
    local dump_bags = get_dump_bags()

    local inventory_max = windower.ffxi.get_bag_info(0).max
    if current_items[0].n == inventory_max then
        tidy(goal_items,current_items,dump_bags)
    end
    if current_items[0].n == inventory_max then
        org_error('Unable to make space, aborting!')
        return
    end
    
    local remainder = math.huge
    while remainder do
        goal_items, current_items = get(goal_items,current_items)
        
        goal_items, current_items = clean_goal(goal_items,current_items)
        goal_items, current_items = tidy(goal_items,current_items,dump_bags)
        remainder = incompletion_check(goal_items,remainder)
        if(remainder) then
            org_verbose("Remainder: "..tostring(remainder)..' Current: '..current_items[0]._info.n,1)
        else
            org_verbose("No remainder, so we found everything we were looking for!")
        end
    end
    goal_items, current_items = tidy(goal_items,current_items,dump_bags)
    
    local count,failures = 0,T{}
    for bag_id,bag in goal_items:it() do
        for ind,item in bag:it() do
            if item:annihilated() then
                count = count + 1
            else
                item.bag_id = bag_id
                failures:append(item)
            end
        end
    end
    org_message('Done! - '..count..' items matched and '..table.length(failures)..' items missing!')
    if table.length(failures) > 0 then
        for i,v in failures:it() do
            org_verbose('Item Missing: '..i.name..' '..(i.augments and tostring(T(i.augments)) or ''))
        end
    end
end

function clean_goal(goal_items,current_items)
    for i,inv in goal_items:it() do
        for ind,item in inv:it() do
            local potential_ind = current_items[i]:contains(item)
            if potential_ind then
                -- If it is already in the right spot, delete it from the goal items and annihilate it.
                local count = math.min(goal_items[i][ind].count,current_items[i][potential_ind].count)
                goal_items[i][ind]:annihilate(goal_items[i][ind].count)
                current_items[i][potential_ind]:annihilate(current_items[i][potential_ind].count)
            end
        end
    end
    return goal_items, current_items
end

function incompletion_check(goal_items,remainder)
    -- Does not work. On cycle 1, you fill up your inventory without purging unnecessary stuff out.
    -- On cycle 2, your inventory is full. A gentler version of tidy needs to be in the loop somehow.
    local remaining = 0
    for i,v in goal_items:it() do
        for n,m in v:it() do
            if not m:annihilated() then
                remaining = remaining + 1
            end
        end
    end
    return remaining ~= 0 and remaining < remainder and remaining
end

function thaw(file_name,bag)
    local bags = _static.bag_ids[bag] and {[bag]=file_name} or table.reassign({},_static.bag_ids) -- One bag name or all of them if no bag is specified
    if settings.default_file:sub(-4) ~= '.lua' then
        settings.default_file = settings.default_file..'.lua'
    end
    for i,v in pairs(_static.bag_ids) do
        bags[i] = bags[i] and windower.file_exists(windower.addon_path..'data/'..i..'/'..file_name) and file_name or default_file_name()
    end
    bags.temporary = nil
    local inv_structure = {}
    for cur_bag,file in pairs(bags) do
        local f,err = loadfile(windower.addon_path..'data/'..cur_bag..'/'..file)
        if f and not err then
            local success = false
            success, inv_structure[cur_bag] = pcall(f)
            if not success then
                org_warning('User File Error (Syntax) - '..inv_structure[cur_bag])
                inv_structure[cur_bag] = nil
            end
        elseif bag and cur_bag:lower() == bag:lower() then
            org_warning('User File Error (Loading) - '..err)
        end
    end
    -- Convert all the extdata back to a normal string
    for i,v in pairs(inv_structure) do
        for n,m in pairs(v) do
            if m.extdata then
                inv_structure[i][n].extdata = string.parse_hex(m.extdata)
            end
        end
    end
    return Items.new(inv_structure)
end

function org_message(msg,col)
    windower.add_to_chat(col or 8,'Organizer: '..msg)
    flog(_debugging.debug_log, 'Organizer [MSG] '..msg)
end

function org_warning(msg)
    if _debugging.warnings then
        windower.add_to_chat(123,'Organizer: '..msg)
    end
    flog(_debugging.debug_log, 'Organizer [WARN] '..msg)
end

function org_debug(level, msg)
    if(_debugging.enabled) then
        if (_debugging.debug[level]) then
            flog(_debugging.debug_log, 'Organizer [DEBUG] ['..level..']: '..msg)
        end
    end
end


function org_error(msg)
    error('Organizer: '..msg)
    flog(_debugging.debug_log, 'Organizer [ERROR] '..msg)
end

function org_verbose(msg,col)
    if tostring(settings.verbose):lower() ~= 'false' then
        windower.add_to_chat(col or 8,'Organizer: '..msg)
    end
    flog(_debugging.debug_log, 'Organizer [VERBOSE] '..msg)
end

function default_file_name()
    player = windower.ffxi.get_player()
    job_name = res.jobs[player.main_job_id]['english_short']
    return player.name..'_'..job_name..'.lua'
end

function simulate_item_delay()
    if settings.item_delay and settings.item_delay > 0 then
        coroutine.sleep(settings.item_delay)
    end
end

function get_dump_bags()
    local dump_bags = {}
    for i,v in pairs(settings.dump_bags) do
        if i and s_to_bag(i) then
            dump_bags[tonumber(v)] = s_to_bag(i)
        elseif i then
            org_error('The bag name ("'..tostring(i)..'") in dump_bags entry #'..tostring(v)..' in the ../addons/organizer/data/settings.xml file is not valid.\nValid options are '..tostring(res.bags))
            return
        end
    end
    return dump_bags
end

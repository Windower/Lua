--Copyright © 2016-2017, Brimstone
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of closetCleaner nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL Brimstone BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-- _addon.version = '1.0'

local cc = {}
config = require ('config')
cc.sandbox = {}
cc.sandbox.windower = setmetatable({}, {__index = windower})
cc.sandbox.windower.coroutine = functions.empty
cc.sandbox.windower.register_event = functions.empty
cc.sandbox.windower.raw_register_event = functions.empty
cc.sandbox.windower.register_unhandled_command = functions.empty

defaults = T{}
-- Jobs you want to execute with, recomment put all active jobs you have lua for will look for <job>.lua or <playername>_<job>.lua files
defaults.ccjobs = { 'BLM', 'BLU', 'BRD', 'BST', 'COR', 'DNC', 'DRG', 'DRK', 'GEO', 'MNK', 'NIN', 'PLD', 'PUP', 'RDM', 'RNG', 'RUN', 'SAM', 'SCH', 'SMN', 'THF', 'WAR', 'WHM' }
-- Put any items in your inventory here you don't want to show up in the final report
-- recommended for furniture, food, meds, pop items or any gear you know you want to keep for some reason
-- use * for anything. 
defaults.ccignore = S{ "Rem's Tale*", "Storage Slip *" }
-- Set to nil or delete for unlimited
defaults.ccmaxuse = nil
-- List bags you want to not check against, needs to match "Location" column in <player>_report.txt
defaults.ccskipBags = S{ 'Storage', 'Temporary' }
-- this prints out the _sets _ignored and _inventory files
ccDebug = false

settings = config.load('ccConfig.xml',defaults)

register_unhandled_command(function(command)
    command = command and command:lower() or nil
    if command ~= 'cc' and command ~= 'closetcleaner' then
        return
    end        
    setmetatable(cc.sandbox, {__index = gearswap.user_env})
    cc.sandbox.itemsBylongName = T{}
    cc.sandbox.itemsByName = T{}
    cc.sandbox.inventoryGear = T{}
    cc.sandbox.gsGear = T{}
    for k,v in pairs(gearswap.res.items) do
        cc.sandbox.itemsBylongName[gearswap.res.items[k].name_log:lower()] = k
        cc.sandbox.itemsByName[gearswap.res.items[k].name:lower()] = k
    end
    cc.sandbox.jobs = {}
    for k,v in pairs(gearswap.res.jobs) do
        cc.sandbox.jobs[gearswap.res.jobs[k].english_short] = k
    end
    if not windower.dir_exists(windower.addon_path..'report') then
        windower.create_dir(windower.addon_path..'report')
    end
    local path = windower.addon_path:gsub('\\','/')
    path = path..'report/'..player.name
    cc.run_report(path)
    cc.sandbox = {}
    cc.sandbox.windower = setmetatable({}, {__index = windower})
    cc.sandbox.windower.register_event = functions.empty
    cc.sandbox.windower.raw_register_event = functions.empty
    cc.sandbox.windower.register_unhandled_command = functions.empty
    return true
end)

-- This function creates the report and generates the calls to the other functions
function cc.run_report(path)
    mainReportName = path..'_report.txt'
    local f = io.open(mainReportName,'w+')
    f:write('closetCleaner Report:\n')
    f:write('=====================\n\n')
    cc.export_inv(path)
    cc.export_sets(path)
    for k,v in pairs(cc.sandbox.inventoryGear) do
        if cc.sandbox.gsGear[k] == nil then
            cc.sandbox.gsGear[k] = 0
        end
    end
    data = T{"Name", " | ", "Count", " | ", "Location", " | ", "Jobs Used", " | ", "Long Name"}
    form = T{"%25s", "%3s", "%10s", "%3s", "%20s", "%3s", "%-88s", "%3s", "%60s"}
    cc.print_row(f, data, form)
    cc.print_break(f, form)
    if ccDebug then
        ignoredReportName = path..'_ignored.txt'
        f2 = io.open(ignoredReportName,'w+')
        f2:write('closetCleaner ignored Report:\n')
        f2:write('=====================\n\n')
        cc.print_row(f2, data, form)
        cc.print_break(f2, form)
    end
    for k,v in cc.spairs(cc.sandbox.gsGear, function(t,a,b) return t[b] > t[a] end) do
        if settings.ccmaxuse == nil or v <= settings.ccmaxuse then
            printthis = 1
            if not cc.job_used[k] then
                cc.job_used[k] = " "
            end
            for s in pairs(settings.ccignore) do
                if windower.wc_match(gearswap.res.items[k].english, s) then
                    printthis = nil
                    if cc.sandbox.inventoryGear[k] == nil then
                        data = T{gearswap.res.items[k].english, " | ", tostring(v), " | ", "NOT FOUND", " | ", cc.job_used[k], " | ", gearswap.res.items[k].english_log}
                    else
                        data = T{gearswap.res.items[k].english, " | ", tostring(v), " | ", cc.sandbox.inventoryGear[k], " | ", cc.job_used[k], " | ", gearswap.res.items[k].english_log}
                    end
                    if ccDebug then
                        cc.print_row(f2, data, form)
                    end
                    break
                end 
            end
            if printthis then
                if cc.sandbox.inventoryGear[k] == nil then
                    data = T{gearswap.res.items[k].english, " | ", tostring(v), " | ", "NOT FOUND", " | ", cc.job_used[k], " | ", gearswap.res.items[k].english_log}
                else
                    data = T{gearswap.res.items[k].english, " | ", tostring(v), " | ", cc.sandbox.inventoryGear[k], " | ", cc.job_used[k], " | ", gearswap.res.items[k].english_log}
                end
                cc.print_row(f, data, form)
            end
        end
    end
    if ccDebug then
        f2:close()
        print("File created: "..ignoredReportName)
    end
    f:close()
    print("File created: "..mainReportName)
end

 -- This function tallies all the gear in your inventory 
function cc.export_inv(path)
    if ccDebug then
        reportName = path..'_inventory.txt'
        finv = io.open(reportName,'w+')
        finv:write('closetCleaner Inventory Report:\n')
        finv:write('=====================\n\n')
    end
        
    local item_list = T{}
    checkbag = true 
    for n = 0, #gearswap.res.bags do
        if not settings.ccskipBags:contains(gearswap.res.bags[n].english) then
            for i,v in ipairs(gearswap.get_item_list(gearswap.items[gearswap.res.bags[n].english:gsub(' ', ''):lower()])) do
                if v.name ~= empty then
                    local slot = gearswap.xmlify(tostring(v.slot))
                    local name = gearswap.xmlify(tostring(v.name)):gsub('NUM1','1')
                    
                    if cc.sandbox.itemsByName[name:lower()] ~= nil then
                        itemid = cc.sandbox.itemsByName[name:lower()]
                    elseif cc.sandbox.itemsBylongName[name:lower()] ~= nil then
                        itemid = cc.sandbox.itemsBylongName[name:lower()]
                    else
                        print("Item: "..name.." not found in gearswap.resources!")
                    end
                    if ccDebug then
                        finv:write("Name: "..name.." Slot: "..slot.." Bag: "..gearswap.res.bags[n].english.."\n")
                    end
                    if cc.sandbox.inventoryGear[itemid] == nil then 
                        cc.sandbox.inventoryGear[itemid] = gearswap.res.bags[n].english
                    else
                        cc.sandbox.inventoryGear[itemid] = cc.sandbox.inventoryGear[itemid]..", "..gearswap.res.bags[n].english
                    end
                end
            end
        end
    end
    if ccDebug then
        finv:close()
        print("File created: "..reportName)
    end
end

-- loads all the relevant jobs.lua files and inserts the sets tables into a supersets table:
-- supersets.<JOB>.sets....
function cc.export_sets(path)
    if ccDebug then
        reportName = path..'_sets.txt'
        fsets = io.open(reportName,'w+')
        fsets:write('closetCleaner sets Report:\n')
        fsets:write('=====================\n\n')
    end
    cc.supersets = {}
    cc.job_used = T{}
    cc.job_logged = T()
    fpath = windower.addon_path:gsub('\\','/')
    fpath = fpath:gsub('//','/')
    fpath = string.lower(fpath)
    dpath = fpath..'data/'
    for i,v in ipairs(settings.ccjobs) do
        dname = string.lower(dpath..player.name..'/'..v..'.lua')
        lname = string.lower(dpath..player.name..'_'..v..'.lua')
        lgname = string.lower(dpath..player.name..'_'..v..'_gear.lua')
        sname = string.lower(dpath..v..'.lua')
        sgname = string.lower(dpath..v..'_gear.lua')
        if windower.file_exists(lgname) then
            cc.supersets[v] = cc.extract_sets(lgname)
        elseif windower.file_exists(lname) then
            cc.supersets[v] = cc.extract_sets(lname)
        elseif windower.file_exists(sgname) then
            cc.supersets[v] = cc.extract_sets(sgname)
        elseif windower.file_exists(sname) then
            cc.supersets[v] = cc.extract_sets(sname)
        elseif windower.file_exists(dname) then
            cc.supersets[v] = cc.extract_sets(dname)
        else
           print('lua file for '..v..' not found!')
        end
    end
    cc.list_sets(cc.supersets, fsets) 
    cc.supersets = nil
    if ccDebug then
        fsets:close()
        print("File created: "..reportName)
    end
end

-- sets the 'sets' and puts them into supersets based off file name. 
function cc.extract_sets(file) 
    local user_file = gearswap.loadfile(file)
    if user_file then 
        gearswap.setfenv(user_file, cc.sandbox) 
        cc.sandbox.sets = {}
        user_file() 
        local def_gear = cc.sandbox.init_get_sets or cc.sandbox.get_sets
        if def_gear then 
            def_gear() 
        end
        return table.copy(cc.sandbox.sets)
    else    
        print('lua file for '..file..' not found!')
    end 
end

-- this function tallies the items used in each lua file
function cc.list_sets(t, f)  
    write_sets = T{}
    local print_r_cache={}
    local function sub_print_r(t,fromTab)
        if (type(t)=="table") then
            for pos,val in pairs(t) do
                if S{"WAR", "MNK", "WHM", "BLM", "RDM", "THF", "PLD", "DRK", "BST", "BRD", "RNG", "SAM", "NIN", "DRG", "SMN", "BLU", "COR", "PUP", "DNC", "SCH", "GEO", "RUN"}:contains(pos) then
                    job = pos
                end
                if (type(val)=="table") then
                    sub_print_r(val,job)
                elseif (type(val)=="string") then
                    if val ~= "" and val ~= "empty" then 
                        if S{"name", "main", "sub", "range", "ammo", "head", "neck", "left_ear", "right_ear", "body", "hands", "left_ring", "right_ring", "back", "waist", "legs", "feet", "ear1", "ear2", "ring1", "ring2", "lear", "rear", "lring", "rring"}:contains(pos) then
                            if cc.sandbox.itemsByName[val:lower()] ~= nil then
                                itemid = cc.sandbox.itemsByName[val:lower()]
                            elseif cc.sandbox.itemsBylongName[val:lower()] ~= nil then
                                itemid = cc.sandbox.itemsBylongName[val:lower()]
                            else
                                print("Item: '"..val.."' not found in gearswap.resources! "..pos)
                            end
                            if ccDebug then
                                f:write('Processing '..job..' name for val '..val..' id '..itemid..'\n')
                            end
                            if write_sets[itemid] == nil then
                                write_sets[itemid] = 1
                                if cc.job_used[itemid] == nil then
                                    cc.job_used[itemid] = job
                                    cc.job_logged[itemid..job] = 1
                                else
                                    cc.job_used[itemid] = cc.job_used[itemid]..","..job
                                    cc.job_logged[itemid..job] = 1
                                end
                            else    
                                write_sets[itemid] = write_sets[itemid] + 1
                                if cc.job_logged[itemid..job] == nil then
                                    cc.job_used[itemid] = cc.job_used[itemid]..","..job
                                    cc.job_logged[itemid..job] = 1
                                end
                            end
                        end
                    end
                elseif (type(val)=="number") then
                    print("Found Number: "..val.." from "..pos.." table "..t)
                else
                    print("Error: Val needs to be table or string "..type(val))
                end
            end
        end
    end
    sub_print_r(t,nil)
    if ccDebug then
        data = T{"Name", " | ", "Count", " | ", "Jobs", " | ", "Long Name"}
        form = T{"%22s", "%3s", "%10s", "%3s", "%88s", "%3s", "%60s"}
        cc.print_row(f, data, form)
        cc.print_break(f, form)
        f:write('\n')
        for k,v in pairs(write_sets) do
            data = T{gearswap.res.items[k].english, " | ", tostring(v), " | ", cc.job_used[k], " | ", gearswap.res.items[k].english_log}
            cc.print_row(f, data, form)
            cc.sandbox.gsGear[k] = v
        end
        f:write()
    else
        for k,v in pairs(write_sets) do
            cc.sandbox.gsGear[k] = v
        end
    end
end

-- interate throught table in a sorted order.
function cc.spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-- pass in file handle and a table of formats and table of data
function cc.print_row(f, data, form)
    for k,v in pairs(data) do
        f:write(string.format(form[k], v))
    end
    f:write('\n')
end

-- pass in file handle and a table of formats and table of data
function cc.print_break(f, form)
    for k,v in pairs(form) do
        number = string.match(v,"%d+")
        for i=1,number do
            f:write('-')
        end
        -- f:write(' ') -- can add characters to end here like spaces but subtract from number in the for loop above
    end
    f:write('\n')
end


function cc.include(str)
    str = str:lower()
    if not (str == 'closetcleaner' or str == 'closetcleaner.lua') then
        include(str, cc.sandbox)
    end
end

cc.sandbox.include = cc.include
cc.sandbox.require = cc.include
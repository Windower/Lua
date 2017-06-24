--Copyright (c) 2016~2017, Brimstone
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

_addon.name = 'closetCleaner'
_addon.version = '0.7'
_addon.author = 'Brimstone'
_addon.commands = {'cc','closetCleaner'}

if windower.file_exists(windower.addon_path..'data/bootstrap.lua') then
    debugging = {windower_debug = true,command_registry = false,general=false,logging=false}
else
    debugging = {}
end

__raw = {lower = string.lower, upper = string.upper, debug=windower.debug,text={create=windower.text.create,
    delete=windower.text.delete,registry = {}},prim={create=windower.prim.create,delete=windower.prim.delete,registry={}}}


language = 'english'
file = require 'files'
require 'strings'
require 'tables'
require 'logger'
-- Restore the normal error function (logger changes it)
error = _raw.error

require 'lists'
require 'sets'


windower.text.create = function (str)
    if __raw.text.registry[str] then
        msg.addon_msg(123,'Text object cannot be created because it already exists.')
    else
        __raw.text.registry[str] = true
        __raw.text.create(str)
    end
end

windower.text.delete = function (str)
    if __raw.text.registry[str] then
        local library = false
        if windower.text.saved_texts then
            for i,v in pairs(windower.text.saved_texts) do
                if v._name == str then
                    __raw.text.registry[str] = nil
                    windower.text.saved_texts[i]:destroy()
                    library = true
                    break
                end
            end
        end
        if not library then
            -- Text was not created through the library, so delete it normally
            __raw.text.registry[str] = nil
            __raw.text.delete(str)
        end
    else
        __raw.text.delete(str)
    end
end

windower.prim.create = function (str)
    if __raw.prim.registry[str] then
        msg.addon_msg(123,'Primitive cannot be created because it already exists.')
    else
        __raw.prim.registry[str] = true
        __raw.prim.create(str)
    end
end

windower.prim.delete = function (str)
    if __raw.prim.registry[str] then
        __raw.prim.registry[str] = nil
        __raw.prim.delete(str)
    else
        __raw.prim.delete(str)
    end
end

texts = require 'texts'
require 'pack'
bit = require 'bit'
socket = require 'socket'
mime = require 'mime'
res = require 'resources'
extdata = require 'extdata'
require 'helper_functions'
require 'actions'
packets = require 'packets'
gearswap = {}
user_env = {}
-- Resources Checks
if res.items and res.bags and res.slots and res.statuses and res.jobs and res.elements and res.skills and res.buffs and res.spells and res.job_abilities and res.weapon_skills and res.monster_abilities and res.action_messages and res.skills and res.monstrosity and res.weather and res.moon_phases and res.races then
else
    error('Missing resources!')
end

require 'packet_parsing'
require 'statics'
require 'equip_processing'
require 'targets'
require 'user_functions'
require 'refresh'
require 'export'
require 'validate'
require 'flow'
require 'triggers'

-- initialize_packet_parsing()
gearswap_disabled = false

windower.register_event('load',function()
    windower.debug('load')
    refresh_globals()
    
    if world.logged_in then
        refresh_user_env()
        if debugging.general then windower.send_command('@unload spellcast;') end
    end
end)

windower.register_event('unload',function ()
    windower.debug('unload')
    user_pcall('file_unload')
    if logging then logfile:close() end
end)

function table_invert(t)
	local s={}
	for k,v in pairs(t) do	
		s[v]=k
	end
	return s
end

windower.register_event('addon command',function (...)
    windower.debug('addon command')
    local splitup = {...}
    if not splitup[1] then return end -- handles //cu
    
    for i,v in pairs(splitup) do splitup[i] = windower.from_shift_jis(windower.convert_auto_trans(v)) end

    local cmd = table.remove(splitup,1):lower()
	
	-- create file
	if not windower.dir_exists(windower.addon_path..'report') then
        windower.create_dir(windower.addon_path..'report')
    end
	local path = windower.addon_path..'report/'..player.name
    -- path = path..os.date(' %H %M %S%p  %y-%d-%m')
	-- if (not overwrite_existing) and windower.file_exists(path..'.lua') then
		-- path = path..' '..os.clock()
	-- end
	
	itemsBylongName = T{}
	itemsByName = T{}
	inventoryGear = T{}
	gsGear = T{}
	for k,v in pairs(res.items) do
		itemsBylongName[res.items[k].enl:lower()] = k
		itemsByName[res.items[k].en:lower()] = k
	end
    
	-- require 'ccConfig'
    if cmd == 'report' then
		require 'ccConfig'
        run_report(path)
    elseif strip(cmd) == 'help' then
        print('closetCleaner: Valid commands are:')
        print(' report  : Generates full usage report closetCleaner/report/<playername>_report.txt.')
    else
		print('checkusage: Command not found')
    end
end)

function export_inv(path)
	if ccDebug then
		reportName = path..'_inventory.txt'
		finv = io.open(reportName,'w+')
		finv:write('closetCleaner Inventory Report:\n')
		finv:write('=====================\n\n')
	end
		
	local item_list = T{}
	checkbag = true 
	for n = 0, #res.bags do
		if not skipBags:contains(res.bags[n].english) then
			for i,v in ipairs(get_item_list(items[res.bags[n].english:gsub(' ', ''):lower()])) do
				if v.name ~= empty then
					local slot = xmlify(tostring(v.slot))
					local name = xmlify(tostring(v.name)):gsub('NUM1','1')
					
					if itemsByName[name:lower()] ~= nil then
						itemid = itemsByName[name:lower()]
					elseif itemsBylongName[name:lower()] ~= nil then
						itemid = itemsBylongName[name:lower()]
					else
						print("Item: "..name.." not found in resources!")
					end
					if ccDebug then
						finv:write("Name: "..name.." Slot: "..slot.." Bag: "..res.bags[n].english.."\n")
					end
					if inventoryGear[itemid] == nil then 
						inventoryGear[itemid] = res.bags[n].english
					else
						inventoryGear[itemid] = inventoryGear[itemid]..", "..res.bags[n].english
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

-- Dummy include function, ignore some search known paths for others
function include(f)
	-- No need to do anything with this
	if f == 'organizer-lib.lua' then
		return
	end
	if windower.file_exists(f) then
		dofile(f)
		return
	end
	if windower.file_exists(gspath..f) then
		dofile(gspath..f)
		return
	end
	mf = gearswap.pathsearch({f})
	if mf then
		if windower.file_exists(mf) then
			dofile(mf)
			return
		end
	end
	libsFiles = { "Modes", "Mote-Include.lua", "Mote-TreasureHunter", "Mote-Mappings", "Mote-Utility", "Mote-Globals", "Mote-SelfCommands"}
	for i,s in ipairs(libsFiles) do
		if s == f then
			incFile = gspath.."libs/"..f
			if windower.file_exists(incFile) then
				dofile(incFile)
			else
				dofile(incFile..".lua")
			end
			return
		end
	end
end

-- sets the 'sets' and puts them into supersets based off file name. 
function extract_sets(file) 
	dofile(file)
	if get_sets ~= nil then
		get_sets()
	elseif init_gear_sets ~= nil then
		init_gear_sets()
	else
		print('ERROR: init_gear_sets() or get_sets() not found!')
	end
	return deepcopy(sets)
end

function export_sets(path)
	if ccDebug then
		reportName = path..'_sets.txt'
		fsets = io.open(reportName,'w+')
		fsets:write('closetCleaner sets Report:\n')
		fsets:write('=====================\n\n')
	end
		
	supersets = {}
	job_used = T{}
	job_logged = T()
	info = {}
	gear = {}
	gearswap.res = res
	
	fpath = windower.addon_path:gsub('\\','/')
	fpath = fpath:gsub('//','/')
	fpath = string.lower(fpath)
	gspath = fpath:gsub('closetcleaner\/','')..'gearswap/'
	dpath = gspath..'data/'
	for i,v in ipairs(ccjobs) do
		sets = {}
		dname = string.lower(dpath..player.name..'/'..v..'.lua')
		lname = string.lower(dpath..player.name..'_'..v..'.lua')
		lgname = string.lower(dpath..player.name..'_'..v..'_gear.lua')
		sname = string.lower(dpath..v..'.lua')
		sgname = string.lower(dpath..v..'_gear.lua')
		if windower.file_exists(lgname) then
			supersets[v] = extract_sets(lgname)
		elseif windower.file_exists(lname) then
			supersets[v] = extract_sets(lname)
		elseif windower.file_exists(sgname) then
			supersets[v] = extract_sets(sgname)
		elseif windower.file_exists(sname) then
			supersets[v] = extract_sets(sname)
		elseif windower.file_exists(dname) then
			supersets[v] = extract_sets(dname)
		else
		   print('lua file for '..v..' not found!')
		end
	end
	
	list_sets( supersets , fsets ) 
	if ccDebug then
		fsets:close()
		print("File created: "..reportName)
	end
end

function list_sets ( t, f )  
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
							if itemsByName[val:lower()] ~= nil then
								itemid = itemsByName[val:lower()]
							elseif itemsBylongName[val:lower()] ~= nil then
								itemid = itemsBylongName[val:lower()]
							else
								print("Item: '"..val.."' not found in resources! "..pos)
							end
							if write_sets[itemid] == nil then
								write_sets[itemid] = 1
								if job_used[itemid] == nil then
									job_used[itemid] = job
									job_logged[itemid..job] = 1
								else
									job_used[itemid] = job_used[itemid]..","..job
									job_logged[itemid..job] = 1
								end
							else	
								write_sets[itemid] = write_sets[itemid] + 1
								if job_logged[itemid..job] == nil then
									job_used[itemid] = job_used[itemid]..","..job
									job_logged[itemid..job] = 1
								end
							end
						end
					end
				else
					print("Error: Val needs to be table or string")
				end
			end
		end
    end
    sub_print_r(t,nil)
	if ccDebug then
		data = T{"Name", " | ", "Count", " | ", "Jobs", " | ", "Long Name"}
		form = T{"%22s", "%3s", "%10s", "%3s", "%88s", "%3s", "%60s"}
		print_row(f, data, form)
		print_break(f, form)
		f:write('\n')
		for k,v in pairs(write_sets) do
			data = T{res.items[k].en, " | ", tostring(v), " | ", job_used[k], " | ", res.items[k].enl}
			print_row(f, data, form)
			gsGear[k] = v
		end
		f:write()
	else
		for k,v in pairs(write_sets) do
			gsGear[k] = v
		end
	end
end

-- pass in file handle and a table of formats and table of data
function print_row(f, data, form)
	for k,v in pairs(data) do
		f:write(string.format(form[k], v))
	end
	f:write('\n')
end

-- pass in file handle and a table of formats and table of data
function print_break(f, form)
	for k,v in pairs(form) do
		number = string.match(v,"%d+")
		for i=1,number do
			f:write('-')
		end
		-- f:write(' ') -- can add characters to end here like spaces but subtract from number in the for loop above
	end
	f:write('\n')
end

function run_report(path)
	mainReportName = path..'_report.txt'
	local f = io.open(mainReportName,'w+')
	f:write('closetCleaner Report:\n')
	f:write('=====================\n\n')
	export_inv(path)
	export_sets(path)
	for k,v in pairs(inventoryGear) do
		if gsGear[k] == nil then
			gsGear[k] = 0
		end
	end
	data = T{"Name", " | ", "Count", " | ", "Location", " | ", "Jobs Used", " | ", "Long Name"}
	form = T{"%25s", "%3s", "%10s", "%3s", "%20s", "%3s", "%-88s", "%3s", "%60s"}
	print_row(f, data, form)
	print_break(f, form)
	if ccDebug then
		ignoredReportName = path..'_ignored.txt'
		f2 = io.open(ignoredReportName,'w+')
		f2:write('closetCleaner ignored Report:\n')
		f2:write('=====================\n\n')
		print_row(f2, data, form)
		print_break(f2, form)
	end
	for k,v in spairs(gsGear, function(t,a,b) return t[b] > t[a] end) do
		if ccmaxuse == nil or v <= ccmaxuse then
			printthis = 1
			if not job_used[k] then
				job_used[k] = " "
			end
			for i,s in ipairs(ccignore) do
				if string.match(res.items[k].en, s) or string.match(res.items[k].en, s) then
					printthis = nil
					if inventoryGear[k] == nil then
						data = T{res.items[k].en, " | ", tostring(v), " | ", "NOT FOUND", " | ", job_used[k], " | ", res.items[k].enl}
					else
						data = T{res.items[k].en, " | ", tostring(v), " | ", inventoryGear[k], " | ", job_used[k], " | ", res.items[k].enl}
					end
					if ccDebug then
						print_row(f2, data, form)
					end
					break
				end 
			end
			if printthis then
				if inventoryGear[k] == nil then
					data = T{res.items[k].en, " | ", tostring(v), " | ", "NOT FOUND", " | ", job_used[k], " | ", res.items[k].enl}
				else
					data = T{res.items[k].en, " | ", tostring(v), " | ", inventoryGear[k], " | ", job_used[k], " | ", res.items[k].enl}
				end
				print_row(f, data, form)
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

function spairs(t, order)
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

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function gearswap.pathsearch(files_list)

    -- base directory search order:
    -- windower
    -- %appdata%/Windower/GearSwap
    
    -- sub directory search order:
    -- libs-dev (only in windower addon path)
    -- libs (only in windower addon path)
    -- data/player.name
    -- data/common
    -- data
    
    local gearswap_data = gspath .. 'data/'
    local gearswap_appdata = (os.getenv('APPDATA') or '') .. '/Windower/GearSwap/'

    local search_path = {
        [1] = gspath .. 'libs-dev/',
        [2] = gspath .. 'libs/',
        [3] = gearswap_data .. player.name .. '/',
        [4] = gearswap_data .. 'common/',
        [5] = gearswap_data,
        [6] = gearswap_appdata .. player.name .. '/',
        [7] = gearswap_appdata .. 'common/',
        [8] = gearswap_appdata,
        [9] = windower.windower_path .. 'addons/libs/'
    }
    
    local user_path
    local normal_path

    for _,basepath in ipairs(search_path) do
        if windower.dir_exists(basepath) then
            for i,v in ipairs(files_list) do
                if v ~= '' then
                    if include_user_path then
                        user_path = basepath .. include_user_path .. '/' .. v
                    end
                    normal_path = basepath .. v
                    
                    if user_path and windower.file_exists(user_path) then
                        return user_path,basepath,v
                    elseif normal_path and windower.file_exists(normal_path) then
                        return normal_path,basepath,v
                    end
                end
            end
        end
    end
    
    return false
end

-- this function looks recursively through tables for a piece of gear  (currently unused)
function has_gear(tab, val)
	for index, value in pairs(tab) do
		if (type(value)=="table") then
			depth = depth + 1
			if has_gear(value, val, f) then
				return true
			end
		elseif value == val then
			return true
		end
	end
	return false
end


--dummy functions
function send_command(c)
	windower.send_command(c)
end

function windower.register_event(c)
	return
end

function windower.raw_register_event(c)
	return
end
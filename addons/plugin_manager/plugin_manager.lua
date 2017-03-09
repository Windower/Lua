--Copyright (c) 2013-2014, Byrthnoth
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


file = require 'files'
require 'tables'
xml = require 'xml'


_addon.version = '1.0'
_addon.author = 'Byrth'
_addon.name = 'plugin_manager'
_addon.commands = {}

windower.register_event('addon command',function(...)
	local cmd = {...}
	if cmd[1] == 'load' then
		load_plugins(cmd[2])
	elseif cmd[1] == 'unload' then
		unload_plugins(cmd[2])
	end
end)

windower.register_event('load',function()
	loader_array = {} -- Expansion of the settings file
	general_array = {} -- List of every addon/plugin that gets loaded. true = loaded sometimes. false = loaded all the time. nil = blocked or not used.
	general_array['addon'] = {}
	general_array['plugin'] = {}
	load_command = {plugin='load ',addon='lua l '}
	unload_command = {plugin='unload ',addon='lua u '}
	load_settings()
	
	-- Iterate over the list of plugins/addons and determine which ones are loaded by all profiles
	-- Load those plugins once and set them to "false" in the general_array
	local firstrun,length = '@',0
	for i,v in pairs(loader_array) do
		length = length + 1
	end
	for q,r in pairs(general_array) do
		for n,m in pairs(r) do
			local counter = 0
			if m == true then
				for i,v in pairs(loader_array) do
					if v[q]:contains(n) then
						counter = counter + 1
					end
				end
				if counter == length then
					firstrun = firstrun..load_command[q]..n..';'
					general_array[q][n] = false
				end
			end
		end
	end
	
	windower.send_command(firstrun)
	if windower.ffxi.get_player() then
        coroutine.sleep(3) -- Wait for firstrun to finish
        unload_plugins()
        coroutine.sleep(3) -- Wait for the unload command spam to finish
        load_plugins()
	end
end)

function load_settings()
	if not file.exists('data/settings.xml') then
		error('plugin_manager: settings.xml is missing.')
	else
		-- Iterate over the settings file and simply it, as well as creating a list of all plugins
		local settingtab = xml.read('data/settings.xml')
        if settingtab then
            settingtab = settingtab:undomify()
        else
            error('plugin_manager: settings.xml has an error in it. Try using an XML validator.')
            return
        end
		for child in settingtab.children:it() do
		-- Global/Names layer
			loader_array[child.name:lower()] = {}
			loader_array[child.name:lower()]['addon'] = T{}
			loader_array[child.name:lower()]['plugin'] = T{}
			for child2 in child.children:it() do
				if child2.name:lower() == 'addon' or child2.name:lower() == 'plugin' then
				-- Addon/Plugin layer <name>children[1]</name>
					loader_array[child.name:lower()][child2.name:lower()][#loader_array[child.name:lower()][child2.name:lower()]+1] = child2.children[1]:lower()
					general_array[child2.name:lower()][child2.children[1]:lower()] = true
				end
			end
		end
		
		-- Iterate over the blacklist and set blocked plugins to nil.
		local blacklisttab = xml.read('../../updates/manifest.xml')
        if not blacklisttab then
            windower.add_to_chat(123,'Plugin_Manager: Cannot read windower/updates/manifest.xml, so plugin blacklist is broken')
        else
            blacklisttab = blacklisttab:undomify()
            for child in blacklisttab:it() do -- plugins
                for child2 in child:it() do -- plugin
                    local blockload,name = false
                    for child3 in child2:it() do --name, autoload, description, etc.
                        if child3.name == 'autoload' and child3.children[1] == 'false' then
                            blockload = true
                        end
                        if child3.name:lower() == 'name' then
                            name = child3.children[1]:lower()
                        end
                        if blockload and name then
                            general_array.plugin[name:lower()] = nil
                        end
                    end
                end
            end
        end
        
		local blacklistadd = xml.read('../../updates/addons.xml')
        if not blacklistadd then
            windower.add_to_chat(123,'Plugin_Manager: Cannot read windower/updates/addons.xml, so addon blacklist is broken')
        else
            blacklistadd = blacklistadd:undomify()
            for child in blacklistadd:it() do -- plugins
                local blockload,name = false
                for child2 in child:it() do --name, autoload, description, etc.
                    if child2.name == 'autoload' and child2.children[1] == 'false' then
                        blockload = true
                    end
                    if child2.name:lower() == 'name' then
                        name = child2.children[1]:lower()
                    end
                    if blockload and name then
                        general_array.addon[name:lower()] = nil
                    end
                end
            end
        end
	end
end

function load_plugins(name)
    name = make_name(name)
	local working_array,commandstr = {},'@'
	
	for q,r in pairs(general_array) do
		for i,v in pairs(loader_array[name][q]) do
			if general_array[q][v] then
				commandstr = commandstr..load_command[q]..v..';'
			end
		end
	end
	windower.send_command(commandstr)
end

function unload_plugins(name)
    name = make_name(name)
	local commandstr = ''
	for i,v in pairs(loader_array[name]) do
		for n,m in pairs(v) do
			if general_array[i][m] then
				commandstr = commandstr..unload_command[i]..m..';'
			end
		end
	end
	windower.send_command(commandstr)
end

windower.register_event('login',function(name)
    coroutine.sleep(3)
    load_plugins(name)
end)

windower.register_event('logout',function(name)
	unload_plugins(name)
end)

function make_name(name)
	if name then
		name = name:lower()
	elseif windower.ffxi.get_player() then
		name = windower.ffxi.get_player().name:lower()
	end
	
	if name == nil or name == '' or not loader_array[name] then
		name = 'global'
	end
	return name or 'global'
end

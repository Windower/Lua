--Copyright (c) 2013, Byrthnoth
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


file = require 'filehelper'
require 'tablehelper'
xml = require 'xml'


function event_addon_command(...)
	local cmd = table.concat({...},' ')
	if cmd == 'load' then
		load_plugins()
	end
end

function event_load()
	loader_array = {}
	general_array = {}
	general_array['addon'] = {}
	general_array['plugin'] = {}
	load_settings()
	unload_plugins()
	send_command('wait 5;lua c plugin_manager load')
end

function load_settings()
	--local settingsFile = file.new('data/settings.xml',true)
	if not file.exists('data/settings.xml') then
		write('plugin_manager is missing its settings file.')
	else
		local settingtab = xml.read('data/settings.xml'):undomify()
		for child in settingtab:it() do
		-- Global/Names layer
			loader_array[child.name] = {}
			loader_array[child.name]['addon'] = T{}
			loader_array[child.name]['plugin'] = T{}
			for child2 in child:it() do
				if child2.name == 'addon' or child2.name == 'plugin' then
				-- Addon/Plugin layer <name>children[1]</name>
					loader_array[child.name][child2.name][#loader_array[child.name][child2.name]+1] = child2.children[1]:lower()
					if not general_array[child2.name][child2.children[1]:lower()] then
						general_array[child2.name][child2.children[1]:lower()] = true
					end
				end
			end
		end
		
		local blacklisttab = xml.read('../../updates/manifest.xml'):undomify()
		for child in blacklisttab:it() do -- plugins
			for child2 in child:it() do -- plugin
				local blockload,name
				for child3 in child2:it() do --name, autoload, description, etc.
					if child3.name == 'autoload' then
						if child3.children[1] == 'false' then
							blockload = true
						end
					end
					if child3.name == 'name' then
						name = child3.children[1]
					end
				end
				if blockload then
					general_array['plugin'][name:lower()] = false
				end
			end
		end
	end
end

function load_plugins()
	local working_array,commandstr = {},'wait 5;'
	if loader_array[get_player().name] then
		working_array = loader_array[get_player().name]
	else
		working_array = loader_array['global']
	end
	
	for i,v in pairs(working_array['plugin']) do
		if general_array['plugin'][v] then
			commandstr = commandstr..'load '..v..';wait 0.1;'
		end
	end
	for i,v in pairs(working_array['addon']) do
		commandstr = commandstr..'lua l '..v..';wait 0.1;'
	end
	send_command(commandstr)
end

function unload_plugins()
	local commandstr = ''
	for i,v in pairs(general_array['plugin']) do
		local sendit = false
		for n,m in pairs(loader_array) do
			if m['plugin']:contains(i) and v then
				sendit = true
			end
		end
		if sendit then commandstr = commandstr..'unload '..i..';wait 0.1;' end
	end
	for i,v in pairs(general_array['addon']) do
		local sendit = false
		for n,m in pairs(loader_array) do
			if m['addon']:contains(i) then
				sendit = true
			end
		end
		if sendit then commandstr = commandstr..'lua u '..i..';wait 0.1;' end
	end
	send_command(commandstr)
end

function event_login(name)
	load_plugins()
end

function event_logout(name)
	unload_plugins()
end
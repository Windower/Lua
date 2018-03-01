--[[
	Copyright (c) 2018, Karuberu
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

	    * Redistributions of source code must retain the above copyright
	      notice, this list of conditions and the following disclaimer.
	    * Redistributions in binary form must reproduce the above copyright
	      notice, this list of conditions and the following disclaimer in the
	      documentation and/or other materials provided with the distribution.
	    * Neither the name of Lookup nor the
	      names of its contributors may be used to endorse or promote products
	      derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY
	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
_addon.name = 'Lookup'
_addon.author = 'Karuberu'
_addon.version = '1.0'
_addon.language = 'english'
_addon.command = 'lookup'

config = require('config')
res = require('resources')

settings = nil
ids = nil
last_item = nil

function initialize()
	load_settings()
	initialize_ids()
end

function load_settings()
	settings = config.load({
		default = 'ffxiclopedia';
		url = {
			ffxiclopedia = 'http://ffxiclopedia.wikia.com/wiki/Special:Search?go=Go&search=%s';
			bgwiki = 'https://www.bg-wiki.com/bg/Special:Search?go=Go&search=%s';
			ffxidb = {
				item = 'http://www.ffxidb.com/items/%s';
				zone = 'http://www.ffxidb.com/zones/%s';
				search = 'http://www.ffxidb.com/search?q=%s';
			};
			ffxiah = {
				item = 'http://www.ffxiah.com/item/%s';
				search = 'http://www.ffxiah.com/search/item?q=%s';
				player = 'https://www.ffxiah.com/search/player?name=%s';
			};
			google = 'https://www.google.com/search?q=%s';
		};
	})
end

function initialize_ids()
	ids = {
		items = {};
		zones = {};
	}
	for item in res.items:it() do
	    ids.items[item.name] = item.id
	    ids.items[item.name_log] = item.id
	end
	for zone in res.zones:it() do
			ids.zones[zone.name] = zone.id
	end
end

function find_id(name)
	return {
		item = ids.items[name];
		zone = ids.zones[name];
	}
end

function get_name(id, list)
	for key, value in next, list do
		if value == id then
			return key
		end
	end
	return nil
end

function translate(str)
	return windower.convert_auto_trans(str)
end

function get_selection(str)
	local target = str:match('<(.+)>')
	if target == 'job' then
		str = windower.ffxi.get_player().main_job_full
	elseif target == 'subjob' or target == 'sj' then
		str = windower.ffxi.get_player().sub_job_full
	elseif target == 'zone' or target == 'area' then
		if windower.ffxi.get_info().mog_house then
			str = 'Mog House'
		else
			str = get_name(windower.ffxi.get_info().zone, ids.zones)
		end
	elseif target == 'lastitem' or target == 'item' then
		str = get_name(last_item, ids.items)
	elseif target ~= nil then
		local mob = windower.ffxi.get_mob_by_target(str:match('<(.+)>'))
		if mob ~= nil then
			str = mob.name
		else
			str = nil
		end
	end
	return str
end

function set_default(term)
	settings.default = term
	config.save(settings, 'all')
end

function set_last_item(bag, index, id, count)
	if bag == 0 then
		last_item = id
	end
end

function process_command(command, term)
	if term == nil or term == '' then
		term = command
		command = settings.default
	else
		command = command:lower()
	end

	if command == 'default' then
		set_default(term)
		return
	end

	term = translate(term)
	term = get_selection(term)

	if term == nil or term == '' then
		return
	end

	local url
	local id = find_id(term)
	if command == 'ffxiclopedia' or command == 'ffxi' or command == 'wikia' then
		url = settings.url.ffxiclopedia:format(term)
	elseif command == 'bg' or command == 'bgwiki' or command == 'bg-wiki' then
		url = settings.url.bgwiki:format(term)
	elseif command == 'db' or command == 'ffxidb' then
		if id.item ~= nil then
			url = settings.url.ffxidb.item:format(id.item)
		elseif id.zone ~= nil then
			url = settings.url.ffxidb.zone:format(id.zone)
		else
			url = settings.url.ffxidb.search:format(term)
		end
	elseif command == 'ah' or command == 'ffxiah' then
		if id.item ~= nil then
			url = settings.url.ffxiah.item:format(id.item)
		else
			url = settings.url.ffxiah.search:format(term)
		end
	elseif command == 'ahp' or command == 'ffxiahp' or command == 'ffxiahplayer' then
		url = settings.url.ffxiah.player:format(term)
	elseif command == 'google' then
		url = settings.url.google:format(term)
	end

	if url ~= nil then
		windower.open_url(url)
	end
end

windower.register_event('load', initialize)
windower.register_event('add item', set_last_item)
windower.register_event('addon command', process_command)

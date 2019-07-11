--[[
    Copyright © 2018, Karuberu
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
_addon.commands = {'lookup', 'lu'}

config = require('config')
res = require('resources')

settings = nil
ids = nil
last_item = nil

function load_settings()
    settings = config.load({
        default = 'ffxiclopedia';
        sites = {
            ffxiclopedia = {
                search = 'https://ffxiclopedia.fandom.com/wiki/Special:Search?query=${term}';
            };
            ['bg-wiki'] = {
                search = 'https://www.bg-wiki.com/bg/Special:Search?go=Go&search=${term}';
            };
            ffxidb = {
                item = 'http://www.ffxidb.com/items/${term}';
                zone = 'http://www.ffxidb.com/zones/${term}';
                search = 'http://www.ffxidb.com/search?q=${term}';
            };
            ffxiah = {
                item = 'http://www.ffxiah.com/item/${term}';
                search = 'http://www.ffxiah.com/search/item?q=${term}';
            };
            ffxiahplayer = {
                search = 'https://www.ffxiah.com/search/player?name=${term}';
            };
            google = {
                search = 'https://www.google.com/search?q=${term}';
            };
            ffxi = { redirect = 'ffxiclopedia'; };
            wikia = { redirect = 'ffxiclopedia'; };
            bgwiki = { redirect = 'bg-wiki'; };
            bg = { redirect = 'bg-wiki'; };
            db = { redirect = 'ffxidb'; };
            ah = { redirect = 'ffxiah'; };
            ffxiahp = { redirect = 'ffxiahplayer'; };
            ahp = { redirect = 'ffxiahplayer'; };
        };
    })
end

-- Creates a list of item and zone ids by name for quicker lookup by name
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

function get_id(name)
    if id == nil then
        return {}
    end
    return {
        item = ids.items[name];
        zone = ids.zones[name];
    }
end

function get_name(id, list)
    if id == nil then
        return nil
    end
    return (list[id] or {}).name
end

-- Converts auto-translate strings to plain text.
-- If the string is not an auto-translate string, the original string is returned.
function translate(str)
    return windower.convert_auto_trans(str)
end

-- Checks to see if the string is a selector (enclosed by <>) and returns a replacement.
-- If the string is not a selector, the original string is returned.
function parse_selection(str)
    local target = str:match('<(.+)>')
    if target == nil then
        return str
    end

    -- custom selection handlers
    if target == 'job' or target == 'mjob' then
        return windower.ffxi.get_player().main_job_full
    elseif target == 'sjob' then
        return windower.ffxi.get_player().sub_job_full
    elseif target == 'zone' then
        if windower.ffxi.get_info().mog_house then
            return 'Mog House'
        else
            return get_name(windower.ffxi.get_info().zone, res.zones)
        end
    elseif target == 'item' then
        return get_name(last_item, res.items)
    end
    -- default to windower's selection handlers
    return (windower.ffxi.get_mob_by_target(str) or {}).name
end

function set_default_site(command_modifier, site)
    settings.default = site
    if command_modifier == 'player' or command_modifier == 'p' then
        -- save only for the current character
        settings:save()
    else
        -- save for all characters
        settings:save('all')
    end
end

function modify_site_settings(site, type, url)
    if url == 'remove' then
        url = nil
    end
    settings.sites[site][type] = url
end

function set_last_item(bag, index, id, count)
    if bag == 0 then
        last_item = id
    end
end

-- Replaces the named parameters in the url
function format_url(url, term)
    if term == nil then
        return term
    end
    return url:gsub('${term}', '%s':format(term))
end

function get_site(command)
    local site = settings.sites[command]
    if site ~= nil and site.redirect ~= nil then
        site = settings.sites[site.redirect]
    end
    return site
end

function get_url(site, term)
    term = translate(term)
    term = parse_selection(term)
    local id = get_id(term)
    if id.item ~= nil and site.item ~= nil then
        url = format_url(site.item, id.item)
    elseif id.zone ~= nil and site.zone ~= nil then
        url = format_url(site.zone, id.zone)
    else
        url = format_url(site.search, term)
    end
    return url
end

function process_command(...)
    -- get the first argument and set it as the command for now
    local command = ({...}[1] or ''):lower()

    if command == 'default' then
        local command_modifier, default_site
        if {...}[3] ~= nil then
            -- if there are three or more arguments, the second one is the modifier
            command_modifier = {...}[2]
            default_site = {...}[3]
        else
            default_site = {...}[2]
        end
        set_default_site(command_modifier, default_site)
        return
    elseif command == 'site' then
        local site = {...}[2]
        local type = {...}[3]
        local url = {...}[4]
        modify_site_settings(site, type, url)
        return
    end

    local term;
    if {...}[2] ~= nil then
        -- if there are two arguments, the first is the command and the second the term
        command = {...}[1]
        term = {...}[2]
    else
        -- otherwise, just a term is provided, so use the default command
        command = settings.default
        term = {...}[1]
    end
    if term == nil then
        return
    end

    local site = get_site(command:lower())
    if site == nil then
        return
    end

    local url = get_url(site, term)
    if url == nil then
        return
    end
    windower.open_url(url)
end

load_settings()
initialize_ids()

windower.register_event('add item', set_last_item)
windower.register_event('addon command', process_command)

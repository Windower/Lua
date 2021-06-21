-- Copyright © 2017, Cair
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of ROE nor the
      -- names of its contributors may be used to endorse or promote products
      -- derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL Cair BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


_addon = {}
_addon.name = 'ROE'
_addon.version = '1.0'
_addon.author = "Cair"
_addon.commands = {'roe'}

packets = require('packets')
config = require('config')
require('logger')


local defaults = T{
    profiles = T{
        default = S{},
    },
    blacklist = S{},
    clear = true,
    clearprogress = false,
    clearall = false,
}

settings = config.load(defaults)

_roe = T{
    active = T{},
    complete = T{},    
    max_count = 30,
}


local function cancel_roe(id)
    id = tonumber(id)
    
    if not id then return end
    
    if settings.blacklist[id] or not _roe.active[id] then return end
    
    local p = packets.new('outgoing', 0x10d, {['RoE Quest'] = id })
    packets.inject(p)
end

local function accept_roe(id)
    id = tonumber(id)
    
    if not id or _roe.complete[id] or _roe.active[id] then return end
    
    local p = packets.new('outgoing', 0x10c, {['RoE Quest'] = id })
    packets.inject(p)
end

local function eval(...)
    assert(loadstring(table.concat({...}, ' ')))()
end

local function save(name)
    if not type(name) == "string" then
        error('`save` : specify a profile name')
        return
    end
    
    name = name:lower()

    settings.profiles[name] = S(_roe.active:keyset())
    settings:save('global')
    notice('saved %d objectives to the profile %s':format(_roe.active:length(), name))
end


local function list()
    notice('You have saved the following profiles: ')
    notice(settings.profiles:keyset())
end

local function set(name)
    if not type(name) == "string" then
        error('`set` : specify a profile name')
        return
    end
    
    name = name:lower()
    
    if not settings.profiles[name] then
        error('`set` : the profile \'%s\' does not exist':format(name))
        return
    end
    
    local needed_quests = settings.profiles[name]:diff(_roe.active:keyset())   
    local available_slots = _roe.max_count - _roe.active:length()
    local to_remove = S{}
           
    if settings.clearall then
        to_remove:update(_roe.active:keyset())
    elseif settings.clear then
        for id,progress in pairs(_roe.active) do
            if (needed_quests:length() - to_remove:length()) <= available_slots then
                break
            end
            if (progress == 0 or settings.clearprogress) and not settings.blacklist[id] then
                to_remove:add(id)
            end
        end
    end
            
        
    if (needed_quests:length() - to_remove:length()) > available_slots then
        error('you do not have enough available quest slots')
        return
    end
    
    for id in to_remove:it() do
        cancel_roe(id)
        coroutine.sleep(.5)
    end
    
    for id in needed_quests:it() do
        accept_roe(id)
        coroutine.sleep(.5)
    end
    
    notice('loaded the profile \'%s\'':format(name))

end

local function unset(name)

    name = name and name:lower()

    if name and settings.profiles[name] then
        for id in _roe.active:keyset():intersection(settings.profiles[name]):it() do
            cancel_roe(id)
            coroutine.sleep(.5)
        end
        notice('unset the profile \'%s\'':format(name))
    elseif name then
        error('`unset` : the profile \'%s\' does not exist':format(name))
    elseif not name then
        notice('clearing ROE objectives.')
        for id,progress in pairs(_roe.active:copy()) do
            if progress == 0 or settings.clearprogress then
                cancel_roe(id)
                coroutine.sleep(.5)
            end
        end
    end

end

local true_strings = S{'true','t','y','yes','on'}
local false_strings = S{'false','f','n','no','off'}
local bool_strings = true_strings:union(false_strings)

local function handle_setting(setting,val)
    setting = setting and setting:lower() or setting
    val = val and val:lower() or val
    
    if not setting or not settings:containskey(setting) then
        error('specified setting (%s) does not exist':format(setting or ''))
    elseif type(settings[setting]) == "boolean" then
        if not val or not bool_strings:contains(val) then
            settings[setting] = not settings[setting]
        elseif true_strings:contains(val) then
            settings[setting] = true
        else    
            settings[setting] = false
        end
            
        notice('%s setting is now %s':format(setting, tostring(settings[setting])))
    end

end

local function blacklist(add_remove,id)
    add_remove = add_remove and add_remove:lower()
    id = id and tonumber(id)

    
    if add_remove and id then
        if add_remove == 'add' then
            settings.blacklist:add(id)
            notice('roe quest %d added to the blacklist':format(id))
        elseif add_remove == 'remove' then
            settings.blacklist:remove(id)
            notice('roe quest %d removed from the blacklist':format(id))
        else
            error('`blacklist` specify \'add\' or \'remove\'')
        end
    else
        error('`blacklist` requires two args, [add|remove] <quest id>')
    end
    
end


local function help()
    notice([[ROE - Command List:
1. help - Displays this help menu.
2. save <profile name> : saves the currently set ROE to the named profile
3. set <profile name> : attempts to set the ROE objectives in the profile
    - Objectives may be canceled automatically based on settings.
    - The default setting is to only cancel ROE that have 0 progress if space is needed
4. unset : removes currently set objectives
    - By default, this will only remove objectives without progress made
5. settings <settings name> : toggles the specified setting
    * settings:
        * clear : removes objectives if space is needed (default true)
        * clearprogress : remove objectives even if they have non-zero progress (default false)
        * clearall : clears every objective before setting new ones (default false)
6. blacklist [add|remove] <id> : blacklists a quest from ever being removed
    - I do not currently have a mapping of quest IDs to names]])
end

local cmd_handlers = {
    eval = eval,
    save = save,
    list = list,
    set = set,
    unset = unset,
    settings = handle_setting,
    blacklist = blacklist,
    help = help,
}


local function inc_chunk_handler(id,data)
    if id == 0x111 then
        _roe.active:clear()
        for i = 1, _roe.max_count do
            local offset = 5 + ((i - 1) * 4)
            local id,progress = data:unpack('b12b20', offset)
            if id > 0 then
                _roe.active[id] = progress
            end
        end
    elseif id == 0x112 then
        local complete = T{data:unpack('b1':rep(1024),4)}:key_map(
            function(k) 
                return (k + 1024*data:unpack('H', 133) - 1) 
            end):map(
            function(v) 
                return (v == 1)
            end)
        _roe.complete:update(complete)
    end
end

local function addon_command_handler(command,...)
    local cmd  = command and command:lower() or "help"
    if cmd_handlers[cmd] then
        cmd_handlers[cmd](...)
    else
        error('unknown command `%s`':format(cmd or ''))
    end

end

local function load_handler()
    for k,v in pairs(settings.profiles) do
        if type(v) == "string" then
            settings.profiles[k] = S(v:split(','):map(tonumber))
        end
    end
    
    local last_roe = windower.packets.last_incoming(0x111)
    if last_roe then inc_chunk_handler(0x111,last_roe) end

end

windower.register_event('incoming chunk', inc_chunk_handler)
windower.register_event('addon command', addon_command_handler)
windower.register_event('load', load_handler)

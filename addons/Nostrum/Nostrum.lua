--[[Copyright © 2014-2017, trv
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Nostrum nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL trv BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.--]]

_addon.name = 'Nostrum'
_addon.author = 'trv'
_addon.version = '3.0'
_addon.commands = {'Nostrum', 'nos'}
_addon.language = string.lower(windower.ffxi.get_info().language)

nostrum = {}

require 'sets'
require 'pack'
require 'lists'
require 'tables'
require 'strings'

xml = require 'xml'
bit = require 'bit'
json = require 'json'
files = require 'files'
res = require 'resources'
config = require 'config'
packets = require 'packets'

parties = require 'parties'
players = require 'players'

do
    --[[
        Grab the widgets library, which is "temporarily" stored
        in the wip folder.
    --]]
    local pattern = package.path
    local temp_pattern = windower.addon_path 
        .. 'wip/?.lua;' .. pattern
    
    package.path = temp_pattern
    
    widgets = require 'widgets'
    
    package.path = pattern
end

require 'global_definitions'
require 'event_handling'
require 'packet_parsing'
require 'helper_functions'
require 'user_environment'

do
    local _print = print
    print = function(...)
        _print(_addon.name, ...)
    end
    
    -- clean up old files
    local out_of_date = false
    local old_files = L{}
    
    for _, old_file in ipairs({
        'helperfunctions.lua',
        'variables.lua',
        'prims.lua',
    }) do
        local file_path = windower.addon_path .. old_file
        
        if windower.file_exists(file_path) then
            out_of_date = true
            old_files:append(file_path)
        end
    end
    
    -- handle an old settings file
    if out_of_date then
        local file_path = windower.addon_path .. 'data/settings.xml'
        print('out of date warning!')
        if windower.file_exists(file_path) then
            -- try to convert the profiles
            local old_settings = config.load('data/settings.xml', {})
            local old_env = setmetatable({}, {__index = _G})
            print('settings found')
            local get_old_variables = loadfile(windower.addon_path .. 'variables.lua')
            local get_old_helperfunctions = loadfile(windower.addon_path .. 'helperfunctions.lua')
            
            if get_old_variables and get_old_helperfunctions then
                setfenv(get_old_variables, old_env)
                setfenv(get_old_helperfunctions, old_env)
                get_old_variables()
                get_old_helperfunctions()

                local new_settings = T{
                    settings = {
                        global = {
                            default = {},
                        }
                    }
                }

                local aliases = function(s)
                    return old_env.options.aliases[s]
                end

                for name, spellset in pairs(old_settings.profiles) do
                    local new = {}
                    new_settings.settings.global['your_old_' .. name .. '_profile'] = new
                    
                    old_env.macro_order = T{nil,L{},nil,L{},L{}}
                    old_env.count_cures(spellset)
                    old_env.count_na(spellset)
                    old_env.count_buffs(spellset)
                    
                    local buffs = old_env.macro_order[5]:reverse()
                    local macros = old_env.macro_order[1]:reverse()
                    local statuses = old_env.macro_order[4]:reverse()
                    
                    new.buffs = buffs:concat('|')
                    new.macros = macros:concat('|')
                    new.statuses = statuses:concat('|')                    
                    
                    new.buff_labels = buffs:map(aliases):concat('|')
                    new.macro_labels = macros:map(aliases):concat('|')
                    new.status_labels = statuses:map(aliases):concat('|')
                    
                    new.buff_icons = new.buffs:lower()
                    new.status_icons = new.statuses:lower()
                end    
                
                files.new('overlays/MsJans/data/settings.xml'):write(
                    '<?xml version="1.1" ?>\n'
                    .. new_settings:to_xml()
                )

                os.rename(file_path, windower.addon_path .. 'overlays/MsJans/data/your_old_settings.xml')
            end
        end
        
        for old_file in old_files:it() do
            os.remove(old_file)
        end
        
        print:prepare(_addon.name .. ' was updated.'):schedule(5)
    end
end

nostrum.state = {
    running = false,
    hidden = false,
    initializing = false,
    debugging = false,    
}

nostrum.available = function()
    local state = nostrum.state
    
    return state.running and not state.hidden
end

nostrum.windower_event_ids = T{}

nostrum.event_listeners = {    
    ['logout'] = function()
        nostrum.state.running = false
        
        for i = 1, 3 do
            alliance[i]:dissolve()
        end
        
        for id in pairs(alliance_lookup) do
            forget(id)
        end
        
        for i = 1, 6 do
            buff_lookup[i] = {array = L{}, active = {}}
        end
        
        call_events('unload')
        clean_up_user_env()
        _G.sandbox = nil
        
        for event in pairs(event_registry) do
            event_registry[event] = nil
        end
        
        unregister_events()
    end,
    
    ['target change'] = function(index)
        -- Update stuff other than HP?
        local mob = windower.ffxi.get_mob_by_index(index)
        
        target = mob or {index = 0, hpp = 0}
        
        local mob_readonly = readonly(mob or {})
        
        sandbox.target = mob_readonly
        call_events('target change', mob_readonly)
    end,
    
    ['mouse'] = function(...)
        if nostrum.available() then
            action.handled = true
            
            local widget_block = widget_listener(...)
            
            if not action.handled then
                input_action()
            end
                        
            local user_block = call_events('mouse input', ...)
            
            return widget_block or user_block
        end
    end,
    
    ['keyboard'] = function(...)
        if nostrum.available() then
            action.handled = true
            
            call_events('keyboard input', ...)
            
            if not action.handled then
                input_action()
            end
        end
    end,
    
    ['zone change'] = function(new_id, old_id)
        pc.zone = new_id
        nostrum.state.running = true
        target.index = 0
        -- No 0x0C8 packet is sent for solo players who zone after summoning trusts
        -- Kick trusts summoned while solo
        
        if alliance[2]:count() == 0 and alliance[3]:count() == 0 then
            local party = alliance[1]
            local kick = L{}
            local is_player_solo = true
            
            for i = party:count(), 2, -1 do
                local id = party[i]
                
                if alliance_lookup[id].is_trust then
                    kick:append(id)
                else
                    is_player_solo = false
                    break
                end
            end
            
            if is_player_solo then
                for i = 1, kick.n do
                    local id = kick[i]
                    
                    forget(id)
                    
                    local spot = party:kick(id)
                    
                    call_events('member leave', 1, spot)
                end
            end
        
        end
        
        low_level_visibility(true)
        call_events('zone change', new_id, old_id)
    end,
    
    ['job change'] = function(main, main_level, sub, sub_level)
        pc.main = main
        pc.sub = sub
        pc.main_level = main_level
        pc.sub_level = sub_level
        
        call_events('job change', main, main_level, sub, sub_level)
    end,

    ['addon command'] = function(...)
        call_events('addon command', ...)
    end,
}

do
    local parse = parse_lookup.incoming
    
    nostrum.event_listeners['incoming chunk'] = function(id, data)
        if parse[id] then
            parse[id](data)
        end
    end
end

do
    local parse = parse_lookup.outgoing
    
    nostrum.event_listeners['outgoing chunk'] = function(id, data)
        if parse[id] then
            parse[id](data)
        end
    end
end

windower.register_event('addon command', function(c, ...)
    local c = c and c:lower() or 'help'
    local args = {...}
    
    if c == 'help' then
        print([[\cs(20, 200, 120)Nostrum commands:\cr
            help: Prints this message.
            refresh(r): Compares the current party structures to the
             - alliance structure in memory.
            visible(v): Toggles the overlay's visibility.
            overlay(o) <name>: Loads a new overlay.
            send(s) <name>: Requires 'send' addon. Sends commands to the
             - character whose name is provided. Revert this setting by
             - entering the send command with no name argument.]])
    elseif c == 'visible' or c == 'v' then
        local not_visible
        
        if args[1] and T{'false', 'n', 'x', 'hide', '0'}:contains(args[1]) then
            not_visible = true
            nostrum.state.hidden = true
        elseif args[1] and T{'true', 'y', 'o', 'show', '1'}:contains(args[1]) then
            not_visible = false
            nostrum.state.hidden = false
        else
            not_visible = not nostrum.state.hidden
            nostrum.state.hidden = visible
        end

        low_level_visibility(not not_visible)
    elseif c == 'refresh' or c == 'r' then
        compare_alliance_to_memory()
    elseif c == 'send' or c == 's' then
        if args[1] then
            local name = tostring(args[1])
            send_string = 'send %s ':format(name)
            print('Commands will be sent to: ' .. name)
        else
            send_string = ''
            print('Input contained no name. Send disabled.')
        end
    elseif c == 'overlay' or c == 'o' then
        if not args[1] then
            print('Specify overlay file')
        else
            call_events('unload')
            clean_up_user_env()
            _G.sandbox = nil
            
            local name = tostring(args[1])
            
            initialize(name)
        end
    elseif c == 'debug' then
        if not args[1] or not nostrum.state.debugging then
            
            dbg = {}
            
            for event, b in pairs(events) do
                dbg[event] = function(...)
                    call_events(event, ...)
                end
            end
            
            nostrum.state.debugging = true
            print('\\cs(255, 122, 122)ƁǝƸΡ βόΦϷ ϐΞΈρ Ъθϼ! Debug mode\\cr')
        end
        
        if not args[1] then return end
        
        local script = tostring(args[1])

        if script == 'exit' then
            dbg = nil
            nostrum.state.debugging = false
            print('\\cs(255, 122, 122)Exiting debug mode.\\cr')
        elseif files.exists('/tests/' .. script .. '.lua') then
            local contents, err = loadfile(windower.addon_path .. 'tests/' .. script .. '.lua')
            
            if contents then
                local test, description = contents()
                
                print('\\cs(200, 200, 255)Running test "' .. script .. '"...\\cr')
                
                if description then
                    print('\\cs(220, 180, 235)' .. description .. '\\cr')
                else
                    print('\\cs(220, 180, 235)This test has no description.\\cr')
                end
                
                if test then
                    test(select(2, ...))
                end
                
                print('\\cs(200, 200, 255)Test complete.\\cr')
            else
                print(err)
            end
        else
            print('\\cs(255, 0, 0)Script not found: \\cr' .. script)
        end
    elseif c == 'eval' then
        assert(loadstring(table.concat(args, ' ')))()
    end
end)

windower.register_event('login', function()
    if not nostrum.state.initializing then
        stall_for_player()
    end
end)

function register_events()
    for event, fn in pairs(nostrum.event_listeners) do
        nostrum.windower_event_ids:append(windower.register_event(event, fn))
    end
end

function unregister_events()
    windower.unregister_event(unpack(nostrum.windower_event_ids))
    nostrum.windower_event_ids = T{}
end

function stall_for_player()
    nostrum.state.initializing = true
    
    local player = windower.ffxi.get_player()
    
    if player then
        local mob = windower.ffxi.get_mob_by_index(player.index)
        
        if not mob then
            coroutine.schedule(stall_for_player, 2)
            return
        end
        
        pc = {
            id = player.id,
            index = player.index,
            main = player.main_job,
            sub = player.sub_job,
            main_level = player.main_job_level,
            sub_level = player.sub_job_level,
            x = mob.x,
            y = mob.y
        }
        
        initialize(config.load({overlay = 'MsJans'}).overlay)
        
        pc.buffs = buff_lookup[1]
    else
        coroutine.schedule(stall_for_player, 2)
    end
end

stall_for_player()

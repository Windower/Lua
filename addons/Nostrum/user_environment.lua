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

function build_a_sandbox(overlay_name)
    sandbox = {
        pairs = pairs,
        ipairs = ipairs,
        assert = assert,
        error = error,
        next = next,
        pcall = pcall,
        print = print,
        select = select,
        setmetatable = setmetatable,
        --getmetatable = getmetatable, -- getmetatable makes it very difficult to create a sandbox
        tonumber = tonumber,
        tostring = tostring,
        type = type,
        unpack = unpack,
        xpcall = xpcall,
    }
    
    sandbox.get_party = function(n)
        local party = alliance[n]
        
        if party then
            local pt = {}
            local n = party:count()
            
            for i = 1, n do
                pt[i] = sandbox_lookup[party[i]]
            end
            
            pt.count = n
            
            return pt
        end
        
        return false
    end
    
    sandbox.get_player = function(party, pos)
        local pt = alliance[party]
        
        if not pt then return false end
        
        return pt[pos] and sandbox_lookup[pt[pos]]
    end
    
    sandbox.get_buff_array = function(n)
        local buff_array = buff_lookup[n] and buff_lookup[n].array
        
        return buff_array and readonly(buff_array)
    end
    
    sandbox.get_active_buffs = function(n)
        local active_buffs = buff_lookup[n] and buff_lookup[n].active
        
        return active_buffs and readonly(active_buffs)
    end
    
    sandbox.addon_state = readonly(nostrum.state)
    sandbox.nostrum_available = nostrum.available
    sandbox.overlay = {}
    sandbox.overlay_name = overlay_name
    sandbox.windower_settings = windower.get_windower_settings()
    sandbox.character = readonly(pc)
    sandbox.register_event = nostrum.register_event
    sandbox.unregister_event = nostrum.unregister_event
    sandbox.get_zone = function() return windower.ffxi.get_info().zone end
    
    interpret_command = get_action_interpreter({})
    sandbox.get_action = interpret_command
    
    sandbox.action = function(act, target)
        if not act then return end

        act = act:lower()
        
        local valid_action = act == 'target' and {prefix = '/target', [_addon.language] = ''}
            or interpret_command(act)
        
        if valid_action then
            action.text = act
            action.target = target
            action.handled = false
            action.proper = valid_action[_addon.language]
            action.prefix = valid_action.prefix
        end
    end

    sandbox.target = readonly(target)

    -- a (very) limited version of require
    -- prevents require from altering Nostrum's global table

    sandbox.overlay_path = '%soverlays/%s/':format(windower.addon_path, overlay_name)
    sandbox.addon_path = windower.addon_path
        
    sandbox.require = function(file)
        local fn, err = loadfile(
            '%s/%s.lua'
            :format(sandbox.overlay_path, file)
        )
        
        if fn then
            setfenv(fn, sandbox)
            return fn()
        else
            print(err)
        end
    end

    sandbox._G = sandbox

    -- available libraries
    sandbox.S, sandbox.T, sandbox.L = S, T, L

    for _, lib in ipairs({
        'config', 'simple_buttons', 'windows', 'scroll_menu', 'scroll_text',
        'sliders', 'widgets', 'buttons', 'groups', 'grids', 'texts', 'prims',
        '_addon', 'list', 'set', 'table', 'coroutine', 'string', 'math',
        'io', 'os', 'json', 'files'
        }) do
        
        
        local t = {}
        sandbox[lib] = t
        
        for s, fn in pairs(_G[lib]) do
            t[s] = fn
        end
    end
    
    sandbox.coroutine.sleep = function(n)
        coroutine.yield('sleep', n)
    end
    
    sandbox.coroutine.yield = function(...)
        coroutine.yield('yield', ...)
    end

    -- this is a bigger pain than expected
    sandbox.files.new = function(path, create)
        if path and type(path) == 'string' then
            path = '/overlays/' .. overlay_name .. '/' .. path
        end
        
        return files.new(path, create)
    end
    
    sandbox.files.exists = function(path)
        if path and type(path) == 'string' then
            path = '/overlays/' .. overlay_name .. '/' .. path
        end
        
        return files.exists(path)
    end
    
    sandbox.config.load = function(path, defaults)
        if not path or type(path) ~= 'string' then
            path = '/overlays/' .. overlay_name .. '/data/settings.xml'
        elseif type(path) == 'string' then
            path = '/overlays/' .. overlay_name .. '/' .. path
        end
        
        return config.load(path, defaults)
    end
    
    sandbox.json.read = function(path)
        if type(path) == 'string' then
            path = '/overlays/' .. overlay_name .. '/' .. path
        end
        
        return json.read(path)
    end
    
    --sandbox.res = res
end

function clean_up_user_env()
    for obj in pairs(bucket.widgets) do
        obj:destroy()
        bucket.widgets[obj] = nil
    end
    
    for name in pairs(bucket.prim) do
        windower.prim.delete(name)
    end
    
    for name in pairs(bucket.text) do
        windower.prim.delete(name)
    end
end

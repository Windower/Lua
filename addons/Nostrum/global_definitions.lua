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

if windower.ffxi.get_info().logged_in then
    local player = windower.ffxi.get_player()
    local player_mob = windower.ffxi.get_mob_by_index(player.index)
    
    pc = {
        id = player.id,
        index = player.index,
        pos = {x = player_mob.x, y = player_mob.y},
        main = player.main_job,
        sub = player.sub_job,
        main_level = player.main_job_level,
        sub_level = player.sub_job_level
    }
    
    target = windower.ffxi.get_mob_by_target('st')
        or windower.ffxi.get_mob_by_target('t')
        or {index = 0, hpp = 0}
else
    pc = {}
    target = {index = 0, hpp = 0}
end

alliance = {parties.new(), parties.new(), parties.new()}

alliance_lookup = setmetatable({}, {__newindex = function(t, k, v)
    rawset(t, k, v)
    
    sandbox_lookup[k] = weak_readonly(v)
end})

trust_lookup = {}
sandbox_lookup = {}
buff_lookup = {
    {array = L{}, active = {}},
    {array = L{}, active = {}},
    {array = L{}, active = {}},
    {array = L{}, active = {}},
    {array = L{}, active = {}},
    {array = L{}, active = {}},
}

action = {
    text = '',
    target = '',
    prefix = '',
    proper = '',
    handled = true
}

function input_action()
    if nostrum.state.debugging then
        print('%s → %s':format(action.prefix .. ' ' .. action.proper, action.target))        
    else
        local formatted_input = action.proper == '' and '%s %s':format(action.prefix, action.target)
            or _addon.language == 'Japanese' and '%s %s %s':format(action.prefix, action.proper, action.target)
            or '%s "%s" %s':format(action.prefix, action.proper, action.target)

        windower.chat.input(formatted_input)
    end
    
    action.handled = true
end

--[[
    Wrap object creation and deletion functions:
        Overlay is loaded/unloaded on log-in/log-out/load (potentially frequently).
        
        Track prim/text object names and delete them if the overlay author forgets to.
        
        Visibility wrapped for addon command 'visible'. Ignore object methods and hide
        them at windower's level, then restore them to the state in bucket.
        
        Widgets need to be destroyed as well (meta will keep a reference to them
        even if the sandbox is destroyed). If the quadtree is tracking them, they
        must be removed or the quadtree will become very large.
        Could create a function to dump the contents of meta(4t) and delete the tree?
--]]

bucket = {}

for _, cat in pairs({'text', 'prim'}) do
    local t = {}
    bucket[cat] = t
    
    local bin = windower[cat]
    local create = bin.create
    local visibility = bin.set_visibility
    local delete = bin.delete
    
    windower[cat].create = function(name)
        create(name)
        t[name] = false
    end
    
    windower[cat].set_visibility = function(name, visible)
        visibility(name, not nostrum.state.hidden and visible)
        t[name] = visible
    end
    
    windower[cat].delete = function(name)
        delete(name)
        t[name] = nil
    end
    
    windower[cat].rawset_visibility = visibility
end

bucket.widgets = {}

for _, cat in pairs({
        'simple_buttons', 'windows', 'buttons',
        'scroll_text', 'sliders', 'scroll_menu',
        'groups', 'grids', 'texts', 'prims',
    }) do
    
    local class = _G[cat]
    local new = class.new
    local destroy = class.destroy
    
    class.new = function(...)
        local obj = new(...) 
        bucket.widgets[obj] = true
        
        return obj
    end
    
    class.destroy = function(obj)
        if widgets.tracking(obj) then
            widgets.do_not_track(obj)
        end

        destroy(obj)
        bucket.widgets[obj] = nil
    end
end

function _pcall(fn, ...)
    local thread = coroutine.create(fn)
    local results = {coroutine.resume(thread, ...)}
    
    while coroutine.status(thread) ~= 'dead' do
        local pass = results[1]
        
        if pass and results[2] then
            local retval = results[2]
            
            if retval == 'sleep' then
                local sleep_time = results[3]
                
                if type(sleep_time) == 'number' then
                    coroutine.sleep(sleep_time)
                end
            elseif retval == 'yield' then
                coroutine.yield(unpack(results, 3))
            end
        end
        
        results = {coroutine.resume(thread)}
    end
    
    return unpack(results)
end

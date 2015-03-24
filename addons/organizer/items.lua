--Copyright (c) 2015, Byrthnoth and Rooks
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

local Items = {}
local items = {}
local bags = {}
local item_tab = {}

local function validate_bag(bag_table)
    if (bag_table.access == 'Everywhere' or (bag_table.access == 'Mog House' and windower.ffxi.get_info().mog_house)) and
        windower.ffxi.get_bag_info(bag_table.id) then
        return true
    end
    return false
end

local function validate_id(id)
    return (id and id ~= 0 and id ~= 0xFFFF) -- Not empty or gil
end

local function wardrobecheck(bag_id,id)
    return bag_id~=8 or (bag_id == 8 and res.items[self.id] and (res.items[self.id].type == 4 or res.items[self.id].type == 5) )
end

function Items.new(loc_items,bool)
    loc_items = loc_items or windower.ffxi.get_items()
    new_instance = setmetatable({}, {__index = function (t, k) if rawget(t,k) then return rawget(t,k) else return rawget(items,k) end end})
    for bag_id,bag_table in pairs(res.bags) do
        if (bool or validate_bag(bag_table)) and (loc_items[bag_id] or loc_items[bag_table.english:lower()]) then
            local cur_inv = new_instance:new(bag_id)
            for inventory_index,item_table in pairs(loc_items[bag_id] or loc_items[bag_table.english:lower()]) do
                if type(item_table) == 'table' and validate_id(item_table.id) then
                    cur_inv:new(item_table.id,item_table.count,item_table.extdata,item_table.status,inventory_index)
                end
            end
        end
    end
    return new_instance
end

function items:new(key)
    local new_instance = setmetatable({_parent = self,_info={n=0,bag_id=key}}, {__index = function (t, k) if rawget(t,k) then return rawget(t,k) else return rawget(bags,k) end end})
    self[key] = new_instance
    return new_instance
end

function items:find(item)
    for bag_id,bag_table in pairs(res.bags) do
        if self[bag_id] and self[bag_id]:contains(item) then
            return bag_id, self[bag_id]:contains(item)
        end
    end
    return false
end

function items:route(start_bag,start_ind,end_bag,count)
    count = count or self[start_bag][start_ind].count
    local failure = false
    local initial_ind = start_ind
    if start_bag ~= 0 and self[0]._info.n < 80 then
        start_ind = self[start_bag][start_ind]:move(0,0x52,count)
    elseif start_bag ~= 0 and self[0]._info.n >= 80 then
        failure = true
        org_warning('Cannot move more than 80 items into inventory')
    end
        
    if start_ind and end_bag ~= 0 and self[end_bag]._info.n < 80 then
        self[0][start_ind]:transfer(end_bag,count)
    elseif not start_ind then
        failure = true
        org_warning('Initial movement of the route failed. ('..tostring(start_bag)..' '..tostring(initial_ind)..' '..tostring(start_ind)..' '..tostring(end_bag)..')')
    elseif self[end_bag]._info.n >= 80 then
        failure = true
        org_warning('Cannot move more than 80 items into that inventory ('..end_bag..')')
    end
    return not failure
end

function items:it()
    local i = 0
    return function ()
        while i < #settings.bag_priority do
            i = i + 1
            local id = settings.bag_priority[i]
            if self[id] and validate_bag(res.bags[id]) then return id, self[id] end
        end
    end
end

function bags:new(id,count,extdata,status,index)
    if self._info.n >= 80 then org_warning('Attempting to add another item to a bag with 80 items') return end
    if index and table.with(self,'index',index) then org_warning('Cannot assign the same index twice') return end
    self._info.n = self._info.n + 1
    index = index or self:first_empty()
    status = status or 0
    self[index] = setmetatable({_parent=self,id=id,count=count,extdata=extdata,index=index,status=status,
        name=res.items[id][_global.language]:lower(),log_name=res.items[id][_global.language..'_log']:lower()},
        {__index = function (t, k) 
            if not t or not k then print('table index is nil error',t,k) end
            if rawget(t,k) then
                return rawget(t,k)
            else
                return rawget(item_tab,k)
            end
        end})
    return index
end

function bags:it()
    local i = 0
    return function ()
        while i < 80 do
            i = i + 1
            if self[i] then return i, self[i] end
        end
    end
end

function bags:first_empty()
    for i=1,80 do
        if not self[i] then return i end
    end
end

function bags:remove(index)
    if not rawget(self,index) then org_warning('Attempting to remove an index that does not exist') return end
    self._info.n = self._info.n - 1
    rawset(self,index,nil)
end

function bags:find_all_instances(item,bool)
    local instances = L{}
    for i,v in self:it() do
        if (bool or not v:annihilated()) and v.id == item.id then -- and v.count >= item.count then
            if item.augments and v.augments and extdata.compare_augments(item.augments,v.augments) or not item.augments then
                -- May have to do a higher level comparison here for extdata.
                -- If someone exports an enchanted item when the timer is
                -- counting down then this function will return false for it.
                instances:append(i)
            end
        end
    end
    if instances.n ~= 0 then
        return instances
    else
        return false
    end
end

function bags:contains(item,bool)
    bool = bool or false -- Default to only looking at unannihilated items
    local instances = self:find_all_instances(item,bool)
    if instances then
        return instances:it()()
    end
    return false
end

function bags:find_unfinished_stack(item,bool)
    local tab = self:find_all_instances(item,bool)
    if tab then
        for i in tab:it() do
            if res.items[self[i].id] and res.items[self[i].id].stack > self[i].count then
                return i
            end
        end
    end
    return false
end

function item_tab:transfer(dest_bag,count)
    -- Transfer an item to a specific bag.
    if not dest_bag then org_warning('Destination bag is invalid.') return false end
    count = count or self.count
    local parent = self._parent
    local targ_inv = parent._parent[dest_bag]
    if not (targ_inv._info.bag_id == 0 or parent._info.bag_id == 0) then
        org_warning('Cannot move between two bags that are not inventory bags.')
    else
        while parent[self.index] and targ_inv:find_unfinished_stack(parent[self.index]) do
            parent[self.index]:move(dest_bag,targ_inv:find_unfinished_stack(parent[self.index]),count)
        end
        if parent[self.index] then
            parent[self.index]:move(dest_bag)
        end
        return true
    end
    return false
end

function item_tab:move(dest_bag,dest_slot,count)
    if not dest_bag then org_warning('Destination bag is invalid.') return false end
    count = count or self.count
    local parent = self._parent
    local targ_inv = parent._parent[dest_bag]
    dest_slot = dest_slot or 0x52
    
    if not self:annihilated() and
        (not dest_slot or not targ_inv[dest_slot] or (targ_inv[dest_slot] and res.items[targ_inv[dest_slot].id].stack < targ_inv[dest_slot].count + count)) and
        (targ_inv._info.bag_id == 0 or parent._info.bag_id == 0) and
        wardrobecheck(targ_inv._info.bag_id,self.id) and
        self:free() then
        windower.packets.inject_outgoing(0x29,string.char(0x29,6,0,0)..'I':pack(count)..string.char(parent._info.bag_id,dest_bag,self.index,dest_slot))
        org_warning('Moving item! ('..res.items[self.id].english..') from '..res.bags[parent._info.bag_id].en..' '..parent._info.n..' to '..res.bags[dest_bag].en..' '..targ_inv._info.n..')')
        local new_index = targ_inv:new(self.id, count, self.extdata)
        --print(parent._info.bag_id,dest_bag,self.index,new_index)
        parent:remove(self.index)
        return new_index
    elseif not dest_slot then
        org_warning('Cannot move the item ('..res.items[self.id].english..'). Target inventory is full ('..res.bags[dest_bag].en..')')
    elseif targ_inv[dest_slot] and res.items[targ_inv[dest_slot].id].stack < targ_inv[dest_slot].count + count then
        org_warning('Cannot move the item ('..res.items[self.id].english..'). Target inventory slot would be overly full ('..(targ_inv[dest_slot].count + count)..' items in '..res.bags[dest_bag].en..')')
    elseif (targ_inv._info.bag_id ~= 0 and parent._info.bag_id ~= 0) then
        org_warning('Cannot move the item ('..res.items[self.id].english..'). Attempting to move from a non-inventory to a non-inventory bag ('..res.bags[parent._info.bag_id].en..' '..res.bags[dest_bag].en..')')
    elseif self:annihilated() then
        org_warning('Cannot move the item ('..res.items[self.id].english..'). It has already been annihilated.')
    elseif not wardrobecheck(targ_inv._info.bag_id,self.id) then
        org_warning('Cannot move the item ('..res.items[self.id].english..') to the wardrobe. Wardrobe cannot hold an item of its type ('..tostring(res.items[self.id].type)..').')
    elseif not self:free() then
        org_warning('Cannot free the item ('..res.items[self.id].english..'). It has an unaddressable item status ('..tostring(self.status)..').')
    end
    return false
end

function item_tab:put_away(usable_bags)
    local current_items = self._parent._parent
    usable_bags = usable_bags or {1,4,2,5,6,7,8}
    local bag_free
    for _,v in ipairs(usable_bags) do
        if current_items[v]._info.n < 80 and wardrobecheck(v,self.id) then
            bag_free = v
            break
        end
    end
    if bag_free then
        self:transfer(bag_free,self.count)
    end
end

function item_tab:free()
    if self.status == 5 then
        local eq = windower.ffxi.get_items().equipment
        for _,v in pairs(res.slots) do
            local ind_name = v.english:lower():gsub(' ','_')
            local bag_name = ind_name..'_bag'
            local ind, bag = eq[ind_name],eq[bag_name]
            if self.index == ind and self._parent._info.bag_id == bag then
                windower.packets.inject_outgoing(0x50,string.char(0x50,0x04,0,0,self._parent._info.bag_id,v.id,0,0))
                break
            end
        end
    elseif self.status ~= 0 then
        return false
    end
    return true
end

function item_tab:annihilate(count)
    count = count or rawget(item_tab,'count')
    local a_count = (rawget(item_tab,'a_count') or 0) + count
    if a_count >count then
        org_warning('Annihilating more of an item ('..item_tab.id..' : '..a_count..') than possible ('..count..'.')
    end
    rawset(self,'a_count',a_count)
end

function item_tab:annihilated()
    return ( (rawget(self,'a_count') or 0) >= rawget(self,'count') )
end

function item_tab:available_amount()
    return ( rawget(self,'count') - (rawget(self,'a_count') or 0) )
end

return Items
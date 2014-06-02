-- Validate either gear sets or inventory.
-- gs validate [inv|set] [filterlist]
-- Where inv == i or inv or inventory
-- Where set == s or set or sets
-- Where filterlist can use - to negate a value (eg: -charis for everything except charis, instead of only charis)
function validate(options)
    local validateType = 'sets'
    if options and #options > 0 then
        if S{'sets','set','s'}:contains(options[1]:lower()) then
            table.remove(options,1)
        elseif S{'inventory','inv','i'}:contains(options[1]:lower()) then
            validateType = 'inv'
            table.remove(options,1)
        end
    end
    
    if validateType == 'inv' then
        validate_inventory(options)
    else
        validate_sets(options)
    end
end

-- Function specifically for seeing what of a player's inventory is not in their gear sets
function validate_inventory(filter)
    local extraitems = L{}
    local alreadyChecked = S{}

    windower.add_to_chat(123,'GearSwap: Checking for items in inventory that are not used in your gear sets.')
    
    for k,v in pairs(items.inventory) do
        if v.id and v.id ~= 0 then
            if not alreadyChecked[v.id] and not find_in_sets(v, sets) and tryfilter(res.items[v.id][language..'_log'] or res.items[v.id][language], filter) then
                if #res.items[v.id][language..'_log'] > #res.items[v.id][language] then
                    extraitems:append(res.items[v.id][language..'_log'])
                else 
                    extraitems:append(res.items[v.id][language])
                end
            end
            alreadyChecked:add(v.id)
        end
    end

    extraitems = extraitems:sort()
    extraitems:map(function(item) windower.add_to_chat(120, item) end)
    windower.add_to_chat(123,'GearSwap: Final count = '..tostring(extraitems:length()))
end

-- Utility support for validate_inventory.
function find_in_sets(item, tab, stack)
    if stack and stack:contains(tab) then
        return false
    end
    for _,v in pairs(tab) do
        local nam = v.name or v
        local aug = v.augments or v.augment
        if type(aug) == 'string' then aug = {aug} end
        if type(nam) == 'string' then
            nam = nam:lower()
            if ((res.items[item.id][language] and res.items[item.id][language]:lower() == nam) or (res.items[item.id][language..'_log'] and res.items[item.id][language..'_log']:lower() == nam)) and (not aug or compare_augments(aug,extdata.decode(item).augments)) then
                return true
            end
        else
            if not stack then stack = S{} end

            stack:add(tab)
            local try = find_in_sets(item, v, stack)
            stack:remove(tab)

            if try then
                return true
            end
        end
    end
    
    return false
end

-- Function specifically for seeing what of a player's gear sets is not in their inventory
function validate_sets(filter)
    local missingitems = S{}

    windower.add_to_chat(123,'GearSwap: Checking for items in gear sets that are not in your inventory.')
    windower.add_to_chat(123,'           (does not detect multiple identical items or look at augments)')
    
    recurse_sets(sets, missingitems, filter)
    
    missingitems = missingitems:sort()
    missingitems:map(function(item) windower.add_to_chat(120, item) end)
    windower.add_to_chat(123,'GearSwap: Final count = '..tostring(missingitems:length()))
end


-- Utility support for validate_sets.
function recurse_sets(tab, accum, filter, stack)
    if stack and stack:contains(tab) then return end
    if type(tab) ~= 'table' then return end
    
    for i,v in pairs(tab) do
        local nam = v.name or v
        local aug = v.augments or v.augment
        if type(aug) == 'string' then aug = {aug} end
        if type(nam) == 'string' and nam ~= 'empty' then
            if type(i) == 'string' and not slot_map[i:lower()] then
                windower.add_to_chat(123,'GearSwap: '..windower.to_shift_jis(tostring(i))..' contains a "name" element but is not a valid slot.')
            elseif tryfilter(nam:lower(), filter) and type(i) == 'string' and slot_map[i:lower()] and not find_in_inv(items.inventory,nam,aug) and not find_in_inv(items.wardrobe,nam,aug) then
                accum:add(nam)
            end
        elseif type(nam) == 'table' and nam ~= empty  then
            if not stack then stack = S{} end

            stack:add(tab)
            recurse_sets(v, accum, filter, stack)
            stack:remove(tab)
        end
    end
end

-- Utility support function for finding an item (with or without augments) in inventory
function find_in_inv(inv,name,aug)    
    for i,v in pairs(inv) do
        if res.items[v.id] and (res.items[v.id][language]:lower() == name:lower() or res.items[v.id][language..'_log']:lower() == name:lower()) and
            (not aug or (v.extdata and compare_augments(aug,extdata.decode(v).augments))) then
            return true
        end
    end
    return false
end


-- Utility support function for filtering results.
function tryfilter(name, filter)
    if not filter or #filter == 0 then
        return true
    end
    
    local pass = true
    for _,v in pairs(filter) do
        if v[1] == '-' then
            pass = false
            v = v:sub(2)
        end
        if not v or type(v) ~= 'string' then
            print_set(filter,'filter with bad v')
        end
        if name:contains(v:lower()) then
            return pass
        end
    end
    return not pass
end


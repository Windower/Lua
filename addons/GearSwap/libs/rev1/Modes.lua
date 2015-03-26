-------------------------------------------------------------------------------------------------------------------
-- This include library allows use of specially-designed tables for tracking
-- certain types of modes and state.
--
-- Usage: include('Modes.lua')
--
-- Construction syntax:
--
-- 1) Create a new list of mode values. The first value will always be the default.
-- MeleeMode = M{'Normal', 'Acc', 'Att'} -- Construct as a basic table, using braces.
-- MeleeMode = M('Normal', 'Acc', 'Att') -- Pass in a list of strings, using parentheses.
--
-- Optional: If constructed as a basic table, and the table contains a key value
-- of 'description', that description will be saved for future reference.
-- If a simple list of strings is passed in, no description will be set.
--
-- 2) Create a boolean mode with a specified default value (note parentheses):
-- UseLuzafRing = M(true)
-- UseLuzafRing = M(false)
--
-- Optional: A string may be provided that will be used as the mode description:
-- UseLuzafRing = M(false, 'description')
-- UseLuzafRing = M(true, 'description')
--
--
-- Public information fields (all are case-insensitive):
--
-- 1) m.description -- Get a text description of the mode table, if it's been set.
-- 2) m.current or m.value -- Gets the current mode value.  Booleans will return the strings "on" or "off".
-- 3) m.index -- Gets the current index value, or true/false for booleans.
--
--
-- Public class functions:
--
-- 1) m:describe(str) -- Sets the description for the mode table to the provided string value.
-- 2) m:options(options) -- Redefine the options for a list mode table.  Cannot be used on a boolean table.
--
--
-- Public mode manipulation functions:
--
-- 1) m:cycle() -- Cycles through the list going forwards.  Acts as a toggle on boolean mode vars.
-- 2) m:cycleback() -- Cycles through the list going backwards.  Acts as a toggle on boolean mode vars.
-- 3) m:toggle() -- Toggles a boolean Mode between true and false.
-- 4) m:set(n) -- Sets the current mode value to n.
--    Note: If m is boolean, n can be boolean true/false, or string of on/off/true/false.
--    Note: If m is boolean and no n is given, this forces m to true.
-- 5) m:unset() -- Sets a boolean mode var to false.
-- 6) m:reset() -- Returns the mode var to its default state.
-- 7) m:default() -- Same as reset()
--
-- All public functions return the current value after completion.
--
--
-- Example usage:
--
-- sets.MeleeMode.Normal = {}
-- sets.MeleeMode.Acc = {}
-- sets.MeleeMode.Att = {}
--
-- MeleeMode = M{'Normal', 'Acc', 'Att', ['description']='Melee Mode'}
-- MeleeMode:cycle()
-- equip(sets.engaged[MeleeMode.current])
-- MeleeMode:options('Normal', 'LowAcc', 'HighAcc')
-- >> Changes the option list, but the description stays 'Melee Mode'
--
--
-- sets.LuzafRing.on = {ring2="Luzaf's Ring"}
-- sets.LuzafRing.off = {}
--
-- UseLuzafRing = M(false)
-- UseLuzafRing:toggle()
-- equip(sets.precast['Phantom Roll'], sets.LuzafRing[UseLuzafRing.value])
-------------------------------------------------------------------------------------------------------------------


_meta = _meta or {}
_meta.M = {}
_meta.M.__class = 'mode'
_meta.M.__methods = {}


-- Default constructor for mode tables
-- M{'a', 'b', etc, ['description']='a'} -- defines a mode list, description 'a'
-- M('a', 'b', etc) -- defines a mode list, no description
-- M('a') -- defines a mode list, default 'a'
-- M{['description']='a'} -- defines a mode list, default 'Normal', description 'a'
-- M{} -- defines a mode list, default 'Normal', no description
-- M(false) -- defines a mode boolean, default false, no description
-- M(true) -- defines a mode boolean, default true, no description
-- M(false, 'a') -- defines a mode boolean, default false, description 'a'
-- M(true, 'a') -- defines a mode boolean, default true, description 'a'
-- M() -- defines a mode boolean, default false, no description
function M(t, ...)
    local m = {}
    m._track = {}

	-- If we're passed a list of strings, convert them to a table
	local args = {...}
	if type(t) == 'string' then
		t = {[1] = t}
		
	    for ind, val in ipairs(args) do
	        t[ind+1] = val
	    end
	end

	-- Construct the table that we'll be added the metadata to
	if type(t) == 'table' then
		m._track._type = 'list'
	    m._track._invert = {}
	    m._track._count = 0
		
	    if t['description'] then
	    	m._track._description = t['description']
	    end

		-- Only copy numerically indexed values
	    for ind, val in ipairs(t) do
	        m[ind] = val
			m._track._invert[val] = ind
		    m._track._count = ind
	    end
	    
	    if m._track._count == 0 then
	        m[1] = 'Normal'
			m._track._invert['Normal'] = 1
		    m._track._count = 1
	    end

		m._track._default = 1
	elseif type(t) == 'boolean' or t == nil then
		m._track._type = 'boolean'
		m._track._default = t or false
    	m._track._description = args[1]
	    m._track._count = 2
    	-- Text lookups for bool values
    	m[true] = 'on'
    	m[false] = 'off'
	else
		-- Construction failure
		error("Unable to construct a mode table with the provided parameters.", 2)
	end

    m._track._current = m._track._default

    return setmetatable(m, _meta.M)
end

--------------------------------------------------------------------------
-- Metamethods
-- Functions that will be used as metamethods for the class
--------------------------------------------------------------------------

-- Handler for __index when trying to access the current mode value.
-- Handles indexing 'current' or 'value' keys.
_meta.M.__index = function(m, k)
	if type(k) == 'string' then
		local lk = k:lower()
		if lk == 'current' or lk == 'value' then
			return m[m._track._current]
		elseif lk == 'index' then
			return m._track._current
		elseif m._track['_'..lk] then
			return m._track['_'..lk]
		else
			return _meta.M.__methods[lk]
		end
	end
end

-- Tostring handler for printing out the table and its current state.
_meta.M.__tostring = function(m)
    local res = ''
    if m._track._description then
    	res = res .. m._track._description .. ': '
    end

	if m._track._type == 'list' then
	    res = res .. '{'
	    for k,v in ipairs(m) do
	        res = res..tostring(v)
	        if m[k+1] ~= nil then
	            res = res..', '
	        end
	    end
	    res = res..'}' 
	else
		res = res .. 'Boolean'
	end
	
    res = res .. ' ('..tostring(m.Current).. ')'
    
    -- Debug addition
    --res = res .. ' [' .. m._track._type .. '/' .. tostring(m._track._current) .. ']'

    return res
end

-- Length handler for the # value lookup.
_meta.M.__len = function(m)
	return m._track._count
end


--------------------------------------------------------------------------
-- Public methods
-- Functions that can be used as public methods for manipulating the class.
--------------------------------------------------------------------------

-- Function to set the table's description.
_meta.M.__methods['describe'] = function(m, str)
	if type(str) == 'string' then
    	m._track._description = str
    else
    	error("Invalid argument type: " .. type(str), 2)
	end
end

-- Function to change the list of options available.
-- Leaves the description intact.
-- Cannot be used on boolean classes.
_meta.M.__methods['options'] = function(m, ...)
    if m._track._type == 'boolean' then
    	error("Cannot revise the options list for a boolean mode class.", 2)
    end

    local options = {...}
    -- Always include a default option if nothing else is given.
    if #options == 0 then
        options = {'Normal'}
    end

    -- Zero-out existing values and clear the tracked inverted list
    -- and member count.    
    for key,val in ipairs(m) do
        m[key] = nil
    end
	m._track._invert = {}
    m._track._count = 0

    -- Insert in new data.
    for key,val in ipairs(options) do
        m[key] = val
		m._track._invert[val] = key
	    m._track._count = key
    end
    
    m._track._current = m._track._default
end


--------------------------------------------------------------------------
-- Public methods
-- Functions that will be used as public methods for manipulating state.
--------------------------------------------------------------------------

-- Cycle forwards through the list
_meta.M.__methods['cycle'] = function(m)
	if m._track._type == 'list' then
		m._track._current = (m._track._current % m._track._count) + 1
	else
		m:toggle()
	end
	
	return m.Current
end

-- Cycle backwards through the list
_meta.M.__methods['cycleback'] = function(m)
	if m._track._type == 'list' then
		m._track._current = m._track._current - 1
		if  m._track._current < 1 then
			m._track._current = m._track._count
		end
	else
		m:toggle()
	end

	return m.Current
end

-- Toggle a boolean value
_meta.M.__methods['toggle'] = function(m)
	if m._track._type == 'boolean' then
		m._track._current = not m._track._current
	else
		error("Cannot toggle a list mode.", 2)
	end

	return m.Current
end


-- Set the current value
_meta.M.__methods['set'] = function(m, val)
	if m._track._type == 'boolean' then
	    if val == nil then
			m._track._current = true
		elseif type(val) == 'boolean' then
			m._track._current = val
		elseif type(val) == 'string' then
			val = val:lower()
			if val == 'on' or val == 'true' then
				m._track._current = true
			elseif val == 'off' or val == 'false' then
				m._track._current = false
			else
				error("Unrecognized value: "..tostring(val), 2)
			end
		else
			error("Unrecognized value type: "..type(val), 2)
		end
	else
		if m._track._invert[val] then
			m._track._current = m._track._invert[val]
		else
			local found = false
		    for v, ind in pairs(m._track._invert) do
		    	if val:lower() == v:lower() then
					m._track._current = ind
					found = true
					break
		    	end
		    end
		    
		    if not found then
		    	error("Unknown mode value: " .. tostring(val), 2)
		    end
		end
	end

	return m.Current
end

-- Reset to the default value
_meta.M.__methods['default'] = function(m)
    m._track._current = m._track._default

	return m.Current
end

-- Reset to the default value
_meta.M.__methods['reset'] = function(m)
    m._track._current = m._track._default

	return m.Current
end

-- Forces a boolean mode to false
_meta.M.__methods['unset'] = function(m)
	if m._track._type == 'boolean' then
        m._track._current = false
    else
    	error("Cannot unset a list mode class.", 2)
    end

	return m.Current
end

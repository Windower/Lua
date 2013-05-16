--[[
A library to handle ingame resources, as provided by the Radsources XMLs. It will look for the files in Windower/plugins/resources.
]]

_libs = _libs or {}
_libs.resources = true
_libs.tablehelper = _libs.tablehelper or require 'tablehelper'
_libs.stringhelper = _libs.stringhelper or require 'stringhelper'
_libs.logger = _libs.logger or require 'logger'
local xml = require 'xml'
_libs.xml = _libs.xml or (xml ~= nil)

local resources = T{}
local abils = T{}
local spells = T{}
local items = T{}
local status = T{}

--[[
	Local functions.
]]

local make_atom

-- Returns the abilities, indexed by ingame ID.
function resources.abils()
	if not abils:isempty() then
		return abils
	end
	
	local dom, err = xml.read('../../plugins/resources/abils.xml')
	if err then
		error(err)
		return T{}
	end
	
	abils = dom.children:map(make_atom)
	dom = nil
	collectgarbage()
	
	return abils
end

-- Returns the spells, indexed by ingame ID.
function resources.spells()
	if not spells:isempty() then
		return spells
	end
	
	local dom, err = xml.read('../../plugins/resources/spells.xml')
	if err then
		error(err)
		return T{}
	end
	
	spells = dom.children:map(make_atom)
	dom = nil
	collectgarbage()
	
	return spells
end

-- Returns the statuses, indexed by ingame ID.
function resources.status()
	if not status:isempty() then
		return status
	end
	
	local dom, err = xml.read('../../plugins/resources/status.xml')
	if err then
		error(err)
		return T{}
	end
	
	status = dom.children:map(make_nested)
	dom = nil
	collectgarbage()
	
	return status
end

-- Returns the items, indexed by ingame ID.
function resources.items()
	if not items:isempty() then
		return items
	end
	
	itemlists = T{'armor', 'general', 'weapons'}
	for _, itemlist in pairs(itemlists) do
		local dom, err = xml.read('../../plugins/resources/items_'..itemlist..'.xml')
		if err then
			error(err)
			return T{}
		end
		
		items:extend(dom.children:map(make_nested))
	end
	dom = nil
	collectgarbage()
	
	return items
end


-- Constructs a table from an atomic DOM node (containing no nested tags).
function make_atom(node)
	local res = T{}
	
	for _, val in ipairs(node.children) do
		res[val['name']] = val['value']
	end
	
	return res
end

-- Constructs a table from an DOM node containing a further nested element, the english language name.
function make_nested(node)
	local res = T{}
	
	for _, val in ipairs(node.children) do
		if val.type == 'attribute' then
			res[val['name']] = val['value']
		else
			res['en'] = value
		end
	end
	
	return res
end


return resources.

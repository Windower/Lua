require('tables')
require('lists')
local files = require('files')
local xml = require('xml-fixed')
local Settings = {}

-- Ripped from xml module for dom creation
local dom = T{}
function dom.new(t)
	return T{
		type = '',
		name = '',
		namespace = nil,
		value = nil,
		children = L{},
		cdata = nil
	}:update(t)
end

-- Loads a file and returns a settings object
function Settings:load(file)
	if type(file) == "string" then
		file = files.new(file, true)
	end
	
	local obj = {
		_file = file,
		_doc = nil,
		_data = {}
	}

	setmetatable(obj, self)
	self.__index = function(t, k)
		if t._data[k] ~= nil then
			return t._data[k]
		end
		return self[k]
	end
	obj:reload()
	return obj
end

-- Converts attributes and a directly attached text node to a table
function getChildrenTable(node)
	local dict = T{}
	if (node and type(node.children) == "table") then
		for k, item in ipairs(node.children) do
			if item.type == "attribute" then
				dict[item.name] = item.value
			elseif item.type == "text" then
				dict.value = item.value
			end
		end
	end
	return dict
end

-- Converts attributes to a table
function getAttributeTable(node)
	local dict = T{}
	if (node and type(node.children) == "table") then
		for k, item in ipairs(node.children) do
			if (item.type == "attribute") then
				dict[item.name] = item.value
			end
		end
	end
	return dict
end

-- Converts \x## sequences into byte characters
function unescapeHex(text)
	return string.gsub(text, "\\x%x%x", function(token)
		local num = tonumber(string.sub(token, 3), 16)
		if num ~= nil then
			return string.char(num)
		end
		return token
	end)
end

-- Converts binary data into \x## sequences
function escapeHex(text)
	return string.gsub(text, "[^%w%s%p]", function(token)
		return "\\x" .. string.format("%x", string.byte(token))
	end)
end

-- Gets an attribute node by name
function getAttribute(node, key)
	local k, attr = node.children:find(function(el)
		return type(el) == "table" and el.type == "attribute" and el.name == key
	end)
	return attr
end

-- Reloads the source file
function Settings:reload() 
	self._doc = xml.read(self._file)
	self:parse()
end

-- Parses the source dom into usable tables
function Settings:parse()
	local data = {
		settings = {},
		triggers = L{},
		filters = L{},
	}
	if (self._doc.name == "ChatMon") then
		for key, value in ipairs(self._doc.children) do
			if (value.type == "tag") then
				if (value.name == "settings") then
					data.settings = getAttributeTable(value)
				elseif (value.name == "trigger") then
					data.triggers:append(getAttributeTable(value))
				elseif (value.name == "filter") then
					-- Unescape hex sequences in the parsed version
					local t = getChildrenTable(value)
					t.value = unescapeHex(t.value)
					data.filters:append(t)
				end
			end
		end
	end
	self._data = data
end

-- Saves the dom back to the file
function Settings:save()
	local xmltext = xml.realize(self._doc)
	self._file:write(xmltext)
end

-- Modifies a dom node attribute
function modifyAttribute(node, key, value)
	local update = false
	local attr = getAttribute(node, key)
	if (attr) then
		-- Attribute exists
		if (value == nil) then
			-- If the value is nil, then remove the entry entirely
			node.children:delete(attr)
			update = true
		elseif value ~= attr.value then
			-- Update the existing value, if the value is actually changing
			attr.value = value
			update = true
		end
	elseif value ~= nil then
		-- Setting does not exist. If a value is being provided, then create a new attribute and append it
		node.children:append(dom.new({
			type = 'attribute',
			name = key,
			namespace = node.namespace,
			value = value
		}))
		update = true
	end
	return update
end

-- Modifies a dom text node
function modifyText(node, value)
	local update = false
	local k, child = node.children:find(function(el)
		return type(el) == "table" and el.type == "text"
	end)
	if (child) then
		-- Attribute exists
		if (value == nil) then
			-- If the value is nil, then remove the entry entirely
			node.children:delete(child)
			update = true
		elseif value ~= child.value then
			-- Update the existing value, if the value is actually changing
			child.value = value
			update = true
		end
	elseif value ~= nil then
		-- Setting does not exist. If a value is being provided, then create a new attribute and append it
		node.children:append(dom.new({
			type = 'text',
			namespace = node.namespace,
			value = value
		}))
		update = true
	end
	return update
end

-- Add, update, or deletes entries in the settings collection
function Settings:changeSetting(key, value)
	local update = false
	local mk, node = self._doc.children:find(function(el)
		return type(el) == "table" and el.name == "settings" 
	end)

	-- If the settings block is missing then add a new one
	if not node then
		node = dom.new({
			type = 'tag',
			name = "settings",
			namespace = self._doc.namespace,
		})
		self._doc.children:append(node)
	end

	-- Update the attribute list
	if modifyAttribute(node, key, value) then
		-- Flush if there was a change
		self:parse()
		self:save()
		return true
	end
	return false
end

-- Adds a trigger configuration
function Settings:addTrigger(trigger)
	if type(trigger) ~= "table" or not trigger.match or not trigger.sound then
		return false
	end

	local node = dom.new({
		type = "tag",
		name = "trigger",
		namespace = self._doc.namespace,
	})
	for name, value in pairs(trigger) do
		modifyAttribute(node, name, value)
	end

	self._doc.children:append(node)
	self:parse()
	self:save()
	return true
end

-- Removes a trigger configuration by its position
function Settings:removeTriggerByIndex(index)
	local cnt = 0
	local removed = nil
	for key, value in ipairs(self._doc.children) do
		if (value.type == "tag" and value.name == "trigger") then
			cnt = cnt + 1
			if (cnt == index) then
				removed = self._doc.children[key]
				table.remove(self._doc.children, key)
			end
		end
	end
	if removed then
		self:parse()
		self:save()
	end
	return removed
end

-- Removes one or more triggers based on a search pattern
function Settings:removeTriggerByPattern(pattern)
	local removed = L{}
	local updated = false

	for key=#self._doc.children, 1, -1 do
		local value = self._doc.children[key]
		if (value.type == "tag" and value.name == "trigger") then
			local attr = getAttributeTable(value)
			if windower.wc_match(attr.match, pattern) then
				removed:insert(1, value)
				self._doc.children:remove(key)
				updated = true
			end
		end
	end
	if updated then
		self:parse()
		self:save()
	end
	return removed
end

-- Adds a chat filter configuration
function Settings:addFilter(filter)
	if type(filter) ~= "table" or not filter.value then
		return false
	end

	local node = dom.new({
		type = "tag",
		name = "filter",
		namespace = self._doc.namespace,
	})
	if filter.mode then
		modifyAttribute(node, "mode", filter.mode)
	end
	if filter.from then
		modifyAttribute(node, "from", filter.from)
	end
	modifyText(node, filter.value)
	
	self._doc.children:append(node)
	self:parse()
	self:save()
	return true
end

-- Removes a chat filter configuration by its position
function Settings:removeFilterByIndex(index)
	local cnt = 0
	local removed = nil
	for key, value in ipairs(self._doc.children) do
		if (value.type == "tag" and value.name == "filter") then
			cnt = cnt + 1
			if (cnt == index) then
				removed = self._doc.children[key]
				table.remove(self._doc.children, key)
			end
		end
	end
	if removed then
		self:parse()
		self:save()
	end
	return removed
end

-- Removes one or more chat filters based on a search pattern
function Settings:removeFilterByPattern(pattern)
	local removed = L{}
	local updated = false

	for key=#self._doc.children, 1, -1 do
		local value = self._doc.children[key]
		if (value.type == "tag" and value.name == "filter") then
			local dict = getChildrenTable(value)
			if windower.wc_match(dict.value, pattern) then
				removed:insert(1, value)
				self._doc.children:remove(key)
				updated = true
			end
		end
	end
	if updated then
		self:parse()
		self:save()
	end
	return removed
end

return Settings
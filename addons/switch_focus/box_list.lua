local box_list = {
    _ordered = {},
    _by_value = {},

    len = function(self)
        return #self._ordered
    end,

    add = function(self, value)
        if self._by_value[value] then
            return
        end

        table.insert(self._ordered, value)
        table.sort(self._ordered)

        self._by_value = {}
        for k, v in ipairs(self._ordered) do
            self._by_value[v] = k
        end
    end,

    remove = function(self, value)
        local index = self._by_value[value]
        if index == nil then
            return
        end

        table.remove(self._ordered, index)

        self._by_value = {}
        for k, v in ipairs(self._ordered) do
            self._by_value[v] = k
        end
    end,

    get_index_of = function(self, value)
        return self._by_value[value]
    end
}
local meta = {
    __index = function(t,k)
        return t._ordered[k]
    end,
}
setmetatable(box_list, meta)
return box_list

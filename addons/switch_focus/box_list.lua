local box_list = {
    _orderd = {},
    _byValue = {},

    len = function(self)
        return #self._orderd
    end,

    add = function(self, value)
        if self._byValue[value] then
            return
        end

        table.insert(self._orderd, value)
        table.sort(self._orderd)

        self._byValue = {}
        for k, v in ipairs(self._orderd) do
            self._byValue[v] = k
        end
    end,

    remove = function(self, value)
        local index = self._byValue[value]
        if index == nil then
            return
        end

        table.remove(self._orderd, index)

        self._byValue = {}
        for k, v in ipairs(self._orderd) do
            self._byValue[v] = k
        end
    end,

    get_index_of = function(self, value)
        if self._byValue[value] then
            return self._byValue[value]
        end
    end
}
local meta = {
    __index = function(t,k)
        if t._orderd[k] then
            return t._orderd[k]
        end
    end,
}
setmetatable(box_list, meta)
return box_list
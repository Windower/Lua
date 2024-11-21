local trigger_class = require('trigger_class')
local get_triggers = {}

function get_triggers.by_name(name)
    local player_path = windower.addon_path .. "/data/triggers/" .. name .. ".lua"
    local triggers_loader
    if windower.file_exists(player_path) then
        print('ChatMon: Loading /triggers/' .. name .. '.lua')
        triggers_loader = loadfile(player_path)
    else
        print('ChatMon: Loading global triggers ')
        triggers_loader = loadfile(windower.addon_path .. "/data/triggers/global.lua")
    end

    local triggers = triggers_loader and triggers_loader()
    for key, value in pairs(triggers) do
        triggers[key] = trigger_class:new(value)
    end

    return triggers
end

return get_triggers

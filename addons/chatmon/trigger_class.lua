local trigger_class = {}
local meta = {__index = trigger_class}

local function get_match(match)
    if match ~= '<name>' then
        return match
    end

    -- this is done to have parity with the old plugin.
    local player_name = windower.ffxi.get_player().name:lower()
    return '* ' .. player_name .. '|'
                .. player_name .. ' *|*\''
                .. player_name .. '\'*|*('
                .. player_name .. ')*|'
                .. player_name .. '|* '
                .. player_name .. ' *|* '
                .. player_name .. '? *|* '
                .. player_name .. '?|'
                .. player_name .. '? *|'
                .. player_name .. '?|*<'
                .. player_name .. '>*'
end

local field_checkers = {}
function field_checkers.from(trigger, event)
    return trigger.from:contains(event.from)
end

function field_checkers.notFrom(trigger, event)
    return not trigger.notFrom:contains(event.from)
end

function field_checkers.match(trigger, event)
    local match = get_match(trigger.match)
    return windower.wc_match(event.text, match)
end

function field_checkers.notMatch(trigger, event)
    local match = get_match(trigger.notMatch)
    return not windower.wc_match(event.text, match)
end

function field_checkers.sender(trigger, event)
    return windower.wc_match(event.sender, trigger.sender)
end

function field_checkers.notSender(trigger, event)
    return windower.wc_match(event.sender, trigger.notSender)
end

function trigger_class:check(event)
    for k in pairs(self) do
        if field_checkers[k] and not field_checkers[k](self, event) then
            return false
        end
    end

    return true
end

function trigger_class:new(o)
    setmetatable(o, meta)
    return o
end

return trigger_class

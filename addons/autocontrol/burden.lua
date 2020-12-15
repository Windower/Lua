local set = require("sets")
local packets = require("packets")

local o = {
    fire = 0,
    earth = 0,
    water = 0,
    wind = 0,
    ice = 0,
    thunder = 0,
    light = 0,
    dark = 0,
}
local burden = {}
local mt = {
    __index = burden
}
setmetatable(o, mt)
local updaters = {}
local heatsink

windower.register_event('incoming chunk',function(id,org,modi,is_injected,is_blocked)
    if id == 0x044 then
        local attachments = windower.ffxi.get_mjob_data().attachments
        if attachments then
            for _, id in pairs(attachments) do
                heatsink = (id == 8610)
                if heatsink then
                    break
                end
            end
        end
    end
end)

local thresholdModifiers =
{
    [11101] = 40, -- Cirque Farsetto +2
    [11201] = 20, -- Cirque Farsetto +1
    [14930] = 5,  -- Pup. Dastanas
    [15030] = 5,  -- Pup. Dastanas +1
    [16281] = 5,  -- Buffoon's Collar
    [16282] = 5,  -- Buffoon's Collar +1
    [20520] = 40, -- Midnights
    [26263] = 10, -- Visucius's Mantle
    [26932] = 40, -- Kara. Farsetto
    [26933] = 40, -- Kara. Farsetto +1
    [27960] = 5,  -- Foire Dastanas
    [27981] = 5,  -- Foire Dastanas +1
    [28634] = 5,  -- Dispersal Mantle
}
burden.threshold = 30

local pet_actions = 
{
    [136] = "activate",
    [139] = "deactivate",
    [141] = "fire",
    [142] = "ice",
    [143] = "wind",
    [144] = "earth",
    [145] = "thunder",
    [146] = "water",
    [147] = "light",
    [148] = "dark",
    [309] = "cooldown",
    [310] = "deus_ex_automata",
}
function burden:update(action)
    updaters[action](self)
end

function burden:zone()
    for k in pairs(self) do
        self[k] = 15
    end
end

function burden.set_decay_event(func)
    burden.decay_event = func
end
function updaters.deactivate(self)
    for k in pairs(self) do
        self[k] = 0
    end
end

function updaters.activate(self)
    for _, id in pairs(windower.ffxi.get_mjob_data().attachments) do
        heatsink = (id == 8610)
        if heatsink then
            break
        end
    end
    burden.update_decay_rate()
    for k in pairs(self) do
        self[k] = 15
    end
end
updaters.deus_ex_automata = updaters.activate

function updaters.cooldown(self)
    for k in pairs(self) do
        self[k] = self[k] / 2
    end
end

function updaters.maneuver(self, type)
    self[type] = self[type] + 15
    local inventory = windower.ffxi.get_items()
    local equipment = {
        sub = {},
        ammo = {},
        main = {},
        head = {},
        body = {},
        back = {},
        legs = {},
        feet = {},
        neck = {},
        hands = {},
        range = {},
        waist = {},
        left_ear = {},
        left_ring = {},
        right_ear = {},
        right_ring = {},
    }
    for k, v in pairs(inventory.equipment) do
        equipment[string.gsub(k ,"_bag","")][k] = v
    end
    burden.threshold = 30
    for k, v in pairs(equipment) do
        item = windower.ffxi.get_items(v[k .. "_bag"], v[k])
        if thresholdModifiers[item.id] then
            burden.threshold = burden.threshold + thresholdModifiers[item.id]
        end
    end
end

function updaters.ice(self) updaters.maneuver(self, "ice") end
function updaters.fire(self) updaters.maneuver(self, "fire") end
function updaters.wind(self) updaters.maneuver(self, "wind") end
function updaters.dark(self) updaters.maneuver(self, "dark") end
function updaters.earth(self) updaters.maneuver(self, "earth") end
function updaters.water(self) updaters.maneuver(self, "water") end
function updaters.light(self) updaters.maneuver(self, "light") end
function updaters.thunder(self) updaters.maneuver(self, "thunder") end

burden.decay_rate = 1
function burden.decay()
    for k in pairs(o) do
        if o[k] > burden.decay_rate then
            o[k] = o[k] - burden.decay_rate
        elseif o[k] > 0 then
            o[k] = 0
        end
    end
    if burden.decay_event then
        burden.decay_event()
    end
    coroutine.schedule(burden.decay, 3)
end
coroutine.schedule(burden.decay, os.date("*t").sec % 3)

local count_to_decay_rate = {
    [0] = 2,
    [1] = 4,
    [2] = 5,
    [3] = 6,
}
function burden.update_decay_rate()
    if heatsink then
        local count = 0
        for _, v in pairs(windower.ffxi.get_player().buffs) do
            if v == 305 then
                count = count + 1
            end
        end
        burden.decay_rate = count_to_decay_rate[count];
    else
        burden.decay_rate = 1
    end
end

return o

_addon.name = 'TParty'
_addon.author = 'Arcon (originally by Cliff)'
_addon.version = '1.0.0.0'

require('sets')
require('functions')
texts = require('texts')

hpp = texts.new('${hpp}', {
    pos = {
        x = -128,
    },
    bg = {
        visible = false,
    },
    flags = {
        right = true,
        bottom = true,
        bold = true,
        draggable = false,
        italic = true,
    },
    text = {
        size = 10,
        alpha = 185,
        red = 115,
        green = 166,
        blue = 213,
    },
})

y_pos = {}
for i = 1, 6 do
    y_pos[i] = -51 - 20*i
end

debug.setmetatable(nil, {__index = {}, __call = functions.empty})

party_keys = S{'p0', 'p1', 'p2', 'p3', 'p4', 'p5'}

windower.register_event('prerender', function()
    local index = windower.ffxi.get_player().target_index
    if index then
        hpp:update(windower.ffxi.get_mob_by_index(index))
        hpp:pos_y(y_pos[(party_keys * table.keyset(windower.ffxi.get_party())):length()])
        hpp:show()
    else
        hpp:hide()
    end
end)

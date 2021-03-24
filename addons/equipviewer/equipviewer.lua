_addon.name = 'EquipViewer'
_addon.version = '3.2.4'
_addon.author = 'Project Tako, Rubenator'
_addon.commands = { 'equipviewer', 'ev' }

require('luau')
local bit = require('bit')
local config = require('config')
local images = require('images')
local texts = require('texts')
local functions = require('functions')
local packets = require('packets')
local icon_extractor = require('icon_extractor')
--icon_extractor.ffxi_path('C:/Program Files (x86)/PlayOnline/SquareEnix/FINAL FANTASY XI')
require('ui_settings')

local equipment_data = {
    [0] =  {slot_name = 'main',       slot_id = 0,  display_pos = 0,  item_id = 0, image = nil},
    [1] =  {slot_name = 'sub',        slot_id = 1,  display_pos = 1,  item_id = 0, image = nil},
    [2] =  {slot_name = 'range',      slot_id = 2,  display_pos = 2,  item_id = 0, image = nil},
    [3] =  {slot_name = 'ammo',       slot_id = 3,  display_pos = 3,  item_id = 0, image = nil},
    [4] =  {slot_name = 'head',       slot_id = 4,  display_pos = 4,  item_id = 0, image = nil},
    [5] =  {slot_name = 'body',       slot_id = 5,  display_pos = 8,  item_id = 0, image = nil},
    [6] =  {slot_name = 'hands',      slot_id = 6,  display_pos = 9,  item_id = 0, image = nil},
    [7] =  {slot_name = 'legs',       slot_id = 7,  display_pos = 14, item_id = 0, image = nil},
    [8] =  {slot_name = 'feet',       slot_id = 8,  display_pos = 15, item_id = 0, image = nil},
    [9] =  {slot_name = 'neck',       slot_id = 9,  display_pos = 5,  item_id = 0, image = nil},
    [10] = {slot_name = 'waist',      slot_id = 10, display_pos = 13, item_id = 0, image = nil},
    [11] = {slot_name = 'left_ear',   slot_id = 11, display_pos = 6,  item_id = 0, image = nil},
    [12] = {slot_name = 'right_ear',  slot_id = 12, display_pos = 7,  item_id = 0, image = nil},
    [13] = {slot_name = 'left_ring',  slot_id = 13, display_pos = 10, item_id = 0, image = nil},
    [14] = {slot_name = 'right_ring', slot_id = 14, display_pos = 11, item_id = 0, image = nil},
    [15] = {slot_name = 'back',       slot_id = 15, display_pos = 12, item_id = 0, image = nil},
}
local encumbrance_data = {}
for i=0,15 do
    encumbrance_data[i] = { slot_name = 'encumbrance', slot_id = i, display_pos = equipment_data[i].display_pos, image = nil }
end
local ammo_count_text = nil
local bg_image = nil

local defaults = T{
    pos = T{
        x = 500,
        y = 500
    },
    size = 32,
    alpha = 230,
    show_encumbrance = true,
    show_ammo_count = true,
    hide_on_zone = true,
    hide_on_cutscene = true,
    left_justify = false,
}
settings = nil
local last_encumbrance_bitfield = 0

-- gets the currently equipped item data for the slot information provided
local function get_equipped_item(slotName, slotId, bag, index)
    if not bag or not index then -- from memory
        local equipment = windower.ffxi.get_items().equipment
        bag = equipment[string.format('%s_bag', slotName)]
        index = equipment[slotName]
        if equipment_data[slotId] then
            equipment_data[slotId].bag_id = bag
            equipment_data[slotId].index = index
        end
    end
    if index == 0 then -- empty equipment slot
        return 0, 0
    end
    local item_data = windower.ffxi.get_items(bag, index)
    return item_data.id, item_data.count
end

-- desc: Updates the ui object(s) for the given slot
local function update_equipment_slot(source, slot, bag, index, item, count)
    local slot_data = equipment_data[slot]
    slot_data.bag_id = bag or slot_data.bag_id
    slot_data.index = index or slot_data.index
    if not item then
        item, count = get_equipped_item(slot_data.slot_name, slot_data.slot_id, bag, index)
    end
    if evdebug then
        bag = slot_data.bag_id
        index = slot_data.index
        log("%s %s %d %d %d":format(source, slot_data.slot_name, item, bag or -1, index or -1))
        print("%s %s %d %d %d":format(source, slot_data.slot_name, item, bag or -1, index or -1))
    end
    if slot_data.slot_name  == 'ammo' then
        slot_data.count = count or slot_data.count or 0
    end
    if slot_data.image and item ~= nil then
        if item == 0 or item == 65535 then -- empty slot
            slot_data.image:hide()
            slot_data.image:clear()
            slot_data.item_id = 0
            slot_data.count = nil
            slot_data.image:update()
        elseif slot_data.item_id ~= item then
            slot_data.item_id = item
            local icon_path = string.format('%sicons/%s.bmp', windower.addon_path, slot_data.item_id)

            if not windower.file_exists(icon_path) then
                icon_extractor.item_by_id(slot_data.item_id, icon_path)
            end
            if windower.file_exists(icon_path) then
                slot_data.image:path(icon_path)
                slot_data.image:alpha(settings.alpha)
                slot_data.image:show()
            end
        end
        if slot_data.slot_name == 'ammo' then
            display_ammo_count(slot_data.count)
        end
        slot_data.image:update()
    end
end

-- Updates the texture for all slots if it's a different piece of equipment
local function update_equipment_slots(source)
    for slot in pairs(equipment_data) do
        update_equipment_slot(source, slot)
    end
end

-- Sets up the image and text ui objects for our equipment
local function setup_ui()
    refresh_ui_settings()
    destroy()
    
    bg_image = images.new(bg_image_settings)
    bg_image:show()

    for key, slot in pairs(equipment_data) do
        slot.item_id = 0
        slot.image = images.new(equipment_image_settings)
        position(slot)
    end
    update_equipment_slots("setup_ui")

    for key, slot in pairs(encumbrance_data) do
        slot.image = images.new(encumbrance_image_settings)
        slot.image:path(windower.addon_path..'encumbrance.png')
        slot.image:hide()
        position(slot)
    end
    display_encumbrance()

    ammo_count_text = texts.new(settings.left_justify and ammo_count_text_settings_left_justify or ammo_count_text_settings)
    display_ammo_count()
end

-- Called when the addon is first loaded.
windower.register_event('load', function()
    if settings then
        config.reload(settings)
    else
        settings = config.load(defaults)
    end
    --Make sure icons directory exists
    if not windower.dir_exists(string.format('%sicons', windower.addon_path)) then
        windower.create_dir(string.format('%sicons', windower.addon_path))
    end

    if windower.ffxi.get_info().logged_in then
        setup_ui()
    end
end)

-- Called whenever character logs out.
windower.register_event('logout', function()
    clear_all_equipment_slots()
    destroy()
end)

-- Called whenever character logs in.
windower.register_event('login', function()
    if settings then
        config.reload(settings)
    else
        settings = config.load(defaults)
    end
    setup_ui()
    update_equipment_slots('login')
end)

-- Called when our addon receives an incoming chunk.
windower.register_event('incoming chunk', function(id, original, modified, injected, blocked)
    if id == 0x050 then --Equip/Unequip
        local packet = packets.parse('incoming', original)
        local index = packet['Inventory Index']
        local slot = packet['Equipment Slot']
        local bag = packet['Inventory Bag']
        equipment_data[slot].bag_id = bag
        equipment_data[slot].index = index
        update_equipment_slot:schedule(0, '0x050', slot, bag, index)
    elseif id == 0x020 or id == 0x01F or id == 0x01E then --Item Update / Item Assign (ammo consumption) / 0x01E item count/last ammo shot
        local packet = packets.parse('incoming', original)
        local bag = packet['Bag']
        local index = packet['Index']

        local slot = nil
        for _,slot_data in pairs(equipment_data) do
            if slot_data.bag_id == bag and slot_data.index == index then
                slot = slot_data.slot_id
                break
            end
        end
        
        if slot then
            if packet['Status'] ~= 5 then --item not equipped
                update_equipment_slot:schedule(0, "0x%x":format(id), slot, 0, 0, 0)
                return
            end
            if slot == 3 then --ammo
                local count = packet['Count'] or 0
                display_ammo_count(count)
            end
            local item = packet['Item']
            update_equipment_slot:schedule(0,"0x%x":format(id), slot, bag, index, item, count)
        end
    elseif id == 0x01B then -- Job Info (Encumbrance Flags)
        local packet = packets.parse('incoming', original)
        display_encumbrance(packet['Encumbrance Flags'])
    elseif id == 0x0A then -- Finish Zone
        show()
    elseif id == 0x0B then -- Zone
        if settings.hide_on_zone then
            hide()
        end
    end
end)

-- Called when our addon receives an outgoing chunk.
windower.register_event('outgoing chunk', function(id, original, modified, injected, blocked)
    if id == 0x100 then -- Job Change Request
        clear_all_equipment_slots()
    end
end)


-- Destroys all created ui objects
function destroy()
    if bg_image then
        bg_image:destroy()
        bg_image = nil
    end
    for key, slot_data in pairs(equipment_data) do
        if slot_data.image ~= nil then
            slot_data.image:destroy()
            slot_data.image = nil
        end
    end
    for key, slot_data in pairs(encumbrance_data) do
        if slot_data.image ~= nil then
            slot_data.image:destroy()
            slot_data.image = nil
        end
    end
    if ammo_count_text then
        ammo_count_text:destroy()
        ammo_count_text = nil
    end
end

-- Shows appropriate ui objects
function show()
    if bg_image then
        bg_image:show()
    end
    for key, slot_data in pairs(equipment_data) do
        if slot_data.item_id ~= 0 and slot_data.image then
            slot_data.image:show()
        end
    end
    display_encumbrance()
    display_ammo_count()
end

-- Hides all ui objects
function hide()
    if bg_image then
        bg_image:hide()
    end
    for key, slot_data in pairs(equipment_data) do
        if slot_data.image then
            slot_data.image:hide()
        end
    end
    for key, slot_data in pairs(encumbrance_data) do
        if slot_data.image then
            slot_data.image:hide()
        end
    end
    if ammo_count_text then
        ammo_count_text:hide()
    end
end

-- Moves ui object to correct spot based on 'display_pos' field
function position(slot)
    local pos_x = settings.pos.x + ((slot.display_pos % 4) * settings.size)
    local pos_y = settings.pos.y + (math.floor(slot.display_pos / 4) * settings.size)
    slot.image:pos(pos_x, pos_y)
end

-- Clears all equipment slot data and hides ui object
function clear_slot(slot)
    local slot_data = equipment_data[slot]
    slot_data.image:hide()
    slot_data.image:clear()
    slot_data.item_id = 0
    slot_data.bag_id = nil
    slot_data.index = nil
    slot_data.count = nil
    slot_data.image:update()

    display_ammo_count()
end

-- Clears all equipment slot data and hides equipment slot ui objects
function clear_all_equipment_slots()
    for slot in pairs(equipment_data) do
        clear_slot(slot)
    end
end

-- Shows and hides appropriate encumbrance ui objects and possibly updates encumbrance
-- flags based on provided bitfield number
function display_encumbrance(bitfield)
    bitfield = bitfield or last_encumbrance_bitfield
    last_encumbrance_bitfield = bitfield
    for key, slot in pairs(encumbrance_data) do
        if slot.image then
            if not settings.show_encumbrance or bit.band(bitfield, bit.lshift(1,key)) == 0 then
                slot.image:hide()
            else
                slot.image:show()
            end
        end
    end
end

-- Displays appropriatly and possibly updates ammo count and ui object
function display_ammo_count(count)
    if not ammo_count_text then return end
    count = count or equipment_data[3] and equipment_data[3].count -- 3 == Ammo
    equipment_data[3].count = count
    if not settings.show_ammo_count or  not count or count <= 1 then
        ammo_count_text:hide()
    else
        ammo_count_text:text(count and tostring(count) or "")
        ammo_count_text:show()
    end
end

-- Called when player status changes.
windower.register_event('status change', function(new_status_id)
    if new_status_id == 4 and settings.hide_on_cutscene then --Cutscene/Menu
        hide()
    else
        show()
    end
end)

-- Called when our addon is unloaded.
windower.register_event('unload', function()
    destroy()
end)

-- Called when the addon receives a command.
windower.register_event('addon command', function (...)
    config.reload(settings)
    coroutine.sleep(0.5)
    local cmd  = (...) and (...):lower() or ""
    local cmd_args = {select(2, ...)}

    if cmd == 'position' or cmd == 'pos' then
        if #cmd_args < 2 then
            error("Not enough arguments.")
            log("Current position: "..settings.pos.x.." "..settings.pos.y)
            return
        end

        settings.pos.x = tonumber(cmd_args[1])
        settings.pos.y = tonumber(cmd_args[2])
        config.save(settings)
        
        setup_ui()

        log('Position changed to '..settings.pos.x..', '..settings.pos.y)
    elseif cmd == 'size' then
        if #cmd_args < 1 then
            error("Not enough arguments.")
            log("Current size: "..settings.size)
            return
        end

        settings.size = tonumber(cmd_args[1])
        config.save(settings)

        setup_ui()

        log('Size changed to '..settings.size)
    elseif cmd == 'scale' then
        if #cmd_args < 1 then
            error("Not enough arguments.")
            log("Current scale: "..settings.size/32)
            return
        end
        local size = tonumber(cmd_args[1])*32
        if size > 100 then
            error('Size too large')
        end
        settings.size = size
        config.save(settings)

        setup_ui()

        log('Size changed to '..settings.size)
    elseif cmd == 'alpha' or cmd == "opacity" then
        if #cmd_args < 1 then
            error("Not enough arguments.")
            log("Current alpha/opacity: "..settings.alpha.."/255 = "..settings.alpha/255)
            return
        end
        local alpha = tonumber(cmd_args[1])
        if alpha <= 1 and alpha > 0 then
            settings.alpha = math.floor(255 * (alpha))
        else
            settings.alpha = math.floor(alpha)
        end
        config.save(settings)

        setup_ui()

        log('Alpha/Opacity changed to '..settings.alpha..'/255')
    elseif cmd:contains('transpar') then
        if #cmd_args < 1 then
            error("Not enough arguments.")
            log("Current transparency: "..(255-settings.alpha).."/255 = "..(255-settings.alpha)/255)
            return
        end
        local transparency = tonumber(cmd_args[1])
        if transparency <= 1 and transparency > 0 then
            settings.alpha = math.floor(255 * (1-transparency))
        else
            settings.alpha = math.floor(255-transparency)
        end
        config.save(settings)

        setup_ui()

        log('Transparency changed to '..255-settings.alpha..'/255')
    elseif cmd:contains('encumb') then
        settings.show_encumbrance = not settings.show_encumbrance
        config.save(settings)

        display_encumbrance()

        log('show_encumbrance changed to '..tostring(settings.show_encumbrance))
    elseif cmd:contains('ammo') or cmd:contains('count') then
        settings.show_ammo_count = not settings.show_ammo_count
        config.save(settings)

        display_ammo_count()

        log('show_ammo_count changed to '..tostring(settings.show_ammo_count))
    elseif cmd == 'hideonzone' or cmd == 'zone' then
        settings.hide_on_zone = not settings.hide_on_zone
        config.save(settings)

        log('hide_on_zone changed to '..tostring(settings.hide_on_zone))
    elseif cmd == 'hideoncutscene' or cmd == 'cutscene' then
        settings.hide_on_cutscene = not settings.hide_on_cutscene
        config.save(settings)

        log('hide_on_cutscene changed to '..tostring(settings.hide_on_cutscene))
    elseif cmd == 'justify' then
        settings.left_justify = not settings.left_justify
        config.save(settings)

        setup_ui()

        log('Ammo text justification changed to '..tostring(settings.left_justify and "Left" or "Right"))
    elseif cmd == "testenc" then
        display_encumbrance(0xffff)
    elseif cmd == "debug" then
        if #cmd_args < 1 then
            local items = windower.ffxi.get_items()
            local e = windower.ffxi.get_items().equipment
            for i=0,15 do
                local v = equipment_data[i]
                local b = e[string.format('%s_bag', v.slot_name)]
                local eb = v.bag_id
                local ind = v.index
                local eind = e[v.slot_name]
                local it = v.item_id
                local eit = windower.ffxi.get_items(eb, eind).id
                log("%s[%d] it=%d eit=%d b=%d eb=%d i=%d ei=%d":format(v.slot_name,i, it, eit, b, eb, ind, eind))
            end
        elseif S{"1", "on", "true"}:contains(cmd_args[1]) then
            evdebug = true
        elseif S{"0", "off", "false"}:contains(cmd_args[1]) then
            evdebug = false
        end
    else
        log("HELP:")
        log("ev position <xpos> <ypos>: move to position (from top left)")
        log("ev size <pixels>: set pixel size of each item slot")
        log("ev scale <factor>: scale multiplier each item slot (from 32px)")
        log("ev alpha <opacity>: set opacity of display (out of 255)")
        log("ev transparency <transparency>: inverse of alpha (out of 255)")
        log("ev ammocount: toggles showing current ammo count")
        log("ev encumbrance: toggles showing encumbrance Xs")
        log("ev hideonzone: toggles hiding while crossing zone line")
        log("ev hideoncutscene: toggles hiding when in cutscene/npc menu/etc")
        log("ev justify: toggles between ammo text left and right justify")
    end
end)

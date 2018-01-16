--[[    BSD License Disclaimer
        Copyright © 2017, sylandro
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of invtracker nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL sylandro BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'invtracker'
_addon.author = 'sylandro'
_addon.version = '1.0.0'
_addon.language = 'English'

config = require('config')
images = require('images')
texts = require('texts')

hideKey = 70
is_hidden_by_cutscene = false
is_hidden_by_key = false

defaults = {}
defaults.HideKey = 70
defaults.SlotImage = {}
defaults.SlotImage.spacing = 4
defaults.SlotImage.blockSpacing = 4
defaults.SlotImage.visible = true
defaults.SlotImage.pos = {}
defaults.SlotImage.pos.x = -360
defaults.SlotImage.pos.y = -50
defaults.SlotImage.equipment = {}
defaults.SlotImage.equipment.visible = true
defaults.SlotImage.equipment.maxColumns = 4
defaults.SlotImage.inventory = {}
defaults.SlotImage.inventory.visible = true
defaults.SlotImage.inventory.maxColumns = 5
defaults.SlotImage.mogSafe = {}
defaults.SlotImage.mogSafe.visible = false
defaults.SlotImage.mogSafe.maxColumns = 5
defaults.SlotImage.mogStorage = {}
defaults.SlotImage.mogStorage.visible = false
defaults.SlotImage.mogStorage.maxColumns = 5
defaults.SlotImage.mogLocker = {}
defaults.SlotImage.mogLocker.visible = false
defaults.SlotImage.mogLocker.maxColumns = 5
defaults.SlotImage.mogSatchel = {}
defaults.SlotImage.mogSatchel.visible = true
defaults.SlotImage.mogSatchel.maxColumns = 5
defaults.SlotImage.mogSack = {}
defaults.SlotImage.mogSack.visible = true
defaults.SlotImage.mogSack.maxColumns = 5
defaults.SlotImage.mogCase = {}
defaults.SlotImage.mogCase.visible = true
defaults.SlotImage.mogCase.maxColumns = 5
defaults.SlotImage.mogWardrobe = {}
defaults.SlotImage.mogWardrobe.visible = false
defaults.SlotImage.mogWardrobe.maxColumns = 5
defaults.SlotImage.tempInventory = {}
defaults.SlotImage.tempInventory.visible = true
defaults.SlotImage.tempInventory.maxColumns = 1
defaults.SlotImage.status = {}
defaults.SlotImage.status.default = {}
defaults.SlotImage.status.default.color = {}
defaults.SlotImage.status.default.color.alpha = 255
defaults.SlotImage.status.default.color.red = 0
defaults.SlotImage.status.default.color.green = 170
defaults.SlotImage.status.default.color.blue = 170
defaults.SlotImage.status.default.background = {}
defaults.SlotImage.status.default.background.color = {}
defaults.SlotImage.status.default.background.color.alpha = 200
defaults.SlotImage.status.default.background.color.red = 0
defaults.SlotImage.status.default.background.color.green = 60
defaults.SlotImage.status.default.background.color.blue = 60
defaults.SlotImage.status.equipment = {}
defaults.SlotImage.status.equipment.color = {}
defaults.SlotImage.status.equipment.color.alpha = 255
defaults.SlotImage.status.equipment.color.red = 253
defaults.SlotImage.status.equipment.color.green = 252
defaults.SlotImage.status.equipment.color.blue = 250
defaults.SlotImage.status.equipment.background = {}
defaults.SlotImage.status.equipment.background.color = {}
defaults.SlotImage.status.equipment.background.color.alpha = 200
defaults.SlotImage.status.equipment.background.color.red = 50
defaults.SlotImage.status.equipment.background.color.green = 50
defaults.SlotImage.status.equipment.background.color.blue = 50
defaults.SlotImage.status.equipped = {}
defaults.SlotImage.status.equipped.color = {}
defaults.SlotImage.status.equipped.color.alpha = 255
defaults.SlotImage.status.equipped.color.red = 150
defaults.SlotImage.status.equipped.color.green = 255
defaults.SlotImage.status.equipped.color.blue = 150
defaults.SlotImage.status.equipped.background = {}
defaults.SlotImage.status.equipped.background.color = {}
defaults.SlotImage.status.equipped.background.color.alpha = 200
defaults.SlotImage.status.equipped.background.color.red = 0
defaults.SlotImage.status.equipped.background.color.green = 100
defaults.SlotImage.status.equipped.background.color.blue = 0
defaults.SlotImage.status.linkshell_equipped = {}
defaults.SlotImage.status.linkshell_equipped.color = {}
defaults.SlotImage.status.linkshell_equipped.color.alpha = 255
defaults.SlotImage.status.linkshell_equipped.color.red = 150
defaults.SlotImage.status.linkshell_equipped.color.green = 255
defaults.SlotImage.status.linkshell_equipped.color.blue = 150
defaults.SlotImage.status.linkshell_equipped.background = {}
defaults.SlotImage.status.linkshell_equipped.background.color = {}
defaults.SlotImage.status.linkshell_equipped.background.color.alpha = 200
defaults.SlotImage.status.linkshell_equipped.background.color.red = 0
defaults.SlotImage.status.linkshell_equipped.background.color.green = 100
defaults.SlotImage.status.linkshell_equipped.background.color.blue = 0
defaults.SlotImage.status.bazaar = {}
defaults.SlotImage.status.bazaar.color = {}
defaults.SlotImage.status.bazaar.color.alpha = 255
defaults.SlotImage.status.bazaar.color.red = 225
defaults.SlotImage.status.bazaar.color.green = 160
defaults.SlotImage.status.bazaar.color.blue = 30
defaults.SlotImage.status.bazaar.background = {}
defaults.SlotImage.status.bazaar.background.color = {}
defaults.SlotImage.status.bazaar.background.color.alpha = 200
defaults.SlotImage.status.bazaar.background.color.red = 100
defaults.SlotImage.status.bazaar.background.color.green = 100
defaults.SlotImage.status.bazaar.background.color.blue = 0
defaults.SlotImage.status.tempItem = {}
defaults.SlotImage.status.tempItem.color = {}
defaults.SlotImage.status.tempItem.color.alpha = 255
defaults.SlotImage.status.tempItem.color.red = 255
defaults.SlotImage.status.tempItem.color.green = 30
defaults.SlotImage.status.tempItem.color.blue = 30
defaults.SlotImage.status.tempItem.background = {}
defaults.SlotImage.status.tempItem.background.color = {}
defaults.SlotImage.status.tempItem.background.color.alpha = 200
defaults.SlotImage.status.tempItem.background.color.red = 100
defaults.SlotImage.status.tempItem.background.color.green = 0
defaults.SlotImage.status.tempItem.background.color.blue = 0
defaults.SlotImage.status.empty = {}
defaults.SlotImage.status.empty.color = {}
defaults.SlotImage.status.empty.color.alpha = 150
defaults.SlotImage.status.empty.color.red = 0
defaults.SlotImage.status.empty.color.green = 0
defaults.SlotImage.status.empty.color.blue = 0
defaults.SlotImage.status.empty.background = {}
defaults.SlotImage.status.empty.background.color = {}
defaults.SlotImage.status.empty.background.color.alpha = 150
defaults.SlotImage.status.empty.background.color.red = 0
defaults.SlotImage.status.empty.background.color.green = 0
defaults.SlotImage.status.empty.background.color.blue = 0

local settings = config.load(defaults)
config.save(settings)

settings.SlotImage.equipment.index = 1
settings.SlotImage.inventory.index = 2
settings.SlotImage.mogSafe.index = 3
settings.SlotImage.mogStorage.index = 4
settings.SlotImage.mogLocker.index = 5
settings.SlotImage.mogSatchel.index = 6
settings.SlotImage.mogSack.index = 7
settings.SlotImage.mogCase.index = 8
settings.SlotImage.mogWardrobe.index = 9
settings.SlotImage.tempInventory.index = 10
settings.SlotImage.box = {}
settings.SlotImage.box.texture = {}
settings.SlotImage.box.texture.path = windower.addon_path..'slot.png'
settings.SlotImage.box.texture.fit = true
settings.SlotImage.box.size = {}
settings.SlotImage.box.size.height = 2
settings.SlotImage.box.size.width = 2
settings.SlotImage.box.repeatable = {}
settings.SlotImage.box.repeatable.x = 1
settings.SlotImage.box.repeatable.y = 1
settings.SlotImage.background = {}
settings.SlotImage.background.texture = {}
settings.SlotImage.background.texture.path = windower.addon_path..'slot.png'
settings.SlotImage.background.texture.fit = true
settings.SlotImage.background.size = {}
settings.SlotImage.background.size.height = 3
settings.SlotImage.background.size.width = 3
settings.SlotImage.background.repeatable = {}
settings.SlotImage.background.repeatable.x = 1
settings.SlotImage.background.repeatable.y = 1

local yRes = windower.get_windower_settings().ui_y_res
local xRes = windower.get_windower_settings().ui_x_res
local xBase = settings.SlotImage.pos.x
local yBase = settings.SlotImage.pos.y
local current_block = 0
local current_slot = 1
local current_row = 1
local current_column = 1
local last_column = 1
local items = {}
local slot_images = {}
local update_time = 0

windower.register_event('load',function()
    if windower.ffxi.get_info().logged_in then
        initialize()
    end
end)

windower.register_event('login', function()
    initialize()
    update_time = os.time()
end)

windower.register_event('logout', function(...)
    hide()
    clear()
end)

windower.register_event('incoming chunk',function(id,org,modi,is_injected,is_blocked)
    if (os.time() - update_time > 30 and id == 0x50 or id == 0xE0 or id == 0x1D) then
      update()
    end
end)

windower.register_event('add item', function(...)
    if (os.time() - update_time > 30) then
        update()
    end
end)

windower.register_event('remove item', function(...)
    if (os.time() - update_time > 30) then
        update()
    end
end)

function initialize()
    hideKey = settings.HideKey
    update()
    show()
end

function update()
    current_block = 0
    last_column = 1
    items = windower.ffxi.get_items()
    update_equipment()
    update_items()
end

function update_equipment()
    if (settings.SlotImage.equipment.visible) then
        initialize_block()
        print_equipment(items.equipment.back)
        print_equipment(items.equipment.waist)
        print_equipment(items.equipment.legs)
        print_equipment(items.equipment.feet)
        print_equipment(items.equipment.body)
        print_equipment(items.equipment.hands)
        print_equipment(items.equipment.left_ring)
        print_equipment(items.equipment.right_ring)
        print_equipment(items.equipment.head)
        print_equipment(items.equipment.neck)
        print_equipment(items.equipment.left_ear)
        print_equipment(items.equipment.right_ear)
        print_equipment(items.equipment.main)
        print_equipment(items.equipment.sub)
        print_equipment(items.equipment.range)
        print_equipment(items.equipment.ammo)
    end
end

function update_items()
    update_bag(settings.SlotImage.inventory,items.inventory,items.max_inventory,items.enabled_inventory)
    update_bag(settings.SlotImage.mogSafe,items.safe,items.max_safe,items.enabled_safe)
    update_bag(settings.SlotImage.mogSafe,items.safe2,items.max_safe2,items.enabled_safe2)
    update_bag(settings.SlotImage.mogStorage,items.storage,items.max_storage,items.enabled_storage)
    update_bag(settings.SlotImage.mogLocker,items.locker,items.max_locker,items.enabled_locker)
    update_bag(settings.SlotImage.mogSatchel,items.satchel,items.max_satchel,items.enabled_satchel)
    update_bag(settings.SlotImage.mogSack,items.sack,items.max_sack,items.enabled_sack)
    update_bag(settings.SlotImage.mogCase,items.case,items.max_case,items.enabled_case)
    update_bag(settings.SlotImage.mogWardrobe,items.wardrobe,items.max_wardrobe,items.enabled_wardrobe)
    update_bag(settings.SlotImage.mogWardrobe,items.wardrobe2,items.max_wardrobe2,items.enabled_wardrobe2)
    update_bag(settings.SlotImage.mogWardrobe,items.wardrobe3,items.max_wardrobe3,items.enabled_wardrobe3)
    update_bag(settings.SlotImage.mogWardrobe,items.wardrobe4,items.max_wardrobe4,items.enabled_wardrobe4)
    update_temp_bag(settings.SlotImage.tempInventory,items.treasure,#items.treasure,items.enabled_treasure)
    --update_temp_bag(settings.SlotImage.tempInventory,items.temporary,items.max_temporary,items.enabled_temporary)
end

function update_bag(config, bag, max, enabled)
    if (config.visible and enabled) then
        initialize_block()
        print_bag(config, bag, max)
    end
end

function update_temp_bag(config, bag, max)
    if (config.visible and bag.enabled) then
        initialize_block()
        for key=1,max,1 do
            print_item(config,-1,max)
        end
    end
end

function initialize_block()
    current_block = current_block + 1
    if slot_images[current_block] == nil then
        slot_images[current_block] = {}
    end
    current_slot = 1
    current_row = 1
    current_column = 1
end

function print_equipment(status)
  if (status > 0) then
      print_slot(settings.SlotImage.status.equipment,settings.SlotImage.equipment.maxColumns,16)
  else
      print_slot(settings.SlotImage.status.empty,settings.SlotImage.equipment.maxColumns,16)
  end
end

function print_bag(config, bag, max)
    table.sort(bag, function(a,b)
        if (a.status ~= b.status) then
            return a.status > b.status
        end
        return a.count > b.count
    end)
    for key=1,max,1 do
      if (bag[key].count > 0) then
          print_item(config,bag[key].status,max)
      else
          print_slot(settings.SlotImage.status.empty,config.maxColumns,max)
      end
    end
end

function print_item(config, status, last_index)
    if (status == -1) then
        print_slot(settings.SlotImage.status.tempItem,config.maxColumns,last_index)
    elseif (status == 0) then
        print_slot(settings.SlotImage.status.default,config.maxColumns,last_index)
    elseif (status == 5) then
        print_slot(settings.SlotImage.status.equipped,config.maxColumns,last_index)
    elseif (status == 19) then
        print_slot(settings.SlotImage.status.linkshell_equipped,config.maxColumns,last_index)
    elseif (status == 25) then
        print_slot(settings.SlotImage.status.bazaar,config.maxColumns,last_index)
    else
        print_slot(settings.SlotImage.status.empty,config.maxColumns,last_index)
    end
end

function print_slot(status, max_columns, last_index)
    update_coordinates()
    if slot_images[current_block][current_slot] == nil then
        slot_images[current_block][current_slot] = {}
    end
    print_slot_background(status.background.color)
    print_slot_box(status.color)
    update_indexes(max_columns,last_index)
end

function print_slot_background(slot_color, max_columns, last_index)
    if slot_images[current_block][current_slot].background == nil then
        slot_images[current_block][current_slot].background = images.new(settings.SlotImage.background)
        slot_images[current_block][current_slot].background:pos(current_x,current_y)
    end
    slot_images[current_block][current_slot].background:width(settings.SlotImage.background.size.width)
    slot_images[current_block][current_slot].background:height(settings.SlotImage.background.size.height)
    slot_images[current_block][current_slot].background:alpha(slot_color.alpha)
    slot_images[current_block][current_slot].background:color(slot_color.red,slot_color.green,slot_color.blue)
end

function print_slot_box(slot_color, max_columns, last_index)
    if slot_images[current_block][current_slot].box == nil then
        slot_images[current_block][current_slot].box = images.new(settings.SlotImage.box)
        slot_images[current_block][current_slot].box:pos(current_x,current_y)
    end
    slot_images[current_block][current_slot].box:width(settings.SlotImage.box.size.width)
    slot_images[current_block][current_slot].box:height(settings.SlotImage.box.size.height)
    slot_images[current_block][current_slot].box:color(slot_color.red,slot_color.green,slot_color.blue)
    slot_images[current_block][current_slot].box:alpha(slot_color.alpha)
end

function update_coordinates()
    current_x = xRes + xBase +
        ((current_column - 1) * settings.SlotImage.spacing) +
        ((current_block - 1) * settings.SlotImage.blockSpacing) +
        ((last_column - 1) * settings.SlotImage.spacing)
    current_y = yRes + yBase - ((current_row - 1) * settings.SlotImage.spacing)
end

function update_indexes(max_columns, last_index)
    if (current_slot % max_columns) == 0 then
        if (current_slot == last_index) then
            last_column = last_column + current_column
        end
        current_column = 1
        current_row = current_row + 1
    else
        current_column = current_column + 1
    end
    current_slot = current_slot + 1
end

function show()
    for key,block in ipairs(slot_images) do
        for key,slot in ipairs(block) do
            slot.background:show()
            slot.box:show()
        end
    end
end

function hide()
    for key,block in ipairs(slot_images) do
        for key,slot in ipairs(block) do
            slot.background:hide()
            slot.box:hide()
        end
    end
end

function clear()
    slot_images = {}
end

windower.register_event('status change', function(new_status_id)
    if (new_status_id == 4) and (is_hidden_by_key == false) then
        is_hidden_by_cutscene = true
        hide()
    elseif (new_status_id ~= 4) and (is_hidden_by_key == false) then
        is_hidden_by_cutscene = false
        show()
    end
end)

windower.register_event('keyboard', function(dik, flags, blocked)
  if (dik == hideKey) and (flags == true) and (is_hidden_by_key == true) and (is_hidden_by_cutscene == false) then
    is_hidden_by_key = false
    show()
  elseif (dik == hideKey) and (flags == true) and (is_hidden_by_key == false) and (is_hidden_by_cutscene == false) then
    is_hidden_by_key = true
    hide()
  end
end)

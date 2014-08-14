_addon.name = 'Find'
_addon.author = 'Skudo'
_addon.version = '1.0.0.0'
_addon.command = 'find'
_addon.language = 'English'

local resources = require 'resources'
require 'logger'

local items = {}
local bags = {
  inventory = 'Inventory',
  safe = 'Mog Safe',
  storage = 'Storage',
  locker = 'Mog Locker',
  satchel = 'Mog Satchel',
  sack = 'Mog Sack',
  case = 'Mog Case'
}

function print_found_items(bag_name, items)
  local line = '%s: %s (%d)'

  for _, item in pairs(items) do
    log(line:format(bag_name, item.name, item.count))
  end
end

function find_items_in_bag(bag, input)
  local found_items = {}

  for _, object in pairs(bag) do
    local item = items[object.id]
    local normalised_input = input:lower()

    if item and item.name:lower():find(normalised_input) then
      if found_items[object.id] then
        found_items[object.id].count = found_items[object.id].count + object.count
      else
        found_items[object.id] = {
          name = item.name,
          count = object.count
        }
      end
    end
  end

  return found_items
end

function find_items(input)
  local owned_items = windower.ffxi.get_items()
  local found_items = {}

  for bag_key, bag_name in pairs(bags) do
    local found_items_in_bag = find_items_in_bag(owned_items[bag_key], input)

    if not table.empty(found_items_in_bag) then found_items[bag_name] = found_items_in_bag end
  end

  return found_items
end

windower.register_event('load', function()
  windower.send_command('alias find lua c find')

  for item in resources.items:it() do
    items[item.id] = item
  end
end)

windower.register_event('unload', function()
  windower.send_command('unalias find')
end)

windower.register_event('addon command', function(...)
  local input = table.concat({...}, ' ')
  local found_items

  if input ~= '' then
    log('Searching for: ' .. input)

    found_items = find_items(input)
    for bag_name, items in pairs(found_items) do
      print_found_items(bag_name, items)
    end

    if table.empty(found_items) then log('No items found.') end
  end
end)
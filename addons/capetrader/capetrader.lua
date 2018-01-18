--[[Copyright © 2016, Lygre, Burntwaffle@Odin
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of CapeTrader nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Lygre, Burntwaffle@Odin BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]--

_addon.name = 'CapeTrader'
_addon.author = 'Lygre, Burntwaffle'
_addon.version = '1.0.2'
_addon.commands = {'capetrader', 'ct'}

require('luau')
require('pack')
require('sets')
require('tables')
require('functions')
require('strings')
local res = require('resources')
local packets = require('packets')
local augPaths = require('allAugPaths')
local maxAugMap = require('maxAugMap')
local extData = require('extdata')
local jobToCapeMap = require('jobToCapeMap')
local validItemNames = require('validItemNames')

function getValidItems()
    local allItems = res.items
    local itemTable = T{}
    local counter = 0
    local numberOfValidItems = validItemNames:length()

    for key, item in pairs(allItems) do
        if counter >= numberOfValidItems then
            break
        end

        if validItemNames:contains(item.english) then
            itemTable:update(T{ [item.english:lower()] = item })
            counter = counter + 1
        end
    end

    return itemTable
end
local validItemTable = getValidItems()

--The following variables need to be carefully tracked and updated throughout all parts of this file.
--TODO: Find ways to reduce the amount of global variables in this list
local currentCape = nil
local pathItem = nil
local pathName = nil
local pathIndex
local capeHasBeenPrepared = false
local currentlyAugmenting = false
local firstTimeAug = false
local timesAugmentedCount = 0
local numberOfTimesToAugment = 0
local tradeReady = false
local maxAugKey = nil
local zoneHasLoaded = true
local inventory = nil

--The following are constants.
local dustSapThreadTradeDelay = 1
local dyeTradeDelay = 2
local endMessageDelay = 2
local threadIndex = 1
local dustIndex = 2
local dyeIndex = 3
local sapIndex = 4
local inventoryBagNumber = 0
local maxAmountDustAndThread = 20
local maxAmountSapAndDye = 10
local blueTextColor = 466
local redTextColor = 123
local greenTextColor = 158

--NOTE: It is possible that the correct values for the following variables can change after a version update.
local gorpaID = nil
local gorpaTargetIndex = nil
local gorpaMenuID = 0x183
local mhauraID = res.zones:with('english','Mhaura').id

windower.register_event('addon command', function(input, ...)
    local cmd = string.lower(input)
    local args = {...}

    updateGorpaID()

    if cmd == 'prep' then
        if args[1] and args[2] and args[3] then
            prepareCapeForAugments(args[2], args[1], args[3])
        else
            windower.add_to_chat(redTextColor, "You are missing at least one input to the prep command.")
        end
    elseif cmd == 'go' then
        if zoneHasLoaded and not currentlyAugmenting then
            if args[1] then
                if tonumber(args[1]) then
                    startAugmentingCape(args[1], true)
                else
                    windower.add_to_chat(redTextColor, 'Error: Not given a numerical argument.')
                end
            else
                startAugmentingCape(1, true)
            end
        elseif not zoneHasLoaded then
            windower.add_to_chat(redTextColor, 'Your inventory has not yet loaded, please try the go command again when your inventory loads.')
        elseif currentlyAugmenting then
            windower.add_to_chat(redTextColor, 'You are currently still augmenting a cape, please wait until the process finishes.')
        end
    elseif cmd == 'list' or cmd == 'l' then
        printAugList()
    elseif cmd == 'help' or cmd == 'h' then
        printHelp()
    elseif cmd == 'unload' or cmd == 'u' then
        windower.send_command('lua unload ' .. _addon.name)
    elseif cmd == 'reload' or cmd == 'r' then
        windower.send_command('lua reload ' .. _addon.name)
    else
        windower.add_to_chat(redTextColor, 'You entered an unknown command, enter //ct help if you forget your commands.')
    end
end)

function getItemIndex(capeOrAugItem)
    for itemIndex, item in pairs(inventory) do
        if item.id == capeOrAugItem.id then
            return itemIndex
        end
    end
end

function getItem(itemName)
    return validItemTable[itemName:lower()]
end

function buildTrade(capeIndex,augmentItemIndex)
    local packet = packets.new('outgoing', 0x036, {
        ["Target"] = gorpaID,
        ["Target Index"] = gorpaTargetIndex,
        ["Item Count 1"] = 1,
        ["Item Count 2"] = 1,
        ["Item Index 1"] = capeIndex,
        ["Item Index 2"] = augmentItemIndex,
        ["Number of Items"] = 2
    })
    packets.inject(packet)
end

windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)
    if id == 0x00B or id == 0x00A then
        zoneHasLoaded = false --NOTE: This idea was taken from Zohno's findall addon.
    end

    if id == 0x034 or id == 0x032 then
        if currentlyAugmenting then

            injectAugmentConfirmationPackets()

            timesAugmentedCount = timesAugmentedCount + 1
            if timesAugmentedCount <= tonumber(numberOfTimesToAugment) then
                windower.add_to_chat(greenTextColor, timesAugmentedCount - 1 .. '/' .. numberOfTimesToAugment .. ' augments completed.')
                tradeReady = true
            else
                capeHasBeenPrepared = false
                currentlyAugmenting = false
                currentCape = nil
                pathItem = nil
                tradeReady = false
                windower.add_to_chat:schedule(endMessageDelay,blueTextColor,'You have finished augmenting your cape.')
            end

            return true
        end
    end

    if id == 0x01D then
        if not zoneHasLoaded then
            zoneHasLoaded = true
        end
        if tradeReady then
            tradeReady = false

            if not pathItem.english:lower():endswith(' dye') then
                startAugmentingCape:schedule(dustSapThreadTradeDelay, numberOfTimesToAugment - timesAugmentedCount + 1, false)
            else
                startAugmentingCape:schedule(dyeTradeDelay, numberOfTimesToAugment - timesAugmentedCount + 1, false)
            end
        end
    end
end)

function checkDistanceToGorpa()
    local zoneID = tonumber(windower.ffxi.get_info().zone)
    if zoneID == mhauraID then
        local gorpa = windower.ffxi.get_mob_by_id(gorpaID)

        if gorpa and gorpa.distance < 36 then
            return true
        else
            windower.add_to_chat(redTextColor, "You're not close enough to Gorpa-Masorpa, please get closer!")
            return false
        end
    else
        windower.add_to_chat(redTextColor, "You are not in Mhaura!")
        currentlyAugmenting = false
        return false
    end
end

function checkAugItemCount(numberOfAugmentAttempts)
    if pathItem then
        local pathItemCount = 0

        for key, itemTable in pairs(inventory) do
            if key ~= 'max' and key ~= 'count' and key ~= 'enabled' then
                if itemTable.id == pathItem.id then
                    pathItemCount = pathItemCount + itemTable.count
                end
            end
        end

        if tonumber(numberOfAugmentAttempts) < 1 then
            windower.add_to_chat(redTextColor, 'Please enter a number of 1 or greater.')
            return false
        elseif tonumber(numberOfAugmentAttempts) > maxAmountSapAndDye and (pathItem.english:lower():endswith(' dye') or pathItem.english:lower():endswith(' sap')) then
            windower.add_to_chat(redTextColor, 'For sap or dye, the max number of times you can augment a cape is ' .. maxAmountSapAndDye .. ' times. You entered: ' .. numberOfAugmentAttempts)
            return false
        elseif tonumber(numberOfAugmentAttempts) > maxAmountDustAndThread and (pathItem.english:lower():endswith(' dust') or pathItem.english:lower():endswith(' thread')) then
            windower.add_to_chat(redTextColor, 'For dust or thread, the max number of times you can augment a cape is ' .. maxAmountDustAndThread .. ' times. You entered: ' .. numberOfAugmentAttempts)
            return false
        elseif tonumber(numberOfAugmentAttempts) > pathItemCount then
            local temp
            if tonumber(numberOfAugmentAttempts) > 1 then
                temp = ' times.'
            elseif tonumber(numberOfAugmentAttempts) == 1 then
                temp = ' time.'
            end

            if pathItemCount ~= 0 then
                windower.add_to_chat(redTextColor, 'You do not have enough ' .. pathItem.name .. ' to augment that cape ' .. numberOfAugmentAttempts .. temp ..' You only have ' .. pathItemCount .. ' in your inventory.')
            else
                windower.add_to_chat(redTextColor, 'You do not have enough ' .. pathItem.name .. ' to augment that cape ' .. numberOfAugmentAttempts .. temp ..' You have none in your inventory.')
            end
            return false
        else
            return true
        end
    end
end

function checkCapeCount()
    local capeCount = 0

    if currentCape then
        for key, itemTable in pairs(inventory) do
            if key ~= 'max' and key ~= 'count' and key ~= 'enabled' then
                if itemTable.id == currentCape.id then
                    capeCount = capeCount + 1
                end
            end
        end

        if capeCount > 1 then
            windower.add_to_chat(redTextColor, 'You have multiple ' .. currentCape.name .. 's in your inventory! Please keep only the one you intend to augment in your inventory.')
            return false
        elseif capeCount == 0 then
            windower.add_to_chat(redTextColor, 'You have zero ' .. currentCape.name .. 's in your inventory. Please find the one you intend to augment and move it to your inventory.')
            return false
        elseif capeCount == 1 then
            return true
        end
    else
        return false
    end
end

function prepareCapeForAugments(augItemType, jobName, augPath)
    if not currentlyAugmenting then
        local validArguments = true
        local augItemTypeIsValid = false

        if not S{'sap', 'dye', 'thread', 'dust'}:contains(augItemType:lower()) then
            windower.add_to_chat(redTextColor, 'Error with the type of augment item you entered. The second input should be sap or dye or thread or dust. You entered: ' .. augItemType:lower())
            validArguments = false
        else
            pathItem = getItem('abdhaljs ' .. augItemType)
            augItemTypeIsValid = true
        end

        if jobToCapeMap[jobName] then
            currentCape = getItem(jobToCapeMap[jobName])
        else
            windower.add_to_chat(redTextColor, 'The job name you entered is not valid. You entered: ' .. jobName)
            validArguments = false
        end

        if augPath and augItemTypeIsValid and validArguments then
            local isValidPath = false
            for i, v in pairs(augPaths[pathItem.english:lower()]) do
                if augPath:lower() == v:lower() then
                    pathIndex = i
                    pathName = augPath
                    isValidPath = true
                    break
                end
            end

            if not isValidPath then
                windower.add_to_chat(redTextColor, 'The augment path you entered is not valid. Please check the possible augment list for ' .. augItemType:lower() .. ' using the //ct list command. You entered: ' .. augPath)
                validArguments = false
            end
        end

        if validArguments then
            maxAugKey = string.lower(augItemType .. augPath)
            capeHasBeenPrepared = true
            timesAugmentedCount = 1
            windower.add_to_chat(greenTextColor, 'You can now augment your ' .. jobToCapeMap[jobName] .. ' with ' .. augPath:lower() .. ' using abdhaljs ' .. augItemType:lower() .. '.')
        else
            capeHasBeenPrepared = false
            currentCape = nil
            pathItem = nil
        end
    else
        windower.add_to_chat(redTextColor, 'You can\'t setup another cape while you are currently augmenting one.')
    end
end

function startAugmentingCape(numberOfRepeats, firstAttempt)
    inventory = windower.ffxi.get_items(inventoryBagNumber)
    currentlyAugmenting = true
    local augStatus = nil
    local capeIndex
    local augmentItemIndex
    if capeHasBeenPrepared and checkCapeCount() and checkAugItemCount(numberOfRepeats) and checkDistanceToGorpa() then
        augStatus = checkAugLimits():lower()
        capeIndex = getItemIndex(currentCape)
        augmentItemIndex = getItemIndex(pathItem)
    end

    if firstAttempt and augStatus then
        if augStatus ~= 'maxed' and augStatus ~= 'notmatching' then
            if augStatus:lower() ~= 'empty' then
                firstTimeAug = false
            else
                firstTimeAug = true
            end

            local temp
            if tonumber(numberOfRepeats) == 1 then
                temp = 'time.'
            else
                temp = 'times.'
            end

            numberOfTimesToAugment = numberOfRepeats
            windower.add_to_chat(blueTextColor, 'Starting to augment your ' .. currentCape.name .. ' ' .. numberOfRepeats .. ' ' .. temp)

            tradeReady = false
            buildTrade(capeIndex,augmentItemIndex)
        else
            currentlyAugmenting = false
            tradeReady = false
        end
    elseif not firstAttempt and augStatus then
        if augStatus and augStatus ~= 'maxed' then
            tradeReady = false
            buildTrade(capeIndex,augmentItemIndex)
        else
            capeHasBeenPrepared = false
            currentlyAugmenting = false
            tradeReady = false
            pathItem = nil
            currentCape = nil
            windower.add_to_chat(blueTextColor, 'Your cape is currently maxed in that augment path, ending the augment process now.')
        end
    elseif not capeHasBeenPrepared then
        currentlyAugmenting = false
        windower.add_to_chat(redTextColor, 'You have not yet setup your cape and augment information with the //ct prep command!')
    else
        currentlyAugmenting = false
    end
end

function checkAugLimits()
    local capeItem
    for index, item in pairs(inventory) do
        if index ~= 'max' and index ~= 'count' and index ~= 'enabled' then
            if item.id == currentCape.id then
                capeItem = item
                break
            end
        end
    end

    local augmentTable
    if extData.decode(capeItem).augments then
        augmentTable = extData.decode(capeItem).augments
    end

    local augValue
    if augmentTable then
        if pathItem.english:lower():endswith(' thread') then
            augValue = augmentTable[threadIndex]
        elseif pathItem.english:lower():endswith(' dust') then
            augValue = augmentTable[dustIndex]
        elseif pathItem.english:lower():endswith(' dye') then
            augValue = augmentTable[dyeIndex]
        elseif pathItem.english:lower():endswith(' sap') then
            augValue = augmentTable[sapIndex]
        end
    else
        augValue = 'none'
    end

    if augValue:lower() == 'none' or not augmentTable then
        return 'empty'
    end

    local max = maxAugMap[maxAugKey].max
    if augValue:contains(max) then
        windower.add_to_chat(redTextColor, 'You have augmented your ' .. currentCape.name .. ' to the max already with ' .. pathItem.name .. '.')
        return 'maxed'
    end

    local mustContainTable = maxAugMap[maxAugKey].mustcontain
    for k, augmentString in pairs(mustContainTable) do
        if not augValue:lower():contains(augmentString:lower()) then
            windower.add_to_chat(redTextColor,'You can\'t augment your ' .. currentCape.name .. ' with ' .. pathName .. ' because it has already been augmented with: ' .. augValue .. ' using ' .. pathItem.name .. '.')
            return 'notmatching'
        end
    end

    local cantContainTable = maxAugMap[maxAugKey].cantcontain
    if table.length(cantContainTable) > 0 then
        for k, augmentString in pairs(cantContainTable) do
            if augValue:lower():contains(augmentString:lower()) then
                windower.add_to_chat(redTextColor,'You can\'t augment your ' .. currentCape.name .. 'with ' .. pathName .. ' because it has already been augmented with: ' .. augValue .. ' using ' .. pathItem.name .. '.')
                return 'notmatching'
            end
        end
    end

    return 'allclear'
end

function injectAugmentConfirmationPackets()
    local optionIndex
    if firstTimeAug then
        firstTimeAug = false
        optionIndex = 512
    else
        optionIndex = 256
    end

    local augmentChoicePacket = packets.new('outgoing', 0x05B)
    augmentChoicePacket["Target"] = gorpaID
    augmentChoicePacket["Option Index"] = optionIndex
    augmentChoicePacket["_unknown1"] = pathIndex
    augmentChoicePacket["Target Index"] = gorpaTargetIndex
    augmentChoicePacket["Automated Message"] = true
    augmentChoicePacket["Zone"] = mhauraID
    augmentChoicePacket["Menu ID"] = gorpaMenuID
    packets.inject(augmentChoicePacket)

    augmentChoicePacket["Automated Message"] = false
    packets.inject(augmentChoicePacket)

    local playerUpdatePacket = packets.new('outgoing', 0x016, {
        ["Target Index"] = windower.ffxi.get_mob_by_target('me').index,
    })
    packets.inject(playerUpdatePacket)
end

function updateGorpaID()
    if not gorpaID then
        local zoneID = tonumber(windower.ffxi.get_info().zone)
        if zoneID == mhauraID then
            local gorpa = windower.ffxi.get_mob_by_name('Gorpa-Masorpa')
            gorpaID = gorpa.id
            gorpaTargetIndex = gorpa.index
        end
    end
end

function printAugList()
    windower.add_to_chat(blueTextColor, 'Thread: hp mp str dex vit agi int mnd chr petmelee petmagic')
    windower.add_to_chat(blueTextColor, 'Dust: acc/atk racc/ratk macc/mdmg eva/meva')
    windower.add_to_chat(blueTextColor, 'Sap: wsd critrate stp doubleattack haste dw enmity+ enmity- snapshot mab fc curepotency waltzpotency petregen pethaste')
    windower.add_to_chat(blueTextColor, 'Dye: hp mp str dex vit agi int mnd chr acc atk racc ratk macc mdmg eva meva petacc petatk petmacc petmdmg')
end

function printHelp()
    windower.add_to_chat(blueTextColor, string.format('%s Version: %s Command Listing:', _addon.name, _addon.version))
    windower.add_to_chat(blueTextColor, '   reload|r Reload CapeTrader.')
    windower.add_to_chat(blueTextColor, '   unload|u Unload CapeTrader.')
    windower.add_to_chat(blueTextColor, '   prep <jobName> <augItem> <augPath> Prepares a given job\'s cape with augItem on augPath. Need to use this before using //ct go.')
    windower.add_to_chat(blueTextColor, '   go <#repeats> Starts augmenting cape with the info gathered from the prep command. The repeats input defaults to one if not provided.')
    windower.add_to_chat(blueTextColor, '   list|l Lists all possible augitems and their valid paths. Use to know what the valid inputs for //ct prep are.')
end

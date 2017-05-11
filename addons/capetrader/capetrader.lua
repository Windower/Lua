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
require('functions')
require('strings')
packets = require('packets')
ambuscadeCapeTable = require('allAmbuscadeCapes')
abdhaljs = require('allAugPaths')
augItems = require('allAugItems')
maxAugMap = require('maxAugMap')
extData = require('extdata')
jobToCapeMap = require('jobToCapeMap')

local playerIndex = nil
local npc = 17797273
local target_index = 153
local menu = 387
local zone = 249
local cape_name = ""
local pathName = nil
local opt_ind
local path_item = ''
local inventoryBagNumber = 0
local maxAmountDustAndThread = 20
local maxAmountSapAndDye = 10
local cape_ind
local aug_ind
local safeToAugment = false
local busy = false
local timesAugmentedCount = nil
local numberOfTimesToAugment = nil
local firstPass = false
local dustSapThreadTradeDelay = 1
local dyeTradeDelay = 2
local tradeReady = false
local threadIndex = 1
local dustIndex = 2
local dyeIndex = 3
local sapIndex = 4
local maxAugKey = nil
local zoneHasLoaded = true
local inventory = nil

windower.register_event('addon command', function(input, ...)
	local cmd = string.lower(input)
	if cmd == 'prep' then
		if arg[1] and arg[2] and arg[3] then
			prepareCapeForAugments(arg[2], arg[1], arg[3])
		else
			windower.add_to_chat(123, "You are missing at least one input to the prep command.")
		end
	elseif cmd == 'go' then
		if zoneHasLoaded then
			inventory = windower.ffxi.get_items(inventoryBagNumber)
			if arg[1] then
				if tonumber(arg[1]) then
					startAugmentingCape(arg[1], true)
				else
					windower.add_to_chat(123, 'Error: Not given a numerical argument.')
				end
			else
				startAugmentingCape(1, true)
			end
		else
			windower.add_to_chat(123, 'Your inventory has not yet loaded, please try the go command again when your inventory loads.')
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
		windower.add_to_chat(123, 'You entered an unknown command, enter //ct help if you forget your commands.')
	end
end)

function getCapeIndex(capeID)
	local capeToAug = ambuscadeCapeTable[capeID]

	for itemIndex, item in pairs(inventory) do
		if item.id == capeToAug.id then
			return itemIndex
		end
	end
end

function getAugItemIndex(augItemName)
	local augItem = augItems[augItemName]

	for itemIndex, item in pairs(inventory) do
		if item.id == augItem.id then
			return itemIndex
		end
	end
end

function build_trade()
	if npc and target_index then
		local packet = packets.new('outgoing', 0x036, {
			["Target"] = npc,
			["Target Index"] = target_index,
			["Item Count 1"] = 1,
			["Item Count 2"] = 1,
			["Item Index 1"] = cape_ind,
			["Item Index 2"] = aug_ind,
			["Number of Items"] = 2
		})
		packets.inject(packet)
	end
end

windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)

	if id == 0x00B or id == 0x00A then
		zoneHasLoaded = false --NOTE: This idea was taken from Zohno's findall addon.
	end

	if id == 0x034 or id == 0x032 then
		if busy and playerIndex then

			if not firstTimeAug then
				injectAugPackets()
			else
				firstTimeAug = false
				injectFirstAugPackets()
			end

			timesAugmentedCount = timesAugmentedCount + 1
			if timesAugmentedCount <= tonumber(numberOfTimesToAugment) then
				windower.add_to_chat(158, timesAugmentedCount - 1 .. '/' .. numberOfTimesToAugment .. ' augments completed.')
				busy = false
				tradeReady = true
			else
				safeToAugment = false
				busy = false
				playerIndex = nil
				maxAugKey = nil
				tradeReady = false
				functions.schedule(sendCompletedMessage, 2)
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

			if path_item ~= 'dye' then
				functions.schedule(startAugmentingCape, dustSapThreadTradeDelay, numberOfTimesToAugment - timesAugmentedCount + 1, false)
			else
				functions.schedule(startAugmentingCape, dyeTradeDelay, numberOfTimesToAugment - timesAugmentedCount + 1, false)
			end
		end
	end
end)

function checkDistanceToNPC()
	local zoneID = tonumber(windower.ffxi.get_info().zone)
	if zoneID == zone then
		local target = windower.ffxi.get_mob_by_id(npc)
		if target and math.sqrt(target.distance) < 6 then
			return true
		else
			windower.add_to_chat(123, "You're not close enough to Gorpa-Masorpa, please get closer!")
			return false
		end
	else
		windower.add_to_chat(123, "You are not in Mhaura!")
		return false
	end
end

function checkThreadDustDyeSapCount(augmentType, numberOfAugmentAttempts)
	if augItems[augmentType] then
		local augItem = augItems[augmentType]
		local augID = augItem.id
		local augItemCount = 0

		for key, itemTable in pairs(inventory) do
			if key ~= 'max' and key ~= 'count' and key ~= 'enabled' then
				local itemID = itemTable.id
				if itemID == augID then
					augItemCount = augItemCount + itemTable.count
				end
			end
		end

		if tonumber(numberOfAugmentAttempts) < 1 then
			windower.add_to_chat(123, 'Please enter a number of 1 or greater.')
			return false
		elseif tonumber(numberOfAugmentAttempts) > maxAmountSapAndDye and (path_item == 'dye' or path_item == 'sap') then
			windower.add_to_chat(123, 'For sap or dye, the max number of times you can augment a cape is ' .. maxAmountSapAndDye .. ' times. You entered: ' .. numberOfAugmentAttempts)
			return false
		elseif tonumber(numberOfAugmentAttempts) > maxAmountDustAndThread and (path_item == 'dust' or path_item == 'thread') then
			windower.add_to_chat(123, 'For dust or thread, the max number of times you can augment a cape is ' .. maxAmountDustAndThread .. ' times. You entered: ' .. numberOfAugmentAttempts)
			return false
		elseif tonumber(numberOfAugmentAttempts) > augItemCount then
			local temp
			if tonumber(numberOfAugmentAttempts) > 1 then
				temp = ' times.'
			elseif tonumber(numberOfAugmentAttempts) == 1 then
				temp = ' time.'
			end
			windower.add_to_chat(123, 'You do not have enough ' .. augItem.en .. ' to augment that cape ' .. numberOfAugmentAttempts .. temp ..' You only have ' .. augItemCount .. ' in your inventory.')
			return false
		else
			aug_ind = getAugItemIndex(augmentType)
			return true
		end
	else
		windower.add_to_chat(158, 'Error with input augmentType in checkThreadDustDyeSapCount function.')
	end

end

function checkCapeCount()
	local capeCount = 0
	local capeID

	if cape_name ~= "" and cape_name then

		for index, cape in pairs(ambuscadeCapeTable) do
			if string.lower(cape.en) == string.lower(cape_name) then
				capeID = cape.id
				break
			end
		end

		for key, itemTable in pairs(inventory) do
			if key ~= 'max' and key ~= 'count' and key ~= 'enabled' then
				local itemID = itemTable.id
				if itemID ~= 0 then
					if itemID == capeID then
						capeCount = capeCount + 1
					end
				end
			end
		end

		if capeCount > 1 then
			windower.add_to_chat(123, 'You have multiple ' .. cape_name .. 's in your inventory! Please keep only the one you intend to augment in your inventory.')
			return false
		elseif capeCount == 0 then
			windower.add_to_chat(123, 'You have zero ' .. cape_name .. 's in your inventory. Please find the one you intend to augment and move it to your inventory.')
			return false
		elseif capeCount == 1 then
			cape_ind = getCapeIndex(capeID)
			return true
		end
	else
		return false
	end
end

function prepareCapeForAugments(augItemType, jobName, augPath)
	if not busy then
		local validArguments = true
		local augItemTypeIsValid = false

		if not S{'sap', 'dye', 'thread', 'dust'}:contains(string.lower(augItemType)) then
			windower.add_to_chat(123, 'Error with the type of augment item you entered. The second input should be sap or dye or thread or dust. You entered: ' .. string.lower(augItemType))
			validArguments = false
		else
			path_item = string.lower(augItemType)
			augItemTypeIsValid = true
		end

		local isCapeTypeValid = false
		if jobToCapeMap[jobName] then
			for index, cape in pairs(ambuscadeCapeTable) do
				if string.lower(cape.en) == string.lower(jobToCapeMap[jobName]) then
					isCapeTypeValid = true
					break
				end
			end
		end

		if not isCapeTypeValid then
			windower.add_to_chat(123, 'The job name you entered is not valid. You entered: ' .. jobName)
			validArguments = false
		else
			cape_name = '' .. jobToCapeMap[jobName] .. ''
		end

		if augPath and augItemTypeIsValid then
			local isValidPath = false
			for i, v in pairs(abdhaljs[path_item]) do
				if augPath:lower() == v:lower() then
					opt_ind = i
					pathName = augPath
					isValidPath = true
					break
				end
			end

			if not isValidPath then
				windower.add_to_chat(123, 'The augment path you entered is not valid. Please check the possible augment list for ' .. string.lower(augItemType) .. ' using the //ct list command. You entered: ' .. augPath)
				validArguments = false
			end
		end

		if validArguments then
			maxAugKey = string.lower(augItemType .. augPath)
			safeToAugment = true
			firstPass = true
			timesAugmentedCount = 1
			windower.add_to_chat(158, 'You can now augment your ' .. jobToCapeMap[jobName] .. ' with ' .. string.lower(augPath) .. ' using abdhaljs ' .. string.lower(augItemType) .. '.')
		else
			maxAugKey = nil
			safeToAugment = false
			opt_ind = nil
			path_item = nil
			path_name = nil
			cape_name = nil
		end
	else
		windower.add_to_chat(123, 'You can\'t setup another cape while you are currently augmenting one.')
	end
end

function startAugmentingCape(numberOfRepeats, firstAttempt)
	local augStatus
	local capeCountsafe = checkCapeCount()
	if safeToAugment and capeCountsafe then
		augStatus = checkAugLimits()
	end
	if safeToAugment and not busy and firstAttempt and augStatus then
		if capeCountsafe and checkThreadDustDyeSapCount(path_item, numberOfRepeats) and checkDistanceToNPC() and string.lower(augStatus) ~= 'maxed' and string.lower(augStatus) ~= 'notmatching' then
			if firstPass then
				if string.lower(augStatus) ~= 'empty' then
					firstTimeAug = false
				else
					firstTimeAug = true
				end

				firstPass = false
				local temp
				if tonumber(numberOfRepeats) == 1 then
					temp = 'time.'
				else
					temp = 'times.'
				end

				numberOfTimesToAugment = numberOfRepeats
				windower.add_to_chat(466, 'Starting to augment your ' .. cape_name .. ' ' .. numberOfRepeats .. ' ' .. temp)
			end

			playerIndex = windower.ffxi.get_mob_by_target('me').index
			busy = true
			tradeReady = false
			build_trade()
		else
			busy = false
			tradeReady = false
			playerIndex = nil
		end
	elseif safeToAugment and not busy and not firstPass and not firstAttempt then
		if augStatus ~= 'maxed' then
			busy = true
			playerIndex = windower.ffxi.get_mob_by_target('me').index
			tradeReady = false
			build_trade()
		else
			safeToAugment = false
			busy = false
			tradeReady = false
			playerIndex = nil
			maxAugKey = nil
			windower.add_to_chat(466, 'Your cape is currently maxed in that augment path, ending the augment process now.')
		end
	elseif busy then
		windower.add_to_chat(123, 'You are currently still augmenting a cape, please wait until the process finishes.')
	elseif not safeToAugment then
		windower.add_to_chat(123, 'You have not yet setup your cape and augment information with the //ct prep command!')
	end
end

function checkAugLimits()
	local capeID
	for id, capeInfo in pairs(ambuscadeCapeTable) do
		if string.lower(capeInfo.en) == string.lower(cape_name) then
			capeID = id
			break
		end
	end

	local capeItem
	for index, item in pairs(inventory) do
		if index ~= 'max' and index ~= 'count' and index ~= 'enabled' then
			if item.id == capeID then
				capeItem = item
			end
		end
	end

	local augmentTable
	if extData.decode(capeItem).augments then
		augmentTable = extData.decode(capeItem).augments
	end

	local augValue
	if augmentTable then
		if path_item == 'thread' then
			augValue = augmentTable[threadIndex]
		elseif path_item == 'dust' then
			augValue = augmentTable[dustIndex]
		elseif path_item == 'dye' then
			augValue = augmentTable[dyeIndex]
		elseif path_item == 'sap' then
			augValue = augmentTable[sapIndex]
		end
	else
		augValue = 'none'
	end

	if string.lower(augValue) == 'none' or not augmentTable then
		return 'empty'
	end

	local max = maxAugMap[maxAugKey].max
	if string.contains(augValue, max) then
		windower.add_to_chat(123, 'You have augmented your ' .. cape_name .. ' to the max already with abdhaljs ' .. path_item .. '.')
		return 'maxed'
	end

	local mustContainTable = maxAugMap[maxAugKey].mustcontain
	for k, augmentString in pairs(mustContainTable) do
		if not string.contains(string.lower(augValue), string.lower(augmentString)) then
			windower.add_to_chat(123,'You can\'t augment your ' .. cape_name .. ' with ' .. pathName .. ' because it has already been augmented with: ' .. augValue .. ' using ' .. path_item .. '.')
			return 'notmatching'
		end
	end

	local cantContainTable = maxAugMap[maxAugKey].cantcontain
	if table.length(cantContainTable) > 0 then
		for k, augmentString in pairs(cantContainTable) do
			if string.contains(string.lower(augValue), string.lower(augmentString)) then
				windower.add_to_chat(123,'You can\'t augment your ' .. cape_name .. 'with ' .. pathName .. ' because it has already been augmented with: ' .. augValue .. ' using ' .. path_item .. '.')
				return 'notmatching'
			end
		end
	end

	return 'allclear'
end

function injectFirstAugPackets()
	local packet = packets.new('outgoing', 0x05B)
	packet["Target"] = npc
	packet["Option Index"] = 512
	packet["_unknown1"] = opt_ind
	packet["Target Index"] = target_index
	packet["Automated Message"] = true
	packet["_unknown2"] = 0
	packet["Zone"] = zone
	packet["Menu ID"] = menu
	packets.inject(packet)

	local packet = packets.new('outgoing', 0x05B)
	packet["Target"] = npc
	packet["Option Index"] = 512
	packet["_unknown1"] = opt_ind
	packet["Target Index"] = target_index
	packet["Automated Message"] = false
	packet["_unknown2"] = 0
	packet["Zone"] = zone
	packet["Menu ID"] = menu
	packets.inject(packet)

	local packet = packets.new('outgoing', 0x016, {
		["Target Index"] = playerIndex,
	})
	packets.inject(packet)
end

function injectAugPackets()
	local packet = packets.new('outgoing', 0x05B)
	packet["Target"] = npc
	packet["Option Index"] = 256
	packet["_unknown1"] = opt_ind
	packet["Target Index"] = target_index
	packet["Automated Message"] = true
	packet["_unknown2"] = 0
	packet["Zone"] = zone
	packet["Menu ID"] = menu
	packets.inject(packet)

	local packet = packets.new('outgoing', 0x05B)
	packet["Target"] = npc
	packet["Option Index"] = 256
	packet["_unknown1"] = opt_ind
	packet["Target Index"] = target_index
	packet["Automated Message"] = false
	packet["_unknown2"] = 0
	packet["Zone"] = zone
	packet["Menu ID"] = menu
	packets.inject(packet)

	local packet = packets.new('outgoing', 0x016, {
		["Target Index"] = playerIndex,
	})
	packets.inject(packet)
end

function sendCompletedMessage()
	windower.add_to_chat(466, 'You have finished augmenting your cape.')
end

function printAugList()
	windower.add_to_chat(466, 'Thread: hp mp str dex vit agi int mnd chr petmelee petmagic')
	windower.add_to_chat(466, 'Dust: acc/atk racc/ratk macc/mdmg eva/meva')
	windower.add_to_chat(466, 'Sap: wsd critrate stp doubleattack haste dw enmity+ enmity- snapshot mab fc curepotency waltzpotency petregen pethaste')
	windower.add_to_chat(466, 'Dye: hp mp str dex vit agi int mnd chr acc atk racc ratk macc mdmg eva meva petacc petatk petmacc petmdmg')
end

function printHelp()
	windower.add_to_chat(466, string.format('%s Version: %s Command Listing:', _addon.name, _addon.version))
	windower.add_to_chat(466, '   reload|r Reload CapeTrader.')
	windower.add_to_chat(466, '   unload|u Unload CapeTrader.')
	windower.add_to_chat(466, '   prep <jobName> <augItem> <augPath> Prepares a given job\'s cape with augItem on augPath. Need to use this before using //ct go.')
	windower.add_to_chat(466, '   go <#repeats> Starts augmenting cape with the info gathered from the prep command. The repeats input defaults to one if not provided.')
	windower.add_to_chat(466, '   list|l Lists all possible augitems and their valid paths. Use to know what the valid inputs for //ct prep are.')
end

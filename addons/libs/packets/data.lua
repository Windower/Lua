--[[
    This file returns a table of known packet data.
]]

local data = {}
local dummy =          {name='Unknown',             description='No data available.'}

data.incoming = setmetatable({}, {__index = function() return dummy end})
data.outgoing = setmetatable({}, {__index = function() return dummy end})

-- Client packets (outgoing)
data.outgoing[0x00A] = {name='Client Connect',      description='(unencrypted/uncompressed) First packet sent when connecting to new zone.'}
data.outgoing[0x00C] = {name='Zone In 1',           description='Likely triggers certain packets to be sent from the server.'}
data.outgoing[0x00D] = {name='Client Leave',        description='Last packet sent from client before it leaves the zone.'}
data.outgoing[0x00F] = {name='Zone In 2',           description='Likely triggers certain packets to be sent from the server.'}
data.outgoing[0x011] = {name='Zone In 3',           description='Likely triggers certain packets to be sent from the server.'}
data.outgoing[0x015] = {name='Standard Client',     description='Packet contains data that is sent almost every time (i.e your character\'s position).'}
data.outgoing[0x016] = {name='Update Request',      description='Packet that requests a PC/NPC update packet.'}
data.outgoing[0x017] = {name='NPC Race Error',      description='Packet sent in response to impossible incoming NPC packets (like trying to put equipment on a race 0 monster).'}
data.outgoing[0x01A] = {name='Action',              description='An action being done on a target (i.e. an attack or spell).'}
data.outgoing[0x01E] = {name='Volunteer',           description='Sent in response to a /volunteer command.'}
data.outgoing[0x028] = {name='Drop Item',           description='Drops an item.'}
data.outgoing[0x029] = {name='Move Item',           description='Move item from one inventory to another.'}
data.outgoing[0x02B] = {name='Translate Request',   description='Request that a phrase be translated.'}
data.outgoing[0x032] = {name='Offer Trade',         description='This is sent when you offer to trade somebody.'}
data.outgoing[0x033] = {name='Trade Tell',          description='This packet allows you to accept or cancel a trade request.'}
data.outgoing[0x034] = {name='Trade Item',          description='Sends the item you want to trade to the server.'}
data.outgoing[0x036] = {name='Menu Item',           description='Use an item from the item menu.'}
data.outgoing[0x037] = {name='Use Item',            description='Use an item.'}
data.outgoing[0x03A] = {name='Sort Item',           description='Stacks the items in your inventory. Sent when hitting "Sort" in the menu.'}
data.outgoing[0x03D] = {name='Blacklist Command',   description='Sent in response to /blacklist add or /blacklist delete.'}
data.outgoing[0x041] = {name='Lot Item',            description='Lotting an item in the treasure pool.'}
data.outgoing[0x042] = {name='Pass Item',           description='Passing an item in the treasure pool.'}
data.outgoing[0x04B] = {name='Servmes',             description='Requests the server message (/servmes).'}
data.outgoing[0x04D] = {name='Delivery Box',        description='Used to manipulate the delivery box.'}
data.outgoing[0x04E] = {name='Auction',             description='Used to bid on an Auction House item.'}
data.outgoing[0x050] = {name='Equip',               description='This command is used to equip your character.'}
data.outgoing[0x051] = {name='Equipset',            description='This packet is sent when using /equipset.'}
data.outgoing[0x052] = {name='Equipset Build',      description='This packet is sent when building an equipset.'}
data.outgoing[0x053] = {name='Lockstyleset',        description='This packet is sent when locking to an equipset.'}
data.outgoing[0x059] = {name='End Synth',           description='This packet is sent to end a synth.'}
data.outgoing[0x05A] = {name='Conquest',            description='This command asks the server for data pertaining to conquest/besieged status.'}
data.outgoing[0x05B] = {name='Dialog choice',       description='Chooses a dialog option.'}
data.outgoing[0x05C] = {name='Warp Request',        description='Request a warp. Used by teleporters and the like.'}
data.outgoing[0x05D] = {name='Emote',               description='This command is used in emotes.'}
data.outgoing[0x05E] = {name='Request Zone',        description='Request from the client to zone.'}
data.outgoing[0x061] = {name='Equipment Screen',    description='This command is used when you open your equipment screen.'}
data.outgoing[0x063] = {name='Digging Finished',    description='This packet is sent when the chocobo digging animation is finished.'}
data.outgoing[0x064] = {name='New KI examination',  description='Sent when you examine a key item with a "new" flag on it.'}
data.outgoing[0x06E] = {name='Party invite',        description='Sent when inviting another player to either party or alliance.'}
data.outgoing[0x06F] = {name='Party leave',         description='Sent when leaving the party or alliance.'}
data.outgoing[0x070] = {name='Party breakup',       description='Sent when disbanding the entire party or alliance.'}
data.outgoing[0x071] = {name='Kick',                description='Sent when you kick someone from linkshell or party.'}
data.outgoing[0x074] = {name='Party response',      description='Sent when responding to a party or alliance invite.'}
data.outgoing[0x077] = {name='Change permissions',  description='Sent when giving party or alliance leader to another player or elevating/decreasing linkshell permissions.'}
data.outgoing[0x078] = {name='Party list request',  description='Sent when checking the party list.'}
data.outgoing[0x083] = {name='NPC Buy Item',        description='Buy an item from a generic NPC.'}
data.outgoing[0x084] = {name='Appraise',            description='Ask server for selling price.'}
data.outgoing[0x085] = {name='Sell Item',           description='Sell an item from your inventory.'}
data.outgoing[0x096] = {name='Synth',               description='Packet sent containing all data of an attempted synth.'}
data.outgoing[0x0A0] = {name='Nominate',            description='Sent in response to a /nominate command.'}
data.outgoing[0x0A1] = {name='Vote',                description='Sent in response to a /vote command.'}
data.outgoing[0x0A2] = {name='Random',              description='Sent in response to a /random command.'}
data.outgoing[0x0AA] = {name='Guild Buy Item',      description='Buy an item from a guild.'}
data.outgoing[0x0AB] = {name='Get Guild Inv List',  description='Gets the offerings of the guild.'}
data.outgoing[0x0AC] = {name='Guild Sell Item',     description='Sell an item to the guild.'}
data.outgoing[0x0AD] = {name='Get Guild Sale List', description='Gets the list of things the guild will buy.'}
data.outgoing[0x0B5] = {name='Speech',              description='Packet contains normal speech.'}
data.outgoing[0x0B6] = {name='Tell',                description='/tell\'s sent from client.'}
data.outgoing[0x0BE] = {name='Merit Point Increase',description='Sent when you increase a merit point ability.'}
data.outgoing[0x0BF] = {name='Job Point Increase',  description='Sent when you increase a job point ability.'}
data.outgoing[0x0C0] = {name='Job Point Menu',      description='Sent when you open the Job Point menu and triggers Job Point Information packets.'}
data.outgoing[0x0C3] = {name='Make Linkshell',      description='Sent in response to the /makelinkshell command.'}
data.outgoing[0x0C4] = {name='Equip Linkshell',     description='Sent to equip a linkshell.'}
data.outgoing[0x0CB] = {name='Open Mog',            description='Sent when opening or closing your mog house.'}
data.outgoing[0x0D2] = {name='Party Marker Request',description='Requests map markers for your party.'}
data.outgoing[0x0D3] = {name='GM Call',             description='Places a call to the GM queue.'}
data.outgoing[0x0D4] = {name='Help Desk Menu',      description='Opens the Help Desk submenu.'}
data.outgoing[0x0DC] = {name='Type Bitmask',        description='This command is sent when change your party-seek or /anon status.'}
data.outgoing[0x0DD] = {name='Check',               description='Used to check other players.'}
data.outgoing[0x0DE] = {name='Set Bazaar Message',  description='Sets your bazaar message.'}
data.outgoing[0x0E0] = {name='Search Comment',      description='Sets your search comment.'}
data.outgoing[0x0E1] = {name='Get LS Message',      description='Requests the current linkshell message.'}
data.outgoing[0x0E2] = {name='Set LS Message',      description='Sets the current linkshell message.'}
data.outgoing[0x0EA] = {name='Sit',                 description='A request to sit or stand is sent to the server.'}
data.outgoing[0x0E7] = {name='Logout',              description='A request to logout of the server.'}
data.outgoing[0x0E8] = {name='Toggle Heal',         description='This command is used to both heal and cancel healing.'}
data.outgoing[0x0F1] = {name='Cancel',              description='Sent when canceling a buff.'}
data.outgoing[0x0F2] = {name='Declare Subregion',   description='Sent when moving to a new subregion of a zone (for instance, a different combination of open doors).'}
data.outgoing[0x0F4] = {name='Widescan',            description='This command asks the server for a widescan.'}
data.outgoing[0x0F5] = {name='Widescan Track',      description='Sent when you choose to track something on widescan.'}
data.outgoing[0x0F6] = {name='Widescan Cancel',     description='Sent when you choose to stop track something on widescan.'}
data.outgoing[0x0FA] = {name='Place/Move Furniture',description='Sends new position for your furniture.'}
data.outgoing[0x0FB] = {name='Remove Furniture',    description='Informs the server you have removed some furniture.'}
data.outgoing[0x0FC] = {name='Plant Flowerpot',     description='Plants a seed in a flowerpot.'}
data.outgoing[0x0FD] = {name='Examine Flowerpot',   description='Sent when you examine a flowerpot.'}
data.outgoing[0x0FE] = {name='Uproot Flowerpot',    description='Uproots a flowerpot.'}
data.outgoing[0x100] = {name='Job Change',          description='Sent when initiating a job change.'}
data.outgoing[0x102] = {name='Untraditional Equip', description='Sent when equipping a pseudo-item like an Automaton Attachment, Instinct, or Blue Magic Spell.'}
data.outgoing[0x104] = {name='Leave Bazaar',        description='Sent when client leaves a bazaar.'}
data.outgoing[0x105] = {name='View Bazaar',         description='Sent when viewing somebody\'s bazaar.'}
data.outgoing[0x106] = {name='Buy Bazaar Item',     description='Buy an item from somebody\'s bazaar.'}
data.outgoing[0x109] = {name='Close Bazaar',        description='Sent after closing your bazaar window.'}
data.outgoing[0x10A] = {name='Set Price',           description='Set the price on a bazaar item.'}
data.outgoing[0x10B] = {name='Open Bazaar',         description='Sent when opening your bazaar window to set prices.'}
data.outgoing[0x10C] = {name='Start RoE Quest',     description='Sent to undertake a Records of Eminence Quest.'}
data.outgoing[0x10D] = {name='Cancel RoE Quest',    description='Sent to cancel a Records of Eminence Quest.'}
data.outgoing[0x10E] = {name='Accept RoE Reward',   description='Accept an RoE qust reward that was not given automatically due to inventory restrictions.'}
data.outgoing[0x10F] = {name='Currency Menu',       description='Requests currency information for the menu.'}
data.outgoing[0x110] = {name='Fishing Action',      description='Sent when casting, releasing a fish, catching a fish, and putting away your fishing rod.'}
data.outgoing[0x111] = {name='Lockstyle',           description='Sent when using the lockstyle command to lock or unlock.'}
data.outgoing[0x112] = {name='RoE Log Request',     description='Sent when zoning. Requests the ROE quest log.'}
data.outgoing[0x114] = {name='HP Map Trigger',      description='Sent when entering a homepoint list for a zone to trigger maps to appear.'}
data.outgoing[0x115] = {name='Currency Menu 2',     description='Requests currency 2 information for the menu.'}
data.outgoing[0x116] = {name='Unity Menu',          description='Sent when opening the Status/Unity menu.'}
data.outgoing[0x117] = {name='Unity Ranking Menu',  description='Sent when opening the Status/Unity/Unity Ranking menu.'}
data.outgoing[0x118] = {name='Unity Chat Status',   description='Sent when changing unity chat status.'}

-- Server packets (incoming)
data.incoming[0x009] = {name='Standard Message',    description='A standardized message send from FFXI.'}
data.incoming[0x00A] = {name='Zone In',             description='Info about character and zone around it.'}
data.incoming[0x00B] = {name='Zone Out',            description='Packet contains IP and port of next zone to connect to.'}
data.incoming[0x00D] = {name='PC Update',           description='Packet contains info about another PC (i.e. coordinates).'}
data.incoming[0x00E] = {name='NPC Update',          description='Packet contains data about nearby targets (i.e. target\'s position, name).'}
data.incoming[0x017] = {name='Incoming Chat',       description='Packet contains data about incoming chat messages.'}
data.incoming[0x01B] = {name='Job Info',            description='Job Levels and levels unlocked.'}
data.incoming[0x01C] = {name='Inventory Count',     description='Describes number of slots in inventory.'}
data.incoming[0x01D] = {name='Finish Inventory',    description='Finish listing the items in inventory.'}
data.incoming[0x01E] = {name='Modify Inventory',    description='Modifies items in your inventory.'}
data.incoming[0x01F] = {name='Item Assign',         description='Assigns an ID to equipped items in your inventory.'}
data.incoming[0x020] = {name='Item Update',         description='Info about item in your inventory.'}
data.incoming[0x021] = {name='Trade Requested',     description='Sent when somebody offers to trade with you.'}
data.incoming[0x022] = {name='Trade Action',        description='Sent whenever something happens with the trade window.'}
data.incoming[0x023] = {name='Trade Item',          description='Sent when an item appears in the trade window.'}
data.incoming[0x025] = {name='Item Accepted',       description='Sent when the server will allow you to trade an item.'}
data.incoming[0x026] = {name='Count to 80',         description='It counts to 80 and does not have any obvious function. May have something to do with populating inventory.'}
data.incoming[0x027] = {name='String Message',      description='Message that includes a string as a parameter.'}
data.incoming[0x028] = {name='Action',              description='Packet sent when an NPC is attacking.'}
data.incoming[0x029] = {name='Action Message',      description='Packet sent for simple battle-related messages.'}
data.incoming[0x02A] = {name='Resting Message',     description='Packet sent when you rest in Abyssea.'}
data.incoming[0x02D] = {name='Kill Message',        description='Packet sent when you gain XP/LP/CP/JP/MP, advance RoE objectives, etc. by defeating a mob.'}
data.incoming[0x02E] = {name='Mog House Menu',      description='Sent when talking to moogle inside mog house.'}
data.incoming[0x02F] = {name='Digging Animation',   description='Generates the chocobo digging animation'}
data.incoming[0x030] = {name='Synth Animation',     description='Generates the synthesis animation'}
data.incoming[0x031] = {name='Synth List',          description='List of recipes or materials needed for a recipe'}
data.incoming[0x032] = {name='NPC Interaction 1',   description='Occurs before menus and some cutscenes'}
data.incoming[0x033] = {name='String NPC Interaction',description='Triggers a menu or cutscene to appear. Contains 4 strings.'}
data.incoming[0x034] = {name='NPC Interaction 2',   description='Occurs before menus and some cutscenes'}
data.incoming[0x036] = {name='NPC Chat',            description='Dialog from NPC\'s.'}
data.incoming[0x037] = {name='Update Char',         description='Updates a characters stats and animation.'}
data.incoming[0x038] = {name='Entity Animation',    description='Sent when a model should play a specific animation.'}
data.incoming[0x039] = {name='Env. Animation',      description='Sent to force animations to specific objects.'}
data.incoming[0x03A] = {name='Independ. Animation', description='Used for arbitrary battle animations that are unaccompanied by an action packet.'}
data.incoming[0x03C] = {name='Shop',                description='Displays items in a vendors shop.'}
data.incoming[0x03D] = {name='Shop Value/Sale',     description='Returns the value of an item or notice it has been sold.'}
data.incoming[0x03E] = {name='Open Buy/Sell',       description='Opens the buy/sell menu for vendors.'}
data.incoming[0x03F] = {name='Shop Buy Response',   description='Sent when you buy something from normal vendors.'}
data.incoming[0x041] = {name='Blacklist',           description='Contains player ID and name for blacklist.'}
data.incoming[0x042] = {name='Blacklist Command',   description='Sent in response to /blacklist add or /blacklist delete.'}
data.incoming[0x044] = {name='Job Info Extra',      description='Contains information about Automaton stats and set Blue Magic spells.'}
data.incoming[0x047] = {name='Translate Response',  description='Response to a translate request.'}
data.incoming[0x04B] = {name='Logout Acknowledge',  description='Acknowledges a logout attempt.'}
data.incoming[0x04B] = {name='Delivery Item',       description='Item in delivery box.'}
data.incoming[0x04C] = {name='Auction House Menu',  description='Sent when visiting auction counter.'}
data.incoming[0x04D] = {name='Servmes Resp',        description='Server response when someone requests it.'}
data.incoming[0x04F] = {name='Data Download 2',     description='The data that is sent to the client when it is "Downloading data...".'}
data.incoming[0x050] = {name='Equip',               description='Updates the characters equipment slots.'}
data.incoming[0x051] = {name='Model Change',        description='Info about equipment and appearance.'}
data.incoming[0x052] = {name='NPC Release',         description='Allows your PC to move after interacting with an NPC.'}
data.incoming[0x053] = {name='Logout Time',         description='The annoying message that tells how much time till you logout.'}
data.incoming[0x055] = {name='Key Item Log',        description='Updates your key item log on zone and when appropriate.'}
data.incoming[0x056] = {name='Quest/Mission Log',   description='Updates your quest and mission log on zone and when appropriate.'}
data.incoming[0x057] = {name='Weather Change',      description='Updates the weather effect when the weather changes.'}
data.incoming[0x058] = {name='Lock Target',         description='Locks your target.'}
data.incoming[0x05A] = {name='Server Emote',        description='This packet is the server\'s response to a client /emote p.'}
data.incoming[0x05B] = {name='Spawn',               description='Server packet sent when a new mob spawns in area.'}
data.incoming[0x05C] = {name='Dialogue Information',description='Used when all the information required for a menu cannot be fit in an NPC Interaction packet.'}
data.incoming[0x05E] = {name='Camp./Besieged Map',  description='Contains information about Campaign and Besieged status.'}
data.incoming[0x05F] = {name='Music Change',        description='Changes the current music.'}
data.incoming[0x061] = {name='Char Stats',          description='Packet contains a lot of data about your character\'s stats.'}
data.incoming[0x062] = {name='Skills Update',       description='Packet that shows your weapon and magic skill stats.'}
data.incoming[0x063] = {name='Set Update',          description='Frequently sent packet during battle that updates specific types of job information, like currently available/set automaton equipment and currently set BLU spells.'}
data.incoming[0x065] = {name='Repositioning',       description='Moves your character. Seems to be functionally idential to the Spawn packet'}
data.incoming[0x067] = {name='Pet Info',            description='Updates information about whether or not you have a pet and the TP, HP, etc. of the pet if appropriate.'}
data.incoming[0x068] = {name='Pet Status',          description='Updates information about whether or not you have a pet and the TP, HP, etc. of the pet if appropriate.'}
data.incoming[0x06F] = {name='Self Synth Result',   description='Results of an attempted synthesis process by yourself.'}
data.incoming[0x070] = {name='Others Synth Result', description='Results of an attempted synthesis process by others.'}
data.incoming[0x071] = {name='Campaign Map Info',   description='Populates the Campaign map.'}
data.incoming[0x075] = {name='Unity Start',         description='Creates the timer and glowing fence that accompanies Unity fights.'}
data.incoming[0x076] = {name='Party Buffs',         description='Packet updated every time a party member\'s buffs change.'}
data.incoming[0x078] = {name='Proposal',            description='Carries proposal information from a /propose or /nominate command.'}
data.incoming[0x079] = {name='Proposal Update',     description='Proposal update following a /vote command.'}
data.incoming[0x082] = {name='Guild Buy Response',  description='Buy an item from a guild.'}
data.incoming[0x083] = {name='Guild Inv List',      description='Provides the items, prices, and counts for guild inventories.'}
data.incoming[0x084] = {name='Guild Sell Response', description='Sell an item to a guild.'}
data.incoming[0x085] = {name='Guild Sale List',     description='Provides the items, prices, and counts for guild inventories.'}
data.incoming[0x086] = {name='Guild Open',          description='Sent to update the current guild status or open the guild buy/sell menu.'}
data.incoming[0x08C] = {name='Merits',              description='Contains all merit information. 3 packets are sent.'}
data.incoming[0x08D] = {name='Job Points',          description='Contains all job point information. 12 packets are sent.'}
data.incoming[0x0A0] = {name='Party Map Marker',    description='Marks where players are on your map.'}
data.incoming[0x0AA] = {name='Spell List',          description='Packet that shows the spells that you know.'}
data.incoming[0x0AC] = {name='Ability List',        description='Packet that shows your current abilities and traits.'}
data.incoming[0x0AE] = {name='Mount List',          description='Packet that shows your current mounts.'}
data.incoming[0x0B4] = {name='Seek AnonResp',       description='Server response sent after you put up party or anon flag.'}
data.incoming[0x0B5] = {name='Help Desk Open',      description='Sent when you open the Help Desk submenu.'}
data.incoming[0x0BF] = {name='Reservation Response',description='Sent to inform the client about the status of entry to an instanced area.'}
data.incoming[0x0C8] = {name='Party Struct Update', description='Updates all party member info in one struct. No player vital data (HP/MP/TP) or names are sent here.'}
data.incoming[0x0C9] = {name='Show Equip',          description='Shows another player your equipment after using the Check command.'}
data.incoming[0x0CA] = {name='Bazaar Message',      description='Shows another players bazaar message after using the Check command or sets your own on zoning.'}
data.incoming[0x0CC] = {name='Linkshell Message',   description='/lsmes text and headers.'}
data.incoming[0x0D2] = {name='Found Item',          description='This command shows an item found on defeated mob or from a Treasure Chest.'}
data.incoming[0x0D3] = {name='Lot/drop item',       description='Sent when someone casts a lot on an item or when the item drops to someone.'}
data.incoming[0x0DC] = {name='Party Invite',        description='Party Invite packet.'}
data.incoming[0x0DD] = {name='Party Member Update', description='Alliance/party member info - zone, HP%, HP% etc.'}
data.incoming[0x0DF] = {name='Char Update',         description='A packet sent from server which updates character HP, MP and TP.'}
data.incoming[0x0E0] = {name='Linkshell Equip',     description='Updates your linkshell menu with the current linkshell.'}
data.incoming[0x0E1] = {name='Party Member List',   description='Sent when you look at the party member list.'}
data.incoming[0x0E2] = {name='Char Info',           description='Sends name, HP, HP%, etc.'}
data.incoming[0x0F4] = {name='Widescan Mob',        description='Displays one monster.'}
data.incoming[0x0F5] = {name='Widescan Track',      description='Updates information when tracking a monster.'}
data.incoming[0x0F6] = {name='Widescan Mark',       description='Marks the start and ending of a widescan list.'}
data.incoming[0x0F9] = {name='Reraise Activation',  description='Reassigns targetable status on reraise activation?'}
data.incoming[0x0FA] = {name='Furniture Interact',  description='Confirms furniture manipulation.'}
data.incoming[0x105] = {name='Data Download 4',     description='The data that is sent to the client when it is "Downloading data...".'}
data.incoming[0x106] = {name='Bazaar Seller Info',  description='Information on the purchase sent to the buyer when they attempt to buy something.'}
data.incoming[0x107] = {name='Bazaar closed',       description='Tells you when a bazaar you are currently in has closed.'}
data.incoming[0x108] = {name='Data Download 5',     description='The data that is sent to the client when it is "Downloading data...".'}
data.incoming[0x109] = {name='Bazaar Purch. Info',  description='Information on the purchase sent to the buyer when the purchase is successful.'}
data.incoming[0x10A] = {name='Bazaar Buyer Info',   description='Information on the purchase sent to the seller when a sale is successful.'}
data.incoming[0x110] = {name='Sparks Update',       description='Occurs when you sparks increase and generates the related message.'}
data.incoming[0x111] = {name='Eminence Update',     description='Causes Records of Eminence messages.'}
data.incoming[0x112] = {name='RoE Quest Log',       description='Updates your RoE quest log on zone and when appropriate.'}
data.incoming[0x113] = {name='Currency Info',       description='Contains all currencies to be displayed in the currency menu.'}
data.incoming[0x115] = {name='Fish Bite Info',      description='Contains information about the fish that you hooked.'}
data.incoming[0x116] = {name='Equipset Build Response', description='Returned from the server when building a set.'}
data.incoming[0x117] = {name='Equipset Response',   description='Returned from the server after the /equipset command.'}
data.incoming[0x118] = {name='Currency 2 Info',     description='Contains all currencies to be displayed in the currency menu.'}
data.incoming[0x119] = {name='Ability Recasts',     description='Contains the currently available job abilities and their remaining recast times.'}

return data

--[[
Copyright © 2013-2015, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

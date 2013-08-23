--[[
This file returns a table of known packet data.
]]

local data = {}
data.incoming = {}
data.outgoing = {}

-- Client packets (outgoing)
data.outgoing[0x00A] = {name='Client Connect',      description='(unencrypted/uncompressed) First packet sent when connecting to new zone.'}
data.outgoing[0x00D] = {name='Client Leave',        description='Last packet sent from client before it leaves the zone.'}
data.outgoing[0x015] = {name='Standard Client',     description='Packet contains data that is sent almost every time (i.e your character\'s position).'}
data.outgoing[0x01A] = {name='Action',              description='An action being done on a target (i.e. an attack or spell).'}
data.outgoing[0x028] = {name='Drop Item',           description='Drops an item.'}
data.outgoing[0x029] = {name='Move Item',           description='Move item from one inventory to another.'}
data.outgoing[0x032] = {name='Offer Trade',         description='This is sent when you offer to trade somebody.'}
data.outgoing[0x033] = {name='Trade Tell',          description='This packet allows you to accept or cancel a trade request.'}
data.outgoing[0x034] = {name='Trade Item',          description='Sends the item you want to trade to the server.'}
data.outgoing[0x037] = {name='Use Item',            description='Use an item.'}
data.outgoing[0x03A] = {name='Sort Item',           description='Packet sent when you choose to auto-sort your inventory.'}
data.outgoing[0x04B] = {name='Servmes',             description='Requests the server message (/servmes).'}
data.outgoing[0x04E] = {name='Auction',             description='Used to bid on an Auction House item.'}
data.outgoing[0x050] = {name='Equip',               description='This command is used to equip your character.'}
data.outgoing[0x05A] = {name='Conquest',            description='This command asks the server for data pertaining to conquest/besieged status.'}
data.outgoing[0x05B] = {name='Dialog choice',       description='Chooses a dialog option.'}
data.outgoing[0x05D] = {name='Emote',               description='This command is used in emotes.'}
data.outgoing[0x05E] = {name='Reqest Zone',         description='Request from the client to zone.'}
data.outgoing[0x061] = {name='Equipment Screen',    description='This command is used when you open your equipment screen.'}
data.outgoing[0x06E] = {name='Invite Player',       description='Used for Inviting.'}
data.outgoing[0x083] = {name='Buy Item',            description='Buy an item.'}
data.outgoing[0x084] = {name='Appraise',            description='Ask server for selling price.'}
data.outgoing[0x085] = {name='Sell Item',           description='Sell an item from your inventory.'}
data.outgoing[0x096] = {name='Synth',               description='Packet sent containing all data of an attempted synth.'}
data.outgoing[0x0B5] = {name='Speech',              description='Packet contains normal speech.'}
data.outgoing[0x0B6] = {name='Tell',                description='/tell\'s sent from client.'}
data.outgoing[0x0DC] = {name='Type Bitmask',        description='This command is sent when change your party-seek or /anon status.'}
data.outgoing[0x0DD] = {name='Check',               description='Used to check other players.'}
data.outgoing[0x0DE] = {name='Set Bazaar Message',  description='Sets your bazaar message.'}
data.outgoing[0x0EA] = {name='Sit',                 description='A request to sit or stand is sent to the server.'}
data.outgoing[0x0E7] = {name='Logout',              description='A request to logout of the server.'}
data.outgoing[0x0E8] = {name='Toggle Heal',         description='This command is used to both heal and cancel healing.'}
data.outgoing[0x0F1] = {name='Cancel',              description='Sent when canceling a buff.'}
data.outgoing[0x0F4] = {name='Widescan',            description='This command asks the server for a widescan.'}
data.outgoing[0x100] = {name='Job Change',          description='Sent when initiating a job change.'}
data.outgoing[0x104] = {name='Leave Bazaar',        description='Sent when client leaves a bazaar.'}
data.outgoing[0x105] = {name='View Bazaar',         description='Sent when viewing somebody\'s bazaar.'}
data.outgoing[0x106] = {name='Buy Bazaar Item',     description='Buy an item from somebody\'s bazaar.'}
data.outgoing[0x10A] = {name='Set Price',           description='Set the price on a bazaar item.'}

-- Server packets (incoming)
data.incoming[0x009] = {name='Standard Message',    description='A standardized message send from FFXI.'}
data.incoming[0x00A] = {name='Data Download 1',     description='Info about character and zone around it.'}
data.incoming[0x00B] = {name='Zone Response',       description='Response from the server confirming client can zone.'}
data.incoming[0x00D] = {name='PC Update',           description='Packet contains info about another PC (i.e. coordinates).'}
data.incoming[0x00E] = {name='NPC Update',          description='Packet contains data about nearby targets (i.e. target\'s position, name).'}
data.incoming[0x017] = {name='Incoming Chat',       description='Packet contains data about incoming chat messages.'}
data.incoming[0x01B] = {name='Job Info',            description='Job Levels and levels unlocked.'}
data.incoming[0x01C] = {name='Inventory Count',     description='Describes number of slots in inventory.'}
data.incoming[0x01D] = {name='Finish Inventory',    description='Finish listing the items in inventory.'}
data.incoming[0x01E] = {name='Modify Inventory',    description='Modifies items in your inventor.'}
data.incoming[0x01F] = {name='Item Assign',         description='Assigns an ID to equipped items in your inventory.'}
data.incoming[0x020] = {name='Item Update',         description='Info about item in your inventory.'}
data.incoming[0x021] = {name='Trade Requested',     description='Sent when somebody offers to trade with you.'}
data.incoming[0x022] = {name='Trade Action',        description='Sent whenever something happens with the trade window.'}
data.incoming[0x025] = {name='Item Accepted',       description='Sent when the server will allow you to trade an item.'}
data.incoming[0x026] = {name='Count to 80',         description='It counts to 80 and does not have any obvious function. May have something to do with populating inventory.'}
data.incoming[0x028] = {name='Action',              description='Packet sent when an NPC is attacking.'}
data.incoming[0x029] = {name='Action Message',      description='Packet sent for simple battle-related messages.'}
data.incoming[0x02A] = {name='Resting Message',     description='Packet sent when you rest in Abyssea.'}
data.incoming[0x02D] = {name='EXP Gain (kill)',     description='Packet sent after you defeat a mob and gain XP.'}
data.incoming[0x030] = {name='Synth Animation',     description='Generates the synthesis animation'}
data.incoming[0x036] = {name='NPC Chat',            description='Dialog from NPC\'s.'}
data.incoming[0x037] = {name='Update Char',         description='Updates a characters stats and animation.'}
data.incoming[0x03C] = {name='Shop',                description='Displays items in a vendors shop.'}
data.incoming[0x03D] = {name='Value',               description='Returns the value of an item.'}
data.incoming[0x041] = {name='Stupid Evil Packet',  description='This packet is stupid and evil. Required for emotes.'}
data.incoming[0x044] = {name='Pet Stat',            description='Contains information about Automaton stats and may be involved in Blue Magic.'}
data.incoming[0x04B] = {name='Logout Acknowledge',  description='Acknoledges a logout attempt.'}
data.incoming[0x04B] = {name='Delivery Item',       description='Item in delivery box.'}
data.incoming[0x04D] = {name='Servmes Resp',        description='Server response when someone requests it.'}
data.incoming[0x04F] = {name='Data Download 2',     description='The data that is sent to the client when it is "Downloading data...".'}
data.incoming[0x050] = {name='Equip',               description='Updates the characters equipment slots.'}
data.incoming[0x051] = {name='Data Download 3',     description='Info about equipment and appearance.'}
data.incoming[0x052] = {name='NPC Release',         description='Allows your PC to move after interacting with an NPC.'}
data.incoming[0x053] = {name='Logout Time',         description='The annoying message that tells how much time till you logout.'}
data.incoming[0x056] = {name='Quest/Mission Log',   description='Updates your quest and mission log on zone and when appropriate.'}
data.incoming[0x057] = {name='Weather Change',      description='Updates the weather effect when the weather changes.'}
data.incoming[0x058] = {name='Lock Target',         description='Locks your target.'}
data.incoming[0x05A] = {name='Server Emote',        description='This packet is the server\'s response to a client /emote p.'}
data.incoming[0x05B] = {name='Spawn',               description='Server packet sent when a new mob spawns in area.'}
data.incoming[0x05E] = {name='Stop Download',       description='Final packet in a DataDld transmission. May be the only packet in a DataDld sequence.'}
data.incoming[0x061] = {name='Char Stats',          description='Packet contains a lot of data about your character\'s stats.'}
data.incoming[0x062] = {name='Skills Update',       description='Packet that shows your weapon and magic skill stats.'}
data.incoming[0x067] = {name='Unnamed Packet 67',   description='Packet that sends mostly useless information, as far as I can tell.'}
data.incoming[0x08C] = {name='IDs in party',    	description='Packet that returns ids of people in party'}
data.incoming[0x0AC] = {name='Ability List',        description='Packet that shows your current abilities and traits.'}
data.incoming[0x0B4] = {name='Seek AnonResp',       description='Server response sent after you put up party or anon flag.'}
data.incoming[0x0C9] = {name='Show Equip',          description='Shows another player your equipment after using the Check command.'}
data.incoming[0x0CC] = {name='Linkshell Message',   description='/lsmes text and headers.'}
data.incoming[0x0CA] = {name='Bazaar Message',      description='Shows another players bazaar message after using the Check command or sets your own on zoning.'}
data.incoming[0x0D2] = {name='Found Item',          description='This command shows an item found on defeated mob.'}
data.incoming[0x0DD] = {name='Alliance Update',     description='Alliance/party member info - zone, HP%, HP% etc.'}
data.incoming[0x0DF] = {name='Char Update',         description='A packet sent from server which updates character HP, MP and TP.'}
data.incoming[0x0E2] = {name='Char Info',           description='Sends name, HP, HP%, etc.'}
data.incoming[0x0F4] = {name='Widescan Mob',        description='Displays one monster.'}
data.incoming[0x0F6] = {name='Widescan Mark',       description='Marks the start and ending of a widescan list.'}
data.incoming[0x0F9] = {name='Reraise Activation',  description='Reassigns targetable status on reraise activation?'}
data.incoming[0x105] = {name='Data Download 4',     description='The data that is sent to the client when it is "Downloading data...".'}
data.incoming[0x108] = {name='Data Download 5',     description='The data that is sent to the client when it is "Downloading data...".'}

return data

--[[
Copyright (c) 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'itemizer'
_addon.author = 'Ihina'
_addon.version = '1.0.0.0'
_addon.command = 'itemizer'

require 'tablehelper'
require 'chat'
require 'logger'
require 'actionhelper'
config = require('config')
res = require('resources')

bagIndex = {}
bagIndex['inventory'] = 0
bagIndex['safe'] = 1
bagIndex['storage'] = 2
bagIndex['locker'] = 3
bagIndex['satchel'] = 5
bagIndex['sack'] = 6

bagTable = {}
function bagTable.inventory() return windower.ffxi.get_items().inventory end
function bagTable.safe() return  windower.ffxi.get_items().safe end
function bagTable.storage() return windower.ffxi.get_items().storage end
function bagTable.locker() return windower.ffxi.get_items().locker end
function bagTable.satchel() return windower.ffxi.get_items().satchel end
function bagTable.sack() return windower.ffxi.get_items().sack end

bagFunc = {}
function bagFunc.get (x,y) windower.ffxi.get_item(x, y) end
function bagFunc.put (x,y) windower.ffxi.put_item(x, y) end

windower.register_event('unhandled command', function(...) 
	local param = L{...}

	if param[1] == 'get' or param[1] == 'put' then
		command = param[1]
		bag = param[param:length()]
		local search = bag
		if command == 'put' then
			search = 'inventory' 
		end
				
		param:remove(0)
		param:remove(param:length())
		item = tostring(param):split(','):concat('')
		item = (item:slice(2, item:length() - 1))
		
		local id = res.items:name(windower.wc_match-{item})
		if id:length() == 0 then
			id = res.items:name_full(windower.wc_match-{item})
			if id:length() == 0 then
				log("Unknown item")
				return
			end
		end
		
		t = bagTable[search]()
		for slot, item in pairs(t) do 
			if id[item.id] then 
				bagFunc[param[0]](bagIndex[bag], slot)
				return
			end 
		end
		log("Item not found")
	end	
end)

--[[
Copyright (c) 2013, Ihina
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Silence nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL IHINA BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
--and thank Arcon for practically writing half this code

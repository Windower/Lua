--[[
Copyright © 2018, from20020516
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of checkparam nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL from20020516 BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.name = 'Checkparam'
_addon.author = 'from20020516'
_addon.version = '1.1'
_addon.commands = {'cp','checkparam'}

require('logger')
res = require('resources')
extdata = require('extdata')
config = require('config')
packets = require('packets')

defaults = {
  NON = 'fast cast',
  WAR = 'store tp|double attack|triple attack|quadruple attack|weapon skill damage',
  MNK = 'store tp|double attack|triple attack|quadruple attack|martial arts|subtle blow',
  WHM = 'cure potency|cure potency ii|fast cast|cure spellcasting time|enmity|healing magic casting time|divine benison|damage taken|physical damage taken|magic damage taken',
  BLM = 'magic attack bonus|magic burst damage|magic burst damage ii|int|magic accuracy|magic damage|fast cast|elemental magic casting time',
  RDM = 'magic attack bonus|magic burst damage|magic burst damage ii|magic accuracy|fast cast|enfeebling magic skill|enhancing magic skill|store tp|dual wield',
  THF = 'store tp|double attack|triple attack|quadruple attack|dual wield',
  PLD = 'enmity|damage taken|physical damage taken|magic damage taken|spell inturruption rate|pharanx|cure potency|fastcast',
  DRK = 'store tp|double attack|triple attack|quadruple attack|weapon skill damage',
  BST = 'pet: double attack|pet: magic attack bonus|pet: damage taken',
  BRD = 'all songs|song effect duration|fast cast|song spellcasting time',
  RNG = 'store tp|snapshot|rapid shot|weapon skill damage',
  SAM = 'store tp|double attack|triple attack|quadruple attack|weapon skill damage',
  NIN = 'store tp|double attack|triple attack|quadruple attack|subtle blow',
  DRG = 'store tp|double attack|triple attack|quadruple attack|weapon skill damage',
  SMN = 'blood pact delay|blood pact delay ii|blood pact damage|avatar perpetuation cost|pet: magic attack bonus|pet: str|pet: double attack',
  BLU = 'store tp|double attack|triple attack|quadruple attack|critical hit rate|critical hit damage|weapon skill damage|fast cast|magic attack bonus|magic accuracy|cure potency',
  COR = 'store tp|snapshot|rapid shot|fast cast|cure potency|magic accuracy|magic attack bonus|magic damage|weapon skill damage',
  PUP = 'pet: hp|pet: damage taken|pet: regen|martial arts|store tp|double attack|triple attack|quadruple attack',
  DNC = 'store tp|double attack|triple attack|quadruple attack',
  SCH = 'magic attack bonus|magic burst damage|magic burst damage ii|magic accuracy|magic damage|fast cast|elemental magic casting time|cure potency|enh mag eff dur|enhancing magic effect duration',
  GEO = 'pet: regen|pet: damage taken|indicolure effect duration|indi eff dur|fast cast|magic evasion',
  RUN = 'enmity|damage taken|physical damage taken|magic damage taken|spell inturruption rate|pharanx|inquartata|fastcast',
  debugmode = false,
}
settings = config.load(defaults)

tbl = {}

windower.register_event('incoming chunk',function(id,data)
  if id == 0x0C9 then
    local p = packets.parse('incoming',data)
    if p['Type'] == 3 then
      local count = p['Count']
      if count == 1 then
        get_text(p['Item'],p['ExtData'])
      else
        for i=1,count do
          get_text(p['Item '..i],p['ExtData '..i])
        end
      end
    elseif p['Type'] == 1 then --metadata
      local t = windower.ffxi.get_mob_by_id(p['Target ID'])
      local mjob = res.jobs[p['Main Job']].ens
      local sjob = res.jobs[p['Sub Job']].ens
      show_results(t.name,mjob,sjob)
    end
  end
end)

function get_text(id,data)
  config.reload(settings)
  local descriptions = res.item_descriptions[id]
  local helptext = descriptions and descriptions.english or '' --for 'vanilla' items. e.g. Moonshade Earring
  local stats = windower.regex.split(helptext,'(Pet|Avatar|Automaton|Wyvern|Luopan): ')
  for i,v in ipairs(windower.regex.split(stats[1],'\n')) do
    split_text(id,v)
  end
  if stats[2] then
    local pet_text = windower.regex.replace(stats[2],'\n',' ')
    split_text(id,pet_text,'pet: ')
  end
  local ext = extdata.decode({id=id,extdata=data})
  if ext.augments then
    for i,v in ipairs(ext.augments) do
      split_text(id,v)
    end
  end
  if enhanced[id] then
    local stats = enhanced[id]:gsub('([+-:][0-9]+)',',%1'):split(',')
    tbl[stats[1]] = tonumber(stats[2]) + (tbl[stats[1]] or 0)
    if settings.debugmode then
      log(id,res.items[id].english,stats[1],stats[2],tbl[stats[1]])
    end
  end
end

function split_text(id,text,arg)
  for key,value in string.gmatch(text,'/?([%D]-):?([%+%-]?[0-9]+)%%?%s?') do
    local key = windower.regex.replace(string.lower(key),'(\\"|\\.|\\s$)','')
    local key = integrate[key] or key
    local key = arg and arg..key or key
    tbl[key] = tonumber(value) + (tbl[key] or 0)
    if settings.debugmode then
      log(id,res.items[id].english,key,value,tbl[key])
    end
  end
end

function show_results(name,mjob,sjob)
  local stats = settings[mjob]
  local head = '<'..mjob..'/'..sjob..'>'
  windower.add_to_chat(160,string.color(name,1,160)..': '..string.color(head,160,160))
  if mjob == 'NON' then
    notice('Unknown job because /anon state. instead display <NON>.')
  end
  for index,key in ipairs(windower.regex.split(stats,'[|]')) do
    local value = tbl[string.lower(key)]
    local color = {value and 1 or 160,value and 166 or 160}
    windower.add_to_chat(160,' ['..string.color(key,color[1],160)..'] '..string.color(tostring(value),color[2],160))
  end
  tbl = {}
  collectgarbage()
end

windower.register_event('load',function()
  print('Checkparam: Activate with in-game /check command.')
end)

integrate = {
  --[[integrate same property.information needed for development. @from20020516]]
  ['quad atk'] = 'quadruple attack',
  ['triple atk'] = 'triple attack',
  ['double atk'] = 'double attack',
  ['dblatk'] = 'double attack',
  ['blood pact ability delay'] = 'blood pact delay',
  ['blood pact ability delay ii'] = 'blood pact delay ii',
  ['blood pact ab. del. ii'] = 'blood pact delay ii',
  ['blood pact recast time ii'] = 'blood pact delay ii',
  ['blood pact dmg'] = 'blood pact damage',
  ['enhancing magic duration'] = 'enhancing magic effect duration',
  ['eva'] = 'evasion',
  ['indicolure spell duration'] = 'indicolure effect duration',
  ['mag eva'] = 'magic evasion',
  ['magic atk bonus'] = 'magic attack bonus',
  ['magatkbns'] = 'magic attack bonus',
  ['mag atk bonus'] = 'magic attack bonus',
  ['mag acc'] = 'magic accuracy',
  ['magic burst dmg'] = 'magic burst damage',
  ['mag dmg'] = 'magic damage',
  ['crithit rate'] = 'critical hit rate',
}
enhanced = {
  [10392] = 'cursna+10', --Malison Medallion
  [10393] = 'cursna+15', --Debilis Medallion
  [10394] = 'fast cast+5', --Orunmila's Torque
  [10469] = 'fast cast+10', --Eirene's Manteel
  [10752] = 'fast cast+2', --Prolix Ring
  [10790] = 'cursna+10', --Ephedra Ring
  [10791] = 'cursna+15', --Haoma's Ring
  [10802] = 'fast cast+5', --Majorelle Shield
  [10826] = 'fast cast+3', --Witful Belt
  [10838] = 'dual wield+5', --Patentia Sash
  [11000] = 'fast cast+3', --Swith Cape
  [11001] = 'fast cast+4', --Swith Cape +1
  [11037] = 'stoneskin+10', --Earthcry Earring
  [11051] = 'increases resistance to all status ailments+5', ----Hearty Earring
  [11544] = 'fast cast+1', --Veela Cape
  [11602] = 'martial arts+10', --Cirque Necklace
  [11603] = 'dual wield+3', --Charis Necklace
  [11615] = 'fast cast+5', --Orison Locket
  [11707] = 'fast cast+2', --Estq. Earring
  [11711] = 'rewards+2', --Ferine Earring
  [11715] = 'dual wield+1', --Iga Mimikazari
  [11722] = 'sublimation+1', --Savant's Earring
  [11732] = 'dual wield+5', --Nusku's Sash
  [11734] = 'martial arts+10', --Shaolin Belt
  [11735] = 'snapshot+3', --Impulse Belt
  [11753] = 'aquaveil+1', --Emphatikos Rope
  [11775] = 'occult acumen+20', --Oneiros Rope
  [11856] = 'fast cast+10', --Anhur Robe
  [13177] = 'stoneskin+30', --Stone Gorget
  [14739] = 'dual wield+5', --Suppanomimi
  [14812] = 'fast cast+2', --Loquac. Earring
  [14813] = 'double attack+5', --Brutal Earring
  [15857] = 'drain and aspir potency+5', --Excelsis Ring
  [15960] = 'stoneskin+20', --Siegel Sash
  [15962] = 'magic burst damage+5', --Static Earring
  [16209] = 'snapshot+5', --Navarch's Mantle
  [19062] = 'divine benison+1', --Yagrush80
  [19082] = 'divine benison+2', --Yagrush85
  [19260] = 'dual wield+3', --Raider's Bmrng.
  [19614] = 'divine benison+3', --Yagrush90
  [19712] = 'divine benison+3', --Yagrush95
  [19821] = 'divine benison+3', --Yagrush99
  [19950] = 'divine benison+3', --Yagrush99+
  [20509] = 'counter+14', --Spharai119AG
  [20511] = 'martial arts+55', --Kenkonken119AG
  [21062] = 'divine benison+3', --Yagrush119
  [21063] = 'divine benison+3', --Yagrush119+
  [21078] = 'divine benison+3', --Yagrush119AG
  [21201] = 'fast cast+2', --Atinian Staff +1
  [27768] = 'fast cast+5', --Cizin Helm
  [27775] = 'fast cast+10', --Nahtirah Hat
  [28054] = 'fast cast+7', --Gendewitha Gages
  [28058] = 'snapshot+4', --Manibozho Gloves
  [28184] = 'fast cast+5', --Orvail Pants +1
  [28197] = 'snapshot+9', --Nahtirah Trousers
  [28206] = 'fast cast+10', --Geomancy Pants
  [28335] = 'cursna+10', --Gende. Galoshes
  [28582] = 'magic burst damage+5', --Locus Ring
  [28619] = 'cursna+15', --Mending Cape
  [28631] = 'elemental siphon+30', --Conveyance Cape
  [28637] = 'fast cast+7', --Lifestream Cape
}

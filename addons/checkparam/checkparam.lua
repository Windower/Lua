_addon.name = 'checkparam'
_addon.author = 'from20020516'
_addon.version = '1.0'
_addon.commands = {'cp','checkparam'}
res,extdata,config = require('resources'),require('extdata'),require('config')
settings = config.load('data/settings.xml')
function key_define()
    job_define = settings[windower.ffxi.get_player().main_job:lower()]
    return job_define and windower.regex.split(job_define,'[|]')
        or {'store tp','quadruple attack','triple attack','double attack','',
            'magic accuracy','fast cast','haste','dual wield','',
            'magic attack bonus','magic burst damage','magic damage','',
            'enmity','cure potency'}
end
function split_text(txt,id,arg)
    for key,value in string.gmatch(txt,"/?([%D]-):?([%+%-]?[0-9]+)%%?%s?") do
        local key = windower.regex.replace(string.lower(key),'(\\"|\\.|\\s$)','')
        local key = integrate[key] or key
        local key = arg and arg..key or key
        tbl[key] = tonumber(value) + (tbl[key] or 0)
        if debug then
            local color = windower.regex.match(key,'enhanced') and 170
            windower.add_to_chat(color or 72,'['..id..']'..res.items[id].en..'['..key..'] '..value..' '..tbl[key])
        end
    end
end
function checkparam(arg1)
    debug = arg1=='debug'
    tbl,txt={},
    windower.send_command('input /checkparam <me>')
    for slot,bag in pairs(windower.ffxi.get_items().equipment) do
        gtbl = windower.ffxi.get_items().equipment
        if not string.find(slot,'_bag') then
            gear = windower.ffxi.get_items(gtbl[slot..'_bag'],gtbl[slot])
            if gtbl[slot] > 0 and gear.id < 65535 then
                if res.item_descriptions[gear.id] then
                    local txt = windower.regex.split(res.item_descriptions[gear.id].en,"(Pet|Avatar|Automaton|Wyvern|Luopan): ")
                    for i,v in pairs(windower.regex.split(txt[1],"\n")) do
                        split_text(v,gear.id)
                    end
                    if txt[2] then
                        local txt = windower.regex.replace(txt[2],'\n',' ')
                        split_text(txt,gear.id,'pet: ')
                    end
                end
                if gear.extdata and extdata.decode(gear).type == 'Augmented Equipment' then
                    for slot,augment in pairs(extdata.decode(gear).augments) do
                        split_text(augment,gear.id)
                    end
                end
                if enhanced[res.items[gear.id].en] then
                    local txt = string.split(string.gsub(enhanced[res.items[gear.id].en], "([+-:][0-9]+)",",%1"),",")
                    tbl[txt[1]] = tonumber(txt[2]) + (tbl[txt[1]] or 0)
                    if debug then
                        windower.add_to_chat(170,'['..gear.id..']'..res.items[gear.id].en..'['..txt[1]..'] '..txt[2]..' '..tbl[txt[1]])
                    end
                end
            end
        end
    end
    windower.add_to_chat(69, '//checkparam')
    for index,key in pairs(key_define()) do
        txt = key == '' and txt..'\n' or (txt or '')..'['..key..'] '..(tbl[string.lower(key)] or 0)..' '
    end
    windower.add_to_chat(70, txt)
    collectgarbage()
end
integrate={
--[[integrate same property.information needed for development. @from20020516]]
['quad atk']='quadruple attack',
['triple atk']='triple attack',
['double atk']='double attack',
['dblatk']='double attack',
['blood pact ability delay']='blood pact delay',
['blood pact ability delay ii']='blood pact delay ii',
['blood pact ab. del. ii']='blood pact delay ii',
['blood pact recast time ii']='blood pact delay ii',
['blood pact dmg']='blood pact damage',
['enhancing magic duration']='enhancing magic effect duration',
['eva']='evasion',
['indicolure spell duration']='indicolure effect duration',
['mag eva']='magic evasion',
['magic atk bonus']='magic attack bonus',
['magatkbns']='magic attack bonus',
['mag atk bonus']='magic attack bonus',
['mag acc']='magic accuracy',
['magic burst dmg']='magic burst damage',
['mag dmg']='magic damage',
['crithit rate']='critical hit rate',
}
enhanced={
['Anhur Robe']='fast cast+10',
['Atinian Staff +1']='fast cast+2',
['Brutal Earring']='double attack+5',
['Charis Necklace']='dual wield+3',
['Cirque Necklace']='martial arts+10',
['Cizin Helm']='fast cast+5',
['Conveyance Cape']='elemental siphon+30',
['Debilis Medallion']='cursna+15',
['Earthcry Earring']='stoneskin+10',
['Eirene\'s Manteel']='fast cast+10',
['Emphatikos Rope']='aquaveil+1',
['Ephedra Ring']='cursna+10',
['Estq. Earring']='fast cast+2',
['Excelsis Ring']='drain and aspir potency+5',
['Ferine Earring']='rewards+2',
['Gende. Galoshes']='cursna+10',
['Gendewitha Gages']='fast cast+7',
['Geomancy Pants']='fast cast+10',
['Haoma\'s Ring']='cursna+15',
['Hearty Earring']='increases resistance to all status ailments+5',
['Iga Mimikazari']='dual wield+1',
['Impulse Belt']='snapshot+3',
['Kenkonken']='martial arts+55',
['Lifestream Cape']='fast cast+7',
['Locus Ring']='magic burst damage+5',
['Loquac. Earring']='fast cast+2',
['Majorelle Shield']='fast cast+5',
['Malison Medallion']='cursna+10',
['Manibozho Gloves']='snapshot+4',
['Mending Cape']='cursna+15',
['Nahtirah Hat']='fast cast+10',
['Nahtirah Trousers']='snapshot+9',
['Navarch\'s Mantle']='snapshot+5',
['Nusku\'s Sash']='dual wield+5',
['Oneiros Rope']='occult acumen+20',
['Orison Locket']='fast cast+5',
['Orunmila\'s Torque']='fast cast+5',
['Orvail Pants +1']='fast cast+5',
['Patentia Sash']='dual wield+5',
['Prolix Ring']='fast cast+2',
['Raider\'s Bmrng.']='dual wield+3',
['Static Earring']='magic burst damage+5',
['Savant\'s Earring']='sublimation+1',
['Shaolin Belt']='martial arts+10',
['Siegel Sash']='stoneskin+20',
['Spharai']='counter+14',
['Stone Gorget']='stoneskin+30',
['Suppanomimi']='dual wield+5',
['Swith Cape +1']='fast cast+4',
['Swith Cape']='fast cast+3',
['Veela Cape']='fast cast+1',
['Witful Belt']='fast cast+3',
['Yagrush']='divine benison+3',
}
windower.register_event('addon command', checkparam)
windower.send_command('cp')
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
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
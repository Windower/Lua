--Copyright (c) 2013~2016, Byrthnoth
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-- Convert the spells and job abilities into a referenceable list of aliases --
 
unify_prefix = {['/ma'] = '/ma', ['/magic']='/ma',['/jobability'] = '/ja',['/ja']='/ja',['/item']='/item',['/song']='/ma',
    ['/so']='/ma',['/ninjutsu']='/ma',['/weaponskill']='/ws',['/ws']='/ws',['/ra']='/ra',['/rangedattack']='/ra',['/nin']='/ma',
    ['/throw']='/ra',['/range']='/ra',['/shoot']='/ra',['/monsterskill']='/ms',['/ms']='/ms',['/pet']='/ja',['Monster']='Monster',['/bstpet']='/ja'}

action_type_map = {['/ja']='Ability',['/jobability']='Ability',['/so']='Magic',['/song']='Magic',['/ma']='Magic',['/magic']='Magic',['/nin']='Magic',['/ninjutsu']='Magic',
    ['/ra']='Ranged Attack',['/range']='Ranged Attack',['/throw']='Ranged Attack',['/shoot']='Ranged Attack',['/ms']='Ability',['/monsterskill']='Ability',
    ['/ws']='Ability',['/weaponskill']='Ability',['/item']='Item',['/pet']='Ability',['/bstpet']='Ability',['Monster']='Monster Move'}

usable_item_bags = {
    res.bags[3],  -- Temporary Items
    res.bags[0],  -- Inventory
    res.bags[8],  -- Wardrobe 1
    res.bags[10], -- Wardrobe 2
    res.bags[11], -- Wardrobe 3
    res.bags[12]} -- Wardrobe 4

equippable_item_bags = {
    res.bags[0],  -- Inventory
    res.bags[8],  -- Wardrobe 1
    res.bags[10], -- Wardrobe 2
    res.bags[11], -- Wardrobe 3
    res.bags[12]} -- Wardrobe 4
    
bag_string_lookup = {}
for i,v in pairs(res.bags) do
    bag_string_lookup[to_windower_bag_api(v.en)]=i
end
    
bstpet_range = {min=672,max=798} -- Range of the JA resource devoted to BST jugpet abilities
    
delay_map_to_action_type = {['Ability']=3,['Magic']=20,['Ranged Attack']=10,['Item']=10,['Monster Move']=10,['Interruption']=3}
    
validabils = {}
validabils['english'] = {['/ma'] = {}, ['/ja'] = {}, ['/ws'] = {}, ['/item'] = {}, ['/ra'] = {}, ['/ms'] = {}, ['/pet'] = {}, ['/trig'] = {}, ['/echo'] = {}}
validabils['french'] = {['/ma'] = {}, ['/ja'] = {}, ['/ws'] = {}, ['/item'] = {}, ['/ra'] = {}, ['/ms'] = {}, ['/pet'] = {}, ['/trig'] = {}, ['/echo'] = {}}
validabils['german'] = {['/ma'] = {}, ['/ja'] = {}, ['/ws'] = {}, ['/item'] = {}, ['/ra'] = {}, ['/ms'] = {}, ['/pet'] = {}, ['/trig'] = {}, ['/echo'] = {}}
validabils['japanese'] = {['/ma'] = {}, ['/ja'] = {}, ['/ws'] = {}, ['/item'] = {}, ['/ra'] = {}, ['/ms'] = {}, ['/pet'] = {}, ['/trig'] = {}, ['/echo'] = {}}

function make_abil(abil,lang,i)
    if not abil[lang] or not abil.prefix then return end
    local sp,pref = abil[lang]:lower(), unify_prefix[abil.prefix:lower()]
    validabils[lang][pref][sp] = i
end

function make_entry(v,i)
    make_abil(v,'english',i)
    make_abil(v,'german',i)
    make_abil(v,'french',i)
    make_abil(v,'japanese',i)
end

for i,v in pairs(res.spells) do
    if not T{363,364}:contains(i) then
        make_entry(v,i)
    end
end

for i,v in pairs(res.job_abilities) do
    make_entry(v,i)
end

for i,v in pairs(res.weapon_skills) do
    v.type = 'WeaponSkill'
    make_entry(v,i)
end

for i,v in pairs(res.monster_abilities) do
    v.type = 'MonsterSkill'
    make_entry(v,i)
end

for i,v in pairs(res.items) do
    v.prefix = '/item'
    if not validabils['english'][v.prefix][v.english:lower()] or v.cast_delay then
        make_entry(v,i)
    end
end
    
    -- Should transition these slot maps to be based off res.slots, but it's very unlikely to change.
default_slot_map = T{'sub','range','ammo','head','body','hands','legs','feet','neck','waist',
    'left_ear', 'right_ear', 'left_ring', 'right_ring','back'}
default_slot_map[0]= 'main'

jas = {false,false,false,false,false,true,false,false,false,false,false,false,false,true,true,false}-- {6,14,15}
readies = {false,false,false,false,false,false,true,true,true,false,false,true,false,false,false,false} -- {7,8,9,12}
uses = {false,true,true,true,true,false,false,false,false,false,true,false,true,false,false,false}--{2,3,4,5,11,13}
unable_to_use = T{17,18,55,56,87,88,89,90,104,191,308,313,325,410,428,561,574,579,580,581,661,665,
    12,16,34,35,40,47,48,49,71,72,76,78,84,91,92,95,96,106,111,128,154,155,190,192,193,198,
    199,215,216,217,218,219,220,233,246,247,307,315,316,328,337,338,346,347,348,349,356,411,443,444,
    445,446,514,516,517,518,523,524,525,547,568,569,575,649,660,662,666,700,701,62,717} -- Probably don't need some of these (event action) 
    -- 94 removed - "You must wait longer to perform that action." -- I think this is only sent in response to engage packets.

-- 192 : param_1 = Ability ID
-- 17 : no information
-- 34 : param_1 = Spell index
pass_through_targs = {['<t>']=true,['<me>']=true,['<ft>']=true,['<scan>']=true,['<bt>']=true,['<lastst>']=true,
    ['<r>']=true,['<pet>']=true,['<p0>']=true,['<p1>']=true,['<p2>']=true,['<p3>']=true,['<p4>']=true,
    ['<p5>']=true,['<a10>']=true,['<a11>']=true,['<a12>']=true,['<a13>']=true,['<a14>']=true,['<a15>']=true,
    ['<a20>']=true,['<a21>']=true,['<a22>']=true,['<a23>']=true,['<a24>']=true,['<a25>']=true,['<st>']=true,
    ['<stnpc>']=true,['<stal>']=true,['<stpc>']=true,['<stpt>']=true}

avatar_element = {Ifrit=0,Titan=3,Leviathan=5,Garuda=2,Shiva=1,Ramuh=4,Carbuncle=6,
    Diabolos=7,Fenrir=7,['Cait Sith']=6,FireSpirit=0,EarthSpirit=3,WaterSpirit=5,
    AirSpirit=2,IceSpirit=1,ThunderSpirit=4,LightSpirit=6,
    DarkSpirit=7}

encumbrance_map = {0x79,0x7F,0x7F,0x7A,0x7B,0x7C,0x7D,0x7D,0x7A,0x7E,0x80,0x80,0x80,0x80,0x7E}
encumbrance_map[0] = 0x79 -- Slots mapped onto encumbrance byte values.

addendum_white = {[14]="Poisona",[15]="Paralyna",[16]="Blindna",[17]="Silena",[18]="Stona",[19]="Viruna",[20]="Cursna",
    [143]="Erase",[13]="Raise II",[140]="Raise III",[141]="Reraise II",[142]="Reraise III",[135]="Reraise"}
    
addendum_black = {[253]="Sleep",[259]="Sleep II",[260]="Dispel",[162]="Stone IV",[163]="Stone V",[167]="Thunder IV",
    [168]="Thunder V",[157]="Aero IV",[158]="Aero V",[152]="Blizzard IV",[153]="Blizzard V",[147]="Fire IV",[148]="Fire V",
    [172]="Water IV",[173]="Water V",[255]="Break"}

resources_ranged_attack = {id="0",index="0",prefix="/range",english="Ranged",german="Fernwaffe",french="Attaque à dist.",japanese="飛び道具",type="Misc",element="None",targets=S{"Enemy"}}

    
-- _globals --
user_data_table = {
    __newindex = function(tab, key, val)
            rawset(tab, user_key_filter(key), val)
        end,

    __index = function(tab, key)
        return rawget(tab, user_key_filter(key))
    end
    }

--[[eq_data_table = {
    __newindex = function(tab, key, val)
            rawset(tab, slot_map[user_key_filter(key)], newtab)
        end,

    __index = function(tab, key)
        return rawget(tab, slot_map[user_key_filter(key)])
    end
    }]]
    
slot_map = make_user_table()

slot_map.main = 0
slot_map.sub = 1
slot_map.range = 2
slot_map.ranged = 2
slot_map.ammo = 3
slot_map.head = 4
slot_map.body = 5
slot_map.hands = 6
slot_map.legs = 7
slot_map.feet = 8
slot_map.neck = 9
slot_map.waist = 10
slot_map.ear1 = 11
slot_map.ear2 = 12
slot_map.left_ear = 11
slot_map.right_ear = 12
slot_map.learring = 11
slot_map.rearring = 12
slot_map.lear = 11
slot_map.rear = 12
slot_map.left_ring = 13
slot_map.right_ring = 14
slot_map.lring = 13
slot_map.rring = 14
slot_map.ring1 = 13
slot_map.ring2 = 14
slot_map.back = 15



gearswap_disabled = true
seen_0x063_type9 = false
delay_0x063_v9 = false
not_sent_out_equip = {}
command_registry = Command_Registry.new()
equip_list = {}
equip_list_history = {}
world = make_user_table()
buffactive = make_user_table()
alliance = make_user_table()
st_targs = {['<st>']=true,['<stpc>']=true,['<stal>']=true,['<stnpc>']=true,['<stpt>']=true}
current_file = nil
disable_table = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false}
disable_table[0] = false
outgoing_action_category_table = {['/ma']=3,['/ws']=7,['/ja']=9,['/ra']=16,['/ms']=25}
encumbrance_table = table.reassign({},disable_table)
registered_user_events = {}
unhandled_command_events = {}
empty = {name="empty"}
--outgoing_packet_table = {}
last_refresh = 0

injected_equipment_registry = {}
for i=0,15 do
    injected_equipment_registry[i] = L{}
end


_global = make_user_table()
_global.pretarget_cast_delay = 0
_global.precast_cast_delay = 0
_global.cancel_spell = false
_global.current_event = 'None'

_settings = {debug_mode = false, demo_mode = false, show_swaps = false}

-- _ExtraData is persistent information that isn't included in the windower API.
-- Because player, pet, and so forth are regularly regenerated from the windower API,
-- this table is necessary to maintain information that goes beyond the windower API.
_ExtraData = {
        player = {buff_details = {}},
        pet = {},
        world = {in_mog_house = false,conquest=false},
    }

unbridled_learning_set = {['Thunderbolt']=true,['Harden Shell']=true,['Absolute Terror']=true,
    ['Gates of Hades']=true,['Tourbillion']=true,['Pyric Bulwark']=true,['Bilgestorm']=true,
    ['Bloodrake']=true,['Droning Whirlwind']=true,['Carcharian Verve']=true,['Blistering Roar']=true,
    ['Uproot']=true,['Crashing Thunder']=true,['Polar Roar']=true,['Mighty Guard']=true,['Cruel Joke']=true,
    ['Cesspool']=true,['Tearing Gust']=true}

tool_map = {
        ['Katon: Ichi'] = res.items[1161],
        ['Katon: Ni'] = res.items[1161],
        ['Katon: San'] = res.items[1161],
        ['Hyoton: Ichi'] = res.items[1164],
        ['Hyoton: Ni'] = res.items[1164],
        ['Hyoton: San'] = res.items[1164],
        ['Huton: Ichi'] = res.items[1167],
        ['Huton: Ni'] = res.items[1167],
        ['Huton: San'] = res.items[1167],
        ['Doton: Ichi'] = res.items[1170],
        ['Doton: Ni'] = res.items[1170],
        ['Doton: San'] = res.items[1170],
        ['Raiton: Ichi'] = res.items[1173],
        ['Raiton: Ni'] = res.items[1173],
        ['Raiton: San'] = res.items[1173],
        ['Suiton: Ichi'] = res.items[1176],
        ['Suiton: Ni'] = res.items[1176],
        ['Suiton: San'] = res.items[1176],
        ['Utsusemi: Ichi'] = res.items[1179],
        ['Utsusemi: Ni'] = res.items[1179],
        ['Utsusemi: San'] = res.items[1179],
        ['Jubaku: Ichi'] = res.items[1182],
        ['Jubaku: Ni'] = res.items[1182],
        ['Jubaku: San'] = res.items[1182],
        ['Hojo: Ichi'] = res.items[1185],
        ['Hojo: Ni'] = res.items[1185],
        ['Hojo: San'] = res.items[1185],
        ['Kurayami: Ichi'] = res.items[1188],
        ['Kurayami: Ni'] = res.items[1188],
        ['Kurayami: San'] = res.items[1188],
        ['Dokumori: Ichi'] = res.items[1191],
        ['Dokumori: Ni'] = res.items[1191],
        ['Dokumori: San'] = res.items[1191],
        ['Tonko: Ichi'] = res.items[1194],
        ['Tonko: Ni'] = res.items[1194],
        ['Tonko: San'] = res.items[1194],
        ['Monomi: Ichi'] = res.items[2553],
        ['Monomi: Ni'] = res.items[2553],
        ['Aisha: Ichi'] = res.items[2555],
        ['Myoshu: Ichi'] = res.items[2642],
        ['Yurin: Ichi'] = res.items[2643],
        ['Migawari: Ichi'] = res.items[2970],
        ['Kakka: Ichi'] = res.items[2644],
        ['Gekka: Ichi'] = res.items[8803],
        ['Yain: Ichi'] = res.items[8804],
    }

universal_tool_map = {
        ['Katon: Ichi'] = res.items[2971],
        ['Katon: Ni'] = res.items[2971],
        ['Katon: San'] = res.items[2971],
        ['Hyoton: Ichi'] = res.items[2971],
        ['Hyoton: Ni'] = res.items[2971],
        ['Hyoton: San'] = res.items[2971],
        ['Huton: Ichi'] = res.items[2971],
        ['Huton: Ni'] = res.items[2971],
        ['Huton: San'] = res.items[2971],
        ['Doton: Ichi'] = res.items[2971],
        ['Doton: Ni'] = res.items[2971],
        ['Doton: San'] = res.items[2971],
        ['Raiton: Ichi'] = res.items[2971],
        ['Raiton: Ni'] = res.items[2971],
        ['Raiton: San'] = res.items[2971],
        ['Suiton: Ichi'] = res.items[2971],
        ['Suiton: Ni'] = res.items[2971],
        ['Suiton: San'] = res.items[2971],
        ['Utsusemi: Ichi'] = res.items[2972],
        ['Utsusemi: Ni'] = res.items[2972],
        ['Utsusemi: San'] = res.items[2972],
        ['Jubaku: Ichi'] = res.items[2973],
        ['Jubaku: Ni'] = res.items[2973],
        ['Jubaku: San'] = res.items[2973],
        ['Hojo: Ichi'] = res.items[2973],
        ['Hojo: Ni'] = res.items[2973],
        ['Hojo: San'] = res.items[2973],
        ['Kurayami: Ichi'] = res.items[2973],
        ['Kurayami: Ni'] = res.items[2973],
        ['Kurayami: San'] = res.items[2973],
        ['Dokumori: Ichi'] = res.items[2973],
        ['Dokumori: Ni'] = res.items[2973],
        ['Dokumori: San'] = res.items[2973],
        ['Tonko: Ichi'] = res.items[2972],
        ['Tonko: Ni'] = res.items[2972],
        ['Tonko: San'] = res.items[2972],
        ['Monomi: Ichi'] = res.items[2972],
        ['Aisha: Ichi'] = res.items[2973],
        ['Myoshu: Ichi'] = res.items[2972],
        ['Yurin: Ichi'] = res.items[2973],
        ['Migawari: Ichi'] = res.items[2972],
        ['Kakka: Ichi'] = res.items[2972],
        ['Gekka: Ichi'] = res.items[2972],
        ['Yain: Ichi'] = res.items[2972],
    }

region_to_zone_map = { 
    [4] = S{100,101,139,140,141,142,167,190},
    [5] = S{102,103,108,193,196,248},
    [6] = S{1,2,104,105,149,150,195},
    [7] = S{106,107,143,144,172,173,191},
    [8] = S{109,110,147,148,197},
    [9] = S{115,116,145,146,169,170,192,194},
    [10] = S{3,4,117,118,198,213,249},
    [11] = S{7,8,119,120,151,152,200},
    [12] = S{9,10,111,166,203,204,206},
    [13] = S{5,6,112,161,162,165},
    [14] = S{126,127,157,158,179,184},
    [15] = S{121,122,153,154,202,251},
    [16] = S{114,125,168,208,209,247},
    [17] = S{113,128.174,201,212},
    [18] = S{123,176,250,252},
    [19] = S{124,159,160,163,205,207,211},
    [20] = S{130,177,178,180,181},
    [22] = S{11,12,13},
    [24] = S{24,25,26,27,28,29,30,31,32},
    }
    

function initialize_globals()
    local pl = windower.ffxi.get_player()
    if not pl then
        player = make_user_table()
        player.vitals = {}
        player.buffs = {}
        player.skills = {}
        player.jobs = {}
        player.merits = {}
    else
        player = make_user_table()
        table.reassign(player,pl)
        if not player.vitals then player.vitals = {} end
        if not player.buffs then player.buffs = {} end
        if not player.skills then player.skills = {} end
        if not player.jobs then player.jobs = {} end
        if not player.merits then player.merits = {} end
    end
    
    player.equipment = make_user_table()
    pet = make_user_table()
    pet.isvalid = false
    fellow = make_user_table()
    fellow.isvalid = false
    partybuffs = {}
    
    -- GearSwap effectively needs to maintain two inventory structures:
    --  one is the proposed current inventory based on equip packets sent to the server,
    --  the other is the currently reported inventory based on packets sent from the server.
    -- The problem with proposed_inv is that it doesn't know when actions force items to unequip or prevent them from equipping.
    -- The problem with reported_inv is that packets can be dropped, so it doesn't always report everything accurately.
    -- In an ideal world, gearswap would maintain a registry of expected changes for each slot,
    --  and would advance along the registry as changes are reported by the server.
    items = windower.ffxi.get_items()
    if not items then
        items = {
                equipment = {},
            }
        for id,name in pairs(default_slot_map) do
            items.equipment[name] = {slot = empty,bag_id=0}
        end
    else
        if not items.equipment then
            items.equipment = {}
            for id,name in pairs(default_slot_map) do
                items.equipment[name] = {slot = empty,bag_id=0}
            end
        else
            for id,name in pairs(default_slot_map) do
                items.equipment[name] = {
                    slot   = items.equipment[name],
                    bag_id = items.equipment[name..'_bag']
                    }
                    items.equipment[name..'_bag'] = nil
                if items.equipment[name].slot == 0 then items.equipment[name].slot = empty end
            end
        end
    end
    for i in pairs(windower.ffxi.get_bag_info()) do
        if not items[i] then items[i] = make_inventory_table()
        else items[i][0] = make_empty_item_table(0) end
    end

    local wo = windower.ffxi.get_info()
    if wo then
        for i,v in pairs(region_to_zone_map) do
            if v:contains(wo.zone) then
               _ExtraData.world.conquest = {
                    region_id = i,
                    region_name = res.regions[i][language],
                    }
                break
            end
        end
    end
end

initialize_globals()

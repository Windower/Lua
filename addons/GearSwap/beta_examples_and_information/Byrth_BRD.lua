include('organizer-lib')

function get_sets()
    sets.precast = {}
    sets.precast.JA = {}
    
    sets.weapons = {sub="Twashtar"}
    -- Precast Sets
    sets.precast.JA.Nightingale = {feet="Bihu Slippers +1"}
    
    sets.precast.JA.Troubadour = {body="Bihu Justaucorps +1"}
    
    sets.precast.JA['Soul Voice'] = {legs="Bihu Cannions +1"}
    
    sets.precast.FC = {}
    
    sets.precast.FC.Song = {
        main="Sangoma",
        sub="Genmei Shield",
        range={ name="Linos", augments={'Accuracy+11','Occ. quickens spellcasting +3%',}},
        ammo=empty,
        head="Fili Calot +1",
        body="Inyanga Jubbah +1",
        hands={ name="Gende. Gages +1", augments={'Phys. dmg. taken -3%','Song spellcasting time -5%',}},
        legs="Querkening Brais",
        feet={ name="Telchine Pigaches", augments={'Song spellcasting time -7%',}},
        neck="Orunmila's Torque",
        waist="Flume Belt +1",
        left_ear="Loquac. Earring",
        right_ear="Enchntr. Earring +1",
        left_ring="Defending Ring",
        right_ring="Weather. Ring +1",
        back="Perimede Cape", -- 80% FC, 10% quickens
    }
    sets.precast['Honor March'] = {range="Marsyas",ammo=empty}
        
    sets.precast.FC.Normal = {
        main="Sangoma",
        sub="Genmei Shield",
        range={ name="Linos", augments={'Accuracy+11','Occ. quickens spellcasting +3%',}},
        ammo=empty,
        head="Nahtirah Hat",
        neck="Orunmila's Torque",
        left_ear="Loquac. Earring",
        right_ear="Enchntr. Earring +1",
        body="Inyanga Jubbah +1",
        hands="Gendewitha Gages +1",
        ring1="Kishar Ring",
        ring2="Weather. Ring +1",
        back={ name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10',}},
        waist="Witful Belt",
        legs="Lengo Pants",
        feet="Chelona Boots +1"} -- 71% FC, 10% Quickens
        
    sets.precast.Cure = {
        main="Felibre's Dague",
        sub="Genbu's Shield",
        body="Heka's Kalasiris",
        legs="Doyen Pants",
        back="Pahtli Cape"
    }
    
    sets.precast.EnhancingMagic = {waist="Siegel Sash"}
    
    sets.precast.WS = {}
    sets.precast.WS['Mordant Rime'] = {
        range={ name="Linos", augments={'Accuracy+15','"Dbl.Atk."+3','Quadruple Attack +3',}},
        head="Brioso Roundlet +2",
        body={ name="Bihu Jstcorps +1", augments={'Enhances "Troubadour" effect',}},
        hands={ name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}},
        legs="Jokushu Haidate",
        feet="Aya. Gambieras +1",
        neck="Fotia Gorget",
        waist="Grunfeld Rope",
        left_ear="Ishvara Earring",
        right_ear="Mache Earring +1",
        left_ring="Ramuh Ring +1",
        right_ring="Ramuh Ring +1",
        back={ name="Intarabus's Cape", augments={'DEX+20','Accuracy+20 Attack+20','"Dual Wield"+10',}},
    }
    --[[sets.precast.WS['Mordant Rime'] = {
        range="Gjallarhorn",
        ammo=empty,
        head="Brioso Roundlet +2",
        body={ name="Bihu Jstcorps +1", augments={'Enhances "Troubadour" effect',}},
        hands="Brioso Cuffs +2",
        legs={ name="Bihu Cannions +1", augments={'Enhances "Soul Voice" effect',}},
        feet="Brioso Slippers +2",
        neck="Fotia Gorget",
        waist="Windbuffet Belt +1",
        left_ear="Ishvara Earring",
        right_ear="Mache Earring +1",
        left_ring="Carb. Ring +1",
        right_ring="Carb. Ring +1",
        back={ name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10',}},
    }]]
        
    sets.precast.WS['Evisceration'] = {range={ name="Linos", augments={'Accuracy+15','"Dbl.Atk."+3','Quadruple Attack +3',}},ammo=empty,
        head="Lustratio Cap +1",neck="Fotia Gorget",ear1="Mache earring +1",ear2="Kuwunga Earring",
        body="Bihu Justaucorps +1",
        hands="Leyline Gloves",
        ring1="Ramuh Ring +1",
        ring2="Begrudging Ring",
        back="Rancorous Mantle",
        waist="Fotia Belt",
        legs="Lustratio Subligar +1",
        feet="Aya. Gambieras +1",}
        
    sets.precast.WS["Rudra's Storm"] = {range={ name="Linos", augments={'Accuracy+15','"Dbl.Atk."+3','Quadruple Attack +3',}},ammo=empty,
        head="Lustratio Cap +1",neck="Caro Necklace",ear1="Moonshade Earring",ear2="Mache earring +1",
        body="Bihu Justaucorps +1",hands="Leyline Gloves",ring1="Ramuh Ring +1",ring2="Ramuh Ring +1",
        back="Letalis Mantle",waist="Grunfeld Rope",legs="Lustratio Subligar +1",feet="Lustratio Leggings +1"}
    
    sets.precast.WS['Aeolian Edge'] = {
        head="Welkin Crown",
        body={ name="Bihu Jstcorps +1", augments={'Enhances "Troubadour" effect',}},
        hands={ name="Chironic Gloves", augments={'Mag. Acc.+24 "Mag.Atk.Bns."+24','Enmity-3','INT+3','Mag. Acc.+10','"Mag.Atk.Bns."+10',}},
        legs="Gyve Trousers",
        feet={ name="Lustra. Leggings +1", augments={'HP+65','STR+15','DEX+15',}},
        neck="Baetyl Pendant",
        waist="Eschan Stone",
        left_ear="Friomisi Earring",
        right_ear={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +25',}},
        left_ring="Shiva Ring +1",
        right_ring="Shiva Ring +1",
    }
    
    -- Midcast Sets
    sets.midcast = {}
        
    sets.midcast.Haste = {main="Mafic Cudgel",sub="Genmei Shield",
        head={name="Nahtirah Hat",priority=11},neck="Orunmila's Torque",ear1="Loquac. Earring",ear2={name="Gifted Earring",priority=10},
        body={name="Zendik Robe",priority=12},hands={name="Gendewitha Gages +1",priority=6},ring2={name="Kishar Ring",priority=7},
        back={name="Pahtli Cape",priority=9},waist="Ninurta's Sash",legs="Bihu Cannions +1",feet={name="Chelona Boots +1",priority=8}}

    sets.midcast.Debuff = {
        main="Carnwenhan",
        sub="Ammurapi Shield",
        range="Gjallarhorn",
        ammo=empty,
        head="Brioso Roundlet +2",
        body={ name="Chironic Doublet", augments={'Mag. Acc.+20 "Mag.Atk.Bns."+20','"Resist Silence"+5','CHR+7','Mag. Acc.+15',}},
        hands="Inyan. Dastanas +1",
        legs="Inyanga Shalwar +1",
        feet="Brioso Slippers +2",
        neck="Canto Necklace +1",
        waist="Luminary Sash",
        left_ear="Dignitary's Earring",
        right_ear="Enchntr. Earring +1",
        left_ring="Carb. Ring +1",
        right_ring="Carb. Ring +1",
        back={ name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10',}},
    }
    
    sets.midcast.Duration = {
        main="Carnwenhan",
        body="Fili Hongreline +1",
        legs="Inyanga Shalwar +1",
        feet="Brioso Slippers +2",
        neck="Moonbow Whistle",
    }
    
    sets.midcast.Buff = {
        main="Carnwenhan",
        sub="Genmei Shield",
        head="Fili Calot +1",
        neck="Moonbow Whistle",
        body="Fili Hongreline +1",
        hands="Fili Manchettes +1",
        legs="Inyanga Shalwar +1",
        feet="Brioso Slippers +2",
    }
    
    sets.midcast.DBuff = {range="Daurdabla",ammo=empty}
    
    sets.midcast.GBuff = {range="Gjallarhorn",ammo=empty}
    
        
    sets.midcast.Ballad = {legs="Fili Rhingrave +1"}
    
    sets.midcast.Madrigal = {back={ name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10',}},}
    
    sets.midcast.Prelude = {back={ name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10',}},}
        
    sets.midcast.Scherzo = {feet="Fili Cothurnes +1"}
        
    sets.midcast.Paeon = {head="Brioso Roundlet +2"}
    
    sets.midcast.March = {hands="Fili Manchettes +1",}
    
    sets.midcast.Lullaby = {range="Daurdabla",hands="Brioso Cuffs +2"}
    
    sets.midcast['Honor March'] = {
        range="Marsyas",
        ammo=empty,
        hands="Fili Manchettes +1",
        }
    
    
    sets.midcast.Waltz = {}
        
    sets.midcast.Cure = {main="Chatoyant Staff",head="Marduk's Tiara +1",neck="Phalaina Locket",ear2="Novia earring",
        body="Heka's Kalasiris",hands="Revealer's Mitts +1",legs="Bihu Cannions +1",feet="Bihu Slippers +1"}
        
    sets.midcast.Stoneskin = {head="Marduk's Tiara +1",neck="Nodens Gorget",body="Inyanga Jubbah +1",
        legs="Shedir Seraweels",feet="Bihu Slippers +1"}
    
    sets.midcast.Cursna={
        head={ name="Vanya Hood", augments={'Healing magic skill +20','"Cure" spellcasting time -7%','Magic dmg. taken -3',}},
        body="Vanya Robe",
        hands="Hieros Mittens",
        legs={ name="Vanya Slops", augments={'Healing magic skill +20','"Cure" spellcasting time -7%','Magic dmg. taken -3',}},
        left_ring="Haoma's Ring",
        right_ring="Haoma's Ring",
        back="Oretan. Cape +1",
        feet="Vanya Clogs",
        neck="Debilis Medallion",
    }
    
    
    --Aftercast Sets
    sets.aftercast = {}
    sets.aftercast.Regen = {main={name="Sangoma",priority=15},sub={name="Genmei Shield",priority=16},range={name="Oneiros Harp",priority=14},ammo={name=empty,priority=13},
        head="Bihu Roundlet +1",neck="Loricate Torque +1",ear1={name="Loquac. Earring",priority=7},ear2={name="Gifted Earring",priority=5},
        body="Ischemia Chasuble",hands={name="Umuthi Gloves",priority=9},ring1="Defending Ring",ring2={name="Dark Ring",priority=8},
        back="Umbra Cape",waist="Flume Belt +1",legs={name="Lengo Pants",priority=6},feet="Fili Cothurnes +1"}
    
    sets.aftercast.PDT = {
        main="Sangoma",
        sub="Genmei Shield",
        range="Oneiros Harp",
        ammo=empty,
        head="Lithelimb Cap",
        body="Emet Harness +1",
        hands="Umuthi Gloves",
        legs="Jokushu Haidate",
        feet="Fili Cothurnes +1",
        neck="Loricate Torque +1",
        waist="Flume Belt +1",
        left_ear="Loquac. Earring",
        right_ear="Gifted Earring",
        left_ring="Defending Ring",
        right_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',}},
        back="Solemnity Cape",
    }
        
    sets.aftercast.Engaged = {
        range={ name="Linos", augments={'Accuracy+15','"Dbl.Atk."+3','Quadruple Attack +3',}},
        ammo=empty,
        head="Aya. Zucchetto +1",
        body="Ayanmo Corazza +1",
        hands={ name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}},
        legs="Jokushu Haidate",
        feet="Aya. Gambieras +1",
        neck="Lissome Necklace",
        waist="Windbuffet Belt +1",
        left_ear="Telos Earring",
        right_ear="Mache Earring +1",
        left_ring="Ramuh Ring +1",
        right_ring="Rajas Ring",
        back={ name="Intarabus's Cape", augments={'DEX+20','Accuracy+20 Attack+20','"Dual Wield"+10',}},
    }
        
    sets.aftercast._tab = {'Regen','PDT'}
    
    sets.aftercast._index = 1
    
    sets.aftercast.Idle = sets.aftercast[sets.aftercast._tab[sets.aftercast._index]]
    
    sets.midcast.Base = sets.aftercast.PDT -- sets.midcast.Haste
    
    DaurdSongs = T{'Water Carol','Water Carol II','Herb Pastoral','Goblin Gavotte'}
    
    send_command('input /macro book 3;wait .1;input /macro set 1')
    timer_reg = {}
    pianissimo_cycle = false
end

function pretarget(spell)
    if spell.type == 'BardSong' and spell.target.type and spell.target.type == 'PLAYER' and not buffactive.pianissimo and not spell.target.charmed and not pianissimo_cycle then
        cancel_spell()
        pianissimo_cycle = true
        send_command('input /ja "Pianissimo" <me>;wait 1.5;input /ma "'..spell.name..'" '..spell.target.name..';')
        return
    end
    if spell.name ~= 'Pianissimo' then
        pianissimo_cycle = false
    end
end

function precast(spell)
    if spell.type == 'BardSong' then
            equip_song_gear(spell)
            equip(sets.precast.FC.Song)
            if spell.english == 'Honor March' then
                equip(sets.precast['Honor March'])
            end
    elseif spell.action_type == 'Magic' then
        equip(sets.precast.FC.Normal)
        if string.find(spell.english,'Cur') and spell.name ~= 'Cursna' then
            equip(sets.precast.Cure)
        end
        if spell.skill == 'Enhancing Magic' then
            equip(sets.precast.EnhancingMagic)
        end
    elseif spell.prefix == '/weaponskill' and sets.precast.WS[spell.name] then
        equip(sets.precast.WS[spell.name])
    end
    
    --if player.status == 'Engaged' then equip({range=nil}) end -- Why?
end

function midcast(spell)
    if spell.type == 'BardSong' then
        equip_song_gear(spell)
    elseif string.find(spell.english,'Waltz') and spell.english ~= 'Healing Waltz' then
        equip(sets.midcast.Base,sets.midcast.Waltz)
    elseif sets.midcast[spell.english] then
        equip(sets.midcast.Base,sets.midcast[spell.english])
    elseif string.find(spell.english,'Cur') then
        equip(sets.midcast.Base,sets.midcast.Cure)
    elseif spell.prefix == '/weaponskill' and sets.precast.WS[spell.name] then
        equip(sets.precast.WS[spell.name])
    else
        equip(sets.midcast.Base)
    end
    
    if sets.precast.JA[spell.english] then equip(sets.precast.JA[spell.english]) end
end

function aftercast(spell)
    if midaction() then return end
    
    if player.status == 'Engaged' then
        equip(sets.aftercast.Engaged)
    else
        equip(sets.aftercast.Idle)
    end
end

function status_change(new,old)
    if new == 'Engaged' then
        equip(sets.aftercast.Engaged)
        --disable('main','sub','ammo')
    elseif T{'Idle','Resting'}:contains(new) then
        equip(sets.aftercast.Idle)
    end
end

function self_command(cmd)
    if cmd == 'unlock' then
        enable('main','sub','ammo')
    elseif cmd == 'midact' then
        midaction(false)
    elseif cmd == 'idle' then
        sets.aftercast._index = sets.aftercast._index%(#sets.aftercast._tab) + 1
        windower.add_to_chat(8,'Aftercast Set: '..sets.aftercast._tab[sets.aftercast._index])
        sets.aftercast.Idle = sets.aftercast[sets.aftercast._tab[sets.aftercast._index]]
        equip(sets.aftercast.Idle)
    end
end

function equip_song_gear(spell)
    if DaurdSongs:contains(spell.english) then
        equip(sets.midcast.Base,sets.midcast.DBuff)
    else
        if spell.target.type == 'MONSTER' then
            equip(sets.midcast.Base,sets.midcast.Debuff,sets.midcast.GBuff)
            if buffactive.troubadour or buffactive['elemental seal'] then
                equip(sets.midcast.Duration,{range="Marsyas",ammo="empty"})
            end
            if string.find(spell.english,'Lullaby') then equip(sets.midcast.Duration,sets.midcast.Lullaby) end
        else
            equip(sets.midcast.Base,sets.midcast.Buff,sets.midcast.GBuff)
            if spell.english == 'Honor March' then equip(sets.midcast['Honor March'])
            elseif string.find(spell.english,'Ballad') then equip(sets.midcast.Ballad)
            elseif string.find(spell.english,'Scherzo') then equip(sets.midcast.Scherzo)
            elseif string.find(spell.english,'Paeon') then equip(sets.midcast.Paeon)
            elseif string.find(spell.english,'Prelude') then equip(sets.midcast.Prelude)
            elseif string.find(spell.english,'Madrigal') then equip(sets.midcast.Madrigal)
            end
        end
    end
end
include('organizer-lib')

function get_sets()

    sets.JA = {}
    sets.JA.Berserk = {body="Pumm. Lorica +1", back={ name="Cichol's Mantle", augments={'STR+20','Accuracy+20 Attack+20','"Dbl.Atk."+10',}}, feet="Agoge Calligae +1"}
    sets.JA.Aggressor = {head="Pumm. Mask +1", body="Agoge Lorica +1"}
    sets.JA.Warcry = {head="Agoge Mask +1"}
    sets.JA['Blood Rage'] = {body="Boii Lorica +1"}
    sets.JA['Mighty Strikes'] = {hands="Agoge Mufflers +1"}
    sets.JA.Tomahawk = {ammo="Thr. Tomahawk",feet="Agoge Calligae +1"}
    sets.JA.Provoke = sets.Enmity
    
    sets.TP = {}
    TP_mode = 'Acc'
    sets.TP.Ragnarok = {main="Ragnarok"}
    sets.TP.Ukonvasara = {main="Ukonvasara"}

    sets.TP.Normal = {
        sub="Bloodrain Strap",
        ammo="Ginsen",
        head="Flam. Zucchetto +1",
        body="Flamma Korazin +1",
        hands={ name="Odyssean Gauntlets", augments={'Attack+23','"Dbl.Atk."+5','STR+9','Accuracy+15',}},
        legs="Jokushu Haidate",--{ name="Odyssean Cuisses", augments={'Attack+30','"Dbl.Atk."+5','AGI+6','Accuracy+10',}},
        feet="Boii Calligae +1",
        neck="Lissome Necklace",
        waist="Windbuffet Belt +1",
        left_ear="Telos Earring",
        right_ear="Brutal Earring",
        left_ring="Petrov Ring",
        right_ring="Rajas Ring",
        back={ name="Cichol's Mantle", augments={'STR+20','Accuracy+20 Attack+20','"Dbl.Atk."+10',}},
    }
    
    sets.TP.Acc = {
        ammo="Seeth. Bomblet +1",
        head="Flam. Zucchetto +1",
        body="Flamma Korazin +1",
        hands={ name="Odyssean Gauntlets", augments={'Attack+23','"Dbl.Atk."+5','STR+9','Accuracy+15',}},
        legs="Jokushu Haidate",
        feet="Flam. Gambieras +1",
        neck="Combatant's Torque",
        waist="Grunfeld Rope",
        left_ear="Cessance Earring",
        right_ear="Telos Earring",
        left_ring="Ramuh Ring +1",
        right_ring="Rajas Ring",
        back={ name="Cichol's Mantle", augments={'STR+20','Accuracy+20 Attack+20','"Dbl.Atk."+10',}},
    }
    
    sets.TP.DT = sets.DT
    
    sets.Enmity = {
        ammo="Iron Gobbet",
        head="Pummeler's Mask +1",
        body="Yorium Cuirass",
        hands={ name="Yorium Gauntlets", augments={'Mag. Evasion+8','Enmity+10','Phys. dmg. taken -4%',}},
        legs={ name="Odyssean Cuisses", augments={'Attack+9','Enmity+8',}},
        feet={ name="Eschite Greaves", augments={'HP+80','Enmity+7','Phys. dmg. taken -4',}},
        neck="Unmoving Collar +1",
        waist="Goading Belt",
        left_ear="Trux Earring",
        right_ear="Pluto's Pearl",
        left_ring="Eihwaz Ring",
        right_ring="Provocare Ring",
        back="Impassive Mantle",
    }
    sets.FC = {
        ammo="Impatiens",
        body={ name="Odyss. Chestplate", augments={'"Fast Cast"+6'}},
        hands="Leyline Gloves",
        feet={ name="Odyssean Greaves", augments={'Accuracy+17','"Fast Cast"+6','Attack+13',}},
        neck="Orunmila's Torque",
        left_ear="Loquac. Earring",
        right_ear="Enchanter Earring +1",
        left_ring="Rahab Ring",
        right_ring="Weather. Ring +1",
    }
    
    sets.WS = {}
    sets.WS['Raging Rush'] = {
        sub="Bloodrain Strap",
        ammo="Yetshila",
        head={ name="Lustratio Cap +1", augments={'INT+35','STR+8','DEX+8',}},
        body="Flamma Korazin +1",
        hands={ name="Odyssean Gauntlets", augments={'Attack+23','"Dbl.Atk."+5','STR+9','Accuracy+15',}},
        legs={ name="Valor. Hose", augments={'Accuracy+27','Crit. hit damage +5%','DEX+3',}},
        feet={ name="Lustra. Leggings +1", augments={'HP+65','STR+15','DEX+15',}},
        neck="Fotia Gorget",
        waist="Metalsinger Belt",
        left_ear="Brutal Earring",
        right_ear={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +25',}},
        left_ring="Begrudging Ring",
        right_ring="Ifrit Ring +1",
        back={ name="Cichol's Mantle", augments={'STR+20','Accuracy+20 Attack+20','"Dbl.Atk."+10',}},
    }
        
    sets.WS["Ukko's Fury"] = {
        sub="Bloodrain Strap",
        ammo="Yetshila",
        head={ name="Lustratio Cap +1", augments={'INT+35','STR+8','DEX+8',}},
        body="Flamma Korazin +1",
        hands={ name="Odyssean Gauntlets", augments={'Attack+23','"Dbl.Atk."+5','STR+9','Accuracy+15',}},
        legs={ name="Valor. Hose", augments={'Accuracy+27','Crit. hit damage +5%','DEX+3',}},
        feet={ name="Lustra. Leggings +1", augments={'HP+65','STR+15','DEX+15',}},
        neck="Fotia Gorget",
        waist="Windbuffet Belt +1",
        left_ear="Brutal Earring",
        right_ear={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +25',}},
        left_ring="Begrudging Ring",
        right_ring="Ifrit Ring +1",
        back={ name="Cichol's Mantle", augments={'STR+20','Accuracy+20 Attack+20','Weapon skill damage +10%',}},
    }
        
    sets.WS["Fell Cleave"] = {
        ammo="Seeth. Bomblet +1",
        head={ name="Lustratio Cap +1", augments={'INT+35','STR+8','DEX+8',}},
        body="Sulevia's Plate. +1",
        hands={ name="Odyssean Gauntlets", augments={'Attack+23','"Dbl.Atk."+5','STR+9','Accuracy+15',}},
        legs="Sulevi. Cuisses +1",
        feet={ name="Lustra. Leggings +1", augments={'HP+65','STR+15','DEX+15',}},
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear="Ishvara Earring",
        right_ear="Brutal Earring",
        left_ring="Ifrit Ring +1",
        right_ring="Rajas Ring",
        back={ name="Cichol's Mantle", augments={'STR+20','Accuracy+20 Attack+20','Weapon skill damage +10%',}},
    }
    
    sets.WS.Resolution = {
        ammo="Seeth. Bomblet +1",
        head={ name="Argosy Celata +1", augments={'STR+12','DEX+12','Attack+20',}},
        body="Flamma Korazin +1",
        hands={ name="Argosy Mufflers +1", augments={'STR+12','DEX+12','Attack+20',}},
        legs={ name="Argosy Breeches +1", augments={'STR+12','DEX+12','Attack+20',}},
        feet={ name="Argosy Sollerets +1", augments={'STR+12','DEX+12','Attack+20',}},
        neck="Fotia Gorget",
        waist="Fotia Belt",
        right_ear="Telos Earring",
        left_ear={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +25',}},
        left_ring="Rajas Ring",
        right_ring="Apate Ring",
        back={ name="Cichol's Mantle", augments={'STR+20','Accuracy+20 Attack+20','"Dbl.Atk."+10',}},
        Gavialis = S{'Lightsday','Earthsday','Windsday','Firesday','Lightningsday'},
    }
    
    sets.WS.Gavialis = {head="Gavialis Helm"}
    
    sets.Idle = {
        ammo="Staunch Tathlum",
        head="Sulevia's Mask +1",
        body="Sulevia's Plate. +1",
        hands={ name="Odyssean Gauntlets", augments={'Attack+29','Damage taken-4%','AGI+3',}},
        legs="Sulevi. Cuisses +1",
        feet="Hermes' Sandals +1",
        neck="Loricate Torque +1",
        waist="Flume Belt +1",
        left_ear="Genmei Earring",
        right_ear="Etiolation Earring",
        left_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',}},
        right_ring="Defending Ring",
        back="Impassive Mantle",
    }
    
    sets.DT = {
        ammo="Staunch Tathlum",
        head="Sulevia's Mask +1",
        body="Sulevia's Plate. +1",
        hands="Souveran Handschuhs +1",
        legs="Sulevi. Cuisses +1",
        feet={ name="Souveran Schuhs +1", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
        neck="Loricate Torque +1",
        waist="Flume Belt +1",
        left_ear="Genmei Earring",
        right_ear="Etiolation Earring",
        left_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',}},
        right_ring="Defending Ring",
        back="Impassive Mantle",
    }
    
    sets.TP.DT = sets.DT
    
    send_command('input /macro book 6;wait .1;input /macro set 2')
end

function precast(spell)
    if spell.cast_time then
        equip(sets.FC)
    end
end

function midcast(spell)
    if sets.JA[spell.english] then
        equip(sets.JA[spell.english])
    elseif sets.WS[spell.english] then
        equip(sets.WS[spell.english])
        if sets.WS[spell.english].Gavialis and sets.WS[spell.english].Gavialis[world.day] then
            equip(sets.WS.Gavialis)
        end
    end
end

function aftercast(spell)
    if player.status == 'Engaged' then
        equip(sets.TP[TP_mode])
    else
        equip(sets.Idle)
    end
end

function status_change(new,old)
    if T{'Idle','Resting'}:contains(new) then
        equip(sets.Idle)
    elseif new == 'Engaged' then
        equip(sets.TP[TP_mode])
    end
end

function self_command(command)
    if command == 'DT' then
        equip(sets.DT)
    elseif command == 'TP' then
        if TP_mode=="Acc" then
            TP_mode="Normal"
        elseif TP_mode=="Normal" then
            TP_mode="DT"
        elseif TP_mode=="DT" then
            TP_mode='Acc'
        end
        windower.add_to_chat('TP mode is now: '..TP_mode)
        equip(sets.TP[TP_mode])
    end
end
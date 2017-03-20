include('organizer-lib')

function get_sets()
    sets.weapons = {main="Suwaiyas"}
    sets.precast = {}
    --sets.precast.Boost = {hands="Anchorite's Gloves +1"}
    sets.precast.Chakra = {ammo="Iron Gobbet",body="Anchorite's Cyclas +1",hands="Hes. Gloves +1"}
    sets.precast.Counterstance = {feet="Hes. Gaiters +1"}
    sets.precast.Focus = {head="Anchorite's Crown +1"}
    sets.precast.Dodge = {feet="Anchorite's Gaiters +1"}
    sets.precast.Mantra = {feet="Hes. Gaiters +1"}
    sets.precast.Footwork = {feet="Shukuyu Sune-Ate"}
    sets.precast['Hundred Fists'] = {legs="Hes. Hose +1"}
    sets.Waltz = {head="Anwig Salade",neck="Unmoving Collar +1",ring1="Valseur's Ring",ring2="Carbuncle Ring +1",
        waist="Aristo Belt",legs="Desultor Tassets",feet="Dance Shoes"}
        
    sets.precast['Victory Smite'] = {
        ammo="Floestone",
        head={ name="Adhemar Bonnet +1", augments={'STR+12','DEX+12','Attack+20',}},
        body={ name="Herculean Vest", augments={'Accuracy+21','Crit. hit damage +5%','DEX+9',}},
        hands={ name="Adhemar Wrist. +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        legs="Hiza. Hizayoroi +1",
        feet={ name="Herculean Boots", augments={'Accuracy+29','Crit. hit damage +5%','DEX+7','Attack+13',}},
        neck="Fotia Gorget",
        waist="Moonbow Belt +1",
        left_ear={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +25',}},
        right_ear="Sherida Earring",
        left_ring="Begrudging Ring",
        left_ring="Niqmaddu Ring",
        back={ name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}},
    }
    
    sets.test = {lring="Ramuh Ring +1",rring="Ramuh Ring +1"}
    sets.test2 = {main="Numen Staff"}
    
    sets.precast['Howling Fist'] = {
        ammo="Floestone",
        head={ name="Adhemar Bonnet +1", augments={'STR+12','DEX+12','Attack+20',}},
        body="Adhemar Jacket +1",
        hands="Adhemar Wrist. +1",
        legs="Hiza. Hizayoroi +1",
        feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','DEX+10',}},
        neck="Caro Necklace",
        waist="Moonbow Belt +1",
        left_ear="Cessance Earring",
        right_ear="Sherida Earring",
        left_ring="Ifrit Ring +1",
        left_ring="Niqmaddu Ring",
        back={ name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}},
    }
    sets.precast['Tornado Kick'] = {
        ammo="Floestone",
        head={ name="Adhemar Bonnet +1", augments={'STR+12','DEX+12','Attack+20',}},
        body="Adhemar Jacket +1",
        hands="Adhemar Wrist. +1",
        legs="Hiza. Hizayoroi +1",
        feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','DEX+10',}},
        neck="Caro Necklace",
        waist="Moonbow Belt +1",
        left_ear="Moonshade Earring",
        right_ear="Sherida Earring",
        left_ring="Ifrit Ring +1",
        left_ring="Niqmaddu Ring",
        back={ name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}},
    }
    sets.precast['Spinning Attack'] = {
        ammo="Floestone",
        head={ name="Adhemar Bonnet +1", augments={'STR+12','DEX+12','Attack+20',}},
        body="Adhemar Jacket +1",
        hands="Adhemar Wrist. +1",
        legs="Hiza. Hizayoroi +1",
        feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','DEX+10',}},
        neck="Caro Necklace",
        waist="Moonbow Belt +1",
        left_ear="Cessance Earring",
        right_ear="Sherida Earring",
        left_ring="Ifrit Ring +1",
        left_ring="Niqmaddu Ring",
        back={ name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}},
    }
        
    sets.WS = {
        ammo="Floestone",
        head={ name="Adhemar Bonnet +1", augments={'STR+12','DEX+12','Attack+20',}},
        body={ name="Herculean Vest", augments={'Accuracy+21','Crit. hit damage +5%','DEX+9',}},
        hands="Adhemar Wrist. +1",
        legs="Hiza. Hizayoroi +1",
        feet={ name="Herculean Boots", augments={'Accuracy+29','Crit. hit damage +5%','DEX+7','Attack+13',}},
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear="Moonshade Earring",
        right_ear="Sherida Earring",
        left_ring="Begrudging Ring",
        left_ring="Niqmaddu Ring",
        back={ name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}},
    }
    
    sets.TP = {}
    
    sets.TP.DD = {
        ammo="Ginsen",
        head={ name="Adhemar Bonnet +1", augments={'STR+12','DEX+12','Attack+20',}},
        body="Adhemar Jacket +1",
        hands="Adhemar Wrist. +1",
        legs={ name="Samnuha Tights", augments={'STR+8','DEX+9','"Dbl.Atk."+3','"Triple Atk."+2',}},
        feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','DEX+10',}},
        neck="Combatant's Torque",
        waist="Moonbow Belt +1",
        left_ear="Cessance Earring",
        right_ear="Sherida Earring",
        left_ring="Niqmaddu Ring",
        right_ring="Epona's Ring",
        back={ name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','"Dbl.Atk."+10',}},
    }
    
    sets.status = {}
    sets.status.Engaged = sets.TP.DD
    
    sets.status.Idle = {
        ammo="Iron Gobbet",
        head="Lithelimb Cap",
        body="Emet Harness +1",
        hands={ name="Herculean Gloves", augments={'Accuracy+30','Damage taken-4%','STR+9','Attack+4',}},
        legs="Mummu Kecks +1",
        feet="Herald's Gaiters",
        neck="Wiglen Gorget",
        waist="Moonbow Belt +1",
        left_ear="Novia Earring",
        right_ear="Genmei Earring",
        left_ring="Defending Ring",
        right_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',}},
        back={ name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','"Dbl.Atk."+10',}},
    }
    send_command('input /macro book 15;wait .1;input /macro set 1')
end

function precast(spell) 
    if spell.english == 'Tornado Kick' and buffactive.Footwork then
        equip(sets.precast[spell.english])
        equip({feet="Shukuyu Sune-Ate"})
    elseif sets.precast[spell.english] then
        equip(sets.precast[spell.english])
    elseif spell.type=="WeaponSkill" then
        equip(sets.WS)
    elseif string.find(spell.english,'Waltz') then
        equip(sets.Waltz)
    end
end

function aftercast(spell)
    if sets.status[player.status] then
        equip(sets.status[player.status])
    end
end

function status_change(new,old)
    if sets.status[new] then
        equip(sets.status[new])
    end
end
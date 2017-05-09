include('organizer-lib')

function get_sets()
    
    
    sets.weapons = {sub="Burtgang",main="Xiutleato",ammo="Excalibur"}
    
    sets.aegis = {sub={name="Aegis"}}
    sets.ochain = {sub={name="Ochain"}}
    sets.priwen = {sub={name="Priwen",hp=80}}
    sets.srivatsa = {sub={name="Srivatsa",hp=150,mp=150}}
    current_shield = {name="Ochain"}
    
    sets.items = {sub="Echo Drops"}
    
    sets.Enmity = {
        main="Burtgang",
        sub={name="Srivatsa",hp=150,mp=150},
        ammo="Iron Gobbet",
        head={ name="Cab. Coronet +1", augments={'Enhances "Iron Will" effect',}, hp=96, mp=78},
        body={ name="Reverence Surcoat +2", hp=244, mp=52},
        hands={ name="Yorium Gauntlets", augments={'Mag. Evasion+8','Enmity+10','Phys. dmg. taken -4%',}, hp=29},
        legs={ name="Odyssean Cuisses", augments={'Attack+9','Enmity+8',}, hp=54, mp=41},
        feet={ name="Eschite Greaves", augments={'HP+80','Enmity+7','Phys. dmg. taken -4',}, hp=98},
        neck="Unmoving Collar +1",
        waist="Goading Belt",
        left_ear="Trux Earring",
        right_ear={name="Pluto's Pearl",mp=24},
        ring1={name="Eihwaz Ring",hp=70},
        right_ring="Provocare Ring",
        back={ name="Weard Mantle", augments={'VIT+1','DEX+1','Enmity+7','Phalanx +4',}, hp=40, mp=40},
    }
    
    sets.precast = {}
    sets.precast.FC = {
        sub={ name="Svalinn", augments={'"Mag.Atk.Bns."+10','Occ. quickens spellcasting +3%',}},
        ammo="Impatiens",
        head={name="Carmine Mask +1",hp=38},
        body={ name="Reverence Surcoat +2", hp=244, mp=52},
        hands={name="Leyline Gloves",hp=25},
        legs={name="Enif Cosciales", hp=40,mp=40},
        feet={name="Carmine Greaves +1", hp=95, mp=80},
        neck={name="Orunmila's Torque", mp=30},
        left_ear={name="Loquac. Earring", mp=30},
        right_ear={name="Etiolation Earring", hp=50, mp=50},
        left_ring="Kishar Ring",
        right_ring="Weather. Ring +1",
        back={name="Reiki Cloak",hp=130},
        waist={name="Eschan Stone",hp=20},
    }
    
    sets.precast.Cure = {
        body={ name="Jumalik Mail", augments={'HP+50','Attack+15','Enmity+9','"Refresh"+2',}, hp=116, mp=59},
        right_ear="Nourish. Earring +1"}
    
    sets.precast['Enhancing Magic'] = {waist="Siegel Sash"}
    
    sets.midcast = {}
    sets.midcast['Shield Bash'] = set_combine(sets.Enmity,sets.aegis,{hands={name="Caballarius Gauntlets +1",hp=104},rring="Fenian Ring"})
    sets.midcast.Chivalry = {hands={name="Caballarius Gauntlets +1",hp=104}} -- Should make a real Chivalry set
    sets.midcast.Sentinel = {feet={name="Cab. Leggings +1",hp=43,mp=23},}
    sets.midcast.Rampart = set_combine(sets.Enmity,{head={ name="Cab. Coronet +1", augments={'Enhances "Iron Will" effect',}, hp=96, mp=78}})
    sets.midcast.Invincible = set_combine(sets.Enmity,{legs={name="Cab. Breeches +1",hp=52,mp=80}})
    sets.midcast.Fealty = {
        body={ name="Cab. Surcoat +1", augments={'Enhances "Fealty" effect',}, hp=118, mp=90},
        }
    sets.midcast['Holy Circle'] = {feet={name="Reverence Leggings +1",hp=48,mp=30}}
    sets.midcast.Provoke = sets.Enmity
    sets.midcast.Flash = set_combine(sets.Enmity,{waist="Chaac Belt"})
    sets.midcast.Palisade = sets.Enmity
    sets.midcast['Stinking Gas'] = sets.Enmity
    sets.midcast['Geist Wall'] = sets.Enmity
    sets.midcast['Jettatura'] = sets.Enmity
    sets.midcast['Soporific'] = sets.Enmity
    sets.midcast['Blank Gaze'] = sets.Enmity
    sets.midcast['Sounds Blast'] = sets.Enmity
    sets.midcast['Sheep Song'] = sets.Enmity
    sets.midcast['Chaotic Eye'] = sets.Enmity
    sets['Divine Emblem'] = {feet={name="Chev. Sabatons +1",hp=22,mp=14}}
    
    sets.midcast.Cover={
        sub="Ochain",
        ammo="Iron Gobbet",
        head={name="Reverence Coronet +1", hp=41, mp=23},
        body={ name="Cab. Surcoat +1", augments={'Enhances "Fealty" effect',}, hp=118, mp=90},
        hands={name="Caballarius Gauntlets +1",hp=104},
        legs={ name="Valor. Hose", augments={'Accuracy+27','Crit. hit damage +5%','DEX+3',}, hp=95},
        feet={name="Souveran Schuhs +1",hp=227,mp=14},
        neck="Unmoving Collar +1",
        waist="Flume Belt +1",
        left_ear="Genmei Earring",
        left_ring="Defending Ring",
        right_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',}, hp=-20,mp=20},
        back={ name="Weard Mantle", augments={'VIT+3','DEX+5','Phalanx +5',}, hp=40, mp=40},
    }

    sets.midcast['Chant du Cygne'] = {
        ammo="Ginsen",
        head={name="Flam. Zucchetto +1",hp=80, mp=20},
        body={name="Flamma Korazin +1",hp=140, mp=35},
        hands={ name="Odyssean Gauntlets", augments={'Attack+23','"Dbl.Atk."+5','STR+9','Accuracy+15',}, hp=31, mp=14},
        legs={ name="Valor. Hose", augments={'Accuracy+27','Crit. hit damage +5%','DEX+3',}, hp=95},
        feet={name="Thereoid Greaves",hp=13},
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +25',}},
        right_ear="Brutal Earring",
        left_ring="Ramuh Ring +1",
        right_ring="Ramuh Ring +1",
        back="Rancorous Mantle",
    }
        
    sets.midcast.Atonement = set_combine(sets.Enmity,{neck="Fotia Gorget",
        ear1="Moonshade Earring",
        head={ name="Valorous Mask", augments={'Weapon skill damage +5%','Attack+4',}, hp=38},
        hands={ name="Odyssean Gauntlets", augments={'Attack+20','Weapon skill damage +5%','VIT+3',}, hp=31, mp=14},
        waist="Fotia Belt",
        feet={name="Sulevia's Leggings +1",hp=20,mp=20}})
        
    sets.midcast['Swift Blade'] = {ammo="Ginsen",
        head={name="Carmine Mask +1",hp=38},
        neck="Fotia Gorget",
        ear1="Steelflash Earring",
        ear2="Bladeborn Earring",
        body={name="Flamma Korazin +1",hp=140, mp=35},
        hands={ name="Odyssean Gauntlets", augments={'Attack+23','"Dbl.Atk."+5','STR+9','Accuracy+15',}, hp=31, mp=14},
        ring1="Ifrit Ring +1",
        ring2="Rajas Ring",
        back="Bleating Mantle",
        waist="Fotia Belt",
        legs={ name="Valor. Hose", augments={'Accuracy+27','Crit. hit damage +5%','DEX+3',}, hp=95},
        feet={name="Flam. Gambieras +1",hp=40,mp=10},
        }
        
    sets.midcast['Savage Blade'] = {
        ammo="Ginsen",
        head={name="Carmine Mask +1",hp=38},
        body={name="Flamma Korazin +1",hp=140, mp=35},
        hands={ name="Odyssean Gauntlets", augments={'Attack+23','"Dbl.Atk."+5','STR+9','Accuracy+15',}, hp=31, mp=14},
        legs={ name="Valor. Hose", augments={'Accuracy+27','Crit. hit damage +5%','DEX+3',}, hp=95},
        feet={name="Sulevia's Leggings +1",hp=20,mp=20},
        neck="Fotia Gorget",
        waist="Windbuffet Belt +1",
        left_ear={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +25',}},
        right_ear="Brutal Earring",
        left_ring="Ifrit Ring +1",
        right_ring="Rajas Ring",
        back="Bleating Mantle",
    }
        
    sets.midcast['Knights of Round'] = {
        ammo="Ginsen",
        head={name="Carmine Mask +1",hp=38},
        neck="Fotia Gorget",
        ear1="Steelflash Earring",
        ear2="Bladeborn Earring",
        body={name="Flamma Korazin +1",hp=140, mp=35},
        hands={ name="Odyssean Gauntlets", augments={'Attack+23','"Dbl.Atk."+5','STR+9','Accuracy+15',}, hp=31, mp=14},
        ring1="Ifrit Ring +1",
        ring2="Rajas Ring",
        back="Bleating Mantle",
        waist="Fotia Belt",
        legs={ name="Valor. Hose", augments={'Accuracy+27','Crit. hit damage +5%','DEX+3',}, hp=95},
        feet={name="Sulevia's Leggings +1",hp=20,mp=20},
        }
        
    sets.midcast.WS = {
        head={name="Flam. Zucchetto +1",hp=80, mp=20},
        neck="Fotia Gorget",
        ear1="Moonshade Earring",
        ear2="Brutal Earring",
        body={name="Flamma Korazin +1",hp=140, mp=35},
        hands={ name="Odyssean Gauntlets", augments={'Attack+23','"Dbl.Atk."+5','STR+9','Accuracy+15',}, hp=31, mp=14},
        ring1="Ramuh Ring +1",
        ring2="Rajas Ring",
        back="Bleating Mantle",
        waist="Windbuffet Belt +1",
        legs={ name="Valor. Hose", augments={'Accuracy+27','Crit. hit damage +5%','DEX+3',}, hp=95},
        feet={name="Flam. Gambieras +1",hp=40,mp=10},
        }
        
    
    sets.midcast.WS_Day = { head={name="Gavialis helm", hp=115, mp=23} }
    
    sets.midcast.Cure = {
        neck="Phalaina Locket",
        rear="Nourishing Earring +1",
        --body={ name="Jumalik Mail", augments={'HP+50','Attack+15','Enmity+9','"Refresh"+2',}, hp=116, mp=59},
        body={ name="Reverence Surcoat +2", hp=244, mp=52},
        hands={name="Souveran Handschuhs +1",hp=239,mp=14},
        ring2={name="Meridian Ring",hp=90},
        ring1={name="Eihwaz Ring",hp=70},
        back={ name="Weard Mantle", augments={'VIT+1','DEX+1','Enmity+7','Phalanx +4',}, hp=40, mp=40},
        legs={name="Souveran Diechlings +1",hp=162,mp=41},
        feet={name="Souveran Schuhs +1",hp=227,mp=14},
        back={name="Reiki Cloak",hp=130},
        }
	
	sets.midcast.Phalanx = {main="Deacon Sword", -- +4
        sub="Priwen", -- +2
        neck="Incanter's Torque", -- +1
        head={ name="Yorium Barbuta", augments={'Phalanx +3',}, hp=41, mp=23}, -- +3
        body={ name="Yorium Cuirass", augments={'Mag. Evasion+7','Enmity+10','Phalanx +3',}, hp=113, mp=85}, -- +3
        hands={name="Souveran Handschuhs +1",hp=239,mp=14}, -- +5
        back={ name="Weard Mantle", augments={'VIT+3','DEX+5','Phalanx +5',}, hp=40, mp=40}, -- +5
        legs={ name="Yorium Cuisses", augments={'Enmity+7','Phalanx +3',}, hp=52}, -- +3
        feet={name="Souveran Schuhs +1",hp=227,mp=14} -- +5
    }
    -- Next tier is about 26 skill away, which isn't worth it.
	
	sets.midcast.Enlight = {
        main={ name="Brilliance", augments={'Shield skill +10','Divine magic skill +15','Enmity+7','DMG:+15',}},
        head={ name="Jumalik Helm", augments={'MND+10','"Mag.Atk.Bns."+15','Magic burst dmg.+10%','"Refresh"+1',}, hp=45, mp=29},
        body={ name="Reverence Surcoat +2", hp=244, mp=52},
        hands={ name="Eschite Gauntlets", hp=109},
        waist="Asklepian Belt",
        neck="Incanter's Torque",}
        
	sets.midcast['Enlight II'] = sets.midcast.Enlight
    -- This puts me over 500 skill. Need to test how much more divine magic skill I would need for another tier.
	
	sets.midcast.Stoneskin = {neck="Nodens Gorget",hands={name="Stone Mufflers",hp=10,mp=10},waist="Siegel Sash"}
    
    sets.aftercast = {}
    
    TP_sets = {'DD','Acc','DT'}
    TP_ind = 3
	
	sets.aftercast.non_DW = {
        main="Burtgang",
        sub=current_shield,
        waist="Windbuffet Belt +1",
        left_ear="Steelflash Earring",
        right_ear="Bladeborn Earring",
        ammo="Ginsen",
        head={name="Flam. Zucchetto +1",hp=80, mp=20},
        body={ name="Reverence Surcoat +2", hp=244, mp=52},
        hands={ name="Odyssean Gauntlets", augments={'Attack+23','"Dbl.Atk."+5','STR+9','Accuracy+15',}, hp=31, mp=14},
        legs={ name="Valor. Hose", augments={'Accuracy+27','Crit. hit damage +5%','DEX+3',}, hp=95},
        feet={name="Flam. Gambieras +1",hp=40,mp=10},
        neck="Lissome Necklace",
        left_ring="Ifrit Ring +1",
        right_ring="Rajas Ring",
        back="Bleating Mantle",
    }
	
    sets.aftercast.Acc = {
        main="Burtgang",
        sub=current_shield,
        ammo="Staunch Tathlum",
        head={name="Carmine Mask +1",hp=38},
        body={ name="Reverence Surcoat +2", hp=244, mp=52},
        hands={ name="Odyssean Gauntlets", augments={'Attack+23','"Dbl.Atk."+5','STR+9','Accuracy+15',}, hp=31, mp=14},
        legs={ name="Carmine Cuisses +1", augments={'Accuracy+20','Attack+12','"Dual Wield"+6',}, hp=50},
        feet={name="Souveran Schuhs +1",hp=227,mp=14},
        neck="Loricate Torque +1",
        waist="Flume Belt +1",
        left_ear="Genmei Earring",
        right_ear={name="Thureous Earring",hp=30,mp=30},
        left_ring="Defending Ring",
        right_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',}, hp=-20,mp=20},
        back="Impassive Mantle",
    }

    sets.aftercast.DW = {
        main="Burtgang",
        ammo="Ginsen",
        head={name="Flam. Zucchetto +1",hp=80, mp=20},
        body={ name="Reverence Surcoat +2", hp=244, mp=52},
        hands={ name="Odyssean Gauntlets", augments={'Attack+23','"Dbl.Atk."+5','STR+9','Accuracy+15',}, hp=31, mp=14},
        legs={ name="Carmine Cuisses +1", augments={'Accuracy+20','Attack+12','"Dual Wield"+6',}, hp=50},
        feet={name="Flam. Gambieras +1",hp=40,mp=10},
        neck="Lissome Necklace",
        waist="Reiki Yotai",
        left_ear="Suppanomimi",
        right_ear="Brutal Earring",
        left_ring="Ifrit Ring +1",
        right_ring="Rajas Ring",
        back="Bleating Mantle",
    }
	
	sets.aftercast.DD = sets.aftercast.non_DW
	
    function sets.aftercast.wield(equip_sub)
		if equip_sub == 'Aegis' or equip_sub =='Ochain' or equip_sub == 'Priwen' then
			sets.aftercast.DD = sets.aftercast.non_DW
--		elseif equip_sub == 'Bloodrain Strap' then
--            sets.aftercast.DD = sets.aftercast.Ragnarok
        else
			sets.aftercast.DD = sets.aftercast.DW
		end
	end
        
    sets.aftercast.DT = {
        main="Burtgang",
        sub=current_shield,
        ammo="Staunch Tathlum",
        head={ name="Odyssean Helm", augments={'Accuracy+16','Phys. dmg. taken -5%','CHR+1','Attack+14',}, hp=112, mp=89},
        body={ name="Reverence Surcoat +2", hp=244, mp=52},
        hands={name="Souveran Handschuhs +1",hp=239,mp=14},
        legs={name="Souveran Diechlings +1",hp=162,mp=41},
        feet={name="Souveran Schuhs +1",hp=227,mp=14},
        neck="Loricate Torque +1",
        waist="Flume Belt +1",
        left_ear="Genmei Earring",
        right_ear={name="Thureous Earring",hp=30,mp=30},
        left_ring="Defending Ring",
        right_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',}, hp=-20,mp=20},
        back="Impassive Mantle",
    }
    
    Idle_sets = {'Idle','Supertanking'}
    Idle_ind = 1
    sets.aftercast.Idle = {
        main="Burtgang",
        sub=current_shield,
        ammo="Staunch Tathlum",
        head={ name="Odyssean Helm", augments={'Accuracy+16','Phys. dmg. taken -5%','CHR+1','Attack+14',}, hp=112, mp=89},
        body={ name="Jumalik Mail", augments={'HP+50','Attack+15','Enmity+9','"Refresh"+2',}, hp=116, mp=59},
        hands={name="Souveran Handschuhs +1",hp=239,mp=14},
        legs={ name="Carmine Cuisses +1", augments={'Accuracy+20','Attack+12','"Dual Wield"+6',}, hp=50},
        feet={name="Souveran Schuhs +1",hp=227,mp=14},
        neck="Loricate Torque +1",
        waist="Flume Belt +1",
        left_ear="Genmei Earring",
        right_ear={name="Thureous Earring",hp=30,mp=30},
        left_ring="Defending Ring",
        right_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',}, hp=-20,mp=20},
        back="Impassive Mantle",
    }
            
    sets.aftercast.Supertanking = {
        main="Burtgang",
        sub=current_shield,
        ammo="Staunch Tathlum",
        head={ name="Odyssean Helm", augments={'Accuracy+16','Phys. dmg. taken -5%','CHR+1','Attack+14',}, hp=112, mp=89},
        body={ name="Jumalik Mail", augments={'HP+50','Attack+15','Enmity+9','"Refresh"+2',}, hp=116, mp=59},
        hands={name="Souveran Handschuhs +1",hp=239,mp=14},
        legs={name="Souveran Diechlings +1",hp=162,mp=41},
        feet={name="Souveran Schuhs +1",hp=227,mp=14},
        neck="Loricate Torque +1",
        waist="Flume Belt +1",
        left_ear="Genmei Earring",
        right_ear={name="Thureous Earring",hp=30,mp=30},
        left_ring="Defending Ring",
        right_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',}, hp=-20,mp=20},
        back="Impassive Mantle",
    }
    
    
    sets.pretarget = {}
    sets.pretarget.HP_Down = {
        head=empty,
        body=empty,
        hands={ name="Yorium Gauntlets", augments={'Mag. Evasion+8','Enmity+10','Phys. dmg. taken -4%',}, hp=29},
        right_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',}, hp=-20,mp=20},
        lear=empty,
        rear=empty,
        lring="Defending Ring",
        back=empty,
        waist="Flume Belt +1",
        legs=empty,
        feet=empty,
        neck=empty,}
	
    Cure_force = false
    send_command('input /macro book 20;wait .1;input /macro set 1')
    disable('main','sub')
    lock_mode = false
end

function pretarget(spell)
    if (spell.name == 'Cure IV' or spell.name == 'Cure III') and player.max_hp - player.hp < 328 and spell.target and spell.target.name == player.name then
        print('equipping HP Down')
        equip(sets.pretarget.HP_Down)
    end
end

function precast(spell)
	sets.aftercast.wield(player.equipment.sub)
    if player.equipment.head == 'Twilight Helm' and player.equipment.body == 'Twilight Mail' then disable('head','body') end
    if spell.action_type == 'Magic' then
        equip(sets.precast.FC)
        if spell.name:sub(1,3) == "Cur" and spell.name ~= "Cursna" then
            equip(sets.precast.Cure)
        elseif spell.skill == 'Enhancing Magic' then
            equip(sets.precast['Enhancing Magic'])
        end
    end
    set_priorities('hp','mp')
end

function midcast(spell)
    midaction(false)
    if player.status =='Engaged' then
        equip(sets.aftercast[TP_sets[TP_ind]])
    else
        equip(sets.aftercast[Idle_sets[Idle_ind]])
    end
    
    if sets.midcast[spell.name] then
        equip(sets.midcast[spell.name])
        day_equip(spell)
    elseif spell.type == 'WeaponSkill' then
        equip(sets.precast.WS)
        day_equip(spell)
    elseif string.find(spell.name,'Cure') then
        equip(sets.Enmity,sets.midcast.Cure)
    end
    
    if spell.english == 'Flash' and buffactive['Divine Emblem'] then
        equip(sets['Divine Emblem'])
    end
    if lockall then
        aftercast(spell)
    end
    set_priorities('hp','mp')
end

function day_equip(spell)
    if not spell.skillchain_a or spell.skillchain_a == '' then return end
    if (check_sc_properties(spell, "Light") or check_sc_properties(spell, "Fusion") or check_sc_properties(spell, "Liquefaction")) and world.day_element == 'Fire' then
    elseif (check_sc_properties(spell, "Light") or check_sc_properties(spell, "Fusion") or check_sc_properties(spell, "Transfixion")) and world.day_element == 'Light' then
    elseif (check_sc_properties(spell, "Light") or check_sc_properties(spell, "Fragmentation") or check_sc_properties(spell, "Detonation")) and world.day_element == 'Wind' then
    elseif (check_sc_properties(spell, "Light") or check_sc_properties(spell, "Fragmentation") or check_sc_properties(spell, "Impaction")) and world.day_element == 'Lightning' then
    elseif (check_sc_properties(spell, "Dark") or check_sc_properties(spell, "Distortion") or check_sc_properties(spell, "Reverberation")) and world.day_element == 'Water' then
    elseif (check_sc_properties(spell, "Dark") or check_sc_properties(spell, "Distortion") or check_sc_properties(spell, "Induration")) and world.day_element == 'Ice' then
    elseif (check_sc_properties(spell, "Dark") or check_sc_properties(spell, "Gravitation") or check_sc_properties(spell, "Scission")) and world.day_element == 'Earth' then
    elseif (check_sc_properties(spell, "Dark") or check_sc_properties(spell, "Gravitation") or check_sc_properties(spell, "Compression")) and world.day_element == 'Dark' then
    else
        return
    end
    equip(sets.midcast.WS_Day)
end

function check_sc_properties(spell,str)
    if spell.skillchain_a == str or spell.skillchain_b == str or spell.skillchain_c == str then return true end
    return false
end

function aftercast(spell)
    if player.status =='Engaged' then
        equip(sets.aftercast[TP_sets[TP_ind]])
    else
        equip(sets.aftercast[Idle_sets[Idle_ind]])
    end
    set_priorities('hp','mp')
end

function status_change(new,old)
    if T{'Idle','Resting'}:contains(new) then
        equip(sets.aftercast[Idle_sets[Idle_ind]])
    elseif new == 'Engaged' then
        equip(sets.aftercast[TP_sets[TP_ind]])
    end
    set_priorities('hp','mp')
end

function buff_change(new,bool)
    if new == 'Reprisal' and bool then
        if current_shield.name == 'Ochain' then
            table.reassign(current_shield,sets.priwen.sub)
            equip({sub=current_shield})
        end
    elseif new == 'Reprisal' and not bool then
        if current_shield.name == 'Priwen' then
            table.reassign(current_shield,sets.ochain.sub)
            equip({sub=current_shield})
        end
    end
    set_priorities('hp','mp')
end

function self_command(command)
    if command == 'toggle TP set' then
        TP_ind = TP_ind%#TP_sets +1
        send_command('@input /echo '..TP_sets[TP_ind]..' SET')
    elseif command == 'toggle Idle set' then
        if Idle_ind == 1 then
            Idle_ind = 2
            send_command('@input /echo SUPERTANKING SET')
        elseif Idle_ind == 2 then
            Idle_ind = 1
            send_command('@input /echo NORMAL SET')
        end
    elseif command == 'toggle LOCK mode' then
        lock_mode = not lock_mode
        if lock_mode then 
            send_command('input /echo MAIN/SUB SWAPPING ENABLED')
            enable('main','sub')
        else
            send_command('input /echo MAIN/SUB SWAPPING DISABLED')
            disable('main','sub')
        end
    elseif command == 'toggle lockall' then
        lockall = not lockall
        if lockall then
            send_command('input /echo SWAPPING DISABLED')
            disable('main','sub')
        else
            send_command('input /echo SWAPPING ENABLED')
            disable('main','sub')
        end
    elseif command == 'DT' then
        equip(sets.DT)
    elseif command == 'PDT Shield' then
        if buffactive['Reprisal'] then
            current_shield = table.reassign(current_shield,sets.priwen.sub)
        else
            current_shield = table.reassign(current_shield,sets.ochain.sub)
        end
        if not lock_mode then send_command('input /equip sub '..current_shield.name)
        else equip({sub=current_shield}) end
    elseif command == 'MDT Shield' then
        current_shield = table.reassign(current_shield,sets.aegis.sub)
        if not lock_mode then send_command('input /equip sub '..current_shield.name)
        else equip({sub=current_shield}) end
    end
    set_priorities('hp','mp')
end

function set_priorities(key1,key2)
    local future,current = gearswap.equip_list,gearswap.equip_list_history
    function get_val(piece,key)
        if piece and type(piece)=='table' and piece[key] and type(piece[key])=='number' then
            return piece[key]
        end
        return 0
    end
    local diff = {}
    for i,v in pairs(future) do
        local priority = get_val(future[i],key1) - get_val(current[i],key1) + (get_val(future[i],key2) - get_val(current[i],key2))
        if type(v) == 'table' then
            future[i].priority = priority
        else
            future[i] = {name=v,priority=priority}
        end
    end
end
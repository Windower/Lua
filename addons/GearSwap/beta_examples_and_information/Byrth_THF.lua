include('organizer-lib')

function get_sets()
    TP_Index = 1
    Idle_Index = 1

    
    ta_hands = {name="Adhemar Wristbands +1"}
    acc_hands = {name="Adhemar Wristbands +1"}
    wsd_hands = {name="Meg. Gloves +1",}
    crit_hands = {name="Adhemar Wristbands +1"}
    dt_hands = { name="Herculean Gloves", augments={'Accuracy+30','Damage taken-4%','STR+9','Attack+4',}}
    waltz_hands = { name="Herculean Gloves", augments={'Accuracy+22','"Waltz" potency +11%','STR+9',}}
    
    sets.weapons = {}
    sets.weapons[1] = {main="Taming Sari"}
    sets.weapons[2]={main="Twashtar"}
    sets.weapons[3]={main="Atoyac"}
    
    sets.JA = {}
--    sets.JA.Conspirator = {body="Raider's Vest +2"}
--    sets.JA.Accomplice = {head="Raider's Bonnet +2"}
--    sets.JA.Collaborator = {head="Raider's Bonnet +2"}
    sets.JA['Perfect Dodge'] = {hands="Plun. Armlets +1"}
    sets.JA.Steal = {ammo="Barathrum",neck="Pentagalus Charm",hands="Thief's Kote",
        waist="Key Ring Belt",legs="Pillager's Culottes +1",feet="Pillager's Poulaines +1"}
    sets.JA.Flee = {feet="Pillager's Poulaines +1"}
    sets.JA.Despoil = {ammo="Barathrum",legs="Raider's Culottes +2",feet="Skulker's Poulaines"}
--    sets.JA.Mug = {head="Assassin's Bonnet +2"}
    sets.JA.Waltz = {head="Anwig Salade",
        neck="Unmoving Collar +1",
        body="Passion Jacket",
        hands=waltz_hands,
        ring1="Valseur's Ring",
        ring2="Carbuncle Ring +1",
        waist="Aristo Belt",
        legs="Desultor Tassets",
        feet="Dance Shoes"
    }
    
    sets.WS = {}
    sets.WS.SA = {}
    sets.WS.TA = {}
    sets.WS.SATA = {}
    
    sets.WS.Evisceration = {
        ammo="Yetshila",
        head="Adhemar Bonnet +1",
        body="Abnoba Kaftan",
        hands=crit_hands,
        legs={ name="Lustr. Subligar +1", augments={'Accuracy+20','DEX+8','Crit. hit rate+3%',}},
        feet="Adhe. Gamashes +1",
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +25',}},
        right_ear="Mache Earring +1",
        left_ring="Begrudging Ring",
        right_ring="Ramuh Ring +1",
        back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Weapon skill damage +10%',}},
    }

    sets.WS["Rudra's Storm"] = {ammo="Seething Bomblet +1",
        head="Lustratio Cap +1",
        neck="Caro Necklace",
        ear1="Moonshade Earring",
        ear2="Ishvara Earring",
        body="Adhemar Jacket +1",
        hands=wsd_hands,
        ring1="Ramuh Ring +1",
        ring2="Ramuh Ring +1",
        back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Weapon skill damage +10%',}},
        waist="Grunfeld Rope",
        legs="Lustratio Subligar +1",
        feet="Lustratio Leggings +1",
    }
        
    sets.WS.SA["Rudra's Storm"] = set_combine(sets.WS["Rudra's Storm"],{ammo="Yetshila",
        head="Adhemar Bonnet +1",
        body={ name="Herculean Vest", augments={'Accuracy+21','Crit. hit damage +5%','DEX+9',}},
        }
    )
        
    sets.WS.TA["Rudra's Storm"] = set_combine(sets.WS["Rudra's Storm"],{ammo="Yetshila",
        head="Adhemar Bonnet +1",
        body={ name="Herculean Vest", augments={'Accuracy+21','Crit. hit damage +5%','DEX+9',}},
        }
    )
    
    sets.WS["Mandalic Stab"] = sets.WS["Rudra's Storm"]
        
    sets.WS.SA["Mandalic Stab"] = sets.WS.SA["Rudra's Storm"]
        
    sets.WS.TA["Mandalic Stab"] = sets.WS.TA["Rudra's Storm"]

    sets.WS.Exenterator = {ammo="Seething Bomblet +1",
        head="Meghanada Visor +1",neck="Fotia Gorget",ear1="Steelflash Earring",ear2="Bladeborn Earring",
        body="Adhemar Jacket +1",
        hands=ta_hands,
        right_ring="Ilabrat Ring",
        ring2="Epona's Ring",
        back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Weapon skill damage +10%',}},
        waist="Fotia Belt",
        legs="Mummu Kecks +1",
        feet="Adhemar Gamashes +1"
    }
        
    TP_Set_Names = {"Low Man","Delay Cap","Evasion","TH","Acc","DT"}
    sets.TP = {}
    sets.TP['Low Man'] = {
        ammo="Seething Bomblet +1",
        head="Adhemar Bonnet +1",
        body="Adhemar Jacket +1",
        hands={ name="Floral Gauntlets", augments={'Rng.Acc.+15','Accuracy+15','"Triple Atk."+3','Magic dmg. taken -4%',}},
        legs="Mummu Kecks +1",
        feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','DEX+10',}},
        neck="Lissome Necklace",
        waist="Reiki Yotai",
        left_ear="Suppanomimi",
        right_ear="Brutal Earring",
        left_ring="Hetairoi Ring",
        right_ring="Epona's Ring",
        back={ name="Toutatis's Cape", augments={'STR+20','Accuracy+20 Attack+20','"Store TP"+10',}},
    }
        
    sets.TP['TH'] = set_combine(sets.TP['Low Man'],{
        hands={ name="Plun. Armlets +1", augments={'Enhances "Perfect Dodge" effect',}},
        feet="Skulker's Poulaines",
    })
        
    sets.TP['Acc'] = {
        ammo="Falcon Eye",
        head={ name="Dampening Tam", augments={'DEX+10','Accuracy+15','Mag. Acc.+15','Quadruple Attack +3',}},
        body="Adhemar Jacket +1",
        hands=acc_hands,
        legs="Mummu Kecks +1",
        feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','DEX+10',}},
        neck="Combatant's Torque",
        waist="Olseni Belt",
        left_ear="Suppanomimi",
        right_ear="Telos Earring",
        left_ring="Ramuh Ring +1",
        right_ring="Ramuh Ring +1",
        back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Weapon skill damage +10%',}},
    }
        
    sets.TP['Delay Cap'] = {
        ammo="Seething Bomblet +1",
        head="Adhemar Bonnet +1",
        body="Adhemar Jacket +1",
        hands=ta_hands,
        legs="Mummu Kecks +1",
        feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','DEX+10',}},
        neck="Lissome Necklace",
        waist="Windbuffet Belt +1",
        left_ear="Cessance Earring",
        right_ear="Telos Earring",
        left_ring="Hetairoi Ring",
        right_ring="Epona's Ring",
        back={ name="Toutatis's Cape", augments={'STR+20','Accuracy+20 Attack+20','"Store TP"+10',}},
    }
        
    sets.TP.Evasion = {
        ammo="Yamarang",
        head="Adhemar Bonnet +1",
        body="Adhemar Jacket +1",
        hands=ta_hands,
        legs="Mummu Kecks +1",
        feet="Adhe. Gamashes +1",
        neck="Combatant's Torque",
        waist="Kasiri Belt",
        left_ear="Eabani Earring",
        right_ear="Infused Earring",
        left_ring="Vengeful Ring",
        right_ring="Epona's Ring",
        back={ name="Canny Cape", augments={'DEX+5','"Dual Wield"+5',}},
    }
                
    sets.TP.DT = {
        ammo="Seething Bomblet +1",
        head={ name="Dampening Tam", augments={'DEX+10','Accuracy+15','Mag. Acc.+15','Quadruple Attack +3',}},
        body="Emet Harness +1",
        hands=dt_hands,
        legs="Mummu Kecks +1",
        feet={ name="Herculean Boots", augments={'Accuracy+20 Attack+20','Phys. dmg. taken -5%','DEX+10','Accuracy+6',}},
        neck="Loricate Torque +1",
        waist="Reiki Yotai",
        left_ear="Suppanomimi",
        right_ear="Genmei Earring",
        left_ring="Defending Ring",
        right_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',}},
        back={ name="Canny Cape", augments={'DEX+5','"Dual Wield"+5',}},
    }
    
    Idle_Set_Names = {'Normal','MDT',"STP"}
    sets.Idle = {}
    sets.Idle.Normal = {
        ammo="Yamarang",
        head="Meghanada Visor +1",
        body="Emet Harness +1",
        hands=dt_hands,
        legs="Mummu Kecks +1",
        feet="Skd. Jambeaux +1",
        neck="Wiglen Gorget",
        waist="Kasiri Belt",
        left_ear="Etiolation Earring",
        right_ear="Genmei Earring",
        left_ring="Paguroidea Ring",
        right_ring="Sheltered Ring",
        back={ name="Toutatis's Cape", augments={'STR+20','Accuracy+20 Attack+20','"Store TP"+10',}},
    }
                
    sets.Idle.MDT = {
        ammo="Yamarang",
        head={ name="Dampening Tam", augments={'DEX+10','Accuracy+15','Mag. Acc.+15','Quadruple Attack +3',}},
        body="Emet Harness +1",
        hands=dt_hands,
        legs="Mummu Kecks +1",
        feet="Skd. Jambeaux +1",
        neck="Loricate Torque +1",
        waist="Wanion Belt",
        left_ear="Etiolation Earring",
        right_ear="Genmei Earring",
        left_ring="Defending Ring",
        right_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',}},
        back="Mollusca Mantle",
    }
    
    sets.Idle['STP'] = {
        main="Vajra",
        sub="Twashtar",
        ammo="Ginsen",
        head="Meghanada Visor +1",
        body={ name="Herculean Vest", augments={'Accuracy+21','Crit. hit damage +5%','DEX+9',}},
        hands="Adhemar Wristbands +1",
        legs={ name="Samnuha Tights", augments={'STR+8','DEX+9','"Dbl.Atk."+3','"Triple Atk."+2',}},
        feet="Skd. Jambeaux +1",
        neck="Combatant's Torque",
        waist="Goading Belt",
        left_ear="Telos Earring",
        right_ear="Digni. Earring",
        left_ring="Apate Ring",
        right_ring="Rajas Ring",
        back={ name="Toutatis's Cape", augments={'STR+20','Accuracy+20 Attack+20','"Store TP"+10',}},
    }
    
    send_command('input /macro book 12;wait .1;input /macro set 2')
    
        
    sets.FastCast = {
        ammo="Impatiens",
        head={ name="Herculean Helm", augments={'"Fast Cast"+6','Mag. Acc.+2',}},
        body={ name="Taeon Tabard", augments={'Accuracy+22','"Fast Cast"+5','Crit. hit damage +3%',}},
        hands="Leyline Gloves",
        legs="Enif Cosciales",
        feet={ name="Herculean Boots", augments={'Mag. Acc.+16','"Fast Cast"+6','MND+4',}},
        neck="Orunmila's Torque",
        left_ear="Loquac. Earring",
        right_ear="Enchntr. Earring +1",
        left_ring="Rahab Ring",
        right_ring="Weather. Ring +1",
    }
    
    
    sets.frenzy = {head="Frenzy Sallet"}
end

function precast(spell)
    if sets.JA[spell.english] then
        equip(sets.JA[spell.english])
    elseif spell.type=="WeaponSkill" then
        if sets.WS[spell.english] then equip(sets.WS[spell.english]) end
        if buffactive['sneak attack'] and buffactive['trick attack'] and sets.WS.SATA[spell.english] then equip(sets.WS.SATA[spell.english])
        elseif buffactive['sneak attack'] and sets.WS.SA[spell.english] then equip(sets.WS.SA[spell.english])
        elseif buffactive['trick attack'] and sets.WS.TA[spell.english] then equip(sets.WS.TA[spell.english]) end
    elseif string.find(spell.english,'Waltz') then
        equip(sets.JA.Waltz)
    elseif spell.action_type == "Magic" then
        equip(sets.FastCast)
    end
end

function aftercast(spell)
    if player.status=='Engaged' then
        equip(sets.TP[TP_Set_Names[TP_Index]])
    else
        equip(sets.Idle[Idle_Set_Names[Idle_Index]])
    end
end

function status_change(new,old)
    if T{'Idle','Resting'}:contains(new) then
        equip(sets.Idle[Idle_Set_Names[Idle_Index]])
    elseif new == 'Engaged' then
        equip(sets.TP[TP_Set_Names[TP_Index]])
    end
end

function buff_change(buff,gain_or_loss)
    if buff=="Sneak Attack" then
        soloSA = gain_or_loss
    elseif buff=="Trick Attack" then
        soloTA = gain_or_loss
    elseif gain_or_loss and buff == 'Sleep' and player.hp > 99 then
        print('putting on Frenzy sallet!')
        equip(sets.frenzy)
    end
end

function self_command(command)
    if command == 'toggle TP set' then
        TP_Index = TP_Index +1
        if TP_Index > #TP_Set_Names then TP_Index = 1 end
        send_command('@input /echo ----- TP Set changed to '..TP_Set_Names[TP_Index]..' -----')
        equip(sets.TP[TP_Set_Names[TP_Index]])
    elseif command == 'toggle Idle set' then
        Idle_Index = Idle_Index +1
        if Idle_Index > #Idle_Set_Names then Idle_Index = 1 end
        send_command('@input /echo ----- Idle Set changed to '..Idle_Set_Names[Idle_Index]..' -----')
        equip(sets.Idle[Idle_Set_Names[Idle_Index]])
    end
end
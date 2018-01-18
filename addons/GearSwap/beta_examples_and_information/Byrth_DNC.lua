include('organizer-lib')

function get_sets()
    
    ta_hands = {name="Adhemar Wristbands +1"}
    acc_hands = {name="Adhemar Wristbands +1"}
    wsd_hands = {name="Maxixi Bangles +3",}
    crit_hands = {name="Adhemar Wristbands +1"}
    dt_hands = { name="Herculean Gloves", augments={'Accuracy+30','Damage taken-4%','STR+9','Attack+4',}}
    waltz_hands = { name="Herculean Gloves", augments={'"Waltz" potency +10%','CHR+9','Attack+4',}}
    
    sets.subs = {sub="Airy Buckler"}
    
    -------------------  JA Sets  ----------------------
    sets.JA = {}
    sets.JA.Trance = {head="Horos Tiara +1"}
    sets.JA.Precast_Waltz = {legs="Desultor Tassets"}
    
    waltz_mode = 0
    sets.JA.Waltz = {}
    sets.JA.Waltz[0] = {
        ammo="Yamarang",
        head={ name="Anwig Salade", augments={'CHR+4','"Waltz" ability delay -2','CHR+2','"Fast Cast"+2',}},
        body="Maxixi Casaque +2",
        hands=waltz_hands,
        legs={ name="Desultor Tassets", augments={'"Waltz" TP cost -5',}},
        feet="Maxixi Toeshoes +2",
        neck="Unmoving Collar +1",
        waist="Aristo Belt",
        left_ear="Eabani Earring",
        right_ear="Roundel Earring",
        left_ring="Carb. Ring +1",
        right_ring="Carb. Ring +1",
        back={ name="Senuna's Mantle", augments={'"Waltz" potency +10%',}},
    }
    
    sets.JA.Waltz[1] = {
        ammo="Yamarang",
        head="Maxixi Tiara +2",
        neck="Unmoving Collar +1",
        lear="Enchanter Earring +1",
        rear="Roundel Earring",
        body="Maxixi Casaque +2",
        hands=waltz_hands,
        lring="Carbuncle Ring +1",
        rring="Carbuncle Ring +1",
        back={ name="Senuna's Mantle", augments={'"Waltz" potency +10%',}},
        waist="Aristo Belt",
        legs="Desultor Tassets",
        feet="Maxixi toeshoes +2"
    }
    
    --[[sets.JA.Waltz[2] = {
        ammo="Yamarang",
        head="Anwig Salade",
        neck="Unmoving Collar +1",
        lear="Enchanter Earring +1",
        rear="Handler's Earring +1",
        body="Maxixi Casaque +3",
        hands=waltz_hands,
        lring="Carbuncle Ring +1",
        rring="Carbuncle Ring +1",
        back="Senuna Mantle", (Waltz +10%, CHR+30)
        waist="Aristo Belt",
        legs="Desultor Tassets",
        feet="Maxixi toeshoes +3"
    }]]
    
    sets.JA.Samba = {head="Maxixi Tiara +2",
        back={ name="Senuna's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Crit.hit rate+10',}},}
    
    sets.JA.Jig = {legs='Horos Tights +1',feet="Maxixi toeshoes +2"}
    
    sets.JA.Step = {
        ammo="Yamarang",
        head="Maxixi Tiara +2",
        body="Adhemar Jacket +1",
        hands="Maxixi Bangles +3",
        legs="Mummu Kecks +1",
        feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','DEX+10',}},
        neck="Combatant's torque",
        waist="Olseni Belt",
        left_ear="Mache earring +1",
        right_ear="Telos Earring",
        left_ring="Ramuh Ring +1",
        right_ring="Ramuh Ring +1",
        back={ name="Senuna's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Crit.hit rate+10',}},
    }
    
    sets.JA['Feather Step'] = set_combine(sets.JA.Step,{feet="Maculele Toeshoes +1"})
    
    sets.JA['No Foot Rise'] = {body="Horos Casaque +1"}
    
    sets.JA['Climactic Flourish'] = {head="Maculele Tiara +1"}
    
    sets.JA['Striking Flourish'] = {body="Maculele casaque +1"}
    
    sets.JA['Reverse Flourish'] = {hands="Maculele bangles +1",back={ name="Toetapper Mantle", augments={'"Store TP"+1','"Dual Wield"+5','"Rev. Flourish"+30',}}}
    
    sets.JA['Violent Flourish'] = {
        ammo="Hydrocera",
        head="Dampening Tam",
        body={ name="Horos Casaque +1", augments={'Enhances "No Foot Rise" effect',}},
        hands="Leyline Gloves",
        legs={ name="Herculean Trousers", augments={'Mag. Acc.+16','"Fast Cast"+6','MND+2',}},
        feet={ name="Herculean Boots", augments={'Mag. Acc.+16','"Fast Cast"+6','MND+4',}},
        neck="Sanctity Necklace",
        waist="Eschan Stone",
        left_ear="Enchanter Earring +1",
        right_ear="Dignitary's Earring",
        left_ring="Weather. Ring +1",
        right_ring="Sangoma Ring",
        back={ name="Senuna's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Crit.hit rate+10',}},
    }
    
    sets.Enmity = {
        ammo="Iron gobbet",
        head="Halitus Helm",
        neck="Unmoving Collar +1",
        lear="Trux Earring",
        rear="Pluto's Pearl", -- Cryptic Earring from Rancibus is better
        body="Emet Harness +1",
        hands="Kurys Gloves",
        lring="Provocare Ring",
        rring="Eihwaz Ring",
        back="Reiki Cloak", -- Augmented Senuna's is better
        waist="Kasiri Belt", -- Trance Belt is better
        legs="Zoar Subligar +1",
        feet="Ahosi Leggings",
    }
    
    sets.JA['Animated Flourish'] = sets.Enmity
    sets.JA.Provoke = sets.Enmity
    sets.JA.Warcry = sets.Enmity
    
    
    ------------------  Idle Sets  ---------------------
    sets.Idle = {}
    sets.Idle.index = {'Normal','MDT'}
    Idle_ind = 1
    sets.Idle.Normal = {main="Terpsichore",sub="Twashtar",ammo="Tengu-no-Hane",
        head="Meghanada Visor +1",neck="Ej Necklace +1",lear="Eabani Earring",rear="Infused Earring",
        body="Emet Harness +1",hands=dt_hands,lring="Sheltered Ring",rring="Vengeful Ring",
        back={ name="Senuna's Mantle", augments={'AGI+20','Eva.+20 /Mag. Eva.+20','Haste+10',}},waist="Kasiri Belt",legs="Maculele Tights +1",feet="Skadi's Jambeaux +1"}
        
    sets.Idle.MDT={head="Dampening Tam",neck="Loricate Torque +1",lear="Etiolation Earring",
        body="Emet Harness +1",hands=dt_hands,lring="Dark Ring",rring="Defending Ring",
        back="Mollusca Mantle",waist="Wanion Belt",legs="Maculele Tights +1",feet="Maxixi toeshoes +2"}
    
    -------------------  TP Sets  ----------------------
    sets.TP={}
    sets.TP.index = {'Acc0','Acc1','Acc2','Eva'}
    TP_ind = 1
    sets.DT_on = false
    
    -- Works for Haste 2 + Haste Samba
    sets.TP.Acc0 = {
        main="Terpsichore",
        sub="Twashtar",
        ammo="Charis Feather",
        head="Adhemar Bonnet +1",
        body="Adhemar Jacket +1",
        hands=ta_hands,
        legs={ name="Samnuha Tights", augments={'STR+8','DEX+9','"Dbl.Atk."+3','"Triple Atk."+2',}},
        feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','DEX+10',}},
        neck="Anu Torque",
        waist="Windbuffet Belt +1",
        left_ear="Sherida Earring",
        right_ear="Telos Earring",
        left_ring="Epona's Ring",
        right_ring="Rajas Ring",
        back={ name="Senuna's Mantle", augments={'STR+20','Accuracy+20 Attack+20','"Store TP"+10',}},
    }
    
    sets.TP.Acc1 = {
        main="Terpsichore",
        sub="Twashtar",
        ammo="Yamarang",
        head="Mummu Bonnet +1",
        body={ name="Adhemar Jacket +1", augments={'STR+12','DEX+12','Attack+20',}},
        hands={ name="Adhemar Wrist. +1", augments={'STR+12','DEX+12','Attack+20',}},
        legs="Mummu Kecks +1",
        feet="Ahosi Leggings",
        neck="Combatant's Torque",
        waist="Windbuffet Belt +1",
        left_ear="Sherida Earring",
        right_ear="Telos Earring",
        left_ring="Epona's Ring",
        right_ring="Rajas Ring",
        back={ name="Senuna's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Store TP"+10',}},
    }
    
    --[[sets.TP.Acc1 = {
        main="Terpsichore",
        sub="Twashtar",
        ammo="Yamarang",
        head={ name="Dampening Tam", augments={'DEX+10','Accuracy+15','Mag. Acc.+15','Quadruple Attack +3',}},
        body="Adhemar Jacket +1",
        hands=ta_hands,
        legs={ name="Samnuha Tights", augments={'STR+8','DEX+9','"Dbl.Atk."+3','"Triple Atk."+2',}},
        feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','DEX+10',}},
        neck="Combatant's Torque",
        waist="Grunfeld Rope",
        left_ear="Sherida Earring",
        right_ear="Telos Earring",
        left_ring="Epona's Ring",
        right_ring="Rajas Ring",
        back={ name="Senuna's Mantle", augments={'STR+20','Accuracy+20 Attack+20','"Store TP"+10',}},
    }]]
        
    sets.TP.Acc2 = {
        main="Terpsichore",
        sub="Twashtar",
        ammo="Yamarang",
        head={ name="Dampening Tam", augments={'DEX+10','Accuracy+15','Mag. Acc.+15','Quadruple Attack +3',}},
        body="Adhemar Jacket +1",
        hands=ta_hands,
        legs="Mummu Kecks +1",
        feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','DEX+10',}},
        neck="Combatant's Torque",
        waist="Olseni Belt",
        left_ear="Mache earring +1",
        right_ear="Telos Earring",
        left_ring="Ramuh Ring +1",
        right_ring="Ramuh Ring +1",
        back={ name="Senuna's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Crit.hit rate+10',}},
    }
    
    sets.TP.DT = {
        main="Terpsichore",
        sub="Twashtar",
        ammo="Yamarang",
        head={ name="Dampening Tam", augments={'DEX+10','Accuracy+15','Mag. Acc.+15','Quadruple Attack +3',}},
        body="Emet Harness +1",
        hands=dt_hands,
        legs="Mummu Kecks +1",
        feet={ name="Herculean Boots", augments={'Accuracy+20 Attack+20','Phys. dmg. taken -5%','DEX+10','Accuracy+6',}},
        neck="Loricate Torque +1",
        waist="Windbuffet belt +1",
        right_ear="Suppanomimi",
        left_ear="Eabani Earring",
        left_ring={ name="Dark Ring", augments={'Breath dmg. taken -4%','Phys. dmg. taken -6%','Magic dmg. taken -5%',}},
        right_ring="Defending Ring",
        back="Mollusca Mantle",
    }
    
    sets.TP.Eva = {
        main="Terpsichore",
        sub="Twashtar",
        ammo="Yamarang",
        head="Maxixi Tiara +2",
        body="Maxixi Casaque +2",
        hands="Maxixi Bangles +3",
        legs="Maculele Tights +1",
        feet="Maxixi Toeshoes +2",
        neck="Ej Necklace +1",
        waist="Svelt. Gouriz +1",
        left_ear="Eabani Earring",
        right_ear="Infused Earring",
        left_ring="Beeline Ring",
        right_ring="Vengeful Ring",
        back={ name="Senuna's Mantle", augments={'AGI+20','Eva.+20 /Mag. Eva.+20','Haste+10',}},
    }
    
    sets.TP.CHR = {
        main="Terpsichore",
        sub="Twashtar",
        head="Dampening Tam",
    }
    
    -------------------  WS Sets  ----------------------
    sets.WS={}
    
    -- Moonshade option sets the left ear to be Moonshade if TP < 2800
    -- Madrigal option sets the right ear to be Kuwaliaoi Attack+17/STR/DEX+2 if you have a madrigal on
    
    sets.WS.Exenterator = {Moonshade=false,Madrigal=false,Tengu=true}
        
    sets.WS.Exenterator[0] = {
        ammo="Floestone",
        head="Meghanada Visor +1",
        body={ name="Adhemar Jacket +1", augments={'STR+12','DEX+12','Attack+20',}},
        hands="Maxixi Bangles +3",
        legs="Meg. Chausses +1",
        feet="Meg. Jam. +1",
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear="Sherida Earring",
        right_ear="Infused Earring",
        left_ring="Epona's Ring",
        right_ring="Ilabrat Ring",
        back={ name="Senuna's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10',}},
    }
    
    sets.WS['Shark Bite'] = {Moonshade=false,Madrigal=true,Tengu=true}
        
    sets.WS['Shark Bite'][0] = {
        ammo="Floestone",
        head="Meghanada Visor +1",
        body="Adhemar Jacket +1",
        hands=wsd_hands,
        legs="Mummu Kecks +1",
        feet="Adhemar Gamashes +1",
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear="Mache earring +1",
        right_ear="Ishvara Earring",
        left_ring="Ramuh Ring +1",
        right_ring="Ilabrat Ring",
        back={ name="Senuna's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%',}},
    }

    sets.WS.Evisceration = {Moonshade=false,Madrigal=true}

    sets.WS.Evisceration[0] = {
        ammo="Charis Feather",
        head="Adhemar Bonnet +1",
        body="Abnoba Kaftan",
        hands=crit_hands,
        legs="Lustratio Subligar +1",
        feet={ name="Herculean Boots", augments={'Accuracy+29','Crit. hit damage +5%','DEX+7','Attack+13',}},
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear="Sherida Earring",
        right_ear="Mache earring +1",
        left_ring="Begrudging Ring",
        right_ring="Ilabrat Ring",
        back={ name="Senuna's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Crit.hit rate+10',}},
    }

    sets.WS.Evisceration[1] = {
        ammo="Falcon Eye",
        head="Dampening Tam",
        body="Adhemar Jacket +1",
        hands=crit_hands,
        legs="Lustratio Subligar +1",
        feet={ name="Herculean Boots", augments={'Accuracy+29','Crit. hit damage +5%','DEX+7','Attack+13',}},
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear="Sherida Earring",
        right_ear="Mache earring +1",
        left_ring="Begrudging Ring",
        right_ring="Ramuh Ring +1",
        back={ name="Senuna's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Crit.hit rate+10',}},
    }

    sets.WS['Pyrrhic Kleos'] = {Moonshade=false,Madrigal=true,Tengu=true}

    sets.WS['Pyrrhic Kleos'][0] ={
        ammo="Floestone",
        head="Lustratio Cap +1",
        body="Adhemar Jacket +1",
        hands=ta_hands,
        legs={ name="Samnuha Tights", augments={'STR+8','DEX+9','"Dbl.Atk."+3','"Triple Atk."+2',}},
        feet="Lustratio Leggings +1",
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear="Sherida Earring",
        right_ear="Brutal Earring",
        left_ring="Apate Ring",
        right_ring="Rajas Ring",
        back={ name="Senuna's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10',}},
    }
    sets.WS['Pyrrhic Kleos'][1] ={
        ammo="Falcon Eye",
        head={ name="Dampening Tam", augments={'DEX+10','Accuracy+15','Mag. Acc.+15','Quadruple Attack +3',}},
        body="Adhemar Jacket +1",
        hands=acc_hands,
        legs="Lustratio Subligar +1",
        feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+4','DEX+10',}},
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear="Mache earring +1",
        right_ear="Telos Earring",
        left_ring="Ramuh Ring +1",
        right_ring="Ramuh Ring +1",
        back={ name="Senuna's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%',}},
    }

    sets.WS['Dancing Edge'] = {Moonshade=false,Madrigal=true,Tengu=true}

    sets.WS['Dancing Edge'][0] = {
        ammo="Floestone",
        head="Adhemar Bonnet +1",
        body="Adhemar Jacket +1",
        hands=ta_hands,
        legs="Mummu Kecks +1",
        feet="Adhemar Gamashes +1",
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear="Steelflash Earring",
        right_ear="Bladeborn Earring",
        left_ring="Ifrit Ring +1",
        right_ring="Ilabrat Ring",
        back={ name="Senuna's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%',}},
    }
        
    sets.WS['Aeolian Edge'] = {Moonshade=true,Madrigal=nil}
    
    sets.WS['Aeolian Edge'][0] = {
        ammo="Pemphredo Tathlum",
        head="Highwing Helm",
        body={ name="Samnuha Coat", augments={'Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+5','"Dual Wield"+5',}},
        hands=wsd_hands,
        legs={ name="Horos Tights +1", augments={'Enhances "Saber Dance" effect',}},
        feet="Adhemar Gamashes +1",
        neck="Sanctity Necklace",
        waist="Wanion Belt",
        left_ear="Crematio Earring",
        right_ear="Friomisi Earring",
        left_ring="Shiva Ring +1",
        right_ring="Shiva Ring +1",
        back="Toro Cape",
    }
        
    sets.WS["Rudra's Storm"] = {Moonshade=true}
    
    sets.WS["Rudra's Storm"][0] = {
        ammo="Charis Feather",
        head="Lustratio Cap +1",
        body={ name="Herculean Vest", augments={'Accuracy+21','Crit. hit damage +5%','DEX+9',}},
        hands=wsd_hands,
        legs="Lustratio Subligar +1",
        feet="Lustratio Leggings +1",
        neck="Caro Necklace",
        waist="Grunfeld Rope",
        left_ear="Mache earring +1",
        right_ear="Ishvara earring",
        left_ring="Ramuh Ring +1",
        right_ring="Ilabrat Ring",
        back={ name="Senuna's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%',}},
    }
    
    sets.WS["Rudra's Storm"][1] = set_combine(sets.WS["Rudra's Storm"][0],{
        ammo="Falcon Eye",
        head="Dampening Tam",
        neck="Fotia gorget",
        right_ring="Ramuh Ring +1",
    })
    
    sets.WS.Madrigal = {left_ear="Kuwunga Earring"}
    sets.WS.Moonshade = {right_ear="Moonshade Earring"}
    sets.WS.Sherida = {left_ear="Sherida Earring"} -- Will cause conflict with the DT set, but this is still the easiest way to handle it at the moment.

    -------------------  MA Sets  ----------------------
    sets.MA={}

    sets.MA.Utsusemi = {}
    sets.MA.Utsusemi.Eva = {
        ammo="Yamarang",
        head="Maxixi Tiara +2",
        neck="Ej Necklace +1",
        ear1="Eabani Earring",
        ear2="Infused Earring",
        body="Maxixi Casaque +2",
        hands="Maxixi Bangles +3",
        lring="Vengeful Ring",
        rring="Defending Ring",
        back={ name="Senuna's Mantle", augments={'AGI+20','Eva.+20 /Mag. Eva.+20','Haste+10',}},
        waist="Svelt. Gouriz +1",
        legs="Maculele Tights +1",
        feet="Maxixi Toeshoes +2",
        }
        
    sets.MA.Utsusemi.DT = sets.TP.DT
        
    sets.MA.FastCast = {
        ammo="Impatiens",
        head={ name="Herculean Helm", augments={'"Fast Cast"+6','Mag. Acc.+2',}},
        body={ name="Taeon Tabard", augments={'Accuracy+22','"Fast Cast"+5','Crit. hit damage +3%',}},
        hands="Leyline Gloves",
        legs={ name="Herculean Trousers", augments={'Mag. Acc.+16','"Fast Cast"+6','MND+2',}},
        feet={ name="Herculean Boots", augments={'Mag. Acc.+16','"Fast Cast"+6','MND+4',}},
        Neck="Orunmila's Torque",
        left_ear="Loquac. Earring",
        right_ear="Enchntr. Earring +1",
        left_ring="Rahab Ring",
        right_ring="Weather. Ring +1",
        back={ name="Senuna's Mantle", augments={'"Fast Cast"+10',}},
        Utsusemi = {
            neck="Magoraga Beads",
            body="Passion Jacket",
            },
    }
    
    sets.tengu = {ammo="Tengu-No-Hane"}
    sets.frenzy = {head="Frenzy Sallet"}
    
    send_command('input /macro book 9;wait .1;input /macro set 2')
    dur_table = {}
    utsu_index = 'DT'
    send_command('lua l daze')
end

function file_unload()
    send_command('lua u daze')
end

function precast(spell)
    if spell.action_type == 'Magic' then
        equip(sets.MA.FastCast)
        if string.find(spell.name,'Utsusemi') then
            equip(sets.MA.FastCast.Utsusemi)
        end
    elseif spell.type == 'Waltz' then
        if buffactive['saber dance'] then
            windower.ffxi.cancel_buff(410)
        end
        equip(sets.JA.Precast_Waltz)
    elseif spell.type == 'Samba' and buffactive['fan dance'] then
        windower.ffxi.cancel_buff(411)
    elseif spell.name == 'Spectral Jig' and buffactive.sneak then
        windower.ffxi.cancel_buff(71)
    end
end


local function get_target_type(perspective,str)
    local user = windower.ffxi.get_mob_by_name(perspective)
    local mob = windower.ffxi.get_mob_by_id(tonumber(str) or -1) or windower.ffxi.get_mob_by_target(tostring(str)) or windower.ffxi.get_mob_by_name(tostring(str))
    if user and mob then
        if mob.id == user.id then
            return 'Self'
        elseif mob.hpp == 0 then
            return 'Corpse'
        elseif mob.in_party and user.in_party then
            return 'Party'
        elseif mob.in_alliance and user.in_alliance then
            return 'Ally'
        elseif not mob.is_npc or mob.spawn_type==14 then
            return 'Player'
        elseif mob.is_npc then
            return 'Enemy'
            -- Not sure how to differentiate NPCs and enemies
        else
            return 'NPC'
        end
    end
end

function filtered_action(spell)
    cancel_spell()
    noti.message('Requesting Sjugy use '..spell.name)
    local targ_typ = get_target_type('Sjugy',spell.target.raw)
    
    if spell.targets[targ_typ] then
        noti.command('Sjugy',spell.name..' '..spell.target.raw)
    else
        noti.command('Sjugy',spell.name)
    end
end

function midcast(spell)
    if sets.JA[spell.name] then
        equip(sets.JA[spell.name])
        if spell.name == "Feather Step" then
            tengu_handler()
        end
    elseif sets.WS[spell.name] then
        if sets.TP.index[TP_ind] == 'Acc2' and sets.WS[spell.name][1] then
            equip(sets.WS[spell.name][1])
        elseif sets.WS[spell.name][0] then
            equip(sets.WS[spell.name][0])
        end
        if sets.WS[spell.name].Tengu then
            tengu_handler()
        end
        if buffactive['Madrigal'] and sets.WS[spell.name].Madrigal == true then
            equip(sets.WS.Madrigal)
        end
        if player.tp < 2800 and sets.WS[spell.name].Moonshade == true then
            equip(sets.WS.Moonshade)
            if spell.name == "Pyrrhic Kleos" or spell.name == "Dancing Edge" then -- Steelflash/Sherida combo
                equip(sets.WS.Sherida)
            end
        end
    elseif spell.type=='Jig' then
        equip(sets.JA.Jig)
    elseif spell.type=='Samba' then
        equip(sets.JA.Samba)
    elseif spell.type=='Waltz' then
        equip(sets.JA.Waltz[waltz_mode])
    elseif spell.type=='Step' then
        equip(sets.JA.Step)
        tengu_handler()
    elseif string.find(spell.name,'Utsusemi') then
        equip(sets.MA.Utsusemi[utsu_index])
    elseif string.find(spell.name,'Monomi') then
        send_command('@wait 1.7;cancel 71')
    end
    
    if spell.type == 'WeaponSkill' then
        if buffactive['climactic flourish'] then
            equip(sets.JA['Climactic Flourish'])
        elseif buffactive['striking flourish'] then
            equip(sets.JA['Striking Flourish'])
        end
    end
end

function tengu_handler()
    if world.time >= 360 and world.time < 1080 then -- 6~18
        equip(sets.tengu)
    end
end

function aftercast(spell)
    local dur,id
    if not spell or not spell.name then windower.add_to_chat(8,'Not spell') return end
    if spell.name:sub(1,11) == 'Chocobo Jig' and (not dur_table['Chocobo Jig'] or not dur_table['Chocobo Jig'] == 190) then
        id = 176
        dur = 190
    elseif spell.name == 'Spectral Jig' and (not dur_table['Spectral Jig'] or not dur_table['Spectral Jig'] == 270) then
        id = 69
        dur = 270
        send_command('st setduration 71 269;')
    elseif spell.name:sub(7,11) == 'Samba' then
        if spell.name:sub(1,11) == 'Drain Samba' then
            id = 368
            if #spell.name == 11 and (not dur_table['Drain Samba'] or not dur_table['Drain Samba'] == 165) then
                dur = 165
                dur_table['Drain Samba'] = 165
            elseif not dur['Drain Samba'] or not dur['Drain Samba'] == 135 then
                dur = 135
                dur_table['Drain Samba'] = 135
            end
        elseif spell.name:sub(1,11) == 'Aspir Samba' then
            id = 369
            if #spell.name == 11 and (not dur_table['Aspir Samba'] or not dur_table['Aspir Samba'] == 165) then
                dur = 165
                dur_table['Aspir Samba'] = 165
            elseif not dur['Aspir Samba'] or not dur['Aspir Samba'] == 135 then
                dur = 135
                dur_table['Aspir Samba'] = 135
            end
        elseif spell.name == 'Haste Samba' and (not dur_table['Haste Samba'] or not dur_table['Haste Samba'] == 135) then
            id = 370
            dur = 135
            dur_table['Haste Samba'] = 135
        end
        
--        if buffactive['saber dance'] then
--            dur = math.floor(dur*1.2)
--        end
    elseif spell.name == 'Trance' and (not dur_table['Trance'] or not dur_table['Trance'] == 80) then
        id = 376
        dur = 80
        dur_table['Trance'] = 165
--    elseif spell.name == 'Grand Pas' then
--        id = 507
--        dur = 60
--    elseif spell.name == 'Presto' then
--        id = 442
--        dur = 30
    end
    if id then
        send_command('st setduration '..id..' '..(dur-1)..';')
    end

    equip_inactive_set(spell)
end

function status_change(new,old)
    equip_inactive_set(nil,new)
end

function buff_change(buff,gain)
    if not gain and not midaction() and (buff == 'Climactic Flourish' or buff=='Striking Flourish' or buff=='Sleep') then
        equip_inactive_set()
    elseif gain and buff == 'Sleep' and player.hp > 99 then
        equip(sets.frenzy)
    end
end

function equip_inactive_set(spell,status)
    status = status or player.status
    if status == 'Engaged' then
        equip(sets.TP[sets.TP.index[TP_ind]])
        tengu_handler()
        if (buffactive['Climactic Flourish'] or spell and spell.english == 'Climactic Flourish') and sets.TP.index[TP_ind] ~= 'Acc' then
            equip(sets.TP.CHR,sets.JA['Climactic Flourish'])
        elseif (buffactive['Striking Flourish'] or spell and spell.english == 'Striking Flourish') and sets.TP.index[TP_ind] ~= 'Acc' then
            equip(sets.TP.CHR,sets.JA['Striking Flourish'])
        end
    else
        equip(sets.Idle[sets.Idle.index[Idle_ind]])
    end
    if sets.DT_on then equip(sets.TP.DT) end
end

function self_command(command)
    if command == 'toggle TP set' then
        TP_ind = TP_ind +1
        if TP_ind > #sets.TP.index then TP_ind = 1 end
        windower.add_to_chat(8,'----- TP Set changed to '..sets.TP.index[TP_ind]..' -----')
        equip(sets.TP[sets.TP.index[TP_ind]])
    elseif command == 'toggle TP set back' then
        TP_ind = TP_ind -1
        if TP_ind < 1 then TP_ind = #sets.TP.index end
        windower.add_to_chat(8,'----- TP Set changed to '..sets.TP.index[TP_ind]..' -----')
        equip(sets.TP[sets.TP.index[TP_ind]])
    elseif command == 'DT' then
        sets.DT_on = not sets.DT_on
        if sets.DT_on then
            equip(sets.TP.DT)
        elseif not midaction() then
            equip_inactive_set()
        end
        windower.add_to_chat(8,'----- DT mode is '..tostring(sets.DT_on)..' -----')
    elseif command == 'toggle Idle set' then
        Idle_ind = Idle_ind +1
        if Idle_ind > #sets.Idle.index then Idle_ind = 1 end
        windower.add_to_chat(8,'----- Idle Set changed to '..sets.Idle.index[Idle_ind]..' -----')
        equip(sets.Idle[sets.Idle.index[Idle_ind]])
    elseif command == 'equip TP set' then
        equip_inactive_set()
    elseif command == 'toggle Utsu set' then
        if utsu_index == 'DT' then utsu_index = 'Eva'
        else utsu_index = 'DT' end
        windower.add_to_chat(8,'----- Utsu Set changed to '..utsu_index..' -----')
    elseif command == 'waltz_mode' then
        waltz_mode = (waltz_mode + 1)%2
        if waltz_mode == 1 then
            windower.add_to_chat(8,'----- Waltz Efficiency Setting -----')
        else
            windower.add_to_chat(8,'----- Waltz Recast Setting (Default) -----')
        end
    end
end
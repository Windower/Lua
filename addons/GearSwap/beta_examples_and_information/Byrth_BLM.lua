function get_sets()
    sets.precast = {}
    sets.precast.Stun = {main="Apamajas II",sub="Arbuda Grip",ammo="Hasty Pinion",
        head="Zelus Tiara",neck="Aesir Torque",ear2="Loquacious Earring",
        body="Hedera Cotehardie",hands="Archmage's Gloves +1",lring="Sangoma Ring",rring="Angha Ring",
        back="Swith Cape +1",waist="Goading Belt",legs="Spaekona's Tonban +1",feet="Chelona Boots +1"}
    
    sets.precast.Stun_MAcc = {main="Apamajas II",sub="Arbuda Grip",ranged="Aureole",
        head="Zelus Tiara",neck="Aesir Torque",ear2="Loquacious Earring",
        body="Hedera Cotehardie",hands="Archmage's Gloves +1",lring="Sangoma Ring",rring="Angha Ring",
        back="Merciful Cape",waist="Goading Belt",legs="Spaekona's Tonban +1",feet="Bokwus Boots"}
        
    sets.precast.FastCast_ElementalMagic = {head="Nahtirah Hat",neck="Orunmila's Torque",ear2="Loquacious Earring",
        body="Anhur Robe",lring="Prolix Ring",back="Swith Cape +1",legs="Orvail Pants +1",feet="Chelona Boots +1"}
        
    sets.precast.FastCast_Other = {head="Nahtirah Hat",neck="Orunmila's Torque",ear2="Loquacious Earring",
        body="Anhur Robe",lring="Prolix Ring",back="Swith Cape +1",
        waist="Siegel Sash",legs="Orvail Pants +1",feet="Chelona Boots +1"}   
    sets.precast.Manafont = {body="Archmage's Coat +1"}
    
    sets.midcast = {}
    sets.midcast['Elemental Magic'] = {main="Ngqoqwanb",sub="Zuuxowu Grip",ammo="Dosis Tathlum",
        head="Hagondes Hat",neck="Eddy Necklace",ear1="Friomisi Earring",ear2="Novio Earring",
        body="Spae. Coat +1",hands="Otomi Gloves",ring1="Icesoul Ring",ring2="Icesoul Ring",
        back="Toro Cape",waist="Sekhmet Corset",legs="Hagondes Pants",feet="Umbani Boots",
        Stone={neck="Quanpur Necklace"}}
    
    sets.midcast['Dark Magic'] = {main="Ngqoqwanb",sub="Mephitis Grip",ammo="Hasty Pinion",
        head="Striga Crown",neck="Aesir Torque",ear1="Hirudinea Earring",ear2="Loquacious Earring",
        body="Spaekona's Coat +1",hands="Archmage's Gloves +1",ring1="Sangoma Ring",ring2="Excelsis Ring",
        back="Merciful Cape",waist="Goading Belt",legs="Spae. Tonban +1",feet="Goetia Sabots +2"}
    
    sets.midcast['Enfeebling Magic'] = {main="Ngqoqwanb",sub="Mephitis Grip",range='Aureole',
        head="Archmage's Petasos +1",neck="Eddy Necklace",ear1="Psystorm Earring",ear2="Lifestorm Earring",
        body="Spaekona's Coat +1",hands="Lurid Mitts",ring1="Sangoma Ring",ring2="Angha Ring",
        back="Bane Cape",waist="Ovate Rope",legs="Spaekona's Tonban +1",feet="Bokwus Boots"}
    
    
    sets.midcast['Healing Magic'] = {}
    
    sets.midcast['Divine Magic'] = {}
    
    sets.midcast['Enhancing Magic'] = {}
    
    sets.midcast.Cure = {main="Arka IV",body="Heka's Kalasiris",hands="Bokwus Gloves",legs="Nares Trews"}
    
    sets.midcast.Stoneskin = {main="Kirin's Pole",neck="Stone Gorget",waist="Siegel Sash",legs="Shedir Seraweels"}
    
    sets.aftercast = {}
    sets.aftercast.Idle = {main="Terra's Staff",sub="Arbuda Grip",ammo="Mana ampulla",
        head={ name="Hagondes Hat", augments={'Phys. dmg. taken -4%','"Mag.Atk.Bns."+24',}},neck="Twilight Torque",ear1="Gifted earring",ear2="Loquacious Earring",
        body="Archmage's Coat +1",hands="Serpentes Cuffs",ring1="Dark Ring",ring2="Defending Ring",
        back="Umbra Cape",waist="Hierarch Belt",legs="Nares Trews",feet="Herald's Gaiters"}
                
    sets.aftercast.Resting = {main="Numen Staff",sub="Ariesian Grip",ammo="Mana ampulla",
        head="Hydra Beret",neck="Eidolon Pendant",ear1="Relaxing Earring",ear2="Antivenom Earring",
        body="Archmage's Coat +1",hands="Nares Cuffs",ring1="Celestial Ring",ring2="Angha Ring",
        back="Vita Cape",waist="Austerity Belt",legs="Nares Trews",feet="Chelona Boots +1"}
    
    sets.Obis = {}
    sets.Obis.Fire = {back='Twilight Cape',lring='Zodiac Ring'}
    sets.Obis.Earth = {back='Twilight Cape',lring='Zodiac Ring'}
    sets.Obis.Water = {back='Twilight Cape',lring='Zodiac Ring'}
    sets.Obis.Wind = {waist='Furin Obi',back='Twilight Cape',lring='Zodiac Ring'}
    sets.Obis.Ice = {waist='Hyorin Obi',back='Twilight Cape',lring='Zodiac Ring'}
    sets.Obis.Lightning = {waist='Rairin Obi',back='Twilight Cape',lring='Zodiac Ring'}
    sets.Obis.Light = {waist='Korin Obi',back='Twilight Cape',lring='Zodiac Ring'}
    sets.Obis.Dark = {waist='Anrin Obi',back='Twilight Cape',lring='Zodiac Ring'}
    
    sets.FC = {staves={
        Fire = {main='Atar I'},
        Lightning = {main='Apamajas I'},
    }}
    
    Magic_Stats = {
        ['Stone'] = {V=10,L1=50,M0=2,L2=100,M50=1,L3=200,M3=0,Max_N=1},
        ['Water'] = {V=25,L1=50,M0=1.8,L2=100,M50=1,L3=200,M3=0,Max_N=1},
        ['Aero'] = {V=40,L1=50,M0=1.6,L2=100,M50=1,L3=200,M3=0,Max_N=1},
        ['Fire'] = {V=55,L1=50,M0=1.4,L2=100,M50=1,L3=200,M3=0,Max_N=1},
        ['Blizzard'] = {V=70,L1=50,M0=1.2,L2=100,M50=1,L3=200,M3=0,Max_N=1},
        ['Thunder'] = {V=85,L1=50,M0=1,L2=100,M50=1,L3=200,M3=0,Max_N=1},
        
        ['Stone II'] = {V=100,L1=50,M0=3,L2=100,M50=2,L3=200,M3=1,Max_N=1},
        ['Water II'] = {V=120,L1=50,M0=2.8,L2=100,M50=1.9,L3=200,M3=1,Max_N=1},
        ['Aero II'] = {V=140,L1=50,M0=2.6,L2=100,M50=1.8,L3=200,M3=1,Max_N=1},
        ['Fire II'] = {V=160,L1=50,M0=2.4,L2=100,M50=1.7,L3=200,M3=1,Max_N=1},
        ['Blizzard II'] = {V=180,L1=50,M0=2.2,L2=100,M50=1.6,L3=200,M3=1,Max_N=1},
        ['Thunder II'] = {V=200,L1=50,M0=2,L2=100,M50=1.5,L3=200,M3=1,Max_N=1},
        
        ['Stone III'] = {V=200,L1=50,M0=4,L2=100,M50=3,L3=200,M3=2,Max_N=1},
        ['Water III'] = {V=230,L1=50,M0=3.7,L2=100,M50=2.9,L3=200,M3=1.95,Max_N=1},
        ['Aero III'] = {V=260,L1=50,M0=3.4,L2=100,M50=2.8,L3=200,M3=1.9,Max_N=1},
        ['Fire III'] = {V=290,L1=50,M0=3.1,L2=100,M50=2.7,L3=200,M3=1.85,Max_N=1},
        ['Blizzard III'] = {V=320,L1=50,M0=2.8,L2=100,M50=2.6,L3=200,M3=1.8,Max_N=1},
        ['Thunder III'] = {V=350,L1=50,M0=2.5,L2=100,M50=2.5,L3=200,M3=1.75,Max_N=1},
        
        ['Stone IV'] = {V=400,L1=50,M0=5,L2=100,M50=4,L3=200,M3=3,Max_N=1},
        ['Water IV'] = {V=440,L1=50,M0=4.7,L2=100,M50=3.9,L3=200,M3=2.95,Max_N=1},
        ['Aero IV'] = {V=480,L1=50,M0=4.4,L2=100,M50=3.8,L3=200,M3=2.9,Max_N=1},
        ['Fire IV'] = {V=520,L1=50,M0=4.2,L2=100,M50=3.7,L3=200,M3=2.85,Max_N=1},
        ['Blizzard IV'] = {V=560,L1=50,M0=3.9,L2=100,M50=3.6,L3=200,M3=2.8,Max_N=1},
        ['Thunder IV'] = {V=600,L1=50,M0=3.6,L2=100,M50=3.5,L3=200,M3=2.75,Max_N=1},
        
        ['Stone V'] = {V=650,L1=50,M0=6,L2=100,M50=5,L3=200,M3=4,Max_N=1},
        ['Water V'] = {V=700,L1=50,M0=5.6,L2=100,M50=4.74,L3=200,M3=3.95,Max_N=1},
        ['Aero V'] = {V=750,L1=50,M0=5.2,L2=100,M50=4.5,L3=200,M3=3.9,Max_N=1},
        ['Fire V'] = {V=800,L1=50,M0=4.8,L2=100,M50=4.24,L3=200,M3=3.85,Max_N=1},
        ['Blizzard V'] = {V=850,L1=50,M0=4.4,L2=100,M50=4,L3=200,M3=3.8,Max_N=1},
        ['Thunder V'] = {V=900,L1=50,M0=4,L2=100,M50=3.74,L3=200,M3=3.75,Max_N=1},
        
        ['Quake']   = {V=700,L1=50,M0=2,L2=100,M50=2,L3=200,M3=2,Max_N=1},
        ['Flood']   = {V=700,L1=50,M0=2,L2=100,M50=2,L3=200,M3=2,Max_N=1},
        ['Tornado'] = {V=700,L1=50,M0=2,L2=100,M50=2,L3=200,M3=2,Max_N=1},
        ['Flare']   = {V=700,L1=50,M0=2,L2=100,M50=2,L3=200,M3=2,Max_N=1},
        ['Freeze']  = {V=700,L1=50,M0=2,L2=100,M50=2,L3=200,M3=2,Max_N=1},
        ['Burst']   = {V=700,L1=50,M0=2,L2=100,M50=2,L3=200,M3=2,Max_N=1},
        ['Impact']  = {V=700,L1=50,M0=2,L2=100,M50=2,L3=200,M3=2,Max_N=1},
        
        ['Quake II']   = {V=800, L1=50,M0=2,L2=100,M50=2.00,L3=200,M3=2.0,Max_N=1},
        ['Flood II']   = {V=800, L1=50,M0=2,L2=100,M50=2.00,L3=200,M3=2.0,Max_N=1},
        ['Tornado II'] = {V=800, L1=50,M0=2,L2=100,M50=2.00,L3=200,M3=2.0,Max_N=1},
        ['Flare II']   = {V=800, L1=50,M0=2,L2=100,M50=2.00,L3=200,M3=2.0,Max_N=1},
        ['Freeze II']  = {V=800, L1=50,M0=2,L2=100,M50=2.00,L3=200,M3=2.0,Max_N=1},
        ['Burst II']   = {V=800, L1=50,M0=2,L2=100,M50=2.00,L3=200,M3=2.0,Max_N=1},
        ['Comet']      = {V=1000,L1=50,M0=4,L2=100,M50=3.75,L3=200,M3=3.5,Max_N=1},
        
        ['Stonega'] =     {V=60, L1=50,M0=3.0,L2=100,M50=2.0,L3=200,M3=1.00,Max_N=10},
        ['Waterga'] =     {V=80, L1=50,M0=2.8,L2=100,M50=1.9,L3=200,M3=1.00,Max_N=10},
        ['Aeroga'] =      {V=100,L1=50,M0=2.6,L2=100,M50=1.8,L3=200,M3=1.00,Max_N=10},
        ['Firaga'] =      {V=120,L1=50,M0=2.4,L2=100,M50=1.7,L3=200,M3=1.00,Max_N=10},
        ['Blizzaga'] =    {V=160,L1=50,M0=2.2,L2=100,M50=1.6,L3=200,M3=1.00,Max_N=10},
        ['Thundaga'] =    {V=200,L1=50,M0=2.0,L2=100,M50=1.5,L3=200,M3=1.00,Max_N=10},
        
        ['Stonega II'] =  {V=250,L1=50,M0=4.0,L2=100,M50=3.0,L3=200,M3=2.00,Max_N=10},
        ['Waterga II'] =  {V=280,L1=50,M0=3.7,L2=100,M50=2.9,L3=200,M3=1.95,Max_N=10},
        ['Aeroga II'] =   {V=310,L1=50,M0=3.4,L2=100,M50=2.8,L3=200,M3=1.90,Max_N=10},
        ['Firaga II'] =   {V=340,L1=50,M0=3.1,L2=100,M50=2.7,L3=200,M3=1.85,Max_N=10},
        ['Blizzaga II'] = {V=370,L1=50,M0=2.8,L2=100,M50=2.6,L3=200,M3=1.80,Max_N=10},
        ['Thundaga II'] = {V=400,L1=50,M0=2.5,L2=100,M50=2.5,L3=200,M3=1.75,Max_N=10},
        
        ['Stonega III'] =  {V=500,L1=50,M0=5.0,L2=100,M50=4.0,L3=200,M3=3.00,Max_N=10},
        ['Waterga III'] =  {V=540,L1=50,M0=4.7,L2=100,M50=3.9,L3=200,M3=2.95,Max_N=10},
        ['Aeroga III'] =   {V=580,L1=50,M0=4.4,L2=100,M50=3.8,L3=200,M3=2.90,Max_N=10},
        ['Firaga III'] =   {V=620,L1=50,M0=4.2,L2=100,M50=3.7,L3=200,M3=2.85,Max_N=10},
        ['Blizzaga III'] = {V=660,L1=50,M0=3.9,L2=100,M50=3.6,L3=200,M3=2.80,Max_N=10},
        ['Thundaga III'] = {V=700,L1=50,M0=3.6,L2=100,M50=3.5,L3=200,M3=2.75,Max_N=10},
        
        ['Stoneja'] =  {V=750, L1=50,M0=6.0,L2=100,M50=5.00,L3=200,M3=4.00,Max_N=10},
        ['Waterja'] =  {V=800, L1=50,M0=5.6,L2=100,M50=4.75,L3=200,M3=3.95,Max_N=10},
        ['Aeroja'] =   {V=850, L1=50,M0=5.2,L2=100,M50=4.50,L3=200,M3=3.90,Max_N=10},
        ['Firaja'] =   {V=900, L1=50,M0=4.8,L2=100,M50=4.25,L3=200,M3=3.85,Max_N=10},
        ['Blizzaja'] = {V=950, L1=50,M0=4.4,L2=100,M50=4.00,L3=200,M3=3.80,Max_N=10},
        ['Thundaja'] = {V=1000,L1=50,M0=4.0,L2=100,M50=3.75,L3=200,M3=3.75,Max_N=10},
        
        ['Geohelix']    = {V=0,L1=75,M0=1.1,L2=85,M50=0.75,L3=200,M3=0.5,Max_N=1},
        ['Hydrohelix']  = {V=0,L1=75,M0=1.1,L2=85,M50=0.75,L3=200,M3=0.5,Max_N=1},
        ['Anemohelix']  = {V=0,L1=75,M0=1.1,L2=85,M50=0.75,L3=200,M3=0.5,Max_N=1},
        ['Pyrohelix']   = {V=0,L1=75,M0=1.1,L2=85,M50=0.75,L3=200,M3=0.5,Max_N=1},
        ['Cryohelix']   = {V=0,L1=75,M0=1.1,L2=85,M50=0.75,L3=200,M3=0.5,Max_N=1},
        ['Ionohelix']   = {V=0,L1=75,M0=1.1,L2=85,M50=0.75,L3=200,M3=0.5,Max_N=1},
        ['Luminohelix'] = {V=0,L1=75,M0=1.1,L2=85,M50=0.75,L3=200,M3=0.5,Max_N=1},
        ['Noctohelix']  = {V=0,L1=75,M0=1.1,L2=85,M50=0.75,L3=200,M3=0.5,Max_N=1},
        }
    
    stuntarg = 'Shantotto'
    send_command('input /macro book 2;wait .1;input /macro set 1')
    
    AMII = {['Freeze II']=true,['Burst II']=true,['Quake II'] = true, ['Tornado II'] = true,['Flood II']=true,['Flare II']=true}
    
end

function precast(spell)
    if AMII[spell.english] then
        equip(sets.precast.FastCast_ElementalMagic,{hands="Archmage's Gloves"})
    elseif spell.english == 'Impact' then
        equip(sets.precast.FastCast_ElementalMagic,{body="Twilight Cloak"})
        if not buffactive.elementalseal then
            add_to_chat(8,'--------- Elemental Seal is down ---------')
        end
    elseif spell.english == 'Stun' then
        if spell.target.name == 'Paramount Mantis' or spell.target.name == 'Tojil' then
            equip(sets.precast.Stun_MAcc)
        else
            equip(sets.precast.Stun)
        end
        if stuntarg ~= 'Shantotto' then
            send_command('@input /t '..stuntarg..' ---- Byrth Stunned!!! ---- ')
        end
        --force_send()
    elseif spell.action_type == 'Magic' then
        if spell.skill == 'Elemental Magic' then
            equip(sets.precast.FastCast_ElementalMagic)
        else
            equip(sets.precast.FastCast_Other)
        end
    elseif sets.precast[spell.english] then
        equip(sets.precast[spell.english])
    end
    
    if sets.FC.staves[spell.element] then
        equip(sets.FC.staves[spell.element])
    end
end

function midcast(spell)
    if AMII[spell.english] then
        weathercheck(spell.element,sets.midcast[spell.skill])
        equip({head="Archmage's Petasos +1"})
    elseif string.find(spell.english,'Cur') then 
        weathercheck(spell.element,sets.midcast.Cure)
    elseif spell.english == 'Impact' then
        local tempset = sets.midcast[spell.skill]
        tempset['body'] = 'Twilight Cloak'
        tempset['head'] = 'empty'
        weathercheck(spell.element,tempset)
    elseif spell.english == 'Stoneskin' then
        equip(sets.midcast.Stoneskin)
    elseif spell.skill then
        weathercheck(spell.element,sets.midcast[spell.skill])
    end
    
    if spell.english == 'Sneak' then
        send_command('@wait 1.8;cancel 71;')
    end
end

function aftercast(spell)
    equip(sets.aftercast.Idle)
    if spell.english == 'Sleep' or spell.english == 'Sleepga' then
        send_command('@wait 55;input /echo ------- '..spell.english..' is wearing off in 5 seconds -------')
    elseif spell.english == 'Sleep II' or spell.english == 'Sleepga II' then
        send_command('@wait 85;input /echo ------- '..spell.english..' is wearing off in 5 seconds -------')
    elseif spell.english == 'Break' or spell.english == 'Breakga' then
        send_command('@wait 25;input /echo ------- '..spell.english..' is wearing off in 5 seconds -------')
    end
end

function status_change(new,old)
    if new == 'Resting' then
        equip(sets.aftercast.Resting)
    else
        equip(sets.aftercast.Idle)
    end
end

function self_command(command)
    if command == 'stuntarg' then
        stuntarg = target.name
    end
end

-- This function is user defined, but never called by GearSwap itself. It's just a user function that's only called from user functions. I wanted to check the weather and equip a weather-based set for some spells, so it made sense to make a function for it instead of replicating the conditional in multiple places.

function weathercheck(spell_element,set)
    if spell_element == world.weather_element or spell_element == world.day_element then
        equip(set,sets.Obis[spell_element])
    else
        equip(set)
    end
    if set[spell_element] then equip(set[spell_element]) end
end
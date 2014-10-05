function get_sets()
    ---  PRECAST SETS  ---
    sets.precast = {}
    
    sets.precast.JA = {}
    sets.precast.JA.Enlightenment = {head="Argute Gown +2"}
    sets.precast.JA['Tabula Rasa'] = {head="Argute Pants +2"}
        
    sets.precast.FastCast = {main="Ngqoqwanb",range=empty,ammo="Impatiens",head="Nahtirah Hat",neck="Orunmila's Torque",
        ear2="Loquacious Earring",body="Anhur Robe",hands="Gendewitha Gages",lring="Prolix Ring",rring="Veneficium Ring",
        back="Swith Cape +1",waist="Witful Belt",legs="Artsieq Hose",feet="Academic's Loafers"}
    
    sets.precast.EnhancingMagic = set_combine(sets.precast.FastCast,{waist="Siegel Sash"})
    
    sets.precast.FC_Weather = {feet="Pedagogy Loafers"}
    
    sets.precast.Cure = set_combine(sets.precast.FastCast,{body="Heka's Kalasiris",back="Pahtli Cape"})
    
    
    ---  MIDCAST SETS  ---
    sets.midcast = {}
    
    sets.midcast['Elemental Magic'] = {main="Ngqoqwanb",sub="Zuuxowu Grip",range=empty,ammo="Dosis Tathlum",
        head="Hagondes Hat",neck="Eddy Necklace",ear1="Friomisi Earring",ear2="Novio Earring",
        body="Seidr Cotehardie",hands="Yaoyotl Gloves",ring1="Icesoul Ring",ring2="Icesoul Ring",
        back="Toro Cape",waist="Wanion Belt",legs="Hagondes Pants",feet="Hagondes Sabots"}
    
    sets.midcast.Helix = {main="Ngqoqwanb",sub="Zuuxowu Grip",range=empty,ammo="Dosis Tathlum",
        head="Hagondes Hat",neck="Eddy Necklace",ear1="Friomisi Earring",ear2="Novio Earring",
        body="Academic's Gown",hands="Yaoyotl Gloves",ring1="Icesoul Ring",ring2="Icesoul Ring",
        back="Twilight Cape",waist="Wanion Belt",legs="Hagondes Pants",feet={name="Hagondes Sabots",augment="Magic Attack Bonus +22"}}
    
    sets.midcast.Stun = {main="Ngqoqwanb",sub="Arbuda Grip",range="Aureole",ammo=empty,
        head="Nahtirah Hat",neck="Aesir Torque",ear1="Belatz Pearl",ear2="Loquacious Earring",
        body="Hedera Cotehardie",hands="Bokwus Gloves",lring="Prolix Ring",rring="Icesoul Ring",
        back="Merciful Cape",waist="Goading Belt",legs="Hagondes Pants",feet="Academic's Loafers"}
    
    sets.midcast['Dark Magic'] = {main="Ngqoqwanb",sub="Arbuda Grip",range="Aureole",ammo=empty,
        head="Striga Crown",neck="Aesir Torque",ear1="Hirudinea Earring",ear2="Loquacious Earring",
        body="Hedera Cotehardie",hands="Bokwus Gloves",ring1="Icesoul Ring",ring2="Excelsis Ring",
        back="Toro Cape",waist="Wanion Belt",legs="Hagondes Pants",feet="Bokwus Boots"}
    
    sets.midcast['Enfeebling Magic'] = {main="Ngqoqwanb",sub="Arbuda Grip",range="Aureole",ammo=empty,
        head="Nahtirah Hat",neck="Eddy Necklace",ear1="Psystorm Earring",ear2="Lifestorm Earring",
        body="Seidr Cotehardie",hands="Hagondes Cuffs +1",ring1="Sangoma Ring",ring2="Omega Ring",
        back="Refraction Cape",waist="Wanion Belt",legs="Artsieq Hose",feet="Bokwus Boots"}
    
    sets.midcast['Healing Magic'] = {}
    
    sets.midcast.Embrava = {main="Kirin's Pole",sub="Fulcio Grip",range=empty,ammo="Savant's Treatise",
        head="Svnt. Bonnet +2",neck="Colossus's Torque",
        body="Anhur Robe",
        back="Merciful Cape",waist="Olympus Sash",legs="Shedir Seraweels",feet="Rubeus Boots"}
    
    sets.midcast['Enhancing Magic'] = {main="Kirin's Pole",sub="Fulcio Grip",range=empty,ammo="Savant's Treatise",
        head="Svnt. Bonnet +2",neck="Colossus's Torque",
        body="Anhur Robe",
        back="Merciful Cape",waist="Olympus Sash",legs="Shedir Seraweels",feet="Rubeus Boots"}
        
    sets.midcast.Regen = {head="Savant's Bonnet +2"}
    
    sets.midcast.Cure = {main="Chatoyant Staff",neck="Phalaina Locket",body="Heka's Kalasiris",hands="Bokwus Gloves",legs="Nares Trews"}
    
    sets.midcast.Stoneskin = {neck="Stone Gorget",waist="Siegel Sash",legs="Shedir Seraweels"}
    
    
    
    ---  AFTERCAST SETS  ---
    sets.Idle = {}
    sets.Idle.noSub = {main="Terra's Staff",sub="Arbuda Grip",range=empty,ammo="Savant's Treatise",
        head="Spurrina Coif",neck="Twilight Torque",ear1="Gifted earring",ear2="Loquacious Earring",
        body="Academic's Gown",hands="Serpentes Cuffs",ring1="Defending Ring",ring2="Dark Ring",
        back="Umbra Cape",waist="Siegel Sash",legs="Nares Trews",feet="Herald's Gaiters"}
    
    sets.Idle.Sub = {main="Terra's Staff",sub="Arbuda Grip",range=empty,ammo="Mana ampulla",
        head="Spurrina Coif",neck="Twilight Torque",ear1="Savant's earring",ear2="Loquacious Earring",
        body="Academic's Gown",hands="Serpentes Cuffs",ring1="Defending Ring",ring2="Dark Ring",
        back="Umbra Cape",waist="Siegel Sash",legs="Nares Trews",feet="Herald's Gaiters"}
    
    sets.Idle.Current = sets.Idle.noSub
    
    sets.Resting = {main="Numen Staff",sub="Ariesian Grip",range=empty,ammo="Mana ampulla",
        head="Spurrina Coif",neck="Eidolon Pendant",ear1="Relaxing Earring",ear2="Antivenom Earring",
        body="Academic's Gown",hands="Nares Cuffs",ring1="Celestial Ring",ring2="Angha Ring",
        back="Felicitas Cape +1",waist="Austerity Belt +1",legs="Nares Trews",feet="Serpentes Sabots"}
    
    
    
    ---  OTHER SETS  ---
    
    -- Relevant Obis. Add the ones you have.
    sets.obi = {}
    sets.obi.Wind = {waist='Furin Obi'}
    sets.obi.Ice = {waist='Hyorin Obi'}
    sets.obi.Lightning = {waist='Rairin Obi'}
    sets.obi.Light = {waist='Korin Obi'}
    sets.obi.Dark = {waist='Anrin Obi'}
    sets.obi.Water = {waist='Suirin Obi'}
    sets.obi.Earth = {waist='Dorin Obi'}
    sets.obi.Fire = {waist='Karin Obi'}
    
    -- Generic gear for day/weather
    sets.weather = {back='Twilight Cape'}
    sets.day = {lring='Zodiac Ring'}
    
    -- If you have nuking gear that only affects one element, you can put it here
    -- For example, Earth Magic Attack Bonus +9
    sets.ele = {}
--    sets.ele.Stone = {neck="Quanpur Necklace"}
    
    sets.staves = {}
    
    -- Magic damage staves, which are used for reducing casting time
    sets.staves.damage = {}
    sets.staves.damage.Lightning = {main="Apamajas I"}
    sets.staves.damage.Fire = {main="Atar I"}
    
    -- Various pieces that enhance specific JAs/spells/etc.
    sets.enh = {}
    sets.enh.Rapture = {head="Savant's Bonnet +2"}
    sets.enh.Ebullience = {head="Savant's Bonnet +2"}
--    sets.enh['Addendum: Black'] = {body="Savant's Gown +2"}
--    sets.enh['Addendum: White'] = {body="Savant's Gown +2"}
    sets.enh.Perpetuance = {hands="Savant's Bracers +2"}
--    sets.enh.Penury = {legs="Savant's Pants +2"}
--    sets.enh.Parsimony = {legs="Savant's Pants +2"} -- I never really want to sacrifice offensive leg stats for an additional -25% MP cost on a half-price spell.
    sets.enh.Klimaform = {feet="Savant's Loafers +2"}
    
    
--    sets.enh.Altruism = {head="Argute Mortarboard +2"}
--    sets.enh.Focalization = {head="Argute Mortarboard +2"}
--    sets.enh.Tranquility = {hands="Argute Bracers +2"}
--    sets.enh.Equanimity = {hands="Argute Bracers +2"}
--    sets.enh.Storm = {feet="Pedagogy Loafers"}

    sets.HELM = {body="Trench Tunic",hands="Field Gloves",legs="Dredger Hose",feet="Field Boots"}
    
    stuntarg = 'Shantotto'
end

function precast(spell)
    if spell.name == 'Celerity' then
        equip({head="Nahtirah Hat"})
    end
    if string.find(spell.name:lower(),'hatchet') or string.find(spell.name:lower(),'pickaxe') or string.find(spell.name:lower(),'sickle') then
        if buffactive.invisible then windower.send_command('cancel invisible') end
        equip(sets.HELM)
    elseif sets.precast.JA[spell.name] then
        equip(sets.precast.JA[spell.name])
    elseif string.find(spell.name,'Cur') and spell.name ~= 'Cursna' then
        equip(sets.precast.Cure)
    elseif spell.skill == 'EnhancingMagic' then
        equip(sets.precast.EnhancingMagic)
    elseif spell.action_type == 'Magic' then
        equip(sets.precast.FastCast)
    end

    if (buffactive.alacrity or buffactive.celerity) and world.weather_element == spell.element and not (spell.skill == 'ElementalMagic' and spell.casttime <3 and buffactive.Klimaform) then
        equip(sets.precast.FC_Weather)
    end
    
    if spell.name == 'Impact' then
        if not buffactive['Elemental Seal'] then
            add_to_chat(8,'--------- Elemental Seal is down ---------')
        end
        equip({head=empty,body="Twilight Cloak"})
    elseif spell.name == 'Stun' then
        if not buffactive.thunderstorm then
            add_to_chat(8,'--------- Thunderstorm is down ---------')
        elseif not buffactive.klimaform then
            add_to_chat(8,'----------- Klimaform is down -----------')
        end
        if stuntarg ~= 'Shantotto' then
            send_command('@input /t '..stuntarg..' ---- Byrth Stunned!!! ---- ')
        end
    end
end

function midcast(spell)
    if string.find(spell.english,'Cur') then 
        equip(sets.midcast.Cure)
        weathercheck(spell.element)
        if buffactive.rapture then equip(sets.enh.Rapture) end
    elseif spell.skill=="Elemental Magic" or spell.name == "Kaustra" then
        if string.find(spell.english,'helix') or spell.name == 'Kaustra' then
            equip(sets.midcast.Helix)
            if sets.ele[spell.element] then equip(sets.ele[spell.element]) end
            if spell.element == world.weather_element then
                equip(sets.weather)
            end
            if spell.element == world.day_element then
                equip(sets.day)
            end
        else
            equip(sets.midcast['Elemental Magic'])
            if sets.ele[spell.element] then equip(sets.ele[spell.element]) end
            weathercheck(spell.element)
        end
        if buffactive.ebullience then equip(sets.enh.Ebullience) end
        if buffactive.klimform then equip(sets.enh.Klimaform) end
    elseif spell.english == 'Impact' then
        equip(sets.midcast[spell.skill],{head=empty,body="Twilight Cloak"})
        weathercheck(spell.element)
    elseif spell.english == 'Stoneskin' then
        equip(sets.midcast.Stoneskin)
    elseif spell.skill == 'Enhancing Magic' then
        equip(sets.midcast.EnhancingMagic)
        if spell.english == 'Embrava' then
            equip(sets.midcast.Embrava)
            if not buffactive.perpetuance then
                add_to_chat(8,'--------- Perpetuance is down ---------')
            end
            if not buffactive.accession then
                add_to_chat(8,'--------- Accession is down ---------')
            end
            if not buffactive.penury then
                add_to_chat(8,'--------- Penury is down ---------')
            end
        else
            if string.find(spell.english,'Regen') then
                equip(sets.midcast.Regen)
            end
            if buffactive.penury then equip(sets.enh.Penury) end
        end
        if buffactive.perpetuance then equip(sets.enh.Perpetuance) end
    elseif spell.skill == 'Enfeebling Magic' then
        equip(sets.midcast['Enfeebling Magic'])
        if spell.type == 'WhiteMagic' and buffactive.altruism then equip(sets.enh.Altruism) end
        if spell.type == 'BlackMagic' and buffactive.focalization then equip(sets.enh.Focalization) end
    else
        equip(sets.midcast[spell.skill])
        weathercheck(spell.element)
    end
    
    if spell.english == 'Sneak' and buffactive.sneak then
        send_command('@wait 1;cancel 71;')
    end
end        

function aftercast(spell)
    equip(sets.Idle.Current)
    
    if spell.english == 'Sleep' or spell.english == 'Sleepga' then
        send_command('@wait 50;input /echo ------- '..spell.english..' is wearing off in 10 seconds -------')
    elseif spell.english == 'Sleep II' or spell.english == 'Sleepga II' then
        send_command('@wait 80;input /echo ------- '..spell.english..' is wearing off in 10 seconds -------')
    elseif spell.english == 'Break' or spell.english == 'Breakga' then
        send_command('@wait 20;input /echo ------- '..spell.english..' is wearing off in 10 seconds -------')
    end
end

function status_change(new,tab)
    if new == 'Resting' then
        equip(sets.Resting)
    else
        equip(sets.Idle.Current)
    end
end

function buff_change(status,gain_or_loss)
    if status == 'Sublimation: Complete' then -- True whether gained or lost
        sets.Idle.Current = sets.Idle.noSub
    elseif status == 'Sublimation: Activated' then
        sets.Idle.Current = sets.Idle.Sub
    end
    equip(sets.Idle.Current)
end

function self_command(command)
    if command == 'stuntarg' then
        stuntarg = target.name
    end
end

-- This function is user defined, but never called by GearSwap itself. It's just a user function that's only called from user functions. I wanted to check the weather and equip a weather-based set for some spells, so it made sense to make a function for it instead of replicating the conditional in multiple places.

function weathercheck(spell_element)
    if spell_element == world.weather_element then
        equip(sets.weather)
        if sets.obi[spell_element] then
            equip(sets.obi[spell_element])
        end
    end
    if spell_element == world.day_element then
        equip(sets.day)
        if sets.obi[spell_element] then
            equip(sets.obi[spell_element])
        end
    end
end
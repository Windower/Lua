function get_sets()
    -- Precast Sets
    sets.precast = {}
    
    sets.precast.FC = {head="Nahtirah Hat",neck="Orunmila's Torque",ear1="Loquac. Earring",ear2="Enchanter Earring +1",body="Marduk's Jubbah +1",
        hands="Hagondes Cuffs",ring1="Veneficium Ring",ring2="Prolix Ring",back="Swith Cape +1",waist="Siegel Sash",legs="Artsieq Hose",
        feet="Chelona Boots +1",Thunder={main='Apamajas I'},Fire={main='Atar I'}}
        
    sets.precast.Cur = {body="Heka's Kalasiris",legs="Nabu's Shalwar",back="Pahtli Cape"}
    
    -- Midcast sets
    sets.midcast = {}
    
    sets.midcast.BP = {ammo="Seraphicaller",head="Glyphic Horn +1",body="Glyphic Doublet +1",hands="Glyphic Bracers +1",back="Samanisi Cape",legs="Glyphic Spats +1",feet="Glyphic Pigaches +1"}
    
    sets.midcast['Mana Cede'] = {hands="Call. Bracers +2"}
    
    sets.midcast['Elemental Siphon'] = {main="Soulscourge",sub="Vox Grip",
        head="Marduk's Tiara +1",neck="Caller's Pendant",rear="Smn. Earring",lear="Andoaa Earring",
        body="Call. Doublet +2",hands="Glyphic Bracers +1",lring="Evoker's Ring",rring="Fervor Ring",
        back="Conveyance Cape",legs="Mdk. Shalwar +1",feet="Caller's Pgch. +2"}
                    
    sets.midcast.Cur = {main="Arka IV",head="Marduk's Tiara +1",ear2="Novia earring",
        body="Heka's Kalasiris"}
        
    sets.midcast.Stoneskin = {head="Marduk's Tiara +1",neck="Stone Gorget",body="Marduk's Jubbah +1",
        hands="Marduk's Dastanas +1",waist="Siegel Sash",legs="Shedir Seraweels"}
    
    -- Pet Midcast Sets
    sets.pet_midcast = {}
    
    sets.BP_Base = {main="Tumafyrig",sub="Vox grip",ammo="Seraphicaller",
        head="Glyphic Horn +1",rear="Smn. Earring",lear="Andoaa Earring",
        body="Call. Doublet +2",hands="Spurrina Gages",ring1="Evoker's Ring",ring2="Fervor Ring",
        legs="Ngen Seraweels",feet="Convoker's Pigaches +1"}
    
    sets.pet_midcast.Phys_BP = set_combine(sets.BP_Base,{main="Soulscourge",head="Caller's horn +2",neck="Caller's Pendant",back="Samanisi Cape",waist="Mujin Obi"})
        
    sets.pet_midcast.MAB_No_TP_BP = set_combine(sets.BP_Base,{neck="Eidolon Pendant",hands="Hagondes Cuffs +1",back="Samanisi Cape",waist="Caller's sash",legs="Hagondes Pants",feet="Hagondes Sabots"})
        
    sets.pet_midcast.MAB_TP_BP = set_combine(sets.BP_Base,{neck="Eidolon Pendant",hands="Hagondes Cuffs +1",back="Samanisi Cape",waist="Caller's sash",legs="Caller's spats +2",feet="Hagondes Sabots"})
        
    sets.pet_midcast.MAB_Spell = set_combine(sets.BP_Base,{neck="Eidolon Pendant",hands="Hagondes Cuffs +1",back="Samanisi Cape",waist="Caller's sash",legs="Hagondes Pants",feet="Hagondes Sabots"})
        
    sets.pet_midcast.MAcc_BP = set_combine(sets.BP_Base,{neck="Caller's Pendant",body="Anhur Robe",hands="Glyphic Bracers +1",back="Samanisi Cape",legs="Glyphic Spats +1",feet="Caller's Pgch. +2"})
    
    sets.pet_midcast.Buff_BP = set_combine(sets.BP_Base,{main="Chatoyant Staff",head="Caller's Horn +2",neck="Caller's Pendant",hands="Glyphic Bracers +1",back="Conveyance Cape",legs="Nares Trews"})
    
    sets.pet_midcast['Shock Squall'] = {main="Soulscourge",sub="Vox Grip",
        head="Marduk's Tiara +1",neck="Caller's Pendant",rear="Smn. Earring",
        body="Call. Doublet +2",hands="Glyphic Bracers +1",lring="Evoker's Ring",rring="Fervor Ring",
        back="Samanisi Cape",legs="Glyphic Spats +1",feet="Glyphic Pigaches +1"}
    
    --Aftercast Sets
    sets.aftercast = {}
    
    sets.aftercast.None = {main="Terra's Staff",sub="Oneiros Grip",
        head="Caller's Horn +2",neck="Twilight Torque",ear1="Loquac. Earring",ear2="Antivenom Earring",
        body="Marduk's Jubbah +1",hands="Marduk's Dastanas +1",ring1="Dark Ring",ring2="Defending Ring",
        back="Umbra Cape",waist="Hierarch belt",legs="Nares Trews",feet="Herald's Gaiters"}
    
    sets.aftercast.Favor = {main="Chatoyant Staff",sub="Vox grip",ammo="Seraphicaller",
        head="Caller's Horn +2",neck="Caller's Pendant",ear1="Loquac. Earring",ear2="Antivenom Earring",
        body="Caller's Doublet +2",hands="Glyphic Bracers +1",ring1="Evoker's Ring",ring2="Fervor Ring",
        back="Conveyance Cape",waist="Hierarch belt",legs="Ngen Seraweels",feet="Rubeus Boots"}
    
    sets.aftercast.Perp_Base = {main="Chatoyant Staff",sub="Oneiros Grip",ammo="Seraphicaller",
        head="Caller's Horn +2",neck="Caller's Pendant",
        body="Glyphic Doublet +1",hands="Glyphic Bracers +1",ring1="Evoker's Ring",ring2="Defending Ring",
        waist="Hierarch belt",legs="Nares Trews",feet="Convoker's Pigaches +1"}
    
    sets.aftercast.Avatar = {}
    sets.aftercast.Avatar.Carbuncle = {hands="Carbuncle Mitts"}
    
    sets.aftercast.Avatar.Diabolos = {waist="Diabolos's Rope"}
    
    sets.aftercast.Avatar.Spirit = {main="Soulscourge",sub="Vox grip",ammo="Seraphicaller",
        head="Caller's Horn +2",neck="Caller's Pendant",ear2="Smn. Earring",
        body="Caller's Doublet +2",hands="Glyphic Bracers +1",ring1="Evoker's Ring",ring2="Fervor Ring",
        back="Conveyance Cape",legs="Glyphic Spats +1",feet="Rubeus Boots"}
                
    sets.aftercast.Resting = {main="Numen Staff",sub="Ariesian Grip",ammo="Mana Ampulla",
        head="Caller's Horn +2",neck="Eidolon Pendant",ear1="Relaxing Earring",ear2="Antivenom Earring",
        body="Marduk's Jubbah +1",hands="Nares Cuffs",ring1="Celestial Ring",ring2="Angha Ring",
        back="Felicitas Cape +1",waist="Austerity Belt +1",legs="Nares Trews",feet="Chelona Boots +1"}
    
    sets.aftercast.Idle = sets.aftercast_None    
    
    -- Variables and notes to myself
    Debuff_BPs = T{'Diamond Storm','Sleepga','Slowga','Tidal Roar','Shock Squall','Nightmare','Pavor Nocturnus','Ultimate Terror','Somnolence','Lunar Cry','Lunar Roar'}
    Magical_BPs_affected_by_TP = T{'Heavenly Strike','Wind Blade','Holy Mist','Night Terror','Thunderstorm','Geocrush','Meteor Strike','Grand Fall','Lunar Bay','Thunderspark'} -- Unsure if Thunderspark is affected by TP
    Magical_BPs_unaffected_by_TP = T{'Nether Blast','Aerial Blast','Searing Light','Diamond Dust','Earthen Fury','Zantetsuken','Tidal Wave','Judgment Bolt','Inferno','Howling Moon','Ruinous Omen','Flaming Crush'}
    Additional_effect_BPs = T{'Rock Throw'}    
    AvatarList = S{'Shiva','Ramuh','Garuda','Leviathan','Diabolos','Titan','Fenrir','Ifrit','Carbuncle',
        'Fire Spirit','Air Spirit','Ice Spirit','Thunder Spirit','Light Spirit','Dark Spirit','Earth Spirit','Water Spirit',
        'Cait Sith','Alexander','Odin','Atomos'}
    send_command('input /macro book 8;wait .1;input /macro set 1')
end

function pet_change(pet,gain)
    idle(pet)
end

function precast(spell)
    if midaction() or pet_midaction() then
        cancel_spell()
        return
    end
--    print_set(gearswap.out_arr,'midaction: '..tostring(midaction())..'  pet_midaction: '..tostring(pet_midaction()))
    if spell.action_type == 'Magic' then
        equip(sets.precast.FC)
        if string.find(spell.english,'Cur') then
            equip(sets.precast.Cur)
        end
    end
    
    if sets.precast.FC[spell.element] then equip(sets.precast.FC[spell.element]) end
end

function midcast(spell)
    if pet_midaction() then
        return
    end
    if string.find(spell.type,'BloodPact') then
        if buffactive['Astral Conduit'] then
            pet_midcast(spell)
        else
            equip(sets.midcast.BP)
        end
    elseif string.find(spell.english,'Cur') then
        equip(sets.midcast.Cur)
    elseif sets.midcast[spell.english] then
        equip(sets.midcast[spell.english])
    else
        idle(pet)
    end
end

function aftercast(spell)
    if pet_midaction() then
        return
    end
    if spell and (not spell.type or not string.find(spell.type,'BloodPact') and not AvatarList:contains(spell.name) or spell.interrupted) then -- and spell.name ~= 'Release'
        -- Don't want to swap away too quickly if I'm about to put BP damage gear on
        -- Need to wait 1 in order to allow pet information to update on Release.
        idle(pet)
    end
end

function status_change(new,old)
    if new=='Idle' then
        idle(pet)
    elseif new=='Resting' then
        equip(sets.aftercast.Resting)
    end
end

function pet_midcast(spell)
    if spell.name == 'Perfect Defense' then
        equip(sets.midcast['Elemental Siphon'],{feet="Rubeus Boots"})
    elseif spell.type=='BloodPactWard' then
        if Debuff_BPs:contains(spell.name) then
            equip(sets.pet_midcast.MAcc_BP)
        else
            equip(sets.pet_midcast.Buff_BP)
        end
    elseif spell.type=='BloodPactRage' then
        if Magical_BPs_affected_by_TP:contains(spell.name) or string.find(spell.name,' II') or string.find(spell.name,' IV') then
            if (spell.name == 'Heavenly Strike' and pet.TP > 120) or pet.TP > 280 then
                equip(sets.pet_midcast.MAB_No_TP_BP)
            else
                equip(sets.pet_midcast.MAB_TP_BP)
            end
        elseif Magical_BPs_unaffected_by_TP:contains(spell.name) then
            equip(sets.pet_midcast.MAB_No_TP_BP)
        elseif Additional_effect_BPs:contains(spell.name) then -- for BPs where the additional effect matters more than the damage
            equip(sets.pet_midcast.MAcc_BP)
        else
            equip(sets.pet_midcast.Phys_BP)
        end
    elseif spell.type=='BlackMagic' then
        equip(sets.pet_midcast.MAB_Spell)
    end
end

function pet_aftercast(spell)
    idle(pet)
end

function self_command(command)
    if command == 'Idle' then
        idle(pet)
    end
end

function idle(pet)
    equip(sets.aftercast.None)
    if pet.isvalid then
        if string.find(pet.name,'Spirit') then
            equip(sets.aftercast.Avatar.Spirit)
        elseif buffactive["Avatar's Favor"] then
            equip(sets.aftercast.Favor)
        else
            equip(sets.aftercast.Perp_Base)
            if sets.aftercast.Avatar[pet.name] then
                equip(sets.aftercast.Avatar[pet.name])
            end
        end
    end
end
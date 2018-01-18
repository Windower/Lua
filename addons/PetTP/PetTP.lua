config = require ('config')
texts  = require('texts')
packets = require('packets')
require('pack')

_addon.name     = 'PetTP'
_addon.author   = 'SnickySnacks'
_addon.version  = '1.02'
_addon.commands = {'ptp','pettp'}

petname            = nil
mypet_idx          = nil
current_hp         = 0
max_hp             = 0
current_mp         = 0
max_mp             = 0
current_hp_percent = 0
current_mp_percent = 0
current_tp_percent = 0
petactive          = false
verbose            = false
superverbose       = false
timercountdown     = 0

defaults = T{}

defaults.autocolor = true

defaults.pos   = T{}
defaults.pos.x = windower.get_windower_settings().x_res*2/3
defaults.pos.y = windower.get_windower_settings().y_res-17

defaults.bg         = T{}
defaults.bg.alpha   = 255
defaults.bg.red     = 0
defaults.bg.green   = 0
defaults.bg.blue    = 0
defaults.bg.visible = true

defaults.flags        = {}
defaults.flags.right  = false
defaults.flags.bottom = false
defaults.flags.bold   = false
defaults.flags.italic = false

defaults.text       = {}
defaults.text.size  = 10
defaults.text.font  = 'Courier New'
defaults.text.alpha = 255
defaults.text.red   = 255
defaults.text.green = 255
defaults.text.blue  = 255

settings = config.load(defaults)
pettp    = texts.new(settings)

function make_visible()
    petactive = true
    pettp:visible(true);
    if verbose == true then windower.add_to_chat(8, 'PetTP Visible') end
end

function make_invisible()
    if petactive then
        pettp:text('')
        pettp:visible(false)
        if verbose == true then windower.add_to_chat(8, 'PetTP Invisible') end
    end
    petactive = false
    mypet_idx = nil
    petname = nil
    current_hp = 0
    max_hp       = 0
    current_mp = 0
    max_mp       = 0
    current_hp_percent = 0
    current_mp_percent = 0
    current_tp_percent = 0
end

function valid_pet(source,pet_idx_in, own_idx_in)
    local player = windower.ffxi.get_player()
    if superverbose == true then windower.add_to_chat(8, 'valid_pet('..source..'): petactive: '..tostring(petactive)..', mypet_idx: '..(mypet_idx or 'nil')..', pet_idx_in: '..(pet_idx_in or 'nil')..', own_idx_in: '..(own_idx_in or 'nil')..', player.index '..player.index) end
    if player.vitals.hp == 0 then
        if superverbose == true then windower.add_to_chat(8, 'valid_pet() : false : Player is dead') end
        timercountdown = 0
        return
    end

    if petactive then 
        if mypet_idx then
            if not pet_idx_in or mypet_idx == pet_idx_in then
                if superverbose == true then windower.add_to_chat(8, 'valid_pet() : true : using mypet_idx') end
                return mypet_idx
            else
                if superverbose == true then 
                    windower.add_to_chat(8, 'mypet_idx ~= pet_idx_in '..mypet_idx..' vs. '..pet_idx_in) 
                end
            end
        elseif own_idx_in and player.index == own_idx_in then
            if superverbose == true then windower.add_to_chat(8, 'valid_pet() : true : using pet_idx_in') end
            mypet_idx = pet_idx_in
            return mypet_idx
        end
    end
    
    local pet = windower.ffxi.get_mob_by_target('pet')    
    if pet_idx_in and pet and pet_idx_in ~= pet.index then
        if superverbose == true then windower.add_to_chat(8, 'valid_pet() : false : pet.index ~= pet_idx_in '..pet.index..' vs. '..pet_idx_in) end
        return
    elseif pet_idx_in and player.mob and player.mob.pet_index and pet_idx_in ~= player.mob.pet_index then
        if superverbose == true then windower.add_to_chat(8, 'valid_pet() : false : player.mob.pet_index ~= pet_idx_in '..player.mob.pet_index..' vs. '..pet_idx_in) end
        return
    elseif pet then
        if superverbose == true then windower.add_to_chat(8, 'valid_pet() : true : Using pet.index') end
        mypet_idx = pet.index
        return mypet_idx
    elseif player.mob and player.mob.pet_index then
        if superverbose == true then windower.add_to_chat(8, 'valid_pet() : true : Using player.mob.pet_index') end
        mypet_idx = player.mob.pet_index    
        return mypet_idx
    end
    if superverbose == true then windower.add_to_chat(8, 'valid_pet() : false : No pet found') end
    return
end
function update_pet(source,pet_idx_in,own_idx_in)
    pet_idx = valid_pet(source,pet_idx_in,own_idx_in)

    if pet_idx == nil then
        if superverbose == true then windower.add_to_chat(8, 'update_pet() : false : pet_idx == nil, pet_idx_in: '..(pet_idx_in or 'nil')..', own_idx_in: '..(own_idx_in or 'nil')) end
        return false
    end

    local pet_table = windower.ffxi.get_mob_by_index(pet_idx)
    if pet_table == nil then
        if petactive then -- presumably we have a pet, he just hasn't loaded, yet...
            if superverbose == true then windower.add_to_chat(8, 'update_pet() : true : pet_table == nil, pet_idx: '..(pet_idx or 'nil')..', '..(own_idx_in or 'nil')) end
            return true
        end
        if superverbose == true then windower.add_to_chat(8, 'update_pet() : false: pet_table == nil, pet_idx: '..(pet_idx or 'nil')..', '..(own_idx_in or 'nil')) end
        make_invisible()
        return false
    end

    petname = pet_table['name']
    if superverbose == true then windower.add_to_chat(8, 'update_pet() : Updating PetName: '..petname) end
    current_hp_percent = pet_table['hpp']
    if not petactive and current_hp_percent == 0 then  -- we're likely picking up a dead or despawning pet
        if superverbose == true then windower.add_to_chat(8, 'update_pet() : Picked up a likely dead pet') end
        make_invisible()
        return false
    end
    if superverbose == true then windower.add_to_chat(8, 'update_pet() : true : Picked up a pet: '..petname..', hp%: '..current_hp_percent..', pet_idx: '..pet_idx) end
    return true
end

function printpettp(pet_idx_in,own_idx_in)
    if not petactive then
        return
    end
    if petname == nil then
        if update_pet('printpettp',pet_idx_in,own_idx_in) == false then
            return
        end
    end

    local output

    output = (petname or 'Unknown')..': '
    if settings.autocolor == true then
        if current_hp_percent > 75 then
            output = output..'\\cr\\cs(128,255,128)'        
        elseif current_hp_percent > 50 then
            output = output..'\\cr\\cs(255,255,0)'
        elseif current_hp_percent > 25 then
            output = output..'\\cr\\cs(255,160,0)'
        else
            output = output..'\\cr\\cs(255,0,0)'
        end
    end
    if max_hp > 0 then
        output = output..current_hp..'/'..max_hp..' '..'('..current_hp_percent..'%)'
    else
        output = output..current_hp_percent..'%'
    end
    if settings.autocolor == true then output = output..'\\cr\\cs('..settings.text.red..','..settings.text.green..','..settings.text.blue..')' end    
    output = output..' ['
    if settings.autocolor == true and current_tp_percent >= 1000 then output = output..'\\cr\\cs(128,255,128)' end
    output = output..current_tp_percent
    if settings.autocolor == true and current_tp_percent >= 1000 then output = output..'\\cr\\cs('..settings.text.red..','..settings.text.green..','..settings.text.blue..')' end    
    output = output..']'
    if max_mp > 0 then
        if current_mp_percent > 75 then
            output = output..'\\cr\\cs(128,255,128)'        
        elseif current_mp_percent > 50 then
            output = output..'\\cr\\cs(255,255,0)'
        elseif current_mp_percent > 25 then
            output = output..'\\cr\\cs(255,160,0)'
        else
            output = output..'\\cr\\cs(255,0,0)'
        end
        output = output..' '..current_mp..'/'..max_mp..' ('..current_mp_percent..'%)'
        if settings.autocolor == true then output = output..'\\cr\\cs('..settings.text.red..','..settings.text.green..','..settings.text.blue..')' end    
    end
    output = output..'\\cr'

    pettp:text(output)
end

windower.register_event('time change', function()
    if timercountdown == 0 then
        return
    elseif petactive then
        if superverbose == true then windower.add_to_chat(8, 'SCAN: Pet appeared between scans!') end
        timercountdown = 0
    else
        timercountdown = timercountdown - 1
        if update_pet('scan') == true then
            if superverbose == true then windower.add_to_chat(8, 'SCAN: Found a pet!') end
            timercountdown = 0
            make_visible()
            printpettp()
        elseif timercountdown == 0 then
            if superverbose == true then windower.add_to_chat(8, 'SCAN: No pet found in 5 ticks') end
        end
    end
end)

windower.register_event('incoming chunk',function(id,original,modified,injected,blocked)
    if not injected then
        if id == 0x44 then
            if original:unpack('C', 0x05) == 0x12 then    -- puppet update
                local new_current_hp, new_max_hp, new_current_mp, new_max_mp = original:unpack('HHHH', 0x069)

                if (not petactive) or (petname == nil) or (petname == "") or (new_current_hp ~= current_hp) or (new_max_hp ~= max_hp) or (new_current_mp ~= current_mp) or (new_max_mp ~= max_mp) then
                    if superverbose == true then                
                        windower.add_to_chat(8, '0x44'
                            ..', cur_hp: '..new_current_hp
                            ..', max_hp: '..new_max_hp
                            ..', cur_mp: '..new_current_mp
                            ..', max_mp: '..new_max_mp
                            ..', name: '.. original:unpack('z', 0x59)
                        )
                    end

                    if petactive then
                        local new_petname = original:unpack('z', 0x59)
                        if petname == nil or petname == "" then
                            if superverbose == true then windower.add_to_chat(8, 'Updating PuppetName: '..new_petname) end
                            petname = new_petname
                        end
                        if petname == new_petname then -- make sure we only update if we actually have a puppet out
                            current_hp = new_current_hp
                            max_hp     = new_max_hp
                            current_mp = new_current_mp
                            max_mp     = new_max_mp
                            if max_hp ~= 0 then
                                current_hp_percent=math.floor(100*current_hp/max_hp)
                            else
                                current_hp_percent=0
                            end
                            if max_mp ~= 0 then
                                current_mp_percent=math.floor(100*current_mp/max_mp)
                            else
                                current_mp_percent=0
                            end
                            printpettp()
                        else
                            if superverbose == true then windower.add_to_chat(8, '0x44, pet is not a puppet') end
                        end
                    else
                        if superverbose == true then windower.add_to_chat(8, '0x44, puppet not active') end
                    end
                end
            end
        elseif id == 0x67 or id == 0x068 then    -- general hp/tp/mp update
            local packet = packets.parse('incoming', original)
            local msg_type = packet['Message Type']
            local msg_len = packet['Message Length']
            pet_idx = packet['Pet Index']
            own_idx = packet['Owner Index']

            if (msg_type == 0x04) and id == 0x067 then
                pet_idx, own_idx = own_idx, pet_idx
            end

            if superverbose == true and id == 0x067 and not ( 
                   (msg_type == 0x02) -- not pet related
                or (msg_type == 0x03 and (own_idx == 0)) -- NPC pops
                or (msg_type == 0x03 and (own_idx ~= windower.ffxi.get_player().index)) -- other people summoning
            ) then
                windower.add_to_chat(8, '0x67'
                       ..', msg_type: '..string.format('0x%02x', msg_type)
                       ..', msg_len: '..msg_len
                       ..', pet_idx: '..pet_idx
                       ..', pet_id: '..(original:byte(0x09)+original:byte(0x0A)*256)
                       ..', own_idx: '..own_idx
                       ..', hp%: '..original:byte(0x0F)
                       ..', mp%: '..original:byte(0x10)
                       ..', tp%: '..(original:byte(0x11)+original:byte(0x12)*256)
                       ..', name: '.. ((msg_len > 24) and original:unpack('z', 0x19) or "")
                    )
            end
            if (msg_type == 0x04) then
                if (pet_idx == 0) then
                    if verbose == true then windower.add_to_chat(8, 'Pet died/despawned') end
                    make_invisible()
                else
                    local newpet = false
                    if not petactive then
                        petactive = true  -- force our pet to appear even if it's not attached to us yet
                        if update_pet('0x67-0x*4',pet_idx,own_idx) == true then
                            make_visible()
                            newpet = true
                        else
                            if superverbose == true then windower.add_to_chat(8, 'Pet not found') end
                            make_invisible()
                        end
                    end
                    local new_hp_percent = packet['Current HP%']
                    local new_mp_percent = packet['Current MP%']
                    local new_tp_percent = packet['Pet TP']
                    if newpet or (new_hp_percent ~= current_hp_percent) or (new_mp_percent ~= current_mp_percent) or (new_tp_percent ~= current_tp_percent) or (petname == nil) or (petname == "") then
                        if (max_hp ~= 0) and (new_hp_percent ~= current_hp_percent) then
                            current_hp = math.floor(new_hp_percent * max_hp / 100)
                        end
                        if (max_mp ~= 0) and (new_mp_percent ~= current_mp_percent) then
                            current_mp = math.floor(new_mp_percent * max_mp / 100)
                        end
                        if ((petname == nil) or (petname == "")) then
                            petname = packet['Pet Name']
                            if superverbose == true then windower.add_to_chat(8, 'Updated PetName: '..petname) end
                        end
                        current_hp_percent = new_hp_percent
                        current_mp_percent = new_mp_percent
                        current_tp_percent = new_tp_percent
                        printpettp(pet_idx,own_idx)
                    end
                end
            elseif not petactive and (msg_type == 0x03) and (own_idx == windower.ffxi.get_player().index) then
                if update_pet('0x67-0x03',pet_idx,own_idx) == true then
                    make_visible()
                    printpettp(pet_idx,own_idx_in)
                else    -- last resort
                    timercountdown = 5
                    if superverbose == true then windower.add_to_chat(8, 'Starting to scan for a pet...') end
                end
            end
        elseif id==0x0E and S{0x07,0x0F}:contains(original:byte(0x0B)) then    -- npc update
            if mypet_idx == original:unpack('H', 0x09) then
                if current_hp_percent ~= original:byte(0x1F) then
                    if superverbose == true then windower.add_to_chat(8, '0x0E - '..original:byte(0x0B)..': '..original:byte(0x1F)) end
                    current_hp_percent = original:byte(0x1F)
                    if max_hp ~= 0 then
                        current_hp = math.floor(current_hp_percent * max_hp / 100)
                    end
                    printpettp(mypet_idx)
                end
            end
        elseif id==0x0E and not S{0x00,0x01,0x08,0x09,0x20}:contains(original:byte(0x0B)) and mypet_idx == (original:byte(0x09)+original:byte(0x0A)*256) then
            if superverbose == true then windower.add_to_chat(8, '0x0E ~ '..original:byte(0x0B)..': '..original:byte(0x1F)) end
        end
    end
end)

windower.register_event('load', function()
    if superverbose == true then
        windower.add_to_chat(8, 'Player index: '..windower.ffxi.get_player().index)
        if windower.ffxi.get_mob_by_target('pet') then
            windower.add_to_chat(8, 'Pet index: '..windower.ffxi.get_mob_by_target('pet').index)
        end
    end
    if windower.ffxi.get_player() then
        if update_pet('load') == true then
            make_visible()
            printpettp()
        end
    end
end)

windower.register_event('zone change', function()
    mypet_idx = nil
    if update_pet('zone') == true then
        if verbose == true then windower.add_to_chat(8, 'Found pet after zoning...') end
        make_visible()
        printpettp()
    elseif petactive then
        make_invisible()
        if verbose == true then windower.add_to_chat(8, 'Lost pet after zoning...') end
    end
end)

windower.register_event('job change', function()
    make_invisible()
end)

windower.register_event('addon command', function(...)
    local splitarr = {...}

    for i,v in pairs(splitarr) do
        if v:lower() == 'save' then
            config.save(settings, 'all')
        elseif v:lower() == 'verbose' then
            verbose = not verbose
            windower.add_to_chat(121,'PetTP: Verbose Mode flipped! - '..tostring(verbose))
        elseif v:lower() == 'superverbose' then
            superverbose = not superverbose
            windower.add_to_chat(121,'PetTP: SuperVerbose Mode flipped! - '..tostring(superverbose))
        elseif v:lower() == 'help' then
            print('   :::   '.._addon.name..' ('.._addon.version..')   :::')
            print('Utilities:')
            print(' 1. verbose --- Some light logging, Default = false')
            print(' 2. help    --- shows this menu')
        end
    end
end)

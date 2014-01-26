local config = require ('config')

_addon.name = 'PetTP'
_addon.author = 'SnickySnacks'
_addon.version = '1.0'
_addon.commands = {'ptp','pettp'}

petname = nil
mypet_idx = nil
current_hp = 0
max_hp = 0
current_mp = 0
max_mp = 0
current_hp_percent = 0
current_mp_percent = 0
current_tp_percent = 0
tb_name = 'addon:pettp'
petactive = false
verbose = false
superverbose = false
timercountdown = 0

defaults = T{}

defaults.autocolor = true
defaults.bgvisible = true

defaults.position = T{}
--defaults.position.x = 1250
--defaults.position.y = 890
defaults.position.x = windower.get_windower_settings().x_res*2/3
defaults.position.y = windower.get_windower_settings().y_res-17

defaults.font = T{}
defaults.font.family = 'Courier New'
defaults.font.size   = 10
defaults.font.a      = 255
defaults.font.bold   = false
defaults.font.italic = false

defaults.colors = T{}
defaults.colors.background = T{}
defaults.colors.background.r = 0
defaults.colors.background.g = 0
defaults.colors.background.b = 0
defaults.colors.background.a = 255

defaults.colors.text = T{}
defaults.colors.text.r = 255
defaults.colors.text.g = 255
defaults.colors.text.b = 255

settings = config.load(defaults)

function make_visible()
    petactive = true
    windower.text.set_visibility(tb_name, true)
    if verbose == true then windower.add_to_chat(8, 'PetTP Visible') end
end

function make_invisible()
    if petactive then
        windower.text.set_text(tb_name, '')
        windower.text.set_visibility(tb_name, false)
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

function valid_pet(pet_idx_in, own_idx_in)
    local player = windower.ffxi.get_player()

    if petactive then 
        if mypet_idx then
            if not pet_idx_in or mypet_idx == pet_idx_in then
                return mypet_idx
            else
                if superverbose == true then 
                    windower.add_to_chat(8, 'valid_pet(): '..tostring(petactive)..', pet_idx_in: '..(pet_idx_in or 'nil')..', own_idx_in: '..(own_idx_in or 'nil')..', player.index '..player.index)
                    windower.add_to_chat(8, 'mypet_idx ~= pet_idx_in '..mypet_idx..' vs. '..pet_idx_in) 
                end
            end
        elseif own_idx_in and player.index == own_idx_in then
            mypet_idx = pet_idx_in
            return mypet_idx
        end
    end
    
    local pet = windower.ffxi.get_mob_by_target('pet')    
    if pet_idx_in and pet and pet_idx_in ~= pet.index then
        if superverbose == true then 
            windower.add_to_chat(8, 'valid_pet(): '..tostring(petactive)..', pet_idx_in: '..(pet_idx_in or 'nil')..', own_idx_in: '..(own_idx_in or 'nil')..', player.index '..player.index)
            windower.add_to_chat(8, 'pet.index ~= pet_idx_in '..pet.index..' vs. '..pet_idx_in) 
        end
        return
    elseif pet_idx_in and player.mob and player.mob.pet_index and pet_idx_in ~= player.mob.pet_index then
        if superverbose == true then 
            windower.add_to_chat(8, 'valid_pet(): '..tostring(petactive)..', pet_idx_in: '..(pet_idx_in or 'nil')..', own_idx_in: '..(own_idx_in or 'nil')..', player.index '..player.index)
            windower.add_to_chat(8, 'player.mob.pet_index ~= pet_idx_in '..player.mob.pet_index..' vs. '..pet_idx_in) 
        end
        return
    elseif pet then
        mypet_idx = pet.index
        return mypet_idx
    elseif player.mob and player.mob.pet_index then
        mypet_idx = player.mob.pet_index    
        return mypet_idx
    end
    if superverbose == true then 
        windower.add_to_chat(8, 'valid_pet(): '..tostring(petactive)..', pet_idx_in: '..(pet_idx_in or 'nil')..', own_idx_in: '..(own_idx_in or 'nil')..', player.index '..player.index)
        windower.add_to_chat(8, 'pet invalid') 
        if pet then
            windower.add_to_chat(8, 'pet.index = '..pet.index)
        end
        if player.mob then
            windower.add_to_chat(8, 'player.mob.pet_index = '..player.mob.pet_index)
        end
    end
    return
end
function update_pet(pet_idx_in,own_idx_in)
    pet_idx = valid_pet(pet_idx_in,own_idx_in)

    if pet_idx == nil then
        if superverbose == true then windower.add_to_chat(8, 'pet_idx == nil, pidx: '..(pet_idx_in or 'nil')..', '..(own_idx_in or 'nil')) end
        return false
    end

    local pet_table = windower.ffxi.get_mob_by_index(pet_idx)
    if pet_table == nil then
        if superverbose == true then windower.add_to_chat(8, 'pet_table == nil, pidx: '..(pet_idx or 'nil')..', '..(own_idx_in or 'nil')) end
        if petactive then -- presumably we have a pet, he just hasn't loaded, yet...
            return true
        end
        make_invisible()
        return false
    end

    petname = pet_table['name']
    if superverbose == true then windower.add_to_chat(8, 'Updating PetName: '..petname) end
    current_hp_percent = pet_table['hpp']
    if not pet_table['mpp'] == nil then
        current_mp_percent = pet_table['mpp']
    end
    current_tp_percent = pet_table['tp']/10
    if not petactive and current_hp_percent == 0 then  -- we're likely picking up a dead or despawning pet
        if superverbose == true then windower.add_to_chat(8, 'Picked up a likely dead pet') end
        make_invisible()
        return false
    end
    if superverbose == true then windower.add_to_chat(8, 'Picked up a pet: '..petname..', hp%: '..current_hp_percent) end
    return true
end

function printpettp(pet_idx_in,own_idx_in)
    if not petactive then
        return
    end
    if petname == nil then
        if update_pet(pet_idx_in,own_idx_in) == false then
            return
        end
    elseif valid_pet(pet_idx_in,own_idx_in) == nil then
        return
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
    if settings.autocolor == true then output = output..'\\cr\\cs('..settings.colors.text.r..','..settings.colors.text.g..','..settings.colors.text.b..')' end    
    output = output..' ['
    if settings.autocolor == true and current_tp_percent >= 100 then output = output..'\\cr\\cs(128,255,128)' end
    output = output..string.format('%.1f',current_tp_percent)..'%'
    if settings.autocolor == true and current_tp_percent >= 100 then output = output..'\\cr\\cs('..settings.colors.text.r..','..settings.colors.text.g..','..settings.colors.text.b..')' end    
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
        output = output..' '..current_mp..'/'..max_mp..' ('..current_mp_percent..')'
        if settings.autocolor == true then output = output..'\\cr\\cs('..settings.colors.text.r..','..settings.colors.text.g..','..settings.colors.text.b..')' end    
    end
    output = output..'\\cr'

    windower.text.set_text(tb_name, output)
end

windower.register_event('time change', function()
    if timercountdown == 0 then
        return
    elseif petactive then
        if superverbose == true then windower.add_to_chat(8, 'SCAN: Pet appeared between scans!') end
        timercountdown = 0
    else
        timercountdown = timercountdown - 1
        if update_pet() == true then
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
            if original:byte(0x05) == 0x12 then    -- puppet update
                if not petactive then
                    if update_pet() == true then
                        make_visible()
                    end
                end
                if petactive then
                    local newpetname    = original:sub(0x59,original:find(string.char(0),0x59)-1)
                    if petname == nil then
                        if superverbose == true then windower.add_to_chat(8, 'Updating PuppetName: '..newpetname) end
                        petname = newpetname
                    end
                    if petname == newpetname then -- make sure we only update if we actually have a puppet out
                        current_hp = original:byte(0x69)+(original:byte(0x6A)*256)
                        max_hp       = original:byte(0x6B)+(original:byte(0x6C)*256)
                        current_mp = original:byte(0x6D)+(original:byte(0x6E)*256)
                        max_mp       = original:byte(0x6F)+(original:byte(0x70)*256)
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
                        if superverbose == true then
                            windower.add_to_chat(8, '0x44'
                                ..', len: '..original:length()
                                ..', petname: '..petname
                                ..', cur_hp: '..current_hp
                                ..', max_hp: '..max_hp
                                ..', cur_mp: '..current_mp
                                ..', max_mp: '..max_mp
                                ..', cur_hp_%: '..current_hp_percent
                                ..', cur_mp_%: '..current_mp_percent
                            )
                        end
                    else
                        if superverbose == true then windower.add_to_chat(8, '0x44, pet is not a puppet') end
                    end
                else
                    if superverbose == true then windower.add_to_chat(8, '0x44, puppet not active') end
                end
            end
        elseif id == 0x67 then    -- general hp/tp/mp update
            if S{0x04,0x44,0xC4,0x84}:contains(original:byte(0x05)) then
                own_idx = (original:byte(0x07)+original:byte(0x08)*256)
                pet_idx = (original:byte(0x0D)+original:byte(0x0E)*256)
            else
                pet_idx = (original:byte(0x07)+original:byte(0x08)*256)
                own_idx = (original:byte(0x0D)+original:byte(0x0E)*256)
            end

            if superverbose == true and not ( 
                   (original:byte(0x05) == 0x02 and original:byte(0x06) == 0x09) -- not pet related
                --or (original:byte(0x05) == 0x84 and original:byte(0x06) == 0x07) -- pet % update
                or (original:byte(0x05) == 0x03 and original:byte(0x06) == 0x05 and (own_idx == 0)) -- NPC pops
                or (original:byte(0x05) == 0x03 and original:byte(0x06) == 0x05 and (own_idx ~= windower.ffxi.get_player().index)) -- other people summoning
            ) then
                windower.add_to_chat(8, '0x67'
                       ..', len: '..original:length()
                       ..', mask_1: '..string.format('0x%02x',original:byte(0x05))
                       ..', mask_2: '..original:byte(0x06)
                       ..', pet_idx: '..pet_idx
                       ..', pet_id: '..(original:byte(0x09)+original:byte(0x0A)*256)
                       ..', flag_1: '..original:byte(0x0B)
                       ..', flag_2: '..original:byte(0x0C)
                       ..', own_idx: '..own_idx
                       ..', hp%: '..original:byte(0x0F)
                       ..', mp%: '..original:byte(0x10)
                       ..', tp%: '..(original:byte(0x11)+original:byte(0x12)*256)/10
                       ..', name: '..original:sub(0x15,original:find(string.char(0),0x15)-1)
                    )
            end
            if (original:byte(0x05) == 0x04) and (original:byte(0x06) == 0x05) then
                make_invisible()
                if verbose == true then windower.add_to_chat(8, 'Pet died/despawned') end
            elseif S{0x04,0x44,0xC4,0x84}:contains(original:byte(0x05)) then
                local newpet = false
                if not petactive then
                    petactive = true  -- force our pet to appear even if it's not attached to us yet
                    if update_pet(pet_idx,own_idx) == true then
                        make_visible()
                        newpet = true
                    else
                        make_invisible()
                        if superverbose == true then windower.add_to_chat(8, 'pet not found') end
                    end
                end
                local new_hp_percent = original:byte(0x0F)
                local new_mp_percent = original:byte(0x10)
                local new_tp_percent = (original:byte(0x11)+(original:byte(0x12)*256))/10
                if newpet or (new_hp_percent ~= current_hp_percent) or (new_mp_percent ~= current_mp_percent) or (new_tp_percent ~= current_tp_percent) or petname == nil then
                    if (max_hp ~= 0) and (new_hp_percent ~= current_hp_percent) then
                        current_hp = math.floor(current_hp_percent * max_hp / 100)
                    end
                    if (max_mp ~= 0) and (new_mp_percent ~= current_mp_percent) then
                        current_mp = math.floor(current_mp_percent * max_mp / 100)
                    end
                    if petname == nil then
                        petname = original:sub(0x15,original:find(string.char(0),0x15)-1)
                        if superverbose == true then windower.add_to_chat(8, 'Updated PetName: '..petname) end
                    end
                    current_hp_percent = new_hp_percent
                    current_mp_percent = new_mp_percent
                    current_tp_percent = new_tp_percent
                    printpettp(pet_idx,own_idx)
                end
            elseif not petactive and (original:byte(0x05) == 0x03) and (original:byte(0x06) == 0x05) and (own_idx == windower.ffxi.get_player().index) then
                if update_pet(pet_idx,own_idx) == true then
                    make_visible()
                    printpettp(pet_idx,own_idx_in)
                else    -- last resort
                    timercountdown = 5
                    if superverbose == true then windower.add_to_chat(8, 'Starting to scan for a pet...') end
                end
            end
        elseif id==0x0E and original:byte(0x0B) == 0x07 then    -- npc update
            if mypet_idx == (original:byte(0x09)+original:byte(0x0A)*256) then
                if current_hp_percent ~= original:byte(0x1F) then
                    if superverbose == true then windower.add_to_chat(8, '0x0E - '..original:byte(0x0B)..': '..original:byte(0x1F)) end
                    current_hp_percent = original:byte(0x1F)
                    if max_hp ~= 0 then
                        current_hp = math.floor(current_hp_percent * max_hp / 100)
                    end
                    printpettp(mypet_idx)
                end
            end
        elseif id==0x0E and not S{0x00,0x01,0x08,0x09}:contains(original:byte(0x0B)) and mypet_idx == (original:byte(0x09)+original:byte(0x0A)*256) then
            if superverbose == true then windower.add_to_chat(8, '0x0E ~ '..original:byte(0x0B)..': '..original:byte(0x1F)) end
        end
    end
end)

windower.register_event('load', function()
    local background = settings.colors.background
    windower.text.create(tb_name)
    windower.text.set_location(tb_name, settings.position.x, settings.position.y)
    windower.text.set_bg_color(tb_name, background.a, background.r, background.g, background.b)
    windower.text.set_color(tb_name, settings.font.a, defaults.colors.text.r, defaults.colors.text.g, defaults.colors.text.b)
    windower.text.set_font(tb_name, settings.font.family)
    windower.text.set_font_size(tb_name, settings.font.size)
    windower.text.set_bold(tb_name, settings.font.bold)
    windower.text.set_italic(tb_name, settings.font.italic)
    windower.text.set_text(tb_name, '')
    windower.text.set_bg_visibility(tb_name, defaults.bgvisible)
    if superverbose == true then
        windower.add_to_chat(8, 'Player index: '..windower.ffxi.get_player().index)
        if windower.ffxi.get_mob_by_target('pet') then
            windower.add_to_chat(8, 'Pet index: '..windower.ffxi.get_mob_by_target('pet').index)
        end
    end
    if update_pet() == true then
        make_visible()
        printpettp()
    end
end)

windower.register_event('Zone change', function()
    mypet_idx = nil
    if update_pet() == true then
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

windower.register_event('unload', function()
    windower.text.delete(tb_name)
end)

windower.register_event('addon command',function (...)
    local splitarr = {...}

    for i,v in pairs(splitarr) do
        if v:lower() == 'verbose' then
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

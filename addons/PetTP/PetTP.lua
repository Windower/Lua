
local config = require 'config'

_addon = _addon or {}
_addon.name = 'PetTP'
_addon.author = 'SnickySnacks'
_addon.version = '1.0'
_addon.commands = {'pettp'}

local petname = 'Unknown'
local mypet_idx = nil
local current_hp = 0
local max_hp = 0
local current_mp = 0
local max_mp = 0
local current_hp_percent = 0
local current_mp_percent = 0
local current_tp_percent = 0
local tb_name = 'addon:pettp'
local charm = false

local defaults = T{}

defaults.autocolor = true
defaults.bgvisible = true

defaults.position = T{}
defaults.position.x = 1250
defaults.position.y = 890

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

function valid_pet(msg_id,pet_idx_in, own_idx_in)
	local player = windower.ffxi.get_player()
	local pet    = windower.ffxi.get_mob_by_target('pet')

	if charm and own_idx_in and player.index == own_idx_in then
		mypet_idx = pet_idx_in
		return mypet_idx
	end
	if pet_idx_in and pet and pet_idx_in ~= pet.index then
		return
	elseif pet_idx_in and player.mob and player.mob.pet_index and pet_idx_in ~= pet.index then
		return
	elseif pet then
		mypet_idx = pet.index
		return mypet_idx
	elseif player.mob and player.mob.pet_index then
		mypet_idx = player.mob.pet_index	
		return mypet_idx
	end
	return
end
function update_pet(msg_id,pet_idx_in, own_idx_in)
	pet_idx = valid_pet(msg_id,pet_idx_in,own_idx_in)

	if pet_idx == nil then
--		windower.add_to_chat(8, 'pet_idx == nil')
		return false
	end

	local pet_table = windower.ffxi.get_mob_by_index(pet_idx)
	if pet_table == nil then
		windower.text.set_visibility(tb_name, false)
		charm = false
		windower.add_to_chat(8, 'PetTP Invisible')
		return false
	end

	petname = pet_table['name']
	current_hp_percent = pet_table['hpp']
	if not pet_table['mpp'] == nil then
		current_mp_percent = pet_table['mpp']
	end
	current_tp_percent = pet_table['tp']/10
--	windower.add_to_chat(8,pet_idx..': '..petname)
	printpettp(msg_id,pet_idx,own_idx_in)
	return true
end

function printpettp(msg_id,pet_idx_in,own_idx_in)
	if valid_pet(msg_id,pet_idx_in,own_idx_in) == nil then
--		windower.add_to_chat(8, 'Invalid pet')
		return
	end

	if msg_id == '0x44' then
		current_hp_percent=math.floor(100*current_hp/max_hp)
		current_mp_percent=math.floor(100*current_mp/max_mp)
	end
	local output

	output = petname..': '
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

windower.register_event('incoming chunk',function(id,original,modified,injected,blocked)
	if not injected then
		if id == 0x44 then
			if original:byte(0x05) == 0x12 then	-- puppet update
--				petname    = original:sub(0x59,original:find(string.char(0),0x59)-1)
				current_hp = original:byte(0x69)+(original:byte(0x6A)*256)
				max_hp	   = original:byte(0x6B)+(original:byte(0x6C)*256)
				current_mp = original:byte(0x6D)+(original:byte(0x6E)*256)
				max_mp	   = original:byte(0x6F)+(original:byte(0x70)*256)
--				windower.add_to_chat(8, petname..': '..current_hp..'/'..max_hp)
				printpettp('0x44')
--			else --if not T{0x02,0x03,0x0F}:contains(original:byte(0x05)) then
--				windower.add_to_chat(8, '0x44 - '..original:byte(5)..' - len: '..original:length())
			end
		elseif id == 0x67 then	-- general hp/tp/mp update
			if false and not ( 
				   (original:byte(0x05) == 0x02 and original:byte(0x06) == 0x09) -- not pet related
				--or (original:byte(0x05) == 0x84 and original:byte(0x06) == 0x07) -- pet % update
				or (original:byte(0x05) == 0x03 and original:byte(0x06) == 0x05 and (((original:byte(0x0D)+original:byte(0x0E)*256) == 0))) -- NPC pops
				or (original:byte(0x05) == 0x03 and original:byte(0x06) == 0x05 and (((original:byte(0x0D)+original:byte(0x0E)*256) ~= windower.ffxi.get_player().index))) -- other people summoning
			) then
				if original:byte(0x06) == 0x08 then
					windower.add_to_chat(8, '0x67'
						   ..', len: '..original:length()
						   ..', mask_1: '..string.format('0x%02x',original:byte(0x05))
						   ..', mask_2: '..original:byte(0x06)
						   ..', pet_idx: '..(original:byte(0x0D)+original:byte(0x0E)*256)
						   ..', pet_id: '..(original:byte(0x09)+original:byte(0x0A)*256)
						   ..', ???1: '..original:byte(0x0B)
						   ..', ???2: '..original:byte(0x0C)
						   ..', own_idx: '..(original:byte(0x07)+original:byte(0x08)*256)
						   ..', hp%: '..original:byte(0x0F)
						   ..', mp%: '..original:byte(0x10)
						   ..', tp%: '..(original:byte(0x11)+original:byte(0x12)*256)
						   ..', unk1: '..original:byte(0x13)
						   ..', unk2: '..original:byte(0x14)
						   ..', name: '..original:sub(0x15,original:find(string.char(0),0x15)-1)
						)
				else
					windower.add_to_chat(8, '0x67'
						   ..', len: '..original:length()
						   ..', mask_1: '..string.format('0x%02x',original:byte(0x05))
						   ..', mask_2: '..original:byte(0x06)
						   ..', pet_idx: '..(original:byte(0x07)+original:byte(0x08)*256)
						   ..', pet_id: '..(original:byte(0x09)+original:byte(0x0A)*256)
						   ..', ???1: '..original:byte(0x0B)
						   ..', ???2: '..original:byte(0x0C)
						   ..', own_idx: '..(original:byte(0x0D)+original:byte(0x0E)*256)
						   ..', hp%: '..original:byte(0x0F)
						   ..', mp%: '..original:byte(0x10)
						   ..', tp%: '..(original:byte(0x11)+original:byte(0x12)*256)
						   ..', unk1: '..original:byte(0x13)
						   ..', unk2: '..original:byte(0x14)
						   ..', name: '..original:sub(0x15,original:find(string.char(0),0x15)-1)
						)
				end
			end
		        if (original:byte(0x05) == 0x04 and original:byte(0x06) == 0x07)
			   or T{0x44,0xC4,0x84}:contains(original:byte(0x05)) then
				current_hp_percent = original:byte(0x0F)
				current_mp_percent = original:byte(0x10)
				current_tp_percent = (original:byte(0x11)+(original:byte(0x12)*256))/10
--				petname = original:sub(0x15,original:find(string.char(0),0x15)-1)
				if original:byte(0x06) == 0x08 then
					own_idx = (original:byte(0x07)+original:byte(0x08)*256)
					pet_idx = (original:byte(0x0D)+original:byte(0x0E)*256)
					if not charm then
						charm = true
						if update_pet(original:byte(0x05),pet_idx,own_idx) == true then
							windower.text.set_visibility(tb_name, true)
							windower.add_to_chat(8, 'PetTP Visible')
						else
							charm = false
						end
					end
				else
					pet_idx = (original:byte(0x07)+original:byte(0x08)*256)
					own_idx = (original:byte(0x0D)+original:byte(0x0E)*256)
					if pet_idx == mypet_idx then
						charm = false
					end
				end
				printpettp('0x67',pet_idx,own_idx)
			elseif (original:byte(0x05) == 0x03) and (original:byte(0x06) == 0x05) and ((original:byte(0x0D)+original:byte(0x0E)*256) ~= 0) then
				if update_pet(original:byte(0x05),original:byte(0x07)+original:byte(0x08)*256) == true then
					current_hp = 0
					max_hp	   = 0
					current_mp = 0
					max_mp	   = 0
					windower.text.set_visibility(tb_name, true)
					windower.add_to_chat(8, 'PetTP Visible')
				end
			elseif (original:byte(0x05) == 0x04) and (original:byte(0x06) == 0x05) then
				windower.text.set_visibility(tb_name, false)
				windower.add_to_chat(8, 'PetTP Invisible')
				charm = false
			end
		elseif id==0x0E and original:byte(0x0B) == 0x07 then	-- npc update
			if mypet_idx == (original:byte(0x09)+original:byte(0x0A)*256) then
				if current_hp_percent ~= original:byte(0x1F) then
					current_hp_percent = original:byte(0x1F)
					printpettp('0x0E',mypet_idx)
				end
			end
		else
			--windower.add_to_chat(8, id)
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
--	windower.add_to_chat(8, 'Player index: '..windower.ffxi.get_player().index)
--	if windower.ffxi.get_mob_by_target('pet') then
--		windower.add_to_chat(8, 'Pet Id: '..windower.ffxi.get_mob_by_target('pet').id)
--	end
    update_pet()
end)

windower.register_event('Zone change', function()
	update_pet()
end)

windower.register_event('job change', function()
	windower.text.set_visibility(tb_name, false)
	windower.add_to_chat(8, 'PetTP Invisible')
	charm = false
end)

windower.register_event('unload', function()
    windower.text.delete(tb_name)
end)

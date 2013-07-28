-- Target Processing --

function valid_target(targ)
	if not spelltarget then spelltarget = {} end
	
	local spell_targ
	if pass_through_targs:contains(targ) then
		local j = get_mob_by_target(targ)
		
		if j == nil then
			table.reassign(spelltarget,target)
		else
			table.reassign(spelltarget,target_type(j))
		end
		spelltarget.raw = targ

		return targ
	elseif targ then
		local mob_array = get_mob_array()
		for i,v in pairs(mob_array) do
			if v['name']==targ and not v['is_npc'] then
				spell_targ = targ
				table.reassign(spelltarget,target_type(v))
				spelltarget.raw = targ
			elseif tonumber(targ) == v['id'] then
				spell_targ = '<lastst>'
				table.reassign(spelltarget,target_type(v))
				spelltarget.raw = '<lastst>'
			end
		end
	end
	return spell_targ
end

function target_type(mob_table)
	if mob_table == nil then return end
	
	
	------------------------------- Should consider moving the partycount part of this code to refresh_player() ----------------------------------
	mob_table.isallymember = false
	if not mob_table.id then
		mob_table.type = 'NONE'
	else
		local j = get_party()
		
		for i,v in pairs(j) do
			if v['mob'] then
				if v['mob']['id'] == mob_table['id'] then
					mob_table.isallymember = true
				end
			end
		end
	------------------------------------------------------------------------------------------------------------------------------------
		
		if player['id'] == mob_table['id'] then
			mob_table.type = 'SELF'
		elseif mob_table['is_npc'] then
			if mob_table['id']%4096>2047 then
				mob_table.type = 'NPC'
			else
				mob_table.type = 'MONSTER'
			end
		else
			mob_table.type = 'PLAYER'
		end
	end
	return mob_table
end
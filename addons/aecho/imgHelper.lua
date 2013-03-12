require 'tablehelper'
imgTable = T{}
function createImage(name,posx,posy,dimx,dimy)
	posX = #imgTable * 24
	prim_delete(name)
	if checkExists(name) then
		return
	else
		if #imgTable == 0 then
			tCell = T{name,posX,0} --name,xpos,ypos
			imgTable[1] = tCell
		else
			tCell = T{name,posX,0}	--name,xpos,ypos
			imgTable[#imgTable+1] = tCell --add cell to table
		end
		prim_set_color(name,187,0,255,0)
		add_to_chat(55,'Color: Green Alpha:187')
		prim_set_fit_to_texture(name,false)
		prim_set_size(name,24,24)
		prim_set_texture(name,'icons\\'..name:lower()..'.png')
		add_to_chat(55,lua_base_path..'icons\\'..name:lower()..'.png')
		--assumes your icons are stored with the name you pass in windower/addons/<youraddon>/icons
		prim_set_repeat(name,1,1)
		prim_set_visibility(name,true)
		if posx == nil then
			prim_set_position(name,posX,0)
		else
			prim_set_position(name,posx,posy)
		end	
	end

end

function deleteImage(name)
	for u = 1, #imgTable do
		if imgTable[u][1] ~= nil then
			if imgTable[u][1] == name then
				table.remove(imgTable,u)
				prim_delete(name)
				return
			end
		end
	end
end

function moveImage(name,oldx,oldy,newx,newy)
	if oldx == nil then
		if newx ~= nil then
			prim_set_position(name,newx,newy)
		end
	elseif newx == nil then
		prim_set_position(name,oldx-24,oldy)
	end

end

function checkExists(name)
	if #imgTable == 0 then
		return false
	else
		for u = 1, #imgTable do
			if imgTable[u][1] == name then
				return true
			else
				return false
			end
		end
	end
end
			
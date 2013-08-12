--[[

Copyright (c) 06 Aug 2013, Ilax / Pr0c3ss0r
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of 'Menu' nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Ilax / Pr0c3ss0r BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


-- CreateMenu(Menu_name, Caption, Menu_Option_List, x, y, Max_Line_Show, sub_key *optional)

 ** Menu_name need to be unique.

 Example:

   MenuList = {
	sub="Oneiros Grip",
	rear="Cmd. Earring",
	main="Terra's Staff",
	neck="Twilight Torque",
	lring="Dark Ring",
	rring="Dark Ring",
	back="Shadow Mantle",
	legs="Crimson Cuisses",
	waist="Flume Belt",
	lear="Moonshade Earring",
	body="Bokwus Robe",
	head="Dls. Chapeau +2",
	feet="Estq. houseaux +2"}

   My_Menu = menu.create("my_menu_name", "Menu caption test", MenuList, 200, 200, 5)

   My_Menu = menu.combine(Menu, {
      on_load = function (this)
         write('Menu ['..this.menu_name..'] on_load trigger')
      end,

      on_dbl_click = function (this, index, val)
         write('Menu ['..this.menu_name..'] dbl_click ['..index..'] ('..val..')')
      end,

      on_close = function (this)
         write('Menu ['..this.menu_name..'] close')
      end,

      on_click = function (this, index, val)
         write('Menu ['..this.menu_name..'] click ['..index..'] ('..val..')')
      end,

      on_move = function (this, x, y)
         write('Menu_event_move ['..this.menu_name..'] X='..x..' Y='..y)
      end
   })

**  Menu Pos			= this.x / this.y
**  menu name			= this.menu_name
**  Menu Scroll position	= this.scr
**  Menu cursor position	= this.cur
**  Menu list text value	= this.text[index]
**  Menu list key value		= this.key[index]

]]------------------------------------------------------------------------------


_libs = _libs or {}
_libs.menu = true


local menu = {}

menu.list = {}
menu.First_Click = 0
menu.mpn = nil
menu.mousePressX = 0
menu.mousePressY = 0
menu.mouse_on = nil
menu.mouse_moved = false
menu.current_menu = nil
menu.callback_list = {}

function menu.callback_event()
   for key, val in pairs(menu.callback_list) do
      if (os.clock() >= menu.callback_list[key].clock) then 

         --only delete if return false or nil.
         local ret = menu.callback_list[key].fn(key)
         if  ret == false or ret == nil then 
            menu.callback_list[key] = nil
         end
      end    
   end
end

windower.register_event('prerender', menu.callback_event) -- Kick event ~30x/sec

function menu.Refresh(MenuName)
   local tb = ''

   for i = 0, menu.list[MenuName]['mx'] do
      tb=tb..menu.list[MenuName]['Core_Text'][i+menu.list[MenuName]['scr']]
   end

   windower.text.set_text('Menu_TB_'..MenuName, tb)

   x,y = windower.text.get_location('Menu_TB_'..MenuName)

   windower.text.set_location('Menu_cur_'..MenuName, x, y + menu.list[MenuName]['cur'] * 14)
   windower.text.set_text('Menu_cur_'..MenuName, menu.list[MenuName]['Core_Text'][menu.list[MenuName]['cur'] + menu.list[MenuName]['scr']])
end

function menu.create(MenuName, Caption, opt, x, y, mx, sub_key)
   menu.list[MenuName] = {}

   local tb = ''
   local scr = ''

   menu.list[MenuName]['menu_name'] = MenuName
   menu.list[MenuName]['Core_Text'] = {}
   menu.list[MenuName]['text'] = {}
   menu.list[MenuName]['key'] = {}

   menu.list[MenuName]['scr'] = 0
   menu.list[MenuName]['cur'] = 0
   menu.list[MenuName]['mx'] = mx - 1
   menu.list[MenuName]['max_ln'] = string.len(Caption)+1

   menu.list[MenuName]['x'] = x
   menu.list[MenuName]['y'] = y

   -- FIX Text Length
   local ii = 0

   for i, v in pairs(opt) do
      if sub_key ~= nil then 
         menu.list[MenuName]['text'][ii] = v[sub_key]
      else
         menu.list[MenuName]['text'][ii] = v
      end

      menu.list[MenuName]['key'][ii] = i

      if menu.list[MenuName]['max_ln'] < string.len(menu.list[MenuName]['text'][ii]) + 1 then 
         menu.list[MenuName]['max_ln'] = string.len(menu.list[MenuName]['text'][ii]) + 1
      end
      ii = ii + 1
   end

   if mx > #menu.list[MenuName]['text'] + 1 then mx = #menu.list[MenuName]['text'] + 1 end

   for i = 0, #menu.list[MenuName]['text'] do
      menu.list[MenuName]['Core_Text'][i] = ' '..menu.list[MenuName]['text'][i]..string.rep(' ', menu.list[MenuName]['max_ln'] - string.len(menu.list[MenuName]['text'][i]))..'\\cr\n'
   end

   for i = 0, mx-1 do
      tb=tb..menu.list[MenuName]['Core_Text'][i]
      scr=scr..' \\cr\n'
   end

   Caption = Caption..string.rep(' ', menu.list[MenuName]['max_ln']- string.len(Caption))..' X\\cr\n'

   -- Create all Textbox

   windower.text.create('Menu_Caption_'..MenuName)
   windower.text.set_location('Menu_Caption_'..MenuName, -10000, -10000)
   windower.text.set_bg_color('Menu_Caption_'..MenuName, 180, 80, 110, 140)
   windower.text.set_color('Menu_Caption_'..MenuName, 250, 250, 250, 250)
   windower.text.set_bold('Menu_Caption_'..MenuName, 'true')
   windower.text.set_text('Menu_Caption_'..MenuName, Caption)
   windower.text.set_bg_visibility('Menu_Caption_'..MenuName, true)
   windower.text.set_font('Menu_Caption_'..MenuName, 'Courier New', 9)
   windower.text.set_visibility('Menu_Caption_'..MenuName, true)

   windower.text.create('Menu_TB_'..MenuName)
   windower.text.set_location('Menu_TB_'..MenuName, -10000, -10000)
   windower.text.set_bg_color('Menu_TB_'..MenuName, 140, 54, 43, 0)
   windower.text.set_color('Menu_TB_'..MenuName, 250, 220, 220, 220)
   windower.text.set_bold('Menu_TB_'..MenuName, 'true')
   windower.text.set_text('Menu_TB_'..MenuName, tb)
   windower.text.set_bg_visibility('Menu_TB_'..MenuName, true)
   windower.text.set_font('Menu_TB_'..MenuName, 'Courier New', 9)
   windower.text.set_visibility('Menu_TB_'..MenuName, true)

   windower.text.create('Menu_cur_'..MenuName)
   windower.text.set_bg_color('Menu_cur_'..MenuName, 155, 40, 40, 100)
   windower.text.set_color('Menu_cur_'..MenuName, 255, 255, 255, 255)
   windower.text.set_bold('Menu_cur_'..MenuName, 'true')
   windower.text.set_text('Menu_cur_'..MenuName, menu.list[MenuName]['Core_Text'][menu.list[MenuName]['cur']])
   windower.text.set_bg_visibility('Menu_cur_'..MenuName, true)
   windower.text.set_font('Menu_cur_'..MenuName, 'Courier New', 9)
   windower.text.set_visibility('Menu_cur_'..MenuName, false)

   windower.text.create('Menu_scr_'..MenuName)
   windower.text.set_bg_color('Menu_scr_'..MenuName, 140, 80, 80, 80)
   windower.text.set_color('Menu_scr_'..MenuName, 255, 0, 0, 0)
   windower.text.set_bold('Menu_scr_'..MenuName, 'true')
   windower.text.set_text('Menu_scr_'..MenuName, scr)
   windower.text.set_bg_visibility('Menu_scr_'..MenuName, true)
   windower.text.set_font('Menu_scr_'..MenuName, 'Courier New', 9)
   windower.text.set_visibility('Menu_scr_'..MenuName, false)

   windower.text.create('Menu_bar_'..MenuName)
   windower.text.set_bg_color('Menu_bar_'..MenuName, 255, 255, 255, 255)
   windower.text.set_color('Menu_bar_'..MenuName, 255, 0, 0, 0)
   windower.text.set_bold('Menu_bar_'..MenuName, 'true')
   windower.text.set_text('Menu_bar_'..MenuName, ' \\cr')
   windower.text.set_bg_visibility('Menu_bar_'..MenuName, true)
   windower.text.set_font('Menu_bar_'..MenuName, 'Courier New', 9)
   windower.text.set_visibility('Menu_bar_'..MenuName, false)

   -- kick this function every .01 sec. (no return or return false cancel the functin loop)
   menu.callback_list['onload_Menu.'..MenuName] = {
      clock = os.clock() + .01,

      fn = function(key) 
         menu.callback_list[key].clock = os.clock() + .01
         key = string.gsub(key, 'onload_Menu.', '')
         local x2,y2 = windower.text.get_extents('Menu_TB_'..key)

         if x2 == 0 then  -- No graphic update yet.
            return true
         end

         local x = menu.list[key]['x']
         local y = menu.list[key]['y']

         menu.move(key, x, y)
         windower.text.set_location('Menu_bar_'..key, x + x2, y + 15)
         windower.text.set_visibility('Menu_Caption_'..key, true)
         windower.text.set_visibility('Menu_TB_'..key, true)
         windower.text.set_visibility('Menu_cur_'..key, true)
         windower.text.set_visibility('Menu_scr_'..key, true)
         windower.text.set_visibility('Menu_bar_'..key, true)


         if type(menu.list[key]['on_load']) == 'function' then
            menu.list[key]['on_load'](menu.list[key])
         end 
      end}

   menu.list[MenuName]['close'] = function()
      write('closing menu')
      windower.text.delete('Menu_TB_'..MenuName)
      windower.text.delete('Menu_cur_'..MenuName)
      windower.text.delete('Menu_scr_'..MenuName)
      windower.text.delete('Menu_bar_'..MenuName)
      windower.text.delete('Menu_Caption_'..MenuName)
      menu.list[MenuName] = nil
   end

   menu.list[MenuName]['move'] = function(x, y)
      menu.move(MenuName, x, y)
   end

   return menu.list[MenuName]
end 

function menu.combine(set1,set2)
   for i,v in pairs(set2) do
      set1[i] = v
   end   
   return set1
end

function menu.move(MenuName, x, y)
   local x1,y1 = windower.text.get_location('Menu_TB_'..MenuName)
   local x2,y2 = windower.text.get_extents('Menu_TB_'..MenuName)

   menu.list[MenuName]['x'] = x
   menu.list[MenuName]['y'] = y

   windower.text.set_location('Menu_Caption_'..MenuName, x, y)
   y = y + 15
   windower.text.set_location('Menu_TB_'..MenuName, x, y)
   windower.text.set_location('Menu_cur_'..MenuName, x, y + menu.list[MenuName]['cur'] * 14)

   windower.text.set_location('Menu_scr_'..MenuName, x + x2, y)
   local bar_x,bar_y = windower.text.get_location('Menu_bar_'..MenuName)
   bar_y = bar_y - y1
   windower.text.set_location('Menu_bar_'..MenuName, x + x2, y + bar_y)
end

function menu.mouse_event(ActionType, x, y, is_blocked)
   local x1 = 0
   local y1 = 0

   local yy1 = 0
   local xx1 = 0

   local NewX = 0
   local NewY = 0

   local this = nil

   if ActionType == 514 then  --mouse up
      if menu.mpn ~= nil then

         if menu.mouse_moved == false then
            this = menu.list[menu.mpn]

            if menu.mouse_on == 'close' then 
               if type(this['on_close']) == 'function' then
                  ret = this['on_close'](this)
                  if ret ~= true then
                     this.close()
                  end
               end                 

            elseif menu.mouse_on == 'content' then 
               if (os.clock() - menu.First_Click) < .5 and menu.First_Click ~= 0 then --mouse dbl_click
                  menu.First_Click = 0
                  if type(this['on_dbl_click']) == 'function' then
                     this['on_dbl_click'](this, this['cur'] + this['scr'], this['text'][ this['cur'] + this['scr'] ])
                  end
                  menu.mpn = nil
                  return true
               else
                  if type(this['on_click']) == 'function' then
                     this['on_click']( this, this['cur'] + this['scr'], this['text'][ this['cur'] + this['scr']])
                  end 
               end
            end
         end 

         menu.mpn = nil
         menu.First_Click = os.clock()
         return true
      end

   elseif ActionType == 512 then  --mouse move
      menu.mouse_moved = true
      menu.First_Click = 0

      if menu.mpn == nil then

         menu.mouse_on = nil

         for key, val in pairs(menu.list) do
            x1,y1 = windower.text.get_location('Menu_TB_'..key)
            x2,y2 = windower.text.get_extents('Menu_TB_'..key)

            if x < x1 + x2+9 and x > x1 then 
               if y < y1 + y2 and y > y1 - 15 then 

                  menu.current_menu = key
   
                  if y > y1 then 
                     if x < x1 + x2+1 then 
                        local Menu_cur = math.floor ((y - y1-1) / 14)
  
                        if menu.list[key]['cur'] ~= Menu_cur then
                           menu.list[key]['cur'] = Menu_cur
                           menu.Refresh(key)
                        end

                        menu.mouse_on = 'content'
                        break
                     else 
                        menu.mouse_on = 'scroll'
                        break
                     end
                  else
                     if x > x1 + x2 then 
                        menu.mouse_on = 'close'
                        break
                     else
                        menu.mouse_on = 'caption'
                        break
                     end
                  end 
               end
            end
         end
      else

         x1,y1 = windower.text.get_location('Menu_Caption_'..menu.mpn)
         x2,y2 = windower.text.get_extents('Menu_TB_'..menu.mpn)

         if menu.mouse_on == 'caption' or menu.mouse_on == 'content' then
            this = menu.list[menu.mpn]
            NewX = x1 + x - menu.mousePressX 
            NewY = y1 + y - menu.mousePressY

            menu.move(menu.mpn, NewX, NewY)

            if type(this['on_move']) == 'function' then
               this['on_move'](this, this.x, this.y)
            end                 

            menu.mousePressX = x
            menu.mousePressY = y

         elseif menu.mouse_on == 'scroll' then
            xx1,yy1 = windower.text.get_location('Menu_bar_'..menu.mpn)
            xx2,yy2 = windower.text.get_extents('Menu_bar_'..menu.mpn)

            if menu.mousePressY > yy1 and menu.mousePressY < yy1 + yy2 then 

               NewY = yy1 + y - menu.mousePressY

               if NewY <= y1 + 15 then 
                  NewY = y1 + 15
                  menu.mousePressY = NewY + ( menu.mousePressY - yy1)
               elseif NewY >= y1 + y2 then 
                  NewY = y1 + y2
                  menu.mousePressY = NewY + ( menu.mousePressY - yy1)
               else
                  menu.mousePressY = y
               end

               windower.text.set_location('Menu_bar_'..menu.mpn, xx1, NewY)

               local MaxScr = (#menu.list[menu.mpn]['text'] - menu.list[menu.mpn]['mx'])

               local per =  (NewY-y1) / y2
               local scr = math.floor(per * MaxScr)
 
               if menu.list[menu.mpn]['scr'] ~= scr then
                  if scr + menu.list[menu.mpn]['cur'] <= #menu.list[menu.mpn]['text'] then
                     menu.list[menu.mpn]['scr'] = scr
                     menu.Refresh(menu.mpn)
                  end
               end

            end
         end
         return false
      end

   elseif ActionType == 513 and menu.mouse_on ~= nil then --mouse down 
      menu.mouse_moved = false
      menu.mousePressX = x
      menu.mousePressY = y
      menu.mpn = menu.current_menu

      return true
   end
end

windower.register_event('mouse', menu.mouse_event)

function menu.event_unload()
   for key, val in pairs(menu.list) do
      windower.text.delete('Menu_TB_'..key)
      windower.text.delete('Menu_cur_'..key)
      windower.text.delete('Menu_scr_'..key)
      windower.text.delete('Menu_bar_'..key)
      windower.text.delete('Menu_Caption_'..key)
      menu.list[key] = nil
   end
end

windower.register_event('unload', menu.event_unload)

return menu
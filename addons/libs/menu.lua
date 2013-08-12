--[[ Menu Lib by Ilax / Pr0c3ss0r 06 Aug 2013


-- CreateMenu(Menu_name, Caption, Menu_Option_List, x, y, Max_Line_Show, sub_key)

 ** Menu_name need to be unique.

 Example:

   MenuList[0] = 'list1'
   MenuList[1] = 'list2'
   MenuList[2] = 'list3'
   MenuList[3] = 'list4'
   MenuList[4] = 'list5'
   MenuList[5] = 'list6'
   MenuList[6] = 'list7'
   MenuList[7] = 'list8'
   MenuList[8] = 'list9'
   MenuList[9] = 'list10'

   Menu = CreateMenu("my_menu_name", "Menu caption test", MenuList, 200, 200, 5)

   Menu = menu_combine(Menu, {
      on_load = function (this)
         write('Menu ['..this.Menu_Name..'] on_load trigger')
      end,

      on_dbl_click = function (this, index, val)
         write('Menu ['..this.Menu_Name..'] dbl_click ['..index..'] ('..val..')')
      end,

      on_close = function (this)
         write('Menu ['..this.Menu_Name..'] close')
      end,

      on_click = function (this, index, val)
         write('Menu ['..this.Menu_Name..'] click ['..index..'] ('..val..')')
      end,

      on_move = function (this, x, y)
         write('Menu_event_move ['..this.Menu_Name..'] X='..x..' Y='..y)
      end
   })

**  Menu_Pos			= this.x / this.y
**  Menu_name			= this.x / this.y
**  Menu Scroll position	= this.scr
**  Menu cursor position	= this.cur
**  Menu list text value	= this.text[index]
**  Menu list key value		= this.key[index]

]]------------------------------------------------------------------------------

_Menu = {}
_Menu.list = {}
_Menu.First_Click = 0
_Menu._MenuPress = nil
_Menu._MenuPressX = 0
_Menu._MenuPressY = 0
_Menu._MenuPress_type = nil
_Menu._MouseMoved = false

_Menu.callback_event = {}

function menu_callback_event()
   for key, val in pairs(_Menu.callback_event) do
      if (os.clock() >= _Menu.callback_event[key].clock) then 

         --only delete if return false or nil.
         local ret = _Menu.callback_event[key].fn(key)
         if  ret == false or ret == nil then 
            _Menu.callback_event[key] = nil
         end
      end    
   end
end

windower.register_event('prerender', menu_callback_event) -- Kick event ~30x/sec

function RefreshMenu(MenuName)
   local tb = ''

   for i = 0, _Menu.list[MenuName]['mx'] do
      tb=tb.._Menu.list[MenuName]['Core_Text'][i+_Menu.list[MenuName]['scr']]
   end
   windower.text.set_text('Menu_TB_'..MenuName, tb)

   x,y = windower.text.get_location('Menu_TB_'..MenuName)

   windower.text.set_location('Menu_cur_'..MenuName, x, y + _Menu.list[MenuName]['cur'] * 14)
   windower.text.set_text('Menu_cur_'..MenuName, _Menu.list[MenuName]['Core_Text'][_Menu.list[MenuName]['cur'] + _Menu.list[MenuName]['scr']])
end

function CreateMenu(MenuName, Caption, opt, x, y, mx, sub_key)
   _Menu.list[MenuName] = {}

   local tb = ''
   local scr = ''

   _Menu.list[MenuName]['Menu_Name'] = MenuName
   _Menu.list[MenuName]['Core_Text'] = {}
   _Menu.list[MenuName]['text'] = {}
   _Menu.list[MenuName]['key'] = {}

   _Menu.list[MenuName]['scr'] = 0
   _Menu.list[MenuName]['cur'] = 0
   _Menu.list[MenuName]['mx'] = mx - 1
   _Menu.list[MenuName]['max_ln'] = string.len(Caption)+1

   _Menu.list[MenuName]['x'] = x
   _Menu.list[MenuName]['y'] = y

   -- FIX Text Length
   local ii = 0

   for i, v in pairs(opt) do
      if sub_key ~= nil then 
         _Menu.list[MenuName]['text'][ii] = v[sub_key]
      else
         _Menu.list[MenuName]['text'][ii] = v
      end

      _Menu.list[MenuName]['key'][ii] = i

      if _Menu.list[MenuName]['max_ln'] < string.len(_Menu.list[MenuName]['text'][ii]) + 1 then 
         _Menu.list[MenuName]['max_ln'] = string.len(_Menu.list[MenuName]['text'][ii]) + 1
      end
      ii = ii + 1
   end

   if mx > #_Menu.list[MenuName]['text'] + 1 then mx = #_Menu.list[MenuName]['text'] + 1 end

   for i = 0, #_Menu.list[MenuName]['text'] do
      _Menu.list[MenuName]['Core_Text'][i] = ' '.._Menu.list[MenuName]['text'][i]..string.rep(' ', _Menu.list[MenuName]['max_ln'] - string.len(_Menu.list[MenuName]['text'][i]))..'\\cr\n'
   end

   for i = 0, mx-1 do
      tb=tb.._Menu.list[MenuName]['Core_Text'][i]
      scr=scr..' \\cr\n'
   end

   Caption = Caption..string.rep(' ', _Menu.list[MenuName]['max_ln']- string.len(Caption))..' X\\cr\n'

   -- Create all Textbox

   windower.text.create('Menu_Caption_'..MenuName)
   windower.text.set_location('Menu_Caption_'..MenuName, x, y)
   windower.text.set_bg_color('Menu_Caption_'..MenuName, 180, 80, 110, 140)
   windower.text.set_color('Menu_Caption_'..MenuName, 250, 250, 250, 250)
   windower.text.set_bold('Menu_Caption_'..MenuName, 'true')
   windower.text.set_text('Menu_Caption_'..MenuName, Caption)


   windower.text.set_bg_visibility('Menu_Caption_'..MenuName, true)
   windower.text.set_font('Menu_Caption_'..MenuName, 'Courier New', 9)
   windower.text.set_visibility('Menu_Caption_'..MenuName, true)

   windower.text.create('Menu_TB_'..MenuName)
   windower.text.set_location('Menu_TB_'..MenuName, x, y+15)
   windower.text.set_bg_color('Menu_TB_'..MenuName, 140, 54, 43, 0)
   windower.text.set_color('Menu_TB_'..MenuName, 250, 250, 250, 250)
   windower.text.set_bold('Menu_TB_'..MenuName, 'true')
   windower.text.set_text('Menu_TB_'..MenuName, tb)
   windower.text.set_bg_visibility('Menu_TB_'..MenuName, true)
   windower.text.set_font('Menu_TB_'..MenuName, 'Courier New', 9)
   windower.text.set_visibility('Menu_TB_'..MenuName, true)

   windower.text.create('Menu_cur_'..MenuName)
   windower.text.set_bg_color('Menu_cur_'..MenuName, 155, 40, 40, 100)
   windower.text.set_color('Menu_cur_'..MenuName, 255, 255, 255, 255)
   windower.text.set_bold('Menu_cur_'..MenuName, 'true')
   windower.text.set_text('Menu_cur_'..MenuName, _Menu.list[MenuName]['Core_Text'][_Menu.list[MenuName]['cur']])
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
   _Menu.callback_event['onload_Menu.'..MenuName] = {
      clock = os.clock() + .01,

      fn = function(key) 
         _Menu.callback_event[key].clock = os.clock() + .01
         key = string.gsub(key, 'onload_Menu.', '')
         local x2,y2 = windower.text.get_extents('Menu_TB_'..key)

         if x2 == 0 then  -- No graphic update yet.
            return true
         end

         local x,y = windower.text.get_location('Menu_TB_'..key)

         windower.text.set_location('Menu_bar_'..key, x, y)
         Move_Menu(key, x, y)

         windower.text.set_visibility('Menu_Caption_'..key, true)
         windower.text.set_visibility('Menu_TB_'..key, true)
         windower.text.set_visibility('Menu_cur_'..key, true)
         windower.text.set_visibility('Menu_scr_'..key, true)
         windower.text.set_visibility('Menu_bar_'..key, true)

         if type(_Menu.list[key]['on_load']) == 'function' then
            _Menu.list[key]['on_load'](_Menu.list[key])
         end 
      end}

   _Menu.list[MenuName]['close'] = function()
      write('closing menu')
      windower.text.delete('Menu_TB_'..MenuName)
      windower.text.delete('Menu_cur_'..MenuName)
      windower.text.delete('Menu_scr_'..MenuName)
      windower.text.delete('Menu_bar_'..MenuName)
      windower.text.delete('Menu_Caption_'..MenuName)
      _Menu.list[MenuName] = nil
   end

   _Menu.list[MenuName]['move'] = function(x, y)
      Move_Menu(MenuName, x, 15 + y)
   end

   return _Menu.list[MenuName]
end 

function menu_combine(set1,set2)
   for i,v in pairs(set2) do
      set1[i] = v
   end   
   return set1
end

function Move_Menu(MenuName, x, y)
   local x1,y1 = windower.text.get_location('Menu_TB_'..MenuName)
   local x2,y2 = windower.text.get_extents('Menu_TB_'..MenuName)

   _Menu.list[MenuName]['x'] = x
   _Menu.list[MenuName]['y'] = y - 15

   windower.text.set_location('Menu_Caption_'..MenuName, x, y - 15)
   windower.text.set_location('Menu_TB_'..MenuName, x, y)
   windower.text.set_location('Menu_cur_'..MenuName, x, y + _Menu.list[MenuName]['cur'] * 14)

   windower.text.set_location('Menu_scr_'..MenuName, x + x2, y)
   local bar_x,bar_y = windower.text.get_location('Menu_bar_'..MenuName)
   bar_y = bar_y - y1
   windower.text.set_location('Menu_bar_'..MenuName, x + x2, y + bar_y)
end

function menu_mouse_event(ActionType, x, y, is_blocked)
   local x1 = 0
   local y1 = 0

   local yy1 = 0
   local xx1 = 0

   local NewX = 0
   local NewY = 0

   local this = nil

   if ActionType == 514 then  --mouse up
      if _Menu._MenuPress ~= nil then

         if _Menu._MouseMoved == false then
            this = _Menu.list[_Menu._MenuPress]

            if _Menu._MenuPress_type == 'close' then 
               if type(this['on_close']) == 'function' then
                  ret = this['on_close'](this)
                  if ret ~= true then
                     this.close()
                  end
               end                 

            elseif _Menu._MenuPress_type == 'content' then 
               if (os.clock() - _Menu.First_Click) < .5 and _Menu.First_Click ~= 0 then --mouse dbl_click
                  _Menu.First_Click = 0
                  if type(this['on_dbl_click']) == 'function' then
                     this['on_dbl_click'](this, this['cur'] + this['scr'], this['text'][ this['cur'] + this['scr'] ])
                  end
                  _Menu._MenuPress_type = nil
                  _Menu._MenuPress = nil
                  return true
               else
                  if type(this['on_click']) == 'function' then
                     this['on_click']( this, this['cur'] + this['scr'], this['text'][ this['cur'] + this['scr']])
                  end 
               end
            end
         end 

         _Menu._MenuPress_type = nil
         _Menu._MenuPress = nil
         _Menu.First_Click = os.clock()
         return true
      end
   end

   if ActionType == 512 then  --mouse move
      _Menu._MouseMoved = true
      _Menu.First_Click = 0
      if _Menu._MenuPress ~= nil then

         x1,y1 = windower.text.get_location('Menu_TB_'.._Menu._MenuPress)
         x2,y2 = windower.text.get_extents('Menu_TB_'.._Menu._MenuPress)

         if _Menu._MenuPress_type == 'caption' or _Menu._MenuPress_type == 'content' then
            this = _Menu.list[_Menu._MenuPress]
            NewX = x1 + x - _Menu._MenuPressX 
            NewY = y1 + y - _Menu._MenuPressY

            Move_Menu(_Menu._MenuPress, NewX, NewY)

            if type(this['on_move']) == 'function' then
               this['on_move'](this, NewX, NewY)
            end                 
            
            _Menu._MenuPressX = x
            _Menu._MenuPressY = y

         elseif _Menu._MenuPress_type == 'scroll' then
            xx1,yy1 = windower.text.get_location('Menu_bar_'.._Menu._MenuPress)
            xx2,yy2 = windower.text.get_extents('Menu_bar_'.._Menu._MenuPress)

            if _Menu._MenuPressY > yy1 and _Menu._MenuPressY < yy1 + yy2 then 

               NewY = yy1 + y - _Menu._MenuPressY

               if NewY <= y1 then 
                  NewY = y1
                  _Menu._MenuPressY = NewY + ( _Menu._MenuPressY - yy1)
               elseif NewY >= y1 + y2 - 15 then 
                  NewY = y1 + y2 - 15
                  _Menu._MenuPressY = NewY + ( _Menu._MenuPressY - yy1)
               else
                  _Menu._MenuPressY = y
               end

               windower.text.set_location('Menu_bar_'.._Menu._MenuPress, xx1, NewY)

               local MaxScr = (#_Menu.list[_Menu._MenuPress]['text'] - _Menu.list[_Menu._MenuPress]['mx'])

               local per =  (NewY-y1) / (y2 - 15)
               local scr = math.floor(per * MaxScr)
 
               if _Menu.list[_Menu._MenuPress]['scr'] ~= scr then
                  if scr + _Menu.list[_Menu._MenuPress]['cur'] <= #_Menu.list[_Menu._MenuPress]['text'] then
                     _Menu.list[_Menu._MenuPress]['scr'] = scr
                     RefreshMenu(_Menu._MenuPress)
                  end
               end

            end
         end

         return false
      end
   end


   for key, val in pairs(_Menu.list) do
      x1,y1 = windower.text.get_location('Menu_TB_'..key)
      x2,y2 = windower.text.get_extents('Menu_TB_'..key)

      if x < x1 + x2+9 and x > x1 then 
         if y < y1 + y2 and y > y1 - 15 then 

            if y > y1 then 
               if x < x1 + x2+1 then 
                  local Menu_cur = math.floor ((y - y1-1) / 14)
  
                  if _Menu.list[key]['cur'] ~= Menu_cur then
                     _Menu.list[key]['cur'] = Menu_cur
                     RefreshMenu(key)
                  end

                  _Menu._MenuPress_type = 'content'
               else 
                  _Menu._MenuPress_type = 'scroll'
               end
            else
               if x > x1 + x2 and ActionType == 513 then 
                  _Menu._MenuPress_type = 'close'
               else
                  _Menu._MenuPress_type = 'caption'
               end
            end 

            if ActionType == 513 then --mouse down 
               _Menu._MouseMoved = false

               _Menu._MenuPress = key
               _Menu._MenuPressX = x
               _Menu._MenuPressY = y

               return true
            end
         end
      end
   end
end

windower.register_event('mouse', menu_mouse_event)

function menu_event_unload()
   for key, val in pairs(_Menu.list) do
      windower.text.delete('Menu_TB_'..key)
      windower.text.delete('Menu_cur_'..key)
      windower.text.delete('Menu_scr_'..key)
      windower.text.delete('Menu_bar_'..key)
      windower.text.delete('Menu_Caption_'..key)
      _Menu.list[key] = nil
   end
end

windower.register_event('unload', menu_event_unload)

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


 Syntax:  menu.new(menu_name, caption, menu_option_list, x, y, max_line_show, sub_key *optional)

 ** menu_name need to be unique.

 Example:

   menu_list = {
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

   my_menu = menu.new("my_menu_name", "Menu caption test", menu_list, 400, 400, 5)

   my_menu['on_load'] = function (this)
      write('Menu ['..this.menu_name..'] on_load trigger')
   end

   my_menu['on_dbl_click'] = function (this, index, val)
      write('Menu ['..this.menu_name..'] dbl_click ['..index..'] ('..val..')')
   end

   my_menu['on_close'] = function (this)
      write('Menu ['..this.menu_name..'] close')
   end

   my_menu['on_click'] = function (this, index, val)
      write('Menu ['..this.menu_name..'] click ['..index..'] ('..val..')')
   end

   my_menu['on_move'] = function (this, x, y)
      write('menu_event_move ['..this.menu_name..'] X='..x..' Y='..y)
   end

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

local menu_list = {}
local First_Click = 0
local mpn = nil
local mouse_press_x = 0
local mouse_press_y = 0
local mouse_on = nil
local mouse_moved = false
local current_menu = nil
local callback_list = {}

local function callback_event()
   for key, val in pairs(callback_list) do
      if (os.clock() >= callback_list[key].clock) then 

         --only delete if return false or nil.
         local ret = callback_list[key].fn(key)
         if  ret == false or ret == nil then 
            callback_list[key] = nil
         end
      end    
   end
end

windower.register_event('prerender', callback_event) -- Kick event ~30x/sec

local function menu_move(menu_name, x, y)
   local x1,y1 = windower.text.get_location('menu_tb_'..menu_name)
   local x2,y2 = windower.text.get_extents('menu_tb_'..menu_name)

   menu_list[menu_name]['x'] = x
   menu_list[menu_name]['y'] = y

   windower.text.set_location('menu_caption_'..menu_name, x, y)

   windower.text.set_location('menu_tb_'..menu_name, x, 15 + y)
   windower.text.set_location('menu_cur_'..menu_name, x, 15 + y + menu_list[menu_name]['cur'] * 14)

   windower.text.set_location('menu_scr_'..menu_name, x + x2, 15 + y)
   local bar_x,bar_y = windower.text.get_location('menu_bar_'..menu_name)
   bar_y = bar_y - y1
   windower.text.set_location('menu_bar_'..menu_name, x + x2, 15 + y + bar_y)
end

local function menu_refresh(menu_name)
   local tb = ''

   for i = 0, menu_list[menu_name]['mx'] do
      tb=tb..menu_list[menu_name]['core_text'][i+menu_list[menu_name]['scr']]
   end

   windower.text.set_text('menu_tb_'..menu_name, tb)

   local x,y = windower.text.get_location('menu_tb_'..menu_name)

   windower.text.set_location('menu_cur_'..menu_name, x, y + menu_list[menu_name]['cur'] * 14)
   windower.text.set_text('menu_cur_'..menu_name, menu_list[menu_name]['core_text'][menu_list[menu_name]['cur'] + menu_list[menu_name]['scr']])
end

function menu.new(menu_name, caption, opt, x, y, mx, sub_key)
   menu_list[menu_name] = {}

   local tb = ''
   local scr = ''

   menu_list[menu_name]['menu_name'] = menu_name
   menu_list[menu_name]['core_text'] = {}
   menu_list[menu_name]['text'] = {}
   menu_list[menu_name]['key'] = {}

   menu_list[menu_name]['scr'] = 0
   menu_list[menu_name]['cur'] = 0
   menu_list[menu_name]['mx'] = mx - 1
   menu_list[menu_name]['max_ln'] = string.len(caption)+1

   menu_list[menu_name]['x'] = x
   menu_list[menu_name]['y'] = y

   -- FIX Text Length
   local ii = 0

   for i, v in pairs(opt) do
      if sub_key ~= nil then 
         menu_list[menu_name]['text'][ii] = v[sub_key]
      else
         menu_list[menu_name]['text'][ii] = v
      end

      menu_list[menu_name]['key'][ii] = i

      if menu_list[menu_name]['max_ln'] < string.len(menu_list[menu_name]['text'][ii]) + 1 then 
         menu_list[menu_name]['max_ln'] = string.len(menu_list[menu_name]['text'][ii]) + 1
      end
      ii = ii + 1
   end

   if mx > #menu_list[menu_name]['text'] + 1 then mx = #menu_list[menu_name]['text'] + 1 end

   for i = 0, #menu_list[menu_name]['text'] do
      menu_list[menu_name]['core_text'][i] = ' '..menu_list[menu_name]['text'][i]..string.rep(' ', menu_list[menu_name]['max_ln'] - string.len(menu_list[menu_name]['text'][i]))..'\\cr\n'
   end

   for i = 0, mx-1 do
      tb=tb..menu_list[menu_name]['core_text'][i]
      scr=scr..' \\cr\n'
   end

   caption = caption..string.rep(' ', menu_list[menu_name]['max_ln']- string.len(caption))..' X\\cr\n'

   -- Create all Textbox

   windower.text.create('menu_caption_'..menu_name)
   windower.text.set_location('menu_caption_'..menu_name, -1000, -1000)
   windower.text.set_bg_color('menu_caption_'..menu_name, 180, 80, 110, 140)
   windower.text.set_color('menu_caption_'..menu_name, 250, 250, 250, 250)
   windower.text.set_bold('menu_caption_'..menu_name, 'true')
   windower.text.set_text('menu_caption_'..menu_name, caption)
   windower.text.set_bg_visibility('menu_caption_'..menu_name, true)
   windower.text.set_font('menu_caption_'..menu_name, 'Courier New', 9)
   windower.text.set_visibility('menu_caption_'..menu_name, true)

   windower.text.create('menu_tb_'..menu_name)
   windower.text.set_location('menu_tb_'..menu_name, -10000, -10000)
   windower.text.set_bg_color('menu_tb_'..menu_name, 140, 54, 43, 0)
   windower.text.set_color('menu_tb_'..menu_name, 250, 220, 220, 220)
   windower.text.set_bold('menu_tb_'..menu_name, 'true')
   windower.text.set_text('menu_tb_'..menu_name, tb)
   windower.text.set_bg_visibility('menu_tb_'..menu_name, true)
   windower.text.set_font('menu_tb_'..menu_name, 'Courier New', 9)
   windower.text.set_visibility('menu_tb_'..menu_name, true)

   windower.text.create('menu_cur_'..menu_name)
   windower.text.set_bg_color('menu_cur_'..menu_name, 155, 40, 40, 100)
   windower.text.set_color('menu_cur_'..menu_name, 255, 255, 255, 255)
   windower.text.set_bold('menu_cur_'..menu_name, 'true')
   windower.text.set_text('menu_cur_'..menu_name, menu_list[menu_name]['core_text'][menu_list[menu_name]['cur']])
   windower.text.set_bg_visibility('menu_cur_'..menu_name, true)
   windower.text.set_font('menu_cur_'..menu_name, 'Courier New', 9)
   windower.text.set_visibility('menu_cur_'..menu_name, false)

   windower.text.create('menu_scr_'..menu_name)
   windower.text.set_bg_color('menu_scr_'..menu_name, 140, 80, 80, 80)
   windower.text.set_color('menu_scr_'..menu_name, 255, 0, 0, 0)
   windower.text.set_bold('menu_scr_'..menu_name, 'true')
   windower.text.set_text('menu_scr_'..menu_name, scr)
   windower.text.set_bg_visibility('menu_scr_'..menu_name, true)
   windower.text.set_font('menu_scr_'..menu_name, 'Courier New', 9)
   windower.text.set_visibility('menu_scr_'..menu_name, false)

   windower.text.create('menu_bar_'..menu_name)
   windower.text.set_bg_color('menu_bar_'..menu_name, 255, 255, 255, 255)
   windower.text.set_color('menu_bar_'..menu_name, 255, 0, 0, 0)
   windower.text.set_bold('menu_bar_'..menu_name, 'true')
   windower.text.set_text('menu_bar_'..menu_name, ' \\cr')
   windower.text.set_bg_visibility('menu_bar_'..menu_name, true)
   windower.text.set_font('menu_bar_'..menu_name, 'Courier New', 9)
   windower.text.set_visibility('menu_bar_'..menu_name, false)

   -- kick this function every render until windower.text.get_extents return value. (no return or return false cancel the functin loop)
   callback_list['onload_Menu.'..menu_name] = {
      clock = os.clock(),

      fn = function(key) 
         callback_list[key].clock = os.clock()
         key = string.gsub(key, 'onload_Menu.', '')
         local x2,y2 = windower.text.get_extents('menu_tb_'..key)

         if x2 == 0 then  -- No graphic update yet.
            return true
         end

         local x = menu_list[key]['x']
         local y = menu_list[key]['y']

         menu_move(key, x, y)
         windower.text.set_location('menu_bar_'..key, x + x2, y + 15)
         windower.text.set_visibility('menu_caption_'..key, true)
         windower.text.set_visibility('menu_tb_'..key, true)
         windower.text.set_visibility('menu_cur_'..key, true)
         windower.text.set_visibility('menu_scr_'..key, true)
         windower.text.set_visibility('menu_bar_'..key, true)


         if type(menu_list[key]['on_load']) == 'function' then
            menu_list[key]['on_load'](menu_list[key])
         end 
      end}

   menu_list[menu_name]['close'] = function()
      write('closing menu')
      windower.text.delete('menu_tb_'..menu_name)
      windower.text.delete('menu_cur_'..menu_name)
      windower.text.delete('menu_scr_'..menu_name)
      windower.text.delete('menu_bar_'..menu_name)
      windower.text.delete('menu_caption_'..menu_name)
      menu_list[menu_name] = nil
   end

   menu_list[menu_name]['move'] = function(x, y)
      menu_move(menu_name, x, y)
   end

   menu_list[menu_name]['refresh'] = function()
      menu_refresh(menu_name)
   end

   return menu_list[menu_name]
end 

windower.register_event('mouse', function(action_type, x, y, is_blocked)
   local x1 = 0
   local y1 = 0

   local yy1 = 0
   local xx1 = 0

   local NewX = 0
   local NewY = 0

   local this = nil

   if action_type == 514 then  --mouse up
      if mpn ~= nil then

         if mouse_moved == false then
            this = menu_list[mpn]

            if mouse_on == 'close' then 
               if type(this['on_close']) == 'function' then
                  ret = this['on_close'](this)
                  if ret ~= true then
                     this.close()
                  end
               end                 

            elseif mouse_on == 'content' then 
               if (os.clock() - first_click) < .5 and first_click ~= 0 then --mouse dbl_click
                  first_click = 0
                  if type(this['on_dbl_click']) == 'function' then
                     this['on_dbl_click'](this, this['cur'] + this['scr'], this['text'][ this['cur'] + this['scr'] ])
                  end
                  mpn = nil
                  return true
               else
                  if type(this['on_click']) == 'function' then
                     this['on_click']( this, this['cur'] + this['scr'], this['text'][ this['cur'] + this['scr']])
                  end 
               end
            end
         end 

         mpn = nil
         first_click = os.clock()
         return true
      end

   elseif action_type == 512 then  --mouse move
      mouse_moved = true
      first_click = 0

      if mpn == nil then

         mouse_on = nil

         for key, val in pairs(menu_list) do
            x1,y1 = windower.text.get_location('menu_tb_'..key)
            x2,y2 = windower.text.get_extents('menu_tb_'..key)

            if x < x1 + x2+9 and x > x1 then 
               if y < y1 + y2 and y > y1 - 15 then 

                  current_menu = key
   
                  if y > y1 then 
                     if x < x1 + x2+1 then 
                        local menu_cur = math.floor ((y - y1-1) / 14)
  
                        if menu_list[key]['cur'] ~= menu_cur then
                           menu_list[key]['cur'] = menu_cur
                           menu_refresh(key)
                        end

                        mouse_on = 'content'
                        break
                     else 
                        mouse_on = 'scroll'
                        break
                     end
                  else
                     if x > x1 + x2 then 
                        mouse_on = 'close'
                        break
                     else
                        mouse_on = 'caption'
                        break
                     end
                  end 
               end
            end
         end
      else

         x1,y1 = windower.text.get_location('menu_caption_'..mpn)
         x2,y2 = windower.text.get_extents('menu_tb_'..mpn)

         if mouse_on == 'caption' or mouse_on == 'content' then
            this = menu_list[mpn]
            NewX = x1 + x - mouse_press_x 
            NewY = y1 + y - mouse_press_y

            menu_move(mpn, NewX, NewY)

            if type(this['on_move']) == 'function' then
               this['on_move'](this, this.x, this.y)
            end                 

            mouse_press_x = x
            mouse_press_y = y

         elseif mouse_on == 'scroll' then
            xx1,yy1 = windower.text.get_location('menu_bar_'..mpn)
            xx2,yy2 = windower.text.get_extents('menu_bar_'..mpn)

            if mouse_press_y > yy1 and mouse_press_y < yy1 + yy2 then 

               NewY = yy1 + y - mouse_press_y

               if NewY <= y1 + 15 then 
                  NewY = y1 + 15
                  mouse_press_y = NewY + ( mouse_press_y - yy1)
               elseif NewY >= y1 + y2 then 
                  NewY = y1 + y2
                  mouse_press_y = NewY + ( mouse_press_y - yy1)
               else
                  mouse_press_y = y
               end

               windower.text.set_location('menu_bar_'..mpn, xx1, NewY)

               local MaxScr = (#menu_list[mpn]['text'] - menu_list[mpn]['mx'])

               local per =  (NewY-y1) / y2
               local scr = math.floor(per * MaxScr)
 
               if menu_list[mpn]['scr'] ~= scr then
                  if scr + menu_list[mpn]['cur'] <= #menu_list[mpn]['text'] then
                     menu_list[mpn]['scr'] = scr
                     menu_refresh(mpn)
                  end
               end

            end
         end
         return false
      end

   elseif action_type == 513 and mouse_on ~= nil then --mouse down 
      mouse_moved = false
      mouse_press_x = x
      mouse_press_y = y
      mpn = current_menu

      return true
   end
end)

windower.register_event('unload', function()
   for key, val in pairs(menu_list) do
      windower.text.delete('menu_tb_'..key)
      windower.text.delete('menu_cur_'..key)
      windower.text.delete('menu_scr_'..key)
      windower.text.delete('menu_bar_'..key)
      windower.text.delete('menu_caption_'..key)
      menu_list[key] = nil
   end
end)

return menu
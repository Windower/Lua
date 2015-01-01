--[[Copyright © 2014, trv
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Rhombus nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL trv BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.--]]

addendum_white = {[14]="Poisona",[15]="Paralyna",[16]="Blindna",[17]="Silena",[18]="Stona",[19]="Viruna",[20]="Cursna",
    [143]="Erase",[13]="Raise II",[140]="Raise III",[141]="Reraise II",[142]="Reraise III",[135]="Reraise"}
    
addendum_black = {[253]="Sleep",[259]="Sleep II",[260]="Dispel",[162]="Stone IV",[163]="Stone V",[167]="Thunder IV",
    [168]="Thunder V",[157]="Aero IV",[158]="Aero V",[152]="Blizzard IV",[153]="Blizzard V",[147]="Fire IV",[148]="Fire V",
    [172]="Water IV",[173]="Water V",[255]="Break"}

unbridled_learning_set = {['Thunderbolt']=true,['Harden Shell']=true,['Absolute Terror']=true,
    ['Gates of Hades']=true,['Tourbillion']=true,['Pyric Bulwark']=true,['Bilgestorm']=true,
    ['Bloodrake']=true,['Droning Whirlwind']=true,['Carcharian Verve']=true,['Blistering Roar']=true,
    ['Uproot']=true,['Crashing Thunder']=true,['Polar Roar']=true}
    
not_a_spell = S{
    'Stratagems', 'Blood Pact: Rage', 'Sambas', 'Waltzes', 'Steps', 'Flourishes I', 'Flourishes II', 'Blood Pact: Ward',
    'Phantom Roll', 'Rune Enchantment', 'Jigs',
}
is_icon = {}
is_icon.W = true
is_icon.R = false
is_icon.G = false
is_icon.B = false
is_icon.Y = false

custom_menu_colors = {
    Fire = '255,133,133',
    Earth = '255,255,133',
    Water = '177,168,255',
    Wind = '111,255,111',
    Ice = '168,251,255',
    Thunder = '250,156,255',
    Light = '255,255,255',
    Darkness = '100,100,100',
}

player_info = {}
player_info.main_job = windower.ffxi.get_player().main_job_id
player_info.sub_job = windower.ffxi.get_player().sub_job_id
player_info.main_job_level = windower.ffxi.get_player().main_job_level
player_info.sub_job_level = windower.ffxi.get_player().sub_job_level
menu_layer_record = L{}
menu_history = {}
menu_list = L{}
menu_start = 1
is_menu_open = false
last_menu_open = {}
font_height_est = 16
selector_pos = {x=0,y=0}
drag_and_drop = false
mouse_safety = false
is_shift_modified = false

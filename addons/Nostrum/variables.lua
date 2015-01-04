--[[Copyright © 2014, trv
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Nostrum nor the
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

w=29
h=24
tab_keys=S{16,18,82,203,205,210}
spell_default=''
send_string = ''
to_update=L{}

saved_prims=S{}
saved_texts=S{}
prims_by_layer={L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{}}
texts_by_layer={L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{}}
misc_hold_for_up={texts=T{},prims=T{}}
macro = {[1]=S{},[2]=S{},[3]=S{}}
macro_visibility = {[1]=false,[2]=false,[3]=false}
text_coordinates={x=T{},y=T{},visible=T{}}
prim_coordinates={x=T{},y=T{},visible=T{},a=T{},r=T{},g=T{},b=T{}}
party_keys = S{'p0', 'p1', 'p2', 'p3', 'p4', 'p5'}
party_two_keys = S{'a10', 'a11', 'a12', 'a13', 'a14', 'a15'}
party_three_keys = S{'a20', 'a21', 'a22', 'a23', 'a24', 'a25'}
seeking_information=S{}
macro_order=T{cures=L{},curagas=L{},buffs=L{},nas=L{}}
position = {
    L{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    L{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    L{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
}
out_of_zone=S{}
out_of_range=S{}
who_am_i=S{}
packet_pt_struc = {[1]=S{},[2]=S{},[3]=S{}}

l={} r={} t={} b={}
region_map = {[1]='curagas',[2]='cures',[3]='cures',[4]='nas',[5]='buffs'}
local dragged = false
is_zoning = false
is_hidden = false
regions = 0

font_widths={
    ['I']=9,['II']=17,['III']=25,['IV']=24,['V']=16,['1']=10,['2']=11,['3']=11,
    ['4']=11,['5']=11,['6']=12
    }
xml_to_lua={
	["Cure"]="Cure",
    ["CureII"]="Cure II",
    ["CureIII"]="Cure III",
    ["CureIV"]="Cure IV",
    ["CureV"]="Cure V",
    ["CureVI"]="Cure VI",
    ["Curaga"]="Curaga",
    ["CuragaII"]="Curaga II",
    ["CuragaIII"]="Curaga III",
    ["CuragaIV"]="Curaga IV",
    ["CuragaV"]="Curaga V",
    ["Sacrifice"]="Sacrifice",
    ["Erase"]="Erase",
    ["Paralyna"]="Paralyna",
    ["Silena"]="Silena",
    ["Blindna"]="Blindna",
    ["Poisona"]="Poisona",
    ["Viruna"]="Viruna",
    ["Stona"]="Stona",
    ["Cursna"]="Cursna",
    ["Haste"]="Haste",
    ["HasteII"]="Haste II",
    ["Flurry"]="Flurry",
    ["FlurryII"]="Flurry II",
    ["Protect"]="Protect",
    ["Shell"]="Shell",
    ["ProtectII"]="Protect II",
    ["ShellII"]="Shell II",
    ["ProtectIII"]="Protect III",
    ["ShellIII"]="Shell III",
    ["ProtectIV"]="Protect IV",
    ["ShellIV"]="Shell IV",
    ["ProtectV"]="Protect V",
    ["ShellV"]="Shell V",
    ["Refresh"]="Refresh",
    ["RefreshII"]="Refresh II",
    ["Regen"]="Regen",
    ["RegenII"]="Regen II",
    ["RegenIII"]="Regen III",
    ["RegenIV"]="Regen IV",
    ["RegenV"]="Regen V",
    ["PhalanxII"]="Phalanx II",
    ["Adloquium"]="Adloquium",
    ["AnimusAugeo"]="Animus Augeo",
    ["AnimusMinuo"]="Animus Minuo",
    ["Embrava"]="Embrava",
}
options={}
options.cures={
    [1]="Cure",
    [2]="CureII",
    [3]="CureIII",
    [4]="CureIV",
    [5]="CureV",
    [6]="CureVI",
}
options.curagas={
    [7]="Curaga",
    [8]="CuragaII",
    [9]="CuragaIII",
    [10]="CuragaIV",
    [11]="CuragaV",
}
options.buffs=L{
    "Haste",
    "HasteII",
    "Flurry",
    "FlurryII",
    "Protect",
    "Shell",
    "ProtectII",
    "ShellII",
    "ProtectIII",
    "ShellIII",
    "ProtectIV",
    "ShellIV",
    "ProtectV",
    "ShellV",
    "Refresh",
    "RefreshII",
    "Regen",
    "RegenII",
    "RegenIII",
    "RegenIV",
    "RegenV",
    "PhalanxII",
    "Adloquium",
    "AnimusMinuo",
    "AnimusAugeo",
    "Embrava"
}

options.na=L{
"Erase",
"Paralyna",
"Silena",
"Blindna",
"Poisona",
"Viruna",
"Stona",
"Cursna",
"Sacrifice",
}
options.aliases={
["Cure"]="1",
["CureII"]="2",
["CureIII"]="3",
["CureIV"]="4",
["CureV"]="5",
["CureVI"]="6",
["Curaga"]="I",
["CuragaII"]="II",
["CuragaIII"]="III",
["CuragaIV"]="IV",
["CuragaV"]="V",
["Sacrifice"]="Sac",
["Erase"]="Eras",
["Paralyna"]="Para",
["Silena"]="Slna",
["Blindna"]="Blnd",
["Poisona"]="Psna",
["Viruna"]="Viru",
["Stona"]="Stna",
["Cursna"]="Curs",
["Haste"]="Haste",
["HasteII"]="Haste",
["Flurry"]="Flry",
["FlurryII"]="Flry",
["Protect"]="Pro",
["Shell"]="Shl",
["ProtectII"]="Pro",
["ShellII"]="Shl",
["ProtectIII"]="Pro",
["ShellIII"]="Shl",
["ProtectIV"]="Pro",
["ShellIV"]="Shl",
["ProtectV"]="Pro",
["ShellV"]="Shl",
["Refresh"]="Ref",
["RefreshII"]="Ref",
["Regen"]="Reg",
["RegenII"]="Reg",
["RegenIII"]="Reg",
["RegenIV"]="Reg",
["RegenV"]="Reg",
["PhalanxII"]="Phlx",
["Adloquium"]="TP+",
["AnimusAugeo"]="Enm+",
["AnimusMinuo"]="Enm-",
["Embrava"]="Embr",
}
options.images={
["Sacrifice"]="00294",--"00094",
["Erase"]="00294",--="00143",
["Paralyna"]="00289",--="00015",
["Silena"]="00290",--="00017",
["Blindna"]="00295",--="00016",
["Poisona"]="00293",--="00014",
["Viruna"]="00288",--="00019",
["Stona"]="00291",--="00018",
["Cursna"]="00292",--"00020",
["Haste"]="00057",
["HasteII"]="00358",
["Flurry"]="00056",
["FlurryII"]="00357",
["Protect"]="00043",
["ProtectII"]="00044",
["ProtectIII"]="00045",
["ProtectIV"]="00046",
["ProtectV"]="00047",
["Shell"]="00048",
["ShellII"]="00049",
["ShellIII"]="00050",
["ShellIV"]="00051",
["ShellV"]="00052",
["Refresh"]="00109",
["RefreshII"]="00473",
["Regen"]="00108",
["RegenII"]="00110",
["RegenIII"]="00111",
["RegenIV"]="00477",
["RegenV"]="00504",
["PhalanxII"]="00107",
["Adloquium"]="00495",
["AnimusAugeo"]="00308",
["AnimusMinuo"]="00309",
["Embrava"]="00478",
}

settings={
    text={
        buttons={
            bold=true,
            font="Times",
            visible=true,
            font_size=15,
            position={x=0,y=0},
            right_justified=false
        },
        name={
            bold=true,
            font="Consolas",
            font_size=10,
            position={x=0,y=0},
            right_justified=false
        },
        tp={
            bold=true,
            font="Consolas",
            font_size=10,
            position={x=0,y=0},
            right_justified=false
        },
        hp={
            bold=true,
            font="Consolas",
            font_size=10,
            right_justified=true
        },
        mp={
            bold=true,
            font="Consolas",
            font_size=10,
            right_justified=true    
        },
        hpp={
            bold=true,
            font="Times",
            font_size=20,
            right_justified=true
        },
        na={
            bold=true,
            font="Times",
            font_size=10,
            right_justified=false
        },
        buffs={
            bold=true,
            font="Times",
            font_size=9,
            right_justified=false,
        },
    },
    primitives={
        hp_bar={
            color={a=176, r=176, g=176, b=176},
            visible=true
        },
    },
    window={
        x_res=windower.get_windower_settings().x_res,
        y_res=windower.get_windower_settings().y_res,
    },
}

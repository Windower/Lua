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
spell_default=''
to_update=L{}

nos_saved_prims=S{}
nos_saved_texts=S{}
saved_images=S{}
prims_by_layer={[1]=T{},[2]=T{},[3]=T{},[4]=T{},[5]=T{},[6]=T{},[7]=T{},[8]=T{},[9]=T{},[10]=T{},[11]=T{},[12]=T{},[13]=T{},[14]=T{},[15]=T{},[16]=T{},[17]=T{},[18]=T{}}
texts_by_layer={[1]=T{},[2]=T{},[3]=T{},[4]=T{},[5]=T{},[6]=T{},[7]=T{},[8]=T{},[9]=T{},[10]=T{},[11]=T{},[12]=T{},[13]=T{},[14]=T{},[15]=T{},[16]=T{},[17]=T{},[18]=T{}}
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
out_of_zone=S{}
who_am_i=S{}
packet_pt_struc = {[1]=S{},[2]=S{},[3]=S{}}

l={} r={} t={} b={}
region_map = {[1]='curagas',[2]='cures',[3]='cures',[4]='nas',[5]='buffs'}
local dragged = false
is_zoning = false
is_hidden = false

font_widths={['I']=9,['II']=17,['III']=25,['IV']=24,['V']=16,['1']=10,['2']=11,['3']=11,['4']=11,['5']=11,['6']=12}
xml_to_lua={--config library doesn't like spaces
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
        color={a=255,r=255,g=255,b=255},
        bold=true,
        font="Times",
        font_size=15,
        position={x=0,y=0},
        visible=true,
        right_justified=false
    },
    name={
        color={a=255,r=255,g=255,b=255},
        bold=true,
        font="Consolas",
        font_size=10,
        position={x=0,y=0},
        visible=true,
        right_justified=false
    },
	tp={
	    color={a=255,r=255,g=255,b=255},
        bold=true,
        font="Consolas",
        font_size=10,
        position={x=0,y=0},
        visible=true,
        right_justified=false
	},
    hp={
        color={a=255,r=255,g=255,b=255},
        bold=true,
        font="Consolas",
        font_size=10,
        visible=true,
        right_justified=true
    },
	mp={
        color={a=255,r=255,g=255,b=255},
        bold=true,
        font="Consolas",
        font_size=10,
        visible=true,
        right_justified=true	
	},
    hpp={
        color={a=255,r=255,g=255,b=255},
        bold=true,
        font="Times",
        font_size=20,
        visible=true,
        right_justified=true
    },
	na={
        color={a=255,r=255,g=255,b=255},
        bold=true,
        font="Times",
        font_size=10,
        visible=false,
        right_justified=false
    },
	buffs={
        color={a=255,r=255,g=255,b=255},
        bold=true,
        font="Times",
        font_size=9,
        visible=false,
		right_justified=false,
	},
},
primitives={
    buttons={
        color={a=66, r=255, g=255, b=255},
        visible=true
    },
	highlight={
		color={a=100, r=255, g=255, b=255},
	},
    curaga_buttons={
        color={a=35, r=255, g=213, b=0},
        visible=true
    },
    background={
        color={a=150, r=0, g=0, b=0},
        visible=true
    },
    hp_bar={
		color={a=176, r=176, g=176, b=176},
		green={a=176, r=1, g=67, b=14},
		yellow={a=176, r=184,g=191,b=0},
		orange={a=176, r=249, g=125, b=1},
		red={a=176, r=141, g=1, b=1},
        visible=true
    },
    mp_bar={
        color={a=100, r=149, g=212, b=243},
        visible=true
    },
    hp_bar_background={
        color={a=155, r=0, g=0, b=0},
		visible=true
	},
	na_buttons={
		color={a=66, r=255, g=255, b=255},
		visible=true
	},
	buff_buttons={
		color={a=66, r=255, g=255, b=255},
		visible=true
	},
},
window={
	x_res=windower.get_windower_settings().x_res,
    y_res=windower.get_windower_settings().y_res,
},
profiles={
	default={
		["Cure"]=true,
		["CureII"]=true,
		["CureIII"]=true,
		["CureIV"]=true,
		["CureV"]=true,
		["CureVI"]=true,
		["Curaga"]=true,
		["CuragaII"]=true,
		["CuragaIII"]=true,
		["CuragaIV"]=true,
		["CuragaV"]=true,
		["Sacrifice"]=true,
		["Erase"]=true,
		["Paralyna"]=true,
		["Silena"]=true,
		["Blindna"]=true,
		["Poisona"]=true,
		["Viruna"]=true,
		["Stona"]=true,
		["Cursna"]=true,
		["Haste"]=true,
		["HasteII"]=false,
		["Flurry"]=false,
		["FlurryII"]=false,
		["Protect"]=false,
		["Shell"]=false,
		["ProtectII"]=false,
		["ShellII"]=false,
		["ProtectIII"]=false,
		["ShellIII"]=false,
		["ProtectIV"]=false,
		["ShellIV"]=false,
		["ProtectV"]=true,
		["ShellV"]=true,
		["Refresh"]=false,
		["RefreshII"]=false,
		["Regen"]=false,
		["RegenII"]=false,
		["RegenIII"]=false,
		["RegenIV"]=true,
		["RegenV"]=false,
		["PhalanxII"]=false,
		["Adloquium"]=false,
		["AnimusAugeo"]=false,
		["AnimusMinuo"]=false,
		["Embrava"]=false,

	},
},
}


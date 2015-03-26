--[[Copyright © 2014-2015, trv
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
tab_keys={[15]=true,[16]=true,[18]=true,[28]=true,[82]=true,[203]=true,[205]=true,[210]=true,}
spell_default=''
send_string = ''
to_update=L{}

saved_prims=S{}
saved_texts=S{}
prims_by_layer={L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{}}
texts_by_layer={L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{},L{}}
misc_hold_for_up={texts=T{},prims=T{}}
macro = {[1]=S{},[2]=S{},[3]=S{}}
macro_visibility = {[1]=true,[2]=true,[3]=true}
text_coordinates={x=T{},y=T{},visible=T{}}
prim_coordinates={x=T{},y=T{},visible=T{},a=T{},r=T{},g=T{},b=T{}}
party_keys = S{'p0', 'p1', 'p2', 'p3', 'p4', 'p5'}
party_two_keys = S{'a10', 'a11', 'a12', 'a13', 'a14', 'a15'}
party_three_keys = S{'a20', 'a21', 'a22', 'a23', 'a24', 'a25'}
seeking_information={}
macro_order=T{cures=L{},curagas=L{},buffs=L{},nas=L{}}
position = {
    L{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    L{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    L{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
}
out_of_zone={}
out_of_range={
    false,false,false,false,false,false,
    false,false,false,false,false,false,
    false,false,false,false,false,false,
}
out_of_view={
    false,false,false,false,false,false,
    false,false,false,false,false,false,
    false,false,false,false,false,false,
}
who_am_i={}
packet_pt_struc = {S{},S{},S{}}

l={} r={} t={} b={}
region_map = {[1]='curagas',[2]='cures',[3]='cures',[4]='nas',[5]='buffs'}
local dragged = false
is_zoning = false
is_hidden = false
regions = 0

font_widths={
    ['I']=9,['II']=17,['III']=25,['IV']=24,['V']=16,
    ['1']=10,['2']=11,['3']=11,['4']=11,['5']=11,['6']=12,
    ['˹1˼']=25,['˹2˼']=25,['˹3˼']=25,['˹4˼']=25,['˹5˼']=25,
    ['˹I˼']=23,['˹II˼']=31,
}
xml_to_lua={
	["cure"]="Cure",
    ["cureii"]="Cure II",
    ["cureiii"]="Cure III",
    ["cureiv"]="Cure IV",
    ["curev"]="Cure V",
    ["curevi"]="Cure VI",
    ["curaga"]="Curaga",
    ["curagaii"]="Curaga II",
    ["curagaiii"]="Curaga III",
    ["curagaiv"]="Curaga IV",
    ["curagav"]="Curaga V",
    ["sacrifice"]="Sacrifice",
    ["erase"]="Erase",
    ["paralyna"]="Paralyna",
    ["silena"]="Silena",
    ["blindna"]="Blindna",
    ["poisona"]="Poisona",
    ["viruna"]="Viruna",
    ["stona"]="Stona",
    ["cursna"]="Cursna",
    ["haste"]="Haste",
    ["hasteii"]="Haste II",
    ["flurry"]="Flurry",
    ["flurryii"]="Flurry II",
    ["protect"]="Protect",
    ["shell"]="Shell",
    ["protectii"]="Protect II",
    ["shellii"]="Shell II",
    ["protectiii"]="Protect III",
    ["shelliii"]="Shell III",
    ["protectiv"]="Protect IV",
    ["shelliv"]="Shell IV",
    ["protectv"]="Protect V",
    ["shellv"]="Shell V",
    ["refresh"]="Refresh",
    ["refreshii"]="Refresh II",
    ["regen"]="Regen",
    ["regenii"]="Regen II",
    ["regeniii"]="Regen III",
    ["regeniv"]="Regen IV",
    ["regenv"]="Regen V",
    ["phalanxii"]="Phalanx II",
    ["adloquium"]="Adloquium",
    ["animusaugeo"]="Animus Augeo",
    ["animusminuo"]="Animus Minuo",
    ["embrava"]="Embrava",
    ["curingwaltz"]="Curing Waltz",
    ["curingwaltzii"]="Curing Waltz II",
    ["curingwaltziii"]="Curing Waltz III",
    ["curingwaltziv"]="Curing Waltz IV",
    ["curingwaltzv"]="Curing Waltz V",
    ["divinewaltz"]="Divine Waltz",
    ["divinewaltzii"]="Divine Waltz II",
    ["healingwaltz"]="Healing Waltz",
}

prefix={
    ["Blindna"]='/ja',
    ["Poisona"]='/ma',
    ["Cure III"]='/ma',
    ["Curaga V"]='/ma',
    ["Sacrifice"]='/ma',
    ["Embrava"]='/ma',
    ["Curaga II"]='/ma',
    ["Stona"]='/ma',
    ["Protect III"]='/ma',
    ["Shell IV"]='/ma',
    ["Curaga IV"]='/ma',
    ["Paralyna"]='/ma',
    ["Protect"]='/ma',
    ["Phalanx II"]='/ma',
    ["Protect V"]='/ma',
    ["Curaga III"]='/ma',
    ["Adloquium"]='/ma',
    ["Divine Waltz II"]='/ja',
    ["Cure"]='/ma',
    ["Divine Waltz"]='/ja',
    ["Curing Waltz V"]='/ja',
    ["Cure II"]='/ma',
    ["Erase"]='/ma',
    ["Cure VI"]='/ma',
    ["Haste II"]='/ma',
    ["Curing Waltz"]='/ja',
    ["Animus Augeo"]='/ma',
    ["Curing Waltz III"]='/ja',
    ["Cure IV"]='/ma',
    ["Regen II"]='/ma',
    ["Animus Minuo"]='/ma',
    ["Curing Waltz IV"]='/ja',
    ["Cure V"]='/ma',
    ["Regen V"]='/ma',
    ["Regen"]='/ma',
    ["Refresh"]='/ma',
    ["Regen IV"]='/ma',
    ["Viruna"]='/ma',
    ["Haste"]='/ma',
    ["Curing Waltz II"]='/ja',
    ["Healing Waltz"]='/ja',
    ["Protect IV"]='/ma',
    ["Cursna"]='/ma',
    ["Silena"]='/ma',
    ["Curaga"]='/ma',
    ["Shell II"]='/ma',
    ["Refresh II"]='/ma',
    ["Shell"]='/ma',
    ["Protect II"]='/ma',
    ["Shell III"]='/ma',
    ["Flurry II"]='/ma',
    ["Flurry"]='/ma',
    ["Regen III"]='/ma',
    ["Shell V"]='/ma',
}

options={
    cures={
        [1]="cure",
        [2]="cureii",
        [3]="cureiii",
        [4]="cureiv",
        [5]="curev",
        [6]="curevi",
        [7]="curingwaltz",
        [8]="curingwaltzii",
        [9]="curingwaltziii",
        [10]="curingwaltziv",
        [11]="curingwaltzv",
    },
    curagas={
        [12]="curaga",
        [13]="curagaii",
        [14]="curagaiii",
        [15]="curagaiv",
        [16]="curagav",
        [17]="divinewaltz",
        [18]="divinewaltzii",
    },
    buffs=L{
        "haste",
        "hasteii",
        "flurry",
        "flurryii",
        "protect",
        "shell",
        "protectii",
        "shellii",
        "protectiii",
        "shelliii",
        "protectiv",
        "shelliv",
        "protectv",
        "shellv",
        "refresh",
        "refreshii",
        "regen",
        "regenii",
        "regeniii",
        "regeniv",
        "regenv",
        "phalanxii",
        "adloquium",
        "animusminuo",
        "animusaugeo",
        "embrava"
    },
    na=L{
        "erase",
        "paralyna",
        "silena",
        "blindna",
        "poisona",
        "viruna",
        "stona",
        "cursna",
        "sacrifice",
        "healingwaltz",
    },
    aliases={
        ["cure"]="1",
        ["cureii"]="2",
        ["cureiii"]="3",
        ["cureiv"]="4",
        ["curev"]="5",
        ["curevi"]="6",
        ["curaga"]="I",
        ["curagaii"]="II",
        ["curagaiii"]="III",
        ["curagaiv"]="IV",
        ["curagav"]="V",
        ["sacrifice"]="Sac",
        ["erase"]="Eras",
        ["paralyna"]="Para",
        ["silena"]="Slna",
        ["blindna"]="Blnd",
        ["poisona"]="Psna",
        ["viruna"]="Viru",
        ["stona"]="Stna",
        ["cursna"]="Curs",
        ["haste"]="Haste",
        ["hasteii"]="Haste",
        ["flurry"]="Flry",
        ["flurryii"]="Flry",
        ["protect"]="Pro",
        ["shell"]="Shl",
        ["protectii"]="Pro",
        ["shellii"]="Shl",
        ["protectiii"]="Pro",
        ["shelliii"]="Shl",
        ["protectiv"]="Pro",
        ["shelliv"]="Shl",
        ["protectv"]="Pro",
        ["shellv"]="Shl",
        ["refresh"]="Ref",
        ["refreshii"]="Ref",
        ["regen"]="Reg",
        ["regenii"]="Reg",
        ["regeniii"]="Reg",
        ["regeniv"]="Reg",
        ["regenv"]="Reg",
        ["phalanxii"]="Phlx",
        ["adloquium"]="TP+",
        ["animusaugeo"]="Enm+",
        ["animusminuo"]="Enm-",
        ["embrava"]="Embr",
        ["curingwaltz"]="˹1˼",
        ["curingwaltzii"]="˹2˼",
        ["curingwaltziii"]="˹3˼",
        ["curingwaltziv"]="˹4˼",
        ["curingwaltzv"]="˹5˼",
        ["divinewaltz"]="˹I˼",
        ["divinewaltzii"]="˹II˼",
        ["healingwaltz"]="HW",
    },
    images={
        ["sacrifice"]="spells\\00294.png",
        ["erase"]="spells\\00294.png",
        ["paralyna"]="spells\\00289.png",
        ["silena"]="spells\\00290.png",
        ["blindna"]="spells\\00295.png",
        ["poisona"]="spells\\00293.png",
        ["viruna"]="spells\\00288.png",
        ["stona"]="spells\\00291.png",
        ["cursna"]="spells\\00292.png",
        ["haste"]="spells\\00057.png",
        ["hasteii"]="spells\\00358.png",
        ["flurry"]="spells\\00056.png",
        ["flurryii"]="spells\\00357.png",
        ["protect"]="spells\\00043.png",
        ["protectii"]="spells\\00044.png",
        ["protectiii"]="spells\\00045.png",
        ["protectiv"]="spells\\00046.png",
        ["protectv"]="spells\\00047.png",
        ["shell"]="spells\\00048.png",
        ["shellii"]="spells\\00049.png",
        ["shelliii"]="spells\\00050.png",
        ["shelliv"]="spells\\00051.png",
        ["shellv"]="spells\\00052.png",
        ["refresh"]="spells\\00109.png",
        ["refreshii"]="spells\\00473.png",
        ["regen"]="spells\\00108.png",
        ["regenii"]="spells\\00110.png",
        ["regeniii"]="spells\\00111.png",
        ["regeniv"]="spells\\00477.png",
        ["regenv"]="spells\\00504.png",
        ["phalanxii"]="spells\\00107.png",
        ["adloquium"]="spells\\00495.png",
        ["animusaugeo"]="spells\\00308.png",
        ["animusminuo"]="spells\\00309.png",
        ["embrava"]="spells\\00478.png",
        ["healingwaltz"]="abilities\\00215.png",
    },
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

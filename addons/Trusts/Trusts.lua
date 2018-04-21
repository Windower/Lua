_addon.name='Trusts'
_addon.author='from20020516'
_addon.version='1.0'
_addon.commands={'trusts','tru'}
res,config,math=require('resources'),require('config'),require('math')
settings=config.load('data/settings.xml')
_addon.language=settings.language
lang={['english']='en',['japanese']='ja'}[string.lower(settings.language)]
function command(arg1,arg2)
    if not cap then
        for i,v in pairs(windower.ffxi.get_key_items()) do
            cap = S{2497,2499,2501}:contains(v) and 3 or v==2884 and 4 or v==2886 and 5 or cap or 0
        end
        if cap == 0 then
            windower.add_to_chat(38,_addon.name..' Error: And nobody loves you.')
            return true;
        end
    end
    if S{'rand','r'}[arg1] then
        call_set('rand')
    elseif S{'retr','refa'}[arg1] then
        windower.send_command('input /retr all')
    elseif S{'save','s'}[arg1] then
        save_set(arg2)
    elseif S{'check','c'}[arg1] then
        check_learned()
    else
        call_set(settings.sets[arg1] and arg1 or 'default')
    end
end
windower.register_event('addon command', command)
function save_set(set)
settings.sets[set],ti={},0
    for i=1,5 do
        local v = windower.ffxi.get_party()['p'..i]
        if v and v.mob.spawn_type == 14 then
            ti = ti+1
            settings.sets[set][ti]=trusts:with('name',v.name)[lang]
        end
    end
    settings:save('all')
    windower.add_to_chat(208,_addon.name..': set '..set..' saved.')
end
function check_exist()
local tn,ct,cp={},0,0
    for i=0,5 do
        local v = windower.ffxi.get_party()['p'..i]
        if v then
            if v.mob.spawn_type == 14 then
                tn[v.name]= v.mob.models[1]
                ct=ct+1
            else
                cp=cp+1
            end
        end
    end
    return {tn,ct,cp};
end
function check_lang(entity)
    return {ja=windower.to_shift_jis(entity.ja),en=entity.en}[lang];
end
function call_trust()
    if #Q > 0 then
        windower.send_command('input /ma "'..check_lang(Q[1])..'" <me>')
    end
end
function call_set(set)
Q,invalid,time={},{},false
    if set == 'rand' then
        math.randomseed(os.clock())
        local party,npcs,pcs = unpack(check_exist())
        if cap == npcs then
            windower.send_command('input /retr all')
            calls,time = npcs,os.clock()
        else
            calls = math.min(cap-npcs,6-npcs-pcs)
        end
        repeat
            local index = trusts[{math.random(1,#trusts),math.random(1,#trusts)}[2]]
            if index and not table.find(invalid,index.name) then
                table.insert(invalid,index.name)
                if windower.ffxi.get_spells()[index.id] and windower.ffxi.get_spell_recasts()[index.id] == 0 then
                    table.insert(Q,index)
                end
            end
        until #Q == calls or #invalid == #trusts
    elseif settings.sets[set] then
        local party,npcs,pcs = unpack(check_exist())
        local retr = npcs
        for i=1,cap do
            if settings.sets[set][tostring(i)] then
                local entity,pos = trusts:with(lang,settings.sets[set][tostring(i)]),i+pcs-1
                if not party[entity.name]
                or party[entity.name] ~= entity.models then
                    if windower.ffxi.get_spell_recasts()[entity.id] == 0 then
                        if windower.ffxi.get_spells()[entity.id] then
                            table.insert(Q,entity)
                        else
                            windower.add_to_chat(38,_addon.name..' error: You aren\'t trusted by '..entity.en..'.')
                        end
                    else
                        local recasts = math.floor(windower.ffxi.get_spell_recasts()[entity.id]/6)/10
                        windower.add_to_chat(208,_addon.name..': '..entity.en..' needs '..recasts..' secs break.')
                        if windower.ffxi.get_party()['p'..pos] then
                            party[windower.ffxi.get_party()['p'..pos].name],retr = nil,retr-1
                        end
                    end
                else
                    party[entity.name],retr = nil,retr-1
                    if settings.auto then
                        windower.add_to_chat(208,_addon.name..': '..entity.en..' already exists.')
                    end
                end
            end
        end
        time = os.clock()
        for name,v in pairs(party) do
            if retr == npcs then
                windower.send_command('input /retr all')
                break;
            else
                windower.send_command('input /retr '..name)
                coroutine.sleep(settings.wait.retr)
            end
        end
    end
    time = time and math.max(0,settings.wait.retrall+time-os.clock()) or 0
    coroutine.schedule(call_trust,time)
end
windower.register_event('action', function(act)
    if settings.auto and act.actor_id == windower.ffxi.get_player().id and Q and #Q > 0 then
        if act.category == 4 and act.param == table.remove(Q,1).id then
            coroutine.schedule(call_trust,settings.wait.aftercast)
        elseif act.category == 8 and act.param == 28787 and act.targets[1].actions[1].param == Q[1].id then
            coroutine.schedule(call_trust,settings.wait.aftercast)
        end
    end
end)
function check_learned()
learned = {}
    for i,v in ipairs(trusts) do
        if windower.ffxi.get_spells()[v.id] == false and not v.en:endswith('(UC)') then
            table.insert(learned,v.id)
            windower.add_to_chat(208,_addon.name..': '..check_lang(v))
        end
    end
    windower.add_to_chat(208,_addon.name..': You haven\'t trusted yet from '..#learned..' trusts.')
end
trusts = T{
[1]={id=896,ja="シャントット",en="Shantotto",name="Shantotto",models=3000},
[2]={id=897,ja="ナジ",en="Naji",name="Naji",models=3001},
[3]={id=898,ja="クピピ",en="Kupipi",name="Kupipi",models=3002},
[4]={id=899,ja="エグセニミル",en="Excenmille",name="Excenmille",models=3003},
[5]={id=900,ja="アヤメ",en="Ayame",name="Ayame",models=3004},
[6]={id=901,ja="ナナー・ミーゴ",en="Nanaa Mihgo",name="NanaaMihgo",models=3005},
[7]={id=902,ja="クリルラ",en="Curilla",name="Curilla",models=3006},
[8]={id=903,ja="フォルカー",en="Volker",name="Volker",models=3007},
[9]={id=904,ja="アジドマルジド",en="Ajido-Marujido",name="Ajido-Marujido",models=3008},
[10]={id=905,ja="トリオン",en="Trion",name="Trion",models=3009},
[11]={id=906,ja="ザイド",en="Zeid",name="Zeid",models=3010},
[12]={id=907,ja="ライオン",en="Lion",name="Lion",models=3011},
[13]={id=908,ja="テンゼン",en="Tenzen",name="Tenzen",models=3012},
[14]={id=909,ja="ミリ・アリアポー",en="Mihli Aliapoh",name="MihliAliapoh",models=3013},
[15]={id=910,ja="ヴァレンラール",en="Valaineral",name="Valaineral",models=3014},
[16]={id=911,ja="ヨアヒム",en="Joachim",name="Joachim",models=3015},
[17]={id=912,ja="ナジャ・サラヒム",en="Naja Salaheem",name="NajaSalaheem",models=3016},
[18]={id=913,ja="プリッシュ",en="Prishe",name="Prishe",models=3017},
[19]={id=914,ja="ウルミア",en="Ulmia",name="Ulmia",models=3018},
[20]={id=915,ja="スカリーZ",en="Shikaree Z",name="ShikareeZ",models=3019},
[21]={id=916,ja="チェルキキ",en="Cherukiki",name="Cherukiki",models=3020},
[22]={id=917,ja="アイアンイーター",en="Iron Eater",name="IronEater",models=3021},
[23]={id=918,ja="ゲッショー",en="Gessho",name="Gessho",models=3022},
[24]={id=919,ja="ガダラル",en="Gadalar",name="Gadalar",models=3023},
[25]={id=920,ja="ライニマード",en="Rainemard",name="Rainemard",models=3024},
[26]={id=921,ja="イングリッド",en="Ingrid",name="Ingrid",models=3025},
[27]={id=922,ja="レコ・ハボッカ",en="Lehko Habhoka",name="LehkoHabhoka",models=3026},
[28]={id=923,ja="ナシュメラ",en="Nashmeira",name="Nashmeira",models=3027},
[29]={id=924,ja="ザザーグ",en="Zazarg",name="Zazarg",models=3028},
[30]={id=925,ja="アヴゼン",en="Ovjang",name="Ovjang",models=3029},
[31]={id=926,ja="メネジン",en="Mnejing",name="Mnejing",models=3030},
[32]={id=927,ja="サクラ",en="Sakura",name="Sakura",models=3031},
[33]={id=928,ja="ルザフ",en="Luzaf",name="Luzaf",models=3032},
[34]={id=929,ja="ナジュリス",en="Najelith",name="Najelith",models=3033},
[35]={id=930,ja="アルド",en="Aldo",name="Aldo",models=3034},
[36]={id=931,ja="モーグリ",en="Moogle",name="Moogle",models=3035},
[37]={id=932,ja="ファブリニクス",en="Fablinix",name="Fablinix",models=3036},
[38]={id=933,ja="マート",en="Maat",name="Maat",models=3037},
[39]={id=934,ja="D.シャントット",en="D. Shantotto",name="D.Shantotto",models=3038},
[40]={id=935,ja="星の神子",en="Star Sibyl",name="StarSibyl",models=3039},
[41]={id=936,ja="カラハバルハ",en="Karaha-Baruha",name="Karaha-Baruha",models=3040},
[42]={id=937,ja="シド",en="Cid",name="Cid",models=3041},
[43]={id=938,ja="ギルガメッシュ",en="Gilgamesh",name="Gilgamesh",models=3042},
[44]={id=939,ja="アレヴァト",en="Areuhat",name="Areuhat",models=3043},
[45]={id=940,ja="セミ・ラフィーナ",en="Semih Lafihna",name="SemihLafihna",models=3044},
[46]={id=941,ja="エリヴィラ",en="Elivira",name="Elivira",models=3045},
[47]={id=942,ja="ノユリ",en="Noillurie",name="Noillurie",models=3046},
[48]={id=943,ja="ルー・マカラッカ",en="Lhu Mhakaracca",name="LhuMhakaracca",models=3047},
[49]={id=944,ja="フェリアスコフィン",en="Ferreous Coffin",name="FerreousCoffin",models=3048},
[50]={id=945,ja="リリゼット",en="Lilisette",name="Lilisette",models=3049},
[51]={id=946,ja="ミュモル",en="Mumor",name="Mumor",models=3050},
[52]={id=947,ja="ウカ・トトゥリン",en="Uka Totlihn",name="UkaTotlihn",models=3051},
[53]={id=948,ja="クララ",en="Klara",name="Klara",models=3053},
[54]={id=949,ja="ロマー・ミーゴ",en="Romaa Mihgo",name="RomaaMihgo",models=3054},
[55]={id=950,ja="クイン・ハスデンナ",en="Kuyin Hathdenna",name="KuyinHathdenna",models=3055},
[56]={id=951,ja="ラーアル",en="Rahal",name="Rahal",models=3056},
[57]={id=952,ja="コルモル",en="Koru-Moru",name="Koru-Moru",models=3057},
[58]={id=953,ja="ピエージェ(UC)",en="Pieuje (UC)",name="Pieuje",models=3058},
[59]={id=954,ja="I.シールド(UC)",en="I. Shield (UC)",name="I.Shield",models=3059},
[60]={id=955,ja="アプルル(UC)",en="Apururu (UC)",name="Apururu",models=3060},
[61]={id=956,ja="ジャコ(UC)",en="Jakoh (UC)",name="Jakoh",models=3061},
[62]={id=957,ja="フラヴィリア(UC)",en="Flaviria (UC)",name="Flaviria",models=3062},
[63]={id=958,ja="ウェイレア",en="Babban",name="Babban",models=3067},
[64]={id=959,ja="アベンツィオ",en="Abenzio",name="Abenzio",models=3068},
[65]={id=960,ja="ルガジーン",en="Rughadjeen",name="Rughadjeen",models=3069},
[66]={id=961,ja="クッキーチェブキー",en="Kukki-Chebukki",name="Kukki-Chebukki",models=3070},
[67]={id=962,ja="マルグレート",en="Margret",name="Margret",models=3071},
[68]={id=963,ja="チャチャルン",en="Chacharoon",name="Chacharoon",models=3072},
[69]={id=964,ja="レイ・ランガヴォ",en="Lhe Lhangavo",name="LheLhangavo",models=3073},
[70]={id=965,ja="アシェラ",en="Arciela",name="Arciela",models=3074},
[71]={id=966,ja="マヤコフ",en="Mayakov",name="Mayakov",models=3075},
[72]={id=967,ja="クルタダ",en="Qultada",name="Qultada",models=3076},
[73]={id=968,ja="アーデルハイト",en="Adelheid",name="Adelheid",models=3077},
[74]={id=969,ja="アムチュチュ",en="Amchuchu",name="Amchuchu",models=3078},
[75]={id=970,ja="ブリジッド",en="Brygid",name="Brygid",models=3079},
[76]={id=971,ja="ミルドリオン",en="Mildaurion",name="Mildaurion",models=3080},
[77]={id=972,ja="ハルヴァー",en="Halver",name="Halver",models=3087},
[78]={id=973,ja="ロンジェルツ",en="Rongelouts",name="Rongelouts",models=3088},
[79]={id=974,ja="レオノアーヌ",en="Leonoyne",name="Leonoyne",models=3089},
[80]={id=975,ja="マクシミリアン",en="Maximilian",name="Maximilian",models=3090},
[81]={id=976,ja="カイルパイル",en="Kayeel-Payeel",name="Kayeel-Payeel",models=3091},
[82]={id=977,ja="ロベルアクベル",en="Robel-Akbel",name="Robel-Akbel",models=3092},
[83]={id=978,ja="クポフリート",en="Kupofried",name="Kupofried",models=3093},
[84]={id=979,ja="セルテウス",en="Selh\'teus",name="Selh\'teus",models=3094},
[85]={id=980,ja="ヨランオラン(UC)",en="Yoran-Oran (UC)",name="Yoran-Oran",models=3095},
[86]={id=981,ja="シルヴィ(UC)",en="Sylvie (UC)",name="Sylvie",models=3096},
[87]={id=982,ja="アブクーバ",en="Abquhbah",name="Abquhbah",models=3098},
[88]={id=983,ja="バラモア",en="Balamor",name="Balamor",models=3099},
[89]={id=984,ja="オーグスト",en="August",name="August",models=3100},
[90]={id=985,ja="ロスレーシャ",en="Rosulatia",name="Rosulatia",models=3101},
[91]={id=986,ja="テオドール",en="Teodor",name="Teodor",models=3103},
[92]={id=987,ja="ウルゴア",en="Ullegore",name="Ullegore",models=3105},
[93]={id=988,ja="マッキーチェブキー",en="Makki-Chebukki",name="Makki-Chebukki",models=3106},
[94]={id=989,ja="キング・オブ・ハーツ",en="King of Hearts",name="KingOfHearts",models=3107},
[95]={id=990,ja="モリマー",en="Morimar",name="Morimar",models=3108},
[96]={id=991,ja="ダラクァルン",en="Darrcuiln",name="Darrcuiln",models=3109},
[97]={id=992,ja="アークHM",en="AAHM",name="ArkHM",models=3113},
[98]={id=993,ja="アークEV",en="AAEV",name="ArkEV",models=3114},
[99]={id=994,ja="アークMR",en="AAMR",name="ArkMR",models=3115},
[100]={id=995,ja="アークTT",en="AATT",name="ArkTT",models=3116},
[101]={id=996,ja="アークGK",en="AAGK",name="ArkGK",models=3117},
[102]={id=997,ja="イロハ",en="Iroha",name="Iroha",models=3111},
[103]={id=998,ja="ユグナス",en="Ygnas",name="Ygnas",models=3118},
[104]={id=1003,ja="コーネリア",en="Cornelia",name="Cornelia",models=3119},
[105]={id=1004,ja="エグセニミルII",en="Excenmille [S]",name="Excenmille",models=3052},
[106]={id=1005,ja="アヤメ(UC)",en="Ayame (UC)",name="Ayame",models=3063},
[107]={id=1006,ja="マート(UC)",en="Maat (UC)",name="Maat",models=3064},
[108]={id=1007,ja="アルド(UC)",en="Aldo (UC)",name="Aldo",models=3065},
[109]={id=1008,ja="ナジャ(UC)",en="Naja (UC)",name="Naja",models=3066},
[110]={id=1009,ja="ライオンII",en="Lion II",name="Lion",models=3081},
[111]={id=1010,ja="ザイドII",en="Zeid II",name="Zeid",models=3086},
[112]={id=1011,ja="プリッシュII",en="Prishe II",name="Prishe",models=3082},
[113]={id=1012,ja="ナシュメラII",en="Nashmeira II",name="Nashmeira",models=3083},
[114]={id=1013,ja="リリゼットII",en="Lilisette II",name="Lilisette",models=3084},
[115]={id=1014,ja="テンゼンII",en="Tenzen II",name="Tenzen",models=3097},
[116]={id=1015,ja="ミュモルII",en="Mumor II",name="Mumor",models=3104},
[117]={id=1016,ja="イングリッドII",en="Ingrid II",name="Ingrid",models=3102},
[118]={id=1017,ja="アシェラII",en="Arciela II",name="Arciela",models=3085},
[119]={id=1018,ja="イロハII",en="Iroha II",name="Iroha",models=3112},
[120]={id=1019,ja="シャントットII",en="Shantotto II",name="Shantotto",models=3110},
},{"id","en","name","models"}
--[[
Copyright © 2018, from20020516
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of checkparam nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL from20020516 BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
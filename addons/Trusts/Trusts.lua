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
    * Neither the name of Trusts nor the
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
_addon.name='Trusts'
_addon.author='from20020516'
_addon.version='1.1'
_addon.commands={'trusts','tru'}

config = require('config')
math = require('math')
math.randomseed(os.clock())
require('logger')

windower.register_event('load',function()
    defaults = {
        auto=true,
        language=windower.ffxi.get_info().language,
        sets={
            ['default']={
                English={
                    ['1']='Valaineral',
                    ['2']='Mihli Aliapoh',
                    ['3']='Tenzen',
                    ['4']='Adelheid',
                    ['5']='Joachim'},
                Japanese={
                    ['1']='ヴァレンラール',
                    ['2']='ミリ・アリアポー',
                    ['3']='テンゼン',
                    ['4']='アーデルハイト',
                    ['5']='ヨアヒム'}}[windower.ffxi.get_info().language]},
        wait={
            ['aftercast']=3,
            ['retr']=1.25,
            ['retrall']=3},}
    settings = config.load(defaults)
    lang = string.lower(settings.language)
    player = windower.ffxi.get_player()
end)

windower.register_event('login',function()
    player = windower.ffxi.get_player()
end)

windower.register_event('addon command',function(...)
    cmd = {...}
    if cmd[1] == 'help' then
        local chat = windower.add_to_chat
        local color = string.color
        chat(1,'Trusts - Command List:')
        chat(207,'//tru '..color('save <setname>',166,160)..' --Save trusts in current party.')
        chat(207,'//tru '..color('<setname>',166,160)..' --Calls trusts you saved.')
        chat(207,'//tru '..color('list',166,160)..' --Lists your saved sets.')
        chat(207,'//tru '..color('random',166,160)..' --What\'s your fortune today?')
        chat(207,'//tru '..color('check',166,160)..' --List of unlearned trusts. gotta catch \'em all!')
    elseif cmd[1] == 'save' then
        save_set(cmd[2])
    elseif cmd[1] == 'check' then
        check_learned()
    elseif cmd[1] == 'list' then
        list_sets()
    else
        call_set(cmd[1] or 'default')
    end
end)

function save_set(set)
    settings.sets[set] = {}
    local trust_ind = 0
    local get_party = windower.ffxi.get_party()
    for i=1,5 do
        local trust = get_party['p'..i]
        if trust and trust.mob.spawn_type == 14 then
            trust_ind = trust_ind + 1
            settings.sets[set][tostring(trust_ind)]=trusts:with('models',trust.mob.models[1])[lang]
        end
    end
    settings:save('all')
    log('set '..set..' saved.')
end

function list_sets()
    local chat = windower.add_to_chat
    settings = config.load()
    chat(1, 'Trusts - Saved sets:')

    for set, _ in pairs(settings.sets) do
        if set ~= 'default' then
            chat(207, set)
        end
    end
end

function check_lang(entity)
    return {japanese=entity.japanese,english=entity.english}[lang];
end

function check_limit()
    for i,v in pairs(windower.ffxi.get_key_items()) do
        --Trust permit,Rhapsody in..
        limit = S{2497,2499,2501}[v] and 3 or v==2884 and 4 or v==2886 and 5 or limit or 0
    end
    return limit;
end

function call_trust()
    if #queue > 0 then
        windower.chat.input('/ma "'..windower.to_shift_jis(check_lang(queue[1]))..'" <me>')
    end
end

function check_exist()
    local party = {} --include only trusts. --['name']=models
    local party_ind = {} -- index of trust's name in current party. {'name1','name2',...,'name5'}
    local get_party = windower.ffxi.get_party()
    for i=1,5 do
        local member = get_party['p'..i]
        if member then
            if member.mob.spawn_type == 14 then
                party[member.name] = member.mob.models[1]
                table.insert(party_ind,member.name)
            end
        end
    end
    return {party,party_ind};
end

function call_set(set)
    queue = {} --trusts to be cast.
    settings = config.load()
    local party,party_ind = unpack(check_exist())
    local limit = check_limit() --upper limit # of calls trust in current player.
    local time = os.clock() --window open
    local get_spells = windower.ffxi.get_spells()
    local get_spell_recasts = windower.ffxi.get_spell_recasts()

    if set == 'random' then
        local checked = {}
        local others = windower.ffxi.get_party().party1_count - #party_ind - 1 --# of human in party exept <me>.

        if limit == #party_ind then
            windower.chat.input('/retr all')
            calls = limit
            coroutine.sleep(settings.wait.retrall)
        else
            calls = limit - #party_ind - others
        end

        repeat
            local index = trusts[math.random(1,#trusts)]
            if not table.find(checked,index.name) then
                table.insert(checked,index.name)
                if get_spells[index.id] and get_spell_recasts[index.id] == 0 then
                    table.insert(queue,index)
                end
            end
        until #queue >= calls or #checked >= 103 --# of unique names w/o Cornelia

    elseif settings.sets[set] then
        retr = {unpack(party_ind)}
        for i=1,limit do
            if settings.sets[set][tostring(i)] then
                local entity = trusts:with(lang,settings.sets[set][tostring(i)])
                if not party[entity.name]
                or party[entity.name] ~= entity.models then
                    if get_spell_recasts[entity.id] == 0 then
                        if get_spells[entity.id] then
                            table.insert(queue,entity)
                        else
                            table.remove(retr,table.find(retr,party_ind[i]))
                            error('You aren\'t trusted by '..entity.english..'.')
                        end
                    else
                        table.remove(retr,table.find(retr,party_ind[i]))
                        local recast = math.floor(get_spell_recasts[entity.id] / 6) / 10
                        log(entity.english..' needs '..recast..' secs break.')
                    end
                else
                    table.remove(retr,table.find(retr,entity.name))
                    if settings.auto then
                        log(entity.english..' already exists.')
                    end
                end
            end
        end
        for index,name in pairs(retr) do
            if #retr == #party_ind then
                windower.chat.input('/retr all')
                coroutine.sleep(settings.wait.retrall)
                break;
            else
                windower.chat.input('/retr '..name)
                coroutine.sleep(settings.wait.retr)
            end
        end
    else
        error('Unknown set name '..(set or ''))
    end
    --if /retr then wait at least 3secs.
    local delay = (limit - #party_ind) == 0 and math.max(0,settings.wait.retrall + time - os.clock()) or 0
    coroutine.schedule(call_trust,delay)
end

windower.register_event('action', function(act)
    if settings.auto and act.actor_id == player.id and queue and #queue > 0 then
        if act.category == 4 and act.param == table.remove(queue,1).id then
            coroutine.schedule(call_trust,settings.wait.aftercast)
        elseif act.category == 8 and act.param == 28787 and act.targets[1].actions[1].param == queue[1].id then
            coroutine.schedule(call_trust,settings.wait.aftercast)
        end
    end
end)

function check_learned()
    local learned = {}
    local get_spells = windower.ffxi.get_spells()
    for i,value in ipairs(trusts) do
        if get_spells[value.id] == false and not value.english:endswith('(UC)') then
            table.insert(learned,value.id)
            log(check_lang(value))
        end
    end
    log('You haven\'t trusted yet from '..#learned..' trusts.')
end

trusts = T{
    [1]={id=896,japanese="シャントット",english="Shantotto",name="Shantotto",models=3000},
    [2]={id=897,japanese="ナジ",english="Naji",name="Naji",models=3001},
    [3]={id=898,japanese="クピピ",english="Kupipi",name="Kupipi",models=3002},
    [4]={id=899,japanese="エグセニミル",english="Excenmille",name="Excenmille",models=3003},
    [5]={id=900,japanese="アヤメ",english="Ayame",name="Ayame",models=3004},
    [6]={id=901,japanese="ナナー・ミーゴ",english="Nanaa Mihgo",name="NanaaMihgo",models=3005},
    [7]={id=902,japanese="クリルラ",english="Curilla",name="Curilla",models=3006},
    [8]={id=903,japanese="フォルカー",english="Volker",name="Volker",models=3007},
    [9]={id=904,japanese="アジドマルジド",english="Ajido-Marujido",name="Ajido-Marujido",models=3008},
    [10]={id=905,japanese="トリオン",english="Trion",name="Trion",models=3009},
    [11]={id=906,japanese="ザイド",english="Zeid",name="Zeid",models=3010},
    [12]={id=907,japanese="ライオン",english="Lion",name="Lion",models=3011},
    [13]={id=908,japanese="テンゼン",english="Tenzen",name="Tenzen",models=3012},
    [14]={id=909,japanese="ミリ・アリアポー",english="Mihli Aliapoh",name="MihliAliapoh",models=3013},
    [15]={id=910,japanese="ヴァレンラール",english="Valaineral",name="Valaineral",models=3014},
    [16]={id=911,japanese="ヨアヒム",english="Joachim",name="Joachim",models=3015},
    [17]={id=912,japanese="ナジャ・サラヒム",english="Naja Salaheem",name="NajaSalaheem",models=3016},
    [18]={id=913,japanese="プリッシュ",english="Prishe",name="Prishe",models=3017},
    [19]={id=914,japanese="ウルミア",english="Ulmia",name="Ulmia",models=3018},
    [20]={id=915,japanese="スカリーZ",english="Shikaree Z",name="ShikareeZ",models=3019},
    [21]={id=916,japanese="チェルキキ",english="Cherukiki",name="Cherukiki",models=3020},
    [22]={id=917,japanese="アイアンイーター",english="Iron Eater",name="IronEater",models=3021},
    [23]={id=918,japanese="ゲッショー",english="Gessho",name="Gessho",models=3022},
    [24]={id=919,japanese="ガダラル",english="Gadalar",name="Gadalar",models=3023},
    [25]={id=920,japanese="ライニマード",english="Rainemard",name="Rainemard",models=3024},
    [26]={id=921,japanese="イングリッド",english="Ingrid",name="Ingrid",models=3025},
    [27]={id=922,japanese="レコ・ハボッカ",english="Lehko Habhoka",name="LehkoHabhoka",models=3026},
    [28]={id=923,japanese="ナシュメラ",english="Nashmeira",name="Nashmeira",models=3027},
    [29]={id=924,japanese="ザザーグ",english="Zazarg",name="Zazarg",models=3028},
    [30]={id=925,japanese="アヴゼン",english="Ovjang",name="Ovjang",models=3029},
    [31]={id=926,japanese="メネジン",english="Mnejing",name="Mnejing",models=3030},
    [32]={id=927,japanese="サクラ",english="Sakura",name="Sakura",models=3031},
    [33]={id=928,japanese="ルザフ",english="Luzaf",name="Luzaf",models=3032},
    [34]={id=929,japanese="ナジュリス",english="Najelith",name="Najelith",models=3033},
    [35]={id=930,japanese="アルド",english="Aldo",name="Aldo",models=3034},
    [36]={id=931,japanese="モーグリ",english="Moogle",name="Moogle",models=3035},
    [37]={id=932,japanese="ファブリニクス",english="Fablinix",name="Fablinix",models=3036},
    [38]={id=933,japanese="マート",english="Maat",name="Maat",models=3037},
    [39]={id=934,japanese="D.シャントット",english="D. Shantotto",name="D.Shantotto",models=3038},
    [40]={id=935,japanese="星の神子",english="Star Sibyl",name="StarSibyl",models=3039},
    [41]={id=936,japanese="カラハバルハ",english="Karaha-Baruha",name="Karaha-Baruha",models=3040},
    [42]={id=937,japanese="シド",english="Cid",name="Cid",models=3041},
    [43]={id=938,japanese="ギルガメッシュ",english="Gilgamesh",name="Gilgamesh",models=3042},
    [44]={id=939,japanese="アレヴァト",english="Areuhat",name="Areuhat",models=3043},
    [45]={id=940,japanese="セミ・ラフィーナ",english="Semih Lafihna",name="SemihLafihna",models=3044},
    [46]={id=941,japanese="エリヴィラ",english="Elivira",name="Elivira",models=3045},
    [47]={id=942,japanese="ノユリ",english="Noillurie",name="Noillurie",models=3046},
    [48]={id=943,japanese="ルー・マカラッカ",english="Lhu Mhakaracca",name="LhuMhakaracca",models=3047},
    [49]={id=944,japanese="フェリアスコフィン",english="Ferreous Coffin",name="FerreousCoffin",models=3048},
    [50]={id=945,japanese="リリゼット",english="Lilisette",name="Lilisette",models=3049},
    [51]={id=946,japanese="ミュモル",english="Mumor",name="Mumor",models=3050},
    [52]={id=947,japanese="ウカ・トトゥリン",english="Uka Totlihn",name="UkaTotlihn",models=3051},
    [53]={id=948,japanese="クララ",english="Klara",name="Klara",models=3053},
    [54]={id=949,japanese="ロマー・ミーゴ",english="Romaa Mihgo",name="RomaaMihgo",models=3054},
    [55]={id=950,japanese="クイン・ハスデンナ",english="Kuyin Hathdenna",name="KuyinHathdenna",models=3055},
    [56]={id=951,japanese="ラーアル",english="Rahal",name="Rahal",models=3056},
    [57]={id=952,japanese="コルモル",english="Koru-Moru",name="Koru-Moru",models=3057},
    [58]={id=953,japanese="ピエージェ(UC)",english="Pieuje (UC)",name="Pieuje",models=3058},
    [59]={id=954,japanese="I.シールド(UC)",english="I. Shield (UC)",name="InvincibleShld",models=3060},
    [60]={id=955,japanese="アプルル(UC)",english="Apururu (UC)",name="Apururu",models=3061},
    [61]={id=956,japanese="ジャコ(UC)",english="Jakoh (UC)",name="JakohWahcondalo",models=3062},
    [62]={id=957,japanese="フラヴィリア(UC)",english="Flaviria (UC)",name="Flaviria",models=3059},
    [63]={id=958,japanese="ウェイレア",english="Babban",name="Babban",models=3067},
    [64]={id=959,japanese="アベンツィオ",english="Abenzio",name="Abenzio",models=3068},
    [65]={id=960,japanese="ルガジーン",english="Rughadjeen",name="Rughadjeen",models=3069},
    [66]={id=961,japanese="クッキーチェブキー",english="Kukki-Chebukki",name="Kukki-Chebukki",models=3070},
    [67]={id=962,japanese="マルグレート",english="Margret",name="Margret",models=3071},
    [68]={id=963,japanese="チャチャルン",english="Chacharoon",name="Chacharoon",models=3072},
    [69]={id=964,japanese="レイ・ランガヴォ",english="Lhe Lhangavo",name="LheLhangavo",models=3073},
    [70]={id=965,japanese="アシェラ",english="Arciela",name="Arciela",models=3074},
    [71]={id=966,japanese="マヤコフ",english="Mayakov",name="Mayakov",models=3075},
    [72]={id=967,japanese="クルタダ",english="Qultada",name="Qultada",models=3076},
    [73]={id=968,japanese="アーデルハイト",english="Adelheid",name="Adelheid",models=3077},
    [74]={id=969,japanese="アムチュチュ",english="Amchuchu",name="Amchuchu",models=3078},
    [75]={id=970,japanese="ブリジッド",english="Brygid",name="Brygid",models=3079},
    [76]={id=971,japanese="ミルドリオン",english="Mildaurion",name="Mildaurion",models=3080},
    [77]={id=972,japanese="ハルヴァー",english="Halver",name="Halver",models=3087},
    [78]={id=973,japanese="ロンジェルツ",english="Rongelouts",name="Rongelouts",models=3088},
    [79]={id=974,japanese="レオノアーヌ",english="Leonoyne",name="Leonoyne",models=3089},
    [80]={id=975,japanese="マクシミリアン",english="Maximilian",name="Maximilian",models=3090},
    [81]={id=976,japanese="カイルパイル",english="Kayeel-Payeel",name="Kayeel-Payeel",models=3091},
    [82]={id=977,japanese="ロベルアクベル",english="Robel-Akbel",name="Robel-Akbel",models=3092},
    [83]={id=978,japanese="クポフリート",english="Kupofried",name="Kupofried",models=3093},
    [84]={id=979,japanese="セルテウス",english="Selh\'teus",name="Selh\'teus",models=3094},
    [85]={id=980,japanese="ヨランオラン(UC)",english="Yoran-Oran (UC)",name="Yoran-Oran",models=3095},
    [86]={id=981,japanese="シルヴィ(UC)",english="Sylvie (UC)",name="Sylvie",models=3096},
    [87]={id=982,japanese="アブクーバ",english="Abquhbah",name="Abquhbah",models=3098},
    [88]={id=983,japanese="バラモア",english="Balamor",name="Balamor",models=3099},
    [89]={id=984,japanese="オーグスト",english="August",name="August",models=3100},
    [90]={id=985,japanese="ロスレーシャ",english="Rosulatia",name="Rosulatia",models=3101},
    [91]={id=986,japanese="テオドール",english="Teodor",name="Teodor",models=3103},
    [92]={id=987,japanese="ウルゴア",english="Ullegore",name="Ullegore",models=3105},
    [93]={id=988,japanese="マッキーチェブキー",english="Makki-Chebukki",name="Makki-Chebukki",models=3106},
    [94]={id=989,japanese="キング・オブ・ハーツ",english="King of Hearts",name="KingOfHearts",models=3107},
    [95]={id=990,japanese="モリマー",english="Morimar",name="Morimar",models=3108},
    [96]={id=991,japanese="ダラクァルン",english="Darrcuiln",name="Darrcuiln",models=3109},
    [97]={id=992,japanese="アークHM",english="AAHM",name="ArkHM",models=3113},
    [98]={id=993,japanese="アークEV",english="AAEV",name="ArkEV",models=3114},
    [99]={id=994,japanese="アークMR",english="AAMR",name="ArkMR",models=3115},
    [100]={id=995,japanese="アークTT",english="AATT",name="ArkTT",models=3116},
    [101]={id=996,japanese="アークGK",english="AAGK",name="ArkGK",models=3117},
    [102]={id=997,japanese="イロハ",english="Iroha",name="Iroha",models=3111},
    [103]={id=998,japanese="ユグナス",english="Ygnas",name="Ygnas",models=3118},
    [104]={id=1004,japanese="エグセニミルII",english="Excenmille [S]",name="Excenmille",models=3052},
    [105]={id=1005,japanese="アヤメ(UC)",english="Ayame (UC)",name="Ayame",models=3063},
    [106]={id=1006,japanese="マート(UC)",english="Maat (UC)",name="Maat",models=3064}, --expected models
    [107]={id=1007,japanese="アルド(UC)",english="Aldo (UC)",name="Aldo",models=3065}, --expected models
    [108]={id=1008,japanese="ナジャ(UC)",english="Naja (UC)",name="NajaSalaheem",models=3066},
    [109]={id=1009,japanese="ライオンII",english="Lion II",name="Lion",models=3081},
    [110]={id=1010,japanese="ザイドII",english="Zeid II",name="Zeid",models=3086},
    [111]={id=1011,japanese="プリッシュII",english="Prishe II",name="Prishe",models=3082},
    [112]={id=1012,japanese="ナシュメラII",english="Nashmeira II",name="Nashmeira",models=3083},
    [113]={id=1013,japanese="リリゼットII",english="Lilisette II",name="Lilisette",models=3084},
    [114]={id=1014,japanese="テンゼンII",english="Tenzen II",name="Tenzen",models=3097},
    [115]={id=1015,japanese="ミュモルII",english="Mumor II",name="Mumor",models=3104},
    [116]={id=1016,japanese="イングリッドII",english="Ingrid II",name="Ingrid",models=3102},
    [117]={id=1017,japanese="アシェラII",english="Arciela II",name="Arciela",models=3085},
    [118]={id=1018,japanese="イロハII",english="Iroha II",name="Iroha",models=3112},
    [119]={id=1019,japanese="シャントットII",english="Shantotto II",name="Shantotto",models=3110},
--  [120]={id=1003,japanese="コーネリア",english="Cornelia",name="Cornelia",models=3119}, --goodbye, my love
    [121]={id=999,japanese="モンブロー",english="Monberaux",name="Monberaux",models=3120},
}

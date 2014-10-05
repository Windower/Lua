-- Default custom dictionary, taken from:
-- http://wipe.guildwork.com/forum/threads/5039eb67205cb26e261f6988-japaneseenglish-guide-ffxi

local dict = {
    -- Party Chat section
    {en="BRB",ja="りせき"},
    {en="Congratulations",ja="おめでとうー"},
    --Excuse Me, WC for 2 Minutes || sumimasen, 2 pun hodo toile ittekimasu || すみません、2分ほどトイレ行ってきます
    {en="Gather for buffs",ja="プロテアとシェルかけるのであつまってください"},
    {en="I messed up",ja="しまった"},
    {en="Sorry, I'm back",ja="ごめんただいまですー"},
    {en="job okay?",ja="でいいかね"},
    {en="It can't be helped",ja="仕方がない "},
    {en="Let's go",ja="行きましょ"},
    --"Mary", Please go to "John's" Party || Mary wa John no patei ni itte kudasai || MaryはJohnのパーティーに行って下さい
    {en="Nice to meet you",ja="よろしくですー"},
    {en="Oh, that's good!",ja="それはいいですね"},
    {en="One moment please",ja="ちょっと待って下さい"},
    {en="Relogging, BRB",ja="コンピューターをさいきどうして、すぐもどります"},
    {en="Sorry, can you invite me again?",ja="ごめんね、またさそって下さい"},
    {en="Sorry, I disconnected",ja="私は接続を失いましたごめんなさい"},
    {en="Thank you",ja="ありがとうですー"},
    {en="They are already there",ja="もおむこおにいっています"},
    {en="Welcome back",ja="お帰りー"},
    {en="What job?",ja="すみません、私のジョブなんですか？"},
    
    -- During an event section
    {en="pop",ja="わかす"},
    {en="Go ahead",ja="先にどうぞ"},
    {en="How many left?",ja="あとなんかいでおわりますか"},
    {en="Hurry up",ja="急いで"},
    {en="I have to go",ja="行かなくてはなりません"},
    {en="I understand",ja="わかった"}, -- Informal
    {en="I understand",ja="わかりました"}, -- Formal
    {en="I will be right back",ja="すぐ戻ります"},
    {en="I will take it",ja="それ下さい"},
    {en="If we trigger weakness, defeat it quickly",ja="弱点ついたら早めに倒しましょう"},
    {en="Ignore weaknesses and defeat it quickly",ja="弱点を無視して早めに倒しましょう "},
    {en="Mission accomplished, see you!",ja="またあとで会いましょう"},
    {en="I'm going to use my merits",ja="メリポ振ってきます"},
    {en="next",ja="次"},
    {en="Roger that",ja="りょうかい"},
    {en="Run/Fight",ja="にげて"},
    {en="See you later",ja="またあとで会いましょう"},
    {en="Take it easy",ja="むりしないで"},
    {en="Thanks for the hard work",ja="お疲れ様でしたー"},
    {en="That was fun",ja="たのしい。。"},
    {en="Puller",ja="つりやく"},
    --We'll Be Done In About 2 More Pulls || Ato 2 webu kurai de owarimasuka || あと2ウェーブくらいで終わりますか
    {en="What an idiot",ja="ばかやろう。。"},
    {en="When is the ending?",ja="おわりますか"},
    {en="You can pop next",ja="つぎわかせていいよ"},
    --(You Find Nothing In The Riftworn Pyxis) || Tanakasan wa daikirai desuyo! || (ノ ゜Д゜)ノ三┸┸
    
    -- Coming and Going
    {en="Bad",ja="だめ"},
    {en="Cheap",ja="やすい"},
    {en="Come with me",ja="私といっしょに来て下さい。"},
    {en="Done",ja="それできまった"},
    {en="Don't touch me",ja="らないで"},
    --Excuse Me, Mind if I Join You? || sumimasen, akiwa arimasu ka? ikitai desu || すみません、あきはありますか？いきたいですー
    --Go Straight, Then Turn Left/ Right! || massugu itte kudasai, Soshite, hidari / migi ni magatte kudasai || まっすぐ行って下さい。そして、 左／右にまがって下さい。
    {en="Good luck",ja="がんばってね"},
    {en="I almost gave up",ja="あきらめてました"},
    {en="I feel sick",ja="調子が悪いです"},
    {en="I'm fine",ja="大丈夫です"},
    {en="I'm leaving",ja="行ってきます"},
    {en="I'm locked out",ja="しめだされました"},
    {en="I'm lost",ja="迷ってしまいました"},
    {en="I'm not going",ja="行きません"},
    {en="Shall we go?",ja="行きませんか"},
    {en="I need your help",ja="たすけて下さい"},
    {en="It's an emergency",ja="きんきゅです"},
    {en="Just a little",ja="少しだけ"},
    {en="Look out",ja="あぶない"},
    {en="No problem",ja="大丈夫です"},
    {en="Nothing",ja="べつに"},
    {en="Nothing much",ja="変わりないです"},
    {en="Please",ja="どぞ"}, -- Offer
    {en="Please",ja="お願します"}, -- Request
    {en="Please write it",ja="かいて下さい"},
    {en="Really sorry",ja="もうしわけございません"},
    {en="Listen",ja="あのね"},
    {en="Stop fooling around",ja="もうやめたら"},
    {en="Take care of yourself",ja="おだいじに"},
    {en="Take your time",ja="ゆっくりしなさい"},
    {en="Team up?",ja="一緒にやりませんか"},
    {en="This sucks",ja="サイアクだ"},
    {en="This way, please",ja="こちらえどうぞ"},
    {en="Time is up",ja="もう時間よ"},
    {en="Troublesome",ja="めんどくさい。。。"},
    {en="What happened?",ja="何かあった"},
    {en="Yes, I'm coming",ja="はい行きます"},
    {en="Yes, that's right",ja="はいそうです"},
    
--[[Casual Chat:
Brb, I'm Going to the Store || riseki, konbini de ikimasu || りせき、コンビニで行きます
Dont Be Late || chikoku shinaide || ちこくしないで
Don't Lie || uso tsukanaide || うそつかないで
Don't Worry || goshinpai naku || ご心配なく
Excuse Me || sumimasen || すみません！
Good Night || oyasuminasai || おやすみなさい
Have Fun || tanoshinde || たのしんで
I Agree || mattakuda || まったくだ
I Don't Know || shirimasen || 知りません
I Don't Speak Japanese, but I'm Using an Online Translator || watashi wa nihongo o hanashimasen demo onrain yakusha o shiyo shiteimasu || 私は日本語を話しませんでもオンラ イン訳者を使用しています
I Guess || souomoimasu || そうおもいます
I'm Bored || taikutsushiteru || たいくつしてる
I'm Confused || mayotteru, konnwakushiteru || まよってる、こんんわくしてる
I'm Hungry || onakaga suita || おなかがすいた
I'm Sleepy || nemutai || ねむたい
I'm Sorry || gomennasai || ごめんなさい
I'm Sorry (Sympathy) || zannen desu || ざんねんです
I'm Sorry, I'm Still Studying JP || gomen, nihongo benkyou shimasu || ごめん、日本語勉強しますー
I'm Sorry I Understand Now || gomen wakatta || ごめんわかった
I Really Like It! || honto ni suki desu || ほんとに好きです
It's Freezing || kogoesouni samui desu || こごえそうにさむいです
It's Not Fair | fukouhei da || ふこうへいだ	
Just Joking(jk) || jodandayo || 冗談だよ
Laugh Out Loud(lol) || www || ｗｗｗ
Leave Me Alone || hottoite || ほっといて
Me Too || watashimo || 私も
No Thanks || iie kekko desu || いいえけっこです
Not Bad || maamaa || まあ々
Okay || iiyo || いいよ
Of Course || mochiron || もちろん
Oh, I see || naru hondo || なるほんど
One Moment Please || chotto matte kudasai || ちょっと待って下さい
Probably || tabun || たぶん
Sleeping || neteiru || ねている
Wake Up || okite || おきて
What's Up? || saikin dou desuka || 最近どうですか？
Whoops || araara || あら々
Yes || hai || はいー
Your Welcome || douitashimashite || どういたしまして

Other Misc/Questions:
Any Ideas? || anata ga donna kangae o motte imasuka || あなたがどんな考えを持っていますか
Are You Okay? | daijoubu desu ka? || 大丈夫ですか
Can I Help You? || otetsudai shimashou ka? || お手伝いしましょうか？
Can You Help Me? || tetsudatte kuremasu ka? || 手伝ってくれますか？
Can You Say It Again? || mouichido itte kuremasu ka? || もういちど言ってくれますか？
Can You Type Roman Letters? || romaji de utte moraemasu ka? || ロマジでうってもらえますか
Do You Need It? || irimasenka || いりませんか
Do You Understand? || wakarimasu ka? || わかりますか
Do You Want to Party? || patei o kumimasen ka || パーティーをくみませんか
Does Anyone Speak English? || dare ga eigo o hanashimasu ka || だれが英語を話しますか
Don’t Be Surprised if Mistakes Are Made || machigai go attemo odorokanaide kudasai || まちがいごあってもおどろかないで下さい
Give Me a Minute to Look That Up || douiu imi ka shiraberu kara chotto matte kudasai || どういういみかしらべるからちょっとまって下さい
How || honoyouni || ほのように
How Are You? || ogenki desuka || お元気ですか？
How Do You Say ___ in JP || ___wa nihongo de nan to iimasuka || __ は日本語で何と言いますか？
How Much is This || kore wa ikura desu ka || これはいくらですか？
How Soon? || dono kurai suguni? || どのくらいすぐに
I Don’t Understand JP Letters || nihongo no moji wa wakarimasen || 日本語のもじはわかりません
I Need to Practice My Japanese || nihonngo o renshu suru hitsuyou ga arimasu || 日本語を練習する必要があります
Linkshell || rinksheru || リンクシェル
Look For a Replacement? || nuke tai node ho juu o sagashite kudasai? || ぬけたいのでほじゅうをさがして下さい
My JP is Not Good || watashi no nihongo wa yokunai desu || 私の日本語はよくないです
My Japanese is Bad || watashi no nihongo wa heta desu || 私の日本語はへたです
Shall We Go? || ikimashou ka || 行きましょか
What || nani || 何
What is ___? || ___ wa nandesu ka? || ___はなんですか
What's Next? || tsugi wa nandesu ka || つぎわなんですか
What's That Called In Japanese? || arewa nihongo de nanto iimasu ka? || あれは日本語で何といいますか？
What's Your Job? || donna shigoto o shiteiru no? || どんなジョブをしているの
Where || doko || どこ
Where Are You? || doko ni imasu ka? || どこにいますか
When || itsu || いつ
Which || donna || どんな
Who || dare || だれ
Why || naze || なぜ]]

--Common Areas/NMs & Events:
    {en="Promathia",ja="プロマシア"},
    {en="Ronfaure",ja="ロンフォール"},
    {en="Gustaberg",ja="グスタベルグ"},
    {en="Sarutabaruta",ja="サルタバルタ"},
    {en="Hahava",ja="ハハヴァ"},
    {en="Celaeno",ja="セラエノ"},
    {en="Voidwrought",ja="ヴォイドロート"},
    {en="Kaggen",ja="カッゲン"},
    {en="Akvan",ja="アクヴァン"},
    {en="Pil",ja="フィル"},
    {en="Qilin",ja="ちーりん"},
    {en="Uptala",ja="ウプタラ"},
    {en="Aello",ja="アイエロ"},
    {en="Gaunab",ja="ガウナブ"},
    {en="Ocythoe",ja="オシトエ"},
    {en="Kalasutrax",ja="カラストラクス"},
    {en="Ig-Alima",ja="イッグアリマ"},
    {en="Botulus Rex",ja="ボチュルス・レックス"},
    {en="Morta",ja="モルタ"},
    {en="Bismarck",ja="ビスマルク"},
    {en="Provenance Fights",ja="真界"},
    {en="Provenance Watcher",ja="水晶龍"},
    {en="Colkhab",ja="コルカブ"},
    {en="Muyingwa",ja="ムイングワ"},
    {en="Tchakka",ja="チャッカ"},
    {en="Dakuwaqa",ja="ダクワカ"},
    {en="Achuka",ja="アチュカ"},
    {en="Tojil",ja="トヒル"},
    {en="Hurkan",ja="フルカン"},
    {en="Yumcax",ja="ユムカクス"},
    {en="Kumhau",ja="クムハウ"},
-- Kazanaru Palace – カザナル宮外郭 --?
    {en="Abyssea",ja="アビセア"},
    {en="Caturae",ja="カトゥラエ"},
    {en="Legion",ja="レギオン"},
    {en="Nyzul",ja="ナイズル"},
    {en="Maze Mongers",ja="モブリンズメイズモンガー"},
    {en="Dynamis",ja="デュナミス"},
    {en="Einherjar",ja="エインヘリヤル"},
    {en="Salvage",ja="サルベージ"},
    {en="Walk of Echoes",ja="ウォークオブエコーズ"},
    {en="Meeble Burrows",ja="ミーブルバローズ"},
    {en="Assaults",ja="アサルト"},
    {en="Limbus",ja="リンバス"},
    {en="Garrison",ja="ガリスン"},
    {en="Grounds of Valor",ja="グラウンドオブヴァラー"},
    {en="Fields of Valor",ja="フィールドオブヴァラー"},
    {en="Brenner",ja="ブレンナー"},
    {en="Ballista",ja="バリスタ"},
    {en="Colonization",ja="コロナイズ"},
    {en="Lair Reive",ja="レイアレイヴ"},
    {en="Wildskeeper Reive",ja="ワイルドキーパーレイヴ"},
    {en="Skirmish",ja="スカーム"},
    {en="Delve",ja="メナス"},
    {en="Ark Angel",ja="アークガーディアン"},
    {en="Divine Might",ja="神威"},
    {en="North",ja="北"},
    {en="East",ja="東"},
    {en="South",ja="南"},
    {en="West",ja="西"},

    -- Things you should know
    {en="Polearm",ja="やり"},
    {en="Automaton",ja="オートマトン"},
    {en="Instrument",ja="楽器"},
    {en="Ability",ja="アビリティ"},
    {en="Wyvern",ja="飛竜"},
    {en="Pet",ja="ペット"},
    {en="Pet",ja="よぶだす"},
    
    
    -- Useful words
    {en="Synergy",ja="相乗効果"},
    {en="Carbuncle",ja="カーバンクル"},
    {en="Fenrir",ja="フェンリル"},
    {en="Ifrit",ja="イフリート"},
    {en="Titan",ja="タイタン"},
    {en="Leviathan",ja="リヴァイアサン"},
    {en="Garuda",ja="ガルーダ"},
    {en="Shiva",ja="シヴァ"},
    {en="Ramuh",ja="ラムウ"},
    {en="Diabolos",ja="ディアボロス"},
    {en="Odin",ja="オーディン"},
    {en="Alexander",ja="アレキサンダー"},
    {en="Cait Sith",ja="ケット・シー"},
    
    
    {en="Weakness",ja="弱点"},
    {en="Trigger",ja="狙って"},
    {en="Blue",ja="青"},
    {en="Red",ja="赤"},
    {en="Yellow",ja="黄"},
    {en="White",ja="白"},
    {en="Black",ja="黒"},
    {en="Silver",ja="銀"},
    {en="Gold",ja="金"},
    {en="Armor",ja="装束"},
    {en="Chest",ja="宝箱"},
    {en="Body",ja="胴"},
    {en="Hands",ja="両手"},
    {en="Legs",ja="両足"},
    {en="Head",ja="頭"},
    {en="Feet",ja="両足"},
    {en="Ring",ja="指"},
    {en="Ear",ja="耳"},
    {en="Back",ja="背"},
    {en="Waist",ja="腰"},
    {en="Lucky Roll",ja="ラッキーロール"},
    {en="Wide Scan",ja="広域スキャン"},
    {en="Charm",ja="あやつる"},
    {en="Snapshot",ja="スナップショット"},
    {en="Double Attack",ja="ダブルアタック"},
    {en="Artifact",ja="アーティファクト"},
    {en="Records of Eminence",ja="エミネンスレコード"},
    {en="Monstrosity",ja="モンストロス"},
    {en="Trust",ja="フェイス"},
    {en="Very Easy",ja="とてもやさしい"},
    {en="Easy",ja="やさしい"},
    {en="Normal",ja="ふつう"},
    {en="Difficult",ja="むずかしい"},
    {en="Very Difficult",ja="とてもむずかしい"},
    {en="Hume",ja="ヒュム"},
    {en="Tarutaru",ja="タルタル"},
    {en="Elvaan",ja="エルヴァーン"},
    {en="Teleport",ja="テレポ"},
    {en="Byne Bill",ja="バイン紙幣"},
    {en="Bronzepiece",ja="オルデール銅貨"},
    {en="Whiteshell",ja="トゥクク白貝貨"},
    {en="Alexandrite",ja="アレキサンドライト"},
    {en="Ancient Beastcoins",ja="獣人古銭"},
    {en="Relic",ja="レリック"},
    {en="Mythic",ja="ミシック"},
    {en="Empyrean",ja="エンピリアン"},
    {en="Sneak and Invisible",ja="インスニ"},
    {en="Aegis and Ochain",ja="イーハン"},
    {en="Overkilled",ja="オーバーキル"},
    {en="Overfished",ja="乱獲"},
    {en="Carby pull",ja="カーバンクルマラソン"},
    {en="set up a Magic Burst",ja="マジックバースト"},
    {en="Skill-up party",ja="スキル上げパーティ"},
    {en="zombie it",ja="ゾンビアタック"},
    {en="Plasm farming",ja="メナポ"},
    {en="Falling asleep",ja="寝落ち"},
    {en="losing claim",ja="横取り"},
    
    
    -- 10/4/14 update
    {en="Dismemberment Brigade",ja="八つ裂き旅団"},
    {en="The Worm's Turn",ja="地竜大王"},
    {en="Grimshell Shocktroopers",ja="鉄甲突撃隊"},
    {en="Steamed Sprouts",ja="居候妖精"},
    {en="Divine Punishers",ja="天誅六人衆"},
    {en="Brothers D'Aurphe",ja="ドーフェ兄弟"},
    {en="Legion XI Comitatensis",ja="第11軍団独立支隊"},
    {en="Amphibian Assault",ja="潜行特務隊"},
    {en="Jungle Boogymen",ja="特命介錯人"},
    {en="Shadow Lord",ja="闇王"},
    {en="Kindred Spirits",ja="蒼の血族"},
    {en="Kam'lanaut",ja="カムラナート"},
    {en="Eald'narche",ja="エルドナーシュ"},
    {en="Ouryu",ja="オウリュウ"},
    {en="Tenzen",ja="テンゼン"},
    {en="Shikaree",ja="シカレー"},
    {en="Puppet in Peril",ja="ランスロード"},
    {en="Gessho",ja="ゲッショー"},
    {en="Incursion",ja="インカージョン"},
    {en="Ymmr",ja="イムル"},
    {en="Ignor",ja="イグノア"},
    {en="Durs",ja="ダルス"},
    {en="Tryl",ja="ダルス"},
    {en="Liij",ja="リッジ"},
    {en="Gramk",ja="グラムク"},
    {en="Utkux",ja="アットクックス"},
    {en="Wopket",ja="ウォップケット"},
    {en="Cailimh",ja="カイルイム"},
    {en="Surge",ja="サージ"},
    {en="Endowed",ja="エンダウ"},
}

return dict
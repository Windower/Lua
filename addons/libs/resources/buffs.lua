local buffs = {}
buffs[0] = { id=0,duration=0,english="KO",log_english="KO'd",french="K.O.",german="K.o.",japanese="戦闘不能"}
buffs[1] = { id=1,duration=0,english="weakness",log_english="weakened",french="Anémie",german="Schwäche",japanese="衰弱"}
buffs[2] = { id=2,duration=0,english="sleep",log_english="asleep",french="Sommeil",german="Schlaf",japanese="睡眠"}
buffs[3] = { id=3,duration=0,english="poison",log_english="poisoned",french="Poison",german="Gift",japanese="毒"}
buffs[4] = { id=4,duration=0,english="paralysis",log_english="paralyzed",french="Paralysie",german="Paralyse",japanese="麻痺"}
buffs[5] = { id=5,duration=0,english="blindness",log_english="blinded",french="Cécité",german="Blind",japanese="暗闇"}
buffs[6] = { id=6,duration=0,english="silence",log_english="silenced",french="Silence",german="Schweigen",japanese="静寂"}
buffs[7] = { id=7,duration=0,english="petrification",log_english="petrified",french="Pétrification",german="Stein",japanese="石化"}
buffs[8] = { id=8,duration=0,english="disease",log_english="diseased",french="Maladie",german="Krankheit",japanese="病気"}
buffs[9] = { id=9,duration=0,english="curse",log_english="cursed",french="Maléfice",german="Fluch",japanese="呪い"}
buffs[10] = { id=10,duration=0,english="stun",log_english="stunned",french="Etourdissement",german="Betäubung",japanese="スタン"}
buffs[11] = { id=11,duration=0,english="bind",log_english="bound",french="Entrave",german="Fessel",japanese="バインド"}
buffs[12] = { id=12,duration=0,english="weight",log_english="weighed down",french="Pesanteur",german="Gewicht",japanese="ヘヴィ"}
buffs[13] = { id=13,duration=0,english="slow",log_english="slowed",french="Lenteur",german="Gemach",japanese="スロウ"}
buffs[14] = { id=14,duration=0,english="charm",log_english="charmed",french="Charme",german="Verzaubert",japanese="魅了"}
buffs[15] = { id=15,duration=0,english="doom",log_english="doomed",french="Glas",german="Verhängnis",japanese="死の宣告"}
buffs[16] = { id=16,duration=0,english="amnesia",log_english="amnesic",french="Amnésie",german="Amnesie",japanese="アムネジア"}
buffs[17] = { id=17,duration=0,english="charm",log_english="charmed",french="Charme",german="Verzaubert",japanese="魅了"}
buffs[18] = { id=18,duration=0,english="gradual petrification",log_english="gradually petrifying",french="Pétrification graduelle",german="Petrifikation",japanese="徐々に石化"}
buffs[19] = { id=19,duration=0,english="sleep",log_english="asleep",french="Sommeil",german="Schlaf",japanese="睡眠"}
buffs[20] = { id=20,duration=0,english="curse",log_english="cursed",french="Maléfice",german="Fluch",japanese="呪い"}
buffs[21] = { id=21,duration=0,english="addle",log_english="addled",french="Egarement",german="Geist-Vernebelung",japanese="アドル"}
buffs[22] = { id=22,duration=0,english="intimidate",log_english="intimidated",french="Intimidation",german="Drangsalierung",japanese="ひるみ"}
buffs[23] = { id=23,duration=0,english="Kaustra",log_english="afflicted with Kaustra",french="Kaustra",german="Kaustra",japanese="メルトン"}
buffs[28] = { id=28,duration=0,english="terror",log_english="terrorized",french="Terreur",german="Angst",japanese="テラー"}
buffs[29] = { id=29,duration=0,english="mute",log_english="muted",french="Mutisme",german="Stumm",japanese="沈黙"}
buffs[30] = { id=30,duration=0,english="bane",log_english="baned",french="Possession",german="Bann",japanese="呪詛"}
buffs[31] = { id=31,duration=0,english="plague",log_english="plagued",french="Peste",german="Pest",japanese="悪疫"}
buffs[32] = { id=32,duration=0,english="Flee",log_english="fleeing",french="Fuite",german="Reißaus",japanese="とんずら"}
buffs[33] = { id=33,duration=0,english="Haste",log_english="hastened",french="Hâte",german="Hast",japanese="ヘイスト"}
buffs[34] = { id=34,duration=0,english="Blaze Spikes",log_english="Blaze Spikes",french="Pointes de feu",german="Flammenspitzen",japanese="ブレイズスパイク"}
buffs[35] = { id=35,duration=0,english="Ice Spikes",log_english="Ice Spikes",french="Pointes de glace",german="Eisspitzen",japanese="アイススパイク"}
buffs[36] = { id=36,duration=0,english="Blink",log_english="Blink",french="Faux-semblant",german="Spiegelschimmer",japanese="ブリンク"}
buffs[37] = { id=37,duration=0,english="Stoneskin",log_english="Stoneskin",french="Cuirasse",german="Steinhaut",japanese="ストンスキン"}
buffs[38] = { id=38,duration=0,english="Shock Spikes",log_english="Shock Spikes",french="Pointes de foudre",german="Schockspitzen",japanese="ショックスパイク"}
buffs[39] = { id=39,duration=0,english="Aquaveil",log_english="Aquaveil",french="Aquavoile",german="Wasserschleier",japanese="アクアベール"}
buffs[40] = { id=40,duration=0,english="Protect",log_english="Protect",french="Bouclier",german="Schutz",japanese="プロテス"}
buffs[41] = { id=41,duration=0,english="Shell",log_english="Shell",french="Barrière",german="Schutzschirm",japanese="シェル"}
buffs[42] = { id=42,duration=0,english="Regen",log_english="regenerating",french="Récup",german="Regenerieren",japanese="リジェネ"}
buffs[43] = { id=43,duration=0,english="Refresh",log_english="refreshing",french="Recharge",german="Erfrischen",japanese="リフレシュ"}
buffs[44] = { id=44,duration=0,english="Mighty Strikes",log_english="Mighty Strikes",french="Destro-frappes",german="Powerschläge",japanese="マイティストライク"}
buffs[45] = { id=45,duration=0,english="Boost",log_english="Boost",french="Accumulation",german="Boost",japanese="ためる"}
buffs[46] = { id=46,duration=0,english="Hundred Fists",log_english="Hundred Fists",french="Cent poings",german="Hundert Fäuste",japanese="百烈拳"}
buffs[47] = { id=47,duration=0,english="Manafont",log_english="Manafont",french="Source de Mana",german="Mana-Fontäne",japanese="魔力の泉"}
buffs[48] = { id=48,duration=0,english="Chainspell",log_english="Chainspell",french="Chaîne de sorts",german="Kettenspruch",japanese="連続魔"}
buffs[49] = { id=49,duration=0,english="Perfect Dodge",log_english="Perfect Dodge",french="Esquive absolue",german="Superkniff",japanese="絶対回避"}
buffs[50] = { id=50,duration=0,english="Invincible",log_english="Invincible",french="Invincible",german="Unbesiegbar",japanese="インビンシブル"}
buffs[51] = { id=51,duration=0,english="Blood Weapon",log_english="Blood Weapon",french="Arme sanguinaire",german="Blutwaffe",japanese="ブラッドウェポン"}
buffs[52] = { id=52,duration=0,english="Soul Voice",log_english="Soul Voice",french="Voix de l'âme",german="Seelenstimme",japanese="ソウルボイス"}
buffs[53] = { id=53,duration=0,english="Eagle Eye Shot",log_english="Eagle Eye Shot",french="Œil d'aigle",german="Adleraugen-Schuss",japanese="イーグルアイ"}
buffs[54] = { id=54,duration=0,english="Meikyo Shisui",log_english="Meikyo Shisui",french="Meikyo Shisui",german="Meikyo Shisui",japanese="明鏡止水"}
buffs[55] = { id=55,duration=0,english="Astral Flow",log_english="Astral Flow",french="Aura astrale",german="Astralstrom",japanese="アストラルフロウ"}
buffs[56] = { id=56,duration=0,english="Berserk",log_english="Berserk",french="Berserk",german="Berserker",japanese="バーサク"}
buffs[57] = { id=57,duration=0,english="Defender",log_english="Defender",french="Défenseur",german="Defender",japanese="ディフェンダー"}
buffs[58] = { id=58,duration=0,english="Aggressor",log_english="Aggressor",french="Agresseur",german="Aggressor",japanese="アグレッサー"}
buffs[59] = { id=59,duration=0,english="Focus",log_english="Focus",french="Précision",german="Fokus",japanese="集中"}
buffs[60] = { id=60,duration=0,english="Dodge",log_english="Dodge",french="Esquive +",german="Ausweichen",japanese="回避"}
buffs[61] = { id=61,duration=0,english="Counterstance",log_english="Counterstance",french="Qui-vive",german="Gegenzug",japanese="かまえる"}
buffs[62] = { id=62,duration=0,english="Sentinel",log_english="Sentinel",french="Sentinelle",german="Sentinel",japanese="センチネル"}
buffs[63] = { id=63,duration=0,english="Souleater",log_english="Souleater",french="Noirceur",german="Seelenfresser",japanese="暗黒"}
buffs[64] = { id=64,duration=0,english="Last Resort",log_english="Last Resort",french="Dernier recours",german="Letzter Ausweg",japanese="ラストリゾート"}
buffs[65] = { id=65,duration=0,english="Sneak Attack",log_english="Sneak Attack",french="Attaque furtive",german="Schleichattacke",japanese="不意打ち"}
buffs[66] = { id=66,duration=0,english="Copy Image",log_english="Copy Image",french="Réplique",german="Kopiebild",japanese="分身"}
buffs[67] = { id=67,duration=0,english="Third Eye",log_english="Third Eye",french="Troisième œil",german="3. Auge",japanese="心眼"}
buffs[68] = { id=68,duration=0,english="Warcry",log_english="Warcry",french="Cri de guerre",german="Kampfschrei",japanese="ウォークライ"}
buffs[69] = { id=69,duration=0,english="Invisible",log_english="Invisible",french="Invisible",german="Unsichtbar",japanese="インビジ"}
buffs[70] = { id=70,duration=0,english="Deodorize",log_english="Deodorize",french="Inodore",german="Parfümieren",japanese="デオード"}
buffs[71] = { id=71,duration=0,english="Sneak",log_english="Sneak",french="Furtivité",german="Schleichen",japanese="スニーク"}
buffs[72] = { id=72,duration=0,english="Sharpshot",log_english="Sharpshot",french="Visée",german="Fangschuss",japanese="狙い撃ち"}
buffs[73] = { id=73,duration=0,english="Barrage",log_english="Barrage",french="Tir en rafale",german="Trommelfeuer",japanese="乱れ撃ち"}
buffs[74] = { id=74,duration=0,english="Holy Circle",log_english="Holy Circle",french="Cercle sacré",german="Heiliger Kreis",japanese="ホーリーサークル"}
buffs[75] = { id=75,duration=0,english="Arcane Circle",log_english="Arcane Circle",french="Cercle ésotérique",german="Arcana-Kreis",japanese="アルケインサークル"}
buffs[76] = { id=76,duration=0,english="Hide",log_english="hiding",french="Dissimulation",german="Verstecken",japanese="かくれる"}
buffs[77] = { id=77,duration=0,english="Camouflage",log_english="camouflaged",french="Camouflage",german="Tarnung",japanese="カモフラージュ"}
buffs[78] = { id=78,duration=0,english="Divine Seal",log_english="Divine Seal",french="Sceau divin",german="Göttersiegel",japanese="女神の印"}
buffs[79] = { id=79,duration=0,english="Elemental Seal",log_english="Elemental Seal",french="Sceau élémentaire",german="Elementar-Siegel",japanese="精霊の印"}
buffs[80] = { id=80,duration=0,english="STR Boost",log_english="STR-boosted",french="STR augmentée",german="STR-Boost",japanese="STRアップ"}
buffs[81] = { id=81,duration=0,english="DEX Boost",log_english="DEX-boosted",french="DEX augmentée",german="DEX-Boost",japanese="DEXアップ"}
buffs[82] = { id=82,duration=0,english="VIT Boost",log_english="VIT-boosted",french="VIT augmentée",german="VIT-Boost",japanese="VITアップ"}
buffs[83] = { id=83,duration=0,english="AGI Boost",log_english="AGI-boosted",french="AGI augmentée",german="AGI-Boost",japanese="AGIアップ"}
buffs[84] = { id=84,duration=0,english="INT Boost",log_english="INT-boosted",french="INT augmentée",german="INT-Boost",japanese="INTアップ"}
buffs[85] = { id=85,duration=0,english="MND Boost",log_english="MND-boosted",french="MND augmenté",german="MND-Boost",japanese="MNDアップ"}
buffs[86] = { id=86,duration=0,english="CHR Boost",log_english="CHR-boosted",french="CHR augmenté",german="CHR-Boost",japanese="CHRアップ"}
buffs[87] = { id=87,duration=0,english="Trick Attack",log_english="Trick Attack",french="Attaque sournoise",german="Trickattacke",japanese="だまし討ち"}
buffs[88] = { id=88,duration=0,english="Max HP Boost",log_english="Max HP-boosted",french="Max. HP augmenté",german="Max HP-Boost",japanese="HPmaxアップ"}
buffs[89] = { id=89,duration=0,english="Max MP Boost",log_english="Max MP-boosted",french="Max. MP augmenté",german="Max MP-Boost",japanese="MPmaxアップ"}
buffs[90] = { id=90,duration=0,english="Accuracy Boost",log_english="accuracy-boosted",french="Précision augmentée",german="Präzisions-Boost",japanese="命中率アップ"}
buffs[91] = { id=91,duration=0,english="Attack Boost",log_english="attack-boosted",french="Attaque augmentée",german="Attacken-Boost",japanese="攻撃力アップ"}
buffs[92] = { id=92,duration=0,english="Evasion Boost",log_english="evasion-boosted",french="Esquive augmentée",german="Ausweich-Boost",japanese="回避率アップ"}
buffs[93] = { id=93,duration=0,english="Defense Boost",log_english="defense-boosted",french="Défense augmentée",german="Verteidigungs-Boost",japanese="防御力アップ"}
buffs[94] = { id=94,duration=0,english="Enfire",log_english="Enfire",french="EndoFeu",german="Feuer +",japanese="エンファイア"}
buffs[95] = { id=95,duration=0,english="Enblizzard",log_english="Enblizzard",french="EndoGlace",german="Eis +",japanese="エンブリザド"}
buffs[96] = { id=96,duration=0,english="Enaero",log_english="Enaero",french="EndoVent",german="Wind +",japanese="エンエアロ"}
buffs[97] = { id=97,duration=0,english="Enstone",log_english="Enstone",french="EndoPierre",german="Erde +",japanese="エンストーン"}
buffs[98] = { id=98,duration=0,english="Enthunder",log_english="Enthunder",french="EndoFoudre",german="Donner +",japanese="エンサンダー"}
buffs[99] = { id=99,duration=0,english="Enwater",log_english="Enwater",french="EndoEau",german="Wasser +",japanese="エンウォータ"}
buffs[100] = { id=100,duration=0,english="Barfire",log_english="Barfire",french="AntiFeu",german="Feuerriegel",japanese="バファイ"}
buffs[101] = { id=101,duration=0,english="Barblizzard",log_english="Barblizzard",french="AntiGlace",german="Eisriegel",japanese="バブリザ"}
buffs[102] = { id=102,duration=0,english="Baraero",log_english="Baraero",french="AntiVent",german="Windriegel",japanese="バエアロ"}
buffs[103] = { id=103,duration=0,english="Barstone",log_english="Barstone",french="AntiPierre",german="Erdenriegel",japanese="バストン"}
buffs[104] = { id=104,duration=0,english="Barthunder",log_english="Barthunder",french="AntiFoudre",german="Donnerriegel",japanese="バサンダ"}
buffs[105] = { id=105,duration=0,english="Barwater",log_english="Barwater",french="AntiEau",german="Wasserriegel",japanese="バウォタ"}
buffs[106] = { id=106,duration=0,english="Barsleep",log_english="Barsleep",french="AntiSommeil",german="Schlafriegel",japanese="バスリプル"}
buffs[107] = { id=107,duration=0,english="Barpoison",log_english="Barpoison",french="AntiPoison",german="Giftriegel",japanese="バポイズン"}
buffs[108] = { id=108,duration=0,english="Barparalyze",log_english="Barparalyze",french="AntiParalysie",german="Paralyseriegel",japanese="バパライズ"}
buffs[109] = { id=109,duration=0,english="Barblind",log_english="Barblind",french="AntiCécité",german="Blindriegel",japanese="バブライン"}
buffs[110] = { id=110,duration=0,english="Barsilence",log_english="Barsilence",french="AntiSilence",german="Schweigriegel",japanese="バサイレス"}
buffs[111] = { id=111,duration=0,english="Barpetrify",log_english="Barpetrify",french="AntiPétrification",german="Steinriegel",japanese="バブレイク"}
buffs[112] = { id=112,duration=0,english="Barvirus",log_english="Barvirus",french="AntiVirus",german="Virenriegel",japanese="バウィルス"}
buffs[113] = { id=113,duration=0,english="Reraise",log_english="Reraise",french="Revie",german="Wiederauferstehen",japanese="リレイズ"}
buffs[114] = { id=114,duration=0,english="Cover",log_english="Cover",french="Couverture",german="Deckung",japanese="かばう"}
buffs[115] = { id=115,duration=0,english="Unlimited Shot",log_english="Unlimited Shot",french="Tirs illimités",german="Dauerschuss",japanese="エンドレスショット"}
buffs[116] = { id=116,duration=0,english="Phalanx",log_english="Phalanx",french="Phalange",german="Phalanx",japanese="ファランクス"}
buffs[117] = { id=117,duration=0,english="Warding Circle",log_english="Warding Circle",french="Cercle protecteur",german="Gewahrsamskreis",japanese="護摩の守護円"}
buffs[118] = { id=118,duration=0,english="Ancient Circle",log_english="Ancient Circle",french="Cercle ancien",german="Urkreis",japanese="エンシェントサークル"}
buffs[119] = { id=119,duration=0,english="STR Boost",log_english="STR-boosted",french="STR augmentée",german="STR-Boost",japanese="STRアップ"}
buffs[120] = { id=120,duration=0,english="DEX Boost",log_english="DEX-boosted",french="DEX augmentée",german="DEX-Boost",japanese="DEXアップ"}
buffs[121] = { id=121,duration=0,english="VIT Boost",log_english="VIT-boosted",french="VIT augmentée",german="VIT-Boost",japanese="VITアップ"}
buffs[122] = { id=122,duration=0,english="AGI Boost",log_english="AGI-boosted",french="AGI augmentée",german="AGI-Boost",japanese="AGIアップ"}
buffs[123] = { id=123,duration=0,english="INT Boost",log_english="INT-boosted",french="INT augmentée",german="INT-Boost",japanese="INTアップ"}
buffs[124] = { id=124,duration=0,english="MND Boost",log_english="MND-boosted",french="MND augmenté",german="MND-Boost",japanese="MNDアップ"}
buffs[125] = { id=125,duration=0,english="CHR Boost",log_english="CHR-boosted",french="CHR augmenté",german="CHR-Boost",japanese="CHRアップ"}
buffs[126] = { id=126,duration=0,english="Spirit Surge",log_english="Spirit Surge",french="Souffle d'esprit",german="Seelenstoß",japanese="竜剣"}
buffs[127] = { id=127,duration=0,english="Costume",log_english="Costume",french="Costume",german="Kostüm",japanese="コスチューム"}
buffs[128] = { id=128,duration=0,english="Burn",log_english="afflicted with Burn",french="Combustion",german="Brennen",japanese="バーン"}
buffs[129] = { id=129,duration=0,english="Frost",log_english="afflicted with Frost",french="Givre",german="Frost",japanese="フロスト"}
buffs[130] = { id=130,duration=0,english="Choke",log_english="afflicted with Choke",french="Suffocation",german="Drossel",japanese="チョーク"}
buffs[131] = { id=131,duration=0,english="Rasp",log_english="afflicted with Rasp",french="Râpe",german="Raspel",japanese="ラスプ"}
buffs[132] = { id=132,duration=0,english="Shock",log_english="afflicted with Shock",french="Choc",german="Schock",japanese="ショック"}
buffs[133] = { id=133,duration=0,english="Drown",log_english="afflicted with Drown",french="Submersion",german="Ertrinken",japanese="ドラウン"}
buffs[134] = { id=134,duration=0,english="Dia",log_english="afflicted with Dia",french="Lumen",german="Dia",japanese="ディア"}
buffs[135] = { id=135,duration=0,english="Bio",log_english="afflicted with Bio",french="Bactérie",german="Bio",japanese="バイオ"}
buffs[136] = { id=136,duration=0,english="STR Down",log_english="afflicted with STR Down",french="STR réduite",german="STR-Down",japanese="STRダウン"}
buffs[137] = { id=137,duration=0,english="DEX Down",log_english="afflicted with DEX Down",french="DEX réduite",german="DEX-Down",japanese="DEXダウン"}
buffs[138] = { id=138,duration=0,english="VIT Down",log_english="afflicted with VIT Down",french="VIT réduite",german="VIT-Down",japanese="VITダウン"}
buffs[139] = { id=139,duration=0,english="AGI Down",log_english="afflicted with AGI Down",french="AGI réduite",german="AGI-Down",japanese="AGIダウン"}
buffs[140] = { id=140,duration=0,english="INT Down",log_english="afflicted with INT Down",french="INT réduite",german="INT-Down",japanese="INTダウン"}
buffs[141] = { id=141,duration=0,english="MND Down",log_english="afflicted with MND Down",french="MND réduit",german="MND-Down",japanese="MNDダウン"}
buffs[142] = { id=142,duration=0,english="CHR Down",log_english="afflicted with CHR Down",french="CHR réduit",german="CHR-Down",japanese="CHRダウン"}
buffs[143] = { id=143,duration=0,english="Level Restriction",log_english="level-restricted",french="Restriction de niveau",german="Level-Einschränkung",japanese="レベル制限"}
buffs[144] = { id=144,duration=0,english="Max HP Down",log_english="afflicted with Max HP Down",french="Max. HP réduit",german="Max HP-Down",japanese="HPmaxダウン"}
buffs[145] = { id=145,duration=0,english="Max MP Down",log_english="afflicted with Max MP Down",french="Max. MP réduit",german="Max MP-Down",japanese="MPmaxダウン"}
buffs[146] = { id=146,duration=0,english="Accuracy Down",log_english="afflicted with Accuracy Down",french="Précision réduite",german="Präzisions-Down",japanese="命中率ダウン"}
buffs[147] = { id=147,duration=0,english="Attack Down",log_english="afflicted with Attack Down",french="Attaque réduite",german="Attacken-Down",japanese="攻撃力ダウン"}
buffs[148] = { id=148,duration=0,english="Evasion Down",log_english="afflicted with Evasion Down",french="Esquive réduite",german="Ausweich-Down",japanese="回避率ダウン"}
buffs[149] = { id=149,duration=0,english="Defense Down",log_english="afflicted with Defense Down",french="Défense réduite",german="Verteidigungs-Down",japanese="防御力ダウン"}
buffs[150] = { id=150,duration=0,english="Physical Shield",log_english="Physical Shield",french="Bouclier physique",german="Körperschild",japanese="物理バリア"}
buffs[151] = { id=151,duration=0,english="Arrow Shield",log_english="Arrow Shield",french="Bouclier à flèches",german="Pfeilschild",japanese="遠隔物理バリア"}
buffs[152] = { id=152,duration=0,english="Magic Shield",log_english="Magic Shield",french="Bouclier magique",german="Magieschild",japanese="魔法バリア"}
buffs[153] = { id=153,duration=0,english="Damage Spikes",log_english="Damage Spikes",french="Pointes de dégâts",german="Schadensspitzen",japanese="ダメージスパイク"}
buffs[154] = { id=154,duration=0,english="Shining Ruby",log_english="Shining Ruby",french="Rubis brillant",german="Glanzrubin",japanese="ルビーの輝き"}
buffs[155] = { id=155,duration=0,english="medicine",log_english="medicated",french="Remède",german="Unter Medikament",japanese="服薬中"}
buffs[156] = { id=156,duration=0,english="Flash",log_english="afflicted with Flash",french="Flash",german="Blitzlicht",japanese="フラッシュ"}
buffs[157] = { id=157,duration=0,english="SJ Restriction",log_english="SJ Restriction",french="Restriction JS",german="NJ-Beschränkung",japanese="サポートジョブ無効"}
buffs[158] = { id=158,duration=0,english="Provoke",log_english="provoked",french="Provocation",german="Provoziert",japanese="挑発"}
buffs[159] = { id=159,duration=0,english="penalty",log_english="penalized",french="Pénalité",german="Bestrafung",japanese="ペナルティ"}
buffs[160] = { id=160,duration=0,english="preparations",log_english="preparing for battle",french="Préparations",german="Vorbereitungen",japanese="試合復帰準備中"}
buffs[161] = { id=161,duration=0,english="Sprint",log_english="Sprint",french="Sprint",german="Sprint",japanese="スプリント"}
buffs[162] = { id=162,duration=0,english="enchantment",log_english="enchanted",french="Enchantement",german="Verzaubertes Item",japanese="エンチャント"}
buffs[163] = { id=163,duration=0,english="Azure Lore",log_english="Azure Lore",french="Sagesse d'azur",german="Blaues Gesetz",japanese="アジュールロー"}
buffs[164] = { id=164,duration=0,english="Chain Affinity",log_english="Chain Affinity",french="Lien de chaînes",german="Blaue Kette",japanese="ブルーチェーン"}
buffs[165] = { id=165,duration=0,english="Burst Affinity",log_english="Burst Affinity",french="Lien d'explosions",german="Blauer Ausbruch",japanese="ブルーバースト"}
buffs[166] = { id=166,duration=0,english="Overdrive",log_english="Overdrive",french="Suractivité",german="Overdrive",japanese="オーバードライヴ"}
buffs[167] = { id=167,duration=0,english="Magic Def. Down",log_english="Magic Def. Down",french="Déf. magique réduite",german="Verminderte Magieabwehr",japanese="魔法防御力ダウン"}
buffs[168] = { id=168,duration=0,english="Inhibit TP",log_english="TP-inhibited",french="Inhibition de TP",german="TP-Sperre",japanese="インヒビットTP"}
buffs[169] = { id=169,duration=0,english="Potency",log_english="Potency",french="Puissance",german="Wirksamkeit",japanese="ポテンシー"}
buffs[170] = { id=170,duration=0,english="Regain",log_english="Regain",french="Regain",german="Wiedererlangen",japanese="リゲイン"}
buffs[171] = { id=171,duration=0,english="Pax",log_english="Pax",french="Pax",german="Pax",japanese="パクス"}
buffs[172] = { id=172,duration=0,english="Intension",log_english="Intension",french="Intensification",german="Intensivierung",japanese="インテンション"}
buffs[173] = { id=173,duration=0,english="Dread Spikes",log_english="Dread Spikes",french="Pointes d'effroi",german="Furchtspitzen",japanese="ドレッドスパイク"}
buffs[174] = { id=174,duration=0,english="Magic Acc. Down",log_english="Magic Acc. Down",french="Préc. magique réduite",german="Magiepräzisions-Down",japanese="魔法命中率ダウン"}
buffs[175] = { id=175,duration=0,english="Magic Atk. Down",log_english="Magic Atk. Down",french="Attq. magique réduite",german="Magieattacken-Down",japanese="魔法攻撃力ダウン"}
buffs[176] = { id=176,duration=0,english="quickening",log_english="quickened",french="Vitesse déplacement augmentée",german="Beschleunigung",japanese="移動速度アップ"}
buffs[177] = { id=177,duration=0,english="encumbrance",log_english="encumbered",french="Astreinte",german="Belastung",japanese="装備変更不可"}
buffs[178] = { id=178,duration=0,english="Firestorm",log_english="Firestorm",french="Loi de la canicule",german="Feuerfront",japanese="熱波の陣"}
buffs[179] = { id=179,duration=0,english="Hailstorm",log_english="Hailstorm",french="Loi du blizzard",german="Hagelfront",japanese="吹雪の陣"}
buffs[180] = { id=180,duration=0,english="Windstorm",log_english="Windstorm",french="Loi des ouragans",german="Sturmfront",japanese="烈風の陣"}
buffs[181] = { id=181,duration=0,english="Sandstorm",log_english="Sandstorm",french="Loi de la sécheresse",german="Staubfront",japanese="砂塵の陣"}
buffs[182] = { id=182,duration=0,english="Thunderstorm",log_english="Thunderstorm",french="Loi des orages",german="Gewitterfront",japanese="疾雷の陣"}
buffs[183] = { id=183,duration=0,english="Rainstorm",log_english="Rainstorm",french="Loi des averses",german="Regenfront",japanese="豪雨の陣"}
buffs[184] = { id=184,duration=0,english="Aurorastorm",log_english="Aurorastorm",french="Loi de l'aurore",german="Aurorafront",japanese="極光の陣"}
buffs[185] = { id=185,duration=0,english="Voidstorm",log_english="Voidstorm",french="Loi du crépuscule",german="Nebelfront",japanese="妖霧の陣"}
buffs[186] = { id=186,duration=0,english="Helix",log_english="Helix",french="Thèse",german="Kern",japanese="計略"}
buffs[187] = { id=187,duration=0,english="Sublimation: Activated",log_english="Sublimation: Activated",french="Révisions en cours",german="MP-Anhäufung",japanese="机上演習:蓄積中"}
buffs[188] = { id=188,duration=0,english="Sublimation: Complete",log_english="Sublimation: Complete",french="Révisions terminées",german="MP-Speicher",japanese="机上演習:蓄積完了"}
buffs[189] = { id=189,duration=0,english="Max TP Down",log_english="Max TP Down",french="Max. TP réduit",german="Max TP-Down",japanese="TPmaxダウン"}
buffs[190] = { id=190,duration=0,english="Magic Atk. Boost",log_english="Magic Atk. Boost",french="Attq. magique augmentée",german="Magieattacken-Boost",japanese="魔法攻撃力アップ"}
buffs[191] = { id=191,duration=0,english="Magic Def. Boost",log_english="Magic Def. Boost",french="Déf. magique augmentée",german="Magieverteidigungs-Boost",japanese="魔法防御力アップ"}
buffs[192] = { id=192,duration=0,english="Requiem",log_english="Requiem",french="Requiem",german="Requiem",japanese="レクイエム"}
buffs[193] = { id=193,duration=0,english="Lullaby",log_english="Lullaby",french="Berceuse",german="Wiegenlied",japanese="ララバイ"}
buffs[194] = { id=194,duration=0,english="Elegy",log_english="Elegy",french="Elégie",german="Elegie",japanese="エレジー"}
buffs[195] = { id=195,duration=0,english="Paeon",log_english="Paeon",french="Péan",german="Paeon",japanese="ピーアン"}
buffs[196] = { id=196,duration=0,english="Ballad",log_english="Ballad",french="Ballade",german="Ballade",japanese="バラード"}
buffs[197] = { id=197,duration=0,english="Minne",log_english="Minne",french="Lied",german="Minne",japanese="ミンネ"}
buffs[198] = { id=198,duration=0,english="Minuet",log_english="Minuet",french="Menuet",german="Menuett",japanese="メヌエット"}
buffs[199] = { id=199,duration=0,english="Madrigal",log_english="Madrigal",french="Madrigal",german="Madrigal",japanese="マドリガル"}
buffs[200] = { id=200,duration=0,english="Prelude",log_english="Prelude",french="Prélude",german="Präludium",japanese="プレリュード"}
buffs[201] = { id=201,duration=0,english="Mambo",log_english="Mambo",french="Mambo",german="Mambo",japanese="マンボ"}
buffs[202] = { id=202,duration=0,english="Aubade",log_english="Aubade",french="Aubade",german="Aubade",japanese="オーバード"}
buffs[203] = { id=203,duration=0,english="Pastoral",log_english="Pastoral",french="Pastorale",german="Kirchenlied",japanese="パストラル"}
buffs[204] = { id=204,duration=0,english="Hum",log_english="Hum",french="Chant",german="Summen",japanese="ハミング"}
buffs[205] = { id=205,duration=0,english="Fantasia",log_english="Fantasia",french="Fantaisie",german="Fantasia",japanese="ファンタジア"}
buffs[206] = { id=206,duration=0,english="Operetta",log_english="Operetta",french="Opérette",german="Operette",japanese="オペレッタ"}
buffs[207] = { id=207,duration=0,english="Capriccio",log_english="Capriccio",french="Capriccio",german="Capriccio",japanese="カプリチオ"}
buffs[208] = { id=208,duration=0,english="Serenade",log_english="Serenade",french="Sérénade",german="Serenade",japanese="セレナーデ"}
buffs[209] = { id=209,duration=0,english="Round",log_english="Round",french="Rondo",german="Rondo",japanese="ロンド"}
buffs[210] = { id=210,duration=0,english="Gavotte",log_english="Gavotte",french="Gavotte",german="Gavotte",japanese="ガボット"}
buffs[211] = { id=211,duration=0,english="Fugue",log_english="Fugue",french="Fugue",german="Fuge",japanese="フーガ"}
buffs[212] = { id=212,duration=0,english="Rhapsody",log_english="Rhapsody",french="Rhapsodie",german="Rhapsodie",japanese="ラプソディ"}
buffs[213] = { id=213,duration=0,english="Aria",log_english="Aria",french="Aria",german="Arie",japanese="アリア"}
buffs[214] = { id=214,duration=0,english="March",log_english="March",french="Marche",german="Marsch",japanese="マーチ"}
buffs[215] = { id=215,duration=0,english="Etude",log_english="Etude",french="Etude",german="Etüde",japanese="エチュード"}
buffs[216] = { id=216,duration=0,english="Carol",log_english="Carol",french="Cantique",german="Gesang",japanese="カロル"}
buffs[217] = { id=217,duration=0,english="Threnody",log_english="Threnody",french="Thrène",german="Klagelied",japanese="スレノディ"}
buffs[218] = { id=218,duration=0,english="Hymnus",log_english="Hymnus",french="Hymne",german="Hymne",japanese="ヒムヌス"}
buffs[219] = { id=219,duration=0,english="Mazurka",log_english="Mazurka",french="Mazurka",german="Mazurka",japanese="マズルカ"}
buffs[220] = { id=220,duration=0,english="Sirvente",log_english="Sirvente",french="Sirvente",german="Sirvente",japanese="シルベント"}
buffs[221] = { id=221,duration=0,english="Dirge",log_english="Dirge",french="Mélopée",german="Abenteurer-Klagelied",japanese="ダージュ"}
buffs[222] = { id=222,duration=0,english="Scherzo",log_english="Scherzo",french="Scherzo",german="Scherzo",japanese="スケルツォ"}
buffs[223] = { id=223,duration=0,english="Nocturne",log_english="Nocturne",french="Nocturne",german="Nocturne",japanese="ノクターン"}
buffs[227] = { id=227,duration=0,english="Store TP",log_english="Store TP",french="Réserve TP",german="TP-Lagern",japanese="ストアTP"}
buffs[228] = { id=228,duration=0,english="Embrava",log_english="Embrava",french="Hardiesse",german="Embrava",japanese="オーラ"}
buffs[229] = { id=229,duration=0,english="Manawell",log_english="Manawell",french="Rosée de Mana",german="Mana-Quell",japanese="魔力の雫"}
buffs[230] = { id=230,duration=0,english="Spontaneity",log_english="Spontaneity",french="Spontanéité",german="Spontanität",japanese="クイックマジック"}
buffs[231] = { id=231,duration=0,english="Marcato",log_english="Marcato",french="Marcato",german="Marcato",japanese="マルカート"}
buffs[233] = { id=233,duration=0,english="Auto-Regen",log_english="Auto-Regen",french="Auto-récup",german="Auto-Regenerieren",japanese="オートリジェネ"}
buffs[234] = { id=234,duration=0,english="Auto-Refresh",log_english="Auto-Refresh",french="Auto-recharge",german="Auto-Erfrischen",japanese="オートリフレシュ"}
buffs[235] = { id=235,duration=0,english="Fishing Imagery",log_english="Fishing Imagery",french="Image pêche",german="Angelbilder",japanese="釣りイメージ"}
buffs[236] = { id=236,duration=0,english="Woodworking Imagery",log_english="Woodworking Imagery",french="Image menuiserie",german="Tischlereibilder",japanese="木工イメージ"}
buffs[237] = { id=237,duration=0,english="Smithing Imagery",log_english="Smithing Imagery",french="Image métallurgie",german="Schmiedebilder",japanese="鍛冶イメージ"}
buffs[238] = { id=238,duration=0,english="Goldsmithing Imagery",log_english="Goldsmithing Imagery",french="Image orfèvrerie",german="Goldschmiedebilder",japanese="彫金イメージ"}
buffs[239] = { id=239,duration=0,english="Clothcraft Imagery",log_english="Clothcraft Imagery",french="Image confection",german="Schneiderbilder",japanese="裁縫イメージ"}
buffs[240] = { id=240,duration=0,english="Leathercraft Imagery",log_english="Leathercraft Imagery",french="Image tannerie",german="Ledereibilder",japanese="革細工イメージ"}
buffs[241] = { id=241,duration=0,english="Bonecraft Imagery",log_english="Bonecraft Imagery",french="Image osserie",german="Knochenwerksbilder",japanese="骨細工イメージ"}
buffs[242] = { id=242,duration=0,english="Alchemy Imagery",log_english="Alchemy Imagery",french="Image alchimie",german="Alchemiebilder",japanese="錬金術イメージ"}
buffs[243] = { id=243,duration=0,english="Cooking Imagery",log_english="Cooking Imagery",french="Image cuisine",german="Kochbilder",japanese="調理イメージ"}
buffs[249] = { id=249,duration=0,english="Dedication",log_english="Dedication",french="Assiduité",german="Hingabe",japanese="専心"}
buffs[250] = { id=250,duration=0,english="EF Badge",log_english="EF Badge",french="Ecusson CE",german="ET-Ausweis",japanese="遠征軍参加資格"}
buffs[251] = { id=251,duration=0,english="Food",log_english="Food",french="Nourriture",german="Essen",japanese="食事"}
buffs[252] = { id=252,duration=0,english="Chocobo",log_english="Chocobo",french="Chocobo",german="Chocobo",japanese="チョコボ"}
buffs[253] = { id=253,duration=0,english="Signet",log_english="Signet",french="Sceau",german="Siegel",japanese="シグネット"}
buffs[254] = { id=254,duration=0,english="Battlefield",log_english="Battlefield",french="Champ de bataille",german="Schlachtfeld",japanese="バトルフィールド"}
buffs[256] = { id=256,duration=0,english="Sanction",log_english="Sanction",french="Sanction",german="Sanktion",japanese="サンクション"}
buffs[257] = { id=257,duration=0,english="Besieged",log_english="Besieged",french="Siège",german="Belagerung",japanese="ビシージド"}
buffs[258] = { id=258,duration=0,english="Illusion",log_english="Illusion",french="Illusion",german="Illusion",japanese="イリュージョン"}
buffs[259] = { id=259,duration=0,english="encumbrance",log_english="encumbered",french="Fardeau",german="Bürde",japanese="エンカンバー"}
buffs[260] = { id=260,duration=0,english="Obliviscence",log_english="Obliviscence",french="Oblitération",german="Vergessenheit",japanese="オブリビセンス"}
buffs[261] = { id=261,duration=0,english="impairment",log_english="impaired",french="Handicap",german="Eingriff",japanese="インペア"}
buffs[262] = { id=262,duration=0,english="Omerta",log_english="Omerta",french="Omerta",german="Schweigepflicht",japanese="オメルタ"}
buffs[263] = { id=263,duration=0,english="debilitation",log_english="debilitated",french="Impotence",german="Entkräftung",japanese="デビリテート"}
buffs[264] = { id=264,duration=0,english="Pathos",log_english="Pathos",french="Pathos",german="Pathos",japanese="パトス"}
buffs[265] = { id=265,duration=0,english="Flurry",log_english="Flurry",french="Exaltation",german="Aufregung",japanese="フラーリー"}
buffs[266] = { id=266,duration=0,english="Concentration",log_english="Concentration",french="Concentration",german="Konzentration",japanese="コンセントレーション"}
buffs[267] = { id=267,duration=0,english="Allied Tags",log_english="Allied Tags",french="Marque des alliés",german="Bündniswappen",japanese="アライドタグ"}
buffs[268] = { id=268,duration=0,english="Sigil",log_english="Sigil",french="Sigil",german="Sigille",japanese="シギル"}
buffs[269] = { id=269,duration=0,english="Level Sync",log_english="Level Sync",french="Synchronisation",german="Level-Adaption",japanese="レベルシンク"}
buffs[270] = { id=270,duration=0,english="Aftermath: Lv.1",log_english="Aftermath: Lv.1",french="Contrecoup : Niv. 1",german="Konsequenz: Level 1",japanese="アフターマス:Lv1"}
buffs[271] = { id=271,duration=0,english="Aftermath: Lv.2",log_english="Aftermath: Lv.2",french="Contrecoup : Niv. 2",german="Konsequenz: Level 2",japanese="アフターマス:Lv2"}
buffs[272] = { id=272,duration=0,english="Aftermath: Lv.3",log_english="Aftermath: Lv.3",french="Contrecoup : Niv. 3",german="Konsequenz: Level 3",japanese="アフターマス:Lv3"}
buffs[273] = { id=273,duration=0,english="Aftermath",log_english="Aftermath",french="Contrecoup",german="Konsequenz",japanese="アフターマス"}
buffs[274] = { id=274,duration=0,english="Enlight",log_english="Enlight",french="EndoLumière",german="Licht +",japanese="エンライト"}
buffs[275] = { id=275,duration=0,english="Auspice",log_english="Auspice",french="Auspice",german="Auspizium",japanese="オースピス"}
buffs[276] = { id=276,duration=0,english="Confrontation",log_english="Confrontation",french="Confrontation",german="Konfrontation",japanese="コンフロント"}
buffs[277] = { id=277,duration=0,english="Enfire II",log_english="Enfire II",french="EndoFeu II",german="Feuer ++",japanese="エンファイアII"}
buffs[278] = { id=278,duration=0,english="Enblizzard II",log_english="Enblizzard II",french="EndoGlace II",german="Eis ++",japanese="エンブリザドII"}
buffs[279] = { id=279,duration=0,english="Enaero II",log_english="Enaero II",french="EndoVent II",german="Wind ++",japanese="エンエアロII"}
buffs[280] = { id=280,duration=0,english="Enstone II",log_english="Enstone II",french="EndoPierre II",german="Erde ++",japanese="エンストーンII"}
buffs[281] = { id=281,duration=0,english="Enthunder II",log_english="Enthunder II",french="EndoFoudre II",german="Donner ++",japanese="エンサンダーII"}
buffs[282] = { id=282,duration=0,english="Enwater II",log_english="Enwater II",french="EndoEau II",german="Wasser ++",japanese="エンウォータII"}
buffs[283] = { id=283,duration=0,english="Perfect Defense",log_english="Perfect Defense",french="Défense absolue",german="Perfekte Abwehr",japanese="絶対防御"}
buffs[284] = { id=284,duration=0,english="Egg",log_english="Egg",french="Œuf",german="Ei",japanese="タマゴ"}
buffs[285] = { id=285,duration=0,english="Visitant",log_english="Visitant",french="Aura d'incursion",german="Wallfahrer",japanese="ビジタント"}
buffs[286] = { id=286,duration=0,english="Baramnesia",log_english="Baramnesia",french="AntiAmnésie",german="Amnesieriegel",japanese="バアムネジア"}
buffs[287] = { id=287,duration=0,english="Atma",log_english="Atma",french="Âtma",german="Atma",japanese="アートマ"}
buffs[288] = { id=288,duration=0,english="Endark",log_english="Endark",french="EndoTénèbres",german="Dunkel +",japanese="エンダーク"}
buffs[289] = { id=289,duration=0,english="Enmity Boost",log_english="Enmity Boost",french="Inimitié augmentée",german="Feindseligkeits-Boost",japanese="敵対心アップ"}
buffs[290] = { id=290,duration=0,english="Subtle Blow Plus",log_english="Subtle Blow Plus",french="Coup subtil augmenté",german="Subtilschlag-Boost",japanese="モクシャアップ"}
buffs[291] = { id=291,duration=0,english="Enmity Down",log_english="Enmity Down",french="Inimitié réduite",german="Feindseligkeits-Down",japanese="敵対心ダウン"}
buffs[292] = { id=292,duration=0,english="Pennant",log_english="Pennant",french="Bannière de bastion",german="IFF-Flagge",japanese="ペナント"}
buffs[293] = { id=293,duration=0,english="Negate Petrify",log_english="Negate Petrify",french="NégaPétrification",german="Stein negieren",japanese="ネゲートペトリ"}
buffs[294] = { id=294,duration=0,english="Negate Terror",log_english="Negate Terror",french="NégaTerreur",german="Furcht negieren",japanese="ネゲートテラー"}
buffs[295] = { id=295,duration=0,english="Negate Amnesia",log_english="Negate Amnesia",french="NégaAmnésie",german="Amnesie negieren",japanese="ネゲートアムネジア"}
buffs[296] = { id=296,duration=0,english="Negate Doom",log_english="Negate Doom",french="NégaGlas",german="Verhängnis negieren",japanese="ネゲートドゥーム"}
buffs[297] = { id=297,duration=0,english="Negate Poison",log_english="Negate Poison",french="NégaPoison",german="Gift negieren",japanese="ネゲートポイズン"}
buffs[298] = { id=298,duration=0,english="critical hit evasion down",log_english="critical hit evasion down",french="Coups critiques subis augmentés",german="Krit. Ausweich-Down",japanese="被クリティカルヒット率アップ"}
buffs[299] = { id=299,duration=0,english="Overload",log_english="overloaded",french="Surcharge",german="Überladen",japanese="オーバーロード"}
buffs[300] = { id=300,duration=0,english="Fire Maneuver",log_english="Fire Maneuver",french="Manœuvre feu",german="Feuermanöver",japanese="ファイアマニューバ"}
buffs[301] = { id=301,duration=0,english="Ice Maneuver",log_english="Ice Maneuver",french="Manœuvre glace",german="Eismanöver",japanese="アイスマニューバ"}
buffs[302] = { id=302,duration=0,english="Wind Maneuver",log_english="Wind Maneuver",french="Manœuvre vent",german="Windmanöver",japanese="ウィンドマニューバ"}
buffs[303] = { id=303,duration=0,english="Earth Maneuver",log_english="Earth Maneuver",french="Manœuvre terre",german="Erdmanöver",japanese="アースマニューバ"}
buffs[304] = { id=304,duration=0,english="Thunder Maneuver",log_english="Thunder Maneuver",french="Manœuvre foudre",german="Donnermanöver",japanese="サンダーマニューバ"}
buffs[305] = { id=305,duration=0,english="Water Maneuver",log_english="Water Maneuver",french="Manœuvre eau",german="Wassermanöver",japanese="ウォータマニューバ"}
buffs[306] = { id=306,duration=0,english="Light Maneuver",log_english="Light Maneuver",french="Manœuvre lumière",german="Lichtmanöver",japanese="ライトマニューバ"}
buffs[307] = { id=307,duration=0,english="Dark Maneuver",log_english="Dark Maneuver",french="Manœuvre ténèbres",german="Schattenmanöver",japanese="ダークマニューバ"}
buffs[308] = { id=308,duration=0,english="Double-Up Chance",log_english="Double-Up Chance",french="Chance de Surenchère",german="Doppelter Einsatz",japanese="ダブルアップチャンス"}
buffs[309] = { id=309,duration=0,english="Bust",log_english="Bust",french="Bust",german="Pleite",japanese="バスト"}
buffs[310] = { id=310,duration=0,english="Fighter's Roll",log_english="Fighter's Roll",french="Jet combattant",german="Kämpfer-Wurf",japanese="ファイターズロール"}
buffs[311] = { id=311,duration=0,english="Monk's Roll",log_english="Monk's Roll",french="Jet du moine",german="Mönchs-Wurf",japanese="モンクスロール"}
buffs[312] = { id=312,duration=0,english="Healer's Roll",log_english="Healer's Roll",french="Jet du guérisseur",german="Heiler-Wurf",japanese="ヒーラーズロール"}
buffs[313] = { id=313,duration=0,english="Wizard's Roll",log_english="Wizard's Roll",french="Jet du sorcier",german="Magier-Wurf",japanese="ウィザーズロール"}
buffs[314] = { id=314,duration=0,english="Warlock's Roll",log_english="Warlock's Roll",french="Jet enchanteur",german="Hexer-Wurf",japanese="ワーロックスロール"}
buffs[315] = { id=315,duration=0,english="Rogue's Roll",log_english="Rogue's Roll",french="Jet du brigand",german="Gauner-Wurf",japanese="ローグズロール"}
buffs[316] = { id=316,duration=0,english="Gallant's Roll",log_english="Gallant's Roll",french="Jet du preux",german="Galant-Wurf",japanese="ガランツロール"}
buffs[317] = { id=317,duration=0,english="Chaos Roll",log_english="Chaos Roll",french="Jet du chaos",german="Chaos-Wurf",japanese="カオスロール"}
buffs[318] = { id=318,duration=0,english="Beast Roll",log_english="Beast Roll",french="Jet de la bête",german="Bestien-Wurf",japanese="ビーストロール"}
buffs[319] = { id=319,duration=0,english="Choral Roll",log_english="Choral Roll",french="Jet du chant",german="Choral-Wurf",japanese="コーラルロール"}
buffs[320] = { id=320,duration=0,english="Hunter's Roll",log_english="Hunter's Roll",french="Jet du chasseur",german="Jäger-Wurf",japanese="ハンターズロール"}
buffs[321] = { id=321,duration=0,english="Samurai Roll",log_english="Samurai Roll",french="Jet du samouraï",german="Samurai-Wurf",japanese="サムライロール"}
buffs[322] = { id=322,duration=0,english="Ninja Roll",log_english="Ninja Roll",french="Jet du ninja",german="Ninja-Wurf",japanese="ニンジャロール"}
buffs[323] = { id=323,duration=0,english="Drachen Roll",log_english="Drachen Roll",french="Jet du drachen",german="Draken-Wurf",japanese="ドラケンロール"}
buffs[324] = { id=324,duration=0,english="Evoker's Roll",log_english="Evoker's Roll",french="Jet de l'adjurateur",german="Rufer-Wurf",japanese="エボカーズロール"}
buffs[325] = { id=325,duration=0,english="Magus's Roll",log_english="Magus's Roll",french="Jet du mage",german="Magus-Wurf",japanese="メガスズロール"}
buffs[326] = { id=326,duration=0,english="Corsair's Roll",log_english="Corsair's Roll",french="Jet du corsaire",german="Piraten-Wurf",japanese="コルセアズロール"}
buffs[327] = { id=327,duration=0,english="Puppet Roll",log_english="Puppet Roll",french="Jet du pantin",german="Puppen-Wurf",japanese="パペットロール"}
buffs[328] = { id=328,duration=0,english="Dancer's Roll",log_english="Dancer's Roll",french="Jet du danseur",german="Flamenco-Wurf",japanese="ダンサーロール"}
buffs[329] = { id=329,duration=0,english="Scholar's Roll",log_english="Scholar's Roll",french="Jet de l'érudit",german="Grimoire-Wurf",japanese="スカラーロール"}
buffs[330] = { id=330,duration=0,english="Bolter's Roll",log_english="Bolter's Roll",french="Jet du coureur",german="Chocobo-Wurf",japanese="ボルターズロール"}
buffs[331] = { id=331,duration=0,english="Caster's Roll",log_english="Caster's Roll",french="Jet de l'incantateur",german="Dozenten-Wurf",japanese="キャスターズロール"}
buffs[332] = { id=332,duration=0,english="Courser's Roll",log_english="Courser's Roll",french="Jet du veneur",german="Korsaren-Wurf",japanese="コアサーズロール"}
buffs[333] = { id=333,duration=0,english="Blitzer's Roll",log_english="Blitzer's Roll",french="Jet de l'agresseur",german="Brachial-Wurf",japanese="ブリッツァロール"}
buffs[334] = { id=334,duration=0,english="Tactician's Roll",log_english="Tactician's Roll",french="Jet du tacticien",german="Taktiker-Wurf",japanese="タクティックロール"}
buffs[335] = { id=335,duration=0,english="Allies' Roll",log_english="Allies' Roll",french="Jet de l'allié",german="Domino-Wurf",japanese="アライズロール"}
buffs[336] = { id=336,duration=0,english="Miser's Roll",log_english="Miser's Roll",french="Jet de l'économe",german="Knauser-Wurf",japanese="マイザーロール"}
buffs[337] = { id=337,duration=0,english="Companion's Roll",log_english="Companion's Roll",french="Jet du compère",german="Kompagnon-Wurf",japanese="コンパニオンロール"}
buffs[338] = { id=338,duration=0,english="Avenger's Roll",log_english="Avenger's Roll",french="Jet du vengeur",german="Rächer-Wurf",japanese="カウンターロール"}
buffs[340] = { id=340,duration=0,english="Warrior's Charge",log_english="Warrior's Charge",french="Charge du guerrier",german="Kriegerwut",japanese="ウォリアーチャージ"}
buffs[341] = { id=341,duration=0,english="Formless Strikes",log_english="Formless Strikes",french="Coups informes",german="Formlose Schläge",japanese="無想無念"}
buffs[342] = { id=342,duration=0,english="Assassin's Charge",log_english="Assassin's Charge",french="Charge assassine",german="Attentäterwut",japanese="アサシンチャージ"}
buffs[343] = { id=343,duration=0,english="Feint",log_english="Feint",french="Feinte",german="Finte",japanese="フェイント"}
buffs[344] = { id=344,duration=0,english="Fealty",log_english="Fealty",french="Fidélité",german="Lehnseid",japanese="フィールティ"}
buffs[345] = { id=345,duration=0,english="Dark Seal",log_english="Dark Seal",french="Sceau ténébreux",german="Dunkles Siegel",japanese="ダークシール"}
buffs[346] = { id=346,duration=0,english="Diabolic Eye",log_english="Diabolic Eye",french="Œil diabolique",german="Diabolisches Auge",japanese="ディアボリクアイ"}
buffs[347] = { id=347,duration=0,english="Nightingale",log_english="Nightingale",french="Rossignol",german="Nachtigall",japanese="ナイチンゲール"}
buffs[348] = { id=348,duration=0,english="Troubadour",log_english="Troubadour",french="Troubadour",german="Troubadour",japanese="トルバドゥール"}
buffs[349] = { id=349,duration=0,english="Killer Instinct",log_english="Killer Instinct",french="Instinct de tueur",german="Killer-Instinkt",japanese="K.インスティンクト"}
buffs[350] = { id=350,duration=0,english="Stealth Shot",log_english="Stealth Shot",french="Tir furtif",german="Tarnschuss",japanese="ステルスショット"}
buffs[351] = { id=351,duration=0,english="Flashy Shot",log_english="Flashy Shot",french="Tir flagrant",german="Grellschuss",japanese="フラッシーショット"}
buffs[352] = { id=352,duration=0,english="Sange",log_english="Sange",french="Sange",german="Sange",japanese="散華"}
buffs[353] = { id=353,duration=0,english="Hasso",log_english="Hasso",french="Hasso",german="Hasso",japanese="八双"}
buffs[354] = { id=354,duration=0,english="Seigan",log_english="Seigan",french="Seigan",german="Seigan",japanese="星眼"}
buffs[355] = { id=355,duration=0,english="Convergence",log_english="Convergence",french="Convergence",german="Konvergenz",japanese="コンバージェンス"}
buffs[356] = { id=356,duration=0,english="Diffusion",log_english="Diffusion",french="Diffusion",german="Diffusion",japanese="ディフュージョン"}
buffs[357] = { id=357,duration=0,english="Snake Eye",log_english="Snake Eye",french="As",german="Schlangenauge",japanese="スネークアイ"}
buffs[358] = { id=358,duration=0,english="Light Arts",log_english="Light Arts",french="Grimoire blanc",german="Weißes Grimoire",japanese="白のグリモア"}
buffs[359] = { id=359,duration=0,english="Dark Arts",log_english="Dark Arts",french="Grimoire noir",german="Schwarz. Grimoire",japanese="黒のグリモア"}
buffs[360] = { id=360,duration=0,english="Penury",log_english="Penury",french="Modestie",german="Ex Deo",japanese="簡素清貧の章"}
buffs[361] = { id=361,duration=0,english="Parsimony",log_english="Parsimony",french="Parcimonie",german="Ex nihilo",japanese="勤倹小心の章"}
buffs[362] = { id=362,duration=0,english="Celerity",log_english="Celerity",french="Célérité",german="Tempus fugit",japanese="電光石火の章"}
buffs[363] = { id=363,duration=0,english="Alacrity",log_english="Alacrity",french="Alacrité",german="Tempus vincit",japanese="疾風迅雷の章"}
buffs[364] = { id=364,duration=0,english="Rapture",log_english="Rapture",french="Fougue",german="Fiat lux",japanese="意気昂然の章"}
buffs[365] = { id=365,duration=0,english="Ebullience",log_english="Ebullience",french="Ebullition",german="Ultima ratio",japanese="気炎万丈の章"}
buffs[366] = { id=366,duration=0,english="Accession",log_english="Accession",french="Avènement",german="Summum bonum",japanese="女神降臨の章"}
buffs[367] = { id=367,duration=0,english="Manifestation",log_english="Manifestation",french="Manifestation",german="Summum malum",japanese="精霊光来の章"}
buffs[368] = { id=368,duration=0,english="Drain Samba",log_english="Drain Samba",french="Samba Spoliation",german="Vampir-Samba",japanese="ドレインサンバ"}
buffs[369] = { id=369,duration=0,english="Aspir Samba",log_english="Aspir Samba",french="Samba Aspiration",german="Leech-Samba",japanese="アスピルサンバ"}
buffs[370] = { id=370,duration=0,english="Haste Samba",log_english="Haste Samba",french="Samba Hâte",german="Kraken-Samba",japanese="ヘイストサンバ"}
buffs[371] = { id=371,duration=0,english="Velocity Shot",log_english="Velocity Shot",french="Tir véloce",german="Schnell-Lader",japanese="ベロシティショット"}
buffs[375] = { id=375,duration=0,english="Building Flourish",log_english="Building Flourish",french="Pirouette intense",german="Odins Polka",japanese="B.フラリッシュ"}
buffs[376] = { id=376,duration=0,english="Trance",log_english="Trance",french="Transe",german="Trance",japanese="トランス"}
buffs[377] = { id=377,duration=0,english="Tabula Rasa",log_english="Tabula Rasa",french="Tabula rasa",german="Tabula rasa",japanese="連環計"}
buffs[378] = { id=378,duration=0,english="Drain Daze",log_english="Drain Daze",french="Stupeur spoliante",german="V. Benommenheit",japanese="ドレインデイズ"}
buffs[379] = { id=379,duration=0,english="Aspir Daze",log_english="Aspir Daze",french="Stupeur aspirante",german="L. Benommenheit",japanese="アスピルデイズ"}
buffs[380] = { id=380,duration=0,english="Haste Daze",log_english="Haste Daze",french="Stupeur hâtive",german="K. Benommenheit",japanese="ヘイストデイズ"}
buffs[381] = { id=381,duration=0,english="Finishing Move",log_english="Finishing Move",french="Mouvement final",german="Tanzmanöver",japanese="フィニシングムーブ"}
buffs[382] = { id=382,duration=0,english="Finishing Move",log_english="Finishing Move",french="Mouvement final",german="Tanzmanöver",japanese="フィニシングムーブ"}
buffs[383] = { id=383,duration=0,english="Finishing Move",log_english="Finishing Move",french="Mouvement final",german="Tanzmanöver",japanese="フィニシングムーブ"}
buffs[384] = { id=384,duration=0,english="Finishing Move",log_english="Finishing Move",french="Mouvement final",german="Tanzmanöver",japanese="フィニシングムーブ"}
buffs[385] = { id=385,duration=0,english="Finishing Move",log_english="Finishing Move",french="Mouvement final",german="Tanzmanöver",japanese="フィニシングムーブ"}
buffs[386] = { id=386,duration=0,english="Lethargic Daze",log_english="Lethargic Daze",french="Stupeur ankylosante",german="Pirouette",japanese="クイックステップ"}
buffs[387] = { id=387,duration=0,english="Lethargic Daze",log_english="Lethargic Daze",french="Stupeur ankylosante",german="Pirouette",japanese="クイックステップ"}
buffs[388] = { id=388,duration=0,english="Lethargic Daze",log_english="Lethargic Daze",french="Stupeur ankylosante",german="Pirouette",japanese="クイックステップ"}
buffs[389] = { id=389,duration=0,english="Lethargic Daze",log_english="Lethargic Daze",french="Stupeur ankylosante",german="Pirouette",japanese="クイックステップ"}
buffs[390] = { id=390,duration=0,english="Lethargic Daze",log_english="Lethargic Daze",french="Stupeur ankylosante",german="Pirouette",japanese="クイックステップ"}
buffs[391] = { id=391,duration=0,english="Sluggish Daze",log_english="Sluggish Daze",french="Stupeur débilitante",german="Ausfallschritt",japanese="ボックスステップ"}
buffs[392] = { id=392,duration=0,english="Sluggish Daze",log_english="Sluggish Daze",french="Stupeur débilitante",german="Ausfallschritt",japanese="ボックスステップ"}
buffs[393] = { id=393,duration=0,english="Sluggish Daze",log_english="Sluggish Daze",french="Stupeur débilitante",german="Ausfallschritt",japanese="ボックスステップ"}
buffs[394] = { id=394,duration=0,english="Sluggish Daze",log_english="Sluggish Daze",french="Stupeur débilitante",german="Ausfallschritt",japanese="ボックスステップ"}
buffs[395] = { id=395,duration=0,english="Sluggish Daze",log_english="Sluggish Daze",french="Stupeur débilitante",german="Ausfallschritt",japanese="ボックスステップ"}
buffs[396] = { id=396,duration=0,english="Weakened Daze",log_english="Weakened Daze",french="Stupeur abrutissante",german="Schuhplattler",japanese="スタッターステップ"}
buffs[397] = { id=397,duration=0,english="Weakened Daze",log_english="Weakened Daze",french="Stupeur abrutissante",german="Schuhplattler",japanese="スタッターステップ"}
buffs[398] = { id=398,duration=0,english="Weakened Daze",log_english="Weakened Daze",french="Stupeur abrutissante",german="Schuhplattler",japanese="スタッターステップ"}
buffs[399] = { id=399,duration=0,english="Weakened Daze",log_english="Weakened Daze",french="Stupeur abrutissante",german="Schuhplattler",japanese="スタッターステップ"}
buffs[400] = { id=400,duration=0,english="Weakened Daze",log_english="Weakened Daze",french="Stupeur abrutissante",german="Schuhplattler",japanese="スタッターステップ"}
buffs[401] = { id=401,duration=0,english="Addendum: White",log_english="Addendum: White",french="Addenda blanc",german="Addendum albus",japanese="白の補遺"}
buffs[402] = { id=402,duration=0,english="Addendum: Black",log_english="Addendum: Black",french="Addenda noir",german="Addendum niger",japanese="黒の補遺"}
buffs[403] = { id=403,duration=0,english="Reprisal",log_english="Reprisal",french="Représailles",german="Reflexion",japanese="リアクト"}
buffs[404] = { id=404,duration=0,english="Magic Evasion Down",log_english="Magic Evasion Down",french="Esquive mag. réduite",german="Magie-Ausweich-Down",japanese="魔法回避率ダウン"}
buffs[405] = { id=405,duration=0,english="Retaliation",log_english="Retaliation",french="Contre-attaque",german="Sühne",japanese="リタリエーション"}
buffs[406] = { id=406,duration=0,english="Footwork",log_english="Footwork",french="Jeu de jambes",german="Beinarbeit",japanese="猫足立ち"}
buffs[407] = { id=407,duration=0,english="Klimaform",log_english="Klimaform",french="Traité de réflexion",german="Prognostica",japanese="虚誘掩殺の策"}
buffs[408] = { id=408,duration=0,english="Sekkanoki",log_english="Sekkanoki",french="Sekkanoki",german="Sekkanoki",japanese="石火之機"}
buffs[409] = { id=409,duration=0,english="Pianissimo",log_english="Pianissimo",french="Pianissimo",german="Pianissimo",japanese="ピアニッシモ"}
buffs[410] = { id=410,duration=0,english="Saber Dance",log_english="Saber Dance",french="Danse du sabre",german="Klingentanz",japanese="剣の舞い"}
buffs[411] = { id=411,duration=0,english="Fan Dance",log_english="Fan Dance",french="Danse de l'éventail",german="Fächertanz",japanese="扇の舞い"}
buffs[412] = { id=412,duration=0,english="Altruism",log_english="Altruism",french="Altruisme",german="Utile dulci",japanese="不惜身命の章"}
buffs[413] = { id=413,duration=0,english="Focalization",log_english="Focalization",french="Focalisation",german="Lege artis",japanese="一心精進の章"}
buffs[414] = { id=414,duration=0,english="Tranquility",log_english="Tranquility",french="Humilité",german="Modus incognitus",japanese="天衣無縫の章"}
buffs[415] = { id=415,duration=0,english="Equanimity",log_english="Equanimity",french="Ataraxie",german="Modus arcanus",japanese="無憂無風の章"}
buffs[416] = { id=416,duration=0,english="Enlightenment",log_english="Enlightenment",french="Apaisement",german="Licentia poetica",japanese="大悟徹底"}
buffs[417] = { id=417,duration=0,english="Afflatus Solace",log_english="Afflatus Solace",french="Consolation",german="Afflatus solatii",japanese="ハートオブソラス"}
buffs[418] = { id=418,duration=0,english="Afflatus Misery",log_english="Afflatus Misery",french="Adversité",german="Afflatus miseriae",japanese="ハートオブミゼリ"}
buffs[419] = { id=419,duration=0,english="Composure",log_english="Composure",french="Aplomb",german="Fassung",japanese="コンポージャー"}
buffs[420] = { id=420,duration=0,english="Yonin",log_english="Yonin",french="Yonin",german="Sonnenkunst",japanese="陽忍"}
buffs[421] = { id=421,duration=0,english="Innin",log_english="Innin",french="Innin",german="Schattenkunst",japanese="陰忍"}
buffs[422] = { id=422,duration=0,english="Carbuncle's Favor",log_english="Carbuncle's Favor",french="Egide de Carbuncle",german="Carbuncles Schutz",japanese="カーバンクルの加護"}
buffs[423] = { id=423,duration=0,english="Ifrit's Favor",log_english="Ifrit's Favor",french="Egide d'Ifrit",german="Ifrits Schutz",japanese="イフリートの加護"}
buffs[424] = { id=424,duration=0,english="Shiva's Favor",log_english="Shiva's Favor",french="Egide de Shiva",german="Shivas Schutz",japanese="シヴァの加護"}
buffs[425] = { id=425,duration=0,english="Garuda's Favor",log_english="Garuda's Favor",french="Egide de Garuda",german="Garudas Schutz",japanese="ガルーダの加護"}
buffs[426] = { id=426,duration=0,english="Titan's Favor",log_english="Titan's Favor",french="Egide de Titan",german="Titans Schutz",japanese="タイタンの加護"}
buffs[427] = { id=427,duration=0,english="Ramuh's Favor",log_english="Ramuh's Favor",french="Egide de Ramuh",german="Ramuhs Schutz",japanese="ラムウの加護"}
buffs[428] = { id=428,duration=0,english="Leviathan's Favor",log_english="Leviathan's Favor",french="Egide de Leviathan",german="Leviathans Schutz",japanese="リヴァイアサンの加護"}
buffs[429] = { id=429,duration=0,english="Fenrir's Favor",log_english="Fenrir's Favor",french="Egide de Fenrir",german="Fenrirs Schutz",japanese="フェンリルの加護"}
buffs[430] = { id=430,duration=0,english="Diabolos's Favor",log_english="Diabolos's Favor",french="Egide de Diabolos",german="Diabolos' Schutz",japanese="ディアボロスの加護"}
buffs[431] = { id=431,duration=0,english="Avatar's Favor",log_english="Avatar's Favor",french="Egide",german="Avatar-Empathie",japanese="神獣の加護"}
buffs[432] = { id=432,duration=0,english="Multi Strikes",log_english="Multi Strikes",french="Attaque multiple",german="Multi-Attacke",japanese="マルチアタック"}
buffs[433] = { id=433,duration=0,english="Double Shot",log_english="Double Shot",french="Double tir",german="Doppelschuss",japanese="ダブルショット"}
buffs[434] = { id=434,duration=0,english="Transcendency",log_english="Transcendency",french="Puissance des dieux",german="Göttertrunk",japanese="天神地祇"}
buffs[435] = { id=435,duration=0,english="Restraint",log_english="Restraint",french="Retenue",german="Beherrschung",japanese="リストレント"}
buffs[436] = { id=436,duration=0,english="Perfect Counter",log_english="Perfect Counter",french="Riposte absolue",german="Super-Konter",japanese="絶対カウンター"}
buffs[437] = { id=437,duration=0,english="Mana Wall",log_english="Mana Wall",french="Barrière de Mana",german="Mana-Wall",japanese="マナウォール"}
buffs[438] = { id=438,duration=0,english="Divine Emblem",log_english="Divine Emblem",french="Emblème divin",german="Gottesemblem",japanese="神聖の印"}
buffs[439] = { id=439,duration=0,english="Nether Void",log_english="Nether Void",french="Vacuité des limbes",german="Niederes Nichts",japanese="ネザーヴォイド"}
buffs[440] = { id=440,duration=0,english="Sengikori",log_english="Sengikori",french="Sengikori",german="Sengikori",japanese="先義後利"}
buffs[441] = { id=441,duration=0,english="Futae",log_english="Futae",french="Futae",german="Futae",japanese="二重"}
buffs[442] = { id=442,duration=0,english="Presto",log_english="Presto",french="Presto",german="Degagé",japanese="プレスト"}
buffs[443] = { id=443,duration=0,english="Climactic Flourish",log_english="Climactic Flourish",french="Pirouette virulente",german="Wogende Polka",japanese="C.フラリッシュ"}
buffs[444] = { id=444,duration=0,english="Copy Image (2)",log_english="Copy Image (2)",french="Réplique (2)",german="Kopiebild (2)",japanese="分身(2)"}
buffs[445] = { id=445,duration=0,english="Copy Image (3)",log_english="Copy Image (3)",french="Réplique (3)",german="Kopiebild (3)",japanese="分身(3)"}
buffs[446] = { id=446,duration=0,english="Copy Image (4+)",log_english="Copy Image (4+)",french="Réplique (4+)",german="Kopiebild (4+)",japanese="分身(4+)"}
buffs[447] = { id=447,duration=0,english="Multi Shots",log_english="Multi Shots",french="Tir multiple",german="Multi-Schuss",japanese="マルチショット"}
buffs[448] = { id=448,duration=0,english="Bewildered Daze",log_english="Bewildered Daze",french="Stupeur accablante",german="Felinenschritt",japanese="フェザーステップ"}
buffs[449] = { id=449,duration=0,english="Bewildered Daze",log_english="Bewildered Daze",french="Stupeur accablante",german="Felinenschritt",japanese="フェザーステップ"}
buffs[450] = { id=450,duration=0,english="Bewildered Daze",log_english="Bewildered Daze",french="Stupeur accablante",german="Felinenschritt",japanese="フェザーステップ"}
buffs[451] = { id=451,duration=0,english="Bewildered Daze",log_english="Bewildered Daze",french="Stupeur accablante",german="Felinenschritt",japanese="フェザーステップ"}
buffs[452] = { id=452,duration=0,english="Bewildered Daze",log_english="Bewildered Daze",french="Stupeur accablante",german="Felinenschritt",japanese="フェザーステップ"}
buffs[453] = { id=453,duration=0,english="Divine Caress",log_english="Divine Caress",french="Caresse divine",german="Göttersalbung",japanese="女神の愛撫"}
buffs[454] = { id=454,duration=0,english="Saboteur",log_english="Saboteur",french="Persévérance",german="Debilitas ",japanese="サボトゥール"}
buffs[455] = { id=455,duration=0,english="Tenuto",log_english="Tenuto",french="Tenuto",german="Tenuto",japanese="テヌート"}
buffs[456] = { id=456,duration=0,english="Spur",log_english="Spur",french="En avant !",german="Anspornen",japanese="気張れ"}
buffs[457] = { id=457,duration=0,english="Efflux",log_english="Efflux",french="Effusion",german="Efflux",japanese="エフラックス"}
buffs[458] = { id=458,duration=0,english="Earthen Armor",log_english="Earthen Armor",french="Armure tellurique",german="Gaia-Panzer",japanese="大地の鎧"}
buffs[459] = { id=459,duration=0,english="Divine Caress",log_english="Divine Caress",french="Caresse divine",german="Göttersalbung",japanese="女神の愛撫"}
buffs[460] = { id=460,duration=0,english="Blood Rage",log_english="Blood Rage",french="Rage sanguinaire",german="Blutrausch",japanese="ブラッドレイジ"}
buffs[461] = { id=461,duration=0,english="Impetus",log_english="Impetus",french="Impulsivité",german="Impetus",japanese="インピタス"}
buffs[462] = { id=462,duration=0,english="Conspirator",log_english="Conspirator",french="Conspirateur",german="Verschwörer",japanese="コンスピレーター"}
buffs[463] = { id=463,duration=0,english="Sepulcher",log_english="Sepulcher",french="Nexus sépulcral",german="Sakraler Bannspruch",japanese="セプルカー"}
buffs[464] = { id=464,duration=0,english="Arcane Crest",log_english="Arcane Crest",french="Nexus arcanique",german="Arcanabann",japanese="アルケインクレスト"}
buffs[465] = { id=465,duration=0,english="Hamanoha",log_english="Hamanoha",french="Nexus démoniaque",german="Hamanoha",japanese="破魔の刃"}
buffs[466] = { id=466,duration=0,english="Dragon Breaker",log_english="Dragon Breaker",french="Nexus draconique",german="Drachenbrecher",japanese="ドラゴンブレイカー"}
buffs[467] = { id=467,duration=0,english="Triple Shot",log_english="Triple Shot",french="Triple tir",german="Dreifachschuss",japanese="トリプルショット"}
buffs[468] = { id=468,duration=0,english="Striking Flourish",log_english="Striking Flourish",french="Pirouette cinglante",german="Doppelschlag-Polka",japanese="S.フラリッシュ"}
buffs[469] = { id=469,duration=0,english="Perpetuance",log_english="Perpetuance",french="Perpétuation",german="Bonum Auxilium",japanese="令狸執鼠の章"}
buffs[470] = { id=470,duration=0,english="Immanence",log_english="Immanence",french="Immanence",german="Dominus Elementorum ",japanese="震天動地の章"}
buffs[471] = { id=471,duration=0,english="Migawari",log_english="Migawari",french="Migawari",german="Migawari",japanese="身替"}
buffs[472] = { id=472,duration=0,english="Ternary Flourish",log_english="Ternary Flourish",french="Pirouette ternaire",german="Ternär-Polka",japanese="T.フラリッシュ"}
buffs[473] = { id=473,duration=0,english="muddle",log_english="muddled",french="Objets inutilisables",german="Torkel",japanese="アイテム使用不可"}
buffs[474] = { id=474,duration=0,english="Prowess",log_english="Prowess",french="Prouesse temporaire",german="Elan",japanese="一時技能"}
buffs[475] = { id=475,duration=0,english="Voidwatcher",log_english="Voidwatcher",french="Milice des abîmes",german="Abyssus-Wacht",japanese="ヴォイドウォッチャー"}
buffs[476] = { id=476,duration=0,english="Ensphere",log_english="Ensphere",french="Sphère bénéfique",german="Sphäre",japanese="インスフィア"}
buffs[477] = { id=477,duration=0,english="Sacrosanctity",log_english="Sacrosanctity",french="Sacro-sainteté",german="Sacrosanctitas",japanese="女神の聖域"}
buffs[478] = { id=478,duration=0,english="Palisade",log_english="Palisade",french="Palissade",german="Palisade",japanese="パリセード"}
buffs[479] = { id=479,duration=0,english="Scarlet Delirium",log_english="Scarlet Delirium",french="Frénésie écarlate",german="Leidensdelirium",japanese="レッドデリリアム"}
buffs[480] = { id=480,duration=0,english="Scarlet Delirium",log_english="Scarlet Delirium",french="Frénésie écarlate",german="Leidensdelirium",japanese="レッドデリリアム"}
buffs[482] = { id=482,duration=0,english="Decoy Shot",log_english="Decoy Shot",french="Tir leurre",german="Täuschungsschuss",japanese="デコイショット"}
buffs[483] = { id=483,duration=0,english="Hagakure",log_english="Hagakure",french="Hagakure",german="Hagakure",japanese="葉隠"}
buffs[484] = { id=484,duration=0,english="Issekigan",log_english="Issekigan",french="Issekigan",german="Issekigan",japanese="一隻眼"}
buffs[485] = { id=485,duration=0,english="Unbridled Learning",log_english="Unbridled Learning",french="Savoir irréfréné",german="Ungezähmtes Wissen",japanese="ノートリアスナレッジ"}
buffs[486] = { id=486,duration=0,english="Counter Boost",log_english="Counter Boost",french="Bonus riposte",german="Konter-Boost",japanese="カウンターアップ"}
buffs[487] = { id=487,duration=0,english="Endrain",log_english="Endrain",french="EndoSpoliation",german="Aussaugen +",japanese="エンドレイン"}
buffs[488] = { id=488,duration=0,english="Enaspir",log_english="Enaspir",french="EndoAspiration",german="Osmose +",japanese="エンアスピル"}
buffs[489] = { id=489,duration=0,english="Afterglow",log_english="Afterglow",french="Répercussion",german="Nachschimmern",japanese="アフターグロウ"}
buffs[490] = { id=490,duration=0,english="Brazen Rush",log_english="Brazen Rush",french="Ruée hardie",german="Wilder Ansturm",japanese="ブラーゼンラッシュ"}
buffs[491] = { id=491,duration=0,english="Inner Strength",log_english="Inner Strength",french="Force intérieure",german="Innere Stärke",japanese="インナーストレングス"}
buffs[492] = { id=492,duration=0,english="Asylum",log_english="Asylum",french="Manteau divin",german="Obhut",japanese="女神の羽衣"}
buffs[493] = { id=493,duration=0,english="Subtle Sorcery",log_english="Subtle Sorcery",french="Sorcellerie subtile",german="Subtile Zauberei",japanese="サテルソーサリー"}
buffs[494] = { id=494,duration=0,english="Stymie",log_english="Stymie",french="Obstruction",german="Sackgasse",japanese="スタイミー"}
buffs[496] = { id=496,duration=0,english="Intervene",log_english="Intervene",french="Intervention",german="Intervention",japanese="インターヴィーン"}
buffs[497] = { id=497,duration=0,english="Soul Enslavement",log_english="Soul Enslavement",french="Vile consumation",german="Seelenfessel",japanese="ソールエンスレーヴ"}
buffs[498] = { id=498,duration=0,english="Unleash",log_english="Unleash",french="Débridement",german="Entfesseln",japanese="アンリーシュ"}
buffs[499] = { id=499,duration=0,english="Clarion Call",log_english="Clarion Call",french="Appel du clairon",german="Fanfarenstoß",japanese="クラリオンコール"}
buffs[500] = { id=500,duration=0,english="Overkill",log_english="Overkill",french="Mitraillage",german="Übermacht",japanese="オーバーキル"}
buffs[501] = { id=501,duration=0,english="Yaegasumi",log_english="Yaegasumi",french="Yaegasumi",german="Yaegasumi",japanese="八重霞"}
buffs[502] = { id=502,duration=0,english="Mikage",log_english="Mikage",french="Mikage",german="Mikage",japanese="身影"}
buffs[503] = { id=503,duration=0,english="Fly High",log_english="Fly High",french="Haut vol",german="Höhenflug",japanese="フライハイ"}
buffs[504] = { id=504,duration=0,english="Astral Conduit",log_english="Astral Conduit",french="Voie astrale",german="Astraler Leiter",japanese="アストラルパッセージ"}
buffs[505] = { id=505,duration=0,english="Unbridled Wisdom",log_english="Unbridled Wisdom",french="Sagesse irréfrénée",german="Ungezähmte Weisheit",japanese="N.ウィズドム"}
buffs[507] = { id=507,duration=0,english="Grand Pas",log_english="Grand Pas",french="Grand pas",german="Kabinettstück",japanese="グランドパー"}
buffs[508] = { id=508,duration=0,english="Widened Compass",log_english="Widened Compass",french="Compas élargi",german="Superkompass",japanese="ワイデンコンパス"}
buffs[509] = { id=509,duration=0,english="Odyllic Subterfuge",log_english="Odyllic Subterfuge",french="Subterfuge odique",german="Ode an Od",japanese="オディリックサブタ"}
buffs[510] = { id=510,duration=0,english="Ergon Might",log_english="Ergon Might",french="Energie ergonique",german="Ergonische Kraft",japanese="エルゴンパワー"}
buffs[511] = { id=511,duration=0,english="Reive Mark",log_english="Reive Mark",french="Marque de Raid",german="Vorstoß-Abzeichen",japanese="レイヴシンボル"}
buffs[512] = { id=512,duration=0,english="Ionis",log_english="Ionis",french="Ionis",german="Ionis",japanese="イオニス"}
buffs[513] = { id=513,duration=0,english="Bolster",log_english="bolstered",french="Géodynamisme",german="Augmentierung",japanese="ボルスター"}
buffs[515] = { id=515,duration=0,english="Lasting Emanation",log_english="Lasting Emanation",french="Emanation durable",german="Aura der Genügsamkeit",japanese="エンデュアエマネイト"}
buffs[516] = { id=516,duration=0,english="Ecliptic Attrition",log_english="Ecliptic Attrition",french="Renforcement sphérique",german="Vollkommener Kreis",japanese="サークルエンリッチ"}
buffs[517] = { id=517,duration=0,english="Collimated Fervor",log_english="Collimated Fervor",french="Ferveur collimatée",german="Kollimativer Rausch",japanese="コリメイトファーバー"}
buffs[518] = { id=518,duration=0,english="Dematerialize",log_english="Dematerialize",french="Dématérialisation",german="Dematerialisation",japanese="デマテリアライズ"}
buffs[519] = { id=519,duration=0,english="Theurgic Focus",log_english="Theurgic Focus",french="Focalisation thaumaturgique",german="Thaumaturgischer Fokus",japanese="タウマテルギフォカス"}
buffs[522] = { id=522,duration=0,english="Elemental Sforzo",log_english="Elemental Sforzo",french="Sforzo élémentaire",german="Verzauberungs-Sforzo",japanese="Ｅ.スフォルツォ"}
buffs[523] = { id=523,duration=0,english="Ignis",log_english="Ignis",french="Ignis",german="Ignis",japanese="イグニス"}
buffs[524] = { id=524,duration=0,english="Gelus",log_english="Gelus",french="Gelus",german="Gelus",japanese="ゲールス"}
buffs[525] = { id=525,duration=0,english="Flabra",log_english="Flabra",french="Flabra",german="Flabra",japanese="フラブラ"}
buffs[526] = { id=526,duration=0,english="Tellus",log_english="Tellus",french="Tellus",german="Tellus",japanese="テッルス"}
buffs[527] = { id=527,duration=0,english="Sulpor",log_english="Sulpor",french="Sulpor",german="Sulpor",japanese="スルポール"}
buffs[528] = { id=528,duration=0,english="Unda",log_english="Unda",french="Unda",german="Unda",japanese="ウンダ"}
buffs[529] = { id=529,duration=0,english="Lux",log_english="Lux",french="Lux",german="Lux",japanese="ルックス"}
buffs[530] = { id=530,duration=0,english="Tenebrae",log_english="Tenebrae",french="Tenebrae",german="Tenebrae",japanese="テネブレイ"}
buffs[531] = { id=531,duration=0,english="Vallation",log_english="Vallation",french="Vallation",german="Wall",japanese="ヴァレション"}
buffs[532] = { id=532,duration=0,english="Swordplay",log_english="Swordplay",french="Jeu d'épée",german="Fechtkunst",japanese="ソードプレイ"}
buffs[533] = { id=533,duration=0,english="Pflug",log_english="Pflug",french="Pflug",german="Pflug",japanese="フルーグ"}
buffs[534] = { id=534,duration=0,english="Embolden",log_english="emboldened",french="Affermissement",german="Ermutigung",japanese="エンボルド"}
buffs[535] = { id=535,duration=0,english="Valiance",log_english="Valiance",french="Valeur",german="Kühnheit",japanese="ヴァリエンス"}
buffs[536] = { id=536,duration=0,english="Gambit",log_english="Gambit",french="Gambit",german="Gambit",japanese="ガンビット"}
buffs[537] = { id=537,duration=0,english="Liement",log_english="Liement",french="Liement",german="Liemont",japanese="リエモン"}
buffs[538] = { id=538,duration=0,english="One for All",log_english="One for All",french="Un pour tous",german="Einer für alle",japanese="ワンフォアオール"}
buffs[539] = { id=539,duration=0,english="Regen",log_english="regenerating",french="Récup",german="Regenerieren",japanese="リジェネ"}
buffs[540] = { id=540,duration=0,english="poison",log_english="poisoned",french="Poison",german="Gift",japanese="ポイズン"}
buffs[541] = { id=541,duration=0,english="Refresh",log_english="refreshing",french="Recharge",german="Erfrischen",japanese="リフレシュ"}
buffs[542] = { id=542,duration=0,english="STR Boost",log_english="STR-boosted",french="STR augmentée",german="STR-Boost",japanese="STRアップ"}
buffs[543] = { id=543,duration=0,english="DEX Boost",log_english="DEX-boosted",french="DEX augmentée",german="DEX-Boost",japanese="DEXアップ"}
buffs[544] = { id=544,duration=0,english="VIT Boost",log_english="VIT-boosted",french="VIT augmentée",german="VIT-Boost",japanese="VITアップ"}
buffs[545] = { id=545,duration=0,english="AGI Boost",log_english="AGI-boosted",french="AGI augmentée",german="AGI-Boost",japanese="AGIアップ"}
buffs[546] = { id=546,duration=0,english="INT Boost",log_english="INT-boosted",french="INT augmentée",german="INT-Boost",japanese="INTアップ"}
buffs[547] = { id=547,duration=0,english="MND Boost",log_english="MND-boosted",french="MND augmenté",german="MND-Boost",japanese="MNDアップ"}
buffs[548] = { id=548,duration=0,english="CHR Boost",log_english="CHR-boosted",french="CHR augmenté",german="CHR-Boost",japanese="CHRアップ"}
buffs[549] = { id=549,duration=0,english="Attack Boost",log_english="attack-boosted",french="Attaque augmentée",german="Attacken-Boost",japanese="攻撃力アップ"}
buffs[550] = { id=550,duration=0,english="Defense Boost",log_english="defense-boosted",french="Défense augmentée",german="Verteidigungs-Boost",japanese="防御力アップ"}
buffs[551] = { id=551,duration=0,english="Magic Atk. Boost",log_english="Magic Atk. Boost",french="Attq. magique augmentée",german="Magieattacken-Boost",japanese="魔法攻撃力アップ"}
buffs[552] = { id=552,duration=0,english="Magic Def. Boost",log_english="Magic Def. Boost",french="Déf. magique augmentée",german="Magieverteidigungs-Boost",japanese="魔法防御力アップ"}
buffs[553] = { id=553,duration=0,english="Accuracy Boost",log_english="accuracy-boosted",french="Précision augmentée",german="Präzisions-Boost",japanese="命中率アップ"}
buffs[554] = { id=554,duration=0,english="Evasion Boost",log_english="evasion-boosted",french="Esquive augmentée",german="Ausweich-Boost",japanese="回避率アップ"}
buffs[555] = { id=555,duration=0,english="Magic Acc. Boost",log_english="Magic Acc. Boost",french="Préc. magique augmentée",german="Magiepräzisions-Boost",japanese="魔法命中率アップ"}
buffs[556] = { id=556,duration=0,english="Magic Evasion Boost",log_english="Magic Evasion Boost",french="Esq. magique augmentée",german="Magie-Ausweich-Boost",japanese="魔法回避率アップ"}
buffs[557] = { id=557,duration=0,english="Attack Down",log_english="afflicted with Attack Down",french="Attaque réduite",german="Attacken-Down",japanese="攻撃力ダウン"}
buffs[558] = { id=558,duration=0,english="Defense Down",log_english="afflicted with Defense Down",french="Défense réduite",german="Verteidigungs-Down",japanese="防御力ダウン"}
buffs[559] = { id=559,duration=0,english="Magic Atk. Down",log_english="afflicted with Magic Atk. Down",french="Attq. magique réduite",german="Magieattacken-Down",japanese="魔法攻撃力ダウン"}
buffs[560] = { id=560,duration=0,english="Magic Def. Down",log_english="afflicted with Magic Adef. Down",french="Déf. magique réduite",german="Magieverteidigungs-Down",japanese="魔法防御力ダウン"}
buffs[561] = { id=561,duration=0,english="Accuracy Down",log_english="afflicted with Accuracy Down",french="Précision réduite",german="Präzisions-Down",japanese="命中率ダウン"}
buffs[562] = { id=562,duration=0,english="Evasion Down",log_english="afflicted with Evasion Down",french="Esquive réduite",german="Ausweich-Down",japanese="回避率ダウン"}
buffs[563] = { id=563,duration=0,english="Magic Acc. Down",log_english="afflicted with Magic Acc. Down",french="Préc. magique réduite",german="Magiepräzisions-Down",japanese="魔法命中率ダウン"}
buffs[564] = { id=564,duration=0,english="Magic Evasion Down",log_english="afflicted with Magic Evasion Down",french="Esq magique réduite",german="Magie-Ausweich-Down",japanese="魔法回避率ダウン"}
buffs[565] = { id=565,duration=0,english="slow",log_english="slowed",french="Lenteur",german="Gemach",japanese="スロウ"}
buffs[566] = { id=566,duration=0,english="paralysis",log_english="paralyzed",french="Paralysie",german="Paralyse",japanese="麻痺"}
buffs[567] = { id=567,duration=0,english="weight",log_english="weighed down",french="Pesanteur",german="Gewicht",japanese="ヘヴィ"}
buffs[568] = { id=568,duration=0,english="Foil",log_english="Foil",french="Esq. spéc. augmentée",german="Traverse",japanese="特殊攻撃回避率アップ"}
buffs[569] = { id=569,duration=0,english="Blaze of Glory",log_english="Blaze of Glory",french="Emportement géomantique",german="Glanz und Gloria",japanese="グローリーブレイズ"}
buffs[570] = { id=570,duration=0,english="Battuta",log_english="Battuta",french="Battuta",german="Battuta",japanese="バットゥタ"}
buffs[571] = { id=571,duration=0,english="Rayke",log_english="Rayke",french="Rayke",german="Rayke",japanese="レイク"}
buffs[572] = { id=572,duration=0,english="Avoidance Down",log_english="afflicted with Avoidance Down",french="Esquive affaiblie",german="Abwendung-Down",japanese="回避能力ダウン"}
buffs[573] = { id=573,duration=0,english="Deluge Spikes",log_english="Deluge Spikes",french="Pointes d'eau",german="Flutspitzen",japanese="アクアスパイク"}
buffs[574] = { id=574,duration=0,english="Fast Cast",log_english="Fast Cast",french="Rapido-magie",german="Schnellzauber",japanese="ファストキャスト"}
buffs[575] = { id=575,duration=0,english="gestation",log_english="gestating",french="Gestation",german="Verwandlungsphase",japanese="出現準備期間"}
buffs[576] = { id=576,duration=0,english="Doubt",log_english="afflicted with Doubt",french="Abattement",german="Entfremdung",japanese="減退中"}
buffs[577] = { id=577,duration=0,english="Cait Sith's Favor",log_english="Cait Sith's Favor",french="Egide de Cait Sith",german="Cait Siths Schutz",japanese="ケット・シーの加護"}
buffs[578] = { id=578,duration=0,english="Fishy Intuition",log_english="Fishy Intuition",french="Instinct de pêcheur",german="Angelsinn",japanese="釣り師のセンス"}
return buffs

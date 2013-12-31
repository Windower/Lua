augment_index = {
	[0x000] = {{stat="none",offset=0}},
	[0x001] = {{stat="hp", offset=1}},
	[0x002] = {{stat="hp", offset=33}},
	[0x003] = {{stat="hp", offset=65}},
	[0x004] = {{stat="hp", offset=97}},
	[0x005] = {{stat="hp", offset=-1}},
	[0x006] = {{stat="hp", offset=-33}},
	[0x007] = {{stat="hp", offset=-65}},
	[0x008] = {{stat="hp", offset=-97}},
	[0x009] = {{stat="mp", offset=1}},
	[0x00A] = {{stat="mp", offset=33}},
	[0x00B] = {{stat="mp", offset=65}},
	[0x00C] = {{stat="mp", offset=97}},
	[0x00D] = {{stat="mp", offset=-1}},
	[0x00E] = {{stat="mp", offset=-33}},
	[0x00F] = {{stat="mp", offset=-65}},
	[0x010] = {{stat="mp", offset=-97}},
	[0x011] = {{stat="hp", offset=1}, {stat="mp", offset=1}},
	[0x012] = {{stat="hp", offset=33}, {stat="mp", offset=33}},
	[0x013] = {{stat="hp", offset=1}, {stat="mp", offset=-1}},
	[0x014] = {{stat="hp", offset=33}, {stat="mp", offset=-33}},
	[0x015] = {{stat="hp", offset=-1}, {stat="mp", offset=1}},
	[0x016] = {{stat="hp", offset=-33}, {stat="mp", offset=33}},
	[0x017] = {{stat="accuracy", offset=1}},
	[0x018] = {{stat="accuracy", offset=-1}},
	[0x019] = {{stat="attack", offset=1}},
	[0x01A] = {{stat="attack", offset=-1}},
	[0x01B] = {{stat="rangedaccuracy", offset=1}},
	[0x01C] = {{stat="rangedaccuracy", offset=-1}},
	[0x01D] = {{stat="rangedattack", offset=1}},
	[0x01E] = {{stat="rangedattack", offset=-1}},
	[0x01F] = {{stat="evasion", offset=1}},
	[0x020] = {{stat="evasion", offset=-1}},
	[0x021] = {{stat="defense", offset=1}},
	[0x022] = {{stat="defense", offset=-1}},
	[0x023] = {{stat="magicaccuracy", offset=1}},
	[0x024] = {{stat="magicaccuracy", offset=-1}},
	[0x025] = {{stat="magicevasion", offset=1}},
	[0x026] = {{stat="magicevasion", offset=-1}},
	[0x027] = {{stat="enmity", offset=1}},
	[0x028] = {{stat="enmity", offset=-1}},
	[0x029] = {{stat="criticalhitrate", offset=1}},
	[0x02A] = {{stat="enemycriticalhitrate", offset=-1}},
	[0x02B] = {{stat="charm", offset=1}},
	[0x02C] = {{stat="storetp", offset=1}, {stat="subtleblow", offset=1}},
	[0x02D] = {{stat="damage", offset=1}},
	[0x02E] = {{stat="damage", offset=-1}},
	[0x02F] = {{stat="delaypercent", offset=1}},
	[0x030] = {{stat="delaypercent", offset=-1}},
	[0x031] = {{stat="haste", offset=1}},
	[0x032] = {{stat="haste", offset=-1}},
	[0x033] = {{stat="hprecoveredwhilehealing", offset=1}},
	[0x034] = {{stat="mprecoveredwhilehealing", offset=1}},
	[0x035] = {{stat="spellinterruptionrate", offset=-1}},
	[0x036] = {{stat="physicaldamagetaken", offset=-1}},
	[0x037] = {{stat="magicdamagetaken", offset=-1}},
	[0x038] = {{stat="breathdamagetaken", offset=-1}},
	[0x039] = {{stat="magiccriticalhitrate", offset=1}},
	[0x03A] = {{stat="magicdefensebonus", offset=-1}},
	[0x03B] = {{stat="latenteffectregain", offset=1}},
	[0x03C] = {{stat="latenteffectrefresh", offset=1}},
	[0x03D] = {{stat="occasionallyincreasesresistancetostatusailments", offset=1}},

	[0x060] = {{stat="petaccuracy", offset=1}, {stat="petrangedaccuracy", offset=1}},
	[0x061] = {{stat="petattack", offset=1}, {stat="petrangedattack", offset=1}},
	[0x062] = {{stat="petevasion", offset=1}},
	[0x063] = {{stat="petdefense", offset=1}},
	[0x064] = {{stat="petmagicaccuracy", offset=1}},
	[0x065] = {{stat="petmagicattackbonus", offset=1}},
	[0x066] = {{stat="petcriticalhitrate", offset=1}},
	[0x067] = {{stat="petenemycriticalhitrate", offset=-1}},
	[0x068] = {{stat="petenmity", offset=1}},
	[0x069] = {{stat="petenmity", offset=-1}},
	[0x06A] = {{stat="petaccuracy", offset=1}, {stat="petrangedaccuracy", offset=1}},
	[0x06B] = {{stat="petattack", offset=1}, {stat="petrangedattack", offset=1}},
	[0x06C] = {{stat="petmagicaccuracy", offset=1}, {stat="petmagicattackbonus", offset=1}},
	[0x06D] = {{stat="petdoubleattack", offset=1}, {stat="petcriticalhitrate", offset=1}},
	[0x06E] = {{stat="petregen", offset=1}},
	[0x06F] = {{stat="pethaste", offset=1}},
	[0x070] = {{stat="petdamagetaken", offset=-1}},
	[0x071] = {{stat="petrangedaccuracy", offset=1}},
	[0x072] = {{stat="petrangedattack", offset=1}},
	[0x073] = {{stat="petstoretp", offset=1}},
	[0x074] = {{stat="petsubtleblow", offset=1}},
	[0x075] = {{stat="petmagicevasion", offset=1}},
	[0x076] = {{stat="petphysicaldamagetaken", offset=1}},
	[0x077] = {{stat="petmagicdefensebonus", offset=1}},
	[0x078] = {{stat="avatarmagicattackbonus", offset=1}},

	--[0x080: {{stat="Pet:",offset = 0}},
	--[0x081: Accuracy +1 Ranged Acc. +0 | value + 1
	--[0x082: Attack +1 Ranged Atk. +0 | value + 1
	--[0x083: Mag. Acc. +1 "Mag.Atk.Bns."+0 | value + 1
	--[0x084: "Double Atk."+1 "Crit. hit +0 | value + 1

	--0x080~0x084 are pet augs with a pair of stats with 0x080 being just "Pet:"
	--the second stat starts at 0. the previous pet augs add +2. the first previous non pet aug adds +2. any other non pet aug will add +1.
	--any aug >= 0x032 will be added after the pet stack and will not be counted to increase the 2nd pet's aug stat and will be prolly assigned to the pet.
	--https://gist.github.com/giulianoriccio/6df4fbd1f2a166fed041/raw/4e1d1103e7fe0e69d25f8264387506b5e38296a7/augs





	[0x085] = {{stat="magicattackbonus", offset=1}},
	[0x086] = {{stat="magicdefensebonus", offset=1}},

	[0x087] = {{stat="avatar",offset=0}},

	[0x089] = {{stat="regen", offset=1}},
	[0x08A] = {{stat="refresh", offset=1}},
	[0x08B] = {{stat="rapidshot", offset=1}},
	[0x08C] = {{stat="fastcast", offset=1}},
	[0x08D] = {{stat="conservemp", offset=1}},
	[0x08E] = {{stat="storetp", offset=1}},
	[0x08F] = {{stat="doubleattack", offset=1}},
	[0x090] = {{stat="tripleattack", offset=1}},
	[0x091] = {{stat="counter", offset=1}},
	[0x092] = {{stat="dualwield", offset=1}},
	[0x093] = {{stat="treasurehunter", offset=1}},
	[0x094] = {{stat="gilfinder", offset=1}},

	[0x099] = {{stat="shieldmastery", offset=1}},

	[0x0B0] = {{stat="resistsleep", offset=1}},
	[0x0B1] = {{stat="resistpoison", offset=1}},
	[0x0B2] = {{stat="resistparalyze", offset=1}},
	[0x0B3] = {{stat="resistblind", offset=1}},
	[0x0B4] = {{stat="resistsilence", offset=1}},
	[0x0B5] = {{stat="resistpetrify", offset=1}},
	[0x0B6] = {{stat="resistvirus", offset=1}},
	[0x0B7] = {{stat="resistcurse", offset=1}},
	[0x0B8] = {{stat="resiststun", offset=1}},
	[0x0B9] = {{stat="resistbind", offset=1}},
	[0x0BA] = {{stat="resistgravity", offset=1}},
	[0x0BB] = {{stat="resistslow", offset=1}},
	[0x0BC] = {{stat="resistcharm", offset=1}},

	[0x0C2] = {{stat="kickattacks", offset=1}},
	[0x0C3] = {{stat="subtleblow", offset=1}},

	[0x0C6] = {{stat="zanshin", offset=1}},

	[0x0D3] = {{stat="snapshot", offset=1}},

	[0x0D7] = {{stat="ninjatoolexpertise", offset=1}},

	[0x101] = {{stat="handtohandskill", offset=1}},
	[0x102] = {{stat="daggerskill", offset=1}},
	[0x103] = {{stat="swordskill", offset=1}},
	[0x104] = {{stat="greatswordskill", offset=1}},
	[0x105] = {{stat="axeskill", offset=1}},
	[0x106] = {{stat="greataxeskill", offset=1}},
	[0x107] = {{stat="scytheskill", offset=1}},
	[0x108] = {{stat="polearmskill", offset=1}},
	[0x109] = {{stat="katanaskill", offset=1}},
	[0x10A] = {{stat="greatkatanaskill", offset=1}},
	[0x10B] = {{stat="clubskill", offset=1}},
	[0x10C] = {{stat="staffskill", offset=1}},

	[0x116] = {{stat="automatonmeleeskill", offset=1}},
	[0x117] = {{stat="automatonrangedskill", offset=1}},
	[0x118] = {{stat="automatonmagicskill", offset=1}},
	[0x119] = {{stat="archeryskill", offset=1}},
	[0x11A] = {{stat="marksmanshipskill", offset=1}},
	[0x11B] = {{stat="throwingskill", offset=1}},

	[0x11E] = {{stat="shieldskill", offset=1}},

	[0x120] = {{stat="divinemagicskill", offset=1}},
	[0x121] = {{stat="healingmagicskill", offset=1}},
	[0x122] = {{stat="enhancingmagicskill", offset=1}},
	[0x123] = {{stat="enfeeblingmagicskill", offset=1}},
	[0x124] = {{stat="elementalmagicskill", offset=1}},
	[0x125] = {{stat="darkmagicskill", offset=1}},
	[0x126] = {{stat="summoningmagicskill", offset=1}},
	[0x127] = {{stat="ninjutsuskill", offset=1}},
	[0x128] = {{stat="singingskill", offset=1}},
	[0x129] = {{stat="stringedinstrumentskill", offset=1}},
	[0x12A] = {{stat="windinstrumentskill", offset=1}},
	[0x12B] = {{stat="bluemagicskill", offset=1}},
	[0x12C] = {{stat="geomancyskill", offset=1}},
	[0x12D] = {{stat="Handbell Skill", offset=1}},

	[0x140] = {{stat="bloodpactabilitydelay", offset=-1}},
	[0x141] = {{stat="avatarperpetuationcost", offset=-1}},
	[0x142] = {{stat="songspellcastingtime", offset=-1}},
	[0x143] = {{stat="curespellcastingtime", offset=-1}},
	[0x144] = {{stat="callbeastabilitydelay", offset=-1}},
	[0x145] = {{stat="quickdrawabilitydelay", offset=-1}},
	[0x146] = {{stat="weaponskillaccuracy", offset=1}},
	[0x147] = {{stat="weaponskilldamage", offset=1}},
	[0x148] = {{stat="criticalhitdamage", offset=1}},
	[0x149] = {{stat="curepotency", offset=1}},
	[0x14A] = {{stat="waltzpotency", offset=1}},
	[0x14B] = {{stat="waltzabilitydelay", offset=-1}},
	[0x14C] = {{stat="skillchaindamage", offset=1}},
	[0x14D] = {{stat="conservetp", offset=1}},
	[0x14E] = {{stat="magicburstdamage", offset=1}},
	[0x14F] = {{stat="magiccriticalhitdamage", offset=1}},
	[0x150] = {{stat="sicandreadyabilitydelay", offset=-1}},
	[0x151] = {{stat="songrecastdelay", offset=-1}},
	[0x152] = {{stat="barrage", offset=1}},
	[0x153] = {{stat="elementalsiphon", offset=1}},
	[0x154] = {{stat="phantomrollabilitydelay", offset=-1}},
	[0x155] = {{stat="repairpotency", offset=1}},
	[0x156] = {{stat="waltztpcost", offset=-1}},

	[0x15E] = {{stat="occasionallymaximizesmagicaccuracy", offset=1}},
	[0x15F] = {{stat="occasionallyquickensspellcasting", offset=1}},
	[0x160] = {{stat="occasionallygrantsdamagebonusbasedontp", offset=1}},
	[0x161] = {{stat="tpbonus", offset=1, multiplier=5}},

	[0x200] = {{stat="strength", offset=1}},
	[0x201] = {{stat="dexterity", offset=1}},
	[0x202] = {{stat="vitality", offset=1}},
	[0x203] = {{stat="agility", offset=1}},
	[0x204] = {{stat="intelligence", offset=1}},
	[0x205] = {{stat="mind", offset=1}},
	[0x206] = {{stat="charisma", offset=1}},
	[0x207] = {{stat="strength", offset=-1}},
	[0x208] = {{stat="dexterity", offset=-1}},
	[0x209] = {{stat="vitality", offset=-1}},
	[0x20A] = {{stat="agility", offset=-1}},
	[0x20B] = {{stat="intelligence", offset=-1}},
	[0x20C] = {{stat="mind", offset=-1}},
	[0x20D] = {{stat="charisma", offset=-1}},
	[0x20E] = {{stat="strength", offset=1}, {stat="dexterity", offset=-1}, {stat="vitality", offset=-1}},
	[0x20F] = {{stat="strength", offset=1}, {stat="dexterity", offset=-1}, {stat="agility", offset=-1}},
	[0x210] = {{stat="strength", offset=1}, {stat="vitality", offset=-1}, {stat="agility", offset=-1}},
	[0x211] = {{stat="strength", offset=-1}, {stat="dexterity", offset=1}, {stat="vitality", offset=-1}},
	[0x212] = {{stat="strength", offset=-1}, {stat="dexterity", offset=1}, {stat="agility", offset=-1}},
	[0x213] = {{stat="dexterity", offset=1}, {stat="vitality", offset=-1}, {stat="agility", offset=-1}},
	[0x214] = {{stat="strength", offset=-1}, {stat="dexterity", offset=-1}, {stat="vitality", offset=1}},
	[0x215] = {{stat="strength", offset=-1}, {stat="vitality", offset=1}, {stat="agility", offset=-1}},
	[0x216] = {{stat="dexterity", offset=-1}, {stat="vitality", offset=1}, {stat="agility", offset=-1}},
	[0x217] = {{stat="strength", offset=-1}, {stat="dexterity", offset=-1}, {stat="agility", offset=1}},
	[0x218] = {{stat="strength", offset=-1}, {stat="vitality", offset=-1}, {stat="agility", offset=1}},
	[0x219] = {{stat="dexterity", offset=-1}, {stat="vitality", offset=-1}, {stat="agility", offset=1}},
	[0x21A] = {{stat="agility", offset=1}, {stat="intelligence", offset=-1}, {stat="mind", offset=-1}},
	[0x21B] = {{stat="agility", offset=1}, {stat="intelligence", offset=-1}, {stat="charisma", offset=-1}},
	[0x21C] = {{stat="agility", offset=1}, {stat="mind", offset=-1}, {stat="charisma", offset=-1}},
	[0x21D] = {{stat="agility", offset=-1}, {stat="intelligence", offset=1}, {stat="mind", offset=-1}},
	[0x21E] = {{stat="agility", offset=-1}, {stat="intelligence", offset=1}, {stat="charisma", offset=-1}},
	[0x21F] = {{stat="intelligence", offset=1}, {stat="mind", offset=-1}, {stat="charisma", offset=-1}},
	[0x220] = {{stat="agility", offset=-1}, {stat="intelligence", offset=-1}, {stat="mind", offset=1}},
	[0x221] = {{stat="agility", offset=-1}, {stat="mind", offset=1}, {stat="charisma", offset=-1}},
	[0x222] = {{stat="intelligence", offset=-1}, {stat="mind", offset=1}, {stat="charisma", offset=-1}},
	[0x223] = {{stat="agility", offset=-1}, {stat="intelligence", offset=-1}, {stat="charisma", offset=1}},
	[0x224] = {{stat="agility", offset=-1}, {stat="mind", offset=-1}, {stat="charisma", offset=1}},
	[0x225] = {{stat="intelligence", offset=-1}, {stat="mind", offset=-1}, {stat="charisma", offset=1}},

	[0x2E4] = {{stat="damage", offset=1}},
	[0x2E5] = {{stat="damage", offset=33}},
	[0x2E6] = {{stat="damage", offset=65}},
	[0x2E7] = {{stat="damage", offset=97}},
	[0x2E8] = {{stat="damage", offset=-1}},
	[0x2E9] = {{stat="damage", offset=-33}},
	[0x2EA] = {{stat="damage", offset=1}},
	[0x2EB] = {{stat="damage", offset=33}},
	[0x2EC] = {{stat="damage", offset=65}},
	[0x2ED] = {{stat="damage", offset=97}},
	[0x2EE] = {{stat="damage", offset=-1}},
	[0x2EF] = {{stat="damage", offset=-33}},
	[0x2F0] = {{stat="delay", offset=1}},
	[0x2F1] = {{stat="delay", offset=33}},
	[0x2F2] = {{stat="delay", offset=65}},
	[0x2F3] = {{stat="delay", offset=97}},
	[0x2F4] = {{stat="delay", offset=-1}},
	[0x2F5] = {{stat="delay", offset=-33}},
	[0x2F6] = {{stat="delay", offset=-65}},
	[0x2F7] = {{stat="delay", offset=-97}},
	[0x2F8] = {{stat="delay", offset=1}},
	[0x2F9] = {{stat="delay", offset=33}},
	[0x2FA] = {{stat="delay", offset=65}},
	[0x2FB] = {{stat="delay", offset=97}},
	[0x2FC] = {{stat="delay", offset=-1}},
	[0x2FD] = {{stat="delay", offset=-33}},
	[0x2FE] = {{stat="delay", offset=-65}},
	[0x2FF] = {{stat="delay", offset=-97}},

	[0x300] = {{stat="fireresistance", offset=1}},
	[0x301] = {{stat="iceresistance", offset=1}},
	[0x302] = {{stat="windresistance", offset=1}},
	[0x303] = {{stat="earthresistance", offset=1}},
	[0x304] = {{stat="lightningresistance", offset=1}},
	[0x305] = {{stat="waterresistance", offset=1}},
	[0x306] = {{stat="lightresistance", offset=1}},
	[0x307] = {{stat="darkresistance", offset=1}},
	[0x308] = {{stat="fireresistance", offset=-1}},
	[0x309] = {{stat="iceresistance", offset=-1}},
	[0x30A] = {{stat="windresistance", offset=-1}},
	[0x30B] = {{stat="earthresistance", offset=-1}},
	[0x30C] = {{stat="lightningresistance", offset=-1}},
	[0x30D] = {{stat="waterresistance", offset=-1}},
	[0x30E] = {{stat="lightresistance", offset=-1}},
	[0x30F] = {{stat="darkresistance", offset=-1}},
	[0x310] = {{stat="fireresistance", offset=1}, {stat="waterresistance", offset=-1}},
	[0x311] = {{stat="fireresistance", offset=-1}, {stat="iceresistance", offset=1}},
	[0x312] = {{stat="iceresistance", offset=-1}, {stat="windresistance", offset=1}},
	[0x313] = {{stat="windresistance", offset=-1}, {stat="earthresistance", offset=1}},
	[0x314] = {{stat="earthresistance", offset=-1}, {stat="lightningresistance", offset=1}},
	[0x315] = {{stat="lightningresistance", offset=-1}, {stat="waterresistance", offset=1}},
	[0x316] = {{stat="lightresistance", offset=1}, {stat="darkresistance", offset=-1}},
	[0x317] = {{stat="lightresistance", offset=-1}, {stat="darkresistance", offset=1}},
	[0x318] = {{stat="fireresistance", offset=1}, {stat="windresistance", offset=1}, {stat="lightningresistance", offset=1}, {stat="lightresistance", offset=1}},
	[0x319] = {{stat="iceresistance", offset=1}, {stat="earthresistance", offset=1}, {stat="waterresistance", offset=1}, {stat="darkresistance", offset=1}},
	[0x31A] = {{stat="fireresistance", offset=1}, {stat="iceresistance", offset=-1}, {stat="windresistance", offset=1}, {stat="earthresistance", offset=-1}, {stat="lightningresistance", offset=1}, {stat="waterresistance", offset=-1}, {stat="lightresistance", offset=1}, {stat="darkresistance", offset=-1}},
	[0x31B] = {{stat="fireresistance", offset=-1}, {stat="iceresistance", offset=1}, {stat="windresistance", offset=-1}, {stat="earthresistance", offset=1}, {stat="lightningresistance", offset=-1}, {stat="waterresistance", offset=1}, {stat="lightresistance", offset=-1}, {stat="darkresistance", offset=1}},
	[0x31C] = {{stat="fireresistance", offset=1}, {stat="iceresistance", offset=1}, {stat="windresistance", offset=1}, {stat="earthresistance", offset=1}, {stat="lightningresistance", offset=1}, {stat="waterresistance", offset=1}, {stat="lightresistance", offset=1}, {stat="darkresistance", offset=1}},
	[0x31D] = {{stat="fireresistance", offset=-1}, {stat="iceresistance", offset=-1}, {stat="windresistance", offset=-1}, {stat="earthresistance", offset=-1}, {stat="lightningresistance", offset=-1}, {stat="waterresistance", offset=-1}, {stat="lightresistance", offset=-1}, {stat="darkresistance", offset=-1}},

	[0x340] = {{stat="addedeffectfiredamage", offset=5}},
	[0x341] = {{stat="addedeffecticedamage", offset=5}},
	[0x342] = {{stat="addedeffectwinddamage", offset=5}},
	[0x343] = {{stat="addedeffectearthdamage", offset=5}},
	[0x344] = {{stat="addedeffectlightningdamage", offset=5}},
	[0x345] = {{stat="addedeffectwaterdamage", offset=5}},
	[0x346] = {{stat="addedeffectlightdamage", offset=5}},
	[0x347] = {{stat="addedeffectwaterdamage", offset=5}},
	[0x348] = {{stat="addedeffectdisease", offset=1}},
	[0x349] = {{stat="addedeffectparalyze", offset=1}},
	[0x34A] = {{stat="addedeffectsilence", offset=1}},
	[0x34B] = {{stat="addedeffectslow", offset=1}},
	[0x34C] = {{stat="addedeffectstun", offset=1}},
	[0x34D] = {{stat="addedeffectpoison", offset=1}},
	[0x34E] = {{stat="addedeffectflash", offset=1}},
	[0x34F] = {{stat="addedeffectblind", offset=1}},
	[0x350] = {{stat="addedeffectdefensedown", offset=1}},
	[0x351] = {{stat="addedeffectsleep", offset=1}},
	[0x352] = {{stat="addedeffectattackdown", offset=1}},
	[0x353] = {{stat="addedeffectevasiondown", offset=1}},
	[0x354] = {{stat="addedeffectaccuracydown", offset=1}},
	[0x355] = {{stat="addedeffectmagicevasiondown", offset=1}},
	[0x356] = {{stat="addedeffectmagicattackdown", offset=1}},
	[0x357] = {{stat="addedeffectmagicdefensedown", offset=1}},
	[0x358] = {{stat="addedeffectmagicaccuracydown", offset=1}},

	[0x380] = {{stat="swordenhancementspelldamage", offset=1}},
	[0x381] = {{stat="enhancessouleatereffect", offset=1}},
}



--[[function extdata_to_augment(extdata)
	if not extdata then return end
	local flags,id_1,val_1,id_2,val_2,id_3,val_3,id_4,val_4,Augment_1,Augment_2,Augment_3,Augment_4
	local trial_complete,trial_number = false
	
	flags = extdata:sub(1,2)
	
	if flags:byte(1) == 2 then
		if flags:byte(2) == 3 then
			id_1 = extdata:byte(3)+(extdata:byte(4)%8)*256
			val_1 = math.floor(extdata:byte(4)/8)
			
			id_2 = extdata:byte(5)+(extdata:byte(6)%8)*256
			val_2 = math.floor(extdata:byte(6)/8)
			
			id_3 = extdata:byte(7)+(extdata:byte(8)%8)*256
			val_3 = math.floor(extdata:byte(8)/8)
			
			if id_1 ~= 0 then Augment_1 = unpack_augment(augment_index[id_1],val_1) end
			if id_2 ~= 0 then Augment_2 = unpack_augment(augment_index[id_2],val_2) end
			if id_3 ~= 0 then Augment_3 = unpack_augment(augment_index[id_3],val_3) end
		elseif flags:byte(2) == 67 then
			id_1 = extdata:byte(7)+(extdata:byte(8)%8)*256
			val_1 = math.floor(extdata:byte(8)/8)
			
			id_2 = extdata:byte(9)+(extdata:byte(10)%8)*256
			val_2 = math.floor(extdata:byte(10)/8)
			
			trial_number = extdata:byte(12)*256+extdata:byte(11)
			if trial_number%32768 > 1 then
				trial_number = trial_number%32768
				trial_complete = true
			end
			
			if id_1 ~= 0 then Augment_1 = unpack_augment(augment_index[id_1],val_1) end
			if id_2 ~= 0 then Augment_2 = unpack_augment(augment_index[id_2],val_2) end
			
		elseif flags:byte(2) == 35 then
			-- Manibozho, Bokwus, etc.
			id_1 = extdata:byte(7)
			val_1 = extdata:byte(8)
			
			id_2 = extdata:byte(9)
			val_2 = extdata:byte(10)
			
			id_3 = extdata:byte(11)
			val_3 = extdata:byte(12)
		end
	elseif flags:byte(1) == 45 then
		-- Pearlsacks are 45,85
	elseif flags:byte(1) == 1 then
		-- Enchanted item
		local uses_remaining = extdata:byte(2)
	end
--	windower.add_to_chat(1,'flags: '..tostring(flags)..'  id/val 1: '..id_1..'/'..val_1..'  id/val 2: '..id_2..'/'..val_2..'  id/val 3: '..id_3..'/'..val_3)
--	windower.add_to_chat(8,'-------------------------------------------')
	
	return Augment_1,Augment_2,Augment_3,Augment_4,trial_number,trial_complete
end

function unpack_augment(augment_table,val)
	local return_augment
	if augment_table and type(augment_table) == 'table' then
		for i,v in pairs(augment_table) do
			if i > 1 then return_augment = return_augment..',' end
			return_augment = (return_augment or '')..v.stat
			if v.offset >= 0 then return_augment = return_augment..((val+v.offset)*(v.multiplier or 1))
			else return_augment = return_augment..'-'..((val-v.offset)*(v.multiplier or 1)) end
		end
	end
	return return_augment or 'nil'
end

for i,v in pairs(windower.ffxi.get_items().inventory) do
	if v.extdata then
		local tempstr = r_items[v.id].english..'   '
		for n=1,string.len(v.extdata) do
			tempstr = tempstr..string.byte(v.extdata,n)..' '
		end
		local aug1,aug2,aug3,trial,done = extdata_to_augment(v.extdata)
		tempstr = tempstr..'    Augs: '..tostring(aug1)..'   '..tostring(aug2)..'   '..tostring(aug3)..'   '..tostring(trial)..'   '..tostring(done)
		windower.add_to_chat(2,tempstr)
	end
end]]

function augment_to_extdata(str)
	local stripped = str:lower():gsub('[^%-%w,]','')
	local twobyte,firstbyte,secondbyte
	
	local a,b,aug,pol,val = string.find(stripped,'(%a+)(%-*)(%d+)')
	if pol == '-' then
		pol = -1
	else
		pol = 1
	end
	
	for i,v in pairs(augment_index) do
		if v[1].stat == aug and (val/(v[1].multiplier or 1) - pol*v[1].offset) <= 32 then -- Value has a maximum value of 32 because it's only 5 bits.
			val = val/(v[1].multiplier or 1) - pol*v[1].offset
			firstbyte = i%256 or 0
			secondbyte = math.floor(i/256)+8*val or 0
			twobyte = string.char(firstbyte)..string.char(secondbyte)
			break
		end
	end
	return twobyte
end
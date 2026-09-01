# gearstats

## English

Print the current equipment stats or save to file for simple comparison.
It just extract the stats for each piece of equipment from the item_descriptions.lua and extdata and add them up.
For information such as `Sets:`, it will assigned a number 1 to each appearance and add them up
Example: 

	TP not depleted when weapon skill used:2
	Set - Increases Accuracy, Ranged Accuracy, and Magic Accuracy:1
	Set - Augments Double Attack:1

The "TP not depleted when weapon skill used" appears on Fotia Gorget and Belt, the number is 2 because it appears twice
For the "Set - Increases Accuracy, Ranged Accuracy, and Magic Accuracy:1", only 1 piece of AF3 was equipped so it count as 1.
Similarly "Set - Augments Double Attack:1" indicates only 1 piece of WAR Empy was equipped

### Limitations

It doesn't aggregate information not directly obtained via extdata.
These are encoded as Path and Rank in extdata, so there is no direct way to read the stats they provide.
Use `//gearstats debug` to see the full structure of information

	"waist" : {
		"count" : 1,
		"description" : ["Haste+9% \"Triple Attack\"+2%", "Unity Ranking: Attack+10～15"],
		"extdata" : {
			"augment_system" : 4,
			"augments" : {
				"1" : "Path: A"
			},
			"path" : "A",
			"rank" : 15,
			"type" : "Augmented Equipment"
		},
		"id" : 28428,
		"name" : "Sailfi Belt +1",
		"stats" : {
			"Haste" : 9,
			"Triple Attack" : 2,
			"Unity Ranking" : {
				"Attack" : 15
			}
		}
	}	

### Command

- `//gearstats help`

Print the help menu

- `//gearstats print`

Print the aggregate stats of the current equipped gear
Example: 

	Generating Equipment Stats
	DMG:336 Delay:480 DEF:717 HP:501 MP:53 Haste:26
	 STR:203 DEX:131 AGI:115 VIT:201 INT:108 MND:138 CHR:157
	 Acc:309 Atk:256 R.Acc:0 R.Atk:10 M.Acc:149 M.Dmg:155
	 Eva:298 M.Eva:464 M.Def.Bn:30 DT:-36 PDT:-5
	 Store TP:54 Double Atk.:43 Triple Atk.:2 Quad Atk.:3
	 TP Bonus:500 PDL:6
	 Subtle Blow:18 Subtle Blow II:5
	:Skill - Magic Accuracy:228 Great Axe:285 Parrying:269
	 Weapon skill DEX:10 Regen:2 Upheaval:1 Crit.hit rate:4 Double Attack damage:20
	 Berserk effect duration:15 Blood Rage effect duration:36
	Right ear - Double Atk.:8 Subtle Blow:6
	Aftermath - Ultimate Skillchain:1 Increases magic burst potency:1
	Aftermath - Increases skillchain potency:1
	Unity Ranking - Atk:15
	Set - Increases Accuracy, Ranged Accuracy, and Magic Accuracy:2
	Set - Augments Double Attack:1

- `//gearstats file <description string>`

This will generate the `file data/{player_name}_{player_main_job}.txt` and append the stats.
The arguments after the `file` command will be inserted into the header line.

	=====[ description_string ]======
	 DMG:336 Delay:480 DEF:717 HP:501 MP:53 Haste:26
	 STR:203 DEX:131 AGI:115 VIT:201 INT:108 MND:138 CHR:157
	 Acc:309 Atk:256 R.Acc:0 R.Atk:10 M.Acc:149 M.Dmg:155
	 Eva:298 M.Eva:464 M.Def.Bn:30 DT:-36 PDT:-5
	 Store TP:54 Double Atk.:43 Triple Atk.:2 Quad Atk.:3
	 TP Bonus:500 PDL:6
	 Subtle Blow:18 Subtle Blow II:5
	:Skill - Magic Accuracy:228 Great Axe:285 Parrying:269
	 Weapon skill DEX:10 Regen:2 Upheaval:1 Crit.hit rate:4 Double Attack damage:20
	 Berserk effect duration:15 Blood Rage effect duration:36
	Right ear - Double Atk.:8 Subtle Blow:6
	Aftermath - Ultimate Skillchain:1 Increases magic burst potency:1
	Aftermath - Increases skillchain potency:1
	Unity Ranking - Atk:15
	Set - Increases Accuracy, Ranged Accuracy, and Magic Accuracy:2
	Set - Augments Double Attack:1

- `//gearstats base`

Set the current gear stats as baseline for comparison

- `//gearstats diff`

Compare the current gear stats with baseline stats

- `//gearstats filediff`

Compare the current gear stats with baseline stats and write to file

- `//gearstats merge_pet_stats < toggle | on | off>`

Merge the Pet: statistics into Automation, Wyvern or Avatar and hide it

- `//gearstats line_wrap < number >`

Set the line wrap limit, defaults to 80 chars per line

- `//gearstats debug`

Output the internal structures into `data/debug.json`
Should invoke `//gearstats print` first to generate structures

### Customization

The output line order (priority_list) and printing name (mapping_table) of attributes is defined in data/settings.json.

Can edit it to change the format based on your preferences.

	{
		"line_wrap" : 80,
		"mapping_table" : {
			"Accuracy" : "Acc",
			"Attack" : "Atk",
			"Damage taken" : "DT",
			"Double Attack" : "Double Atk.",
			"Evasion" : "Eva",
			"Magic Accuracy" : "M.Acc",
			"Magic Atk. Bonus" : "M.Atk.Bn",
			"Magic Damage" : "M.Dmg",
			"Magic Def. Bonus" : "M.Def.Bn",
			"Magic Evasion" : "M.Eva",
			"Magic burst damage" : "MB.Dmg",
			"Magical damage taken" : "MDT",
			"Occ. quickens spellcasting" : "Quick Cast",
			"Physical damage limit" : "PDL",
			"Physical damage taken" : "PDT",
			"Quad Attack" : "Quad Atk.",
			"Ranged Accuracy" : "R.Acc",
			"Ranged Attack" : "R.Atk",
			"Skillchain Bonus" : "SC.Bonus",
			"Spell interruption rate down" : "Interrupt Down Rate",
			"Triple Attack" : "Triple Atk.",
			"Weapon skill damage" : "WS.Dmg"
		},
		"merge_pet_stats" : true,
		"priority_list" : [["DMG", "Delay", "DEF", "HP", "MP", "Haste"],
			["STR", "DEX", "AGI", "VIT", "INT", "MND", "CHR"],
			["Accuracy", "Attack", "Ranged Accuracy", "Ranged Attack", "Magic Accuracy", "Magic Atk. Bonus", "Magic Damage", "Magic burst damage"],
			["Evasion", "Magic Evasion", "Magic Def. Bonus", "Damage taken", "Physical damage taken", "Magical damage taken"],
			["Regain", "Store TP", "Double Attack", "Triple Attack", "Quad Attack", "Dual Wield"],
			["Weapon skill damage", "TP Bonus", "Skillchain Bonus", "Physical damage limit"],
			["Enmity", "Counter", "Subtle Blow", "Subtle Blow II"],
			["Refresh", "Conserve MP", "Fast Cast", "Occ. quickens spellcasting", "Spell interruption rate down"]]
	}

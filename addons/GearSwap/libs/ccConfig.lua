-- Jobs you want to execute with, recomment put all active jobs you have lua for will look for <job>.lua or <playername>_<job>.lua files
ccjobs = { 'BLM', 'BLU', 'BRD', 'BST', 'DRG', 'GEO', 'MNK', 'NIN', 'PLD', 'RDM', 'RNG', 'RUN', 'SAM', 'SCH', 'SMN', 'THF', 'WAR', 'WHM' }
-- Put any items in your inventory here you don't want to show up in the final report
-- recommended for furniture, food, meds, pop items or any gear you know you want to keep for some reason
-- supports lua regex syntax, put each separate one as its own entry in the table
-- see: https://www.lua.org/pil/20.2.html
ccignore = { "Rem's Tale*", "Storage Slip %d+", "Deed of*", "%a+ Virtue", "Dragua's Scale",
			"Glittering Yarn", "Dim. Ring*", "Cupboard", ".*VCS.*", ".*Abjuration.*", "%a+ Organ",
			"Mecisto. Mantle", "Homing Ring", "%a+ Plans", "Orblight", "Yellow 3D Almirah",
			"%a+ Statue", "Luminion Chip", ".* Mannequin", "R. Bamboo Grass", "Coiled Yarn",
			"Stationery Set", "%a+ Flag", "Bonbori", "Imperial Standard", "%a+ Bed", "Adamant. Statue",
			"Festival Dolls", "Taru Tot Toyset", "Bookshelf", "Guild Flyers", "San d'Orian Tree",
			".*Signet Staff", "Capacity Ring", "Facility Ring", "Trizek Ring", "Bam. Grass Basket", "Portafurnace",
			"%a+'s Sign", "%a+'s Apron", "Toolbag .*", "%a+ Crepe", "%a+ Sushi.*", ".* Stable Collar", "Plovid Effluvium",
			"Gem of the %a+", "Inoshishinofuda", "Ichigohitofuri", "Chonofuda", "Shikanofuda", "Shihei", "Midras.s Helm .1", "Cobra Staff", "Ram Staff", "Fourth Staff",
			"Warp Ring", "Chocobo Whistle", "Warp Cudgel", "%a+ Broth", "Tavnazian Ring", "Official Reflector",
			"Pashhow Ring", "Dredger Hose", "Trench Tunic", "Sanjaku.Tenugui", "Katana.kazari", "Sanjaku.Tenugui",
			"Carver's Torque", "Kabuto.kazari", "Etched Memory", "Trbl. Hatchet", "Maat's Cap", "Trbl. Pickaxe",
			"Olduum Ring", "Linkpearl", "Caliber Ring", "Vana'clock", "Signal Pearl", "Windy Greens", "Nexus Cape",
			"Wastebasket", "Sickle", "Carpenter's Gloves", "Shinobi.Tabi", "Guardian Board", "%a+ Pie", "Pet Food %a+",
			"Reraise %a+", "P. %a+ Card", "Diorite", "Abdhaljs Seal", "Kin's Scale", "*Curry*", "Crepe B. Helene",
			"Rounsey Wand", "Tant. Broth"
			}
-- This is the most use of an item you want to show up in the report
-- Set to nil or delete for unlimited
ccmaxuse = nil
-- List bags you want to not check against, needs to match "Location" column in <player>_report.txt
skipBags = S{ 'Storage', 'Temporary' }
-- this prints out the _sets _ignored and _inventory files
ccDebug = false
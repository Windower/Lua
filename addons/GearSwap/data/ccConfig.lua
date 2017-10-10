-- Jobs you want to execute with, recomment put all active jobs you have lua for will look for <job>.lua or <playername>_<job>.lua files
-- delete jobs you do not play or have lua files for
ccjobs = { 'BLM', 'BLU', 'BRD', 'BST', 'COR', 'DRG', 'DNC', 'DRK', 'GEO', 'MNK', 'NIN', 'PLD', 'PUP', 'RDM', 'RNG', 'RUN', 'SAM', 'SCH', 'SMN', 'THF', 'WAR', 'WHM' }
-- Put any items in your inventory here you don't want to show up in the final report
-- recommended for furniture, food, meds, pop items or any gear you know you want to keep for some reason
-- use * for wildcard matching. see ccConfig_example.lua for examples
ccignore = { }
-- This is the most use of an item you want to show up in the report
-- Set to nil or delete for unlimited
ccmaxuse = nil
-- List bags you want to not check against, needs to match "Location" column in <player>_report.txt
skipBags = S{ 'Temporary' }
-- this prints out the _sets _ignored and _inventory files
ccDebug = false
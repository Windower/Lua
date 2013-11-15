#Shortcuts v1.3
####written by Byrth  

Completes and properly formats commands (prefixed by at least one '/'),
including emotes and checks. This addon is part of a larger "replacing
spellcast" project, and represents the interpretation part of spellcast.

####Commands/Settings:  
None  

####Changelog:  
v1.3 - 11/15/13 - Added handling for "Corpse" spells and fixed a minor glitch in target creation.
v1.2 - 11/13/13 - Added abiguous case handling for amorph/bird spells.
v1.1 - 10/23/13 - Reduced "spell1" to "spell" and made some minor adjustments.
v1.0 - 10/16/13 - Fixed some ambiguous name processing issues with monsterskills.
v0.9 - 10/1/13  - Fixed targets.lua's interpretation of the target flags.
v0.8 - 08/14/13 - Fixed split(), which was causing errors when assembling resources.
v0.7 - 08/12/13 - Improved the hashing algorithm (better roman numeral conversion) and improved target creation again. Updated documentation.
v0.6 - 08/11/13 - Fixed autotranslate, eliminated valid commands that aren't prefixed by '/', and made target creation smarter.
v0.5 - 08/05/13 - Added handling for <st..> commands and support for target shorthands (t for <t>, stpc for <stpc>, etc.)
v0.4 - 07/25/13 - Added handling for Monstrosity. Added logging. Modified target handling.
v0.3 - 07/14/13 - Fixed an ambiguous_names error. Retooled some parts in anticipation of the new hook and Monstrosity. Added infinite loop detection.
v0.2 - 06/19/13 - Fixed the addon's capacity for infinite loops. Added safe auto-completion for party commands. Added target commands.
v0.1 - 06/15/13 - Created Addon  
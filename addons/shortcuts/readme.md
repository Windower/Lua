#Shortcuts v2.9
####written by Byrth  

Completes and properly formats commands (prefixed by at least one '/'),
including emotes and checks. This addon is part of a larger "replacing
spellcast" project, and represents the interpretation part of spellcast.

####Commands/Settings:  
None  

####Changelog:  
v2.9 - 03/05/16 - Adjusted default target logic when the target is a Trust.
v2.8 - 11/27/15 - Changed how the non-action commands are handled (including secondary arguments).
v2.7 - 11/15/14 - Totally gutted and reworked the ambiguous spell handling system. It is much simpler now.
v2.6 -  9/27/14 - Fixed an error with absolute remapping of ambiguous spells
v2.5 -  8/30/14 - Expanded shortcuts to include single-slash commands. Expanded command prefixes to include double-slash commands.
v2.4 -  8/30/14 - Changed ambiguous case handling to respect specified prefixes.
v2.3 -  6/20/14 - Added new monstrosity skill disambiguation.
v2.2 -  5/19/14 - Accommodated new Resources changes.
v2.1 -  4/18/14 - Added custom aliases to Shortcuts.
v2.0 -  4/ 7/14 - Made Shortcuts calculate available spells/abilities in the case of ambiguous abilities. Moving towards an automated ambiguity-handling framework.
v1.9 -  3/20/14 - Changed Shortcuts over to use the resources library.
v1.8 -  1/ 6/14 - Fix target selection. Interpret the outgoing text as an ability first (instead of combination of ability and target).
v1.7 - 12/31/13 - Fixed st targets for shortcuts.
v1.6 - 12/12/13 - Fixed "target is nil" bug.
v1.5 - 12/7/13  - Various bugfixes and more complete support for pattern matching.
v1.4 - 11/17/13 - Improved ambiguous name handling using windower.ffxi.get_abilities().
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
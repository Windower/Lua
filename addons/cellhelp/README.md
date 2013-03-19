Cell Helper, for old Salvage

This addon displays what Pathos cells are still needed in a text box, alters the drop message to display what each Pathos cell does and whether it is still needed, and writes a LL profile (salvage-<playername>.txt when a cell is obtained to pass cells that you have already obtained.

This addon cannot pass things currently in the treasure pool (as LL cannot do that), but any subsequent drop of that cell will be passed. 

In order to manually pass a cell you do not need, you can either obtain it, or type "/echo <me> obtains a --incus cell--." replacing the incus cell with the name of the needed cell. include the "--". Manually editing the LL profile will NOT work, as the addon erases everything in the text document, then rewrites it when a cell is obtained.

If some add/pass functionality is added to Luacore then I'll edit this addon to reflect that. 

Current bugs: While it will say which cells you have, it will also add /Have/ to everything that is dropped, even outside of salvage. I will fix this soon.




#Rhombus

Creates a click-able onscreen menu based on customizable user files. Allows for significantly more organization than the in-game menu.

### Usage

This addon has no commands. Loading it will create an icon with four rhombi. Each rhombus indicates the region where clicking will open a menu.
Starting at the top-most rhombus and moving clock-wise, the menus that will open are: weapon skills (green), magic (red), job abilities (blue), and pet commands (yellow).
The menu can be repositioned by holding down shift and clicking anywhere within the icon.

#### Creating Custom Menus

Upon load or log in, the following files are searched for and loaded if found:

* `P:/ath/to/Windower/addons/Rhombus/data/spells_template.lua`
* `P:/ath/to/Windower/addons/Rhombus/data/ws_template.lua`
* `P:/ath/to/Windower/addons/Rhombus/data/ja_template.lua`
* `P:/ath/to/Windower/addons/Rhombus/data/pet_command_template.lua`
* `P:/ath/to/Windower/addons/Rhombus/data/spell_aliases.lua`

Each file is expected to return a table. The first four files create the structure of the corresponding menus, while the fourth is a simple mapping of in-game spell or ability names
to custom names. (You might use it to rename 'Goblin Gavotte' to 'Resist Bind', for example. Renaming spells and abilities within the menus has no effect on how they are sent as commands.)

To create a menu, simply list the spell ids (obtained from windower's resources) that you want to appear. If you want to create a sub-menu within that menu, add a key/value pair to your table with key 'sub_menu' and a table as the value.
List each sub-menu as you would like it to appear in your menu within the sub_menu table. Values in the sub_menu table must be strings to avoid conflicts. To add spells to a sub-menu, create a key with the same name as the sub-menu in the table that contains the sub_menu key.
Sub-menus may also contain sub_menu keys: there is no limit to the number of sub-menus you can create.

The ja_template, ws_template, and pet_command_template files work only slightly differently than the spells_template file. The table returned by each of these files should have keys corresponding to each in-game job's name that you want to create a menu for. These keys should
have table values which will contain the structure of the menu as described above.

In the event that no file is found for a template, the default values from memory will be used. If a table within that file (in the case of job abilities, weapon skills, and pet commands) is found for either your main or sub job, but not both, the remaining abilities found in memory
will be appended to the menu you constructed. If both tables are found, the menus will be merged with sub-menus and contents appearing in order.

Example menus can be found at the following location: https://github.com/trv6/Windower4/tree/master/Rhombus%20examples

#### Using the Mouse

Left-clicking on the rhombus icons opens the corresponding menu, or closes it if the menu is already open. New menus can be opened without closing
the current menu, and if a menu is closed by opening a new menu rather than by clicking a second time on the corresponding rhombus, the position within that
menu will be saved. The next time the menu is opened, it will open to the saved location rather than the beginning of the menu.
Left-clicking a menu item will input the ability or spell to the console, while left-clicking with the shift key held down will do the same but with the (hopefully) appropriate subtarget command appended.
Note that in order for left-clicking to work properly, the shortcuts addon must also be loaded.
Right-clicking on the menu will travel back one menu, or close the menu if the base menu is open.
Right-clicking on the rhombus icon will close the currently opened menu, saving the position within the menu.
Only 12 menu items can be displayed at a time. The rest may be scrolled to using the scroll-wheel of your mouse.

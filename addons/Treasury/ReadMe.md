# Treasury

An addon that manages the treasure pool for you and keeps your inventory clean of unwanted items. It does three things:
1. It lots/passes on items based on per-character rules as defined in the settings file
2. It automatically stacks items in your inventory after it changes, if enabled
3. If automatically drops unwanted items from your inventory, if enabled

### Commands

Note:
All commands can be shortened to `//tr`. `lot` and `pass` can be shortened to `l` and `p` respectively. `add` and `remove` can be shortened to `a` or `+` and `r` or `-` respectively.

`//treasuy lot|pass add|remove [global] <name>`

This will add to or remove from the lot list or pass list all items matching `name`. `name` can contain standard Windower wildcards (`*`, `?`, `|`). It will add those for the current character only, unless global is specified, in which case it will add it for all characters.

There are a few special key words for `name`:
* `crystals` matches all crystal items (excluding HQ synthing crystals)
* `geodes` matches all geode items (NQ)
* `avatarites` matches all geode items (HQ)
* `currency` matches all Dynamis currency (all three tiers of all three kinds)
* `seals` matches the standard seals found in the field (BS, KS, KC, HKC, SKC)
* `pool` matches your current treasure pool

'//treasury lot|pass clear|list`

This will either clear the specified list (for the current character only) or list all items on the specified list.

`//treasury lotall`

Lots on all items currently in the pool

`//treasury passall`

Passes on all items currently in the pool

`//treasury clearall`

Clears all character-specific settings (it will keep global settings)

`//treasury autodrop [on|off]`

Sets the auto-drop setting to true or false. If neither is provided, it toggles the current setting.

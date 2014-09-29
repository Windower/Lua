# Yush

A portable macro engine based on customizable Lua files. Triggers faster than in-game macros and allow a significantly higher number of key combinations.

### Usage

This addon has no commands, it only works with custom Lua user files. Upon load, login or job change it tries to load one of the following files in the specified order:

* `P:/ath/to/Windower/addons/Yush/data/Name_MAIN_SUB.lua`
* `P:/ath/to/Windower/addons/Yush/data/Name_MAIN.lua`
* `P:/ath/to/Windower/addons/Yush/data/Name.lua`
* `P:/ath/to/Windower/addons/Yush/data/binds.lua`

The file needs to return a table. The table is a key -> action mapping, where the key is a combination of keys to press (denoted by the `+` sign) and the action can either be a Windower command or another table. If it's another table, it will open that table and new keys will be looked up in that table.

To go back to the base level, press the button that has been defined in the `data/settings.xml` file as `ResetKey`. To go back only one level, press the button that has been defined in the same file as `BackKey`. They default to `` ` `` and `Backspace` respectively.

### Settings

**ResetKey**

The key which resets the current macro set to the root set (the same that is active when the file is loaded).

**BackKey**

The key which resets the current macro set to the previous set.

**Verbose**

If true, will display the current macro set you are in. The name it displays is the same name it has in the file it loads.

**VerboseOutput**

Determines where the current macro set will be displayed (only effective if the *Verbose* setting is `true`). The following options are available:
* **Chat**: Will display the current macro set in the FFXI chat log.
* **Console**: Will display the current macro set in the Windower console.
* **Text** (**default**): Will display the current macro set in a text box.

**Label**

The properties of the text object holding the current macro set name, if *Verbose* is enabled and *VerboseOutput* set to `Text`.

### Commands

```
yush reset
```

Resets the current macro set to the root set (the same that is active when the file is loaded).

```
yush back
```

Resets the current macro set to the previous set.

```
yush press [keys...]
```

Simulates a macro key press. This has no effect outside of *Yush* macros and is only there so you can set up commands to simulate *Yush* macro changes.

```
yush set <BackKey|ResetKey|Verbose> [value]
```

Sets the corresponding settings key to the provided value and saves it for the current character. If no value is provided, it displays the current settings.

```
yush save
```

Saves the current character's settings for all characters.

### Includes

Yush supports inclusion of base files, in case certain jobs share a macro structure.

If you define a table `WAR` in a file called `WAR-include.lua` that looks like this:
```lua
WAR = {
    ['Ctrl+1'] = 'input /ja "Berserk" <me>',
    ['Ctrl+2'] = 'input /ja "Warcry" <me>',
}
```

You can make use of that file by including it in another file as follows:
```lua
include('WAR-include.lua')
```

It's even possible to define tables in multiple files. The order in which they are included is the order that entries will be overwritten in. So if you define a `WAR` table in both `WAR-include.lua` as well as the file you're including it in (`Arcon_THF.lua` in this example), the table would contain entries from both files without any necessary functions or special syntax, where duplicate entries from `Arcon_THF.lua` would take priority. Simply define the table twice and values will be overwritten in the order they appear in in the file.

Following is another example. This piece is from `WAR-include.lua`:
```lua
WAR = {
    ['Ctrl+1'] = 'input /ja "Berserk" <me>',
    ['Ctrl+2'] = 'input /ja "Warcry" <me>',
}
```

This is from `Arcon_THF.lua`:
```lua
include('WAR-include.lua')

WAR = {
    ['Ctrl+2'] = 'input /ja "Aggressor" <me>',
}
```

The result would be *Berserk* on `Ctrl+1` and *Aggressor* on `Ctrl+2`, since the include came first and defined *Warcry* on `Ctrl+2`, but then it was overwritten by the *Aggressor* definition below.

### Logic

Yush supports the full use of the Lua language, as well as all Windower API functions and most Lua libraries (possibly all, but they weren't all tested). For example, in the `Arcon_THF.lua` file we can disambiguate which macros to include depending on the subjob:

```lua
local sub = windower.ffxi.get_player().sub_job
if sub == 'WAR' then
    include('WAR-include.lua')
elseif sub == 'DNC' then
    include('DNC-include.lua')
end
```

### Example

This is what an example file called `Arcon_THF.lua` in the addon's `data` folder would look like:

```lua
WAR = {
    ['Ctrl+2'] = 'input /ja "Provoke" <me>',
    ['Ctrl+3'] = 'input /ja "Warcry" <me>',
    ['Ctrl+4'] = 'input /ja "Aggressor" <me>',
    ['Ctrl+5'] = 'input /ja "Berserk" <me>',
    ['Alt+2'] = 'input /ja "Defender" <me>',
}

JA = {
    ['Ctrl+1'] = 'input /ja "Perfect Dodge" <me>',
    ['Ctrl+2'] = 'input /ja "Sneak Attack" <me>',
    ['Ctrl+3'] = 'input /ja "Trick Attack" <me>',
    ['Ctrl+4'] = 'input /ja "Bully" <me>',
    ['Ctrl+5'] = 'input /ja "Hide" <me>',
    ['Alt+2'] = WAR,                -- Goes to WAR sub table
    ['Alt+4'] = 'input /ja "Collaborator" <stpt>',
    ['Alt+3'] = 'input /ja "Flee" <me>',
}

Magic = {
    ['Ctrl+2'] = 'input /ma "Utsusemi: Ichi" <me>',
    ['Ctrl+3'] = 'input /ma "Utsusemi: Ni" <me>',
    ['Alt+2'] = 'input /ma "Monomi: Ichi" <me>',
    ['Alt+3'] = 'input /ma "Tonko: Ni" <me>',
}

WS = {
    ['Ctrl+2'] = 'input /ja "Assassin\'s Charge" <me>',
    ['Ctrl+3'] = 'input /ws "Aeolian Edge" <t>',
    ['Alt+2'] = 'input /ws "Exenterator" <t>',
    ['Alt+3'] = 'input /ws "Mercy Stroke" <t>',
    ['Alt+4'] = 'input /ws "Evisceration" <t>',
}

return {
    ['Ctrl+1'] = 'input /ja "Perfect Dodge" <me>',
    ['Ctrl+2'] = 'autoset',         -- Custom alias, equips current idle set according to variables
    ['Ctrl+3'] = 'set Regen',       -- Custom alias, equips Regen set
    ['Ctrl+4'] = 'set Magical',     -- Custom alias, equips PDT set
    ['Ctrl+5'] = 'set Physical',    -- Custom alias, equips MDT set
    ['Ctrl+9'] = 'var treasurehunter nil; autoset',
    ['Ctrl+0'] = 'var treasurehunter TreasureHunter; autoset',
    ['Alt+2'] = JA,                 -- Goes to JA sub table
    ['Alt+3'] = Magic,              -- Goes to Magic sub table
    ['Alt+5'] = WS,                 -- Goes to WS sub table
}
```

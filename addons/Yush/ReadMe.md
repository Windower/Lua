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

### Example

This is what an example file called `Arcon_THF.lua` in the addon's `data` folder would look like:

```lua
WAR = {
    ['Ctrl+2'] = 'provoke',
    ['Ctrl+3'] = 'warcry',
    ['Ctrl+4'] = 'aggressor',
    ['Ctrl+5'] = 'berserk',
    ['Alt+2'] = 'defender',
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
    ['Ctrl+2'] = 'input /ja "Assassin\'s Charge" <me>'
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

# Switch Focus #

* switch focus to another character running the addon.

----

**Addon Command:** `swf`, `switch`, `switch_focus`

#### Commands: ####
1. `help` : Shows a menu of commands in game
1. `to <name>` : switch focus to specified character.
    - `<name>` can be a partial.
    - other character must also have `switch_focus` loaded.
    - if switch fails checks for any box in lobby to give focus to.
1. `back` : switch focus back to character that **last sent you focus using `switch_focus`**.
1. `(n)ext` : switch focus to next character in alphabetical order.
1. `(p)rev` : switch focus to previous character in alphabetical order.

#### Example use: ####
```plian
//switch to nif
```
this will pass focus to the character whos name matches `nif`, this could be `Nifim` or `Niflheim`

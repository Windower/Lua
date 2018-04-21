# SpellBook

This addon helps you find missing spells. You can search by job and level,
or by category.

## Usage
Spent jp can be specified for spells learned from Gifts by entering a value of 100-1500.
Spells are never given as Gifts for less than 100 jp and values under 100 are treated as level.


```
//spbk help
```
Show help text.
```
//spbk [current]
```
Show learnable spells based on current main and sub job and level/jp.
```
//spbk <main|sub> [<level|spent jp|all>]
```
Show missing spells for current main or sub job. Defaults to the job\'s current level/jp.
```
//spbk <job> [<level|spent jp|all>]
```
Show missings spells for specified job and level. Defaults to the job\'s level/jp.
```
//spbk <category> [all]
```
Show learnable spells by category. Limited to spells which are learnable, unless all is added after the category.

Categories: whitemagic, blackmagic, songs, ninjustu, summoning, bluemagic, geomancy, trusts, all (Trusts are not included in all)


## Credits

Inspired by the SpellCheck addon by Zubis

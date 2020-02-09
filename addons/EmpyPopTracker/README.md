# FFXI Empyrean Pop Tracker

An FFXI Windower 4 addon that tracks items and key items for popping Empyrean NMs in Abyssea, such as Briareus, Apademak and Sobek.

![Example of Cirein-croin tracking](readme/demo.png) ![All KIs obtained](readme/demo-full.png)

Key items are identified by the Zhe (Ж) character. Treasure pool counts for pop items are listed in amber after the item in the format of [3] (assuming 3 of that item in the pool).

## Load

`//lua load empypoptracker`

## Track an NM

`//ept track glavoid` tracks Glavoid pop items/key items.

You can also track an NM by using a wildcard pattern, because fuck having to remember how to spell Itzpapalotl:

`//ept track itz*`

For a full list of trackable NMs, see the nms directory or use the `list` command (see below).

## Other Commands

### List Trackable NMs

`//ept list`

### Open BG Wiki for NM

`//ept bg`

### Hide UI

`//ept hide`

### Show UI

`//ept show`

### Display Help

`//ept help`

## Where is Fistule?

Fistule is a unique NM when compared to the others. It does not require KIs that can be tracked, so it isn't included with the addon.

## Contributing

Notice something not quite right? [Raise an issue](https://github.com/xurion/ffxi-empy-pop-tracker/issues).

[Pull requests](https://github.com/xurion/ffxi-empy-pop-tracker/pulls) welcome!

# FindAll

This addon searches items stored on all your characters. To build the initial list, you must login and either receive any item-handling packet, logout, or input the `findall` command on any character at least once with each of them.  
The list is stored on the machine on which the addon is executed, being updated everytime you look for an item, certain packets arrive, or you logout, so this will not work the best if you use multiple PCs, unless you store your Windower installation in Dropbox or somewhere.
The addon will show a warning if your entire inventory has not re-loaded since zoning, but it should still be accurate because Windower's item handling API has moved to being packet based.

It offers an on-screen tracker that keeps track of items you specify or of your used/free space in specified bags.

## Tracker

The settings file has a field that you can use to define what is being tracked in a text box on the screen.
The text supports variables denoted by curly braces preceded by a dollar sign `${}`.
Each variable consists of two parts, the bag indicator and the item name, separated by a colo `:`.
For example, to track the amount of shihei in your inventory, you would do this:
```xml
        <Track>${inventory:shihei}</Track>
```

This will merely display a number on the screen. You can add flavor text outside of the variable:
```xml
        <Track>Shihei: ${inventory:shihei}</Track>
```

You can also use wildcards for item names:
```xml
        <Track>Crystals: ${inventory:*crystal}</Track>
```

You can use any of the bag names defined [here](https://github.com/Windower/Resources/blob/master/lua/bags.lua) as well as the key word `all` to search all bags. Every variable name is case-insensitive.

There are a three variables that can be used instead of item names: `$freespace`, `$usedspace` and `$maxspace`
If those are used, the respective value will be displayed:
```xml
        <Track>Inventory: ${inventory:$freespace}, Wardrobe: ${wardrobe:$freespace}</Track>
```

### Formatting

Since the tracker uses XML for formatting and XML is shitty, this will not work:
```xml
        <Track>
Inventory: ${inventory:$freespace}
Satchel:   ${satchel:$freespace}
Sack:      ${sack:$freespace}
Case:      ${case:$freespace}
Wardrobe:  ${wardrobe:$freespace}
        </Track>
```

The spaces and new lines will all collapse into a single space and you'll get one long and unreadable line.
To make the format appear as you have it in the XML settings file you need to wrap the entire text in `<![CDATA[` and `]]>` tags:
```xml
        <Track>
<![CDATA[Inventory: ${inventory:$freespace}
Satchel:   ${satchel:$freespace}
Sack:      ${sack:$freespace}
Case:      ${case:$freespace}
Wardrobe:  ${wardrobe:$freespace}]]>
        </Track>
```

That will correctly preserve any formatting you have inside the text.
With that, you can even do something like this:
```xml
        <Track>
<![CDATA[Inventory: ${inventory:$usedspace||%2i}/${inventory:$maxspace||%2i} → ${inventory:$freespace||%2i}
Satchel:   ${satchel:$usedspace||%2i}/${satchel:$maxspace||%2i} → ${satchel:$freespace||%2i}
Sack:      ${sack:$usedspace||%2i}/${sack:$maxspace||%2i} → ${sack:$freespace||%2i}
Case:      ${case:$usedspace||%2i}/${case:$maxspace||%2i} → ${case:$freespace||%2i}
Wardrobe:  ${wardrobe:$usedspace||%2i}/${wardrobe:$maxspace||%2i} → ${wardrobe:$freespace||%2i}]]>
        </Track>
```

And it will result in this:

![Tracker example](https://picster.at/img/8/f/9/8f93097ce393a03b4196ef2602186c27.png)

## Commands

### Update ###

```
findall
```

Forces a list update

### Search ###

```
findall [:<character1> [:...]] <query> [-e<filename>|--export=<filename>]
```
* `character1`: the name of the characters to use for the search.
* `...`: variable list of character names.
* `query` the word you are looking for.
* `-e<filename>` or `--export=<filename>` exports the results to a csv file. The file will be created in the data folder.

Looks for any item whose name (long or short) contains the specified value on the specified characters.

## Examples ##

```
findall thaumas
```

Search for "thaumas" on all your characters.

```
findall :alpha :beta thaumas
```

Search for "thaumas" on "alpha" and "beta" characters.

```
findall :omega
```

Show all the items stored on "omega".

----

## TODO

- Use IPC to notify the addon about any change to the character's items list to reduce the amount of file rescans.
- Use IPC to synchronize the list between PCs in LAN or Internet (requires IPC update).

----

## Changelog

### v1.20170501
* **add**: Added a setting to stop the display of keyitems. Maybe someone will add a command toggle for it later?

### v1.20170405
* **fix**: Adjusted the conditions for updating the shared storages.json to make it more robust.
* **add**: Added key item tracking.

### v1.20150521
* **fix**: Fixed after May 2015 FFXI update
* **change**: Future proofed the addon to be less prone to breaks

### v1.20140328
* **change**: Changed the inventory structure refresh rate using packets.
* **add**: IPC usage to track changes across simultaneously active accounts.

### v1.20140210
* **fix**: Fixed bug that occasionally deleted stored inventory structures.
* **change**: Increased the inventory structure refresh rate using packets.

### v1.20131008
* **add**: Added new case storage support.

### v1.20130610
* **add**: Added slips as searchable storages for the current character.
* **add**: The search results will show the long name if the short one doesn't contain the inputted search terms.

### v1.20130605
* **fix**: Fixed weird results names in search results.

### v1.20130603
* **add**: Added export function.
* **change**: Leave the case of items' names untouched

### v1.20130529
* **fix:** Escaped patterns in search terms.
* **change**: Aligned to Windower's addon development guidelines.

### v1.20130524
* **add:** Added temp items support.

### v1.20130521
* **add:** Added characters filter.

### v1.20130520
* First release.

# Clock

Displays the current time in various time zones around the world in a customizable format on the screen.

### Commands

#### Time format

```
clock format [new]
```

If `new` is provided, will set that as the new format, according to [these rules](http://www.cplusplus.com/reference/ctime/strftime/). If omitted, will print out the current format.

#### Sorting

```
clock sort [order]
```

If `order` is provided, will set that as the new sorting order. If omitted, will print out the current sorting order. Valid values are:
* `None`: Leaves the order as it is defined in the file
* `Alphabetical`: Sorts them alphabetically by their time zone abbreviation
* `Time`: Sorts them according to the time they display in ascending order

#### Add time zone

```
clock add <timezones...>
```

Appends a time zone to the list of currently displayed time zones. The `timezone` parameter needs to be one of [these abbreviations](https://github.com/Windower/Lua/blob/4.1-dev/addons/Clock/time_zones.lua).

#### Remove time zone

```
clock remove <timezones...>
```

Removes a time zone from the list of currently displayed time zones. The `timezone` parameter needs to be one of [these abbreviations](https://github.com/Windower/Lua/blob/4.1-dev/addons/Clock/time_zones.lua).

#### Set up time zone display

```
clock display <timezone> <name>
```

Sets the display name for a time zone, instead of displaying the time zone identifier. So `clock display jst JP clock` would display `JP clock` before the time instead of `JST`.

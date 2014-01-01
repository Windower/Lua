# Update

Once loaded can update all addons and plugins to the newest version using `//update`. This can also be done automatically by configuring the settings file or by typing `//update auto`.

### Commands

#### Update

```
update
```

Will send an update command.

**Note:** This interferes with Spellcast XMLs using the custom `update` trigger command. To resolve that problem stop using Spellcast.

#### Toggle automatic updates

```
update auto [on|off]
```

Sets automatic updating to on or off (toggles if no argument specified). Note that automatic updates will not check for updates while you're currently in combat.

#### Set update interval

```
update interval <time>
```

Sets the automatic update interval to the provided time. Allows unit conversion, defaults to seconds. Example:

```
update interval 5min
update interval 2h
update interval 30
```

These will set the interval to 5 minutes, 2 hours and 30 seconds respectively.

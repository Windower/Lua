Author:Stjepan Bakrac

# AutoJoin

Once loaded, will automatically join party and alliance invites. If you're in a CS, it will wait until it's finished and then join (unless the invite time expires). It will also wait in similar situations, such as being dead and unable to act. It will not process the invite at all if the treasure pool is not empty. This feature may be extended in the future, once access to treasure pool information is exposed in Lua, in which case it could automatically join once the pool empties.

### Modes

AutoJoin can operate in two modes (can be changed in the settings file):

* Whitelist mode [default]
Will only join invites from people you have specifically whitelisted. See below for whitelist commands.

* Blacklist mode
Will always join, except invites from people you blacklisted. Note that this is _not_ your FFXI blacklist, but another blacklist you have to create for this.

### Commands

All commands are prefaced with `//autojoin`, or `//aj`.

#### Mode switch

```
//autojoin mode [[b|black|blist|blacklist]|[w|white|wlist|whitelist]]
```

If no mode is specified, the current mode will be printed.

#### Add names to blacklist/whitelist

```
//autojoin [[b|black|blist|blacklist]|[w|white|wlist|whitelist]] [[+|a|add]|[-|r|remove]] [name [...]]
```

Will add or remove the specified names to the blacklist or whitelist. If no names are specified, it will print out the current blacklist or whitelist.

#### Print current settings

```
//autojoin status
```

Shows the current mode, the people on the blacklist and whitelist, as well as if auto-decline for blacklisted people is activated.

#### Save settings

```
//autojoin save
```

Saves current settings for all characters. This will overwrite all user-defined settings. Nothing is needed to save settings for the current character, that happens automatically any setting is changed.


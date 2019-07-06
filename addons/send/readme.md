## Usage
Syntax for the send command is send [playername, @others, @all, @job] [command]

e.g. 
```
/con send @all /ma "Blizzard" <t>
```

If you wish to change the color of the text added from aecho. Or any plugin that includes send <player> atc. Near the end of the send.lua you will find the following:

```
windower.add_to_chat(55,msg:sub(5))
```

You may change the 55 to any number from 1 to 255 to get a (not always) different color. 

### Sending mob ids through send

You can send target ids from the sender to the receiver. Any addon could take advantage of this, but right now
it's especially advantageous to use with gearswap. Gearswap will resolve the mob id to the monster if it is within range.

```
/con send @others /ma "Blizzard" <tid>
```

This is faster than the current alternative of
```
/con send @others /assist Player1
<wait 1>
/con send @others /ma "Blizzard" <t>
```

and more accurate than

```
/con send @others /ma "Blizzard" <bt>
```

because you may not always know what you are going to get with `<bt>`

You can also use last sub target id for when you are engaged and don't want to switch targets.

```
/ta <stnpc>
/con send @others /ma "Blizzard" <laststid>
```

`/ta <stnpc>` will block execution until you are finished selecting a monster
then it will execute the next line.

#### List of target ids

* `tid`: the id of the target
* `laststid`: last subtarget (e.g stnpc)
* `meid`: the id of yourself
* `petid`: player's pet id
* `stid`: current sub-target id
* `btid`: Party's enemy, is not guaranteed to return the same mob as <bt>
* `htid`: help target id
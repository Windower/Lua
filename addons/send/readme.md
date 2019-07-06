## Usage
Syntax for the send command is 

```
send [playername, @others, @all, @job] [command]
```

Available send targets
* playername
* @others
* @all
* @job

e.g. 
```
/con send @all /ma "Blizzard" <t>
```

### Sending mob ids through send

The next two examples require gearswap to be loaded to use. These examples pass the mob id from the sender to the receiver. With the receiver having gearswap loaded, it will resolve the id to the correct monster if it is in range.

```
/con send @others /ma "Blizzard" <tid>
```

```
/ta <stnpc>
/con send @others /ma "Blizzard" <laststid>
```

#### List of target ids

* `tid`: the id of the target
* `laststid`: last subtarget
* `meid`: the id of yourself
* `petid`: player's pet id
* `stid`: current sub-target id
* `btid`: Party's enemy, is not guaranteed to return the same mob as <bt>
* `htid`: help target id
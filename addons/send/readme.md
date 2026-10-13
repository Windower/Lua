## Usage

```
//send <target> <command>
```

The `target` can be:
* the receiver's name
* `@all` to send to all instances,
* `@others` to send to all instances excluding the sender,
* `@party` to send to all instances that are in the sender's party,
* `@zone` to send to all instances in the same zone as the sender,
* `@<job>` to send to every instance on that job (e.g. `@whm`). If two characters are on the same job, both receive the command.
* `@<job>:<N>` to send to only the Nth character on that job (e.g. `@cor:2`). Characters sharing a job are ordered alphabetically by name. If there is no such character, `send` prints `no character found`.

The `command` can be any valid FFXI or Windower command. It is sent as-is and never modified, apart from the entity ID substitution described below.

Each instance announces its name and main job to the others, which is how `@<job>:<N>` is resolved.

Assuming `Alice` and `Bob` are both CORs:
```
//send @cor /ma "Haste" <me>        (both Alice and Bob cast)
//send @cor:2 /ma "Haste" <me>      (only Bob casts)
```

**Examples:**
```
//send @all /ma "Blizzard" <t>

//send @whm /ma "Haste" <me>

//send @cor:2 /ma "Haste" <me>

//send Mymule reload timers
```

## Sending entity IDs

Entity IDs can be sent to the receiver by appending `id` to a target specifier, like `<tid>` for the target's ID. This works not just for `<tid>` but for all common targets mentioned [here](https://github.com/Windower/Lua/wiki/FFXI-Functions#windowerffxiget_mob_by_targettarget), i.e. `<laststid>`, `<meid`, etc. To be able to use in-game actions with target IDs like that requires GearSwap to be loaded on the receiver's end.

Examples:
```
//send Mymule /ma "Stun" <tid>

/ta <stnpc>
//send Mymule /ma "Blizzard" <laststid>
```

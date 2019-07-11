## Usage

```
//send <target> <command>
```

The target can be the receiver's name, `@all` to send to all instances, `@other` to send to all instances excluding the sender or `@<job>` to send to a specific job. The command can be any valid FFXI or Windower command.

Examples:
```
//send @all /ma "Blizzard" <t>

//send @whm /ma "Haste" <me>

//send Mymule //reload timers
```

## Sending entity IDs

Entity IDs can be sent to the receiver by appending `id` to a target specifier, like `<tid>` for the target's ID. This works not just for `<tid>` but for all common targets mentioned [here](https://github.com/Windower/Lua/wiki/FFXI-Functions#windowerffxiget_mob_by_targettarget), i.e. `<laststid>`, `<meid`, etc. To be able to use in-game actions with target IDs like that requires GearSwap to be loaded on the receiver's end.

Examples:
```
//send Mymule /ma "Stun" <tid>

/ta <stnpc>
//send Mymule /ma "Blizzard" <laststid>
```

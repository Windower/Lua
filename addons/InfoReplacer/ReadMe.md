# InfoReplacer #

Replaces outgoing text prefixed by % with respective information. For a complete list of replacements, view [`reps.lua`](https://github.com/Windower/Lua/blob/4.1/addons/InfoReplacer/reps.lua).

----

### Commands: ###

#### Show replacements ####

```
//inforeplacer list
```

Shows all (custom) replacement names.

#### Set custom replacement ####

```
//inforeplacer set <name> <value>
```

Defines a custom replacement variable as the provided value.

#### Set custom code replacement ####

```
//inforeplacer seteval <name> <code>
```

Defines a custom replacement variable as the provided Lua expression. This expression will be evaluated whenever it appears in the chat, so this can be used to print dynamic values.

#### Remove custom replacement ####

```
//inforeplacer unset <name>
```

Deletes a previously defined custom replacement variable.

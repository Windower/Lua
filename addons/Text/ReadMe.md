# Text

Allows creation and manipulation of text objects on the screen.

### Commands

All commands are of the following form:
```
text <name> <command> [args1 [arg2 [...]]]
```

There are two special commands to create and delete text objects:
* `create`: Creates a text object with the specified name and optionally sets the contents to the following string
* `delete`: Deletes the text object with the specified name

All other commands and their arguments can be found in the [`texts` library](https://github.com/Windower/Lua/blob/4.1-dev/addons/libs/texts.lua). Every function in there that modifies the text object can be used as a command.

### Examples

The following list of commands will create a text object containing the text "Awkward" at position (500, 500) in a huge font and bright yellow color.

```
text foo create Awkward
text foo pos 500 500
text foo color 255 255 0
text foo size 50
text foo italic true
```

This will delete it again
```
text foo delete
```

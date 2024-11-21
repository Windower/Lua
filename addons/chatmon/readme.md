# Chatmon #

* Port of chatmon plugin, create audible alert in response to chat events.

----

### Settings:

* Chatmon uses 'settings.xml' in its data folder for all settings.
* `DisableOnFocus`: `true` or `false` disables the playing of sounds when the gam window has focus.
* `SoundInterval`: the number of seconds to wait before allowing another sound to be played.

----

### User File:

#### Character specific:
* a file named `data/<character_name>.lua` whill be loaded for `<character_name>` when they log in.
* if no character specific file is found, `data/global.lua` will be loaded instead.

#### Tigger Fields:
* `from`: a set of chat name you would like the trigger to happen on, the full list of chat modes can be found here [resources/chat.lua](https://github.com/Windower/Resources/blob/master/resources_data/chat.lua)

  * in addition to the stated chat modes, you can provide `"all"` this flag will trigger checks of all text that is displayed in the chat.

* `notFrom`: a set of chat mode names you want the tigger to **ignore**.

* `match`: text you whould like to match to have the trigger sound to be played, 

  * `*` can be used as a wild card. Ex. `*Nif*` will trigger for any text containing with `Nif` such as `Hi Nifim` or `Hi Niflheim` or `lolNifim`

  * `|` cab be used to seperate multiple words you want to tigger for such as `Jo|Yo`, will trigger `Jo` and `Yo`

  * `<name>` can be used as a special flag to cover your character name in a number of common contexts.

  * when the trigger source is `tell`, `invite`, or `examine` the text evaluated for match is the **senders name** all other sources evaluate the message text.

* `notMatch`: text you would like to **not** match for the trigger sound to be played, this would allow you to filter out terms you know might conflit with your match string.

  * Ex. you can have `Niflheim` this would prevent the match of `Nif*` from playing the sound if the full the text being evaluated is is `Niflheim`

* `sound`: this is the path to the sound file you want to play, if just a file name is given the file will be assumed to be in the `sounds` folder in the chatmon file directory.

#### Example Trigger:

```lua
{ from = S{ "tell" }, notFrom = S{}, match = "*", notMatch = "", sound = "IncomingTell.wav"},
```

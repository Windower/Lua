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

  * in addition to the stated chat modes, you can provide `all`.
    * `all` will trigger all that is displayed in the chat.
    * `all` respect the in-game blacklist, the other channel options do not.
    * `all` is affected unpredictabilty by addons which alter the text, just be aware when making your match text. ex addon: battlemod
    * `all` does contain the full text displayed in the chat, meaning the sender's name will be part of the beginning of the text that is evaluated.

* `notFrom`: a set of chat mode names you want the tigger to **ignore**.

* `match`: text you whould like to match to have the trigger sound to be played, 

  * `*` can be used as a wild card. Ex. `*Nif*` will trigger for any text containing with `Nif` such as `Hi Nifim` or `Hi Niflheim` or `lolNifim`

  * `|` can be used to seperate multiple words you want to tigger for such as `Jo|Yo`, will trigger `Jo` and `Yo`

  * `<name>` can be used as a special flag to cover your character name in a number of common contexts.

  * when the trigger source is `tell`, `emotes`, `invite`, or `examine` the text evaluated for match is the **senders name** all other sources evaluate the message text.

* `notMatch`: text you would like to **not** match for the trigger sound to be played, this would allow you to filter out terms you know might conflit with your match string.

  * Ex. you can have `Niflheim` this would prevent the match of `Nif*` from playing the sound if the full the text being evaluated is is `Niflheim`

* `sender`: text you want to match the sender's name.

  * only valid for multi-player commuication channels. i.e. `say`, `shout`, `linkshell`, ect...

  * does not work with `all`, `tell`, `emotes`, `invite` or `examine`

* `notSender`: text you do not want to match the sender's name.

  * only valid for multi-player commuication channels. i.e. `say`, `shout`, `linkshell`, ect...

  * does not work with `all`, `tell`, `emotes`, `invite` or `examine`

* `sound`: this is the path to the sound file you want to play, if just a file name is given the file will be assumed to be in the `sounds` folder in the chatmon file directory.

### Example Trigger:

#### This example triggers when any player other than Arcon says something containing Nif but not if they Nifl:
```lua
{ from = S{ "say" }, notFrom = S{ "shout" }, match = "*Nif*", notMatch = "*Nifl*", notSender = "Arcon" sound = "IncomingTalk.wav"},
```
triggers exampe:
> Iyroku : Hi Nif

does not triggers example:
> Arcon : Hi Nif

> Iyroku : Hi Nifl

#### This example triggers when a monster uses Beserk unless it is a Mountain Sheep:
```lua
{ from = S{ "all" }, match = "*Beserk*", notMatch = "*Mountain Sheep*", sound = "SomeCustomSound.wav"},
```
triggers exampe:
> [Muspelheim] Beserk 🡒 Muspelheim

does not triggers example:
> [Mountain Sheep] Beserk 🡒 Muspelheim

# Chatmon #

* Port of chatmon plugin, create audible alert in response to chat events.

----

### Settings:

* Chatmon uses 'settings.xml' in its data folder for all settings.
* `DisableOnFocus`: `true` or `false` disables the playing of sounds when the gam window has focus.
* `SoundInterval`: The number of seconds to wait before allowing another sound to be played.

----

### User File:

#### Character specific:
* A file named `data/<character_name>.lua` whill be loaded for `<character_name>` when they log in.
* If no character specific file is found, `data/global.lua` will be loaded instead.

#### Tigger Fields:
* `from`: A set of chat names you would like the trigger to happen on, the full list of chat names can be found here [resources/chat.lua](https://github.com/Windower/Resources/blob/master/resources_data/chat.lua)

  * in addition to the stated chat modes, you can provide `all`.
    * `all` Will trigger all that is displayed in the chat.
    * `all` Respect the in-game blacklist, the other channel options do not.
    * `all` Is affected unpredictabilty by addons which alter the text, just be aware when making your match text. For example the addon battlemod.
    * `all` Does contain the full text displayed in the chat, meaning the sender's name will be part of the beginning of the text that is evaluated.

* `notFrom`: A set of chat mode names you want the tigger to **ignore**.

* `match`: Text you whould like to match to have the trigger sound to be played, 

  * `*` Can be used as a wild card. Ex. `*Nif*` will trigger for any text containing with `Nif` such as `Hi Nifim` or `Hi Niflheim` or `lolNifim`

  * `|` Can be used to seperate multiple words you want to tigger for such as `Jo|Yo`, will trigger `Jo` and `Yo`

  * `<name>` Can be used as a special flag to cover your character name in a number of common contexts.

  * When the trigger source is `tell`, `emote`, `invite`, or `examine` the text evaluated for match is the **senders name** all other sources evaluate the message text.

* `notMatch`: Text you would like to **not** match for the trigger sound to be played, this would allow you to filter out terms you know might conflit with your match string.

  * Ex. You can have `Niflheim` this would prevent the match of `Nif*` from playing the sound if the full the text being evaluated is is `Niflheim`

* `sender`: Text you want to match the sender's name.

  * Only valid for multi-player commuication channels. i.e. `say`, `shout`, `linkshell`, ect...

  * Does not work with `all`, `tell`, `emote`, `invite` or `examine`

* `notSender`: Text you do not want to match the sender's name.

  * Only valid for multi-player commuication channels. i.e. `say`, `shout`, `linkshell`, ect...

  * Does not work with `all`, `tell`, `emote`, `invite` or `examine`

* `sound`: This is the path to the sound file you want to play, if just a file name is given the file will be assumed to be in the `sounds` folder in the chatmon file directory.

### Example Trigger:

#### This example triggers when any player other than Arcon says something containing Nif but not if they Nifl:
```lua
{ from = S{ "say" }, notFrom = S{ "shout" }, match = "*Nif*", notMatch = "*Nifl*", notSender = "Arcon" sound = "IncomingTalk.wav"},
```
Example text that would trigger the above trigger:
> Iryoku : Hi Nif

Examples that would not trigger:
> Arcon : Hi Nif

> Iryoku : Hi Nifl

#### This example triggers when the text Beserk is added to the chat unless the text also contains Mountain Sheep:
```lua
{ from = S{ "all" }, match = "*Beserk*", notMatch = "*Mountain Sheep*", sound = "SomeCustomSound.wav"},
```
Example text that would trigger the above trigger:
> [Muspelheim] Beserk 🡒 Muspelheim

Example that would not trigger:
> [Mountain Sheep] Beserk 🡒 Mountain Sheep

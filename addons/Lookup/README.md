# Lookup
A simple [Windower4](http://www.windower.net/) addon that looks up search terms through in-game commands.

The default search is performed with the following command:
```
//lookup "Search Term"
```
This will open up the search in your default browser.

The search term can be plain text, auto-translate text, or one of the available [selectors](#selectors). If the search term contains a space, it must be surrounded in quotes (this does not apply to selectors).

The available search sites are [FFXIclopedia](http://ffxiclopedia.wikia.com/), [BGWiki](http://www.bg-wiki.com), [FFXIAH](http://www.ffxiah.com), [FFXIDB](http://www.ffxidb.com), and [Google](http://www.google.com).

See the [commands](#commands) section for a list of all available commands.

## Selectors
Selectors can be used in place of plain text search terms. They are very useful for quickly getting information about something in the environment or a recently obtained item.

| Selector | Replacement |
|----------|-------------|
| `<t>` | The current target's name. |
| `<bt>` | The current battle target'name . |
| `<pet>` | The name of the current player's pet. |
| `<me>` | The current player's name. |
| `<r>` | The name of the player that last sent a tell to you. |
| `<job>` | The current player's main job. |
| `<subjob>`<br>`<sj>` | The current player's subjob. |
| `<area>`<br>`<zone>` | The current area/zone. |
| `<item>`<br>`<lastitem>` | The last item placed in the player's inventory, including items moved from other bags. |

## Commands
```
//lookup "Search Term"
```
Searches for the term on the default site. The default site is set to "ffxiclopedia" initially, but can be changed with the "default" command.

#### Default
```
//lookup default "site"
```
Sets the default site to search with. Saved in the global settings (not character-specific).

#### FFXIclopedia
```
//lookup ffxiclopedia "Search Term"
```
```
//lookup ffxi "Search Term"
```
```
//lookup wikia "Search Term"
```
Searches for the term on [FFXIclopedia](http://ffxiclopedia.wikia.com/).

#### BGWiki
```
//lookup bg-wiki "Search Term"
```
```
//lookup bgwiki "Search Term"
```
```
//lookup bg "Search Term"
```
Searches for the term on [BGWiki](http://www.bg-wiki.com).

#### FFXIAH
```
//lookup ffxiah "Item"
```
```
//lookup ah "Item"
```
Searches for the item on [FFXIAH](http://www.ffxiah.com).

```
//lookup ffxiahplayer "Player"
```
```
//lookup ffxiahp "Player"
```
```
//lookup ahp "Player"
```
Searches for the player on [FFXIAH](http://www.ffxiah.com).

#### FFXIDB
```
//lookup ffxidb "Search Term"
```
```
//lookup db "Search Term"
```
Searches for the term on [FFXIDB](http://www.ffxidb.com).

#### Google
```
//lookup google "Search Term"
```
Searches for the term on [Google](http://www.google.com).

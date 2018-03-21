# Lookup
A simple [Windower4](http://www.windower.net/) addon that looks up search terms through in-game commands.

The default search is performed with the following command:
```
//lookup "Search Term"
```
Alternatively, the shorthand `lu` can be used:
```
//lu "Search Term"
```

Running this command will open up the search in your default browser.

The search term can be plain text, auto-translate text, or one of the available [selectors](#selectors). If the search term contains a space, it must be surrounded in quotes (this does not apply to selectors).

The default search sites are [FFXIclopedia](http://ffxiclopedia.wikia.com/), [BGWiki](http://www.bg-wiki.com), [FFXIAH](http://www.ffxiah.com), [FFXIDB](http://www.ffxidb.com), and [Google](http://www.google.com). See the [site command](#site) for how to add additional sites.

See the [commands](#commands) section for a list of all available commands.

## Selectors
Selectors can be used in place of plain text search terms. They are very useful for quickly getting information about something in the environment or a recently obtained item.

The following selectors are accepted by this addon:

| Selector | Replacement |
|----------|-------------|
| `<job>`<br>`<mjob>` | The current player's main job. |
| `<sjob>` | The current player's subjob. |
| `<zone>` | The current area/zone. |
| `<item>` | The last item placed in the player's inventory, including items moved from other bags. |

The selectors found in [Windower's documentation](https://github.com/Windower/Lua/wiki/FFXI-Functions#windowerffxiget_mob_by_targettarget) are also accepted. Some of the more useful selectors are listed below, for convenience:

| Selector | Replacement |
|----------|-------------|
| `<t>` | The current target's name. |
| `<bt>` | The current battle target'name . |
| `<pet>` | The name of the current player's pet. |
| `<me>` | The current player's name. |
| `<r>` | The name of the player that last sent a tell to you. |

## Commands
```
//lookup "Search Term"
```
Searches for the term on the default site. The default site is set to "ffxiclopedia" initially, but can be changed with the "default" command.

Alternatively, the shorthand `lu` can be used:
```
//lu "Search Term"
```

#### Default
```
//lookup default "site"
```
Sets the default site to search with. Saved in the global settings (not character-specific).

```
//lookup default player "site"
```
```
//lookup default p "site"
```
Saves the default site only for the current player.

#### Site
```
//lookup site "site" search "http://www.example.com/search?q=${term}"
```
Adds or modifies the site lookup capability.

The second argument, `"site"` is the site that you're modifying. For example, specifying `"ffxiclopedia"` would modify the settings for `ffxiclopedia` searches. New sites can also be added this way.

The third argument, `search`, can be substituted for `zone` or `item` if the site supports zone or item ids in its url.

The last argument is the url of the search. The `${term}` in the url will be substituted for the search term when a lookup is performed.

```
//lookup site "site" remove
```
Removes all lookup capability for the specified site (`"site"`).

```
//lookup site "site" search remove
```
Removes the `search` lookup capability for the specified site (`"site"`). The `search` argument can also be substituted for `zone` or `item`.

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

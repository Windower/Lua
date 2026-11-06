#Itemizer

Provides a chat/console interface for moving items around between bags. Optionally also automatically fetches items into the main inventory before item usage (both regular usage and Ninjutsu tools).

### Commands
```
itemizer delay <delay>
```

Sets the delay for pulling items into your inventory to 'delay'. (Default 0.5)

```
itemizer autoitems (shortened: ai)
```

Toggles the auto-pulling of items from bags if not in your inventory. (Default: True)

```
itemizer autostack (shortened: as)
```

Toggles the auto-stacking of items when moving items to non-inventory bags. (Default: True)

```
itemizer autoninjatools (shortened: ant)
```

Toggles automatic retrieval of missing ninja tools from accessible bags. (Default: True)

```
itemizer useuniversaltool <spell> (shortened: uut)
```

Toggles universal tool preference for `spell` on NIN main. Omit the :ichi or :ni suffix. Enabled by default for all spells. For example, `itemizer uut katon` toggles the preference for Katon.

```
itemizer ninjatoolfallback (shortened: ntf)
```

Toggles fallback to the spell-specific tool on NIN main. It applies only when automatic ninja tool retrieval is enabled, the spell prefers a universal tool, and Itemizer cannot find that tool. For example, Utsusemi falls back from Shikanofuda to Shihei and Katon falls back from Inoshishinofuda to Uchitake. This setting defaults to on.

```
get <item> [bag] [count]
```

Retrieves the specified item from the specified bag. If `bag` is omitted it will fetch the item from any accessible bag, if available. If `count` is omitted only a single item is fetched. If `count` is `all` all items will be fetched.

```
put <item> <bag> [count]
```

Places the specified item into the specified bag. If `count` is omitted only a single item is put away. If `count` is `all` all items will be put away.

```
move <item> [source bag] <destination bag> [count]
```

Moves the specified item from the specified source bag to the specified destination bag. If `source bag` is omitted it will fetch the item from any accessible bag, if available. If `count` is omitted only a single item is fetched. If `count` is `all` all items will be fetched.

```
gets <item> [bag]
puts <item> <bag>
moves <item> [source bag] <destination bag>
```

Same as the `get`, `put` and `move` variants if `all` was specified for the `count` argument.

### Notes

Both the full name and the abbrevited names are valid entries. Wildcards are allowed. For example, `//get *ore` would fetch all ores from all accessible bags to the main inventory.

### Examples

```
//put Mandau sack
//put Whirlpool mask satchel
//get Hct. Subligar +1 storage
//get Raider's armlets +2 safe
//get "HoPe toRQue" locker
//get earth crystal 5
//get *crystal
```

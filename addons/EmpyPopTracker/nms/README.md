# NM data

The data structure for each trackable NM uses a series of nested NM entities. A standard NM entity contains the following data:

| Key                      | Type      | Required? | Description                         |
| ------------------------ | --------- | --------- | ----------------------------------- |
| name                     | String    | Required  | Name of the NM                      |
| collectable              | Number    | Optional  | The ID of the collectable item      |
| collectable_target_count | Number    | Optional  | The target no. of collectable items |
| pops                     | Table     | Optional  | The pop information for the NM      |
| pops{}.id                | Number    | Required  | The ID of the item/key item         |
| pops{}.type              | String    | Required  | Either "key item" or "item"         |
| pops{}.dropped_from      | NM Entity | Required  | A nested set of NM information      |

A simple example of the above would be:

```lua
{
    name = 'Azdaja',
    collectable = 3292, --Azdaja's Horn
    collectable_target_count = 75,
    pops = { {
        id = 1531, --Vacant Bugard Eye
        type = 'key item',
        dropped_from = { name = 'Deelgeed, Timed (F-9/F-10)' }
    } }
}
```

A larger example with multiple nested entities:

```lua
{
    name = 'Bukhis',
    collectable = 2966, --Bukhis's Wing
    collectable_target_count = 50,
    pops = { {
        id = 1508, --Ingrown Taurus Nail
        type = 'key item',
        dropped_from = {
            name = 'Khalkotaur, Forced (F-4)',
            pops = { {
                id = 3098, --Gnarled Taurus Horn
                type = 'item',
                dropped_from = { name = 'Aestutaur (G-9/G-10)' }
            } }
        }
    }, {
        id = 1509, --Ossified Gargouille Hand
        type = 'key item',
        dropped_from = {
            name = 'Quasimodo, Forced (F-4)',
            pops = { {
                id = 3099, --Gargouille Stone
                type = 'item',
                dropped_from = {
                    name = 'Gruesome Gargouille (F-10/G-10)'
                }
            } }
        }
    }, {
        id = 1510, --Imbrued Vampyr Fang
        type = 'key item',
        dropped_from = { name = 'Lord Varney, Timed (G-10/H-10)' }
    } }
}

```

The main addon file requires the index.lua file which in turn is responsible for requiring and returning data for each nm.

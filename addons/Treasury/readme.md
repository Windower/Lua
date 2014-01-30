This addon essentially does what LightLuggage does, but more user friendly.

Items will be passed or lotted based on the addon's internal code when:
1) The addon is loaded/reloaded
2) A new pass or lot command is inputted (both on a current or an alternate character if the global key word is used)
3) If a new item drops into the treasure pool


Commands:

//[lot|pass] [add|remove] {global} (item name)
Basic input command structure.  Examples available at the bottom.

//[lot|pass] list
Displays which items are currently in the addon's code

//[lot|pass] clear
Clears all of the items on a specified list

//treasury clearall
Clears all of the items on both the lot and the pass list


Global:
The 'global' key word is useful if you multi-box.

//pass add global earth crystal 
- This command will tell all of your characters to add 'earth crystal' to the list of items to pass


Wildcards:
This addon supports the use of wildcards [*].  

----Be careful when using it for it may (probably will) have unintended consequences.-----


Other special key words:
The key words available are listed below and can be used in place of a set group of items

'pool' - refers to all of the items currently in the treasure pool
'seals' - refers to all 5 types of seals (From Beastmen's Seals to Sacred Kindred Crests)
'currency' - refers to all dynamis currency (bynes, whiteshells, bronzepieces and 100s).  Not including forgotten items.
'junk' - refers to all crystals, geodes and elemental -ite items.  This does not include clusters.


Other functions:
This addon also auto sorts your inventory like Light Luggage does.



Examples:
//lot add fire crystal
- Adds 'fire crystal' to the list of items to always lot.

//lot remove ice crystal
- Removes 'ice crystal' from the list of items to always lot.

//lot list
- Displays a list of items that will be lotted.

//pass list
- Displays a list of items that will be passed.

//pass add global *crystal
- This command will tell all of your characters to add every item in the game that ends with 'crystal' to the pass list.  
- While this will pass items like Titanite and Shivite, it will also pass items like Alexandrite and Painite.  Be careful.
- It's typically not advised to use this unless your search term is very specific, like //lot add forgotten*
- Use the 'junk' key word to get rid of crystals/geodes/-ites!

//pass add global pool
- This command tells all of your character to add all of the items in the pool to the list of items to pass.

//lot add currency
- This command tells your current character to lot all dynamis of currency.

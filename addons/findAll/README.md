**Author:** Giuliano Riccio  
**Version:** v 1.20131120

# FindAll #

This addon searches items stored on all your characters. To build the initial list, you must login and logout (or input the "findall" command) at least once with each of them.  
The list is stored on the machine on which the addon is executed, being updated everytime you look for an item or on logout, so this will not work the best if you use multiple PCs, at least until IPC will let them communicate over LAN or Internet (in development).  
The addon has a deferral time of 20 seconds when it's loaded, you are logging in or zoning to give the game enough time to load all the items.  
If you notice that this time is too short, please create an issue report in the bug tracker.

## Commands ##
### findall ###
Forces a list update

```
findall
```

### Search ###
Looks for any item whose name (long or short) contains the specified value on the specified characters.

```
findall [:<character1> [:...]] <query> [-e<filename>|--export=<filename>]
```
* **_character1_:** the name of the characters to use for the search.
* **...:** variable list of character names.
* **_query_** the word you are looking for.
* **-e<filename>** or **--export=<filename>** exports the results to a csv file. The file will be created in the data folder.

### Examples ###
Search for "thaumas" on all your characters.

```
findall thaumas
```
Search for "thaumas" on "alpha" and "beta" characters.

```
findall :alpha :beta thaumas
```
Show all the items stored on "omega".

```
findall :omega
```

----

##TODO##

- Use IPC to notify the addon about any change to the character's items list to reduce the amount of file rescans.
- Use IPC to synchronize the list between PCs in LAN or Internet (requires IPC update).

----

##Changelog##
### v1.20131008 ###
* **add**: Added new case storage support

### v1.20130610 ###
* **add**: Added slips as searchable storages for the current character.
* **add**: The search results will show the long name if the short one doesn't contain the inputted search terms.

### v1.20130605 ###
* **fix**: Fixed weird results names in search results.

### v1.20130603 ###
* **add**: Added export function.
* **change**: Leave the case of items' names untouched

### v1.20130529 ###
* **fix:** Escaped patterns in search terms.
* **change**: Aligned to Windower's addon development guidelines.

### v1.20130524 ###
* **add:** Added temp items support.

### v1.20130521 ###
* **add:** Added characters filter.

### v1.20130520 ###
* First release.

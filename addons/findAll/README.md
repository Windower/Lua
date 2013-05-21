**Author:** Giuliano Riccio

**Version:** v 1.20130520

**Description:**  
This plugin searches for items stored on all of your characters. To build the initial list, you must login and logout (or input the "findall" command) at least once with each of them.  
The list is stored on the machine on which the addon is executed so this will not work the best if you use multiple PCs, at least until IPC will let multiple machines communicate over LAN or IP (in development).  
The addon has a deferral time of 20 seconds when being loaded or when logging in to give the game enough time to download all the items.  
If you notice that this time is too short, please create an issue report in the bug tracker.

The list is updated everytime you look for an item or on logout.

**Abbreviation:** //findall

**Commands:**

* findall -- forces an update of the list
* findall &lt;query&gt; -- looks for any item whose name (long or short) contains the specified value  
**example1:** findall thaumas -- searches for "thaumas" on all of your characters  
**example2:** findall :alpha :beta thaumas -- searches for "thaumas" on "alpha" and "beta" characters  
**example3:** findall :omega -- shows all the items stored on "omega"

**TODO**

- Use IPC to notify the addon about any change to the character's items list to reduce the amount of file rescans
- Use IPC to synchronize the list between PCs in LAN or Internet (requires IPC update)

#changelog
## v1.20130521
* added characters filter

## v1.20130520
* first release

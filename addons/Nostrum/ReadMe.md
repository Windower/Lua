# Nostrum

An interface which may ease the creation of interactive displays for party-related information.

### Commands

command(shortcut)

##### Abbreviation: //nos
1. help(h):
  - Prints a list of available commands.
2. refresh(r):
  - Compares the current party structures to the alliance structure in memory and adds any new members. Only nearby alliance members can be added to the structure, as Nostrum cannot track a player without access to their ID. This command is intended to be used in the relatively uncommon case where Nostrum is unable to gather the information it needs on load. This may occur if you load Nostrum while in a party where the members are spread out and do not receive an alliance update packet for some time afterwards.
3. visible(v) &lt;boolean&gt;:
  - Toggles the visibility of the overlay.
4. send(s) &lt;name&gt;: 
  - Requires send addon. Sends commands to the character whose name was provided. Revert this setting by entering the send command with no name argument.
5. debug &lt;script&gt; &lt;args&gt;:
  - Used for debugging overlays. Pass 'exit' to <script> to exit debug mode.
6. eval &lt;statement&gt;:
  - Used in a pinch.
  
Additional commands may be processed by overlay files. See the ReadMe file for the overlay you have selected for additional information.
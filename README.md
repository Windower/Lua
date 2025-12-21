# DoorHelper (Windower 4 Addon)

Author: **Aragan**  
Version: **1.6**  

DoorHelper is a Windower 4 addon that automatically interacts with nearby doors 
By default, it only runs inside **Sortie**.



---

## Features

- **Auto Door Interaction**
  - Scans nearby NPCs and interacts with the nearest “door-like” 

- **Sortie-Only Mode (Default: ON)**
  - When enabled, the addon logic only runs when you are inside the **Sortie** zone.


- **Debug Mode**
  - Prints Menu ID / NPC / Index / Zone when menu packets are received.

---

## Installation

1. Create a folder:
   - `Windower4/addons/DoorHelper/`

2. Put the addon file inside that folder:
   - `DoorHelper.lua`

3. Load the addon in-game:
   - `//lua l doorhelper`

(Optional) Add it to your `scripts/init.txt` if you want it to auto-load.

---

## Commands

DoorHelper supports these command aliases:

- `//doorhelper ...`
- `//dh ...`

### Auto-Yes Mode

- `//dh yes on`
- `//dh yes off`
- `//dh yes toggle`
- `//dh yes status`

### Debug Mode

- `//dh debug on`
- `//dh debug off`
- `//dh debug toggle`
- `//dh debug status`

### Sortie-Only Mode

- `//dh sortie on`  
  Restrict the addon to Sortie only (default).

- `//dh sortie off`  
  Allow the addon to run in any zone (except for the safety rule for Auto-Yes in zone 72).

- `//dh sortie toggle`
- `//dh sortie status`

### Skip Event

- `//dh skip`  
  Sends ESC a few times to try to close stuck menus/dialogs.


---

- **Too much spam in chat**
  - Turn debug off:
    - `//dh debug off`

---

## License

Personal use / private distribution unless you specify otherwise.

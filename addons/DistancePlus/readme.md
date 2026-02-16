# DistancePlus

**DistancePlus** is a Windower 4 addon that enhances the standard distance display in Final Fantasy XI. It provides precise distance tracking, visual range indicators for various combat modes (Ranged, Magic, Ninjutsu), and helps players position themselves effectively for abilities, casting, and avoiding vertical Area of Effect (AOE) damage.

## Features

* **Precise Distance Tracking:** Displays distance to the target with high precision (defaulting to 2 decimal places).
* **Model Size Correction:** Automatically accounts for the player's and the target's model sizes to calculate "true" interaction ranges.
* **Job & Mode Automation:** Automatically detects your main job and sets the appropriate distance mode (e.g., Magic for Mages, Gun for Corsairs).
* **Ranged Attack Assistance:** Visual color indicators for "True Shot" and "Square Shot" ranges for Bows, Crossbows, and Guns.
* **Pet Distance:** Displays the distance between you and your pet (useful for Beastmasters and Summoners).
* **Ability Range Tracker:** Lists job abilities and highlights them in **Green** when you are within range to use them.
* **Height/Vertical Tracking:** Displays the vertical distance (Z-axis) to the target, helping you determine if you are safe from vertical AOEs.

---

## Commands

Use the `//dp` command to control the addon.

| Command | Description |
| :--- | :--- |
| `//dp help` | Displays the help menu in the chat log. |
| `//dp default` | Resets the addon to standard distance tracking mode (White text). |
| `//dp magic` | Sets the mode to **Magic**. Useful for checking casting range. |
| `//dp ninjutsu` | Sets the mode to **Ninjutsu**. |
| `//dp gun` | Sets the mode to **Gun**. (Default for COR). |
| `//dp bow` | Sets the mode to **Bow**. (Useful for RNG). |
| `//dp xbow` | Sets the mode to **Crossbow**. (Useful for RNG). |
| `//dp ja` or `//dp abilitylist` | Toggles the **Ability List** on screen. Shows which JAs are in range. |
| `//dp height` | Toggles the **Height** display. Shows vertical distance to target. |
| `//dp maxdecimal` | Expands the distance display to 12 decimal places (Debug mode). |

---

## Modes and Color Keys

The distance text changes color to indicate your status based on the active mode.

### Ranged Modes (Gun, Bow, Xbow)
Calculates distance based on weapon type and model sizes to optimize damage.
* **Blue:** **True Shot** (Best damage range).
* **Green:** **Square Shot** (Good damage range).
* **Yellow:** Ranged Attack Capable (No distance bonus).
* **White:** Out of range (Cannot shoot).

### Magic & Ninjutsu Modes
* **Green:** Target is within casting range.
* **White:** Target is out of casting range.

### Pet Distance (BST)
* **Green:** Pet is within command range (approx. 4 yalms + model size).
* **White:** Pet is too far.

### Height (Vertical Distance)
Useful for positioning on slopes or stairs to avoid specific mob attacks.
* **Green:** **Safe.** You are vertically far enough from the mob (High or Low) to likely avoid vertical AOEs.
* **Red:** **Danger.** You are on the same vertical plane as the mob.

### Ability List
* **Green Text:** The ability is within range of the target.
* **White Text:** The ability is out of range.

---

## Automatic Job Detection
Upon loading or changing jobs, DistancePlus attempts to set the best mode for you:
* **RDM, BLM, GEO, SCH, WHM, BRD:** Auto-sets to **Magic** mode.
* **COR:** Auto-sets to **Gun** mode.
* **NIN:** Auto-sets to **Ninjutsu** mode.
* **RNG:** Defaults to standard (You must manually select `//dp bow`, `//dp xbow`, or `//dp gun`).

## Configuration
Settings such as font size, font type, and screen position can be customized in the `data/settings.xml` file.

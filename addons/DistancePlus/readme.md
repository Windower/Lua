# DistancePlus

**DistancePlus** is a Windower 4 addon that enhances the standard distance display in Final Fantasy XI. It provides precise distance tracking, visual range indicators for various combat modes (Ranged, Magic, Ninjutsu), and helps players position themselves effectively for abilities, casting, and avoiding vertical Area of Effect (AOE) damage.

## Features

* **Precise Distance Tracking:** Displays distance to the target with high precision (defaulting to 2 decimal places).
* **Contextual Labels:** Displays text indicators next to the distance (e.g., "True Shot", "Square Shot", "Critical Penalty") to let you know exactly where you stand.
* **Ranged Attack Assistance:** * **Blue:** **True Shot** (Bonus Damage Zone).
    * **Green:** **Square Shot** (Standard Damage).
    * **Yellow:** **Distance Penalty** (Too Far - Reduced Damage/Accuracy).
    * **Red:** **Critical Penalty** (Too Close - Massive Penalty).
* **Model Size Correction:** Automatically accounts for the player's and the target's model sizes to calculate "true" interaction ranges.
* **Job & Mode Automation:** Automatically detects your main job and sets the appropriate distance mode (e.g., Magic for Mages, Gun for Corsairs).
* **Performance Optimized:** Runs efficiently with throttled calculations to ensure zero impact on game frame rate.
* **Pet Distance:** Displays the distance between you and your pet (useful for Beastmasters and Summoners).
* **Ability Range Tracker:** Lists job abilities and highlights them in **Green** when you are within range to use them.
* **Height/Vertical Tracking:** Displays the vertical distance (Z-axis) to the target, helping you determine if you are safe from vertical AOEs.

---

## Commands

Use the `//dp` command to control the addon.

| Command | Description |
| :--- | :--- |
| `//dp help` | Displays the new, color-coded help menu and legend in the chat log. |
| `//dp default` | Resets the addon to standard distance tracking mode (White text). |
| `//dp magic` | Sets the mode to **Magic**. Green = In Casting Range. |
| `//dp ninjutsu` | Sets the mode to **Ninjutsu**. Green = In Casting Range. |
| `//dp gun` | Sets the mode to **Gun**. Displays True Shot/Square Shot logic. |
| `//dp bow` | Sets the mode to **Bow**. Displays True Shot/Square Shot logic. |
| `//dp xbow` | Sets the mode to **Crossbow**. Displays True Shot/Square Shot logic. |
| `//dp ja` | Toggles the **Ability List** on screen. Shows which JAs are in range. |
| `//dp height` | Toggles the **Height** display. Shows vertical distance to target. |
| `//dp maxdecimal` | Toggles high-precision display (12 decimal places) for debugging. |

---

## Modification Log (v2.0 Updates)

Below is a summary of the bugs fixed and enhancements implemented compared to the original version of the script.

### Enhancements
* **Visual Text Labels:** The distance display now includes text descriptions (e.g., "14.50 Distance Penalty") instead of just a number, making it immediately clear what your current status is.
* **"Critical Penalty" Zone:** Added a **Red** warning zone for being too close (Point Blank) to the target, which causes severe accuracy/damage penalties often overlooked by players.
* **Accessibility Improvements:** * Changed the "True Shot" color from dark blue (unreadable) to **Deep Sky Blue** (readable).
    * Fixed the "Yellow" color code to ensure it appears visible in the chat log.
* **Performance Throttling:** The math calculations now run 10 times a second instead of 60 times a second. This reduces CPU load by ~83% while keeping the display visually smooth.
* **New Help Menu:** Completely rewrote `//dp help` to include a color legend and tips on Weapon Skill mechanics (Physical vs. Magical distance rules).

### Bug Fixes & Code Cleanup
* **Global Variable Pollution:** Fixed a critical issue where variables like `settings`, `distance`, and `self` were declared globally. They are now `local`, preventing crashes or conflicts with other Windower addons.
* **Memory Optimization:** The `displayabilities` function now uses table insertion instead of string concatenation, preventing unnecessary garbage collection cycles and memory churn.
* **Logic Refactor:** Removed duplicate, copy-pasted code blocks for Gun, Bow, and Xbow logic. These are now handled by a single, smarter `get_ranged_status` function, making the code cleaner and easier to maintain.
* **Static Table Fix:** Moved the `range_mult` table definition outside of the main loop so it is created only once upon load, rather than being recreated every single frame.

# enemybar

This is an addon for Windower4 for FFXI. It creates a big health bar for the target to make it easy to see.

![alt text](https://i.imgur.com/8g96UZY.png)

### Commands:
target_frame = **t**arget/**s**ub**t**arget/**f**ocus**t**arget/**a**ggro/all. Specifies which target frame to update the settings for, or all of them.

| Command | Action |
| --- | --- |
| //eb setup/debug/demo/test | Activate setup mode. Enables draging target frames and displays everything with your current settings. Ctrl-drag to snap to grid. |
| //eb focustarget/ft [target name] | Specifies a focus target. The focus target frame will display this target's hp and status. |
| //eb **s**et pos *target_frame* x y | Moves a target frame to a specified position |
| //eb **s**et color *target_frame* red green blue | Specifies the hp bar color for the given target frame |
| //eb **s**et count *target_frame* i | Specifies the number of aggro'd monsters to display in the aggro frame |
| //eb **s**et stack_dir *target_frame* up/down | Specifies the stack direction of the aggro frame. Up stacks upwards, down stacks downwards |
| //eb **s**et stack_padding *target_frame* i | Specifies the distance between the target bars in the aggro frame |
| //eb **s**et font *target_frame* font_name | Specifies the font name for the given target frame. |
| //eb **s**et font_size *target_frame* i | Specifies the font size for the given target frame. |
| //eb **s**et width *target_frame* i | Specifies the width of the hp bar for the given target frame. |
| //eb **s**et show *target_frame* **t**rue/**f**alse/on/off/**y**es/**n**o | Display the given target frame. |
| //eb **s**et show_target_icon *target_frame* **t**rue/**f**alse/on/off/**y**es/**n**o | Display whether the enemy is targeted or not in the given target frame. |
| //eb **s**et show_target *target_frame* **t**rue/**f**alse/on/off/**y**es/**n**o | Display the target of the target in the given target frame. |
| //eb **s**et show_debuff *target_frame* **t**rue/**f**alse/on/off/**y**es/**n**o | Display the debuffs on the target in the given target frame. |
| //eb **s**et show_action *target_frame* **t**rue/**f**alse/on/off/**y**es/**n**o | Display the current action of the target in the given target frame. |
| //eb **s**et show_dist *target_frame* **t**rue/**f**alse/on/off/**y**es/**n**o | Display the distance from the target in the given target frame. |
| //eb help | Shows help text for this addon |

UPDATE: 1.1
Updates;
- unified healbar creation and management logic
Added several things:
- focus target function to track a specified target's status
- mob action (spell/ws) and attention tracking (not quite enmity, but close)
- aggro'd mobs can now be displayed as a stack of health bars + their action and attention
- display for target/subtarget/focustarget/aggro'd mobs' distance.
- indicator on aggro'd mobs' health bars for which is targeted.
- indicator on target/subtarget/focustarget/aggro'd mobs for crowd control status effects

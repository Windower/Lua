# InfoBar #

Displays a configurable bar showing information on your targets.

List of variables:
${name}, ${id}, ${index}, ${x}, ${y}, ${z}, ${facing}, ${facing_dir}, ${game_moon}, ${game_moon_pct}, ${zone_name}, ${notes}
${alchemy}, ${bonecraft}, ${clothcraft}, ${cooking}, ${fishing}, ${goldsmithing}, ${leathercraft}, ${smithing},
${woodworking} (this will show if the guild shops are closed or open)
player only variables: ${main_job}, ${main_job_level}, ${sub_job}, ${sub_job_level}
mob only variables: ${family}, ${job}, ${levelrange}, ${weakness}, ${resistances},
${immunities}, ${drops}, ${stolen}, ${spawns}, ${spawntime}, ${isagressive},
${islinking}, ${isnm}, ${isfishing}, ${detect}

Adding variables:
To add variables open the settings.xml in the data folder with an editor and add the variables as you wish
to the NoTarget (when you have no target or target yourself), TargetPC (you target another player),
TargetNPC (you target a npc) , TargetMob (you target a mob) tags.
You can also add normal strings to them, for example Name: ${name}

----

### Commands: ###

#### help ####

```
//ib|infobar help
```

Shows a list of commands.

#### notes add ####

```
//ib|infobar notes add <string>
```

Defines a note to the current target.

#### notes delete ####

```
//ib|infobar notes delete
```

Delete a note to the current target that was defined previously.

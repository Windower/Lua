# autoFPS

`autoFPS` is an addon for Windower that automatically sets the FPS to 30 during cutscenes to avoid any freezing behavior. This helps ensure a smooth gameplay experience during cutscenes by lowering the FPS, and then restores it once the cutscene is over.

## Version Changelog

- `v0.1` - Initial release.
- `v0.2` - Added per zone toggle.
- `v0.3` - Added command to control cutscene behavior.
- `v0.4` - Cleaned up code and added an exclusion list to avoid limiting FPS when navigating teleport or spark/accolade NPC menus.

## Features

- Automatically adjusts FPS during login, cutscenes, and certain NPC interactions.
- Restores FPS to uncapped (or 60 if configured) after the cutscene ends.
- Simple commands to manually control FPS settings.

## Installation

1. Download the `autoFPS` addon.
2. Place the `autoFPS` folder in your Windower `addons` directory.
3. Load the addon in-game using the command: `//lua load autoFPS`.
4. To autoload the addon, add the line `lua load autoFPS` to your init script.

## Dependencies

This addon requires the `config` plugin to be loaded to function properly.

## Usage

The following commands are supported in the `autoFPS` addon:

- `//autofps cs` or `//autofps cutscene` - Enable/disable controlling FPS during cutscenes.
- `//autofps zone` - Enable/disable controlling FPS per zone/area, configured in `zones.lua`.
- `//autofps help` - Displays the help menu.
- `//autofps reload` - Reloads the addon.
- `//autofps status` - Displays the current settings.

## Configuration

The FPS settings can be customized by modifying the `FrameRateDivisor` values in the script:
- `0` - Uncapped (can be limited in the NVIDIA Control Panel)
- `1` - 60 FPS
- `2` - 30 FPS

## Disable FPS in Busy Zones

If you experience FPS drops in certain zones, you can configure the file `zones.lua`. If you wish to not use this feature, you can configure the `settings.lua`; it's disabled by default.

## Credits

- Code for `cutscene detection` was inspired by the `giltracker` addon made by sylandro.
- Code for the `exclusion list` was inspired by the `FastCS` addon made by Cairthenn.
- Thank you to the `Windower` community for assistance with some questions during development.

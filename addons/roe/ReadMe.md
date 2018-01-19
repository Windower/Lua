**Author:**  Cair<br>
**Version:**  1.0<br>
**Date:** Oct. 30, 2017<br>

### ROE ###

This addon lets you save your currently set objectives to profiles that can be loaded. It can also be configured to remove quests for you. By default, ROE will remove quests that are not in a profile only if their progress is zero. You can customize this to your liking.



#### Commands: ####
1. help - Displays this help menu.
2. save <profile name> : saves the currently set ROE to the named profile
3. set <profile name> : attempts to set the ROE objectives in the profile
    - Objectives may be canceled automatically based on settings.
    - The default setting is to only cancel ROE that have 0 progress if space is needed
4. unset <profile name> : removes currently set objectives
    - if a profile name is specified, every objective in that profile will be removed
    - if a profile name is not specificed, all objectives will be removed (based on your settings)
5. settings <settings name> : toggles the specified setting
    * settings:
        * clear : removes objectives if space is needed (default true)
        * clearprogress : remove objectives even if they have non-zero progress (default false)
        * clearall : clears every objective before setting new ones (default false)
6. blacklist [add|remove] <id> : blacklists a quest from ever being removed
    - I do not currently have a mapping of quest IDs to names

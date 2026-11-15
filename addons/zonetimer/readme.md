# ZoneTimer

Version 2.0.0.0 displays the elapsed real-world time in the current zone. It can stay visible, remain hidden, or briefly appear with optional reminders.

A fresh installation shows the HUD at X=400, Y=0, in Arial size 12. Reminders are disabled. Settings files are created automatically; do not install a preconfigured `data` directory.

## Commands

Use `//zt` or `//zonetimer` in game. In the Windower console, omit the leading `//`.

| Command | Description |
| --- | --- |
| `//zt` | Print the current zone name and elapsed time to chat. |
| `//zt time` or `//zt t` | Same as `//zt`. |
| `//zt show` | Fade in and remain visible. Save this character's preference. |
| `//zt hide` | Fade out and remain hidden between temporary displays. Save this character's preference. |
| `//zt fade on` / `//zt fade off` | Enable or disable animations. Fades are enabled by default. |
| `//zt reminder 30` | Remind at each 30-minute interval since zone entry or timer reset. Use a positive whole number of minutes, including `1`. |
| `//zt reminder off` | Disable reminders. `0` also works. |
| `//zt reset` | Restart the current zone timer. |
| `//zt posX 400` / `//zt posY 0` | Set the horizontal or vertical position. |
| `//zt fontsize 12` | Set font size, from 1 to 100. Fractional sizes are supported. |
| `//zt font Arial Black` | Set the primary font. Names with spaces are supported; configured fallback fonts are retained. |
| `//zt color 255 255 255` | Set text RGB using three integers from 0 to 255. |
| `//zt bg_color 0 0 0` | Set background RGB using three integers from 0 to 255. |
| `//zt alpha 160` | Set text opacity from 0 (transparent) to 255 (opaque). `text_alpha` is an alias. |
| `//zt bg_alpha 120` | Set background opacity from 0 to 255. |
| `//zt bg show` / `//zt bg hide` | Show or hide the background independently of the text. `background` and `on`/`off` are also accepted. |
| `//zt padding 5` | Set background padding to an integer from 0 to 100 pixels. `pad` is an alias. |
| `//zt stroke 1` | Set outline width from 0 to 10. `off` removes it; `on` sets width 1. |
| `//zt bold on` / `//zt bold off` | Enable or disable bold text. |
| `//zt drag on` / `//zt drag off` | Enable or disable mouse dragging. The position saves on release. |
| `//zt help` | Display command help. |
| `//zt print` | Print entry and current Unix timestamps to the Windower console (legacy debug command). |

Use `fade`, `reminder`, `bg`, `color`, `bg_color`, `alpha`, `bg_alpha`, `padding`, `stroke`, `bold`, or `drag` without a value to display that setting. Commands are case-insensitive. Chat output requires a logged-in character.

## Appearance, previews, and dragging

The default appearance is white text, a black one-pixel outline, and a visible black background with zero padding. Text and background alpha both start at 255. Bold is off and dragging is on. Appearance changes apply immediately and save for the active character.

Changing an appearance setting while the HUD is hidden previews it for three seconds: one second fading in, one second holding, and one second fading out. Further changes extend the preview without flashing. Queries, timer commands, and reminder commands do not start previews. `show` and `hide` use one-second transitions and can reverse an active fade.

Dragging during a preview or reminder holds the HUD at its configured opacity until the mouse is released. Release starts a fresh three-second preview, or a ten-second display if a reminder has priority. Dragging does not change the saved visibility preference.

Text, outline, and background fade independently to their configured alpha values, not necessarily to 255. Changing text or background alpha during a fade updates its endpoint. Background visibility remains independent of its color and alpha.

With `fade off`, manual show/hide is immediate. Previews and reminders still last three and ten seconds, but appear and disappear without animation. No `prerender` fade handler is registered. Changing the fade setting during a temporary display restarts that display using the new setting.

NPC menus and cutscenes temporarily hide the HUD. Zoning also hides it and restores it on arrival, unless it is configured as hidden or an NPC event is still active. Fading out may not be visible if the game stops rendering during loading. Mog Houses sharing their parent zone ID do not reset elapsed time. Reminders continue counting. With `fade off`, these transitions are immediate. The timer and zone are checked once per second; no watchdog or packet injection is used.

## Optional reminders

For an OLED-friendly setup, use `//zt hide` followed by `//zt reminder 30`. The reminder interval is saved across addon reloads and game sessions.

Each reminder prints the actual zone name and elapsed time to chat: a blue `[Zone timer]` prefix, white explanatory text, a green zone name, and yellow elapsed time. When the HUD is normally hidden, it appears for ten seconds: one second fading in, eight seconds holding, and one second fading out. When permanently shown, it remains visible and the reminder only writes to chat.

Reminders take priority over appearance previews. Hiding the HUD does not disable reminders. Changing the interval selects the next interval boundary from zone entry or the last reset; it does not send missed reminders.

## Configuration files and upgrades

ZoneTimer uses Windower's `config` library to create and save settings. Shared defaults and character-owned data have separate files:

```text
data/settings.xml     Shared defaults and legacy character sections
data/alice.xml        Alice's overrides and zone state
data/bob.xml          Bob's overrides and zone state
```

`settings.xml` supplies shared `<global>` defaults. Once this file exists, ZoneTimer reads it without rewriting it. Each lowercase character file stores `<overrides>` and `<zone_state>` inside its own `<global>` section. In a character file, `<global>` is local to that file; it does not affect other characters.

Commands save only the preferences they explicitly set. An explicit value remains a character override even when it currently matches a shared default. Other preferences continue to inherit shared defaults. Zone tracking and temporary fades do not create appearance overrides. Different character names write to different files, so they do not overwrite one another's settings. Filenames intentionally do not include a server ID: identical names on different servers share preferences when using the same addon directory.

On the first load for a character without its own file, ZoneTimer imports that character's legacy section from `settings.xml`. Existing character files are not reimported. The shared file is preserved, and globally stored zone records are ignored. Migration cannot identify or repair values already changed by an older version.

To edit shared defaults manually, unload ZoneTimer in every running FFXI instance, edit `data/settings.xml`, and load the addon again. To edit a character file, unload the addon for that character first. Changes made to a character file while it is loaded can be overwritten by the next save. Use commands for ordinary appearance changes.

Existing standard `texts` properties remain supported, including italic, right justification, stroke color/alpha, and fallback fonts. Those advanced properties can be edited in XML. Padding belongs alongside `pos` and `text`, not inside `bg`. To resume inheritance for a preference, unload the addon and remove that preference from the character file's `<overrides>` section.

## Zone time and addon reloads

The timer uses elapsed real-world seconds and does not wrap at 24 hours. Without a valid saved record, counting starts when the addon observes the current zone; it cannot recover an earlier entry that happened while it was not running. A different zone ID or `reset` starts a new timer. Entering or leaving a Mog House with the same parent zone ID does not reset it; a separate zone ID, such as Mog Garden's, does.

A normal addon unload records a restoration timestamp in the character file. Loading again within **five minutes of that unload**, on the same character, server, and zone, resumes the previous timer. The five-minute window limits how long an unloaded timer remains eligible for restoration; it does not limit the duration of a running zone timer. Missing, mismatched, future-dated, or older records start a fresh timer. Player or zone information that arrives shortly after addon loading is checked before restoration is decided.

Logout clears the zone record, and a new login starts fresh. Unexpected termination normally leaves no eligible clean-unload marker. A new session with an addon loaded only after login can still be indistinguishable from a recent addon reload when its saved identity, zone, and timestamps match. The timestamp check is a conservative restoration rule, not a session identifier.

Appearance, visibility, fades, and reminder preferences survive these timer resets. Timer checks run once per second; hidden HUD text is not repeatedly rewritten. Frame-based updates are used only while fading.

Original plugin by Krellion. Addon by Ihina.

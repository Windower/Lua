# giltracker
This addon displays the current gil, similar to the FFXIV Gil HUD widget.

![Imgur](https://i.imgur.com/vZ8NkDr.png)

## Settings

- `thousandsSeparator`: Separator used when displaying gil. Defaults to `,`.
  Named values are `comma`, `period`, `space`, and `none`. Literal and custom
  separators such as `.`, `,`, or `○` are also supported. Custom values must
  be valid XML text.
- `refreshInterval`: Seconds between periodic gil updates. Defaults to `5`.
  Values below `1` are treated as `1`.

Custom separators must be valid XML text. XML-reserved characters must be
escaped, such as `&amp;` for `&` and `&lt;` for `<`.

## How to edit the settings
1. Login to your character in FFXI
2. Edit the addon settings file: **_Windower4\addons\giltracker\data\settings.xml_**
3. Save the file
4. Press Insert in FFXI to access the windower console
5. Type ``` lua r giltracker ``` to reload the addon
6. Press Insert in FFXI again to close the windower console

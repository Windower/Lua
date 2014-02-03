**Author:** Giuliano Riccio  
**Version:** v 1.20131102

# Timestamp #
This addon prefixes any chat message with a timestamp.
Based on Timestamp plugin.

## Commands ##
### help ###
Shows the help text

```
timestamp [<command>] help
```
* **_command_:** defines the name of the command you need help with

### format ###
Sets the timestamp's format.

```
timestamp format [help|<color>]
```
* **help:** shows the help text.
* **_format_:** defines the timestamp's format. The available constants are: **${year}**, **${y}**, **${year_short}**, **${month}**, **${m}**, **${month_short}**, **${month_long}**, **${day}**, **${d}**, **${day_short}**, **${day_long}**, **${hour}**, **${h}**, **${hour24}**, **${hour12}**, **${minute}**, **${min}**, **${second}**, **${s}**, **${sec}**, **${ampm}**, **${timezone}**, **${tz}**, **${timezone_sep}**, **${tz_sep}**, **${time}**, **${date}**, **${datetime}**, **${iso8601}**, **${rfc2822}**, **${rfc822}**, **${rfc1036}**, **${rfc1123}**, **${rfc3339}**

### color ###
Sets the timestamp's color.

```
timestamp color [help|<color>]
```
* **help:** shows the help text.
* **_color_:** defines the timestamp's color. The value must be between 0 and 511, inclusive.

----

## Changelog ##

### v1.20130616 ###
* **fix:** Fixed some indentation issues.

### v1.20130607 ###
* **fix:** Fixed custom timestamp formatting.

### v1.20130529 ###
* first release.

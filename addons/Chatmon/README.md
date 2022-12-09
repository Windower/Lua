# Chatmon
Author: Xabis / Aurum (Asura)
Version: 1.0  
Chat Monitor

Abbreviation: //cm, //chatmon

## About

This is a replacement to the official Chatmon plugin provided by the Windower team.

Functionality has been expanded and enhanced, adding additional features and compatibility with Battlemod. Care has been taken to keep the original chatmon xml configuration compatible.

Commands:
* trigger : List, Add, and Remove audio alerts
* filter : List, Add, and Remove chat filters
* setting: List, Set, and Remove configuration options
* showchannels: A toggle that will prefix incoming text with its associated channel
* showblocks: A toggle that will echo blocked text into the chat window, for debugging purposes
* test: A utility to test various pattern matching
* play: A utility to check if a sound is valid, and then plays it

## Audio Triggers:

When a pattern matches incoming text, the associated sound will play.

Sub Commands:
* list : Lists all current audio triggers
* add : Adds a new audio trigger
* remove : Removes an audio trigger by either its index or a search pattern

Audio triggers may be optionally limited to play on channels that you specify. Unlike the original chatmon plugin, you are not restricted on which channels may be filtered. While there are a few built-in named shortcuts, you may use any numerical channel id.

Named shortcuts: Say, Shout, Yell, Party, Linkshell, \*Linkshell2, Tell, Emote, Examine, \*Readies, \*Wearoff, \*Casting  
\* New with this addon.

## Chat Filters:

Chat filters allows you to block incoming chat from appearing in your chat window. This allows you to customize your online experience, such as removing unwanted rmt and merc spam. 

The original chatmon does include filter functionality, however access to its filters it not available.

Sub Commands:
* list : Lists all current chat filters
* add : Adds a new filter
* grab : Creates a new filter from the last message received by the specified player
* remove : Removes a chat filter by either its index or a search pattern

Filters support both [wc_match](https://github.com/Windower/Lua/wiki/Functions#windowerwc_matchstr-pattern) and [Regular Expressions](https://regexr.com/).

Grab is a great way to capture those sneaky messages sent by real money traders using unicode characters. Grab the full text, then you can pare it down in the config file if you like. Binary characters are represented simply by using a \xFF style escape sequence.

## Settings:

Settings provides configuration for a few built in audio alerts. If you do not want these alerts to fire, simply remove them.

Sub Commands:
* list : Lists settings
* set : Adds or updates a setting value
* remove : Removes the setting

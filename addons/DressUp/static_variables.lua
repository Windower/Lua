-- Copyright © 2013-2014, Cairthenn
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of DressUp nor the
      -- names of its contributors may be used to endorse or promote products
      -- derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL Cairthenn BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

helptext = [[DressUp - Command List:
1. help - Displays this help menu.
2a. self/others [race/face/<item slot>] [<item name>/<race name>/<face>]
2b. player <player name> [race/face/item slot] [item name/name/face]
	- Assigns models to yourself, others, or an individual player as specified.
	- Supports IDs as well as names. Specify male or female if necessary.
3. clear [self/others/player] <player name> [race/face/<item slot>]
	- Clears settings for the selection. Player name specific to player option.
4. replacements [race/face/<item slot>] <selection1> <selection2>
	- Handles 1:1 replacement, similar to .DAT swapping. 
5. blinking [self/others/party/follow/all] [always/target/combat/all] [on/off]
	- Changes blinking settings. Toggles if nothing is specified.
	- Also accepts "bmn" and "blinkmenot" as command prefix.
6. autoupdate - Updates your model as you send the commands to do so.
	- This uses outgoing packets.
 ]]

-- Initializes default settings table
defaults = {}
defaults.autoupdate = false
defaults.profiles = {}
defaults["others"] = {}
defaults.replacements = { face = {}, race = {}, head = {}, body = {}, hands = {}, legs = {}, feet = {}, main = {}, sub = {}, ranged = {} }

defaults.blinking = {}
defaults.blinking["party"] = { target = false, always = false, combat = false}
defaults.blinking["others"] = { target = false, always = false, combat = false}
defaults.blinking["all"] = { target = false, always = false, combat = false }
defaults.blinking["self"] = { target = false, always = false, combat = false }
defaults.blinking["follow"] = { target = false, always = false, combat = false }

-- Array of races and various abbreviations accepted for race strings

_races = {}
_races["hume"] = { ["m"] = 1, ["f"] = 2, ["male"] = 1, ["female"] = 2 }
_races["h"] = { ["m"] = 1, ["f"] = 2, ["male"] = 1, ["female"] = 2 }
_races["elvaan"] = { ["m"] = 3, ["f"] = 4, ["male"] = 3, ["female"] = 4  }
_races["elv"] = { ["m"] = 3, ["f"] = 4, ["male"] = 3, ["female"] = 4  }
_races["e"] = { ["m"] = 3, ["f"] = 4, ["male"] = 3, ["female"] = 4  }
_races["tarutaru"] = { ["m"] = 5, ["f"] = 6, ["male"] = 5, ["female"] = 6 }
_races["taru"] = { ["m"] = 5, ["f"] = 6, ["male"] = 5, ["female"] = 6 }
_races["t"] = { ["m"] = 5, ["f"] = 6, ["male"] = 5, ["female"] = 6 }
_races["mithra"] = 7
_races["m"] = 7
_races["galka"] = 8
_races["g"] = 8

-- Maps commonly known face IDs to their actual IDs

_faces = {}
_faces["1a"] = 1
_faces["1b"] = 2
_faces["2a"] = 3
_faces["2b"] = 4
_faces["3a"] = 5
_faces["3b"] = 6
_faces["4a"] = 7
_faces["4b"] = 8
_faces["5a"] = 9
_faces["5b"] = 10
_faces["6a"] = 11
_faces["6b"] = 12
_faces["7a"] = 13
_faces["7b"] = 14
_faces["8a"] = 15
_faces["8b"] = 16
_faces["Fomor"] = 29
_faces["Mannequin"] = 30

-- PC Update Masks associated with model changes

model_mask = L{16,17,20,21}

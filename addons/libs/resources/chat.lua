-- Chat modes
local chat = {}

chat[0]  = {english = 'say',       colors = {incoming = 9,     outgoing = 1}}
chat[1]  = {english = 'shout',     colors = {incoming = 10,    outgoing = 2}}
chat[3]  = {english = 'tell',      colors = {incoming = 12,    outgoing = 4}}
chat[4]  = {english = 'party',     colors = {incoming = 13,    outgoing = 5}}
chat[5]  = {english = 'linkshell', colors = {incoming = 14,    outgoing = 6}}
chat[8]  = {english = 'emote',     colors = {incoming = 15,    outgoing = 7}}
chat[26] = {english = 'yell',      colors = {incoming = 11,    outgoing = 3}}

-- For Packet 0x17 (Incoming Chat):
-- 0 = Say
-- 1 = Shout
-- 2 = Nothing
-- 3 = Tell
-- 4 = Party
-- 5 = Linkshell
-- 6 = SystemMessage
-- 7 = SystemMessage
-- 8 = Emote
-- 9 = Nothing
-- 10 = Nothing
-- 11 = Nothing
-- 12 = GMTell
-- 13 = No sender say
-- 14 = No sender shout
-- 15 = No sender party
-- 16 = No sender linkshell
-- 17~24 = yellow text, like a bazaar check message
-- 25 = Say?
-- 26 = Yell
-- >26 = Nothing

return chat

--[[
Copyright (c) 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

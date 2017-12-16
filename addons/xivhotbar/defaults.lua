--[[
        Copyright © 2017, SirEdeonX
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of xivhotbar nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL SirEdeonX BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local defaults = {}

defaults.Hotbar = {}
--defaults.Hotbar.Number = 3
defaults.Hotbar.HideEmptySlots = false
defaults.Hotbar.HideActionName = false
defaults.Hotbar.HideActionCost = false
defaults.Hotbar.HideActionElement = true
defaults.Hotbar.HideRecastAnimation = false
defaults.Hotbar.HideRecastText = false
defaults.Hotbar.HideBattleNotice = false

defaults.Controls = {}
defaults.Controls.ToggleBattleMode = 43

defaults.Theme = {}
defaults.Theme.BattleNotice = 'ffxiv'
defaults.Theme.Slot = 'ffxiv'
defaults.Theme.Frame = 'ffxiv'

defaults.Style = {}
defaults.Style.SlotAlpha = 100
defaults.Style.SlotSpacing = 6
defaults.Style.HotbarSpacing = 56
defaults.Style.OffsetX = 0
defaults.Style.OffsetY = 0

defaults.Color = {}
defaults.Color.MpCost = {}
defaults.Color.MpCost.Red = 230
defaults.Color.MpCost.Green = 91
defaults.Color.MpCost.Blue = 151
defaults.Color.TpCost = {}
defaults.Color.TpCost.Red = 254
defaults.Color.TpCost.Green = 222
defaults.Color.TpCost.Blue = 0
defaults.Color.Feedback = {}
defaults.Color.Feedback.Opacity = 150
defaults.Color.Feedback.Speed = 30
defaults.Color.Disabled = {}
defaults.Color.Disabled.Opacity = 100

defaults.Texts = {}
defaults.Texts.Font = 'sans-serif'
defaults.Texts.Size = 7
defaults.Texts.OffsetX = 0
defaults.Texts.OffsetY = 0
defaults.Texts.Color = {}
defaults.Texts.Color.Alpha = 255
defaults.Texts.Color.Red = 255
defaults.Texts.Color.Green = 255
defaults.Texts.Color.Blue = 255
defaults.Texts.Stroke = {}
defaults.Texts.Stroke.Width = 2
defaults.Texts.Stroke.Alpha = 200
defaults.Texts.Stroke.Red = 20
defaults.Texts.Stroke.Green = 20
defaults.Texts.Stroke.Blue = 20

return defaults
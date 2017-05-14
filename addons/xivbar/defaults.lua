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
            * Neither the name of xivbar nor the
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

defaults.Bars = {}
defaults.Bars.OffsetX = 0
defaults.Bars.OffsetY = 0

defaults.Theme = {}
defaults.Theme.Name = 'ffxiv'
defaults.Theme.Compact = false
defaults.Theme.Bar = {}
defaults.Theme.Bar.Width = 132
defaults.Theme.Bar.Spacing = 18
defaults.Theme.Bar.Offset = 0
defaults.Theme.Bar.Compact = {}
defaults.Theme.Bar.Compact.Width = 116
defaults.Theme.Bar.Compact.Spacing = 16
defaults.Theme.Bar.Compact.Offset = 0
defaults.Theme.DimTpBar = true

defaults.Texts = {}
defaults.Texts.Font = 'sans-serif'
defaults.Texts.Size = 14
defaults.Texts.Offset = 0
defaults.Texts.Color = {}
defaults.Texts.Color.Alpha = 255
defaults.Texts.Color.Red = 253
defaults.Texts.Color.Green = 252
defaults.Texts.Color.Blue = 250
defaults.Texts.Stroke = {}
defaults.Texts.Stroke.Width = 2
defaults.Texts.Stroke.Alpha = 200
defaults.Texts.Stroke.Red = 50
defaults.Texts.Stroke.Green = 50
defaults.Texts.Stroke.Blue = 50
defaults.Texts.FullTpColor = {}
defaults.Texts.FullTpColor.Red = 80
defaults.Texts.FullTpColor.Green = 180
defaults.Texts.FullTpColor.Blue = 250

return defaults
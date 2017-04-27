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

defaults = {}

defaults.Bars = {}
defaults.Bars.Style = 'ffxiv'
defaults.Bars.Compact = false
defaults.Bars.OffsetX = 0
defaults.Bars.OffsetY = 0

defaults.Images = {}
defaults.Images.FFXIV = {}
defaults.Images.FFXIV.Background = windower.addon_path..'resources/ffxiv_bar_bg.png'
defaults.Images.FFXIV.BackgroundCompact = windower.addon_path..'resources/ffxiv_bar_compact.png'
defaults.Images.FFXIV.Hp = windower.addon_path..'resources/ffxiv_hp_fg.png'
defaults.Images.FFXIV.Mp = windower.addon_path..'resources/ffxiv_mp_fg.png'
defaults.Images.FFXIV.Tp = windower.addon_path..'resources/ffxiv_tp_fg.png'
defaults.Images.FFXI = {}
defaults.Images.FFXI.Background = windower.addon_path..'resources/ffxi_bar_bg.png'
defaults.Images.FFXI.BackgroundCompact = windower.addon_path..'resources/ffxi_bar_compact.png'
defaults.Images.FFXI.Hp = windower.addon_path..'resources/ffxi_hp_fg.png'
defaults.Images.FFXI.Mp = windower.addon_path..'resources/ffxi_mp_fg.png'
defaults.Images.FFXI.Tp = windower.addon_path..'resources/ffxi_tp_fg.png'

defaults.Texts = {}
defaults.Texts.FFXIV = {}
defaults.Texts.FFXIV.Size = 16
defaults.Texts.FFXIV.Font = 'sans-serif'
defaults.Texts.FFXIV.Alpha = 255
defaults.Texts.FFXIV.Red = 253
defaults.Texts.FFXIV.Green = 252
defaults.Texts.FFXIV.Blue = 250
defaults.Texts.FFXIV.Stroke = {}
defaults.Texts.FFXIV.Stroke.Width = 2
defaults.Texts.FFXIV.Stroke.Alpha = 150
defaults.Texts.FFXIV.Stroke.Red = 83
defaults.Texts.FFXIV.Stroke.Green = 78
defaults.Texts.FFXIV.Stroke.Blue = 36
defaults.Texts.FFXI = {}
defaults.Texts.FFXI.Size = 14
defaults.Texts.FFXI.Font = 'sans-serif'
defaults.Texts.FFXI.Alpha = 255
defaults.Texts.FFXI.Red = 253
defaults.Texts.FFXI.Green = 252
defaults.Texts.FFXI.Blue = 250
defaults.Texts.FFXI.Stroke = {}
defaults.Texts.FFXI.Stroke.Width = 2
defaults.Texts.FFXI.Stroke.Alpha = 200
defaults.Texts.FFXI.Stroke.Red = 50
defaults.Texts.FFXI.Stroke.Green = 50
defaults.Texts.FFXI.Stroke.Blue = 50
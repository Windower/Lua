--[[
Copyright © 2018, Sjshovan (Apogee)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of MountMuzzle nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Patrick Finnigan BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

packets = {
    inbound = {
        music_change = {
            id = 0x05F
        }
    },
    outbound = {
        action = {
            id = 0x1A,
            categories = {
                mount = 0x1A,
                unmount = 0x12
            },
            params = {
                mount = 0x04,
                unmount = 0x00
            }
        }
    },
}

player = {
	statuses = {
		mounted = 85
	}
}

music = {
    songs = {
        silent = 90,
        normal = 84,
        choco = 212,
        zone = 0,
    },
    types = {
        mount = 4
    }
}

colors = {
    primary = 200,
    secondary = 207,
    info = 0,
    warn = 140,
    danger = 167,
    success = 158
}

muzzles = {
    silent = {
        name = 'silent',
        song = music.songs.silent,
        description = ''
    },
    normal = {
        name = 'normal',
        song = music.songs.normal,
        description = ''
    },
    choco = {
        name = 'choco',
        song = music.songs.choco,
        description = ''
    },
    zone = {
        name = 'zone',
        song = music.songs.zone,
        description = ''
    }
}
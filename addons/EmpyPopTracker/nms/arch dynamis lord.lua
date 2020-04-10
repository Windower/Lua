--[[
Copyright © 2020, Dean James (Xurion of Bismarck)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of Empy Pop Tracker nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Dean James (Xurion of Bismarck) BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

return {
    name = 'Arch Dynamis Lord',
    pops = { {
        id = 3429, --Fiendish Tome (26)
        type = 'item',
        dropped_from = {
            name = 'Dynamis Lord, Forced (E-8)',
            pops = { {
                id = 3358, --Shrouded Bijou
                type = 'item',
                dropped_from = { name = 'Various Demon lottery NMs' }
            } }
        }
    }, {
        id = 3430, --Fiendish Tome (27)
        type = 'item',
        dropped_from = {
            name = 'Duke Haures, Forced (J-7)',
            pops = { {
                id = 3400, --Odious Skull
                type = 'item',
                dropped_from = { name = 'Kindred DRK, RDM & SAM' }
            } }
        }
    }, {
        id = 3431, --Fiendish Tome (28)
        type = 'item',
        dropped_from = {
            name = 'Marquis Caim, Forced (J-6)',
            pops = { {
                id = 3401, --Odious Horn
                type = 'item',
                dropped_from = { name = 'Kindred BRD, NIN, SMN & WAR' }
            } }
        }
    }, {
        id = 3432, --Fiendish Tome (29)
        type = 'item',
        dropped_from = {
            name = 'Baron Avnas, Forced (I-5)',
            pops = { {
                id = 3402, --Odious Blood
                type = 'item',
                dropped_from = { name = 'Kindred DRG, MNK, THF & WHM' }
            } }
        }
    }, {
        id = 3433, --Fiendish Tome (30)
        type = 'item',
        dropped_from = {
            name = 'Count Haagenti, Forced (F-7)',
            pops = { {
                id = 3403, --Odious Pen
                type = 'item',
                dropped_from = { name = 'Kindred BLM, BST, PLD & RNG' }
            } }
        }
    } }
}

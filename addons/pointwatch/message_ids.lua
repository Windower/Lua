--Copyright (c) 2014, Byrthnoth
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-- Offset messages:
-- Abyssea's offset message is the one that reports your Pearlescent, Ebon, Gold, and Silvery light when you /heal.
--     Do a Control-F for Pearlescent to find it if using the POLUtils method. It should be the first result.

-- SEE THE "FIXING POINTWATCH" FILE IN THIS FOLDER FOR INSTRUCTIONS ON HOW TO FIX POINTWATCH.

local messages = {
    z15  = {
        name = 'Abyssea - Konschtat',
        offset = 7312,
        pearl_ebon_gold_silvery = 0,
        azure_ruby_amber = 1,
        visitant_status_update = 9,
        visitant_status_wears_off = 10,
        visitant_status_extend = 12,
        visitant_status_gain = 45,
        pearlescent_light = 183,
        golden_light = 184,
        silvery_light = 185,
        ebon_light = 186,
        azure_light = 187,
        ruby_light = 188,
        amber_light = 189,
    },
    z132 = {
        name = 'Abyssea - La Theine',
        offset = 7312,
        pearl_ebon_gold_silvery = 0,
        azure_ruby_amber = 1,
        visitant_status_update = 9,
        visitant_status_wears_off = 10,
        visitant_status_extend = 12,
        visitant_status_gain = 45,
        pearlescent_light = 183,
        golden_light = 184,
        silvery_light = 185,
        ebon_light = 186,
        azure_light = 187,
        ruby_light = 188,
        amber_light = 189,
    },
    z45  = {
        name = 'Abyssea - Tahrongi',
        offset = 7312,
        pearl_ebon_gold_silvery = 0,
        azure_ruby_amber = 1,
        visitant_status_update = 9,
        visitant_status_wears_off = 10,
        visitant_status_extend = 12,
        visitant_status_gain = 45,
        pearlescent_light = 183,
        golden_light = 184,
        silvery_light = 185,
        ebon_light = 186,
        azure_light = 187,
        ruby_light = 188,
        amber_light = 189,
    },
    z215 = {
        name = 'Abyssea - Attohwa',
        offset = 7212,
        pearl_ebon_gold_silvery = 0,
        azure_ruby_amber = 1,
        visitant_status_update = 9,
        visitant_status_wears_off = 10, -- Could also be 7194, the singular message. That is less than 10 minutes though, so shouldn't need to update for it.
        visitant_status_extend = 12,
        visitant_status_gain = 45, -- Could also be 7228 or 7229
        pearlescent_light = 183,
        golden_light = 184,
        silvery_light = 185,
        ebon_light = 186,
        azure_light = 187,
        ruby_light = 188,
        amber_light = 189,
    },
    z216 = {
        name = 'Abyssea - Misareaux',
        offset = 7312,
        pearl_ebon_gold_silvery = 0,
        azure_ruby_amber = 1,
        visitant_status_update = 9,
        visitant_status_wears_off = 10,
        visitant_status_extend = 12,
        visitant_status_gain = 45,
        pearlescent_light = 183,
        golden_light = 184,
        silvery_light = 185,
        ebon_light = 186,
        azure_light = 187,
        ruby_light = 188,
        amber_light = 189,
    },
    z217 = {
        name = 'Abyssea - Vunkerl',
        offset = 7312,
        pearl_ebon_gold_silvery = 0,
        azure_ruby_amber = 1,
        visitant_status_update = 9,
        visitant_status_wears_off = 10,
        visitant_status_extend = 12,
        visitant_status_gain = 45,
        pearlescent_light = 183,
        golden_light = 184,
        silvery_light = 185,
        ebon_light = 186,
        azure_light = 187,
        ruby_light = 188,
        amber_light = 189,
    },
    z218 = {
        name = 'Abyssea - Altepa',
        offset = 7312,
        pearl_ebon_gold_silvery = 0,
        azure_ruby_amber = 1,
        visitant_status_update = 9,
        visitant_status_wears_off = 10,
        visitant_status_extend = 12,
        visitant_status_gain = 45,
        pearlescent_light = 183,
        golden_light = 184,
        silvery_light = 185,
        ebon_light = 186,
        azure_light = 187,
        ruby_light = 188,
        amber_light = 189,
    },
    z254 = {
        name = 'Abyssea - Grauberg',
        offset = 7312,
        pearl_ebon_gold_silvery = 0,
        azure_ruby_amber = 1,
        visitant_status_update = 9,
        visitant_status_wears_off = 10,
        visitant_status_extend = 12,
        visitant_status_gain = 45,
        pearlescent_light = 183,
        golden_light = 184,
        silvery_light = 185,
        ebon_light = 186,
        azure_light = 187,
        ruby_light = 188,
        amber_light = 189,
    },
    z253 = {
        name = 'Abyssea - Uleguerand',
        offset = 7212,
        pearl_ebon_gold_silvery = 0,
        azure_ruby_amber = 1,
        visitant_status_update = 9,
        visitant_status_wears_off = 10,
        visitant_status_extend = 12,
        visitant_status_gain = 45,
        pearlescent_light = 183,
        golden_light = 184,
        silvery_light = 185,
        ebon_light = 186,
        azure_light = 187,
        ruby_light = 188,
        amber_light = 189,
    },
}

return messages

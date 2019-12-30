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
    * Neither the name of Battle Stations nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sjshovan (Apogee) BE LIABLE FOR ANY
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
        },
        zone_update = {
            id = 0x00A
        }
    },
    outbound = {
        action = {
            id = 0x1A,
            categories = {
                engage = 2,
                disengage = 4
                
             },
        }
    },
}

player = {
	statuses = {
        idle = 0x00,
        fighting = 0x01,
	},
    buffs = {
        reiveMark = 511
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

music = {
    songs = {
        final_fantasy_xi = {
            battle_theme = 101,
            battle_theme_2 = 103,
            battle_in_the_dungeon = 115,
            battle_in_the_dungeon_2 = 102,
            tough_battle = 125,            
            awakening = 119
        },
        rise_of_the_zilart = {
            battle_theme_3 = 191,
            battle_in_the_dungeon_3 = 192,
            tough_battle_2 = 193,
            fighters_of_the_crystal = 196,
            ealdnarche = 198,
            belief = 195
        },
        chains_of_promathia = {
            onslaught = 219,
            depths_of_the_soul = 218,
            turmoil = 220,
            ruler_of_the_skies = 232,
            dusk_and_dawn = 224,
            a_realm_of_emptiness = 137    
        },
        treasures_of_aht_urhgan = {
            mercenaries_delight = 138,
            delve = 139,
            rapid_onslaught_assault = 144,
            fated_strife_besieged = 142,
            hellriders = 143,
            black_coffin = 172,
            iron_colossus = 186,
            ragnarok = 187
        },
        wings_of_the_goddess = {
            clash_of_standards = 215,
            on_this_blade = 216,
            roar_of_the_battle_drums = 247,
            run_maggot_run = 249,
            under_a_clouded_moon = 250,
            kindred_cry = 217,
            provenance_watcher = 55,
            goddess_divine = 46
        },
        seekers_of_adoulin = {
            steel_sings_blades_dance = 57,
            breaking_ground = 64,
            buccaneers = 170,
            keepers_of_the_wild = 62
        },
        add_ons = {
            echoes_of_creation = 47,
            luck_of_the_mog = 49,
            a_feast_for_ladies = 50,
            melodies_errant = 52,
            shinryu = 53,
            wail_of_the_void = 82
        },
        others = {
            silent = 9999,
            normal = 09,
            zone = 00
        },
    },
    types = {
        battle_solo = 2,
        battle_party = 3,
        idle_day = 0,
        idle_night = 1
    }
}

stations = {
    receivers = T{
        solo = 'solo',
        party = 'party'
    },

    categories = T{
        ['100'] = 'Final Fantasy XI',
        ['101'] = 'Rise of the Zilart',
        ['102'] = 'Chains of Promathia',
        ['103'] = 'Treasures of Aht Urhgan',
        ['104'] = 'Wings of the Goddess',
        ['105'] = 'Seekers of Adoulin',
        ['106'] = 'Add-Ons',
        ['107'] = 'Others'
    },
   
    frequencies = T{
    
        --(100) Final Fantasy XI --
        
        ['100.1'] = {
            callSign = 'Battle Theme',
            song = music.songs.final_fantasy_xi.battle_theme
        },
        ['100.2'] = {
            callSign = 'Battle Theme 2',
            song = music.songs.final_fantasy_xi.battle_theme_2
        },
        ['100.3'] = {
            callSign = 'Battle in the Dungeon',
            song = music.songs.final_fantasy_xi.battle_in_the_dungeon
        },
        ['100.4'] = {
            callSign = 'Battle in the Dungeon 2',
            song = music.songs.final_fantasy_xi.battle_in_the_dungeon_2
        },
        ['100.5'] = {
            callSign = 'Tough Battle',
            song = music.songs.final_fantasy_xi.tough_battle
        },
        ['100.6'] = {
            callSign = 'Awakening',
            song = music.songs.final_fantasy_xi.awakening
        },
        
        --(101) Rise of the Zilart --
      
        ['101.1'] = {
            callSign = 'Battle Theme 3',
            song = music.songs.rise_of_the_zilart.battle_theme_3
        },
        ['101.2'] = {
            callSign = 'Battle in the Dungeon 3',
            song = music.songs.rise_of_the_zilart.battle_in_the_dungeon_3
        },
        ['101.3'] = {
            callSign = 'Tough Battle 2',
            song = music.songs.rise_of_the_zilart.tough_battle_2
        },
        ['101.4'] = {
            callSign = 'Fighters of the Crystal',
            song = music.songs.rise_of_the_zilart.fighters_of_the_crystal
        },
        ['101.5'] = {
            callSign = "Eald'narche",
            song = music.songs.rise_of_the_zilart.ealdnarche
        },
        ['101.6'] = {
            callSign = 'Belief',
            song = music.songs.rise_of_the_zilart.belief
        },
        
        --(102) Chains of Promathia --

        ['102.1'] = {
            callSign = 'Onslaught',
            song = music.songs.chains_of_promathia.onslaught
        },
        ['102.2'] = {
            callSign = 'Depths of the Soul',
            song = music.songs.chains_of_promathia.depths_of_the_soul
        },
        ['102.3'] = {
            callSign = 'Turmoil',
            song = music.songs.chains_of_promathia.turmoil
        },
        ['102.4'] = {
            callSign = 'Ruler of the Skies',
            song = music.songs.chains_of_promathia.ruler_of_the_skies
        },
        ['102.5'] = {
            callSign = 'Dusk and Dawn',
            song = music.songs.chains_of_promathia.dusk_and_dawn
        },
        ['102.6'] = {
            callSign = 'A Realm of Emptiness',
            song = music.songs.chains_of_promathia.a_realm_of_emptiness
        },
        
        --(103) Treasures of Aht Urhgan --
        
        ['103.1'] = {
            callSign = "Mercenaries' Delight",
            song = music.songs.treasures_of_aht_urhgan.mercenaries_delight
        },
        ['103.2'] = {
            callSign = 'Delve',
            song = music.songs.treasures_of_aht_urhgan.delve
        },
        ['103.3'] = {
            callSign = 'Rapid Onslaught -Assult-',
            song = music.songs.treasures_of_aht_urhgan.rapid_onslaught_assault
        },
        ['103.4'] = {
            callSign = 'Fated Strife -Besieged-',
            song = music.songs.treasures_of_aht_urhgan.fated_strife_besieged
        },
        ['103.5'] = {
            callSign = 'Hellriders',
            song = music.songs.treasures_of_aht_urhgan.hellriders
        },
        ['103.6'] = {
            callSign = 'Black Coffin',
            song = music.songs.treasures_of_aht_urhgan.black_coffin
        },
        ['103.7'] = {
            callSign = 'Iron Colossus',
            song = music.songs.treasures_of_aht_urhgan.iron_colossus
        },
        ['103.8'] = {
            callSign = 'Ragnarok',
            song = music.songs.treasures_of_aht_urhgan.ragnarok
        },
        
        --(104) Wings of the Goddess --
        
        ['104.1'] = {
            callSign = 'Clash of Standards',
            song = music.songs.wings_of_the_goddess.clash_of_standards
        },
        ['104.2'] = {
            callSign = 'On this Blade',
            song = music.songs.wings_of_the_goddess.on_this_blade
        },
        ['104.3'] = {
            callSign = 'Roar of the Battle Drums',
            song = music.songs.wings_of_the_goddess.roar_of_the_battle_drums
        },
        ['104.4'] = {
            callSign = 'Run Maggot, Run!',
            song = music.songs.wings_of_the_goddess.run_maggot_run
        },
        ['104.5'] = {
            callSign = 'Under a Clouded Moon',
            song = music.songs.wings_of_the_goddess.under_a_clouded_moon
        },
        ['104.6'] = {
            callSign = 'Kindred Cry',
            song = music.songs.wings_of_the_goddess.kindred_cry
        },
        ['104.7'] = {
            callSign = 'Provenance Watcher',
            song = music.songs.wings_of_the_goddess.provenance_watcher
        },
        ['104.8'] = {
            callSign = 'Goddess Divine',
            song = music.songs.wings_of_the_goddess.goddess_divine
        },
      
        --(105) Seekers of Adoulin --
        
        ['105.1'] = {
            callSign = 'Steel Sings, Blades Dance',
            song = music.songs.seekers_of_adoulin.steel_sings_blades_dance
        },
        ['105.2'] = {
            callSign = 'Braking Ground',
            song = music.songs.seekers_of_adoulin.breaking_ground
        },
        ['105.3'] = {
            callSign = 'Buccaneers',
            song = music.songs.seekers_of_adoulin.buccaneers
        },
        ['105.4'] = {
            callSign = 'Keepers of the Wild',
            song = music.songs.seekers_of_adoulin.keepers_of_the_wild
        },
    
        --(106) Add-Ons --
        
        ['106.1'] = {
            callSign = 'Echoes of Creation',
            song = music.songs.add_ons.echoes_of_creation
        },
        ['106.2'] = {
            callSign = 'Luck of the Mog',
            song = music.songs.add_ons.luck_of_the_mog
        },
        ['106.3'] = {
            callSign = 'A Feast for Ladies',
            song = music.songs.add_ons.a_feast_for_ladies
        },
        ['106.4'] = {
            callSign = 'Melodies Errant',
            song = music.songs.add_ons.melodies_errant
        },
        ['106.5'] = {
            callSign = 'Shinryu',
            song = music.songs.add_ons.shinryu
        },
        ['106.6'] = {
            callSign = 'Wail of the Void',
            song = music.songs.add_ons.wail_of_the_void
        },
        
        --(107) Others --
        
        ['107.1'] = {
            callSign = 'No Music',
            song = music.songs.others.silent
        },
        ['107.2'] = {
            callSign = 'Original Music',
            song = music.songs.others.normal
        },
        ['107.3'] = {
            callSign = 'Current Zone Music (Default)',
            song = music.songs.others.zone
        }
    }
}

return {
    packets = packets,
    player = player,
    colors = colors,
    music = music, 
    stations = stations    
}
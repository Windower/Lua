-- Copyright © 2014-2015, Cairthenn
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of InfoReplacer nor the
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

require('tables')
local res = require('resources')

return T{

    name            = function() return windower.ffxi.get_player().name end,
    linkshell       = function() return windower.ffxi.get_player().linkshell end,
    linkshell_rank  = function() return windower.ffxi.get_player().linkshell_rank end,
    linkshell_slot  = function() return windower.ffxi.get_player().linkshell_slot end,
    main_job        = function() return res.jobs[windower.ffxi.get_player().main_job].short end,
    main_job_level  = function() return windower.ffxi.get_player().main_job_level end,
    main_job_full   = function() return res.jobs[windower.ffxi.get_player().main_job].english end,
    main_job_id     = function() return windower.ffxi.get_player().main_job_id end,
    status          = function() return res.statuses[windower.ffxi.get_player().status].english end,
    status_id       = function() return windower.ffxi.get_player().status end,
    index           = function() return windower.ffxi.get_player().index end,
    sub_job         = function() return res.jobs[windower.ffxi.get_player().sub_job].short end,
    sub_job_level   = function() return windower.ffxi.get_player().sub_job_level end,
    sub_job_full    = function() return res.jobs[windower.ffxi.get_player().sub_job].english end,
    sub_job_id      = function() return windower.ffxi.get_player().sub_job_id end,
    target_index    = function() return windower.ffxi.get_player().target_index end,
    target_locked   = function() return windower.ffxi.get_player().target_locked and "True" or "False" end,
    autorun         = function() return windower.ffxi.get_player().autorun and "True" or "False" end,
    follow_index    = function() return windower.ffxi.get_player().follow_index end,
    in_combat       = function() return windower.ffxi.get_player().in_combat and "True" or "False" end,
    id              = function() return windower.ffxi.get_mob_by_target('me').id end,


    hp      = function() return windower.ffxi.get_player().vitals.hp end,
    max_hp  = function() return windower.ffxi.get_player().vitals.max_hp end,
    hpp     = function() return windower.ffxi.get_player().vitals.hpp end,
    mp      = function() return windower.ffxi.get_player().vitals.mp end,
    max_mp  = function() return windower.ffxi.get_player().vitals.max_mp end,
    mpp     = function() return windower.ffxi.get_player().vitals.mpp end,
    tp      = function() return windower.ffxi.get_player().vitals.tp end,


    hand_to_hand        = function() return windower.ffxi.get_player().skills.hand_to_hand end,
    dagger              = function() return windower.ffxi.get_player().skills.dagger end,
    sword               = function() return windower.ffxi.get_player().skills.sword end,
    great_sword         = function() return windower.ffxi.get_player().skills.great_sword end,
    axe                 = function() return windower.ffxi.get_player().skills.axe end,
    great_axe           = function() return windower.ffxi.get_player().skills.great_axe end,
    scythe              = function() return windower.ffxi.get_player().skills.scythe end,
    polearm             = function() return windower.ffxi.get_player().skills.polearm  end,
    katana              = function() return windower.ffxi.get_player().skills.katana end,
    great_katana        = function() return windower.ffxi.get_player().skills.great_katana end,
    club                = function() return windower.ffxi.get_player().skills.club end,
    staff               = function() return windower.ffxi.get_player().skills.staff end,
    archery             = function() return windower.ffxi.get_player().skills.archery end,
    marksmanship        = function() return windower.ffxi.get_player().skills.marksmanship end,
    throwing            = function() return windower.ffxi.get_player().skills.throwing end,
    guarding            = function() return windower.ffxi.get_player().skills.guarding end,
    evasion             = function() return windower.ffxi.get_player().skills.evasion end,
    shield              = function() return windower.ffxi.get_player().skills.shield end,
    parrying            = function() return windower.ffxi.get_player().skills.parrying end,
    divine_magic        = function() return windower.ffxi.get_player().skills.divine_magic end,
    healing_magic       = function() return windower.ffxi.get_player().skills.healing_magic end,
    enhancing_magic     = function() return windower.ffxi.get_player().skills.enhancing_magic end,
    enfeebling_magic    = function() return windower.ffxi.get_player().skills.enfeebling_magic end,
    elemental_magic     = function() return windower.ffxi.get_player().skills.elemental_magic end,
    dark_magic          = function() return windower.ffxi.get_player().skills.dark_magic end,
    summoning_magic     = function() return windower.ffxi.get_player().skills.summoning_magic end,
    ninjitsu            = function() return windower.ffxi.get_player().skills.ninjitsu end,
    singing             = function() return windower.ffxi.get_player().skills.singing end,
    stringed_instrument = function() return windower.ffxi.get_player().skills.string end,
    wind_instrument     = function() return windower.ffxi.get_player().skills.wind end,
    blue_magic          = function() return windower.ffxi.get_player().skills.blue_magic end,
    alchemy             = function() return windower.ffxi.get_player().skills.alchemy end,
    bonecraft           = function() return windower.ffxi.get_player().skills.bonecraft end,
    clothcraft          = function() return windower.ffxi.get_player().skills.clothcraft end,
    cooking             = function() return windower.ffxi.get_player().skills.cooking end,
    fishing             = function() return windower.ffxi.get_player().skills.fishing end,
    goldsmithing        = function() return windower.ffxi.get_player().skills.goldsmithing end,
    leathercraft        = function() return windower.ffxi.get_player().skills.leathercraft end,
    smithing            = function() return windower.ffxi.get_player().skills.smithing end,
    woodworking         = function() return windower.ffxi.get_player().skills.woodworking end,
    synergy             = function() return windower.ffxi.get_player().skills.synergy end,


    camera_x        = function() return windower.ffxi.get_camera().camera_x end,
    camera_y        = function() return windower.ffxi.get_camera().camera_y end,
    camera_z        = function() return windower.ffxi.get_camera().camera_z end,


    windower_x          = function() return windower.get_windower_settings().windower_x end,
    windower_y          = function() return windower.get_windower_settings().windower_y end,
    windower_x_pos      = function() return windower.get_windower_settings().windower_x_pos end,
    windower_y_pos      = function() return windower.get_windower_settings().windower_y_pos end,
    ui_x                = function() return windower.get_windower_settings().ui_x end,
    ui_y                = function() return windower.get_windower_settings().ui_y end,
    launcher_version    = function() return windower.get_windower_settings().launcher_version end,
                             

    day             = function() return res.days[windower.ffxi.get_info().day].english end,
    day_element     = function() return res.elements[res.days[windower.ffxi.get_info().day].element].english end,
    moon            = function() return res.moon_phases[windower.ffxi.get_info().moon_phase].english end,
    moon_pct        = function() return windower.ffxi.get_info().moon end,
    time            = function() time = windower.ffxi.get_info().time return (time / 60):floor() .. ':' .. (time % 60) end,
    zone            = function() return res.zones[windower.ffxi.get_info().zone].english end,
    zone_id         = function() return windower.ffxi.get_info().zone end,
    logged_in       = function() return windower.ffxi.get_info().logged_in end,
    weather         = function() return res.weather[windower.ffxi.get_info().weather].english end,
    weather_id      = function() return windower.ffxi.get_info().weather end,
    weather_element = function() return res.elements[res.weathers[windower.ffxi.get_info().weather].element].english end,
    language        = function() return windower.ffxi.get_info().language end,
                            

    target_name             = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').name end,
    target_claim_id         = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').claim_id end,
    target_distance         = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').distance end,
    target_facing           = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').facing end,
    target_hpp              = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').hpp end,
    target_id               = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').id end,
    target_is_npc           = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').is_npc  and "True" or "False" end,
    target_mob_type         = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').mob_type end,
    target_model_size       = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t')._model_size end,
    target_speed            = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').speed end,
    target_speed_base       = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').speed_base end,
    target_status           = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').status end,
    target_index            = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').index end,
    target_x                = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').x end,
    target_y                = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').y end,
    target_z                = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').z end,
    target_pet_index        = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').pet_index end,
    target_mpp              = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').mpp end,
    target_fellow_index     = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').fellow_index end,
    target_race             = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').race end,
    target_tp               = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').tp end,
    target_charmed          = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').charmed and "True" or "False" end,
    target_in_party         = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').in_party and "True" or "False" end,
    target_in_alliance      = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').in_alliance and "True" or "False" end,
    target_is_valid         = function() return windower.ffxi.get_mob_by_target('t') and windower.ffxi.get_mob_by_target('t').is_valid and "True" or "False" end,

    pet_name           = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').name end,
    pet_claim_id       = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').claim_id end,
    pet_distance       = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').distance end,
    pet_facing         = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').facing end,
    pet_hpp            = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').hpp end,
    pet_id             = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').id end,
    pet_is_npc         = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').is_npc end,
    pet_mob_type       = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').mob_type end,
    pet_model_size     = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').model_size end,
    pet_speed          = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').speed end,
    pet_speed_base     = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').speed_base end,
    pet_status         = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').status end,
    pet_index          = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').index end,
    pet_x              = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').x end,
    pet_y              = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').y end,
    pet_z              = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').z end,
    pet_race           = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').race end,
    pet_tp             = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').tp end,
    pet_charmed        = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').charmed and "True" or "False" end,
    pet_in_party       = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').in_party  and "True" or "False" end,
    pet_in_alliance    = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').in_alliance and "True" or "False" end,
    pet_is_valid       = function() return windower.ffxi.get_mob_by_target('pet') and windower.ffxi.get_mob_by_target('pet').is_valid  and "True" or "False" end,
                            

    gil         = function() return windower.ffxi.get_items().gil end,

    ammo        = function() return windower.ffxi.get_items().equipment.ammo > 0 and res.items[windower.ffxi.get_items().inventory[windower.ffxi.get_items().equipment.ammo].id].english end,
    back        = function() return windower.ffxi.get_items().equipment.back > 0 and res.items[windower.ffxi.get_items().inventory[windower.ffxi.get_items().equipment.back].id].english end,
    body        = function() return windower.ffxi.get_items().equipment.body > 0 and res.items[windower.ffxi.get_items().inventory[windower.ffxi.get_items().equipment.body].id].english end,
    feet        = function() return windower.ffxi.get_items().equipment.feet > 0 and res.items[windower.ffxi.get_items().inventory[windower.ffxi.get_items().equipment.feet].id].english end,
    hands       = function() return windower.ffxi.get_items().equipment.hands > 0 and res.items[windower.ffxi.get_items().inventory[windower.ffxi.get_items().equipment.hands].id].english end,
    head        = function() return windower.ffxi.get_items().equipment.head > 0 and res.items[windower.ffxi.get_items().inventory[windower.ffxi.get_items().equipment.head].id].english end,
    left_ear    = function() return windower.ffxi.get_items().equipment.left_ear > 0 and res.items[windower.ffxi.get_items().inventory[windower.ffxi.get_items().equipment.left_ear].id].english end,
    legs        = function() return windower.ffxi.get_items().equipment.legs > 0 and res.items[windower.ffxi.get_items().inventory[windower.ffxi.get_items().equipment.legs].id].english end,
    left_ring   = function() return windower.ffxi.get_items().equipment.left_ring > 0 and res.items[windower.ffxi.get_items().inventory[windower.ffxi.get_items().equipment.left_ring].id].english end,
    main        = function() return windower.ffxi.get_items().equipment.main > 0 and res.items[windower.ffxi.get_items().inventory[windower.ffxi.get_items().equipment.main].id].english end,
    neck        = function() return windower.ffxi.get_items().equipment.neck > 0 and res.items[windower.ffxi.get_items().inventory[windower.ffxi.get_items().equipment.neck].id].english end,
    range       = function() return windower.ffxi.get_items().equipment.range > 0 and res.items[windower.ffxi.get_items().inventory[windower.ffxi.get_items().equipment.range].id].english end,
    right_ear   = function() return windower.ffxi.get_items().equipment.right_ear > 0 and res.items[windower.ffxi.get_items().inventory[windower.ffxi.get_items().equipment.right_ear].id].english end,
    right_ring  = function() return windower.ffxi.get_items().equipment.right_ring > 0 and res.items[windower.ffxi.get_items().inventory[windower.ffxi.get_items().equipment.right_ring].id].english end,
    sub         = function() return windower.ffxi.get_items().equipment.sub > 0 and res.items[windower.ffxi.get_items().inventory[windower.ffxi.get_items().equipment.sub].id].english end,
    waist       = function() return windower.ffxi.get_items().equipment.waist > 0 and res.items[windower.ffxi.get_items().inventory[windower.ffxi.get_items().equipment.waist].id].english end
}

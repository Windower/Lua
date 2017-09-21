--[[Copyright © 2016, Lygre, Burntwaffle@Odin
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of CapeTrader nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY Lygre, Burntwaffle@Odin BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]--

return T{
    ['threadhp'] = {['max'] = '60', ['mustcontain'] = T{'hp'},['cantcontain'] = T{}},
    ['threadmp'] = {['max'] = '60', ['mustcontain'] = T{'mp'},['cantcontain'] = T{}},
    ['threadstr'] = {['max'] = '20', ['mustcontain'] = T{'str'},['cantcontain'] = T{}},
    ['threaddex'] = {['max'] = '20', ['mustcontain'] = T{'dex'},['cantcontain'] = T{}},
    ['threadvit'] = {['max'] = '20', ['mustcontain'] = T{'vit'},['cantcontain'] = T{}},
    ['threadagi'] = {['max'] = '20', ['mustcontain'] = T{'agi'},['cantcontain'] = T{}},
    ['threadint'] = {['max'] = '20', ['mustcontain'] = T{'int'},['cantcontain'] = T{}},
    ['threadmnd'] = {['max'] = '20', ['mustcontain'] = T{'mnd'},['cantcontain'] = T{}},
    ['threadchr'] = {['max'] = '20', ['mustcontain'] = T{'chr'},['cantcontain'] = T{}},
    ['threadpetmelee'] = {['max'] = '20', ['mustcontain'] = T{'acc','r.acc','atk.','r.atk'},['cantcontain'] = T{}},
    ['threadpetmagic'] = {['max'] = '20', ['mustcontain'] = T{'pet','m.acc.','m.dmg.'},['cantcontain'] = T{}},

    ['dustacc/atk'] = {['max'] = '20', ['mustcontain'] = T{'accuracy','attack'},['cantcontain'] = T{}},
    ['dustracc/ratk'] = {['max'] = '20', ['mustcontain'] = T{'rng.acc','rng.atk'},['cantcontain'] = T{}},
    ['dustmacc/mdmg'] = {['max'] = '20', ['mustcontain'] = T{'mag. acc','mag. dmg.'},['cantcontain'] = T{}},
    ['dusteva/meva'] = {['max'] = '20', ['mustcontain'] = T{'eva.','mag. eva.'},['cantcontain'] = T{}},

    ['sapwsd'] = {['max'] = '10', ['mustcontain'] = T{'weapon skill damage'},['cantcontain'] = T{}},
    ['sapcritrate'] = {['max'] = '10', ['mustcontain'] = T{'crit'},['cantcontain'] = T{}},
    ['sapstp'] = {['max'] = '10', ['mustcontain'] = T{'store tp'},['cantcontain'] = T{}},
    ['sapdoubleattack'] = {['max'] = '10', ['mustcontain'] = T{'dbl.atk.'},['cantcontain'] = T{}},
    ['saphaste'] = {['max'] = '10', ['mustcontain'] = T{'haste'},['cantcontain'] = T{'pet'}},
    ['sapdw'] = {['max'] = '10', ['mustcontain'] = T{'dual'},['cantcontain'] = T{}},
    ['sapenmity+'] = {['max'] = '10', ['mustcontain'] = T{'enmity','+'},['cantcontain'] = T{}},
    ['sapenmity-'] = {['max'] = '10', ['mustcontain'] = T{'enmity','-'},['cantcontain'] = T{}},
    ['sapsnapshot'] = {['max'] = '10', ['mustcontain'] = T{'snapshot'},['cantcontain'] = T{}},
    ['sapmab'] = {['max'] = '10', ['mustcontain'] = T{'mag.atk.bns.'},['cantcontain'] = T{}},
    ['sapfc'] = {['max'] = '10', ['mustcontain'] = T{'fast cast'},['cantcontain'] = T{}},
    ['sapcurepotency'] = {['max'] = '10', ['mustcontain'] = T{'cure'},['cantcontain'] = T{}},
    ['sapwaltzpotency'] = {['max'] = '10', ['mustcontain'] = T{'waltz'},['cantcontain'] = T{}},
    ['sappetregen'] = {['max'] = '10', ['mustcontain'] = T{'pet','regen'},['cantcontain'] = T{}},
    ['sappethaste'] = {['max'] = '10', ['mustcontain'] = T{'pet','haste'},['cantcontain'] = T{}},

    ['dyehp'] = {['max'] = '20', ['mustcontain'] = T{'hp'},['cantcontain'] = T{}},
    ['dyemp'] = {['max'] = '20', ['mustcontain'] = T{'mp'},['cantcontain'] = T{}},
    ['dyestr'] = {['max'] = '10', ['mustcontain'] = T{'str'},['cantcontain'] = T{}},
    ['dyedex'] = {['max'] = '10', ['mustcontain'] = T{'dex'},['cantcontain'] = T{}},
    ['dyevit'] = {['max'] = '10', ['mustcontain'] = T{'vit'},['cantcontain'] = T{}},
    ['dyeagi'] = {['max'] = '10', ['mustcontain'] = T{'agi'},['cantcontain'] = T{}},
    ['dyeint'] = {['max'] = '10', ['mustcontain'] = T{'int'},['cantcontain'] = T{}},
    ['dyemnd'] = {['max'] = '10', ['mustcontain'] = T{'mnd'},['cantcontain'] = T{}},
    ['dyechr'] = {['max'] = '10', ['mustcontain'] = T{'chr'},['cantcontain'] = T{}},
    ['dyeacc'] = {['max'] = '10', ['mustcontain'] = T{'accuracy'},['cantcontain'] = T{'pet'}},
    ['dyeatk'] = {['max'] = '10', ['mustcontain'] = T{'attack'},['cantcontain'] = T{'pet'}},
    ['dyeracc'] = {['max'] = '10', ['mustcontain'] = T{'rng', 'acc'},['cantcontain'] = T{'pet'}},
    ['dyeratk'] = {['max'] = '10', ['mustcontain'] = T{'rng', 'atk'},['cantcontain'] = T{'pet'}},
    ['dyemacc'] = {['max'] = '10', ['mustcontain'] = T{'mag', 'acc'},['cantcontain'] = T{'pet'}},
    ['dyemdmg'] = {['max'] = '10', ['mustcontain'] = T{'magic', 'damage'},['cantcontain'] = T{'pet'}},
    ['dyeeva'] = {['max'] = '10', ['mustcontain'] = T{'evasion'}, ['cantcontain'] = T{'mag'}},
    ['dyemeva'] = {['max'] = '10', ['mustcontain'] = T{'mag', 'evasion'},['cantcontain'] = T{}},
    ['dyepetacc'] = {['max'] = '10', ['mustcontain'] = T{'pet','accuracy','rng', 'acc'},['cantcontain'] = T{}},
    ['dyepetatk'] = {['max'] = '10', ['mustcontain'] = T{'pet','attack','rng', 'atk'},['cantcontain'] = T{}},
    ['dyepetmacc'] = {['max'] = '10', ['mustcontain'] = T{'pet','mag' , 'acc'},['cantcontain'] = T{}},
    ['dyepetmdmg'] = {['max'] = '10', ['mustcontain'] = T{'pet','magic', 'damage'},['cantcontain'] = T{}},
}

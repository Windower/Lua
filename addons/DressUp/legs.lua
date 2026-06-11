-- Copyright © 2013, Cairthenn
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of DressUp nor the
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


models.legs = {}

-- Unobtainable Legs
models.legs[275] = { name = "bastokan campaign armor" , model = 218} 
models.legs[276] = { name = "sandy campaign armor" , model = 217}   -- elvaan m and elvaan f only
models.legs[277] = { name = "nanaa mihgo - ingrid - spitewardon" , model = 242}  -- mithra, hume f, humem elvaanm galka only
models.legs[278] = { name = "rughadjeen armor" , model = 178} -- elvaan m 
models.legs[279] = { name = "abqubah armor" , model = 173} -- hume m only
models.legs[10326] = { name = "enif cosciales" , model = 16543} 
models.legs[10327] = { name = "adhara seraweels" , model = 16544} 
models.legs[10328] = { name = "murzim cosciales" , model = 159} 
models.legs[10329] = { name = "shedir seraweels" , model = 160} 
models.legs[10330] = { name = "marine boxers" , model = 16718} 
models.legs[10331] = { name = "marine shorts" , model = 334} 
models.legs[10332] = { name = "woodsy boxers" , model = 334} 
models.legs[10333] = { name = "woodsy shorts" , model = 16719} 
models.legs[10334] = { name = "creek boxers" , model = 334} 
models.legs[10335] = { name = "creek shorts" , model = 335} 
models.legs[10336] = { name = "river shorts" , model = 334} 
models.legs[10337] = { name = "dune boxers" , model = 334} 
models.legs[10338] = { name = "marine boxers +1" , model = 334} 
models.legs[10339] = { name = "marine shorts +1" , model = 334} 
models.legs[10340] = { name = "woodsy boxers +1" , model = 334} 
models.legs[10341] = { name = "woodsy shorts +1" , model = 334} 
models.legs[10342] = { name = "creek boxers +1" , model = 334} 
models.legs[10343] = { name = "creek shorts +1" , model = 335} 
models.legs[10344] = { name = "river shorts +1" , model = 334} 
models.legs[10345] = { name = "dune boxers +1" , model = 334} 
models.legs[10346] = { name = "dux cuisses" , model = 16720} 
models.legs[10347] = { name = "dux cuisses +1" , model = 336} 
models.legs[10348] = { name = "chelona trousers" , model = 16721} 
models.legs[10349] = { name = "chelona trousers +1" , model = 337} 
models.legs[10550] = { name = "rheic dirs" , model = 16579} 
models.legs[10551] = { name = "rheic dirs +1" , model = 195} 
models.legs[10552] = { name = "rheic dirs +2" , model = 195} 
models.legs[10553] = { name = "rheic dirs +3" , model = 195} 
models.legs[10554] = { name = "phorcys dirs" , model = 195} 
models.legs[10555] = { name = "euxine kecks" , model = 16580} 
models.legs[10556] = { name = "euxine kecks +1" , model = 196} 
models.legs[10557] = { name = "euxine kecks +2" , model = 196} 
models.legs[10558] = { name = "euxine kecks +3" , model = 196} 
models.legs[10559] = { name = "thaumas kecks" , model = 196} 
models.legs[10560] = { name = "tethyan trews" , model = 16581} 
models.legs[10561] = { name = "tethyan trews +1" , model = 197} 
models.legs[10562] = { name = "tethyan trews +2" , model = 197} 
models.legs[10563] = { name = "tethyan trews +3" , model = 197} 
models.legs[10564] = { name = "nares trews" , model = 197} 
models.legs[10565] = { name = "hrafn hose" , model = 16707} 
models.legs[10566] = { name = "tenryu hakama" , model = 16708} 
models.legs[10567] = { name = "kheper kecks" , model = 16704} 
models.legs[10568] = { name = "auspex slops" , model = 16706} 
models.legs[10569] = { name = "paean tights" , model = 16705} 
models.legs[10570] = { name = "huginn hose" , model = 323} 
models.legs[10571] = { name = "tenryu hakama +1" , model = 324} 
models.legs[10572] = { name = "khepri kecks" , model = 320} 
models.legs[10573] = { name = "spurrina slops" , model = 322} 
models.legs[10574] = { name = "iaso tights" , model = 321} 
models.legs[10575] = { name = "ugol brayettes" , model = 16534} 
models.legs[10576] = { name = "mavros brayettes" , model = 150} 
models.legs[10577] = { name = "urja trousers" , model = 16434} 
models.legs[10578] = { name = "sthira trousers" , model = 7} 
models.legs[10579] = { name = "spolia trews" , model = 16533} 
models.legs[10580] = { name = "opima trews" , model = 149} 
models.legs[10581] = { name = "lefay brais" , model = 16497} 
models.legs[10582] = { name = "gardyloo trousers" , model = 16478} 
models.legs[10583] = { name = "hexed hose" , model = 16389} 
models.legs[10584] = { name = "hexed hakama" , model = 16393} 
models.legs[10585] = { name = "hexed kecks" , model = 16555} 
models.legs[10586] = { name = "hexed slops" , model = 16404} 
models.legs[10587] = { name = "hexed tights" , model = 16402} 
models.legs[10588] = { name = "hexed hose -1" , model = 16389 }
models.legs[10589] = { name = "hexed hakama -1" , model = 16393 }
models.legs[10590] = { name = "hexed kecks -1" , model = 16555 }
models.legs[10591] = { name = "hexed slops -1" , model = 16404 }
models.legs[10592] = { name = "hexed tights -1" , model = 16402 }
models.legs[10593] = { name = "decennial tights" , model = 16715} 
models.legs[10594] = { name = "decennial hose" , model = 16716} 
models.legs[10595] = { name = "decennial tights +1" , model = 331} 
models.legs[10596] = { name = "decennial hose +1" , model = 332} 
models.legs[10597] = { name = "akasha chaps" , model = 16495} 
models.legs[10598] = { name = "alcedo cuisses" , model = 16496} 
models.legs[10710] = { name = "war. cuisses +2" , model = 16449} 
models.legs[10711] = { name = "mel. hose +2" , model = 16451} 
models.legs[10712] = { name = "clr. pantaln. +2" , model = 16453} 
models.legs[10713] = { name = "src. tonban +2" , model = 16455} 
models.legs[10714] = { name = "dls. tights +2" , model = 16457} 
models.legs[10715] = { name = "asn. culottes +2" , model = 16459} 
models.legs[10716] = { name = "vlr. breeches +2" , model = 16461} 
models.legs[10717] = { name = "abs. flanchard +2" , model = 16463} 
models.legs[10718] = { name = "mst. trousers +2" , model = 16465} 
models.legs[10719] = { name = "brd. cannions +2" , model = 16467} 
models.legs[10720] = { name = "sct. braccae +2" , model = 16469} 
models.legs[10721] = { name = "sao. haidate +2" , model = 16471} 
models.legs[10722] = { name = "kog. hakama +2" , model = 16473} 
models.legs[10723] = { name = "wym. brais +2" , model = 16475} 
models.legs[10724] = { name = "smn. spats +2" , model = 16477} 
models.legs[10725] = { name = "mirage shalwar +2" , model = 16550} 
models.legs[10726] = { name = "comm. culottes +2" , model = 16552} 
models.legs[10727] = { name = "ptn. churidars +2" , model = 16554} 
models.legs[10728] = { name = "etoile tights +2" , model = 16688} 
models.legs[10729] = { name = "argute pants +2" , model = 16599} 
models.legs[11124] = { name = "rvg. cuisses +2" , model = 16666} 
models.legs[11125] = { name = "tantra hose +2" , model = 16667} 
models.legs[11126] = { name = "orsn. pantaln. +2" , model = 16668} 
models.legs[11127] = { name = "goet. chausses +2" , model = 16669} 
models.legs[11128] = { name = "estqr. fuseau +2" , model = 16670} 
models.legs[11129] = { name = "raid. culottes +2" , model = 16671} 
models.legs[11130] = { name = "creed cuisses +2" , model = 16672} 
models.legs[11131] = { name = "bale flanchard +2" , model = 16673} 
models.legs[11132] = { name = "ferine quijotes +2" , model = 16674} 
models.legs[11133] = { name = "aoidos' rhing. +2" , model = 16675} 
models.legs[11134] = { name = "sylvan bragues +2" , model = 16676} 
models.legs[11135] = { name = "unkai haidate +2" , model = 16677} 
models.legs[11136] = { name = "iga hakama +2" , model = 16678} 
models.legs[11137] = { name = "lncr. cuissots +2" , model = 16679} 
models.legs[11138] = { name = "caller's spats +2" , model = 16680} 
models.legs[11139] = { name = "mavi tayt +2" , model = 16681} 
models.legs[11140] = { name = "nvrch. culottes +2" , model = 16682} 
models.legs[11141] = { name = "cirq. pantaloni +2" , model = 16683} 
models.legs[11142] = { name = "charis tights +2" , model = 16689} 
models.legs[11143] = { name = "savant's pants +2" , model = 16690} 
models.legs[11224] = { name = "ravagers cuisses +1" , model = 282} 
models.legs[11225] = { name = "tantra hose +1" , model = 283} 
models.legs[11226] = { name = "orison pantaloons +1" , model = 284} 
models.legs[11227] = { name = "goetia chausses +1" , model = 285} 
models.legs[11228] = { name = "estoqueurs fuseau +1" , model = 286} 
models.legs[11229] = { name = "raiders culottes +1" , model = 287} 
models.legs[11230] = { name = "creed cuisses +1" , model = 288} 
models.legs[11231] = { name = "bale flanchard +1" , model = 289} 
models.legs[11232] = { name = "ferine quijotes +1" , model = 290} 
models.legs[11233] = { name = "aoidos rhingrave +1" , model = 291} 
models.legs[11234] = { name = "sylvan bragues +1" , model = 292} 
models.legs[11235] = { name = "unkai haidate +1" , model = 293} 
models.legs[11236] = { name = "iga hakama +1" , model = 294} 
models.legs[11237] = { name = "lancers cuissots +1" , model = 295} 
models.legs[11238] = { name = "callers spats +1" , model = 296} 
models.legs[11239] = { name = "mavi tayt +1" , model = 297} 
models.legs[11240] = { name = "navarchs culottes +1" , model = 298} 
models.legs[11241] = { name = "cirque pantaloni +1" , model = 299} 
models.legs[11242] = { name = "charis tights +1" , model = 305} 
models.legs[11243] = { name = "savants pants +1" , model = 306} 
models.legs[11928] = { name = "gules subligar" , model = 16440} 
models.legs[11929] = { name = "gules subligar +1" , model = 56} 
models.legs[11930] = { name = "versa breeches" , model = 16442} 
models.legs[11931] = { name = "versa breeches +1" , model = 58} 
models.legs[11932] = { name = "lore slops" , model = 16499} 
models.legs[11933] = { name = "lore slops +1" , model = 115} 
models.legs[11934] = { name = "cybele pants" , model = 16527} 
models.legs[11935] = { name = "ambushers hose" , model = 94} 
models.legs[11936] = { name = "bustle dirs" , model = 16558} 
models.legs[11937] = { name = "sagacity lappas" , model = 16521} 
models.legs[11938] = { name = "bellicus cuisses" , model = 16654} 
models.legs[11939] = { name = "bestia breeches" , model = 16657} 
models.legs[11940] = { name = "paragon brayettes" , model = 16660} 
models.legs[11941] = { name = "skopos braccae" , model = 16633} 
models.legs[11942] = { name = "kokugetsu haidate" , model = 16636} 
models.legs[11943] = { name = "spry tights" , model = 16639} 
models.legs[11944] = { name = "mederi slacks" , model = 16642} 
models.legs[11945] = { name = "literae pants" , model = 16645} 
models.legs[11946] = { name = "facio spats" , model = 16648} 
models.legs[11947] = { name = "nisse slacks" , model = 16651} 
models.legs[11948] = { name = "stanch cuisses" , model = 16439} 
models.legs[11949] = { name = "haven hose" , model = 16546} 
models.legs[11950] = { name = "alcide's subligar" , model = 16494} 
models.legs[11951] = { name = "alcides subligar +1" , model = 110} 
models.legs[11952] = { name = "nemus salvars" , model = 16556} 
models.legs[11953] = { name = "nemus salvars +1" , model = 172} 
models.legs[11954] = { name = "nebula slops" , model = 16485} 
models.legs[11955] = { name = "nebula slops +1" , model = 101} 
models.legs[11956] = { name = "novennial hose" , model = 16619} 
models.legs[11957] = { name = "novennial boots" , model = 16629} 
models.legs[11958] = { name = "calmecac trousers" , model = 16590} 
models.legs[11959] = { name = "calmecac subligar" , model = 16591} 
models.legs[11960] = { name = "jingang hose" , model = 16592} 
models.legs[11961] = { name = "menhit slacks" , model = 16593} 
models.legs[11962] = { name = "galvanic slops" , model = 18} 
models.legs[11963] = { name = "affronter cuisses" , model = 16409} 
models.legs[11964] = { name = "whirlwind dirs" , model = 159} 
models.legs[11965] = { name = "dream trousers" , model = 16627} 
models.legs[11966] = { name = "dream trousers +1" , model = 243} 
models.legs[11967] = { name = "dream pants" , model = 16628} 
models.legs[11968] = { name = "dream pants +1" , model = 244} 
models.legs[11969] = { name = "ogier's breeches" , model = 16709} 
models.legs[11970] = { name = "athos's tights" , model = 16710} 
models.legs[11971] = { name = "rubeus spats" , model = 16711} 
models.legs[11972] = { name = "praeco slacks" , model = 16713} 
models.legs[11973] = { name = "hidalgo slops" , model = 149} 
models.legs[11974] = { name = "avant cuisses" , model = 16413} 
models.legs[11975] = { name = "avant cuisses +1" , model = 29} 
models.legs[11976] = { name = "kacura subligar" , model = 110} 
models.legs[11977] = { name = "kacura subligar +1" , model = 110} 
models.legs[11978] = { name = "sweven slacks" , model = 16515} 
models.legs[11979] = { name = "sweven slacks +1" , model = 131} 
models.legs[11980] = { name = "calma hose" , model = 16665} 
models.legs[11981] = { name = "mustela brais" , model = 16632} 
models.legs[11982] = { name = "magavan slops" , model = 16653} 
models.legs[11983] = { name = "triplus subligar" , model = 16588} 
models.legs[11984] = { name = "induro cuisses" , model = 16656} 
models.legs[11985] = { name = "tussle breeches" , model = 16659} 
models.legs[11986] = { name = "mystagog slacks" , model = 16644} 
models.legs[11987] = { name = "ngen seraweels" , model = 160} 
models.legs[12068] = { name = "ravagers cuisses" , model = 282} 
models.legs[12069] = { name = "tantra hose" , model = 283} 
models.legs[12070] = { name = "orison pantaloons" , model = 284} 
models.legs[12071] = { name = "goetia chausses" , model = 285} 
models.legs[12072] = { name = "estoqueurs fuseau" , model = 286} 
models.legs[12073] = { name = "raiders culottes" , model = 287} 
models.legs[12074] = { name = "creed cuisses" , model = 288} 
models.legs[12075] = { name = "bale flanchard" , model = 289} 
models.legs[12076] = { name = "ferine quijotes" , model = 290} 
models.legs[12077] = { name = "aoidos rhingrave" , model = 291} 
models.legs[12078] = { name = "sylvan bragues" , model = 292} 
models.legs[12079] = { name = "unkai haidate" , model = 293} 
models.legs[12080] = { name = "iga hakama" , model = 294} 
models.legs[12081] = { name = "lancers cuissots" , model = 295} 
models.legs[12082] = { name = "callers spats" , model = 296} 
models.legs[12083] = { name = "mavi tayt" , model = 297} 
models.legs[12084] = { name = "navarchs culottes" , model = 298} 
models.legs[12085] = { name = "cirque pantaloni" , model = 299} 
models.legs[12086] = { name = "charis tights" , model = 305} 
models.legs[12087] = { name = "savants pants" , model = 306} 
models.legs[12216] = { name = "ebon cuisses" , model = 270} 
models.legs[12217] = { name = "furia cuisses" , model = 16655} 
models.legs[12218] = { name = "ebur cuisses" , model = 272} 
models.legs[12219] = { name = "ebon breeches" , model = 273} 
models.legs[12220] = { name = "furia breeches" , model = 16658} 
models.legs[12221] = { name = "ebur breeches" , model = 275} 
models.legs[12222] = { name = "ebon brayettes" , model = 276} 
models.legs[12223] = { name = "furia brayettes" , model = 16661} 
models.legs[12224] = { name = "ebur brayettes" , model = 16662} 
models.legs[12225] = { name = "ebon hose" , model = 16663} 
models.legs[12226] = { name = "furia hose" , model = 16664} 
models.legs[12227] = { name = "ebur hose" , model = 281} 
models.legs[12228] = { name = "ebon brais" , model = 16630} 
models.legs[12229] = { name = "furia brais" , model = 16631} 
models.legs[12230] = { name = "ebur brais" , model = 248} 
models.legs[12231] = { name = "ebon braccae" , model = 249} 
models.legs[12232] = { name = "furia braccae" , model = 16634} 
models.legs[12233] = { name = "ebur braccae" , model = 16635} 
models.legs[12234] = { name = "shikkoku haidate" , model = 252} 
models.legs[12235] = { name = "shinku haidate" , model = 16637} 
models.legs[12236] = { name = "ginhaku haidate" , model = 16638} 
models.legs[12237] = { name = "ebon tights" , model = 255} 
models.legs[12238] = { name = "furia tights" , model = 16640} 
models.legs[12239] = { name = "ebur tights" , model = 16641} 
models.legs[12240] = { name = "ebon slacks" , model = 258} 
models.legs[12241] = { name = "furia slacks" , model = 16643} 
models.legs[12242] = { name = "ebur slacks" , model = 260} 
models.legs[12243] = { name = "ebon pants" , model = 261} 
models.legs[12244] = { name = "furia pants" , model = 16646} 
models.legs[12245] = { name = "ebur pants" , model = 16647} 
models.legs[12246] = { name = "ebon spats" , model = 264} 
models.legs[12247] = { name = "furia spats" , model = 16649} 
models.legs[12248] = { name = "ebur spats" , model = 16650} 
models.legs[12249] = { name = "ebon slops" , model = 267} 
models.legs[12250] = { name = "furia slops" , model = 16652} 
models.legs[12251] = { name = "ebur slops" , model = 269} 
models.legs[12800] = { name = "cuisses" , model = 16368} 
models.legs[12801] = { name = "mythril cuisses" , model = 29} 
models.legs[12802] = { name = "gold cuisses" , model = 25} 
models.legs[12803] = { name = "darksteel cuisses" , model = 16406} 
models.legs[12804] = { name = "adaman cuisses" , model = 55} 
models.legs[12805] = { name = "koenig diechlings" , model = 16479} 
models.legs[12806] = { name = "iron musketeers cuisses" , model = 25} 
models.legs[12807] = { name = "judge's cuisses" , model = 16414} 
models.legs[12808] = { name = "chain hose" , model = 5} 
models.legs[12809] = { name = "silver hose" , model = 5} 
models.legs[12810] = { name = "breeches" , model = 16396} 
models.legs[12811] = { name = "dst. breeches" , model = 16397} 
models.legs[12812] = { name = "thick breeches" , model = 58} 
models.legs[12813] = { name = "adaman breeches" , model = 16447} 
models.legs[12814] = { name = "royal knights breeches" , model = 13} 
models.legs[12815] = { name = "royal squires breeches" , model = 12} 
models.legs[12816] = { name = "scale cuisses" , model = 16412} 
models.legs[12817] = { name = "brass cuisses" , model = 28} 
models.legs[12818] = { name = "byakko's haidate" , model = 16483} 
models.legs[12819] = { name = "coral cuisses" , model = 16410} 
models.legs[12820] = { name = "dragon cuisses" , model = 16444} 
models.legs[12821] = { name = "gavial cuisses" , model = 16411} 
models.legs[12822] = { name = "centurions cuisses" , model = 26} 
models.legs[12823] = { name = "brz. subligar +1" , model = 16399} 
models.legs[12824] = { name = "leather trousers" , model = 16385} 
models.legs[12825] = { name = "lizard trousers" , model = 16390} 
models.legs[12826] = { name = "studded trousers" , model = 1} 
models.legs[12827] = { name = "cuir trousers" , model = 1} 
models.legs[12828] = { name = "raptor trousers" , model = 16391} 
models.legs[12829] = { name = "beak trousers" , model = 6} 
models.legs[12830] = { name = "tiger trousers" , model = 50} 
models.legs[12831] = { name = "coeurl trousers" , model = 16438} 
models.legs[12832] = { name = "bronze subligar" , model = 15} 
models.legs[12833] = { name = "brass subligar" , model = 15} 
models.legs[12834] = { name = "bone subligar" , model = 16400} 
models.legs[12835] = { name = "beetle subligar" , model = 16} 
models.legs[12836] = { name = "iron subligar" , model = 16398} 
models.legs[12837] = { name = "carapace subligar" , model = 14} 
models.legs[12838] = { name = "scorpion subligar" , model = 16} 
models.legs[12839] = { name = "darksteel subligar" , model = 14} 
models.legs[12840] = { name = "sitabaki" , model = 16401} 
models.legs[12841] = { name = "cotton sitabaki" , model = 17} 
models.legs[12842] = { name = "soil sitabaki" , model = 17} 
models.legs[12843] = { name = "haidate" , model = 9} 
models.legs[12844] = { name = "shinobi hakama" , model = 16388} 
models.legs[12846] = { name = "wukongs hakama" , model = 4} 
models.legs[12847] = { name = "yasha hakama" , model = 16482} 
models.legs[12848] = { name = "brais" , model = 16405} 
models.legs[12849] = { name = "cotton brais" , model = 21} 
models.legs[12850] = { name = "hose" , model = 16407} 
models.legs[12851] = { name = "wool hose" , model = 23} 
models.legs[12852] = { name = "battle hose" , model = 16408} 
models.legs[12853] = { name = "war brais" , model = 16480} 
models.legs[12854] = { name = "mercenary captains hose" , model = 21} 
models.legs[12855] = { name = "mercenarys sitabaki" , model = 17} 
models.legs[12856] = { name = "slops" , model = 20} 
models.legs[12857] = { name = "linen slops" , model = 20} 
models.legs[12858] = { name = "wool slops" , model = 18} 
models.legs[12859] = { name = "velvet slops" , model = 18} 
models.legs[12860] = { name = "silk slops" , model = 16403} 
models.legs[12861] = { name = "noble's slacks" , model = 16441} 
models.legs[12862] = { name = "tactician magicians slops" , model = 19} 
models.legs[12863] = { name = "solid cuisses" , model = 28} 
models.legs[12864] = { name = "slacks" , model = 16387} 
models.legs[12865] = { name = "black slacks" , model = 3} 
models.legs[12866] = { name = "linen slacks" , model = 16394} 
models.legs[12867] = { name = "white slacks" , model = 16395} 
models.legs[12868] = { name = "silk slacks" , model = 11} 
models.legs[12870] = { name = "combat casters slacks" , model = 3} 
models.legs[12871] = { name = "custom slacks" , model = 16415} 
models.legs[12872] = { name = "custom pants" , model = 31} 
models.legs[12873] = { name = "magna m chausses" , model = 31} 
models.legs[12874] = { name = "magna f chausses" , model = 31} 
models.legs[12875] = { name = "wonder braccae" , model = 31} 
models.legs[12876] = { name = "savage loincloth" , model = 31} 
models.legs[12877] = { name = "elders braguette" , model = 31} 
models.legs[12878] = { name = "coral subligar" , model = 56} 
models.legs[12879] = { name = "dusk trousers" , model = 16493} 
models.legs[12880] = { name = "ogre trousers" , model = 94} 
models.legs[12881] = { name = "legionnaires subligar" , model = 15} 
models.legs[12882] = { name = "royal footmans trousers" , model = 1} 
models.legs[12883] = { name = "hume slacks" , model = 16392} 
models.legs[12884] = { name = "hume pants" , model = 8} 
models.legs[12885] = { name = "elvaan m chausses" , model = 8} 
models.legs[12886] = { name = "tarutaru braccae" , model = 8} 
models.legs[12887] = { name = "mithran loincloth" , model = 8} 
models.legs[12888] = { name = "galkan braguette" , model = 8} 
models.legs[12889] = { name = "elvaan f chausses" , model = 8} 
models.legs[12890] = { name = "chain hose +1" , model = 5} 
models.legs[12891] = { name = "iron subligar +1" , model = 14} 
models.legs[12892] = { name = "brass subligar +1" , model = 15} 
models.legs[12893] = { name = "brass cuisses +1" , model = 28} 
models.legs[12894] = { name = "silver hose +1" , model = 5} 
models.legs[12895] = { name = "breeches +1" , model = 12} 
models.legs[12896] = { name = "brais +1" , model = 21} 
models.legs[12897] = { name = "slops +1" , model = 20} 
models.legs[12898] = { name = "slacks +1" , model = 3} 
models.legs[12899] = { name = "sitabaki +1" , model = 17} 
models.legs[12900] = { name = "great brais" , model = 21} 
models.legs[12901] = { name = "linen slops +1" , model = 20} 
models.legs[12902] = { name = "cotton sitabaki +1" , model = 17} 
models.legs[12903] = { name = "hose +1" , model = 23} 
models.legs[12904] = { name = "linen slacks +1" , model = 10} 
models.legs[12905] = { name = "soil sitabaki +1" , model = 17} 
models.legs[12906] = { name = "wool slops +1" , model = 18} 
models.legs[12907] = { name = "wool hose +1" , model = 23} 
models.legs[12908] = { name = "leather trousers +1" , model = 1} 
models.legs[12909] = { name = "fine trousers" , model = 6} 
models.legs[12910] = { name = "strong trousers" , model = 1} 
models.legs[12911] = { name = "cuir trousers +1" , model = 1} 
models.legs[12912] = { name = "bone subligar +1" , model = 16} 
models.legs[12913] = { name = "beetle subligar +1" , model = 16} 
models.legs[12914] = { name = "carapace subligar +1" , model = 14} 
models.legs[12915] = { name = "freeswords slops" , model = 20} 
models.legs[12916] = { name = "cuisses +1" , model = 16386} 
models.legs[12917] = { name = "mages slacks" , model = 3} 
models.legs[12918] = { name = "mages slops" , model = 18} 
models.legs[12919] = { name = "dino trousers" , model = 7} 
models.legs[12920] = { name = "matre bragezenn" , model = 7} 
models.legs[12921] = { name = "ace's hose" , model = 16605} 
models.legs[12922] = { name = "martial slacks" , model = 11} 
models.legs[12923] = { name = "jujitsu sitabaki" , model = 17} 
models.legs[12924] = { name = "magic cuisses" , model = 28} 
models.legs[12925] = { name = "shinobi hakama +1" , model = 4} 
models.legs[12926] = { name = "white slacks +1" , model = 11} 
models.legs[12927] = { name = "silk slops +1" , model = 19} 
models.legs[14208] = { name = "scorpion subligar +1" , model = 16} 
models.legs[14209] = { name = "darksteel breeches +1" , model = 21} 
models.legs[14210] = { name = "perle brayettes" , model = 16623} 
models.legs[14211] = { name = "mythril cuisses +1" , model = 29} 
models.legs[14212] = { name = "gilt cuisses" , model = 25} 
models.legs[14213] = { name = "beak trousers +1" , model = 6} 
models.legs[14214] = { name = "fighter's cuisses" , model = 16448} 
models.legs[14215] = { name = "temple hose" , model = 16450} 
models.legs[14216] = { name = "healer's pantaln." , model = 16452} 
models.legs[14217] = { name = "wizard's tonban" , model = 16454} 
models.legs[14218] = { name = "warlock's tights" , model = 16456} 
models.legs[14219] = { name = "rogue's culottes" , model = 16458} 
models.legs[14220] = { name = "gallant breeches" , model = 16460} 
models.legs[14221] = { name = "chaos flanchard" , model = 16462} 
models.legs[14222] = { name = "beast trousers" , model = 16464} 
models.legs[14223] = { name = "choral cannions" , model = 16466} 
models.legs[14224] = { name = "hunter's braccae" , model = 16468} 
models.legs[14225] = { name = "myochin haidate" , model = 16470} 
models.legs[14226] = { name = "ninja hakama" , model = 16472} 
models.legs[14227] = { name = "drachen brais" , model = 16474} 
models.legs[14228] = { name = "evoker's spats" , model = 16476} 
models.legs[14229] = { name = "darksteel cuisses +1" , model = 22} 
models.legs[14230] = { name = "coral cuisses +1" , model = 27} 
models.legs[14231] = { name = "dragon cuisses +1" , model = 60} 
models.legs[14232] = { name = "feral trousers" , model = 50} 
models.legs[14233] = { name = "torama trousers" , model = 54} 
models.legs[14234] = { name = "darksteel subligar +1" , model = 14} 
models.legs[14235] = { name = "mermans subligar" , model = 56} 
models.legs[14236] = { name = "haidate +1" , model = 9} 
models.legs[14237] = { name = "battle hose +1" , model = 24} 
models.legs[14238] = { name = "war brais +1" , model = 96} 
models.legs[14239] = { name = "aristocrats slacks" , model = 57} 
models.legs[14240] = { name = "silk slacks +1" , model = 11} 
models.legs[14241] = { name = "portent pants" , model = 16491} 
models.legs[14242] = { name = "rusty subligar" , model = 15} 
models.legs[14243] = { name = "iron cuisses" , model = 16436} 
models.legs[14244] = { name = "iron cuisses +1" , model = 52} 
models.legs[14245] = { name = "steel cuisses" , model = 16437} 
models.legs[14246] = { name = "steel cuisses +1" , model = 53} 
models.legs[14247] = { name = "zenith slacks" , model = 107} 
models.legs[14248] = { name = "zenith slacks +1" , model = 107} 
models.legs[14249] = { name = "opaline hose" , model = 16500} 
models.legs[14250] = { name = "ceremonial hose" , model = 116} 
models.legs[14251] = { name = "wedding hose" , model = 116} 
models.legs[14252] = { name = "thick breeches +1" , model = 58} 
models.legs[14253] = { name = "arhat's hakama" , model = 16443} 
models.legs[14254] = { name = "masters sitabaki" , model = 17} 
models.legs[14255] = { name = "masters sitabaki +1" , model = 17} 
models.legs[14256] = { name = "arhats hakama +1" , model = 59} 
models.legs[14257] = { name = "aurore brais" , model = 16625} 
models.legs[14258] = { name = "teal slops" , model = 16624} 
models.legs[14259] = { name = "bastokan subligar" , model = 15} 
models.legs[14260] = { name = "republic subligar" , model = 15} 
models.legs[14261] = { name = "royal squires breeches +1" , model = 12} 
models.legs[14262] = { name = "royal squires breeches +2" , model = 12} 
models.legs[14263] = { name = "iron musketeers cuisses +1" , model = 25} 
models.legs[14264] = { name = "iron musketeers cuisses +2" , model = 25} 
models.legs[14265] = { name = "san dorian trousers" , model = 1} 
models.legs[14266] = { name = "kingdom trousers" , model = 1} 
models.legs[14267] = { name = "bastokan cuisses" , model = 26} 
models.legs[14268] = { name = "republic cuisses" , model = 26} 
models.legs[14269] = { name = "windurstian sitabaki" , model = 17} 
models.legs[14270] = { name = "federation sitabaki" , model = 17} 
models.legs[14271] = { name = "windurstian brais" , model = 21} 
models.legs[14272] = { name = "federation brais" , model = 21} 
models.legs[14273] = { name = "windurstian slops" , model = 20} 
models.legs[14274] = { name = "federation slops" , model = 20} 
models.legs[14275] = { name = "combat casters slacks +1" , model = 3} 
models.legs[14276] = { name = "combat casters slacks +2" , model = 3} 
models.legs[14277] = { name = "tactician magicians slops +1" , model = 19} 
models.legs[14278] = { name = "tactician magicians slops +2" , model = 19} 
models.legs[14279] = { name = "ogre trousers +1" , model = 94} 
models.legs[14280] = { name = "crimson cuisses" , model = 16446} 
models.legs[14281] = { name = "blood cuisses" , model = 62} 
models.legs[14282] = { name = "arcane slops" , model = 149} 
models.legs[14283] = { name = "kaiser diechlings" , model = 95} 
models.legs[14286] = { name = "frog trousers" , model = 7} 
models.legs[14287] = { name = "luna subligar" , model = 16} 
models.legs[14288] = { name = "clowns subligar" , model = 56} 
models.legs[14289] = { name = "clowns subligar +1" , model = 56} 
models.legs[14290] = { name = "vagabond's hose" , model = 16488} 
models.legs[14291] = { name = "nomads hose" , model = 104} 
models.legs[14292] = { name = "fisherman's hose" , model = 16486} 
models.legs[14293] = { name = "anglers hose" , model = 102} 
models.legs[14294] = { name = "chocobo hose" , model = 16487} 
models.legs[14295] = { name = "riders hose" , model = 103} 
models.legs[14296] = { name = "armada breeches" , model = 63} 
models.legs[14297] = { name = "field hose" , model = 16489} 
models.legs[14298] = { name = "worker hose" , model = 105} 
models.legs[14299] = { name = "rst. hakama" , model = 16445} 
models.legs[14300] = { name = "rasetsu hakama +1" , model = 61} 
models.legs[14301] = { name = "errant slops" , model = 101} 
models.legs[14302] = { name = "mahatma slops" , model = 101} 
models.legs[14303] = { name = "shura haidate" , model = 16490} 
models.legs[14304] = { name = "shura haidate +1" , model = 106} 
models.legs[14305] = { name = "dragon subligar" , model = 110} 
models.legs[14306] = { name = "dragon subligar +1" , model = 110} 
models.legs[14307] = { name = "dusk trousers +1" , model = 109} 
models.legs[14308] = { name = "hecatomb subligar" , model = 16484} 
models.legs[14309] = { name = "hecatomb subligar +1" , model = 100} 
models.legs[14310] = { name = "austere slops" , model = 115} 
models.legs[14311] = { name = "penance slops" , model = 115} 
models.legs[14312] = { name = "gem cuisses" , model = 55} 
models.legs[14313] = { name = "gavial cuisses +1" , model = 27} 
models.legs[14314] = { name = "garrison hose" , model = 105} 
models.legs[14315] = { name = "sha'ir seraweels" , model = 16519} 
models.legs[14316] = { name = "sheikh seraweels" , model = 135} 
models.legs[14317] = { name = "barone cosciales" , model = 16520} 
models.legs[14318] = { name = "conte cosciales" , model = 136} 
models.legs[14319] = { name = "bison kecks" , model = 16518} 
models.legs[14320] = { name = "braves kecks" , model = 134} 
models.legs[14321] = { name = "igqira lappas" , model = 137} 
models.legs[14322] = { name = "genie lappas" , model = 137} 
models.legs[14323] = { name = "noct brais" , model = 16517} 
models.legs[14324] = { name = "mist slacks" , model = 16514} 
models.legs[14325] = { name = "seers slacks" , model = 131} 
models.legs[14326] = { name = "garish slacks" , model = 130} 
models.legs[14327] = { name = "shade tights" , model = 16513} 
models.legs[14328] = { name = "seers slacks +1" , model = 131} 
models.legs[14329] = { name = "eisendiechlings" , model = 16522} 
models.legs[14330] = { name = "rubious slacks" , model = 130} 
models.legs[14331] = { name = "shade tights +1" , model = 129} 
models.legs[14332] = { name = "kampfdiechlings" , model = 138} 
models.legs[14333] = { name = "noct brais +1" , model = 133} 
models.legs[14334] = { name = "shinimusha haidate" , model = 9} 
models.legs[14335] = { name = "nokizaru hakama" , model = 4} 
models.legs[15117] = { name = "warriors cuisses" , model = 65} 
models.legs[15118] = { name = "melee hose" , model = 67} 
models.legs[15119] = { name = "clerics pantaloons" , model = 69} 
models.legs[15120] = { name = "sorcerers tonban" , model = 71} 
models.legs[15121] = { name = "duelists tights" , model = 73} 
models.legs[15122] = { name = "assassins culottes" , model = 75} 
models.legs[15123] = { name = "valor breeches" , model = 77} 
models.legs[15124] = { name = "abyss flanchard" , model = 79} 
models.legs[15125] = { name = "monster trousers" , model = 81} 
models.legs[15126] = { name = "bards cannions" , model = 83} 
models.legs[15127] = { name = "scouts braccae" , model = 85} 
models.legs[15128] = { name = "saotome haidate" , model = 87} 
models.legs[15129] = { name = "koga hakama" , model = 89} 
models.legs[15130] = { name = "wyrm brais" , model = 91} 
models.legs[15131] = { name = "summoners spats" , model = 93} 
models.legs[15367] = { name = "falconers hose" , model = 5} 
models.legs[15368] = { name = "war hose" , model = 23} 
models.legs[15369] = { name = "aikido koshita" , model = 11} 
models.legs[15370] = { name = "sable cuisses" , model = 22} 
models.legs[15371] = { name = "darksteel codpiece" , model = 14} 
models.legs[15372] = { name = "magic slacks" , model = 3} 
models.legs[15373] = { name = "bravos subligar" , model = 16} 
models.legs[15374] = { name = "druids slops" , model = 20} 
models.legs[15375] = { name = "aries subligar" , model = 16416} 
models.legs[15376] = { name = "taurus subligar" , model = 32} 
models.legs[15377] = { name = "gemini subligar" , model = 32} 
models.legs[15378] = { name = "cancer subligar" , model = 32} 
models.legs[15379] = { name = "leo subligar" , model = 32} 
models.legs[15380] = { name = "virgo subligar" , model = 32} 
models.legs[15381] = { name = "libra subligar" , model = 32} 
models.legs[15382] = { name = "scorpius subligar" , model = 32} 
models.legs[15383] = { name = "sagittarius subligar" , model = 32} 
models.legs[15384] = { name = "capricornus subligar" , model = 32} 
models.legs[15385] = { name = "aquarius subligar" , model = 32} 
models.legs[15386] = { name = "pisces subligar" , model = 32} 
models.legs[15387] = { name = "trackers kecks" , model = 134} 
models.legs[15388] = { name = "ophiuchus subligar" , model = 32} 
models.legs[15389] = { name = "vir subligar" , model = 16417} 
models.legs[15390] = { name = "femina subligar" , model = 33} 
models.legs[15391] = { name = "blessed trousers" , model = 16526} 
models.legs[15392] = { name = "hachiman hakama" , model = 16525} 
models.legs[15393] = { name = "blessed trousers +1" , model = 142} 
models.legs[15394] = { name = "hachiman hakama +1" , model = 141} 
models.legs[15395] = { name = "lord's cuisses" , model = 16523} 
models.legs[15396] = { name = "wise braconi" , model = 143} 
models.legs[15397] = { name = "wise braconi +1" , model = 143} 
models.legs[15398] = { name = "yasha hakama +1" , model = 98} 
models.legs[15399] = { name = "kings cuisses" , model = 139} 
models.legs[15400] = { name = "black cuisses" , model = 16535} 
models.legs[15401] = { name = "onyx cuisses" , model = 151} 
models.legs[15402] = { name = "alumine brayettes" , model = 150} 
models.legs[15403] = { name = "luisant brayettes" , model = 150} 
models.legs[15404] = { name = "traders slops" , model = 149} 
models.legs[15405] = { name = "barons slops" , model = 149} 
models.legs[15406] = { name = "unicorn subligar" , model = 16532} 
models.legs[15407] = { name = "unicorn subligar +1" , model = 148} 
models.legs[15408] = { name = "hume trunks" , model = 16541} 
models.legs[15409] = { name = "hume shorts" , model = 157} 
models.legs[15410] = { name = "elvaan trunks" , model = 157} 
models.legs[15411] = { name = "elvaan shorts" , model = 157} 
models.legs[15412] = { name = "tarutaru trunks" , model = 157} 
models.legs[15413] = { name = "mithra shorts" , model = 157} 
models.legs[15414] = { name = "galka trunks" , model = 157} 
models.legs[15415] = { name = "hume trunks +1" , model = 157} 
models.legs[15416] = { name = "hume shorts +1" , model = 157} 
models.legs[15417] = { name = "elvaan trunks +1" , model = 157} 
models.legs[15418] = { name = "elvaan shorts +1" , model = 157} 
models.legs[15419] = { name = "tarutaru trunks +1" , model = 157} 
models.legs[15420] = { name = "mithra shorts +1" , model = 157} 
models.legs[15421] = { name = "galka trunks +1" , model = 157} 
models.legs[15422] = { name = "black hose" , model = 102} 
models.legs[15423] = { name = "tarutaru shorts" , model = 16542} 
models.legs[15424] = { name = "tarutaru shorts +1" , model = 158} 
models.legs[15425] = { name = "galliard trousers" , model = 130} 
models.legs[15426] = { name = "torrent subligar" , model = 16586} 
models.legs[15427] = { name = "teutates subligar" , model = 16563} 
models.legs[15428] = { name = "ocelot trousers" , model = 16615} 
models.legs[15429] = { name = "wicca subligar" , model = 16600} 
models.legs[15430] = { name = "augurs brais" , model = 223} 
models.legs[15561] = { name = "fighters cuisses +1" , model = 64} 
models.legs[15562] = { name = "temple hose +1" , model = 66} 
models.legs[15563] = { name = "healers pantaloons +1" , model = 68} 
models.legs[15564] = { name = "wizards tonban +1" , model = 70} 
models.legs[15565] = { name = "warlocks tights +1" , model = 72} 
models.legs[15566] = { name = "rogues culottes +1" , model = 74} 
models.legs[15567] = { name = "gallant breeches +1" , model = 76} 
models.legs[15568] = { name = "chaos flanchard +1" , model = 78} 
models.legs[15569] = { name = "beast trousers +1" , model = 80} 
models.legs[15570] = { name = "choral cannions +1" , model = 82} 
models.legs[15571] = { name = "hunters braccae +1" , model = 84} 
models.legs[15572] = { name = "myochin haidate +1" , model = 86} 
models.legs[15573] = { name = "ninja hakama +1" , model = 88} 
models.legs[15574] = { name = "drachen brais +1" , model = 90} 
models.legs[15575] = { name = "evokers spats +1" , model = 92} 
models.legs[15576] = { name = "homam cosciales" , model = 159} 
models.legs[15577] = { name = "nashira seraweels" , model = 160} 
models.legs[15578] = { name = "crow hose" , model = 162} 
models.legs[15579] = { name = "raven hose" , model = 162} 
models.legs[15580] = { name = "warriors cuisses +1" , model = 65} 
models.legs[15581] = { name = "melee hose +1" , model = 67} 
models.legs[15582] = { name = "clerics pantaloons +1" , model = 69} 
models.legs[15583] = { name = "sorcerers tonban +1" , model = 71} 
models.legs[15584] = { name = "duelists tights +1" , model = 73} 
models.legs[15585] = { name = "assassins culottes +1" , model = 75} 
models.legs[15586] = { name = "valor breeches +1" , model = 77} 
models.legs[15587] = { name = "abyss flanchard +1" , model = 79} 
models.legs[15588] = { name = "monster trousers +1" , model = 81} 
models.legs[15589] = { name = "bards cannions +1" , model = 83} 
models.legs[15590] = { name = "scouts braccae +1" , model = 85} 
models.legs[15591] = { name = "saotome haidate +1" , model = 87} 
models.legs[15592] = { name = "koga hakama +1" , model = 89} 
models.legs[15593] = { name = "wyrm brais +1" , model = 91} 
models.legs[15594] = { name = "summoners spats +1" , model = 93} 
models.legs[15595] = { name = "hydra brais" , model = 16516} 
models.legs[15596] = { name = "hydra tights" , model = 16512} 
models.legs[15597] = { name = "hydra brayettes" , model = 16548} 
models.legs[15598] = { name = "hydra hose" , model = 16547} 
models.legs[15599] = { name = "bahamuts hose" , model = 23} 
models.legs[15600] = { name = "magus shalwar" , model = 16549} 
models.legs[15601] = { name = "corsair's culottes" , model = 16551} 
models.legs[15602] = { name = "pup. churidars" , model = 16553} 
models.legs[15603] = { name = "sipahi zerehs" , model = 171} 
models.legs[15604] = { name = "amir dirs" , model = 174} 
models.legs[15605] = { name = "jaridah salvars" , model = 172} 
models.legs[15606] = { name = "yigit seraweels" , model = 16560} 
models.legs[15607] = { name = "abtal zerehs" , model = 171} 
models.legs[15608] = { name = "akinji salvars" , model = 172} 
models.legs[15609] = { name = "pln. seraweels" , model = 16559} 
models.legs[15610] = { name = "sturdy trousers" , model = 1} 
models.legs[15611] = { name = "sturdy slacks" , model = 3} 
models.legs[15612] = { name = "strike subligar" , model = 56} 
models.legs[15613] = { name = "jet seraweels" , model = 176} 
models.legs[15614] = { name = "exorcist hose" , model = 5} 
models.legs[15615] = { name = "hydra cuisses" , model = 27} 
models.legs[15616] = { name = "hydra cuisses +1" , model = 27} 
models.legs[15617] = { name = "barbarossas zerehs" , model = 171} 
models.legs[15618] = { name = "vendors slops" , model = 149} 
models.legs[15619] = { name = "princes slops" , model = 149} 
models.legs[15620] = { name = "silken slops" , model = 19} 
models.legs[15621] = { name = "magi slops" , model = 19} 
models.legs[15622] = { name = "mercenarys trousers" , model = 57} 
models.legs[15623] = { name = "volunteers brais" , model = 132} 
models.legs[15624] = { name = "mercenarys subligar" , model = 14} 
models.legs[15625] = { name = "ares' flanchard" , model = 16566} 
models.legs[15626] = { name = "enyos cuisses" , model = 2} 
models.legs[15627] = { name = "phoboss cuisses" , model = 22} 
models.legs[15628] = { name = "deimoss cuisses" , model = 29} 
models.legs[15629] = { name = "skadi's chausses" , model = 16567} 
models.legs[15630] = { name = "njords trousers" , model = 109} 
models.legs[15631] = { name = "freyrs trousers" , model = 109} 
models.legs[15632] = { name = "freyas trousers" , model = 54} 
models.legs[15633] = { name = "usukane hizayoroi" , model = 16568} 
models.legs[15634] = { name = "hoshikazu hakama" , model = 4} 
models.legs[15635] = { name = "tsukikazu haidate" , model = 9} 
models.legs[15636] = { name = "hikazu hakama" , model = 141} 
models.legs[15637] = { name = "marduk's shalwar" , model = 16569} 
models.legs[15638] = { name = "anus brais" , model = 21} 
models.legs[15639] = { name = "eas brais" , model = 132} 
models.legs[15640] = { name = "enlils brayettes" , model = 164} 
models.legs[15641] = { name = "morrigan's slops" , model = 16570} 
models.legs[15642] = { name = "nemains slops" , model = 20} 
models.legs[15643] = { name = "bodbs slops" , model = 149} 
models.legs[15644] = { name = "machas slops" , model = 101} 
models.legs[15645] = { name = "khimaira kecks" , model = 134} 
models.legs[15646] = { name = "stout kecks" , model = 134} 
models.legs[15647] = { name = "askar dirs" , model = 195} 
models.legs[15648] = { name = "denali kecks" , model = 196} 
models.legs[15649] = { name = "goliard trews" , model = 197} 
models.legs[15650] = { name = "shock subligar" , model = 14} 
models.legs[15651] = { name = "ice trousers" , model = 7} 
models.legs[15652] = { name = "blaze hose" , model = 23} 
models.legs[15653] = { name = "tabin hose" , model = 23} 
models.legs[15654] = { name = "tabin hose +1" , model = 23} 
models.legs[15655] = { name = "shadow cuishes" , model = 16584} 
models.legs[15656] = { name = "valkyries cuishes" , model = 200} 
models.legs[15657] = { name = "shadow trews" , model = 16585} 
models.legs[15658] = { name = "valkyries trews" , model = 201} 
models.legs[15659] = { name = "dancer's tights" , model = 16594} 
models.legs[15660] = { name = "dancer's tights" , model = 16595} 
models.legs[16311] = { name = "scholar's pants" , model = 16598} 
models.legs[16312] = { name = "iron ram breeches" , model = 12} 
models.legs[16313] = { name = "fourth division cuisses" , model = 25} 
models.legs[16314] = { name = "cobra unit slops" , model = 19} 
models.legs[16315] = { name = "iron ram hose" , model = 221} 
models.legs[16316] = { name = "fourth schoss" , model = 16606} 
models.legs[16317] = { name = "cobra subligar" , model = 16603} 
models.legs[16318] = { name = "cobra trews" , model = 16604} 
models.legs[16319] = { name = "sangoma lappas" , model = 137} 
models.legs[16320] = { name = "kensei sitabaki" , model = 17} 
models.legs[16321] = { name = "custom trunks" , model = 16609} 
models.legs[16322] = { name = "custom shorts" , model = 225} 
models.legs[16323] = { name = "magna trunks" , model = 225} 
models.legs[16324] = { name = "magna shorts" , model = 225} 
models.legs[16325] = { name = "wonder trunks" , model = 16610} 
models.legs[16326] = { name = "wonder shorts" , model = 226} 
models.legs[16327] = { name = "savage shorts" , model = 225} 
models.legs[16328] = { name = "elder trunks" , model = 225} 
models.legs[16329] = { name = "custom trunks +1" , model = 225} 
models.legs[16330] = { name = "custom shorts +1" , model = 225} 
models.legs[16331] = { name = "magna trunks +1" , model = 225} 
models.legs[16332] = { name = "magna shorts +1" , model = 225} 
models.legs[16333] = { name = "wonder trunks +1" , model = 225} 
models.legs[16334] = { name = "wonder shorts +1" , model = 226} 
models.legs[16335] = { name = "savage shorts +1" , model = 225} 
models.legs[16336] = { name = "elder trunks +1" , model = 225} 
models.legs[16337] = { name = "hachiryu haidate" , model = 16611} 
models.legs[16338] = { name = "ruby seraweels" , model = 160} 
models.legs[16339] = { name = "paddock trousers" , model = 7} 
models.legs[16340] = { name = "armadillo cuisses" , model = 52} 
models.legs[16341] = { name = "aurum cuisses" , model = 139} 
models.legs[16342] = { name = "oracles braconi" , model = 143} 
models.legs[16343] = { name = "enkidus subligar" , model = 56} 
models.legs[16344] = { name = "oily trousers" , model = 6} 
models.legs[16345] = { name = "magus shalwar +1" , model = 165} 
models.legs[16346] = { name = "mirage shalwar" , model = 166} 
models.legs[16347] = { name = "mirage shalwar +1" , model = 166} 
models.legs[16348] = { name = "corsairs culottes +1" , model = 167} 
models.legs[16349] = { name = "commodore trews" , model = 168} 
models.legs[16350] = { name = "commodore trews +1" , model = 168} 
models.legs[16351] = { name = "puppetry churidars +1" , model = 169} 
models.legs[16352] = { name = "pantin churidars" , model = 170} 
models.legs[16353] = { name = "pantin churidars +1" , model = 170} 
models.legs[16354] = { name = "malagigis trousers" , model = 7} 
models.legs[16355] = { name = "bediveres hose" , model = 23} 
models.legs[16356] = { name = "nimues tights" , model = 129} 
models.legs[16357] = { name = "dancers tights +1" , model = 210} 
models.legs[16358] = { name = "dancers tights +1" , model = 211} 
models.legs[16359] = { name = "scholars pants +1" , model = 214} 
models.legs[16360] = { name = "etoile tights" , model = 304} 
models.legs[16361] = { name = "etoile tights +1" , model = 304} 
models.legs[16362] = { name = "argute pants" , model = 215} 
models.legs[16363] = { name = "argute pants +1" , model = 215} 
models.legs[16364] = { name = "benedight hose" , model = 16616} 
models.legs[16365] = { name = "argent hose" , model = 232} 
models.legs[16366] = { name = "platino hose" , model = 232} 
models.legs[16367] = { name = "phlegethons trousers" , model = 1} 
models.legs[16368] = { name = "herders subligar" , model = 15} 
models.legs[16369] = { name = "blitzer poleyn" , model = 16620} 
models.legs[16370] = { name = "desultor tassets" , model = 16621} 
models.legs[16371] = { name = "tatsu. sitagoromo" , model = 16622} 
models.legs[16372] = { name = "stearc subligar" , model = 32} 
models.legs[16373] = { name = "kyoshu sitabaki" , model = 17} 
models.legs[16374] = { name = "layqa seraweels" , model = 135} 
models.legs[16375] = { name = "surge subligar" , model = 110} 
models.legs[16376] = { name = "bahram cuisses" , model = 60} 
models.legs[16377] = { name = "kyoshu sitabaki +1" , model = 17} 
models.legs[16378] = { name = "dinner hose" , model = 16614} 
models.legs[16379] = { name = "inmicus cuisses" , model = 55} 
models.legs[16380] = { name = "entois trousers" , model = 7} 
models.legs[16381] = { name = "tumbler trunks" , model = 109} 
models.legs[16382] = { name = "adapas slacks" , model = 3} 
models.legs[16383] = { name = "mirador trousers" , model = 7} 
models.legs[23241] = { name = "pummelers cuisses +2" , model = 64} 
models.legs[23242] = { name = "anchorites hose +2" , model = 66} 
models.legs[23243] = { name = "theophany pantaloons +2" , model = 68} 
models.legs[23244] = { name = "spaekonas tonban +2" , model = 70} 
models.legs[23245] = { name = "atrophy tights +2" , model = 72} 
models.legs[23246] = { name = "pillagers culottes +2" , model = 74} 
models.legs[23247] = { name = "reverence breeches +2" , model = 76} 
models.legs[23248] = { name = "ignominy flanchard +2" , model = 78} 
models.legs[23249] = { name = "totemic trousers +2" , model = 80} 
models.legs[23250] = { name = "brioso cannions +2" , model = 82} 
models.legs[23251] = { name = "orion braccae +2" , model = 84} 
models.legs[23252] = { name = "wakido haidate +2" , model = 86} 
models.legs[23253] = { name = "hachiya hakama +2" , model = 88} 
models.legs[23254] = { name = "vishap brais +2" , model = 90} 
models.legs[23255] = { name = "convokers spats +2" , model = 92} 
models.legs[23256] = { name = "assimilators shalwar +2" , model = 165} 
models.legs[23257] = { name = "laksamanas trews +2" , model = 167} 
models.legs[23258] = { name = "foire churidars +2" , model = 169} 
models.legs[23259] = { name = "maxixi tights +2" , model = 211} 
models.legs[23260] = { name = "maxixi tights +2" , model = 211} 
models.legs[23261] = { name = "academics pants +2" , model = 214} 
models.legs[23262] = { name = "geomancy pants +2" , model = 308} 
models.legs[23263] = { name = "runeist trousers +2" , model = 338} 
models.legs[23264] = { name = "agoge cuisses +2" , model = 65} 
models.legs[23265] = { name = "hesychasts hose +2" , model = 67} 
models.legs[23266] = { name = "piety pantaloons +2" , model = 69} 
models.legs[23267] = { name = "archmages tonban +2" , model = 71} 
models.legs[23268] = { name = "vitiation tights +2" , model = 73} 
models.legs[23269] = { name = "plunderers culottes +2" , model = 75} 
models.legs[23270] = { name = "caballarius breeches +2" , model = 77} 
models.legs[23271] = { name = "fallens flanchard +2" , model = 79} 
models.legs[23272] = { name = "ankusa trousers +2" , model = 81} 
models.legs[23273] = { name = "bihu cannions +2" , model = 83} 
models.legs[23274] = { name = "arcadian braccae +2" , model = 85} 
models.legs[23275] = { name = "sakonji haidate +2" , model = 87} 
models.legs[23276] = { name = "mochizuki hakama +2" , model = 89} 
models.legs[23277] = { name = "pteroslaver brais +2" , model = 91} 
models.legs[23278] = { name = "glyphic spats +2" , model = 93} 
models.legs[23279] = { name = "luhlaza shalwar +2" , model = 166} 
models.legs[23280] = { name = "lanun trews +2" , model = 168} 
models.legs[23281] = { name = "pitre churidars +2" , model = 170} 
models.legs[23282] = { name = "horos tights +2" , model = 304} 
models.legs[23283] = { name = "pedagogy pants +2" , model = 215} 
models.legs[23284] = { name = "bagua pants +2" , model = 310} 
models.legs[23285] = { name = "futhark trousers +2" , model = 339} 
models.legs[23286] = { name = "boii cuisses +2" , model = 282 }
models.legs[23287] = { name = "bhikku hose +2" , model = 283 }
models.legs[23288] = { name = "ebers pant. +2" , model = 284 }
models.legs[23289] = { name = "wicce chausses +2" , model = 285 }
models.legs[23290] = { name = "leth. fuseau +2" , model = 286 }
models.legs[23291] = { name = "skulk. culottes +2" , model = 287 }
models.legs[23292] = { name = "chev. cuisses +2" , model = 288 }
models.legs[23293] = { name = "heath. flanchard +2" , model = 289 }
models.legs[23294] = { name = "nukumi quijotes +2" , model = 290 }
models.legs[23295] = { name = "fili rhingrave +2" , model = 291 }
models.legs[23296] = { name = "amini bragues +2" , model = 292 }
models.legs[23297] = { name = "kasuga haidate +2" , model = 293 }
models.legs[23298] = { name = "hattori hakama +2" , model = 294 }
models.legs[23299] = { name = "pelt. cuissots +2" , model = 295 }
models.legs[23300] = { name = "beck. spats +2" , model = 296 }
models.legs[23301] = { name = "hashishin tayt +2" , model = 297 }
models.legs[23302] = { name = "chas. culottes +2" , model = 298 }
models.legs[23303] = { name = "karagoz pantaloni +2" , model = 299} 
models.legs[23304] = { name = "maculele tights +2" , model = 305 }
models.legs[23305] = { name = "arbatel pants +2" , model = 306 }
models.legs[23306] = { name = "azimuth tights +2" , model = 341 }
models.legs[23307] = { name = "eri. leg guards +2" , model = 371 }
models.legs[23576] = { name = "pummelers cuisses +3" , model = 64} 
models.legs[23577] = { name = "anchorites hose +3" , model = 66} 
models.legs[23578] = { name = "theophany pantaloons +3" , model = 68} 
models.legs[23579] = { name = "spaekonas tonban +3" , model = 70} 
models.legs[23580] = { name = "atrophy tights +3" , model = 72} 
models.legs[23581] = { name = "pillagers culottes +3" , model = 74} 
models.legs[23582] = { name = "reverence breeches +3" , model = 76} 
models.legs[23583] = { name = "ignominy flanchard +3" , model = 78} 
models.legs[23584] = { name = "totemic trousers +3" , model = 80} 
models.legs[23585] = { name = "brioso cannions +3" , model = 82} 
models.legs[23586] = { name = "orion braccae +3" , model = 84} 
models.legs[23587] = { name = "wakido haidate +3" , model = 86} 
models.legs[23588] = { name = "hachiya hakama +3" , model = 88} 
models.legs[23589] = { name = "vishap brais +3" , model = 90} 
models.legs[23590] = { name = "convokers spats +3" , model = 92} 
models.legs[23591] = { name = "assimilators shalwar +3" , model = 165} 
models.legs[23592] = { name = "laksamanas trews +3" , model = 167} 
models.legs[23593] = { name = "foire churidars +3" , model = 169} 
models.legs[23594] = { name = "maxixi tights +3" , model = 211} 
models.legs[23595] = { name = "maxixi tights +3" , model = 211} 
models.legs[23596] = { name = "academics pants +3" , model = 214} 
models.legs[23597] = { name = "geomancy pants +3" , model = 308} 
models.legs[23598] = { name = "runeist trousers +3" , model = 338} 
models.legs[23599] = { name = "agoge cuisses +3" , model = 65} 
models.legs[23600] = { name = "hesychasts hose +3" , model = 67} 
models.legs[23601] = { name = "piety pantaloons +3" , model = 69} 
models.legs[23602] = { name = "archmages tonban +3" , model = 71} 
models.legs[23603] = { name = "vitiation tights +3" , model = 73} 
models.legs[23604] = { name = "plunderers culottes +3" , model = 75} 
models.legs[23605] = { name = "caballarius breeches +3" , model = 77} 
models.legs[23606] = { name = "fallens flanchard +3" , model = 79} 
models.legs[23607] = { name = "ankusa trousers +3" , model = 81} 
models.legs[23608] = { name = "bihu cannions +3" , model = 83} 
models.legs[23609] = { name = "arcadian braccae +3" , model = 85} 
models.legs[23610] = { name = "sakonji haidate +3" , model = 87} 
models.legs[23611] = { name = "mochizuki hakama +3" , model = 89} 
models.legs[23612] = { name = "pteroslaver brais +3" , model = 91} 
models.legs[23613] = { name = "glyphic spats +3" , model = 93} 
models.legs[23614] = { name = "luhlaza shalwar +3" , model = 166} 
models.legs[23615] = { name = "lanun trews +3" , model = 168} 
models.legs[23616] = { name = "pitre churidars +3" , model = 170} 
models.legs[23617] = { name = "horos tights +3" , model = 304} 
models.legs[23618] = { name = "pedagogy pants +3" , model = 215} 
models.legs[23619] = { name = "bagua pants +3" , model = 310} 
models.legs[23620] = { name = "futhark trousers +3" , model = 339} 
models.legs[23621] = { name = "boii cuisses +3" , model = 282 }
models.legs[23622] = { name = "bhikku hose +3" , model = 283 }
models.legs[23623] = { name = "ebers pant. +3" , model = 284 }
models.legs[23624] = { name = "wicce chausses +3" , model = 285 }
models.legs[23625] = { name = "leth. fuseau +3" , model = 286 }
models.legs[23626] = { name = "skulk. culottes +3" , model = 287 }
models.legs[23627] = { name = "chev. cuisses +3" , model = 288 }
models.legs[23628] = { name = "heath. flanchard +3" , model = 289 }
models.legs[23629] = { name = "nukumi quijotes +3" , model = 290 }
models.legs[23630] = { name = "fili rhingrave +3" , model = 291 }
models.legs[23631] = { name = "amini bragues +3" , model = 292 }
models.legs[23632] = { name = "kasuga haidate +3" , model = 293 }
models.legs[23633] = { name = "hattori hakama +3" , model = 294 }
models.legs[23634] = { name = "pelt. cuissots +3" , model = 295 }
models.legs[23635] = { name = "beck. spats +3" , model = 296 }
models.legs[23636] = { name = "hashishin tayt +3" , model = 297 }
models.legs[23637] = { name = "chas. culottes +3" , model = 298 }
models.legs[23638] = { name = "kara. pantaloni +3" , model = 299 }
models.legs[23639] = { name = "maculele tights +3" , model = 305 }
models.legs[23640] = { name = "arbatel pants +3" , model = 306 }
models.legs[23641] = { name = "azimuth tights +3" , model = 341 }
models.legs[23642] = { name = "eri. leg guards +3" , model = 371 }
models.legs[23722] = { name = "volte brais" , model = 132} 
models.legs[23723] = { name = "volte tights" , model = 128} 
models.legs[23724] = { name = "volte brayettes" , model = 164} 
models.legs[23725] = { name = "volte hose" , model = 163} 
models.legs[23735] = { name = "malignance tights" , model = 458} 
models.legs[23747] = { name = "hervor brayettes" , model = 276} 
models.legs[23748] = { name = "heidrek brais" , model = 252} 
models.legs[23749] = { name = "angantyr tights" , model = 267} 
models.legs[23776] = { name = "ikengas trousers" , model = 464} 
models.legs[23777] = { name = "gleti's breeches" , model = 465 }
models.legs[23778] = { name = "sakpatas cuisses" , model = 466} 
models.legs[23779] = { name = "mpacas hose" , model = 467} 
models.legs[23780] = { name = "agwus slops" , model = 468} 
models.legs[23781] = { name = "bunzis pants" , model = 469} 
models.legs[23782] = { name = "nyame flanchard" , model = 470} 
models.legs[23795] = { name = "ziamet salvars" , model = 474} 
models.legs[23809] = { name = "esthetes hose" , model = 480} 
models.legs[23815] = { name = "sapphire trousers" , model = 483 }
models.legs[23820] = { name = "jadeite chausses" , model = 484 }
models.legs[23825] = { name = "diamond hiza." , model = 485 }
models.legs[23830] = { name = "emerald shalwar" , model = 486 }
models.legs[23835] = { name = "ruby slops" , model = 487 }
models.legs[23840] = { name = "apathy brais" , model = 16875} 
models.legs[23844] = { name = "rage brais" , model = 16878} 
models.legs[23849] = { name = "cowardice tonban" , model = 16876} 
models.legs[23854] = { name = "envy flanchard" , model = 16877} 
models.legs[23859] = { name = "arrogance brais" , model = 16874} 
models.legs[23872] = { name = "hebenus boxers" , model = 495 }
models.legs[23874] = { name = "hebenus shorts" , model = 496 }
models.legs[23893] = { name = "dhalmel trousers" , model = 498 }
models.legs[24030] = { name = "pumm. cuisses +4" , model = 64 }
models.legs[24031] = { name = "anch. hose +4" , model = 66 }
models.legs[24032] = { name = "theo. pant. +4" , model = 68 }
models.legs[24033] = { name = "spae. tonban +4" , model = 70 }
models.legs[24034] = { name = "atro. tights +4" , model = 72 }
models.legs[24035] = { name = "pill. culottes +4" , model = 74 }
models.legs[24036] = { name = "rev. breeches +4" , model = 76 }
models.legs[24037] = { name = "ig. flanchard +4" , model = 78 }
models.legs[24038] = { name = "tot. trousers +4" , model = 80 }
models.legs[24039] = { name = "brios. cann. +4" , model = 82 }
models.legs[24040] = { name = "orion braccae +4" , model = 84 }
models.legs[24041] = { name = "wakido haidate +4" , model = 86 }
models.legs[24042] = { name = "hachiya hakama +4" , model = 88 }
models.legs[24043] = { name = "vishap brais +4" , model = 90 }
models.legs[24044] = { name = "con. spats +4" , model = 92 }
models.legs[24045] = { name = "assim. shalwar +4" , model = 165 }
models.legs[24046] = { name = "laksa. trews +4" , model = 167 }
models.legs[24047] = { name = "foire churidars +4" , model = 169 }
models.legs[24048] = { name = "maxixi tights +4" , model = 211 }
models.legs[24049] = { name = "maxixi tights +4" , model = 211 }
models.legs[24050] = { name = "acad. pants +4" , model = 214 }
models.legs[24051] = { name = "geo. pants +4" , model = 308 }
models.legs[24052] = { name = "rune. trousers +4" , model = 338 }
models.legs[24053] = { name = "agoge cuisses +4" , model = 65 }
models.legs[24054] = { name = "hesy. hose +4" , model = 67 }
models.legs[24055] = { name = "piety panta. +4" , model = 69 }
models.legs[24056] = { name = "arch. tonban +4" , model = 71 }
models.legs[24057] = { name = "viti. tights +4" , model = 73 }
models.legs[24058] = { name = "plun. culottes +4" , model = 75 }
models.legs[24059] = { name = "cab. breeches +4" , model = 77 }
models.legs[24060] = { name = "fall. flanchard +4" , model = 79 }
models.legs[24061] = { name = "an. trousers +4" , model = 81 }
models.legs[24062] = { name = "bihu cann. +4" , model = 83 }
models.legs[24063] = { name = "arc. braccae +4" , model = 85 }
models.legs[24064] = { name = "sakonji haidate +4" , model = 87 }
models.legs[24065] = { name = "mochi. hakama +4" , model = 89 }
models.legs[24066] = { name = "ptero. brais +4" , model = 91 }
models.legs[24067] = { name = "glyph. spats +4" , model = 93 }
models.legs[24068] = { name = "luh. shalwar +4" , model = 166 }
models.legs[24069] = { name = "lanun trews +4" , model = 168 }
models.legs[24070] = { name = "pitre churidars +4" , model = 170 }
models.legs[24071] = { name = "horos tights +4" , model = 304 }
models.legs[24072] = { name = "peda. pants +4" , model = 215 }
models.legs[24073] = { name = "bagua pants +4" , model = 310 }
models.legs[24074] = { name = "futh. trousers +4" , model = 339 }
models.legs[24129] = { name = "hope brais" , model = 513 }
models.legs[24130] = { name = "perfection brais" , model = 513 }
models.legs[24131] = { name = "revelation brais", model = 513}
models.legs[24144] = { name = "trust brais" , model = 514 }
models.legs[24145] = { name = "prestige brais" , model = 514 }
models.legs[24146] = { name = "sworn brais" , model = 514 }
models.legs[24159] = { name = "bravery tonban" , model = 515 }
models.legs[24160] = { name = "intrep. tonban" , model = 515 }
models.legs[24161] = { name = "indom. tonban" , model = 515 }
models.legs[24174] = { name = "just. flanchard" , model = 516 }
models.legs[24175] = { name = "magnif. flan." , model = 516 }
models.legs[24176] = { name = "duty flanchard" , model = 516 }
models.legs[24189] = { name = "mercy haidate" , model = 517 }
models.legs[24190] = { name = "grace haidate" , model = 517 }
models.legs[24191] = { name = "clem. haidate" , model = 517 }
-- models.legs[24204] = { name = "apathy cuisses" , model = 'XXXXXX' }
-- models.legs[24205] = { name = "defeat cuisses" , model = 'XXXXXX' }
-- models.legs[24206] = { name = "igno. cuisses" , model = 'XXXXXX' }
-- models.legs[24219] = { name = "arro. trousers" , model = 'XXXXXX' }
-- models.legs[24220] = { name = "brav. trousers" , model = 'XXXXXX' }
-- models.legs[24221] = { name = "irrev. trousers" , model = 'XXXXXX' }
-- models.legs[24234] = { name = "coward. wai." , model = 'XXXXXX' }
-- models.legs[24235] = { name = "noth. wai." , model = 'XXXXXX' }
-- models.legs[24236] = { name = "despair wai." , model = 'XXXXXX' }
-- models.legs[24249] = { name = "envy breeches" , model = 'XXXXXX' }
-- models.legs[24250] = { name = "jeal. breeches" , model = 'XXXXXX' }
-- models.legs[24251] = { name = "resent. breeches" , model = 'XXXXXX' }
-- models.legs[24264] = { name = "rage guards" , model = 'XXXXXX' }
-- models.legs[24265] = { name = "hatred guards" , model = 'XXXXXX' }
-- models.legs[24266] = { name = "wrath guards" , model = 'XXXXXX' }
models.legs[24290] = { name = "cs slacks +1" , model = 16414 }
models.legs[24291] = { name = "cs pants +1" , model = 31 }
models.legs[24292] = { name = "mgm chausses +1" , model = 31 }
models.legs[24293] = { name = "mgf chausses +1" , model = 31 }
models.legs[24294] = { name = "wn braccae +1" , model = 31 }
models.legs[24295] = { name = "sv loincloth +1" , model = 31 }
models.legs[24296] = { name = "el braguette +1" , model = 31 }
models.legs[25838] = { name = "fancy trunks" , model = 447} 
models.legs[25839] = { name = "fancy shorts" , model = 448} 
models.legs[25840] = { name = "odyssean cuisses" , model = 412} 
models.legs[25841] = { name = "valorous hose" , model = 413} 
models.legs[25842] = { name = "herculean trousers" , model = 580} 
models.legs[25843] = { name = "merlinic shalwar" , model = 415} 
models.legs[25844] = { name = "chironic hose" , model = 416} 
models.legs[25849] = { name = "dashing subligar" , model = 423} 
models.legs[25850] = { name = "pretty pink subligar" , model = 453} 
-- models.legs[25851] = { name = "ashen subligar" , model = 'XXXXXX' }
models.legs[25852] = { name = "darraigners brais" , model = 350} 
models.legs[25853] = { name = "querkening brais" , model = 223} 
models.legs[25854] = { name = "arjuna breeches" , model = 328} 
models.legs[25855] = { name = "tatenashi haidate" , model = 227} 
models.legs[25856] = { name = "tatenashi haidate +1" , model = 227} 
models.legs[25857] = { name = "ilm lappas" , model = 16827} 
models.legs[25858] = { name = "sulevias cuisses" , model = 182} 
models.legs[25859] = { name = "sulevias cuisses +1" , model = 182} 
models.legs[25860] = { name = "meghanada chausses" , model = 183} 
models.legs[25861] = { name = "meghanada chausses +1" , model = 183} 
models.legs[25862] = { name = "hizamaru hizayoroi" , model = 184} 
models.legs[25863] = { name = "hizamaru hizayoroi +1" , model = 184} 
models.legs[25864] = { name = "stinky subligar" , model = 14} 
models.legs[25865] = { name = "inyanga shalwar" , model = 185} 
models.legs[25866] = { name = "inyanga shalwar +1" , model = 185} 
models.legs[25867] = { name = "jhakri slops" , model = 186} 
models.legs[25868] = { name = "jhakri slops +1" , model = 186} 
models.legs[25869] = { name = "ayanmo cosciales" , model = 159} 
models.legs[25870] = { name = "ayanmo cosciales +1" , model = 159} 
models.legs[25871] = { name = "taliah seraweels" , model = 160} 
models.legs[25872] = { name = "taliah seraweels +1" , model = 160} 
models.legs[25873] = { name = "flamma dirs" , model = 195} 
models.legs[25874] = { name = "flamma dirs +1" , model = 195} 
models.legs[25875] = { name = "mummu kecks" , model = 196} 
models.legs[25876] = { name = "mummu kecks +1" , model = 196} 
models.legs[25877] = { name = "mallquis trews" , model = 197} 
models.legs[25878] = { name = "mallquis trews +1" , model = 197} 
models.legs[25879] = { name = "sulevias cuisses +2" , model = 182} 
models.legs[25880] = { name = "meghanada chausses +2" , model = 183} 
models.legs[25881] = { name = "hizamaru hizayoroi +2" , model = 184} 
models.legs[25882] = { name = "inyanga shalwar +2" , model = 185} 
models.legs[25883] = { name = "jhakri slops +2" , model = 186} 
models.legs[25884] = { name = "ayanmo cosciales +2" , model = 159} 
models.legs[25885] = { name = "taliah seraweels +2" , model = 160} 
models.legs[25886] = { name = "flamma dirs +2" , model = 195} 
models.legs[25887] = { name = "mummu kecks +2" , model = 196} 
models.legs[25888] = { name = "mallquis trews +2" , model = 197} 
models.legs[25889] = { name = "oshosi trousers" , model = 109} 
models.legs[25890] = { name = "oshosi trousers +1" , model = 109} 
models.legs[25891] = { name = "kendatsuba hakama" , model = 61} 
models.legs[25892] = { name = "kendatsuba hakama +1" , model = 61} 
models.legs[25893] = { name = "ea slops" , model = 101} 
models.legs[25894] = { name = "ea slops +1" , model = 101} 
models.legs[25895] = { name = "ratri cuisses" , model = 151} 
models.legs[25896] = { name = "ratri cuisses +1" , model = 151} 
models.legs[25897] = { name = "arke cosciales" , model = 136} 
models.legs[25898] = { name = "arke cosciales +1" , model = 136} 
models.legs[25899] = { name = "pinga pants" , model = 57} 
models.legs[25900] = { name = "pinga pants +1" , model = 57} 
models.legs[25901] = { name = "mousai seraweels" , model = 135} 
models.legs[25902] = { name = "mousai seraweels +1" , model = 135} 
models.legs[25903] = { name = "heyoka subligar" , model = 110} 
models.legs[25904] = { name = "heyoka subligar +1" , model = 110} 
models.legs[25905] = { name = "baayami slops" , model = 115} 
models.legs[25906] = { name = "baayami slops +1" , model = 115} 
models.legs[25907] = { name = "turms subligar" , model = 148} 
models.legs[25908] = { name = "turms subligar +1" , model = 148} 
models.legs[25909] = { name = "morbol subligar" , model = 461} 
models.legs[25910] = { name = "cait sith subligar" , model = 463} 
models.legs[25911] = { name = "denim pants" , model = 479} 
models.legs[25912] = { name = "denim pants +1" , model = 479 }
models.legs[27152] = { name = "agoge cuisses" , model = 65} 
models.legs[27153] = { name = "agoge cuisses +1" , model = 65} 
models.legs[27154] = { name = "hesychasts hose" , model = 67} 
models.legs[27155] = { name = "hesychasts hose +1" , model = 67} 
models.legs[27156] = { name = "piety pantaloons" , model = 69} 
models.legs[27157] = { name = "piety pantaloons +1" , model = 69} 
models.legs[27158] = { name = "archmages tonban" , model = 71} 
models.legs[27159] = { name = "archmages tonban +1" , model = 71} 
models.legs[27160] = { name = "vitiation tights" , model = 73} 
models.legs[27161] = { name = "vitiation tights +1" , model = 73} 
models.legs[27162] = { name = "plunderers culottes" , model = 75} 
models.legs[27163] = { name = "plunderers culottes +1" , model = 75} 
models.legs[27164] = { name = "caballarius breeches" , model = 77} 
models.legs[27165] = { name = "caballarius breeches +1" , model = 77} 
models.legs[27166] = { name = "fallens flanchard" , model = 79} 
models.legs[27167] = { name = "fallens flanchard +1" , model = 79} 
models.legs[27168] = { name = "ankusa trousers" , model = 81} 
models.legs[27169] = { name = "ankusa trousers +1" , model = 81} 
models.legs[27170] = { name = "bihu cannions" , model = 83} 
models.legs[27171] = { name = "bihu cannions +1" , model = 83} 
models.legs[27172] = { name = "arcadian braccae" , model = 85} 
models.legs[27173] = { name = "arcadian braccae +1" , model = 85} 
models.legs[27174] = { name = "sakonji haidate" , model = 87} 
models.legs[27175] = { name = "sakonji haidate +1" , model = 87} 
models.legs[27176] = { name = "mochizuki hakama" , model = 89} 
models.legs[27177] = { name = "mochizuki hakama +1" , model = 89} 
models.legs[27178] = { name = "pteroslaver brais" , model = 91} 
models.legs[27179] = { name = "pteroslaver brais +1" , model = 91} 
models.legs[27180] = { name = "glyphic spats" , model = 93} 
models.legs[27181] = { name = "glyphic spats +1" , model = 93} 
models.legs[27182] = { name = "luhlaza shalwar" , model = 166} 
models.legs[27183] = { name = "luhlaza shalwar +1" , model = 166} 
models.legs[27184] = { name = "lanun trews" , model = 168} 
models.legs[27185] = { name = "lanun trews +1" , model = 168} 
models.legs[27186] = { name = "pitre churidars" , model = 170} 
models.legs[27187] = { name = "pitre churidars +1" , model = 170} 
models.legs[27188] = { name = "horos tights" , model = 304} 
models.legs[27189] = { name = "horos tights +1" , model = 304} 
models.legs[27190] = { name = "pedagogy pants" , model = 215} 
models.legs[27191] = { name = "pedagogy pants +1" , model = 215} 
models.legs[27192] = { name = "bagua pants" , model = 310} 
models.legs[27193] = { name = "bagua pants +1" , model = 310} 
models.legs[27194] = { name = "futhark trousers" , model = 339} 
models.legs[27195] = { name = "futhark trousers +1" , model = 339} 
models.legs[27196] = { name = "lustratio subligar" , model = 100} 
models.legs[27197] = { name = "lustratio subligar +1" , model = 100} 
models.legs[27198] = { name = "souveran diechlings" , model = 95} 
models.legs[27199] = { name = "souveran diechlings +1" , model = 95} 
models.legs[27200] = { name = "argosy breeches" , model = 63} 
models.legs[27201] = { name = "argosy breeches +1" , model = 63} 
models.legs[27202] = { name = "rao haidate" , model = 106} 
models.legs[27203] = { name = "rao haidate +1" , model = 106} 
models.legs[27204] = { name = "apogee slacks" , model = 107} 
models.legs[27205] = { name = "apogee slacks +1" , model = 107} 
models.legs[27206] = { name = "carmine cuisses" , model = 62} 
models.legs[27207] = { name = "carmine cuisses +1" , model = 62} 
models.legs[27208] = { name = "bewitched subligar" , model = 100} 
models.legs[27209] = { name = "voodoo subligar" , model = 100} 
models.legs[27210] = { name = "bewitched diechlings" , model = 95} 
models.legs[27211] = { name = "voodoo diechlings" , model = 95} 
models.legs[27212] = { name = "bewitched breeches" , model = 63} 
models.legs[27213] = { name = "voodoo breeches" , model = 63} 
models.legs[27214] = { name = "bewitched haidate" , model = 106} 
models.legs[27215] = { name = "voodoo haidate" , model = 106} 
models.legs[27216] = { name = "bewitched slacks" , model = 107} 
models.legs[27217] = { name = "voodoo slacks" , model = 107} 
models.legs[27218] = { name = "bewitched cuisses" , model = 62} 
models.legs[27219] = { name = "voodoo cuisses" , model = 62} 
models.legs[27220] = { name = "miasmic pants" , model = 381} 
models.legs[27221] = { name = "avatara slops" , model = 20} 
models.legs[27222] = { name = "limbo trousers" , model = 327} 
models.legs[27223] = { name = "feast hose" , model = 365} 
models.legs[27224] = { name = "gefechtdiechlings" , model = 138} 
models.legs[27225] = { name = "wildheitdiechlings" , model = 138} 
models.legs[27226] = { name = "sombra tights" , model = 129} 
models.legs[27227] = { name = "sombra tights +1" , model = 129} 
models.legs[27228] = { name = "revealers pants" , model = 99} 
models.legs[27229] = { name = "revealers pants +1" , model = 99} 
models.legs[27230] = { name = "zoar subligar" , model = 216} 
models.legs[27231] = { name = "zoar subligar +1" , model = 216} 
models.legs[27232] = { name = "yorium cuisses" , model = 55} 
models.legs[27233] = { name = "acro breeches" , model = 325} 
models.legs[27234] = { name = "taeon tights" , model = 326} 
models.legs[27235] = { name = "telchine braconi" , model = 143} 
models.legs[27236] = { name = "helios spats" , model = 327} 
models.legs[27237] = { name = "boii cuisses" , model = 282} 
models.legs[27238] = { name = "boii cuisses +1" , model = 282} 
models.legs[27239] = { name = "bhikku hose" , model = 283} 
models.legs[27240] = { name = "bhikku hose +1" , model = 283} 
models.legs[27241] = { name = "ebers pantaloons" , model = 284} 
models.legs[27242] = { name = "ebers pantaloons +1" , model = 284} 
models.legs[27243] = { name = "wicce chausses" , model = 285} 
models.legs[27244] = { name = "wicce chausses +1" , model = 285} 
models.legs[27245] = { name = "lethargy fuseau" , model = 286} 
models.legs[27246] = { name = "lethargy fuseau +1" , model = 286} 
models.legs[27247] = { name = "skulkers culottes" , model = 287} 
models.legs[27248] = { name = "skulkers culottes +1" , model = 287} 
models.legs[27249] = { name = "chevaliers cuisses" , model = 288} 
models.legs[27250] = { name = "chevaliers cuisses +1" , model = 288} 
models.legs[27251] = { name = "heathens flanchard" , model = 289} 
models.legs[27252] = { name = "heathens flanchard +1" , model = 289} 
models.legs[27253] = { name = "nukumi quijotes" , model = 290} 
models.legs[27254] = { name = "nukumi quijotes +1" , model = 290} 
models.legs[27255] = { name = "fili rhingrave" , model = 291} 
models.legs[27256] = { name = "fili rhingrave +1" , model = 291} 
models.legs[27257] = { name = "amini bragues" , model = 292} 
models.legs[27258] = { name = "amini bragues +1" , model = 292} 
models.legs[27259] = { name = "kasuga haidate" , model = 293} 
models.legs[27260] = { name = "kasuga haidate +1" , model = 293} 
models.legs[27261] = { name = "hattori hakama" , model = 294} 
models.legs[27262] = { name = "hattori hakama +1" , model = 294} 
models.legs[27263] = { name = "peltasts cuissots" , model = 295} 
models.legs[27264] = { name = "peltasts cuissots +1" , model = 295} 
models.legs[27265] = { name = "beckoners spats" , model = 296} 
models.legs[27266] = { name = "beckoners spats +1" , model = 296} 
models.legs[27267] = { name = "hashishin tayt" , model = 297} 
models.legs[27268] = { name = "hashishin tayt +1" , model = 297} 
models.legs[27269] = { name = "chasseurs culottes" , model = 298} 
models.legs[27270] = { name = "chasseurs culottes +1" , model = 298} 
models.legs[27271] = { name = "karagoz pantaloni" , model = 299} 
models.legs[27272] = { name = "karagoz pantaloni +1" , model = 299} 
models.legs[27273] = { name = "maculele tights" , model = 305} 
models.legs[27274] = { name = "maculele tights +1" , model = 305} 
models.legs[27275] = { name = "arbatel pants" , model = 306} 
models.legs[27276] = { name = "arbatel pants +1" , model = 306} 
models.legs[27277] = { name = "azimuth tights" , model = 341} 
models.legs[27278] = { name = "azimuth tights +1" , model = 341} 
models.legs[27279] = { name = "erilaz leg guards" , model = 371} 
models.legs[27280] = { name = "erilaz leg guards +1" , model = 371} 
models.legs[27281] = { name = "pupils trousers" , model = 577} 
models.legs[27282] = { name = "eschite cuisses" , model = 392} 
models.legs[27283] = { name = "despair cuisses" , model = 389} 
models.legs[27284] = { name = "naga hakama" , model = 394} 
models.legs[27285] = { name = "rawhide trousers" , model = 393} 
models.legs[27286] = { name = "pursuers pants" , model = 390} 
models.legs[27287] = { name = "psycloth lappas" , model = 391} 
models.legs[27288] = { name = "vanya slops" , model = 395} 
models.legs[27289] = { name = "doyen pants" , model = 209} 
models.legs[27291] = { name = "swimming togs" , model = 404} 
models.legs[27292] = { name = "swimming togs +1" , model = 404} 
models.legs[27293] = { name = "cossie bottom" , model = 405} 
models.legs[27294] = { name = "cossie bottom +1" , model = 405} 
models.legs[27295] = { name = "samnuha tights" , model = 401} 
models.legs[27296] = { name = "agent pants" , model = 407} 
models.legs[27297] = { name = "starlet skirt" , model = 408} 
models.legs[27298] = { name = "emicho hose" , model = 323} 
models.legs[27299] = { name = "emicho hose +1" , model = 323} 
models.legs[27300] = { name = "ryuo hakama" , model = 324} 
models.legs[27301] = { name = "ryuo hakama +1" , model = 324} 
models.legs[27302] = { name = "adhemar kecks" , model = 320} 
models.legs[27303] = { name = "adhemar kecks +1" , model = 320} 
models.legs[27304] = { name = "amalric slops" , model = 322} 
models.legs[27305] = { name = "amalric slops +1" , model = 322} 
models.legs[27306] = { name = "kaykaus tights" , model = 321} 
models.legs[27307] = { name = "kaykaus tights +1" , model = 321} 
models.legs[27308] = { name = "vexed hose" , model = 323} 
models.legs[27309] = { name = "jinxed hose" , model = 323} 
models.legs[27310] = { name = "vexed hakama" , model = 324} 
models.legs[27311] = { name = "jinxed hakama" , model = 324} 
models.legs[27312] = { name = "vexed kecks" , model = 320} 
models.legs[27313] = { name = "jinxed kecks" , model = 320} 
models.legs[27314] = { name = "vexed slops" , model = 322} 
models.legs[27315] = { name = "jinxed slops" , model = 322} 
models.legs[27316] = { name = "vexed tights" , model = 321} 
models.legs[27317] = { name = "jinxed tights" , model = 321} 
models.legs[27318] = { name = "jokushu haidate" , model = 99} 
models.legs[27319] = { name = "obatala subligar" , model = 389} 
models.legs[27320] = { name = "selvans subligar" , model = 207} 
models.legs[27321] = { name = "lengo pants" , model = 344} 
models.legs[27322] = { name = "talab trousers" , model = 231} 
models.legs[27323] = { name = "enticers pants" , model = 356} 
models.legs[27324] = { name = "gyve trousers" , model = 410} 
models.legs[27325] = { name = "track pants" , model = 579} 
models.legs[27326] = { name = "track pants +1" , model = 579} 
models.legs[28068] = { name = "abatteur subligar" , model = 168} 
models.legs[28069] = { name = "pungas slops" , model = 115} 
models.legs[28070] = { name = "briscard cuisses" , model = 139} 
models.legs[28071] = { name = "ares flanchard +1" , model = 182} 
models.legs[28072] = { name = "skadis chausses +1" , model = 183} 
models.legs[28073] = { name = "usukane hizayoroi +1" , model = 184} 
models.legs[28074] = { name = "marduks shalwar +1" , model = 185} 
models.legs[28075] = { name = "morrigans slops +1" , model = 186} 
models.legs[28076] = { name = "kers flanchard" , model = 182} 
models.legs[28077] = { name = "sigyns chausses" , model = 183} 
models.legs[28078] = { name = "omodaka hizayoroi" , model = 184} 
models.legs[28079] = { name = "nabus shalwar" , model = 185} 
models.legs[28080] = { name = "feas slops" , model = 186} 
models.legs[28081] = { name = "ates flanchard" , model = 22} 
models.legs[28082] = { name = "idis trousers" , model = 7} 
models.legs[28083] = { name = "genta-no-hakama" , model = 9} 
models.legs[28084] = { name = "namrus shalwar" , model = 23} 
models.legs[28085] = { name = "neits slops" , model = 45} 
models.legs[28086] = { name = "rustic trunks" , model = 16742} 
models.legs[28087] = { name = "shoal trunks" , model = 16743} 
models.legs[28088] = { name = "rustic trunks +1" , model = 16742 }
models.legs[28089] = { name = "shoal trunks +1" , model = 16743 }
models.legs[28090] = { name = "pummelers cuisses" , model = 64} 
models.legs[28091] = { name = "anchorites hose" , model = 66} 
models.legs[28092] = { name = "theophany pantaloons" , model = 68} 
models.legs[28093] = { name = "spaekonas tonban" , model = 70} 
models.legs[28094] = { name = "atrophy tights" , model = 72} 
models.legs[28095] = { name = "pillagers culottes" , model = 74} 
models.legs[28096] = { name = "reverence breeches" , model = 76} 
models.legs[28097] = { name = "ignominy flanchard" , model = 78} 
models.legs[28098] = { name = "totemic trousers" , model = 80} 
models.legs[28099] = { name = "brioso cannions" , model = 82} 
models.legs[28100] = { name = "orion braccae" , model = 84} 
models.legs[28101] = { name = "wakido haidate" , model = 86} 
models.legs[28102] = { name = "hachiya hakama" , model = 88} 
models.legs[28103] = { name = "vishap brais" , model = 90} 
models.legs[28104] = { name = "convokers spats" , model = 92} 
models.legs[28105] = { name = "assimilators shalwar" , model = 165} 
models.legs[28106] = { name = "laksamanas trews" , model = 167} 
models.legs[28107] = { name = "foire churidars" , model = 169} 
models.legs[28108] = { name = "maxixi tights" , model = 211} 
models.legs[28109] = { name = "maxixi tights" , model = 211} 
models.legs[28110] = { name = "academics pants" , model = 214} 
models.legs[28111] = { name = "pummelers cuisses +1" , model = 64} 
models.legs[28112] = { name = "anchorites hose +1" , model = 66} 
models.legs[28113] = { name = "theophany pantaloons +1" , model = 68} 
models.legs[28114] = { name = "spaekonas tonban +1" , model = 70} 
models.legs[28115] = { name = "atrophy tights +1" , model = 72} 
models.legs[28116] = { name = "pillagers culottes +1" , model = 74} 
models.legs[28117] = { name = "reverence breeches +1" , model = 76} 
models.legs[28118] = { name = "ignominy flanchard +1" , model = 78} 
models.legs[28119] = { name = "totemic trousers +1" , model = 80} 
models.legs[28120] = { name = "brioso cannions +1" , model = 82} 
models.legs[28121] = { name = "orion braccae +1" , model = 84} 
models.legs[28122] = { name = "wakido haidate +1" , model = 86} 
models.legs[28123] = { name = "hachiya hakama +1" , model = 88} 
models.legs[28124] = { name = "vishap brais +1" , model = 90} 
models.legs[28125] = { name = "convokers spats +1" , model = 92} 
models.legs[28126] = { name = "assimilators shalwar +1" , model = 165} 
models.legs[28127] = { name = "laksamanas trews +1" , model = 167} 
models.legs[28128] = { name = "foire churidars +1" , model = 169} 
models.legs[28129] = { name = "maxixi tights +1" , model = 211} 
models.legs[28130] = { name = "maxixi tights +1" , model = 211} 
models.legs[28131] = { name = "academics pants +1" , model = 214} 
models.legs[28132] = { name = "geo. pants +1" , model = 16723 }
models.legs[28133] = { name = "rune. trousers +1" , model = 16722 }
models.legs[28134] = { name = "assiduity pants" , model = 114} 
models.legs[28135] = { name = "assiduity pants +1" , model = 114} 
models.legs[28136] = { name = "augury cuisses" , model = 114} 
models.legs[28137] = { name = "augury cuisses +1" , model = 114} 
models.legs[28138] = { name = "perle brayettes +1" , model = 239} 
models.legs[28139] = { name = "aurore brais +1" , model = 241} 
models.legs[28140] = { name = "teal slops +1" , model = 240} 
models.legs[28141] = { name = "wisent kecks" , model = 134} 
models.legs[28142] = { name = "brontes cuisses" , model = 112} 
models.legs[28143] = { name = "wukongs hakama +1" , model = 4} 
models.legs[28144] = { name = "adapas slacks +1" , model = 3} 
models.legs[28145] = { name = "mirador trousers +1" , model = 63} 
models.legs[28146] = { name = "hidalgo slops +1" , model = 20} 
models.legs[28148] = { name = "perdition slops" , model = 19} 
models.legs[28149] = { name = "ken. hanmomohiki" , model = 368}
models.legs[28150] = { name = "sho. hanmomohiki" , model = 369}
models.legs[28151] = { name = "sifahir slacks" , model = 176} 
models.legs[28152] = { name = "gorney brayettes +1" , model = 354} 
models.legs[28153] = { name = "shneddick tights +1" , model = 355} 
models.legs[28154] = { name = "weatherspoon pants +1" , model = 356} 
models.legs[28155] = { name = "scufflers cosciales" , model = 136} 
models.legs[28156] = { name = "ighwa trousers" , model = 333} 
models.legs[28157] = { name = "xaddi cuisses" , model = 365} 
models.legs[28158] = { name = "qaaxo tights" , model = 363} 
models.legs[28159] = { name = "artsieq hose" , model = 364} 
models.legs[28160] = { name = "cizin breeches +1" , model = 274} 
models.legs[28161] = { name = "otronif brais +1" , model = 247} 
models.legs[28162] = { name = "iuitl tights +1" , model = 256} 
models.legs[28163] = { name = "gendewitha spats +1" , model = 265} 
models.legs[28164] = { name = "hagondes pants +1" , model = 262} 
models.legs[28165] = { name = "laktisma hose" , model = 61} 
models.legs[28166] = { name = "quiahuiz leggings" , model = 16717 }
models.legs[28167] = { name = "kaabnax trousers" , model = 16730 }
models.legs[28168] = { name = "outrider hose" , model = 5} 
models.legs[28169] = { name = "espial hose" , model = 23} 
models.legs[28170] = { name = "wayfarer slops" , model = 20} 
models.legs[28171] = { name = "temachtiani pants" , model = 216} 
models.legs[28172] = { name = "mesyohi slacks" , model = 11} 
models.legs[28173] = { name = "osmium cuisses" , model = 53} 
models.legs[28174] = { name = "theurgists slacks" , model = 131} 
models.legs[28176] = { name = "aetosaur trousers" , model = 6} 
models.legs[28177] = { name = "aetosaur trousers +1" , model = 6} 
models.legs[28178] = { name = "shabti cuisses" , model = 22} 
models.legs[28179] = { name = "shabti cuisses +1" , model = 22} 
models.legs[28180] = { name = "haruspex slops" , model = 28} 
models.legs[28181] = { name = "haruspex slops +1" , model = 28} 
models.legs[28182] = { name = "kari. brayettes +1" , model = 16727 }
models.legs[28183] = { name = "thur. tights +1" , model = 16728 }
models.legs[28184] = { name = "orvail pants +1" , model = 16729 }
-- models.legs[28185] = { name = "alliance pants" , model = 'XXXXXX' }
models.legs[28186] = { name = "morass pants" , model = 16731} 
models.legs[28187] = { name = "woodland pants" , model = 16732} 
models.legs[28188] = { name = "gorney brayettes" , model = 16738} 
models.legs[28189] = { name = "shneddick tights" , model = 16739} 
models.legs[28190] = { name = "weatherspoon pants" , model = 16740} 
models.legs[28191] = { name = "founders hose" , model = 357} 
models.legs[28192] = { name = "cizin breeches" , model = 274} 
models.legs[28193] = { name = "otronif brais" , model = 247} 
models.legs[28194] = { name = "iuitl tights" , model = 256} 
models.legs[28195] = { name = "gendewitha spats" , model = 258} 
models.legs[28196] = { name = "hagondes pants" , model = 262} 
models.legs[28197] = { name = "nahtirah trousers" , model = 346} 
models.legs[28198] = { name = "miki. cuisses" , model = 16733} 
models.legs[28199] = { name = "manibozho brais" , model = 16734} 
models.legs[28200] = { name = "bokwus slops" , model = 16735} 
models.legs[28201] = { name = "xux trousers" , model = 346} 
models.legs[28202] = { name = "dredger hose" , model = 104} 
models.legs[28203] = { name = "orvail pants" , model = 344} 
models.legs[28204] = { name = "thurandaut tights" , model = 343} 
models.legs[28205] = { name = "karieyh brayettes" , model = 16726} 
models.legs[28206] = { name = "geomancy pants" , model = 308} 
models.legs[28207] = { name = "runeist trousers" , model = 338} 
models.legs[70001] = { name = "??? slops" , model = 16545 }
models.legs[70002] = { name = "special volunteer's" , model = 16557 }

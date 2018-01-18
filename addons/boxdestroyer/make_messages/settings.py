search = b'You were unable to enter a combination.\x7f1\x00\x07'

zones = {
    #1: 6421, # phanauet channel
    #2: 6422, # carpenters' landing
    #3: 6423, # manaclipper
    #4: 6424, # bibiki bay
    #11: 6431, # oldton movalpolos
    #15: 6435, # abyssea - konschtat
    #24: 6444, # lufaise meadows
    #25: 6445, # misareaux coast
    #26: 6446, # tavnazian safehold
    #27: 6447, # phomiuna aquaducts
    #33: 6453, # al'taieu
    #39: 6459, # dynamis - valkurm
    #40: 6460, # dynamis - buburimu
    #41: 6461, # dynamis - qufim
    #42: 6462, # dynamis - tavnazia
    #43: 6463, # diorama abdhaljs-ghelsba
    #44: 6464, # abdhaljs isle-purgonorgo
    #45: 6465, # abyssea - tahrongi
    #46: 6466, # open sea route to al zahbi
    #47: 6467, # open sea route to mhaura
    #48: 6468, # al zahbi
    #50: 6470, # aht urhgan whitegate
    #51: 6471, # wajaom woodlands
    #52: 6472, # bhaflau thickets
    #53: 6473, # nashmau
    #54: 6474, # arrapago reef
    #55: 6475, # ilrusi atoll
    #56: 6476, # periqia
    #57: 6477, # talacca cove
    #58: 6478, # silver sea route to nashmau
    #59: 6479, # silver sea route to al zahbi
    #60: 6480, # the ashu talif
    #61: 6481, # mount zhayolm
    #65: 6485, # mamook
    #66: 6486, # mamool ja training grounds
    #67: 6487, # jade sepulcher
    #68: 6488, # aydeewa subterrane
    #69: 6489, # leujaoam sanctum
    #79: 6499, # caedarva mire
    #81: 6501, # east ronfaure [s]
    #82: 6502, # jugner forest [s]
    #83: 6503, # vunkerl inlet [s]
    #84: 6504, # batallia downs [s]
    #85: 6505, # la vaule [s]
    #86: 6506, # everbloom hollow
    #87: 6507, # bastok markets [s]
    #88: 6508, # north gustaberg [s]
    #89: 6509, # grauberg [s]
    #90: 6510, # pashhow marshlands [s]
    #91: 6511, # rolanberry fields [s]
    #93: 6513, # ruhotz silvermines
    #94: 6514, # windurst waters [s]
    #95: 6515, # west sarutabaruta [a]
    #96: 6516, # fort karugo-narugo [s]
    #99: 6519, # castle oztroja [s]
    100: 6520, # west ronfaure
    101: 6521, # east ronfaure
    102: 6522, # la theine plateau
    103: 6523, # valkurm dunes
    104: 6524, # jugner forest
    105: 6525, # batallia downs
    106: 6526, # north gustaberg
    107: 6527, # south gustaberg
    108: 6528, # konschtat highlands
    109: 6529, # pashhow marshlands
    110: 6530, # rolanberry fields
    111: 6531, # beaucedine glacier
    112: 6532, # xarcabard
    113: 6533, # cape teriggan
    114: 6534, # eastern altepa desert
    115: 6535, # west sarutabaruta
    116: 6536, # east sarutabaruta
    117: 6537, # tahrongi canyon
    118: 6538, # buburimu peninsula
    119: 6539, # meriphataud mountains
    120: 6540, # sauromugue champaign
    121: 6541, # the sanctuary of zi'tah
    122: 6542, # ro'maeve
    123: 6543, # yuhtunga jungle
    124: 6544, # yhoator jungle
    125: 6545, # western altepa desert
    126: 6546, # qufim island
    127: 6547, # behemoth's dominion
    128: 6548, # valley of sorrows
    130: 6550, # ru'aun gardens
    #132: 6552, # abyssea - la theine
    #134: 6554, # dynamis - beaucedine
    #136: 6556, # beaucedine glacier [s]
    #139: 6559, # horlais peak
    #140: 6560, # ghelsba outpost
    #141: 6561, # fort ghelsba
    #142: 6562, # yughott grotto
    #143: 6563, # palborough mines
    #145: 6565, # giddeus
    #148: 6568, # qulun dome
    #149: 6569, # davoi
    #151: 6571, # castle oztroja
    153: 6573, # the boyahda tree
    #154: 6574, # dragon's aery
    #157: 6577, # middle delkfutt's tower
    158: 6578, # upper delkfutt's tower
    159: 6579, # temple of uggalepih
    160: 6580, # den of rancor
    166: 6586, # ranguemont pass
    167: 6587, # bostaunieux oubliette
    169: 6589, # torimarai canal
    172: 6592, # zeruhn mines
    173: 6593, # korroloka tunnel
    174: 6594, # kuftal tunnel
    176: 6596, # sea serpent grotto
    177: 6597, # ve'lugannon palace
    178: 6598, # the shrine of ru'avitau
    #184: 6604, # lower delkfutt's tower
    #186: 6606, # dynamis - bastok
    #187: 6607, # dynamis - windurst
    190: 6610, # king ranpere's tomb
    191: 6611, # dangruf wadi
    192: 6612, # inner horutoto ruins
    193: 6613, # ordelle's caves
    194: 6614, # outer horutoto ruins
    195: 6615, # eldieme necropolis
    196: 6616, # gusgan mines
    197: 6617, # crawler's nest
    198: 6618, # maze of shakrami
    200: 6620, # garlaige citadel
    204: 6624, # fei'yin
    205: 6625, # ifrit's cauldron
    208: 6628, # quicksand caves
    212: 6632, # gustav tunnel
    213: 6633, # labyrinth of onzozo
    #216: 6636, # abyssea - misareaux
    #217: 6637, # abyssea - vunkerl
    #218: 6638, # abyssea - altepa
    #220: 6640, # ship bound for selbina
    #221: 6641, # ship bound for mhaura
    #222: 6642, # provenance
    #227: 6647, # ship bound for selbina
    #228: 6648, # ship bound for mhaura
    #231: 6651, # northern san d'oria
    #232: 6652, # port san d'oria
    #234: 6654, # bastok mines
    #235: 6655, # bastok markets
    #236: 6656, # port bastok
    #237: 6657, # metalworks
    #238: 6658, # windurst waters
    #239: 6659, # windurst walls
    #240: 6660, # port windurst
    #241: 6661, # windurst woods
    #242: 6662, # heavens tower
    #245: 6665, # lower jeuno
    #246: 6666, # port jeuno
    #247: 6667, # rabao
    #248: 6668, # selbina
    #249: 6669, # mhaura
    #250: 6670, # kazham
    #251: 6671, # hall of the gods
    #252: 6672, # norg
    #253: 6473, # abyssea - uleguerand
    #254: 6674, # abyssea - grauberg
    #256: 85591, # western adoulin
    #257: 85592, # eastern adoulin
    #258: 85593, # rala waterways
    #259: 85594, # rala waterways [u]
    #260: 85595, # yahse hunting grounds
    #261: 85596, # ceizak battlegrounds
    #262: 85597, # foret de hennetiel
    #263: 85598, # yorcia weald
    #264: 85599, # yorcia weald [u]
    #265: 85600, # morimar basalt fields
    #266: 85601, # marjami ravine
    #267: 85602, # kamihr drifts
    #268: 85603, # sih gates
    #269: 85604, # moh gates
    #270: 85605, # cirdas caverns
    #271: 85606, # cirdas caverns [u]
    #272: 85607, # dho gates
    #273: 85608, # woh gates
    #274: 85609, # outer ra'kaznar
    #275: 85610, # outer ra'kaznar [u]
    #276: 85611, # ra'kaznar inner court
    #277: 85612, # ra'kaznar turris
    #280: 85615, # mog garden
    #281: 85616, # leafallia
    #288: 85623, # escha - zi'tah
    #289: 85624, # escha - ru'aun
    #291: 85626, # reisenjima
}

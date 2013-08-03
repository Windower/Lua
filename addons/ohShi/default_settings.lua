--Declaring default settings
defaults = T{}
--Addon settings
defaults.staggeronly = false  
defaults.showrolls = true
defaults.selfrolls = false
defaults.duration = 10

--Textbox settings
defaults.bg = {}
defaults.bg.red = 0
defaults.bg.blue = 0
defaults.bg.green = 0
defaults.pos = {}
defaults.pos.x = 400
defaults.pos.y = 300
defaults.text = {}
defaults.text.red = 255
defaults.text.green = 255
defaults.text.blue = 255
defaults.text.font = 'Consolas'
defaults.text.size = 10

--Moblist defaults
defaults.moblist = T{}
defaults.moblist['voidwatch'] = S{"Qilin", "Celaeno", "Morta", "Bismarck", "Ig-Alima", "Kalasutrax", "Ocythoe", "Gaunab", "Hahava", "Cherufe", "Botulus Rex", "Taweret", "Agathos", "Goji", "Gugalanna", "Gasha", "Giltine", "Mellonia", "Kaggen", "Akvan", "Pil", "Belphoebe", "Kholomodumo", "Aello", "Uptala", "Sarbaz", "Shah", "Wazir", "Asb", "Rukh", "Provenance Watcher"}
defaults.moblist['abyssea'] = S{"Alfard", "Orthrus", "Carabosse", "Glavoid", "Isgebind"}
defaults.moblist['legion'] = S{"Veiled", "Lofty", "Soaring", "Mired", "Paramount"}
defaults.moblist['meebles'] = S{"Goldwing", "Silagilith", "Surtr", "Dreyruk", "Samursk", "Umagrhk", "Izyx", "Grannus", "Svaha", "Melisseus"}
defaults.moblist['other'] = S{"Tiamat", "Khimaira", "Khrysokhimaira", "Cerberus", "Dvergr", "Bloodthirsty", "Hydra", "Enraged", "Odin"}
defaults.moblist['dangerous'] = S{"Provenance Watcher", "Apademak"}
defaults.dangerwords = T{}
defaults.dangerwords['weaponskills'] = S{"Zantetsuken", "Geirrothr", "Astral Flow", "Chainspell", "Beastruction", "Mandible Massacre", "Oblivion's Mantle", "Divesting Gale", "Frog", "Danse", "Raksha Stance", "Yama's", "Ballistic Kick", "Eradicator", "Arm Cannon", "Gorge", "Extreme Purgitation", "Slimy Proposal", "Rancid Reflux", "Provenance Watcher starts", "Pawn's Penumbra", "Gates", "Fulmination", "Nerve", "Thundris"}
defaults.dangerwords['spells'] = S{"Death", "Meteor", "Kaustra", "Breakga", "Thundaga IV", "Thundaja", "Firaga IV", "Firaja", "Aeroga IV", "Aeroja", "Blizzaga IV", "Blizzaja", "Stonega IV", "Stoneja"}

--Fill settings from either defaults table or settings.xml
settings = config.load(defaults)

--create tables to be used throughout the addon
tracking = T{}
prims = S{}
spells = {}
jAbils = {}
mAbils = {}
stats = {}

speFName = '../../plugins/resources/spells.xml'
staFName = '../../plugins/resources/status.xml'
jaFName = '../../plugins/resources/abils.xml'
maFName = '../libs/resources/mabils.xml'

speFile = files.new(speFName)
staFile = files.new(staFName)
jaFile = files.new(jaFName)
maFile = files.new(maFName)

--Save settings on load (in case this is first run)
settings:save('all')


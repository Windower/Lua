# Cape Trader
Cape Trader is used to automate the process of augmenting ambuscade capes. The cape trader addon injects packets extensively so please take that into consideration and use this addon at you own risk. While there are some safeguards in this addon, there is still a risk that you can lose your abdhaljs thread,dust,sap and dye if you use this addon. Please read the usage notes and information on the prep and go commands carefully as well as the warnings section before deciding to use this addon.

___
### Usage notes

Load the addon by using the following command:

    //lua load capetrader

There are some conditions that you need to meet in order to use the important go and prep commands:

1. You must be in Mhaura and be within a distance of 6 to the Gorpa-Masorpa npc.

2. If you have recently zoned into Mhaura you will have to wait to use the go command until your inventory loads, or if you have only recently logged in.

3. Make sure there is only one of the given cape you want to augment in your inventory. For example if you are intending to augment an ogma's cape, there should only be one ogma's cape in your inventory.

4. The go command takes a number as an input that represents the number of times you wish to augment your cape. It is possible you will lose your thread,dust,sap and dye if you enter a number that would take your augment past its possible maximum. For example suppose you have an ogma's cape already augmented with Dex+5 from a thread item. After using the **//ct prep run thread dex** command you enter **//ct go 20** command. There is a safeguard that will stop the augmentation process after augmenting your cape 15 times. However it is highly recommended that you enter the exact number of times you need to max a particular augment path just in case.

5. It is also possible to lose augment items if you try to augment a cape with a different path than is already present. Suppose again you have an ogma's cape augmented with DEX+5 via threads. If you enter the **//ct prep run thread str** and then the **//ct go 15** command intending to augment your cape with str, **you might lose these 15 threads**. There is now a safeguard to avoid this, but it is highly recommended you make sure your intended augment path already matches what is on the cape.

6. Make sure you do not move items around your various inventory bags while the augmentation process is ongoing. You can mess around with your inventory after you get the ending message, otherwise you might interrupt the augmentation process and need to reload the addon.

7. The augmentation process can occasionally stall. If this ever happens you can use the **//ct r** command to reload the addon and start the process over again.


Suppose you want to augment an ogma's cape from scratch with dex, accuracy and attack, and double attack. You can use the following steps:

1. Enter //ct prep run thread dex

2. Enter //ct go 20

3. Wait for the ending message

4. Enter //ct prep run dust acc/atk

5. Enter //ct go 20

6. Wait for the ending message.

7. Enter //ct prep run sap doubleattack

8. Enter //ct go 10

9. Upon receiving the completion message you can then consider augmenting another cape.

___

### Commands

The **help** command displays all of the possible commands of CapeTrader in your chat windower. Below are the equivalent ways of calling the command:

    //ct help
    //ct h
    //capetrader help
    //capetrader h

The **reload** command reloads the addon. Useful if the capetrader addon ever gets stuck during the augmentation process. The below are equivalent:

    //ct reload
    //ct r
    //capetrader reload
    //capetrader r

The **unload** command reloads the addon. Useful if the capetrader addon ever gets stuck during the augmentation process or you want to unload the addon quickly. The below are equivalent:

    //ct unload
    //ct u
    //capetrader unload
    //capetrader u

The **prep** command is one of the key components of this addon's function. This command tells the go command how to augment your cape. There are three inputs to the prep command. First is the 3 letter abbreviation of the job on the cape, for example: cor blm whm pup. The second is the type of augment item you need to use: thread, dust, sap and dye.  Third is the augment path. Note that none of these inputs are case sensitive. Also in case you are not sure exactly what to input for the augment path, you can use the list command or use the following list for reference. Below are all of the possible combinations of valid augment paths:

    //ct prep war thread hp
    //ct prep mnk thread mp
    //ct prep whm thread str
    //ct prep blm thread dex
    //ct prep rdm thread vit
    //ct prep thf thread agi
    //ct prep pld thread int
    //ct prep drk thread mnd
    //ct prep bst thread chr
    //ct prep brd thread petmelee
    //ct prep rng thread petmagic

    //ct prep sam dust acc/atk
    //ct prep nin dust racc/ratk
    //ct prep drg dust macc/mdmg
    //ct prep smn dust eva/meva

    //ct prep blu sap wsd
    //ct prep cor sap critrate
    //ct prep pup sap stp
    //ct prep dnc sap doubleattack
    //ct prep sch sap haste
    //ct prep geo sap dw
    //ct prep run sap enmity+
    //ct prep war sap enmity-
    //ct prep mnk sap snapshot
    //ct prep whm sap mab
    //ct prep blm sap fc
    //ct prep rdm sap curepotency
    //ct prep thf sap waltzpotency
    //ct prep pld sap petregen
    //ct prep drk sap pethaste

    //ct prep bst dye hp
    //ct prep brd dye mp
    //ct prep rng dye str
    //ct prep sam dye dex
    //ct prep nin dye vit
    //ct prep drg dye agi
    //ct prep smn dye int
    //ct prep blu dye mnd
    //ct prep cor dye chr
    //ct prep pup dye acc
    //ct prep dnc dye atk
    //ct prep sch dye racc
    //ct prep geo dye ratk
    //ct prep run dye macc
    //ct prep war dye mdmg
    //ct prep mnk dye eva
    //ct prep whm dye meva
    //ct prep blm dye petacc
    //ct prep rdm dye petatk
    //ct prep thf dye petmacc
    //ct prep pld dye petmdmg

The **go** command is the second key component of the CapeTrader addon and requires that you have used the prep command correctly beforehand. Remember again that using this command carries with it some risks as described in the usage notes section. If you do not provide an input the go command will by default only augment your cape once. Below are equivalent ways of augmenting your cape 20 times:

    //ct go 20
    //capetrader go 20

The **list** command is used as a reminder of what are valid inputs for the augmentpath input of the prep command. Below are the equivalent ways of calling this command:

    //ct list
    //capetrader list
    //ct l
    //capetrader l
___


### Warnings and notes on the relevant packets
There are four parts to the process of augmenting your ambuscade cape:

1. Part 1: Targetting gorpa-masorpa plus putting together and trading the relevant items. This takes me about 10 seconds to complete manually. (Involves outgoing packet 0x036)

2. Part 2: Waiting for the dialog menu to pop up and become usable. This takes about 1 second and can't be controlled by the player. (Involves the incoming 0x034 packet.)

3. Part 3: Navigating the menu to confirm and augment your cape. This takes me 2-3 seconds to confirm manually. (Involves 2 outgoing 0x05B packets)

4. Part 4: Waiting and receiving your newly augmented cape. This takes anywhere from 1 to 3 seconds and can't be controlled by the player. (Involves the incoming 0x01D packet)

The cape trader addon uses packets in order to substantially speed up parts one and three from above at a speed that would not normally be possible. Therefore if you use this addon you could potentially look suspicious. Part 1 of the process takes only 1 second using this addon. If this makes you uncomfortable you can change the value of the dustSapThreadTradeDelay and dyeTradeDelay variables in the capeTrader.lua file to a more reasonable amount if you wish. Please note that the augmenting with dyes needs a bit longer of a delay to work. This addon does part 3 pretty much instantaneously once the incoming 0x034 packet is received from part 2. So once again you can look suspicious again during this stage. The time it takes for part 2 and 4 should not be that different from you augmenting capes manually.

The possibility of the loss of augment items comes from part 3. When augmenting manually you will get denied by the npc if you try to trade an already maxed cape. Injecting the 0x036 packet and later the 0x05B packets bypasses this check but you lose your augment items but receive your cape back unchanged if you have already maxed an augment path. There are some safeguards to prevent this happening in this addon but it has not been tested on every single augment path. So please use the go command with caution.

Please keep all of the above in mind before deciding to use this addon. If you do decide to use CapeTrader I hope you find it useful!

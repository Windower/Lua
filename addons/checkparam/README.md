# checkparam
  - //cp
	-  装備中アイテムの任意のプロパティを合計して表示します。
	  -  displays the total of property of current equipments.(defined in setting.xml)
  - //cp debug
	- 装備中アイテムの全てのプロパティを装備ごとに表示します。
	- displays all the properties of current equipments, separately for each equipment.
## data/settings.xml
  - 表示させるプロパティをジョブごとに定義します。
  - checkparam uses “setting.xml”to define the properties you want to be displayed.you can define the properties for each job.
	- `|` 区切り記号 divide each property 
	- `||` 改行 starts new line on display
  - 召喚獣: 飛竜: オートマトン: 羅盤: などペットに関するプロパティは全て`pet: `で指定します。
	-  `pet: ` define properties for all pets,which means avatar,wyvern,automaton,luopan.
  - If there’s something wrong,or something strange,please tell me on Twitter [@from20020516](https://twitter.com/from20020516) **with simple English**. Thank you!
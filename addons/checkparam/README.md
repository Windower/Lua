# checkparam
  - //cp
	-  装備中アイテムの任意のプロパティを合計して表示します。
	  -  displays the total of property of current equipments.(defined in setting.xml)
  - //cp debug
	- 装備中アイテムの全てのプロパティを装備ごとに表示します。
	- displays all the properties of current equipments, separately for each equipment.
## data/settings.xml
  - 表示させるプロパティをジョブごとに定義します。
  - define the properties to be displayed for each job.
	- |  区切り記号 separator
	- || 改行 new line
  - 召喚獣: 飛竜: オートマトン: 羅盤: などペットに関するプロパティは全てpet: で指定します。
	- all 'pets' propaties(avatar:, luopan:...) require 'pet:' instead.
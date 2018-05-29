# checkparam

- `/check` OR `/c` (in-game command)
  - 「調べる」したとき、対象が装備しているアイテムのうち任意のプロパティを合計して表示します。
  - whenever you /check any player, displays the total of property of current equipments.(defined in `setting.xml`)

## data/settings.xml (auto-generated)
- 表示させるプロパティをジョブごとに定義します。
  - `|` 区切り記号 divide each property
  - `NON`は/anon時に使用
  - 召喚獣: 飛竜: オートマトン: 羅盤: などペットに関するプロパティは全て`pet: `で指定します。


- Checkparam uses `setting.xml` to define the properties you want to be displayed.
  - You can define the properties for each job.
  - `NON` means target status is /anon
  -  `pet: ` define properties for all pets, which means avatar,wyvern,automaton,luopan.
- If there’s something wrong,or something strange,please tell me on Twitter [@from20020516](https://twitter.com/from20020516) **with simple English**. Thank you!

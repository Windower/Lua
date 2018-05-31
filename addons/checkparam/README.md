# checkparam

- `/check` OR `/c` (in-game command)
  - Whenever you `/check` any player, displays the total of property of that players current equipments.(defined in `settings.xml`)
  - プレイヤーを「調べる」したとき、そのプレイヤーが装備しているアイテムの任意のプロパティを合計して表示します。(`settings.xml`で定義)
- `//checkparam` OR `//cp` (addon command)
  - same as /check <me>. you can use this command in equipment menu.
  - /check <me> と同様ですが、装備変更画面でも使用できます。

## data/settings.xml (auto-generated)

- Define the properties you want to be displayed for each job.
  - `|` divide each property
  -  `pet: ` define properties for all pets, which means avatar: wyvern: automaton: luopan:
- 表示させたいプロパティをジョブごとに定義します。
  - `|` 区切り記号
  - `pet: ` 召喚獣: 飛竜: オートマトン: 羅盤: は代わりに`pet:`で指定します。

- If there’s something wrong,or something strange,  
please tell me on Twitter [@from20020516](https://twitter.com/from20020516) **with simple English**. Thank you!

# checkparam
![40696007-caf91c3c-63fe-11e8-9837-516f9e1f2b0e](https://user-images.githubusercontent.com/26649687/40877257-96ccef12-66b8-11e8-97a4-797789375a00.jpg)
## English
- `/check` OR `/c` (in-game command)
  - Whenever you `/check` any player, displays the total of property of that players current equipments.(defined in `settings.xml`)
- `//checkparam` OR `//cp` (addon command)
    - same as /check <me>. you can use this command in equipment menu.

### data/settings.xml (auto-generated)
- Define the properties you want to be displayed for each job.
    - `|` divide each property
    -  `pet: ` define properties for all pets, which means avatar: wyvern: automaton: luopan:
- `<levelfilter>` ignore players with below the level `<number>` when `/check`. default value is 99.
    - **Tips:** if set `100`, ignore all players. you can still use `//cp` for yourself.
- If there’s something wrong,or something strange,  
please tell me on Twitter [@from20020516](https://twitter.com/from20020516) **with simple English**. Thank you!

## 日本語
- `/check` または `/c`（ゲーム内コマンド）
    - プレイヤーを「調べる」したとき、そのプレイヤーが装備しているアイテムの任意のプロパティを合計して表示します。(`settings.xml`で定義)
- `//checkparam` または `//cp`（アドオンコマンド）
    - /check <me> と同様ですが、装備変更画面でも使用できます。

### data/settings.xml (自動生成)
- 表示させたいプロパティをジョブごとに定義します。
    - `|` 区切り記号
    - `pet: ` 召喚獣: 飛竜: オートマトン: 羅盤: は代わりに`pet:`で指定します。
- `<levelfilter>`
    -「調べる」時に対象のレベルが設定値未満なら結果を表示しません。(初期値99)
    - **Tips:** `100`を設定すると「調べる」時の結果を表示しません。

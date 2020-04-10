# Bonanza

- Judge your Bonanza Marbles. activate with when you recive system message (/smes) with winning numbers.
- Purchase Bonanza Marbles with any combination of numbers.

#### Japanese

- モグボナンザの当せんを判定。当せん番号を含むシステムメッセージ (/smes) を受信するとボナンザマーブルを鑑定し、結果を出力します。
- 任意の数字の組み合わせでボナンザマーブルを購入します。

## Commands

- //bonanza judge
  - same as in-game /smes.

### Purchase marble (inject packets)

- //bonanza `<number>` `[number]`...
  - purchase specified marble(s).
- //bonanza random
  - purchase up to 10 marbles with at random.
- //bonanza sequence `<number>`
  - purchase up to 10 marbles with consecutive number.
  - e.g. `15250` then buying 15250 to 15259.
- //bonanza last `<number>`
  - purchase up to 10 random marbles with tail of specified `0-9`.
  - e.g. `0` then 2224**0**, 6231**0**, 4586**0**, 9078**0**...

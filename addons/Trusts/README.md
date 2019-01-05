# Trusts

- //tru save `<setname>` : Save trusts in current party.
- //tru `<setname>` : Calls trusts you saved.
- //tru list : Lists your saved sets.
- //tru random : What's your fortune today?
- //tru check : List of unlearned trusts. gotta catch 'em all!

### 使い方

- //tru save `<setname>`
  - 呼び出し中のフェイスをセットに保存（セット名は半角英字）
- //tru `<setname>`
  - 保存したセットのフェイスを召喚
  - 呼び出し先と"同枠"のフェイスは戻す
    - 既にPTにいる場合は戻さない = 倒れたフェイスの補充が可能
    - リキャストが不足している場合は戻さない
- //tru list
  - 保存したセットを一覧表示します。
- //tru random
  - フェイスガチャ。PT枠上限までランダムで召喚
- //tru check
  - 未習得フェイスを表示

### data/settings.xml (auto-generated)
- language : `<Japanese>` OR `<English>`
- auto : `true` OR `false`
  - 登録フェイスを全て自動で呼び出すか、1体ごとに1クリックするか選択
- wait
  - ユーザーのPC環境に応じて長くする。ファストキャストは無関係
  - aftercast : `number`
    - 詠唱完了から次の詠唱までの待機時間。初期値3秒
  - retr : `number`
    - フェイスを戻したあと次の詠唱までの待機時間。初期値1.25秒
  - retrall : `number`
    - フェイスを全て戻したあと次の詠唱までの待機時間。初期値3秒

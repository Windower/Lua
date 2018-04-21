# Trusts
- English available. 
- //tru [setname] 
  - data/settings.xml でユーザー定義したフェイスを順に呼び出す
- //tru save [setname]
  - 現在呼び出し中のフェイスをセットに保存
- //tru rand
  - フェイスおみくじ。PT枠上限までランダムで呼び出す
- //tru refa
  - 全てのフェイスを戻す。/refa allと同じ
- //tru check
  - 未習得フェイスを表示
## data/settings.xml
  - `auto` : 登録フェイスを全て自動で呼び出すか、1体ごとに1ポチするか定義
  - `wait` : 詠唱完了から次の詠唱までの待機時間。初期値3秒
## TODO
- ロールを定義してrandで遊びやすくする（tank,healer,buffer,melee,range...）
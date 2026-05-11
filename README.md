# Kabukicho Online

Roblox向けの夜街ソーシャルアクションMMOプロトタイプです。恋愛・出会い目的ではなく、評判、カリスマ、店ランキング、PvP、カオスイベントで盛り上がる短時間プレイを軸にしています。

![Kabukicho Online demo](assets/demo/kabukicho-online-demo.gif)

このGIFはPlaywrightで自動生成したWebプレビューです。実ゲームはRoblox StudioでRojo同期後にPlayして確認します。

## 実行方法

1. Roblox Studioで空のPlaceを開く
2. Rojoを使う場合は、このリポジトリで `rojo serve`
3. Studio側でRojoプラグインから接続
4. Playを押す

## デモGIF生成

```powershell
npm run capture:demo
```

## 実装済みMVP

- 三人称標準移動に加えたダッシュ
- 近距離プッシュPvP
- NPC群衆とProximityPromptによる客集め
- Money / Reputation / Charisma / ClubRank
- ランキング取得
- 店ランク上昇
- エモート
- ネオン街の自動生成
- ランダムなカオスイベント
- 物理で転がる街ギミック
- モバイル向けボタンUI

## 推奨フォルダ構成

```text
src/
  shared/
    Constants.lua
    GameConfig.lua
    Util.lua
  server/
    Main.server.lua
    RemoteBootstrap.lua
    WorldBuilder.lua
    PlayerDataService.lua
    EconomyService.lua
    RankingService.lua
    NPCService.lua
    PvPService.lua
    ChaosEventService.lua
  client/
    Main.client.lua
docs/
  GAME_DESIGN.md
  ROADMAP.md
```

## Roblox規約配慮

このプロトタイプでは「恋愛」「デート」「マッチング」系の仕組みを入れていません。NPCは「ファン」「観光客」「配信者」などの街の客として扱い、報酬は評判、SNS人気、店ランキング、金、カリスマに寄せています。

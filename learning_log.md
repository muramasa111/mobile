# Flutter学習ログ

## 2026-05-20 14:02 +09:00

### 今日扱った内容
- Flutterでは画面をWidgetの組み合わせで作ることを確認した。
- `Scaffold`、`Text`、`ElevatedButton`、`Column`、`Row`、`Container`、`Navigator` などの基本Widgetを確認した。
- データ構造はDartの `class` で作ることを確認した。
- `Star` クラスを作成した。
- `required this.xxx` は、クラスを作るときに必ず指定する値を表す書き方だと確認した。

### 現在の進捗
- `lib/models/star.dart` に `Star` クラスを作成済み。
- 次は星座線を表すクラスを作る予定。

### 理解したこと
- `class` はデータの設計図。
- `final` は一度決めたら変えない値。
- `String` は文字、`double` は小数。
- `required this.id` は、作成時に `id` を必ず渡すという意味。

## 2026-05-20 14:07 +09:00

### 今日扱った内容
- 星座線を表す `ConstellationEdge` クラスを作成した。
- `Constellation` は星座、`Edge` は線やつながりという意味だと確認した。
- Dartの変数名は `fromStarID` より `fromStarId` のようなキャメルケースが自然だと確認した。

### 現在の進捗
- `lib/models/star.dart` に `Star` クラスを作成済み。
- `lib/models/constellation_edge.dart` に `ConstellationEdge` クラスを作成済み。
- 次は星座全体を表す `Constellation` クラスを作る予定。

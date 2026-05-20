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

## 2026-05-20 14:53 +09:00

### 今日扱った内容
- `StarView` に `CustomPaint` を配置した。
- `StarPainter extends CustomPainter` を作成した。
- `paint` メソッド内で `canvas.drawCircle` を使い、星のような丸を描画した。
- 色を `Colors.red` にして、画面上に丸が表示されることを確認した。

### 理解したこと
- `CustomPaint` は自由に図形を描くためのWidget。
- `CustomPainter` は実際の描画処理を書くクラス。
- `canvas.drawCircle` で丸を描ける。
- `Offset(x, y)` で描画位置を指定する。

## 2026-05-20 15:15 +09:00

### 今日扱った内容
- `StarPainter` に `Constellation` データを渡すようにした。
- `constellations[0]` から星座データを1つ取り出した。
- `for (final star in constellation.stars)` で星のリストを順番に処理した。
- `star.x`、`star.y` を使って、データに登録した星を画面に描画した。

### 現在の進捗
- `constellation_data.dart` の星データから、画面に点を2つ表示できた。

## 2026-05-20 15:48 +09:00

### 今日扱った内容
- `StarView` を `StatelessWidget` から `StatefulWidget` に変更した。
- `StatefulWidget` では `createState()` を使って、状態を管理する `State` クラスを作ることを確認した。
- `StatefulWidget` は大文字小文字を正確に書く必要があることを確認した。

### 現在の進捗
- 星をタップして選択する準備として、`StarView` が状態を持てる形になった。

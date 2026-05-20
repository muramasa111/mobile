# Flutterコード書き方メモ

Flutterを書くときに見返すためのメモです。  
「何をしたいか」から探せるようにまとめます。

## 目次

- [Flutterの考え方](#flutterの考え方)
- [1画面を作る](#1画面を作る)
- [文字を表示する](#文字を表示する)
- [ボタンを作る](#ボタンを作る)
- [縦に並べる](#縦に並べる)
- [横に並べる](#横に並べる)
- [中央に置く](#中央に置く)
- [背景色・サイズをつける](#背景色サイズをつける)
- [余白を入れる](#余白を入れる)
- [画面遷移する](#画面遷移する)
- [前の画面に戻る](#前の画面に戻る)
- [StatelessWidget](#statelesswidget)
- [StatefulWidget](#statefulwidget)
- [画面を更新する](#画面を更新する)
- [今回のアプリで使うもの](#今回のアプリで使うもの)

---

## Flutterの考え方

Flutterでは、画面を `Widget` という部品の組み合わせで作ります。

| もの | Flutterで使うWidget |
|---|---|
| 文字 | `Text` |
| ボタン | `ElevatedButton` |
| 画面の土台 | `Scaffold` |
| 縦並び | `Column` |
| 横並び | `Row` |
| 中央配置 | `Center` |
| 箱・背景色・サイズ | `Container` |

---

## 1画面を作る

### 使うもの

`Scaffold`

### 最小コード

```dart
Scaffold(
  appBar: AppBar(
    title: Text("ホーム"),
  ),
  body: Center(
    child: Text("こんにちは"),
  ),
)
```

### ポイント

- `Scaffold` は1画面の土台。
- `appBar` は上のバー。
- `body` は画面の中身。

### Scaffoldの中身

```dart
return Scaffold(
  appBar: AppBar(
    title: Text("天体観測"),
  ),
  body: Center(
    child: Text("Star View"),
  ),
);
```

| 書き方 | 意味 |
|---|---|
| `return` | この画面に表示するWidgetを返す |
| `Scaffold` | 画面全体の基本構造 |
| `appBar` | 画面上部のバー |
| `AppBar` | 上部バーのWidget |
| `title` | AppBarに表示するタイトル |
| `body` | AppBar以外のメイン部分 |
| `Center` | 中身を中央に置くWidget |
| `child` | 中に入れるWidgetが1つのときに使う |

`body` には、画面のメイン表示を書きます。

今回なら、最終的に `body` に星空表示を入れます。

---

## 文字を表示する

### 使うもの

`Text`

### 最小コード

```dart
Text("こんにちは")
```

### 文字サイズや色を変える

```dart
Text(
  "こんにちは",
  style: TextStyle(
    fontSize: 24,
    color: Colors.white,
  ),
)
```

---

## ボタンを作る

### 使うもの

`ElevatedButton`

### 最小コード

```dart
ElevatedButton(
  onPressed: () {
    print("押されました");
  },
  child: Text("ボタン"),
)
```

### ポイント

- `onPressed` に押したときの処理を書く。
- `child` にボタン内の表示を書く。

---

## 縦に並べる

### 使うもの

`Column`

### 最小コード

```dart
Column(
  children: [
    Text("上"),
    Text("下"),
  ],
)
```

### 中央寄せ

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text("上"),
    Text("下"),
  ],
)
```

---

## 横に並べる

### 使うもの

`Row`

### 最小コード

```dart
Row(
  children: [
    Text("左"),
    Text("右"),
  ],
)
```

---

## 中央に置く

### 使うもの

`Center`

### 最小コード

```dart
Center(
  child: Text("中央"),
)
```

---

## 背景色・サイズをつける

### 使うもの

`Container`

### 最小コード

```dart
Container(
  width: 200,
  height: 100,
  color: Colors.blue,
  child: Text("箱"),
)
```

---

## 余白を入れる

### 周りに余白を入れる

```dart
Padding(
  padding: EdgeInsets.all(16),
  child: Text("余白つき"),
)
```

### 間に空白を入れる

```dart
SizedBox(height: 20)
```

---

## 画面遷移する

### 使うもの

`Navigator.push`

### 最小コード

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => StarView(),
  ),
);
```

### ポイント

- `StarView()` の部分に、移動先の画面を書く。
- `context` は、今いる画面の情報。

---

## 前の画面に戻る

### 使うもの

`Navigator.pop`

### 最小コード

```dart
Navigator.pop(context);
```

---

## StatelessWidget

### 使う場面

画面の中身が変化しないとき。

### 最小コード

```dart
class SamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("サンプル")),
      body: Center(
        child: Text("変化しない画面"),
      ),
    );
  }
}
```

---

## StatefulWidget

### 使う場面

画面の中身が変化するとき。

例:

- ボタンを押したら数字が変わる
- 星を選択する
- 線をつなぐ
- 図鑑の状態が変わる

### 最小コード

```dart
class SamplePage extends StatefulWidget {
  @override
  State<SamplePage> createState() => _SamplePageState();
}

class _SamplePageState extends State<SamplePage> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("サンプル")),
      body: Center(
        child: Text("count: $count"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            count++;
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

## 画面を更新する

### 使うもの

`setState`

### 最小コード

```dart
setState(() {
  count++;
});
```

### ポイント

- 変数の値を変えたあと、画面に反映したいときに使う。
- `StatefulWidget` の中で使う。

---

## 今回のアプリで使うもの

| やりたいこと | 使うもの |
|---|---|
| 星を描く | `CustomPainter` |
| 星座線を描く | `CustomPainter` |
| 星をタップする | `GestureDetector` |
| 画面をドラッグする | `GestureDetector` |
| 星を光らせる | `AnimationController` |
| 星を暗くする | `AnimationController` |
| 画面を更新する | `setState` |
| 図鑑状態を保存する | `shared_preferences` |

---

## 書き方の基本パターン

Flutterでは、だいたい次の形で書きます。

```dart
Widget名(
  設定名: 値,
  child: 子Widget,
)
```

子Widgetが複数ある場合は `children` を使います。

```dart
Widget名(
  children: [
    Widget1(),
    Widget2(),
  ],
)
```

---

## よく間違えやすいところ

### カンマ

Flutterでは、最後に `,` をつけることが多いです。

```dart
Text(
  "こんにちは",
)
```

### child と children

| 書き方 | 意味 |
|---|---|
| `child` | 子Widgetが1つ |
| `children` | 子Widgetが複数 |

```dart
Center(
  child: Text("1つだけ"),
)
```

```dart
Column(
  children: [
    Text("1つ目"),
    Text("2つ目"),
  ],
)
```

---

## classを書く

### classとは

`class` は、データや処理をひとまとめにするための設計図です。

今回のアプリでは、星や星座を表すために使います。

### 基本形

```dart
class Star {
  final String id;
  final String name;
  final double x;
  final double y;

  const Star({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
  });
}
```

### 意味

| 書き方 | 意味 |
|---|---|
| `class Star` | `Star` という名前の設計図を作る |
| `final String id;` | 文字列の `id` を持つ |
| `final double x;` | 小数の `x` を持つ |
| `const Star({...})` | `Star` を作るための書き方 |
| `required this.id` | 作るときに `id` を必ず指定する |

### 使い方

```dart
const vega = Star(
  id: "vega",
  name: "ベガ",
  x: 120,
  y: 80,
);
```

### ポイント

- `String` は文字。
- `int` は整数。
- `double` は小数。
- `final` は、一度入れたら変えない値。
- 星の基本データは変わらないので `final` が向いている。

### required thisとは

`required this.id` は、クラスを作るときに `id` を必ず指定する、という意味です。

```dart
class Star {
  final String id;
  final String name;

  const Star({
    required this.id,
    required this.name,
  });
}
```

この場合、`Star` を作るときは必ず `id` と `name` が必要です。

```dart
const vega = Star(
  id: "vega",
  name: "ベガ",
);
```

`required` があるので、次のように `name` を書き忘れるとエラーになります。

```dart
const vega = Star(
  id: "vega",
);
```

`this.id` は、「このクラスが持っている `id` に値を入れる」という意味です。

### コンストラクタとは

コンストラクタは、クラスから実際のデータや部品を作るときの書き方です。

例えば `Star` クラスにこのようなコンストラクタがあります。

```dart
const Star({
  required this.id,
  required this.name,
  required this.x,
  required this.y,
});
```

これがあると、次のように `Star` を作れます。

```dart
const vega = Star(
  id: "vega",
  name: "ベガ",
  x: 120,
  y: 80,
);
```

`StarPainter` でも同じです。

```dart
class StarPainter extends CustomPainter {
  final Constellation constellation;

  StarPainter({
    required this.constellation,
  });
}
```

このコンストラクタがあると、外から星座データを渡して `StarPainter` を作れます。

```dart
StarPainter(
  constellation: constellation,
)
```

### なぜコンストラクタが必要か

クラスの中で使いたい値を、外から渡すためです。

今回なら、`StarPainter` は星を描くために星座データが必要です。

そのため、`constellation` をコンストラクタで受け取ります。

---

## Listを書く

### Listとは

`List` は、同じ種類のデータを複数まとめて持つためのものです。

例えば、星を1つだけではなく、たくさん持ちたいときに使います。

### 文字のリスト

```dart
final List<String> names = [
  "ベガ",
  "アルタイル",
  "デネブ",
];
```

### 意味

| 書き方 | 意味 |
|---|---|
| `List<String>` | 文字列を複数入れるリスト |
| `names` | リストの名前 |
| `[...]` | リストの中身 |

### Starのリスト

```dart
final List<Star> stars = [
  Star(
    id: "vega",
    name: "ベガ",
    x: 100,
    y: 120,
    brightness: 1.0,
    color: Colors.white,
  ),
  Star(
    id: "altair",
    name: "アルタイル",
    x: 200,
    y: 180,
    brightness: 0.9,
    color: Colors.white,
  ),
];
```

これは `Star` を複数持つリストです。

### 空のリスト

```dart
final List<Star> stars = [];
```

### リストから1つ取り出す

```dart
final firstStar = stars[0];
```

`0` は1番目という意味です。

### リストの数を調べる

```dart
final count = stars.length;
```

### リストを順番に見る

```dart
for (final star in stars) {
  print(star.name);
}
```

### 今回のアプリでの使い方

星座は、星を複数持ちます。

```dart
final List<Star> stars;
```

星座は、星座線も複数持ちます。

```dart
final List<ConstellationEdge> edges;
```

つまり、`Constellation` クラスの中でリストを使います。

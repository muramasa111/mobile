# 星空ガイドビュー 技術ログ

## 2026-05-13 15:55 +09:00

### ログ運用
- 技術的な検討・調査・実装判断は、この `technical_log.md` に記録する。
- アイディアや体験設計の変更は、既存の `idea_log.md` に記録する。
- ログを書くときは、日付と時刻を併記する。

### 現時点の技術検討テーマ
- Flutterでスマホの向きに合わせた星空表示をどう実装するか。
- 現在地・日時・端末姿勢から、画面に表示する星をどう決めるか。
- 4つの星座、やぎ座・こと座・わし座・はくちょう座の星データと星座線をどう用意するか。
- 図鑑状態、星座完成判定、夏の大三角の発見判定をどう管理するか。

## 2026-05-13 16:00 +09:00

### 60時間での現実的な開発範囲
- 前提: ユーザーはFlutter開発未経験。AIの支援を受けながら進める。
- 現状: 既存プロジェクトはホーム、天体観測、星座一覧、星座詳細、設定の仮画面がある。星空描画やゲーム処理はまだ未実装。
- 60時間で目指すべき範囲は、Stellarium級の正確な天文アプリではなく、端末の向きに合わせて星空が動き、4星座を探して図鑑登録できるデモアプリ。

### 60時間で入れたい機能
- 初回起動時の誕生月入力。
- やぎ座チュートリアル。
- 星空ガイド画面。
- 端末の向きに応じて星空表示が動く体験。
- やぎ座・こと座・わし座・はくちょう座の星表示。
- 星をタップして正しい星同士をつなぐ処理。
- 間違った選択時に星が一瞬暗くなる反応。
- 星座名解禁、星座完成、図鑑登録。
- 図鑑一覧と詳細画面。
- ベガ・アルタイル・デネブをつなぐ夏の大三角の特別発見。
- 進捗保存。

### 60時間では難しい、または後回しにする機能
- Stellariumと同等の高精度な全天シミュレーション。
- 全天の星データ・全88星座対応。
- カメラ映像と星の完全なAR重ね合わせ。
- コンパス誤差を高度に補正する仕組み。
- 12星座すべてを使った誕生星座チュートリアル。
- 天候、空の明るさ、観測環境まで考慮した表示。
- 完成度の高い演出やサウンド全般。

### 推奨方針
- 星データは4星座と夏の大三角周辺に絞る。
- 表示はFlutterのCustomPainterで描く。
- 端末姿勢によって星空が動くことを最優先にする。
- 天文学的な精度より、デモで伝わる体験を優先する。

## 2026-05-13 16:10 +09:00

### 推奨技術スタック
- UI: Flutter標準のMaterial UI。
- 星空描画: Flutter標準のCustomPainter。
- タップ判定: GestureDetectorと自前の星座データ。
- 状態管理: provider + ChangeNotifier。
- 進捗保存: shared_preferences。
- 現在地取得: geolocator。
- 端末姿勢取得: 第一候補はflutter_rotation_sensor。実機検証で不安定ならflutter_compass + sensors_plusに切り替える。
- 数学処理: dart:mathを基本にし、回転や行列が複雑になったらvector_mathを使う。
- 星・星座線データ: Stellarium skyculturesのwesternデータとNASA Bright Star Catalogを参考に、必要な星だけアプリ内JSONに手作業で整理する。

### ライブラリ比較
- geolocator: 現在地取得の第一候補。利用者が多く、権限確認・位置取得・位置更新に対応している。
- location: 代替候補。ただし今回はgeolocatorで十分。
- flutter_rotation_sensor: azimuth/pitch/roll、rotation matrix、quaternionを直接扱えるため、空に向ける体験を作りやすい。利用者数は少なめなので、早めの実機検証が必要。
- flutter_compass: 方位だけなら簡単。星空表示には傾きも必要なので、単体では不足する。
- sensors_plus: accelerometer/gyroscope/magnetometerにアクセスできる安定候補。ただし生センサー値から姿勢を作る必要があり、MVPでは実装負荷が高い。最新7系は現在のAndroid設定より要求が高めなので、使うならバージョン確認が必要。
- provider: Flutter初心者でも扱いやすい状態管理。図鑑状態、選択中の星、接続済み線、完成状態を管理するのに十分。
- flutter_riverpod: 高機能だが、今回の規模では学習コストがやや高い。
- shared_preferences: 誕生月、チュートリアル完了、星座の解禁・完成状態などの保存に十分。
- HiveなどのDB: データが増える場合は候補だが、今回は不要。
- astronomia/geoengine系: 天文計算ライブラリ候補。ただしMVPでは4星座分の固定星データと簡易的な座標変換で足りる可能性が高い。

### 最初に検証する技術リスク
- 実機で端末の向き、特に方位と傾きが安定して取れるか。
- 端末を動かしたとき、星空表示が直感的に動くか。
- 現在地取得の権限まわりがAndroid/iOSで通るか。
- CustomPainterで星と線を描き、タップ位置から星を選べるか。

### 現時点のおすすめ
- まずflutter_rotation_sensor + geolocator + CustomPainterで小さい試作を作る。
- 試作では、実際の星座処理より先に、画面に星を数個出し、端末の向きで動くかを確認する。
- センサーが不安定なら、flutter_compass + sensors_plus、またはデモ用の手動方向調整を併用する。

## 2026-05-13 16:20 +09:00

### 現時点で使う技術・ライブラリ
- Flutter標準のMaterial: 画面UI。
- Flutter標準のNavigator: 画面遷移。
- Flutter標準のCustomPainter: 星、星座線、星空の描画。
- Flutter標準のGestureDetector: 星のタップ判定。
- Flutter標準のAnimationController: 星が光る、暗くなる、完成演出。
- dart:math: 座標計算。
- geolocator: 現在地取得。
- flutter_rotation_sensor: 端末の向き・傾きを取る第一候補。
- provider: 図鑑状態、選択中の星、接続済み線などの状態管理。
- shared_preferences: 誕生月、チュートリアル完了、図鑑進捗の保存。

### 必要なら使う候補
- vector_math: 回転計算が複雑になった場合に使う。
- flutter_compass: flutter_rotation_sensorがうまく動かない場合の方位取得代替。
- sensors_plus: flutter_rotation_sensorがうまく動かない場合の生センサー取得代替。

### 使わない方針
- カメラAR系ライブラリ。
- 3Dエンジン。
- サーバー。
- DB。
- ログイン機能。
- 星をつなぐ専用ライブラリ。

### 星をつなぐ処理
- 星を選ぶ、線をつなぐ、完成判定を行う部分は専用ライブラリなしで実装する。
- CustomPainter、GestureDetector、自前の星座データで実現する。

## 2026-05-20 10:10 +09:00

### 対応端末方針
- デモ版はAndroidのみを対象にする。
- iOS/iPad対応は今回の範囲外にする。
- 権限設定、センサー検証、実機テストはAndroidに絞って進める。

## 2026-05-20 10:16 +09:00

### 星データ方針
- 星データは4星座分を手入力に近い形で用意する。
- 外部データを丸ごと取り込むより、デモに必要な星と線だけを整理して持つ。

### 完成条件
- 星座の形を覚えることも目的なので、主要な線だけでなく細かい線まで含める。
- 各星座に定義した星座線をすべて正しくつないだら完成にする。

### デモ操作方針
- 発表はパソコン内でのデモになる可能性が高い。
- センサー操作だけでなく、画面ドラッグで星空を動かせるモードを用意する。
- ドラッグ操作は、センサーが使えない環境や不安定な場合の逃げ道にする。

## 2026-05-20 10:21 +09:00

### 現在のプロジェクト調査
- `starguide` はFlutterプロジェクト。
- `pubspec.yaml` はほぼ初期状態で、追加ライブラリはまだ入っていない。
- `lib/main.dart` はFlutter初期テンプレートのカウンターコードが残っているが、実際のhomeは `HomePage`。
- `HomePage` から `StarView`、`ConstellationList`、`ConstellationDetail`、`Settings` に遷移する仮画面がある。
- `StarView`、`ConstellationList`、`ConstellationDetail`、`Settings` は中身が仮テキスト。
- `test/widget_test.dart` は初期カウンター用テストのままで、現在のアプリ構成とは合っていない。
- Androidの `AndroidManifest.xml` には位置情報などの権限設定はまだない。

### 実行環境メモ
- `flutter --version` と `flutter analyze` は、Flutter SDK `C:/Users/guslg/flutter` のGit safe.directory設定で停止した。
- 実装後にFlutterコマンドで検証するには、`git config --global --add safe.directory C:/Users/guslg/flutter` が必要になる可能性が高い。

### 実装開始時の推奨順序
- まず、既存の仮画面を活かしつつ星空ビューの試作から始める。
- 最初は追加ライブラリを入れず、CustomPainter、GestureDetector、ドラッグ操作、自前データで星を描く。
- その後、星を選ぶ、線をつなぐ、完成判定、図鑑状態へ進める。
- 位置情報や端末センサーは、ゲーム部分が動いてから追加する。

// flutter codelab
// ランダムな単語のペアをお気に入り登録できるアプリ

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// MyAppで定義したアプリの実行をFlutterに指示
void main() {
  runApp(MyApp());
}

// Widget: すべてのFlutterアプリを作成する際の元になる要素
// MyApp自体がWidget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// MyAppStateでは、アプリが機能するために必要となるデータを定義。
// 状態クラスは 自身の変更に関する通知を行うことができるChangeNotifierを拡張して作成。
// 状態は、ChangeNotifierProviderを使用して作成され、アプリ全体に提供される。
// (アプリ内のどのウィジェットも状態を取得可能)

class MyAppState extends ChangeNotifier {
  // ランダムな単語のペアを定義
  var current = WordPair.random();

  // 単語の更新
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  // buildメソッド：ウィジェットを常に最新にするために、周囲の状況が変化するたびに自動的に呼び出されるメソッド
  @override
  Widget build(BuildContext context) {
    // MyHomePage では、watchメソッドを使用してアプリの現在の状態に対する変更を追跡
    var appState = context.watch<MyAppState>();

    // 単語のペア(単語の表示のたびにappState全体を参照するのを避ける)
    var pair = appState.current;

    // どの build メソッドも必ず、ウィジェットか、ウィジェットのネストしたツリー（こちらのほうが一般的）を返却
    // Scaffold: 画面の基本骨組みを提供するウィジェット
    return Scaffold(
      body: Center(
        // Column:
        // Flutterにおける非常に基本的なレイアウトウィジェット
        // 任意の数の子を従え、それらを上から下へ一列に配置（デフォルトでは上揃え）
        // Centerウィジェットでラップすることで、Column自体を左右中央に配置

        child: Column(
          // 縦方向に中央揃え
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // Text：文字列を画面に表示するための基本ウィジェット
            //Text('A random AWESOME idea:'),

            // appStateで定義したデータ（単語ペア）を表示
            BigCard(pair: pair),

            // 余白を確保するためのウィジェット
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                appState.getNext();
              },
              child: Text('Next'), // Flutterでは、行末にもカンマをつけるのが慣習
            ),
          ],
        ),
      ),
    );
  }
}

// 単語表示用のウィジェット
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // styleに書式を格納
    // theme.textThemeの中のdisplayMediumの書式を指定colorでコピー
    // displayMediumはnullable（null許容）型である。
    // 型安全なDartでは、nullableなdisplayMediumにcopyWithが使えないが、
    // !をつけることで、nullが入らない想定であるとコンパイラに伝えることができ、
    // copyWithが使えるようになる。
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    // カードウィジェットを返却
    return Card(
      // 色を指定
      color: theme.colorScheme.primary,

      // 子にパディングウィジェットを追加
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,

          // 画面読み上げソフト用のラベルを指定
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

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

  // お気に入りの単語を保持するリスト
  // var favorites = <WordPair>[];

  // お気に入りの単語を保持する集合
  var favorites = <WordPair>{};

  // お気に入りの登録、解除を行う関数
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }

    print(favorites);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// State: 変更可能なデータを保持するオブジェクト
// MyHomePageの状態を管理するクラス
// _をつけることで、プライベートクラス化
class _MyHomePageState extends State<MyHomePage> {
  // サイドバーの選択中インデックス
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    // 選択中のインデックスに応じて表示するページを切り替え
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              // SafeArea: デバイスのノッチやステータスバー、ホームインジケーターなどの
              // システムUI要素と重ならないようにするウィジェット
              SafeArea(
                // サイドバー
                child: NavigationRail(
                  // サイドバーの拡張表示
                  // falseの場合、アイコンのみ表示
                  extended: constraints.maxWidth >= 600,
                  // サイドバーの項目
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  // 選択中のインデックス
                  selectedIndex: selectedIndex,
                  // 項目が選択されたときのコールバック
                  onDestinationSelected: (value) {
                    // 選択中のインデックスを更新
                    // setState: 状態が変更されたことをFlutterに通知し、UIを再構築
                    // StatefulWidgetの状態を変更する際に使用される組み込みメソッド
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              // メインコンテンツ
              // Expanded: 子ウィジェットが利用可能なスペースを占有するようにするウィジェット
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

// 単語ペアを表示し、お気に入り登録するためのウィジェット
// HomePageの子ウィジェット
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    var favorites = appState.favorites;

    // お気に入りがない場合の表示
    if (favorites.isEmpty) {
      return Center(child: Text('No favorites yet.'));
    }
    
    // お気に入りがある場合の表示
    return ListView(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text('Favorites:')),
        for (var pair in favorites) ListTile(
          leading: Icon(Icons.favorite),
          title: Text(pair.asLowerCase),
        ),
      ],
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

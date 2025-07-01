import 'package:flutter/material.dart';

void main() => runApp(RecipeApp());

class RecipeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'レシピアプリ',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // 状態付きボタン関連
  List<int> buttonStates = List.filled(15, 0);
  final List<String> buttonLabels = [
    '和食', '洋食', '中華', 'イタリアン', '韓国料理',
    'サラダ', 'スープ', 'ご飯もの', '麺類', '揚げ物',
    '焼き物', '煮物', 'デザート', '飲み物', 'その他',
  ];

  // スライダー用変数
  double _sliderValue1 = 20;
  double _sliderValue2 = 50;

  // 食材リスト（仮データ）
  final List<Map<String, String>> stockItems = [
    {'name': 'たまねぎ', 'count': '2', 'expiry': '2025/07/01'},
    {'name': 'にんじん', 'count': '3', 'expiry': '2025/06/28'},
    {'name': 'じゃがいも', 'count': '5', 'expiry': '2025/07/05'},
  ];

  void _onBottomNavTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('レシピアプリ'), backgroundColor: Colors.orange),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: [
          buildGeneratePage(),
          buildSearchPage(),
          buildStockPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: '生成'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '検索'),
          BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: '食料庫'),
        ],
      ),
    );
  }

  /// 1. 生成ページ
  Widget buildGeneratePage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 40, color: Colors.orange.shade50, alignment: Alignment.center, child: Text("生成画面")),
          SizedBox(height: 12),
          // 状態付きボタン群
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: buttonLabels.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              Color buttonColor;
              switch (buttonStates[index]) {
                case 1:
                  buttonColor = Colors.deepOrange;
                  break;
                case -1:
                  buttonColor = Colors.orange.shade100;
                  break;
                default:
                  buttonColor = Colors.grey.shade300;
              }
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    if (buttonStates[index] == 0) {
                      buttonStates[index] = 1;
                    } else if (buttonStates[index] == 1) {
                      buttonStates[index] = -1;
                    } else {
                      buttonStates[index] = 0;
                    }
                  });
                },
                child: Text(buttonLabels[index], textAlign: TextAlign.center),
              );
            },
          ),
          SizedBox(height: 24),
          Text("予算: ${_sliderValue1.toInt()} 円"),
          Slider(
            value: _sliderValue1,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${_sliderValue1.toInt()}',
            onChanged: (value) => setState(() => _sliderValue1 = value),
          ),
          Text("調理時間: ${_sliderValue2.toInt()} 分"),
          Slider(
            value: _sliderValue2,
            min: 0,
            max: 120,
            divisions: 24,
            label: '${_sliderValue2.toInt()}',
            onChanged: (value) => setState(() => _sliderValue2 = value),
          ),
          Container(height: 30, color: Colors.orange.shade50, alignment: Alignment.center, child: Text("下帯")),
        ],
      ),
    );
  }

  /// 2. 検索ページ
  Widget buildSearchPage() {
    return Column(
      children: [
        Container(height: 40, color: Colors.orange.shade50, alignment: Alignment.center, child: Text("検索画面")),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'レシピを検索',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              buildRecipeSection("おすすめ", Colors.pink),
              buildRecipeSection("お気に入り", Colors.blue),
              buildRecipeSection("履歴", Colors.green),
            ],
          ),
        ),
        Container(height: 30, color: Colors.orange.shade50, alignment: Alignment.center, child: Text("下帯")),
      ],
    );
  }

  Widget buildRecipeSection(String title, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text('レシピ ${index + 1}')),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 3. 食料庫ページ
  Widget buildStockPage() {
    return Stack(
      children: [
        Column(
          children: [
            Container(height: 40, color: Colors.orange.shade50, alignment: Alignment.center, child: Text("食料庫")),
            Expanded(
              child: ListView.builder(
                itemCount: stockItems.length,
                itemBuilder: (context, index) {
                  final item = stockItems[index];
                  return ListTile(
                    title: Text('${item['name']}（${item['count']}個）'),
                    subtitle: Text('賞味期限: ${item['expiry']}'),
                    trailing: Icon(Icons.edit),
                  );
                },
              ),
            ),
            Container(height: 30, color: Colors.orange.shade50, alignment: Alignment.center, child: Text("下帯")),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              print("食材追加ボタンが押されました");
              // ダイアログなどで追加可能
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.orange,
          ),
        ),
      ],
    );
  }
}

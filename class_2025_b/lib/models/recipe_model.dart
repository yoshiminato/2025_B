

// レシピクラス
class Recipe{

  String? id;                      // Firestore用のドキュメントID
  String title;                    // レシピのタイトル
  String description;              // レシピの説明
  String? imageUrl;                // レシピの画像URL（Firebase StorageのURLなど）
  String? imageBase64;             // レシピの画像のBase64エンコードされた文字列（生成AIの出力受取用）
  Map<String, String> ingredients; // 材料のリスト
  List<String> steps;              // 調理手順のリスト {手順: 所要時間}
  String time;                     // 総所要時間
  String cost;                     // 予算（コスト）
  DateTime createdAt;              // 作成日時
  String? userId;                  // 作成者のUID
  int reviewCount;                 // レビュー数（初期値は0）
  int likeCount;                   // いいね数（初期値は0）
  int taste_ave;                   // 味の平均評価   
  int useful_ave;                  // 作りやすさの平均評価
  int costperformance_ave;         // コストパフォーマンスの平均評価
  int reccommend;                  // おすすめ度 

  
  
  Recipe({
    this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.time,
    required this.cost,
    required this.createdAt,
    this.userId,
    this.reviewCount = 0,
    this.likeCount = 0,
    this.taste_ave = 0,
    this.useful_ave = 0,
    this.costperformance_ave = 0,
    this.reccommend = 0,
  });

  // レシピ生成時刻とユーザIDを新たに登録するメゾッド
  addAdditionalInfo({String? userid}) {
    createdAt = DateTime.now();
    userId = userid;
  }
  // RecipeオブジェクトをMapに変換（Firestore保存用）
  Map<String, dynamic> toMap() {
    // ingredientsMapを2つの配列に分けて保存
    List<String> ingredientNames = ingredients.keys.toList();
    List<String> ingredientAmounts = ingredients.values.toList();
    
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients, // 従来のMap形式も保持（互換性のため）
      'ingredientNames': ingredientNames, // 検索用の材料名配列
      'ingredientAmounts': ingredientAmounts, // 分量配列
      'steps': steps,
      'time': time,
      'cost': cost,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'userId': userId,
      'reviewCount': reviewCount,
      'likeCount': likeCount,
      'taste_ave': taste_ave,
      'useful_ave': useful_ave,
      'costperformance_ave': costperformance_ave,
      'reccommend': reccommend,
    };
  }  // MapからRecipeオブジェクトを作成（Firestore読み込み用）
  factory Recipe.fromMap(Map<String, dynamic> map) {
    Map<String, String> ingredients = {};
    
    // 新しい形式（ingredientNames + ingredientAmounts）がある場合
    if (map.containsKey('ingredientNames') && map.containsKey('ingredientAmounts')) {
      List<String> names = List<String>.from(map['ingredientNames'] as List);
      List<String> amounts = List<String>.from(map['ingredientAmounts'] as List);
      
      // 2つの配列を組み合わせてMapを作成
      for (int i = 0; i < names.length && i < amounts.length; i++) {
        ingredients[names[i]] = amounts[i];
      }
    } 
    // 従来の形式（ingredients Map）がある場合（後方互換性）
    else if (map.containsKey('ingredients')) {
      ingredients = Map<String, String>.from(map['ingredients'] as Map);
    }
    
    return Recipe(
      id: map['id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String?,
      ingredients: ingredients,
      steps: List<String>.from(map['steps'] as List),
      time: map['time'] as String,
      cost: map['cost'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      userId: map['userId'] as String?,
      reviewCount: map['reviewCount'] as int? ?? 0,
      likeCount: map['likeCount'] as int? ?? 0,
      taste_ave: map['taste_ave'] as int? ?? 0,
      useful_ave: map['useful_ave'] as int? ?? 0,
      costperformance_ave: map['costperformance_ave'] as int? ?? 0,
      reccommend: map['reccommend'] as int? ?? 0,
    );
  }
  // RecipeオブジェクトをJSONに変換（API用）?? ユーザの評価履歴をもとにプロンプトするなら使うかも
  Map<String, dynamic> toJson() {
    // ingredientsMapを2つの配列に分けて保存
    List<String> ingredientNames = ingredients.keys.toList();
    List<String> ingredientAmounts = ingredients.values.toList();
    
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients, // 従来のMap形式も保持（互換性のため）
      'ingredientNames': ingredientNames, // 検索用の材料名配列
      'ingredientAmounts': ingredientAmounts, // 分量配列
      'steps': steps,
      'time': time,
      'cost': cost,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'reviewCount': reviewCount,
      'likeCount': likeCount,
      'taste_ave': taste_ave,
      'useful_ave': useful_ave,
      'costperformance_ave': costperformance_ave,
      'reccommend': reccommend,
    };
  }
  // JSONからRecipeオブジェクトを作成（API用）
  factory Recipe.fromJson(Map<String, dynamic> json) {
    Map<String, String> ingredients = {};
    
    // 新しい形式（ingredientNames + ingredientAmounts）がある場合
    if (json.containsKey('ingredientNames') && json.containsKey('ingredientAmounts')) {
      List<String> names = List<String>.from(json['ingredientNames'] as List);
      List<String> amounts = List<String>.from(json['ingredientAmounts'] as List);
      
      // 2つの配列を組み合わせてMapを作成
      for (int i = 0; i < names.length && i < amounts.length; i++) {
        ingredients[names[i]] = amounts[i];
      }
    } 
    // 従来の形式（ingredients Map）がある場合（後方互換性）
    else if (json.containsKey('ingredients')) {
      ingredients = Map<String, String>.from(json['ingredients'] as Map);
    }
    
    return Recipe(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      ingredients: ingredients,
      steps: List<String>.from(json['steps'] as List),
      time: json['time'] as String,
      cost: json['cost'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String?,
      reviewCount: json['reviewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      taste_ave: json['taste_ave'] as int? ?? 0,
      useful_ave: json['useful_ave'] as int? ?? 0,
      costperformance_ave: json['costperformance_ave'] as int? ?? 0,
      reccommend: json['reccommend'] as int? ?? 0,
    );
  }

}

final sampleRecipe1 = Recipe(
  title: "Sample Recipe 1",
  description: "This is a sample recipe description.",
  imageUrl: "https://example.com/sample.jpg",
  ingredients: {"Ingredient 1": "1 cup", "Ingredient 2": "2 tbsp", "Ingredient 3": "3 tsp"},
  steps: ["Step 1", "Step 2", "Step 3"],
  time: "30分",
  cost: "1000円",
  createdAt: DateTime.now(),
  userId: "sampleUserId",
  id: "sampleRecipeId",
  reviewCount: 0,
  likeCount: 0,
  taste_ave: 0,
  useful_ave: 0,
  costperformance_ave: 0,
  reccommend: 0,
);

final sampleRecipe2 = Recipe(
  title: "Sample Recipe 2",
  description: "This is another sample recipe description.",
  imageUrl: "https://example.com/sample2.jpg",
  ingredients: {"Ingredient A": "1 cup", "Ingredient B": "2 tbsp", "Ingredient C": "3 tsp"},
  steps: ["Step A", "Step B", "Step C"],
  time: "25分",
  cost: "800円",
  createdAt: DateTime.now(),
  userId: "sampleUserId2",
  id: "sampleRecipeId2",
  reviewCount: 0,
  likeCount: 0,
  taste_ave: 0,
  useful_ave: 0,
  costperformance_ave: 0,
  reccommend: 0,
);

final sampleRecipe3 = Recipe(
  title: "Sample Recipe 3",
  description: "This is yet another sample recipe description.",
  imageUrl: "https://example.com/sample3.jpg",
  ingredients: {"Ingredient X": "1 cup", "Ingredient Y": "2 tbsp", "Ingredient Z": "3 tsp"},
  steps: ["Step X", "Step Y", "Step Z"],
  time: "20分",
  cost: "600円",
  createdAt: DateTime.now(),
  userId: "sampleUserId3",
  id: "sampleRecipeId3",
  reviewCount: 0,
  likeCount: 0,
  taste_ave: 0,
  useful_ave: 0,
  costperformance_ave: 0,
  reccommend: 0,
);

final sampleRecipe4 = Recipe(
  title: "Sample Recipe 4",
  description: "This is a different sample recipe description.",
  imageUrl: "https://example.com/sample4.jpg",
  ingredients: {"Ingredient I": "1 cup", "Ingredient II": "2 tbsp", "Ingredient III": "3 tsp"},
  steps: ["Step I", "Step II", "Step III"],
  time: "35分",
  cost: "1200円",
  createdAt: DateTime.now(),
  userId: "sampleUserId4",
  id: "sampleRecipeId4",
  reviewCount: 0,
  likeCount: 0,
  taste_ave: 0,
  useful_ave: 0,
  costperformance_ave: 0,
  reccommend: 0,
);

final sampleRecipe5 = Recipe(
  title: "Sample Recipe 5",
  description: "This is another different sample recipe description.",
  imageUrl: "https://example.com/sample5.jpg",
  ingredients: {"Ingredient M": "1 cup", "Ingredient N": "2 tbsp", "Ingredient O": "3 tsp"},
  steps: ["Step M", "Step N", "Step O"],
  time: "15分",
  cost: "500円",
  createdAt: DateTime.now(),
  userId: "sampleUserId5",
  id: "sampleRecipeId5",
  reviewCount: 0,
  likeCount: 0,
  taste_ave: 0,
  useful_ave: 0,
  costperformance_ave: 0,
  reccommend: 0,
);

final sampleRecipe6 = Recipe(
  title: "Sample Recipe 6",
  description: "This is yet another different sample recipe description.",
  imageUrl: "https://example.com/sample6.jpg",
  ingredients: {"Ingredient P": "1 cup", "Ingredient Q": "2 tbsp", "Ingredient R": "3 tsp"},
  steps: ["Step P", "Step Q", "Step R"],
  time: "40分",
  cost: "900円",
  createdAt: DateTime.now(),
  userId: "sampleUserId6",
  id: "sampleRecipeId6",
  reviewCount: 0,
  likeCount: 0,
  taste_ave: 0,
  useful_ave: 0,
  costperformance_ave: 0,
  reccommend: 0,
);

final sampleRecipe7 = Recipe(
  title: "Sample Recipe 7",
  description: "This is a unique sample recipe description.",
  imageUrl: "https://example.com/sample7.jpg",
  ingredients: {"Ingredient S": "1 cup", "Ingredient T": "2 tbsp", "Ingredient U": "3 tsp"},
  steps: ["Step S", "Step T", "Step U"],
  time: "22分",
  cost: "700円",
  createdAt: DateTime.now(),
  userId: "sampleUserId7",
  id: "sampleRecipeId7",
  reviewCount: 0,
  likeCount: 0,
  taste_ave: 0,
  useful_ave: 0,
  costperformance_ave: 0,
  reccommend: 0,
);

final sampleRecipe8 = Recipe(
  title: "Sample Recipe 8",
  description: "This is another unique sample recipe description.",
  imageUrl: "https://example.com/sample8.jpg",
  ingredients: {"Ingredient V": "1 cup", "Ingredient W": "2 tbsp", "Ingredient X": "3 tsp"},
  steps: ["Step V", "Step W", "Step X"],
  time: "28分",
  cost: "1100円",
  createdAt: DateTime.now(),
  userId: "sampleUserId8",
  id: "sampleRecipeId8",
  reviewCount: 0,
  likeCount: 0,
  taste_ave: 0,
  useful_ave: 0,
  costperformance_ave: 0,
  reccommend: 0,
);

final sampleRecipe9 = Recipe(
  title: "Sample Recipe 9",
  description: "This is yet another unique sample recipe description.",
  imageUrl: "https://example.com/sample9.jpg",
  ingredients: {"Ingredient Y": "1 cup", "Ingredient Z": "2 tbsp", "Ingredient AA": "3 tsp"},
  steps: ["Step Y", "Step Z", "Step AA"],
  time: "18分",
  cost: "650円",
  createdAt: DateTime.now(),
  userId: "sampleUserId9",
  id: "sampleRecipeId9",
  reviewCount: 0,
  likeCount: 0,
  taste_ave: 0,
  useful_ave: 0,
  costperformance_ave: 0,
  reccommend: 0,
);

final sampleRecipe10 = Recipe(
  title: "Sample Recipe 10",
  description: "This is a final unique sample recipe description.",
  imageUrl: "https://example.com/sample10.jpg",
  ingredients: {"Ingredient AB": "1 cup", "Ingredient AC": "2 tbsp", "Ingredient AD": "3 tsp"},
  steps: ["Step AB", "Step AC", "Step AD"],
  time: "32分",
  cost: "850円",
  createdAt: DateTime.now(),
  userId: "sampleUserId10",
  id: "sampleRecipeId10",
  reviewCount: 0,
  likeCount: 0,
  taste_ave: 0,
  useful_ave: 0,
  costperformance_ave: 0,
  reccommend: 0,
);

final sampleRecipes = [
  sampleRecipe1,
  sampleRecipe2,
  sampleRecipe3,
  sampleRecipe4,
  sampleRecipe5,
  sampleRecipe6,
  sampleRecipe7,
  sampleRecipe8,
  sampleRecipe9,
  sampleRecipe10,
];
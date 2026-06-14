import 'dart:io';
import 'package:class_2025_b/error_handle.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:class_2025_b/states/selected_image_state.dart';
import 'package:class_2025_b/states/recipe_id_state.dart';
import 'package:class_2025_b/states/user_state.dart';
import 'package:class_2025_b/services/database_service.dart';
import 'package:class_2025_b/services/storage_service.dart';
import 'package:class_2025_b/models/comment_model.dart';
part 'comment_state.g.dart';

// 編集中のコメントを管理するプロバイダ
@riverpod
class CurrentCommentNotifier extends _$CurrentCommentNotifier {
  @override
  String build() {
    return ""; // 初期値は空文字
  }

  // コメントを更新するメソッド
  void updateComment(String newComment) {
    state = newComment; // コメントを更新
  }

  // コメントを更新するメソッド
  Future<void> addComment(TextEditingController controller) async {

    // DatabaseServiceとStorageServiceのインスタンスを取得
    final dbService = DatabaseService();
    final strageService = StorageService();

    final text = state;

    final recipeId = ref.read(recipeIdProvider);

    if (text.isEmpty) {
      throw Exception("コメントが空です");
    }

    if (recipeId == null) {
      throw Exception("レシピIDが設定されていません");
    }

    final selectedImageType = ref.read(selectedImageTypeProvider);
    final capturedImage = ref.read(capturedImageProvider);
    final uploadedImage = ref.read(uploadedImageProvider);

    late final String? imagePath;

    if(selectedImageType == SelectedImageType.captured && capturedImage != null) {
      imagePath = await strageService.storeImageAndGetUrl(capturedImage, "comments");
    }
    else if(selectedImageType == SelectedImageType.uploaded && uploadedImage != null) {
      imagePath = await strageService.storeUint8ListImageAndGetUrl(uploadedImage, "comments");
    }
    else {
      imagePath = null; // 画像がない場合は空文字
    }

    // ユーザー情報を取得
    final user = ref.read(userProvider);

    // コメントオブジェクトを作成
    final comment = Comment(
      id: null,
      recipeId: recipeId,
      userId: (user == null) ? null : user.uid, // ユーザーIDがnullの場合は匿名とする
      content: text,
      imagePath: imagePath,
      timestamp: DateTime.now()
    );

    // コメントをデータベースに保存
    try {
      dbService.addComment(comment);
    } catch (e) {
      handleError(e);
      throw Exception("コメントの保存に失敗しました: $e");
    }

    // コメント送信後の処理
    controller.clear(); // コメント入力欄をクリア
    ref.read(selectedImageTypeProvider.notifier).state = SelectedImageType.none; // 選択された画像タイプをクリア  
    ref.read(capturedImageProvider.notifier).state = null; // キャプチャされた画像をクリア
    ref.read(uploadedImageProvider.notifier).state = null; // アップロードされた
    _clearComment(); // コメントの状態をクリア

    ref.read(commentsRefreshTrigger.notifier).state++; // コメント送信後にリフレッシュ
  }

  // コメントをクリアするメソッド
  void _clearComment() {
    state = "";
  }

  bool get isEmpty {
    return state.isEmpty; // コメントが空かどうか
  }

  String get currentComment {
    return state; // 現在のコメントを取得
  }
}


// コメントの更新トリガーを管理するプロバイダ
final commentsRefreshTrigger = StateProvider<int>((ref) => 0);


// コメント一覧の状態を管理するプロバイダ
final commentsNotifierProvider = FutureProvider<List<Comment>> ((ref) async {

  // DatabaseServiceのインスタンスを作成
  final dbService = DatabaseService();

  // レシピIDを取得
  final recipeId = ref.watch(recipeIdProvider);
  // コメントの更新トリガーを監視
  ref.watch(commentsRefreshTrigger);

  if (recipeId == null) {
    return []; // レシピIDがない場合は空のリストを返す
  }
  
  try {
    final comments = await dbService.getCommentsByRecipeId(recipeId);

    for(Comment comment in comments) {
      // レビュー情報を取得
      if (comment.userId != null) {
        final uid = comment.userId!;
        final rid = ref.read(recipeIdProvider);//comment.recipeId;
        if (rid == null) {
          debugPrint("レシピIDがnullです。レビュー情報を取得できません。");
          continue; // レシピIDがnullの場合はスキップ
        }
        final review = await dbService.getReviewByRecipeIdAndUserId(uid, rid);

        comment.review = review; // コメントにレビュー情報を追加
      } else {
        comment.review = null; // ユーザーIDがない場合はレビューもnull
      }
    }

    return comments;
  } 
  catch (e) {
    handleError(e);
    throw Exception("コメントの取得に失敗しました: $e");
  }
});



import 'dart:io';
import 'dart:typed_data';
import 'package:class_2025_b/error_handle.dart';
import 'package:class_2025_b/global.dart';
import 'package:class_2025_b/routers/router.dart';
import 'package:class_2025_b/states/recipe_id_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/models/comment_model.dart';
import 'package:class_2025_b/models/review_model.dart';
import 'package:class_2025_b/states/comment_state.dart';
import 'package:class_2025_b/states/selected_image_state.dart';
import 'package:class_2025_b/widgets/star_widget.dart';
import 'package:file_picker/file_picker.dart';

class CommentsWidget extends HookConsumerWidget {

  const CommentsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final recipeId = ref.watch(recipeIdProvider);

    // レシピIDがnullの場合は何も表示しない
    if (recipeId == null) {
      return const SizedBox.shrink();
    }

    // テキスト入力用のコントローラーを定義
    final textController = useTextEditingController();

    // コメントの状態プロバイダとそのNotifierを取得
    ref.watch(currentCommentNotifierProvider);
    final notifier = ref.read(currentCommentNotifierProvider.notifier);

    // 選択された画像の状態を取得
    final capturedImage = ref.watch(capturedImageProvider);

    final uploadedImage = ref.watch(uploadedImageProvider);

    // コメント一覧の取得
    final commentsPanel = ref.watch(commentsNotifierProvider).when(
      data: (data) => Column(children: data.map((comment) => CommentCard(comment: comment)).toList()),
      error: (e, s) => Center(child: Text("エラーが発生しました: $e")), 
      loading: () => const Center(child: CircularProgressIndicator()),
    );

    // 削除ボタンの定義
    final deleteButton = Positioned(
      // 画像との相対位置
      top: -8,
      right: -8,
      child: IconButton(
        onPressed: () {
          ref.read(uploadedImageProvider.notifier).state = null;
          ref.read(capturedImageProvider.notifier).state = null;
          ref.read(selectedImageTypeProvider.notifier).state = SelectedImageType.none;
        },
        icon: Container(
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 16,
          ),
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 24,
          minHeight: 24,
        ),
      ),
    );

    final selectedImageType = ref.watch(selectedImageTypeProvider);

    // 画像パネル - 画像が選択されていない場合は空のウィジェットを表示
    final imagePanel = selectedImageType == SelectedImageType.none 
      ?
      SizedBox.shrink()
      :
      SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          children: [
            // 画像本体
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: switch (selectedImageType) {
                  SelectedImageType.captured when capturedImage != null =>
                    Image.file(capturedImage, fit: BoxFit.cover),
                  SelectedImageType.uploaded when uploadedImage != null =>
                    Image.memory(uploadedImage, fit: BoxFit.cover),
                  _ => const SizedBox.shrink(),}
              ),
            ),
            // 削除ボタン
            deleteButton,
          ],
        )
      );

    // テキストフィールド
    final textField = TextField(
      controller: textController,
      style: const TextStyle(fontSize: 12),
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText: 'コメントを入力',
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 8, right: 4, top: 2, bottom: 2),
          child: Icon(Icons.search, size: 16),
        ),
        border: OutlineInputBorder(
        ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      ),
      onChanged: (value) => notifier.updateComment(value),
      minLines: 1,
      maxLines: 5,
    );
    
    // テキストフィールドのコンテナ
    final textFieldContainer = SizedBox(
      height: 35, // テキストフィールドの幅を指定
      child: textField,
    );

    // カメラキャプチャボタン
    final captureButton = IconButton(
      icon: const Icon(Icons.camera_alt, size: 30, color: Colors.grey),
      onPressed: kIsWeb ?
        () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("webではカメラは使用できません"))) :
        () => AppRouter.goToCameraCapture(context),
    );

    // アップロードボタン
    final uploadButton = IconButton(
      icon: Icon(Icons.add),
      onPressed: 
        () async {
          try {
            debugPrint("ファイル選択を開始します");
            
            // より詳細な設定でファイルピッカーを呼び出す
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
              allowMultiple: false,
            );
            
            debugPrint("ファイル選択結果: ${result != null ? '成功' : 'キャンセル'}");
            
            if (result != null && result.files.isNotEmpty) {
              final file = result.files.first;
              debugPrint("選択されたファイル: ${file.name}");
              
              if (kIsWeb) {
                // Webはbytesで扱う
                final Uint8List? fileBytes = file.bytes;
                if (fileBytes != null) {
                  debugPrint("Web: ファイルサイズ ${fileBytes.length} bytes");
                  ref.read(uploadedImageProvider.notifier).state = fileBytes;
                  ref.read(selectedImageTypeProvider.notifier).state = SelectedImageType.uploaded;
                  debugPrint("Web: 画像を設定完了");
                } else {
                  debugPrint("Web: ファイルのbytesがnullです");
                }
              } else {
                // モバイルはpathでFileを扱う
                final filePath = file.path;
                debugPrint("Android: ファイルパス $filePath");
                if (filePath != null) {
                  final fileObj = File(filePath);
                  final exists = fileObj.existsSync();
                  debugPrint("Android: ファイル存在確認 $exists");
                  if (exists) {
                    ref.read(capturedImageProvider.notifier).state = fileObj;
                    ref.read(selectedImageTypeProvider.notifier).state = SelectedImageType.captured;
                    debugPrint("Android: 画像を設定完了");
                  } else {
                    debugPrint("Android: ファイルが存在しません");
                  }
                } else {
                  debugPrint("Android: ファイルパスがnullです");
                }
              }
            } else {
              debugPrint("ファイル選択がキャンセルされました");
            }
          } catch (e, stackTrace) {
            debugPrint("ファイル選択エラー: $e");
            debugPrint("スタックトレース: $stackTrace");
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("ファイル選択エラー: $e")),
              );
            }
          }
        },
    );

    // 送信ボタン
    final submitButton = ElevatedButton(
      // テキストが空でない場合のみコメント投稿処理が有効(ボタンが押せる)
      onPressed: !notifier.isEmpty ? () async {
        try{
          await notifier.addComment(textController);
        }
        catch (e) {
          debugPrint("コメント送信エラー: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("コメントの送信中にエラーが発生しました: $e")),
          );
        }
      } : null,
      style: ElevatedButton.styleFrom(
       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
       minimumSize: const Size(65, 40),  // 最小サイズを指定
       backgroundColor: Colors.blue[100],   // ボタンの背景色),
      ),
      child: const Text("送信", style: TextStyle(fontSize: 10), textAlign: TextAlign.center,),
    );

    // 送信ボタンのコンテナ - 固定幅を指定
    final submitButtonContainer = SizedBox(
      width: 60,
      child: submitButton,
    );

    // 入力ウィジェットをまとめたウィジェット(カメラボタン, テキストフィールド, 送信ボタン)
    final inputPanel = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        captureButton,
        uploadButton,
        SizedBox(width: 8),
        Expanded(child: textFieldContainer),
        SizedBox(width: 8),
        submitButtonContainer,
      ],
    );

    // コメント関連ウィジェット全般をまとめたコンテナ
    final commentsContainer = Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imagePanel,
          const SizedBox(height: 16),
          inputPanel,
          const SizedBox(height: 16),
          const Text("コメント一覧", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),          
          const SizedBox(height: 8),
          commentsPanel
        ],
      ),
    );

    return commentsContainer;
  }
}

class CommentCard extends StatelessWidget {

  const CommentCard({super.key, required this.comment});

  final Comment comment;

  @override


  Widget build(BuildContext context) {

    String? url;

    final path = comment.imagePath;

    if (path != null) {
      url = getUrl(storageHost, storagePort, path);
    }

    // コメントで表示する画像
    final image = url != null 
      // 画像が存在する場合は表示
      ? Image.network(ensureAltMediaParameter(url), fit: BoxFit.cover)

      // 画像が存在しない場合は画像アイコンを表示
      : Container(color: Colors.grey[300],child: const Icon(Icons.image));

    const imageSize = 60.0;

    // 画像のサイズを指定
    final imageContainer = SizedBox(
      width: imageSize,
      height: imageSize,
      child: image,
    );

    Review? review = comment.review;
    double? reccomend;

    if(review != null){
      reccomend = review.tasteRating * Review.tasteweight +
        review.easeRating * Review.easeweight +
        review.cospRating * Review.cospweight;
    }

    // テキストコメントのコンテナ(コメント, 投稿日時)
    final textCommentContainer = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StarWidget(rating: reccomend),
        Text(comment.content),
        const SizedBox(height: 4),
        Text(
          // 投稿日時を日付のみ表示
          comment.timestamp.toString().split(' ')[0],
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );

    

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),                          
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // 画像部分 - シンプルな固定サイズ
            imageContainer,
            const SizedBox(width: 12),
            // テキスト部分
            Expanded(
              child: textCommentContainer,
            ),
          ],
        ),
      ),
    );
  }
}
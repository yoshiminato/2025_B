import 'dart:io';
import 'package:class_2025_b/routers/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/models/comment_model.dart';
import 'package:class_2025_b/screens/camera_capture_screen.dart';
import 'package:class_2025_b/services/storage_service.dart';
import 'package:class_2025_b/services/database_service.dart';
import 'package:class_2025_b/states/user_state.dart';
import 'package:class_2025_b/states/comment_state.dart';


class CommentsWidget extends HookConsumerWidget {

  const CommentsWidget({super.key, required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // テキスト入力用のコントローラーを定義
    final textController = useTextEditingController();

    textController.text = ref.read(commentProvider);

    final selectedImage = ref.watch(selectedImageProvider);

    // ログイン状態を監視（読み取り専用ではなく監視）
    final signedIn = ref.watch(signedInProvider);    // サービスをuseMemoizedで固定
    final storageService = StorageService();//useMemoized(() => StorageService(), []);
    final dbService = DatabaseService();//useMemoized(() => DatabaseService(), []);

    // 更新トリガー
    final refreshTrigger = useState<int>(0);

    // コメント結果を状態として管理
    final commentResult = useState<Widget>(const Center(child: CircularProgressIndicator()));
    

    useEffect(() {
      final futureComment = dbService.getCommentsByRecipeId(recipeId);
      final widget = FutureBuilder(
        future: futureComment,
        builder: (content, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            if(snapshot.error.toString().contains("認証エラー")){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("認証エラー発生, 自動ログアウトしました"),
                ),
              );
            }
            return Center(child: Text("エラーが発生しました: ${snapshot.error}"));
          }

          final comments = snapshot.data as List<Comment>;
          if (comments.isEmpty) {
            return const Center(child: Text("コメントはまだありません"));
          }
          
          return Column(
            children: comments.map((comment) => CommentCard(comment: comment)).toList(),
          );
        }
      );
      
      // 状態を更新
      commentResult.value = widget;
      return null;
    }, [refreshTrigger.value]);

    final imageContainer = selectedImage == null 
    ?
    SizedBox(
      width: 0,
      height: 0,
    )
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
              child: Image.file(
                selectedImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 削除ボタン（右上に配置）
          Positioned(
            top: -8,
            right: -8,
            child: IconButton(
              onPressed: () {
                // selectedImageをnullに初期化
                ref.read(selectedImageProvider.notifier).state = null;
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
          ),
        ],
      ),
    );


    final textField = TextField(
      controller: textController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: "コメントを入力",
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => ref.read(commentProvider.notifier).state = value,
      minLines: 1,
      maxLines: 5,
    );
    

    final captureButton = IconButton(
      icon: const Icon(Icons.camera_alt, size: 30, color: Colors.grey),
      onPressed: () => AppRouter.goToCameraCapture(context)
      );

    final submitButton = ElevatedButton(
      onPressed: signedIn ?
      () async {
        final commentText = ref.read(commentProvider);

        // コメントを送信する処理
        if (commentText.isNotEmpty || selectedImage != null) {
          // ここでコメントを送信する処理を実装
          // 例えば、APIにPOSTリクエストを送るなど

          final user = ref.read(userProvider);

          // 画像URLを格納する変数
          late final String? imageUrl;
          
          if(selectedImage != null) {
            // 画像をストレージに保存
            try{
              imageUrl = await storageService.storeImageAndGetUrl(selectedImage, "comments");
            } 
            catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("画像の保存に失敗しました: ${e.toString()}"),
                ),
              );
            }
          }

          else {
            // 画像が選択されていない場合はnullを設定
            imageUrl = null;
          }                    
          
          // コメントモデルを作成
          final comment = Comment(
            id: null,
            recipeId: recipeId, // ここは実際のレシピIDに置き換える
            userId: user!.uid, // ここは実際のユーザーIDに置き換える
            content: textController.text,
            imageUrl: imageUrl,
            timestamp: DateTime.now(),
          );

          debugPrint("コメント送信: $commentText");

          try{
            // コメントをDBに保存
            await dbService.addComment(comment);
          }
          catch (e) {
            if(e.toString().contains("認証エラー")){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("認証エラー発生, 自動ログアウトしました"),
                ),
              );
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("コメントの保存に失敗しました: ${e.toString()}"),
              ),
            );
            return;
          }
          
          // 更新をトリガー
          refreshTrigger.value++;
          
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('コメントが投稿されました')),
          );

          // 入力フィールドをクリア
          textController.clear();
          ref.read(commentProvider.notifier).state = ""; // コメントもクリア
          ref.read(selectedImageProvider.notifier).state = null; // 画像もクリア
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("コメントまたは画像を入力してください")),
          );
        }
      } :
      null,
      style: ElevatedButton.styleFrom(
       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
       minimumSize: const Size(65, 40),  // 最小サイズを指定
       backgroundColor: Colors.blue[100],   // ボタンの背景色),
      ),
      child: const Text("送信", style: TextStyle(fontSize: 10), textAlign: TextAlign.center,),
    );

    final submitButtonContainer = SizedBox(
      width: 60,
      child: submitButton,
    );

    

    final commentsContainer = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageContainer,
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              captureButton,
              Expanded(
                child: textField,
              ),
              submitButtonContainer,
            ],
          ),
          const SizedBox(height: 16),
          const Text("コメント一覧", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),          const SizedBox(height: 8),
          commentResult.value
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

    // コメントで表示する画像
    final image = comment.imageUrl != null 
      // 画像が存在する場合は表示
      ? Image.network(
          comment.imageUrl!,
          fit: BoxFit.cover,
        ) 
      // 画像が存在しない場合は画像アイコンを表示
      : Container(
          color: Colors.grey[300],
          child: const Icon(Icons.image),
        );

    const imageSize = 60.0;

    // 画像のサイズを指定
    final imageContainer = SizedBox(
      width: imageSize,
      height: imageSize,
      child: image,
    );

    // テキストコメントのコンテナ(コメント, 投稿日時)
    final textCommentContainer = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(comment.content),
        const SizedBox(height: 4),
        Text(
          comment.timestamp.toString(),
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
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:class_2025_b/services/database_service.dart';
import 'package:class_2025_b/services/storage_service.dart';
import 'package:class_2025_b/models/comment_model.dart';


// 撮影した画像を共有するためのProvider
final selectedImageProvider = StateProvider<File?>((ref) => null);

class CommentTestScreen extends HookConsumerWidget {
  const CommentTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // データベースサービスとストレージサービスのインスタンスを取得
    final dbService = DatabaseService();
    final storageService = StorageService();

    // テキスト入力用のコントローラーを定義
    final textController = useTextEditingController();

    // 画像のプロバイダから値を取得
    final selectedImage = ref.watch(selectedImageProvider);

    // 入力文字列の
    final textState = useState<String>('');

    // データベースからコメントのリストを取得
    final  comments = useFuture(dbService.getComments('sample_recipe_id'));

    // 画面のコンテンツ
    final content = Padding(
      padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            
            // テキストフィールド(コメント入力用)
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'コメントを入力',
                border: OutlineInputBorder(),
                 // 画像選択をリセット
              ),
              maxLines: 3,
              onChanged: (value) => textState.value = value,
            ),

            const SizedBox(height: 20),
            
            // 撮影ボタン
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<File>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraCaptureScreen(),
                  ),
                );
                
                if (result != null) {
                  ref.read(selectedImageProvider.notifier).state = result;
                }
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('写真を撮影'),
            ),
            
            const SizedBox(height: 20),
            
            // 選択された画像の表示
            if (selectedImage != null) ...[
              const Text('撮影した画像:'),
              const SizedBox(height: 10),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    selectedImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  ref.read(selectedImageProvider.notifier).state = null;
                },
                child: const Text('画像を削除'),
              ),
            ] else ...[
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('画像が選択されていません'),
                ),
              ),
            ],
            
            // 送信ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (selectedImage != null || textController.text.isNotEmpty)
                  ? () async {

                    // 画像URLを格納する変数
                    late final String? imageUrl;
                    
                    if(selectedImage != null) {
                      // 画像をストレージに保存
                      imageUrl = await storageService.storeImageAndGetUrl(selectedImage, "comments");
                    }
                    else {
                      // 画像が選択されていない場合はnullを設定
                      imageUrl = null;
                    }

                    // コメントモデルを作成(実際にはユーザID,レシピIDともに適切な値に置き換える必要があります)
                    final comment = Comment(
                      id: null,
                      recipeId: 'example_recipe_id', // ここは実際のレシピIDに置き換える
                      userId: 'example_user_id', // ここは実際のユーザーIDに置き換える
                      content: textController.text,
                      imageUrl: imageUrl,
                      timestamp: DateTime.now(),
                    );
                    
                    // コメントをDBに保存
                    await dbService.addComment(comment);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('コメントが投稿されました')),
                    );

                    // リセット
                    textController.clear();
                    textState.value = '';
                    ref.read(selectedImageProvider.notifier).state = null;
                  }

                : null, // 条件を満たさない場合はnullにしてボタンを無効化


                child: const Text('投稿'),
              ),
            ),

            comments.hasData
            ? 
            Column(
              children: [
                for(final comment in comments.data!)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8.0),                          
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // 画像部分 - シンプルな固定サイズ
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: (comment.imageUrl != null) 
                              ? Image.network(
                                  comment.imageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image),
                                ),
                          ),
                          const SizedBox(width: 12),
                          // テキスト部分
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment.content),
                                const SizedBox(height: 4),
                                Text(
                                  comment.timestamp.toString(),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              ]
            )
            : 
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );

    return Scaffold(
      appBar: AppBar(
        title: const Text('コメントテスト'),
      ),
      body: SingleChildScrollView(
        child: content,
      ),  
    );
  }
}

// 撮影専用画面
class CameraCaptureScreen extends HookConsumerWidget {
  const CameraCaptureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraController = useState<CameraController?>(null);
    final isCameraInitialized = useState(false);
    final isTakingPicture = useState(false);
    final capturedImage = useState<File?>(null);

    // カメラの初期化
    useEffect(() {
      Future<void> initializeCamera() async {
        try {
          final cameras = await availableCameras();
          if (cameras.isNotEmpty) {
            final controller = CameraController(
              cameras.first,
              ResolutionPreset.medium,
            );
            
            await controller.initialize();
            cameraController.value = controller;
            isCameraInitialized.value = true;
          }
        } catch (e) {
          debugPrint('カメラ初期化エラー: $e');
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('カメラエラー'),
                content: Text('カメラの初期化に失敗しました: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      }
      
      initializeCamera();
      
      return () {
        cameraController.value?.dispose();
      };
    }, []);

    // 撮影処理
    Future<void> takePicture() async {
      if (cameraController.value == null || !isCameraInitialized.value) return;
      
      try {
        isTakingPicture.value = true;
        
        final XFile image = await cameraController.value!.takePicture();
        final File file = File(image.path);
        capturedImage.value = file;
        
        debugPrint('撮影完了: ${image.path}');
        
      } catch (e) {
        debugPrint('撮影エラー: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('撮影に失敗しました: $e')),
          );
        }
      } finally {
        isTakingPicture.value = false;
      }
    }

    // 撮影後の確認画面
    if (capturedImage.value != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('撮影結果'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                child: Image.file(
                  capturedImage.value!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        capturedImage.value = null;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text('取り直す'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(capturedImage.value);
                      },
                      child: const Text('この画像を使用'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }    // カメラ撮影画面
    return Scaffold(
      appBar: AppBar(
        title: const Text('写真撮影'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                child: isCameraInitialized.value && cameraController.value != null
                    ? CameraPreview(cameraController.value!)
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ),            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 戻るボタン
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        backgroundColor: Colors.grey[300],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: Colors.black),
                          SizedBox(width: 8),
                          Text('戻る', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                    // 撮影ボタン
                    ElevatedButton(
                      onPressed: isCameraInitialized.value && !isTakingPicture.value
                          ? takePicture
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                        shape: const CircleBorder(),
                        backgroundColor: Colors.white,
                      ),
                      child: isTakingPicture.value
                          ? const CircularProgressIndicator()
                          : const Icon(
                              Icons.camera_alt,
                              size: 30,
                              color: Colors.black,
                            ),
                    ),
                    // 空のスペース（レイアウト調整用）
                    const SizedBox(width: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
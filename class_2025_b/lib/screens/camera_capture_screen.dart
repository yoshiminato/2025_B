import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/routers/router.dart';


// 撮影した画像を共有するためのProvider
final selectedImageProvider = StateProvider<File?>((ref) => null);

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
                    onPressed: () => AppRouter.goToHome(context),
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
            onPressed: () => AppRouter.goToHome(context),
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
                        ref.read(selectedImageProvider.notifier).state = capturedImage.value;
                        AppRouter.goToHome(context);
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
          onPressed: () => AppRouter.goToHome(context),
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
                      onPressed: () => AppRouter.goToHome(context),
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
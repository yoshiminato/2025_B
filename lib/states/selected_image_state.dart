import 'package:class_2025_b/states/recipe_id_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:io';
import 'dart:typed_data';

enum SelectedImageType{
  none,
  captured,
  uploaded
}

// 撮影した画像を共有するためのProvider
final selectedImageProvider = StateProvider<File?>((ref) => null);

// 選択されている画像のタイプを保存するプロバイダ
final selectedImageTypeProvider = StateProvider<SelectedImageType>((ref) {
  ref.watch(recipeIdProvider); // 依存関係を追加して、recipeIdが更新されたときに再評価されるようにする
  return SelectedImageType.none;
});

// 撮影した画像を共有するためのProvider
final capturedImageProvider = StateProvider<File?>((ref) {
  ref.watch(recipeIdProvider); // 依存関係を追加して、recipeIdが更新されたときに再評価されるようにする
  return null;
});

// アップロードされた画像のデータを保存するプロバイダ
final uploadedImageProvider = StateProvider<Uint8List?>((ref) {
  ref.watch(recipeIdProvider); // 依存関係を追加して、recipeIdが更新されたときに再評価されるようにする
  return null;
});
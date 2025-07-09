import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:io';
import 'dart:typed_data';

enum SelectedImageType{
  captured,
  uploaded
}

// 撮影した画像を共有するためのProvider
final selectedImageProvider = StateProvider<File?>((ref) => null);

// 選択されている画像のタイプを保存するプロバイダ
final selectedImageTypeProvider = StateProvider<SelectedImageType?>((ref) => null);

// 撮影した画像を共有するためのProvider
final capturedImageProvider = StateProvider<File?>((ref) => null);

// アップロードされた画像のデータを保存するプロバイダ
final uploadedImageProvider = StateProvider<Uint8List?>((ref)=>null);
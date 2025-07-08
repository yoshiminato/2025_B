import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:io';

// 撮影した画像を共有するためのProvider
final selectedImageProvider = StateProvider<File?>((ref) => null);
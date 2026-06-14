import 'dart:convert';
import 'dart:io';
import 'package:class_2025_b/error_handle.dart';
import 'package:class_2025_b/global.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService{

  // base64形式の画像をFirebase Storageに保存し、ダウンロードURLを返すメソッド
  Future<String?> storeBase64ImageAndGetUrl(String base64String, String folder) async {
    try{
      // Base64文字列の検証
      if (base64String.isEmpty) {
        debugPrint("Base64文字列が空です。画像を保存できません。");
        return null; // 空の文字列の場合はnullを返す
      }
      Uint8List imageBytes = base64Decode(base64String);
      String filename = const Uuid().v4();
      Reference storageRef = FirebaseStorage.instance.ref().child('$folder/$filename.png');
      await storageRef.putData(imageBytes, SettableMetadata(contentType: "image/png"));
      String downloadUrl = await storageRef.getDownloadURL();
      String path = extractPathFromUrl(downloadUrl);
      debugPrint("画像アップロード成功: $path");
      return path;    
    }
    catch (e) {
      debugPrint("画像保存エラー: $e");
      handleError(e);
      throw Exception('画像の保存に失敗しました: ${e.toString()}');
    }
  }

  // File型の画像データをFirebase Storageに保存し、ダウンロードURLを返す
  Future<String> storeImageAndGetUrl(File image, String folder) async {
    //画像のIDを生成
    final uuid = Uuid().v4();
    try{
      //folderという保存しているところへの道を参照
      final storageRef = FirebaseStorage.instance.ref().child(folder).child(uuid);
      //imageをfolderへ保存
      await storageRef.putFile(image);
      final url = await storageRef.getDownloadURL();
      String path = extractPathFromUrl(url);
      debugPrint("画像アップロード成功: $path");
      return path;
    }
    catch (e) {
      handleError(e);
      throw Exception('画像の保存に失敗しました: ${e.toString()}');
    }
  }

  // Uint8List型の画像データをFirebase Storageに保存し、ダウンロードURLを返す
  Future<String> storeUint8ListImageAndGetUrl(Uint8List imageBytes, String folder) async {
    final uuid = const Uuid().v4();
    try {
      final storageRef = FirebaseStorage.instance.ref().child(folder).child('$uuid.png');
      await storageRef.putData(imageBytes, SettableMetadata(contentType: "image/png"));
      final url = await storageRef.getDownloadURL();
      String path = extractPathFromUrl(url);
      debugPrint("画像アップロード成功: $path");
      return path;
    } catch (e) {
      handleError(e);
      throw Exception('Uint8List画像の保存に失敗しました: ${e.toString()}');
    }
  }
}
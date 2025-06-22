import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class StorageService{

  // base64形式の画像をFirebase Storageに保存し、ダウンロードURLを返すメソッド
  Future<String> storeBase64ImageAndGetUrl(String base64String, String folder) async {
    
    try{
      
      // Base64文字列の検証
      if (base64String.isEmpty) {
        throw Exception("Base64文字列が空です");
      }
      
      Uint8List imageBytes = base64Decode(base64String);

      String filename = const Uuid().v4();
      Reference storageRef = FirebaseStorage.instance.ref().child('$folder/$filename.png');
      await storageRef.putData(imageBytes, SettableMetadata(contentType: "image/png"));
      String downloadUrl = await storageRef.getDownloadURL();

      debugPrint("画像アップロード成功: $downloadUrl");

      return downloadUrl;
    }
    catch (e) {
      // エラーが発生した場合はサンプル画像URLを返す
      debugPrint("画像アップロードでエラー: $e");
      debugPrint("エラータイプ: ${e.runtimeType}");
      final fallbackImageUrl = "https://picsum.photos/300/200";
      debugPrint("フォールバック画像URL: $fallbackImageUrl");
      return fallbackImageUrl;
    }
  }


  Future<String> storeImageAndGetUrl(File image, String folder) async {
    
    // モックデータを返す
    return Future.value("https://picsum.photos/300/200");
  }

}


void main(){
  debugPrint("StorageServiceが初期化されました");
}
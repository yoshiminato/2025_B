import 'dart:convert';
import 'dart:io';
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

      debugPrint("画像アップロード成功: $downloadUrl");

      return downloadUrl;    }
    catch (e) {
      // 認証エラーの場合の特別な処理
      if (e.toString().contains('UNAUTHENTICATED') || 
          e.toString().contains('INVALID_REFRESH_TOKEN')) {
        debugPrint("Firebase Storage認証エラーが発生しました: $e");
        try{
          await FirebaseAuth.instance.signOut();
          debugPrint("自動ログアウトを実行しました");
          }
        catch (signOutError) {
          debugPrint("ログアウトエラー: $signOutError");
        }
        // 認証エラーの場合は例外を投げる
        throw Exception('認証エラー: 再ログインしてください');
      }
      throw Exception('画像の保存に失敗しました: ${e.toString()}');
    }
  }


  Future<String> storeImageAndGetUrl(File image, String folder) async {
    
    //画像のIDを生成
    final uuid = Uuid().v4();

    try{
      //folderという保存しているところへの道を参照
      final storageRef = FirebaseStorage.instance.ref().child(folder).child(uuid);

      //imageをfolderへ保存
      await storageRef.putFile(image);


      final url = await storageRef.getDownloadURL();
      debugPrint("取得したURLは$url");

      //保存した画像へのURLを返す
      return url;
    }
    catch (e) {
      if (e.toString().contains('UNAUTHENTICATED') || 
          e.toString().contains('INVALID_REFRESH_TOKEN')) {
        debugPrint("認証エラーが発生しました。再ログインが必要です: ${e.toString()}");
        // FirebaseAuthからログアウト
        try {
          await FirebaseAuth.instance.signOut();
          debugPrint("自動ログアウトを実行しました");
        } catch (signOutError) {
          debugPrint("ログアウトエラー: $signOutError");
        }
        throw Exception('認証エラー: 再ログインしてください');
      }
      throw Exception('画像の保存に失敗しました: ${e.toString()}');

    }
  }

}


void main(){
  debugPrint("StorageServiceが初期化されました");
}
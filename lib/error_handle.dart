import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';


// 認証エラーの場合に自動ログアウト
void handleError(Object e) async{
  // エラーダイアログを表示
  // 認証エラーの場合の特別な処理
  if (e.toString().contains('UNAUTHENTICATED') || 
      e.toString().contains('INVALID_REFRESH_TOKEN')) {
    debugPrint("認証エラーが発生しました。再ログインが必要です: ${e.toString()}");
    // FirebaseAuthからログアウト
    try {
      await FirebaseAuth.instance.signOut();
    } catch (signOutError) {
      debugPrint("ログアウトエラー: $signOutError");
    }
    throw Exception('認証エラー: 再ログインしてください');
  }
  
  // その他のエラーの場合
  debugPrint("エラー: ${e.toString()}");
  debugPrint("エラータイプ: ${e.runtimeType}");
}
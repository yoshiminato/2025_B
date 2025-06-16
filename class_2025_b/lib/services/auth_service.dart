import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';


/// 通信の流れをまとめておくサービスクラス
class AuthService {
  /// サインイン
  Future<bool> googleSignIn() async {

    const clientId = '281366495345-6ds3p8dv4g95gqqebiquskk0su5nfe6p.apps.googleusercontent.com';

    // アプリが知りたい情報
    const scopes = [
      'openid', // 他サービス連携用のID
      'profile', // 住所や電話番号
      'email', // メールアドレス
    ];


    // Googleでサインイン の画面へ飛ばす
    final request = GoogleSignIn(
      clientId: kIsWeb ? clientId : null, // Webの場合はクライアントIDを指定
      scopes: scopes
    );

    final response = await request.signIn();

    // 受け取ったデータの中からアクセストークンを取り出す
    final authn = await response?.authentication;
    final accessToken = authn?.accessToken;

    final idToken = authn?.idToken;

    // アクセストークンが null だったら中止
    if (accessToken == null) {
      return false;
    }

    /* Firebase と通信 */

    // Firebaseへアクセストークンを送る
    final oAuthCredential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken,
    );

    await FirebaseAuth.instance.signInWithCredential(
      oAuthCredential,
    );

    

    return true;
    
  }

  /// サインアウト
  Future<void> signOut() async {
    // // Google Sign-Inからもサインアウト
    // final googleSignIn = GoogleSignIn();
    // if (await googleSignIn.isSignedIn()) {
    //   await googleSignIn.signOut();
    //   debugPrint("Google Sign-Inからサインアウト完了");
    // }
    
    // Firebase Authからサインアウト
    await FirebaseAuth.instance.signOut();
    return;
  }

  Future<void> signUp(String email, String passwd) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: passwd,
      );
    } on FirebaseAuthException catch (e) {
      // エラーハンドリング
      debugPrint(e.message);
      rethrow;
    }
  }

  Future<void> signIn(String email, String passwd) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: passwd,
      );
    } on FirebaseAuthException catch (e) {
      // エラーハンドリング
      debugPrint(e.message);
      rethrow;
    }
  }

  bool isEmailVerified() {
    final user = FirebaseAuth.instance.currentUser;
    debugPrint("user: ${user?.email}, emailVerified: ${user?.emailVerified}");
    if (user != null && user.emailVerified) {
      return true;
    }
    return false;
  }
}
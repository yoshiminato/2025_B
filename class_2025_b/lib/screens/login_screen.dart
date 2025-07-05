import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:class_2025_b/routers/router.dart';
import 'package:class_2025_b/states/user_state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/services/auth_service.dart';

/*
2025/07/06 安田　デザイン調整
  ・guestLoginButton = ElevatedButton()
    ⇒guestLoginLink = GestureDetector()に変更
    ※ボタンからリンク風表示に変更ということです。    
    ※ボタンバージョンのコードは残してはいますが、使用しません。
  ・ボタンクラス内でデザインの調整（styleForm追加）
  ・背景色を設定
  ・Scaffold内、いろいろ追加（四角で囲ったり、位置関係調整したり）
  ・自動コード補完が入っているっぽいです。
  （一切手を加えていない箇所でも、元のコードよりカンマが増えていたので念のため）
*/

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = AuthService();

    final emailTextController = useTextEditingController();
    final emailText = useState<String>("");
    final passwordTextController = useTextEditingController();
    final passwordText = useState<String>("");

    final emailTextField = TextField(
      controller: emailTextController,
      onChanged: (text) => emailText.value = text,
      decoration: InputDecoration(
        labelText: "メールアドレスを入力",
        hintText: "メールアドレスを入力してください",
      ),
    );

    final passwordTextField = TextField(
      controller: passwordTextController,
      onChanged: (text) => passwordText.value = text,
      decoration: InputDecoration(
        labelText: "パスワードを入力",
        hintText: "パスワードを入力してください",
      ),
      obscureText: true,
    );

    final textFieldContainer = Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(children: [emailTextField, passwordTextField]),
    );

    final loginButton = ElevatedButton(
      onPressed: () async {
        try {
          await authService.signIn(emailText.value, passwordText.value);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("ログイン成功")));
          AppRouter.goToHome(context);
        } catch (e) {
          debugPrint("ログインに失敗: ${e.toString()}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("ログインに失敗しました: ${e.toString()}")),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        fixedSize: const Size(120, 30),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text("ログイン"),
    );

    final signUpButton = ElevatedButton(
      onPressed: () {
        AppRouter.goToRegister(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange,
        side: BorderSide(color: Colors.orange, width: 1),
        fixedSize: const Size(120, 30),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text("新規登録"),
    );

    final guestLoginButton = ElevatedButton(
      onPressed: () {
        AppRouter.goToHome(context);
      },
      child: Text("ログインせずに使用する"),
    );

    final guestLoginLink = GestureDetector(
      onTap: () {
        AppRouter.goToHome(context);
      },
      child: Text(
        "ログインせずに使用する",
        style: TextStyle(
          color: const Color.fromARGB(255, 233, 140, 0),
          decoration: TextDecoration.underline,
          decorationColor: Color.fromARGB(255, 233, 140, 0),
          decorationThickness: 1.5,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 240, 236),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "ログイン",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              textFieldContainer,
              loginButton,
              const SizedBox(height: 8),
              signUpButton,
              const SizedBox(height: 8),
              //guestLoginButton,
              guestLoginLink,
            ],
          ),
        ),
      ),
    );
  }
}

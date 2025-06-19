import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:class_2025_b/routers/router.dart';
import 'package:class_2025_b/states/user_state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:class_2025_b/services/auth_service.dart';



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
        hintText: "メールアドレスを入力してください"
      )
    );

    final passwordTextField = TextField(
      controller: passwordTextController,
      onChanged: (text) => passwordText.value = text,
      decoration: InputDecoration(
        labelText: "パスワードを入力",
        hintText: "パスワードを入力してください"
      ),
      obscureText: true,
    );

    final textFieldContainer = Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          emailTextField,
          passwordTextField,
        ],
      ),
    );  

    final loginButton = ElevatedButton(
      onPressed: () async {
        try{
          await authService.signIn(emailText.value, passwordText.value);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("ログイン成功"),
            ),
          );
          AppRouter.goToHome(context);  
        } catch (e) {
          debugPrint("ログインに失敗: ${e.toString()}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("ログインに失敗しました: ${e.toString()}"),
            ),
          );
        }
                
      },
      child: Text("ログインする")
    );

    final signUpButton = ElevatedButton(
      onPressed: () {
        AppRouter.goToRegister(context);
      }, 
      child: Text("新規登録")
    );


    final guestLoginButton = ElevatedButton(
      onPressed: () {
        AppRouter.goToHome(context);
      }, 
      child: Text("ログインせずに使用する")
    );

    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("ログイン"),   
            textFieldContainer,
            loginButton,
            signUpButton,
            guestLoginButton,
          ],
        ),
      ),
    );
  }
}
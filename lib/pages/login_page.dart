import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_button.dart';
import 'package:flutter_application_1/components/my_text_field.dart';
import 'package:flutter_application_1/services/auth/auth_services.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void logIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signInWithEmailandPassword(
          emailController.text, passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hideKeyboard, // Hide keyboard when tapping anywhere on the screen
      child: Scaffold(
        backgroundColor: Colors.deepPurpleAccent[1000],
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_red_eye, size: 80),
                  Text("Приложение-квест"),
                  const SizedBox(height: 70),
                  Text("Давно не виделись!"),
                  const SizedBox(height: 10),
                  MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false),
                  const SizedBox(height: 10),
                  MyTextField(
                      controller: passwordController,
                      hintText: 'Пароль',
                      obscureText: true),
                  const SizedBox(height: 15),
                  MyButton(onTap: logIn, text: "Войти"),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Нет аккаунта?"),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Зарегистрируйтесь",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

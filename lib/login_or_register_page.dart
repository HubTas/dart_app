import 'package:dartapp/register_screen.dart';
import 'package:dartapp/login_screen.dart';
import 'package:flutter/material.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool showWelcomeScreen = true;

  void toggleScreens() {
    setState(() {
      showWelcomeScreen = !showWelcomeScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showWelcomeScreen) {
      return LoginScreen(
        toggleScreens: toggleScreens,
      );
    } else {
      return RegisterScreen(
        toggleScreens: toggleScreens,
      );
    }
  }
}

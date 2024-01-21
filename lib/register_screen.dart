import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.toggleScreens,
  });

  final Function()? toggleScreens;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  void register() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      if (passwordController.text == confirmPasswordController.text) {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'email': emailController.text,
          'username': usernameController.text,
          'tournaments': 0,
          'matches': 0,
          'score': 0,
          'dartsThrown': 0,
          'matchesWon': 0,
        });
      } else {
        showErrorMessage('Hasło nie zgadza się z potwierdzeniem');
      }
      Get.back();
    } on FirebaseAuthException catch (e) {
      Get.back();
      showErrorMessage(e.code);
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            message,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 50,
                top: 80,
              ),
              child: Image.asset(
                'assets/images/dart_throw_1.png',
                width: 100,
                height: 100,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                bottom: 8,
              ),
              child: Text(
                'Załóż konto',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                controller: emailController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Nazwa użytkownika',
                  border: OutlineInputBorder(),
                ),
                controller: usernameController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Hasło',
                  border: OutlineInputBorder(),
                ),
                controller: passwordController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Potwierdź hasło',
                  border: OutlineInputBorder(),
                ),
                controller: confirmPasswordController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      height: 50,
                      width: 150,
                      child: FloatingActionButton(
                        heroTag: 'button3',
                        backgroundColor:
                            const Color.fromARGB(255, 123, 193, 255),
                        elevation: 10,
                        onPressed: widget.toggleScreens,
                        child: const Text(
                          'Logowanie',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      height: 50,
                      width: 150,
                      child: FloatingActionButton(
                        heroTag: 'button4',
                        backgroundColor:
                            const Color.fromARGB(255, 123, 193, 255),
                        elevation: 10,
                        onPressed: register,
                        child: const Text(
                          'Zarejestruj',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

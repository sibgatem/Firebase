import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GuestAuthScreen extends StatelessWidget {
  GuestAuthScreen({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<String?> signIn() async {
    final auth = FirebaseAuth.instance;
    try {
      await auth.signInAnonymously();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Пароль слишком слабый';
      } else if (e.code == 'email-already-in-use') {
        return 'Этот адрес уже используется';
      } else if (e.code == 'invalid-email') {
        return 'Некорректный email';
      } else if (e.code == 'user-not-found') {
        return 'Пользователь не найден';
      } else {
        return e.code;
      }
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Авторизоваться как гость'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() != true) {
                      return;
                    }
                    signIn().then((error) {
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Успешная анонимная авторизация'),
                          ),
                        );
                      }
                    });
                  },
                  child: const Text(
                    'Sign In as guest',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

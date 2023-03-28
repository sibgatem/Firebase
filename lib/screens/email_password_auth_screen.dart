import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/firestore/firestore_utils.dart';
import 'package:flutter_auth/utils/auth_response.dart';

class EmailPasswordAuthScreen extends StatelessWidget {
  EmailPasswordAuthScreen({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<AuthResponse> signIn() async {
    final auth = FirebaseAuth.instance;
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return const Failed("Ошибка при авторизации");
      }
      final profile = await FirestoreUtils.getUser(authUid: uid);
      if (profile == null) {
        return const Failed("Профиль не найден");
      }
      return Success(profile);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return const Failed('Пароль слишком слабый');
      } else if (e.code == 'email-already-in-use') {
        return const Failed('Этот адрес уже используется');
      } else if (e.code == 'invalid-email') {
        return const Failed('Некорректный email');
      } else if (e.code == 'user-not-found') {
        return const Failed('Пользователь не найден');
      } else {
        return Failed(e.code);
      }
    } catch (e) {
      return Failed(e.toString());
    }
  }

  Future<AuthResponse> signUp() async {
    final auth = FirebaseAuth.instance;
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return const Failed("Ошибка при регистрации");
      }
      final profile = await FirestoreUtils.createUser(
        authUid: uid,
        username: emailController.text,
      );
      print(profile?.username);
      if (profile == null) {
        return const Failed("Ошибка при создании профиля");
      }
      return Success(profile);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return const Failed('Пароль слишком слабый');
      } else if (e.code == 'email-already-in-use') {
        return const Failed('Этот адрес уже используется');
      } else if (e.code == 'invalid-email') {
        return const Failed('Некорректный email');
      } else if (e.code == 'user-not-found') {
        return const Failed('Пользователь не найден');
      } else {
        return Failed(e.code);
      }
    } catch (e) {
      return Failed(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email password auth'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email'
                  ),
                  validator: (value) {
                    if (value?.trim().isNotEmpty == true) {
                      return null;
                    }
                    return "Required field";
                  },
                ),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                      labelText: 'username'
                  ),
                  validator: (value) {
                    if (value?.trim().isNotEmpty == true) {
                      return null;
                    }
                    return "Required field";
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                      labelText: 'Password'
                  ),
                  validator: (value) {
                    if (value?.trim().isNotEmpty == true) {
                      return null;
                    }
                    return "Required field";
                  },
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() != true) {
                      return;
                    }
                    signIn().then((response) {
                      if (!response.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              response.error ?? "Неизвестная ошибка",
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Успешная авторизация'),
                          ),
                        );
                        Navigator.of(context).pushReplacementNamed('/profile');
                      }
                    });
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() != true) {
                      return;
                    }
                    signUp().then((response) {
                      if (!response.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              response.error ?? "Неизвестная ошибка",
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Успешная регистрация'),
                          ),
                        );
                        Navigator.of(context).pushReplacementNamed('/profile');
                      }
                    });
                  },
                  child: const Text(
                    'Sign Up',
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
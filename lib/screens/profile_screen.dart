import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/firestore/firestore_utils.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();

  Future<bool> updateData() async {
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid;
    if (uid == null) return false;
    final username = usernameController.text;
    return await FirestoreUtils.updateUser(authUid: uid, username: username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваш профиль'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('profiles')
                        .snapshots(),
                    builder: (BuildContext ctx,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) return const Text('Загрузка...');
                      final user = snapshot.data?.docs.firstWhere((element) {
                        final elUser = element.data() as Map<String, dynamic>;
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid == null) return false;
                        return elUser['uid'] == uid;
                      }).data() as Map<String, dynamic>;
                      return FutureBuilder(
                          future: FirestoreUtils.getUser(authUid: user['uid']),
                          builder: (_, profile) {
                            if (profile.hasData) {
                              return Text(
                                  'Добро пожаловать, ${profile.data?.username}');
                            } else {
                              return const Text('Загрузка');
                            }
                          });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                        labelText: 'Никнейм'
                    ),
                    validator: (value) {
                      if (value?.trim().isNotEmpty == true) {
                        return null;
                      }
                      return "Required field";
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() != true) {
                        return;
                      }
                      updateData().then((result) {
                        if (result) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Данные изменены'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Произошла ошибка'),
                            ),
                          );
                        }
                      });
                    },
                    child: const Text(
                      'Изменить никнейм',
                      style: TextStyle(fontSize: 16),
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

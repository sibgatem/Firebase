import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_auth/models/user.dart';

class FirestoreUtils {
  static Future<UserProfile?> createUser({
    required String authUid,
    required String username,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection("profiles").doc(authUid).set(
        {
          "uid": authUid,
          "username": username,
        },
      );
      return UserProfile(uid: authUid, username: username);
    } catch (e) {
      return null;
    }
  }

  static Future<UserProfile?> getUser({required String authUid}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot =
          await firestore.collection("profiles").doc(authUid).get();
      final data = snapshot.data();
      if (data == null) return null;
      return UserProfile(
        uid: data["uid"],
        username: data["username"],
      );
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateUser({
    required String authUid,
    required String username,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('profiles').doc(authUid).set(
        {
          "uid": authUid,
          "username": username,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/user.dart';
import 'user_datasource.dart';

class UserDatasourceFirebase implements UserDatasource {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  @override
  Future<User?> fetchUser(String id) async {
    debugPrint('[UserDatasource] fetchUser($id) start');
    final doc = await _firestore.collection('users').doc(id).get();
    debugPrint('[UserDatasource] fetchUser doc.exists=${doc.exists}');
    if (!doc.exists) return null;
    return User.fromJson({...doc.data()!, 'id': id});
  }

  @override
  Future<void> createOrUpdateUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  @override
  Future<void> deleteUser(String id) async {
    await _firestore.collection('users').doc(id).delete();
  }

  Future<String> uploadProfileImage(String uid, File image) async {
    final ref = _storage.ref().child('profile_images/$uid.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }
}

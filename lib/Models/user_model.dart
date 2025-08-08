import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;

  UserModel({required this.uid, required this.name, required this.email});

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(uid: doc.id, name: d['name'], email: d['email']);
  }

  Map<String, dynamic> toJson() => {'name': name, 'email': email};
}

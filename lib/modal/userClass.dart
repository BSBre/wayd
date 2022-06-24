import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String name;
  String id;
  String email;
  String idFrom;
  String timeStamp;
  String content;

  User({required this.name, required this.email, required this.id, required this.timeStamp, required this.idFrom, required this.content});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };

  static List<User> fromJson(QuerySnapshot<Map<String, dynamic>> json, String id) {
    List<User> users = [];
    for (var element in json.docs) {
      if(id != element.get("id")) {
        users.add(User(name: element.get("name"), email: element.get("email"), id: element.get("id"), timeStamp: "", idFrom: "", content: ""));
      }
    }
    return users;
  }
}
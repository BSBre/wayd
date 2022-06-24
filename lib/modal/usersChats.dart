import 'package:cloud_firestore/cloud_firestore.dart';

class UserChats {
  List<String> idChat;

  UserChats({required this.idChat});

  static UserChats fromJson(QuerySnapshot<Map<String, dynamic>> json) {
    List<String> idChatTmp = [];
    for (var element in json.docs) {
      idChatTmp.add(element.id);
    }

    return UserChats(idChat: idChatTmp);
  }
}
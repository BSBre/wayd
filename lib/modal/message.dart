class Message {
  final String content;
  final String idFrom;
  final String idTo;
  final int timeStamp;

  Message({required this.content, required this.idFrom, required this.idTo, required this.timeStamp});

  static Message fromJson(Map<String, dynamic> json) => Message(timeStamp: json["timeStamp"], content: json["content"], idFrom: json["idFrom"], idTo: json["idTo"]);
}
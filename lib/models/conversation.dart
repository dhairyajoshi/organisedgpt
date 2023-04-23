class Message {
  int u, a, t;
  String c;

  Message(this.u, this.c, this.a, this.t);
}

class ChatModel {
  String id, name;

  ChatModel(this.id, this.name);

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(json['_id'], json['name']);
  } 
}

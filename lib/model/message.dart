class Message {
  String? id;
  final String body;
  final String author;

  Message({this.id, required this.body, required this.author});

  Map<String, dynamic> toJson() => {"body": body, "author": author};

  Message.fromJson(String key, Map<String, dynamic> value)
      : id = key,
        author = value['author'],
        body = value['body'];
}

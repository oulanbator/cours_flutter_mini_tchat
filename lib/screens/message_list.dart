import 'package:cours_flutter_mini_tchat/model/message.dart';
import 'package:flutter/material.dart';

class MessageList extends StatelessWidget {
  final List<Message> messages;

  const MessageList({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) => _listElement(messages[index]),
    );
  }

  _listElement(Message msg) {
    return ListTile(
      title: Text(msg.author),
      subtitle: Text(msg.body),
    );
  }
}

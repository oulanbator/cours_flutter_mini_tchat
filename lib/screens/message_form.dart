import 'package:cours_flutter_mini_tchat/model/message.dart';
import 'package:flutter/material.dart';

class MessageForm extends StatefulWidget {
  final Function(Message message) onPost;

  const MessageForm({super.key, required this.onPost});

  @override
  State<MessageForm> createState() => _MessageFormState();
}

class _MessageFormState extends State<MessageForm> {
  final authorController = TextEditingController();
  final messageController = TextEditingController();

  _handlePost() {
    widget.onPost(Message(
      body: messageController.text,
      author: authorController.text,
    ));

    messageController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        TextField(
          controller: authorController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: "Auteur"),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: messageController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: "Message"),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _handlePost(),
          child: const Text("Envoyer"),
        )
      ],
    );
  }
}

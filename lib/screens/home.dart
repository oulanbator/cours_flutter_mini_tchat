import 'dart:async';

import 'package:cours_flutter_mini_tchat/model/message.dart';
import 'package:cours_flutter_mini_tchat/screens/message_form.dart';
import 'package:cours_flutter_mini_tchat/screens/message_list.dart';
import 'package:cours_flutter_mini_tchat/service/message_service.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<Message>> _messagesFuture = MessageService().getMessages();

  late Timer _timer;

  // Initialise un timer, toutes les secondes on réaffecte _messagesFuture pour que le widget soir rerendu
  @override
  void initState() {
    super.initState();
    // Initialize and start the timer
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      // Call setState to refresh the view
      setState(() {
        // Fetch new messages
        _messagesFuture = MessageService().getMessages();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Expanded(
            child: FutureBuilder(
                future: _messagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return MessageList(messages: snapshot.data!);
                  } else if (snapshot.hasError) {
                    return Text("Error");
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                })),
        MessageForm(
          onPost: (Message message) => _sendMessage(message),
        ),
      ],
    ));
  }

  _sendMessage(Message message) async {
    await MessageService().postMessage(message);
    setState(() {
      _messagesFuture = MessageService().getMessages();
    });
  }
}

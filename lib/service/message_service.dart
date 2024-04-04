import 'dart:convert';

import 'package:cours_flutter_mini_tchat/constants.dart';
import 'package:cours_flutter_mini_tchat/model/message.dart';
import 'package:http/http.dart';

class MessageService {
  final String messagesUrl = "${Constants.baseUrl}/messages.json";

  Future<void> postMessage(Message message) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*"
    };

    String body = jsonEncode(message.toJson());

    final response = await post(
      Uri.parse(messagesUrl),
      headers: headers,
      body: body,
    );
  }

  Future<List<Message>> getMessages() async {
    final response = await get(Uri.parse(messagesUrl));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return parseMessages(response.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print("error. status code : ${response.statusCode}");
      throw Exception('Failed to load album');
    }
  }

  List<Message> parseMessages(String responseBody) {
    if (jsonDecode(responseBody) == null) return [];
    // Parse la réponse en tant que Map<String, dynamic>, à l'aide de jsonDecode()
    final Map<String, dynamic> data = jsonDecode(responseBody);
    // Effectue un mapping de chaque élément de notre Map (data.entries.map)
    // Map un 'Message' grâce au constructeur .fromJson
    // Retourne une List<Message> avec .toList();
    return data.entries
        .map((map) => Message.fromJson(map.key, map.value))
        .toList();
  }
}

# cours_flutter_mini_tchat

## Setup du projet

- Cloner le projet :
```
git clone ...
cd ...
flutter pub get
```


- Recréer un dossier pour la plateforme cible sur laquelle vous souhaitez build :
```
flutter create --platforms=android .
```

ou pour plusieurs plateformes :
```
flutter create --platforms=windows,linux .
```


- Ajouter le package http à votre projet :
```
flutter pub add http
```


## Création d'un fichier pour les constantes 

En réalité cette étape est optionnelle, vous pourriez le faire autrement, mais on pourra ainsi facilement se connecter tous à la même base de donnée une fois le TP fini.

- Créer un fichier pour les constantes de votre application 'lib/constants.dart'
- Renseigner l'url vers votre base de données Firebase en static pour y accéder facilement (je vous invite à renseigner l'URL de votre propre base de données pour pouvoir surveiller les modifications de la base à mesure que vous faites des appels HTTP, et travailler plus facilement pendant la phase de dev)

```
class Constants {
  static const String baseUrl = "https://.....";
}
```


## Création d'un model de Message

Nous avons besoin d'un objet métier pour représenter nos messages, et nous aider dans la sérialisation/désérialisation lors de nos appels asynchrones.

- Créer un model pour les messages 'lib/model/message.dart'

```
class Message {
  String? id;
  final String body;
  final String author;

  Message({this.id, required this.body, required this.author});
}
```

En vous appuyant sur les slides et TPs de la précédente session :
- Implémentez le constructeur 'Message.fromJson'
- Implémentez la méthode toJson()

Documentation Flutter :

> https://docs.flutter.dev/cookbook/networking/fetch-data

> https://docs.flutter.dev/data-and-backend/serialization/json#serializing-json-inside-model-classes


# Création d'un MessageService pour intéragir avec la base de données

- Créer un service pour communiquer avec firebase: 'lib/services/message_service.dart'
- Créer une propriété ou un getter retournant l'url vers le 'noeud' où nous voulons stocker des données 

```
final String messagesUrl = "${Constants.baseUrl}/messages.json";
```

> La base Realtime Database de firestore attends des headers lorsqu'elle est requêtée. Je vous propose d'utiliser l'implémentation ci-dessous, pour plus de simplicité. Notez toutefois que cela dépend des API avec lesquelles vous intéragissez et que la question des headers est une source d'erreurs fréquente.

- Créer la méthode pour envoyer un message (POST)

```
Future<void> postMessage(Message message) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*"
    };

    String body = jsonEncode(message.toJson());

    final response = await http.post(
      Uri.parse(messagesUrl),
      headers: headers,
      body: body,
    );
}
```

- Créer les méthodes pour récupérer la liste des messages (en vous basant sur ce que nous avons déjà vu dans les autres TPs).

> Encore une fois, attention au format retourné par votre API. 

- Vous pouvez regarder la forme de la réponse avec un client HTTP (ou via votre navigateur) pour une requête GET à l'adresse suivante :

```
https://tp-firebase-database-default-rtdb.europe-west1.firebasedatabase.app/messages.json
```

> Il s'agit de l'URL vers ma base de données, mais vous pouvez remplacer par la votre

- Pour mapper une liste de messages à partir de notre résultat nous allons devoir adapter notre méthode fromJson...

```
Message.fromJson(String key, Map<String, dynamic> value)
      : id = key,
        body = value['body'] as String,
        author = value['author'] as String;
```

- ...ainsi que la manière de parser notre réponse :

```
List<Message> parseMessages(String responseBody) {
    final Map<String, dynamic> data = jsonDecode(responseBody);
    return data.entries.map((e) => Message.fromJson(e.key, e.value)).toList();
}
```
> Nous avons utilisé 'data.entries.map' plutôt que 'data.map' (comme dans le précédent TP) car nous manipulons une map et que nous souhaitons accéder à la clé de chaque entrée (car c'est elle qui contient l'id dans la réponse de l'API firebase).

## Création des éléments de la vue Home

L'écran Home (Scaffold) contiendra un Column avec deux enfants : 
- un Expanded qui contiendra la liste de messages (MessageList)
- un widget au bas de l'écran qui sera la zone de saisie des messages (MessageForm)

> Je vous propose ci-dessous des exemples d'implémentation très simples pour ces deux widgets. Libre à vous de les rendre plus élégants. Vous pouvez jouer par exemple sur la décoration de vos TextField, le rendu et l'emplacement du bouton "Envoyer" (pourquoi pas un IconButton positionné à droite par exemple). De même pour la liste de messages, rien ne vous oblige à utiliser un ListTile pour le rendu d'un message, vous pouvez faire votre propre widget personnalisé avec Container / DecoratedBox, etc..

- Créer le widget MessageForm : 'lib/widgets/message_form.dart'

```
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
```

> Notez que j'ai fait 'remonter' (via le callback 'onPost') la gestion de l'envoi d'un message vers le widget parent plutôt que gérer notre appel à Firebase directement dans MessageForm. A votre avis, pourquoi ?

- Créer également un widget séparé pour la liste de messages à afficher : 'lib/widgets/message_list.dart'

```
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
```

Tentez d'implémenter seuls l'écran Home. En principe nous avons déjà vu tous les éléments dont vous avez besoin. Pour rappel :

- FutureBuilder vous permet de construire votre vue à partir d'un Future
- setState va forcer un nouveau rendu d'un widget Stateful

- Lorsque j'envoie un message je souhaite le voir s'afficher dans la liste. Comment faire ?

Bonus : Lorsque nous serons plusieurs à publier des messages dans firebase, comment faire pour que l'écran affiche les nouveaux messages lorsqu'ils sont postés par d'autre utilisateurs ?

> L'application est finie ? Vous pouvez modifier l'url de la base de données stockée dans vos constantes pour échanger des messages dans le même channel. Vous pouvez utiliser la base que j'ai créé si vous le souhaitez :

```
https://tp-firebase-database-default-rtdb.europe-west1.firebasedatabase.app
```

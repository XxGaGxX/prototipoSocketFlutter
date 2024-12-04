import 'dart:async';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    //connessione al socket
    socket = IO.io("http://192.168.1.122:4500", <String, dynamic>{
      'transports': ['websocket']
    });
    //Apertura della socket
    socket.on("connect", (_) {
      setState(() {
        errorMessage = "connesso al server";
      });
    });
    //Listen per invio dei messaggi
    socket.on("message", (data) {
      _streamController.add(data);
    });
  }

  @override
  void Dispose() {
    socket.disconnect();
    _controller.dispose();
    _streamController.close();
    super.dispose();
  }

  late IO.Socket socket;
  final StreamController<String> _streamController = StreamController<String>();
  Stream<String> get messagesStream => _streamController.stream;
  String errorMessage = '';
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                height: 65,
                child: TextField(
                  onChanged: (value) {
                    if (socket.connected) {
                      sendMessage(value);
                    }
                  },
                  controller: _controller,
                  decoration: const InputDecoration(
                      labelText: "Inserisci il messaggio",
                      border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder<String>(
                  stream: messagesStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (errorMessage.isNotEmpty) {
                      Text(errorMessage);
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: ListTile(
                          title: Text(
                              "messaggio ricevuto: ${snapshot.data ?? ""}")),
                    );
                  })
              // )
            ],
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  void sendMessage(String value) {
    socket.emit('', value);
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:http/http.dart' as http;

// URL de la API a consumir
var url = '';

// Pagina de chat
class ChatPage extends StatefulWidget {
  final BluetoothDevice server;
  const ChatPage({this.server});
  @override
  _ChatPage createState() => new _ChatPage();
}

// Mensaje
class _Message {
  // Quien lo envio y el texto
  int whom;
  String text;
  // Constructor
  _Message(this.whom, this.text);
}

// Pagina de chat
class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  BluetoothConnection connection;
  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';
  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;
  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();
    // Conexion bluetooth
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
        messages.add(_Message(1, "Welcome to your IoT App"));
      });
      connection.input.listen(_onDataReceived).onDone(() {
        // Verificacion de que lado se realizo la desconexion
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
          title: (isConnecting
              ? Text('Connecting chat to ' + widget.server.name + '...')
              : isConnected
                  ? Text('Live chat with ' + widget.server.name)
                  : Text('Chat log with ' + widget.server.name))),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(5),
              width: double.infinity,
              child: FittedBox(
                child: Row(
                  children: [
                    FlatButton(
                      onPressed: isConnected ? () => _sendMessage('1') : null,
                      child: ClipOval(child: Image.asset('images/ledOn.png')),
                    ),
                    FlatButton(
                      onPressed: isConnected ? () => _sendMessage('0') : null,
                      child: ClipOval(child: Image.asset('images/ledOff.png')),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: ListView(
                  padding: const EdgeInsets.all(12.0),
                  controller: listScrollController,
                  children: list),
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    child: TextField(
                      style: const TextStyle(fontSize: 15.0),
                      controller: textEditingController,
                      decoration: InputDecoration.collapsed(
                        hintText: isConnecting
                            ? 'Wait until connected...'
                            : isConnected
                                ? 'Type your message...'
                                : 'Chat got disconnected',
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      enabled: isConnected,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: isConnected
                          ? () => _sendMessage(textEditingController.text)
                          : null),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Asignar búfer para datos analizados
    Uint8List buffer = Uint8List(data.length);
    int bufferIndex = buffer.length;
    // Aplicar control para baskspace
    int backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }
    // Crear mensaje si hay un carácter de nueva línea
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      String aux = backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString.substring(0, index);
      setState(() {
        messages.add(_Message(1, "Temperatura: " + aux));
        _messageBuffer = "";
      });
      // Una vez creado el mensaje que nos envio el dispositivo bluetooh
      //procedemos a realizar una peticion POST para que pueda ser operado
      //por la API
      http
          .post(url, body: {'temperature': aux})
          .then((res) {})
          .catchError((error) {
            print('Cannot connect, exception occured');
            print(error);
          });
    } else {
      // En caso contrario agregamos el contenido que llega al buffer
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  // Envio de mensajes
  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();
    text = text == '1' ? "1" : "0";
    if (text.length > 0) {
      try {
        // Envio del estado para prender o apagar la LED
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;
        setState(() {
          messages
              .add(_Message(clientID, text == '1' ? "LED: on" : "LED: off"));
        });
        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignorar el error, pero notificar al estado
        setState(() {});
      }
    }
  }
}

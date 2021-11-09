import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
//import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '/helpers/misc.dart';
import '/helpers/api_req.dart';

class SocketTest extends StatefulWidget {
  const SocketTest({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SocketTest> {
  final TextEditingController _controller = TextEditingController();
  /* final _channel = WebSocketChannel.connect(
    Uri.parse('wss://ws.ifelse.io/'),
  ); */
  final _channel = IOWebSocketChannel.connect(wsUrl);
  var iter = 0;
  Timer? timer;
  Stream? wstream;

  @override
  void initState() {
    super.initState();
    _channel.sink.add(json.encode({'action': 'setId', 'id': 3}));
    wstream = _channel.stream;
    wstream!.listen((v) => cprint('stream listen: $v'));
    setTimer();
  }

  void setTimer() {
    timer = Timer.periodic(const Duration(seconds: 55), (Timer t) => ping());
  }

  void ping() {
    _channel.sink.add(json.encode({'action': 'ping', 'id': 3}));
  }

  void periodic() {
    const dur = Duration(seconds: 3);
    Timer.periodic(dur, (Timer t) => sendLoc());
  }

  void sendLoc() {
    if (iter < points.length) {
      var data = {'action': 'chat', 'text': points[iter], 'to': 1};
      _channel.sink.add(json.encode(data));
      iter++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Send a message'),
              ),
            ),
            const SizedBox(height: 24),
            StreamBuilder(
              stream: _channel.stream,
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                var txt = '';
                if (snapshot.hasData) {
                  cprint('snapshot ${snapshot.data}');
                  Map resp = json.decode(snapshot.data);
                  if (resp.isNotEmpty && resp.containsKey('text')) {
                    txt = resp['text'];
                  }
                }
                return Text(txt);
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: const Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  var points = [
    '42.881377, 74.583476',
    '42.881951, 74.583583',
    '42.881910, 74.584229',
    '42.881859, 74.585305',
    '42.881808, 74.586748',
    '42.881745, 74.587789',
    '42.881686, 74.588883',
    '42.881631, 74.590364',
    '42.881545, 74.592161',
    '42.881431, 74.593835',
    '42.881404, 74.594866',
    '42.881624, 74.595129'
  ];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      var data = {'action': 'chat', 'text': _controller.text, 'to': 1};
      cprint('sinking $data');
      _channel.sink.add(json.encode(data));
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }
}

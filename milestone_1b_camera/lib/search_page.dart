import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mqtt_app_state.dart';
import 'mqtt_manager.dart';
import 'play_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late CustomMQTTManager myMQTTManager;
  late MQTTAppState currentMQTTState;
  late String idCache;
  final TextEditingController _idTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setAppConnectionState());
  }

  @override
  Widget build(BuildContext context) {
    final MQTTAppState mqttState = Provider.of<MQTTAppState>(context);
    currentMQTTState = mqttState;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              'Search',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          )),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPubIdMessageRow(),
            _buildConnectButton(currentMQTTState.getIdWasSent, currentMQTTState.getAppConnectionState),
            _buildPlayButton(currentMQTTState.getCanPlay),
          ],
        ),
      ),
    );
  }

  Widget _buildPubIdMessageRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: _buildTextField(_idTextController, 'Enter a username'),
          ),
          _buildSendIdButton(currentMQTTState.getIdWasSent)
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController targetController, String hintText) {
    return TextField(
        enabled: true,
        controller: targetController,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
          labelText: hintText,
        ));
  }

  Widget _buildSendIdButton(bool textWasSent) {
    return ElevatedButton(
      onPressed: textWasSent ? null : _setID,
      child: const Text('Send'), //
    );
  }

  Widget _buildConnectButton(bool textWasSent, MQTTAppConnectionState mqttState) {
    bool stateIsConnected = false;
    bool finalBool = false;

    if (mqttState == MQTTAppConnectionState.connected) {
      stateIsConnected = true;
    }

    if (!stateIsConnected && textWasSent) {
      finalBool = true;
    }

    return ElevatedButton(
      onPressed: finalBool ? _startMyManager : null,
      child: const Text('Connect'),
    );
  }

  Widget _buildPlayButton(bool canPlay) {
    return ElevatedButton(
      onPressed: canPlay ? _play : null,
      child: const Text('Play'),
    );
  }

  Widget _buildScrollableTextWith(String text) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: 400,
        height: 200,
        child: SingleChildScrollView(
          child: Text(text),
        ),
      ),
    );
  }

  //LOGIC::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  void _setAppConnectionState() {
    currentMQTTState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  void _setID() {
    if (_idTextController.text.isEmpty) {
      currentMQTTState.setIdWasSent(false);
      print('Error:: Invalid ID!');
    } else {
      currentMQTTState.setIdWasSent(true);
      idCache = _idTextController.text;
    }
  }

  void _startMyManager() {
    myMQTTManager = CustomMQTTManager(incomingState: currentMQTTState, incomingID: _idTextController.text);
    myMQTTManager.initializeMQTTClient();
    myMQTTManager.connect();
  }

  void _play() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PlayPage(mqttManagerRef: myMQTTManager)));
  }

  //Legacy
  void _publish() {
    myMQTTManager.publish("defaultTESTMESSAGE");
  }
}

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'mqtt_app_state.dart';

class CustomMQTTManager {
  // Private instance of client

  //10.0.2.2 : 8000 || 1883
  //127.0.0.1 : 1883
  //192.168.1.8

  final String _host;
  final String _identifier;
  final int _port;
  final String _topic;
  MqttServerClient? _client;
  final MQTTAppState _currentMQTTState;

  // Constructor
  CustomMQTTManager({required MQTTAppState incomingState, required String incomingID})
      : _host = "10.0.2.2",
        _identifier = incomingID,
        _port = 1883,
        _topic = 'luisTopic',
        _currentMQTTState = incomingState;

  void onConnected() {
    print('ON CONNECTED');
    _currentMQTTState.setAppConnectionState(MQTTAppConnectionState.connected);

    //Sub to topic
    _client!.subscribe(_topic, MqttQos.exactlyOnce);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final rcvdMsg = c![0].payload as MqttPublishMessage;
      final rcvdPayload = MqttPublishPayload.bytesToStringAsString(rcvdMsg.payload.message);

      dealWithListen(rcvdPayload);
    });
  }

  void onDisconnected() {
    print('ON DISCONNECT');
  }

  void onSubscribed(String topic) {
    print('ON SUB: $topic');
  }

  void onSubscribeFail(String topic) {
    print('ON SUB FAIL: $topic');
  }

  void onUnsubscribed(String? topic) {
    print('ON UNSUB: $topic');
  }

  void pong() {
    print('Ping response client callback invoked');
  }

  void initializeMQTTClient() {
    print('initizalize client start');
    _client = MqttServerClient.withPort(_host, _identifier, _port);
    _client!.keepAlivePeriod = 20;

    _client!.onConnected = onConnected;
    _client!.onDisconnected = onDisconnected;
    _client!.onSubscribed = onSubscribed;
    _client!.onSubscribeFail = onSubscribeFail;
    _client!.onUnsubscribed = onUnsubscribed;
    _client!.pongCallback = pong;

    _client!.secure = false;
    _client!.logging(on: true);

    final MqttConnectMessage connectMesg = MqttConnectMessage()
        .authenticateAs('test', 'test')
        .withClientIdentifier(_identifier)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);

    _client!.connectionMessage = connectMesg;
  }

  void connect() async {
    assert(_client != null);
    try {
      print('start client connecting');
      await _client!.connect();
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      disconnect();
    }

    //Error if connection failed
    if (_client!.connectionStatus!.state != MqttConnectionState.connected) {
      print('ERROR:: client connection failed - disconnecting...');
      disconnect();
    }
  }

  void disconnect() {
    print('start disconnecting');
    publish("Disconnect");
    _client!.disconnect();
  }

  void publish(String msgToPublish) {
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();

    builder.addString(_identifier + "::" + msgToPublish);

    _client!.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!, retain: true);
  }

  void resetMQTTVars() {
    _currentMQTTState.setAppConnectionState(MQTTAppConnectionState.disconnected);
    _currentMQTTState.setPlayerNum(0);
    _currentMQTTState.setCanPlay(false);
    _currentMQTTState.setCodeWasChosen(false);
    _currentMQTTState.setCodeToDecipher("");
    _currentMQTTState.resetTurnCounter();
    _currentMQTTState.setHasTried(false);
    _currentMQTTState.setOpponentHasTried(false);
    _currentMQTTState.setEndString("");
    disconnect();
  }

  void dealWithListen(String incomingMsg) {
    //Parse received string
    int myIndex = incomingMsg.lastIndexOf(":");
    myIndex += 1;
    String mySubstring = incomingMsg.substring(myIndex);

    //Set player order
    if (_currentMQTTState.getCurrentPlayerNum == MQTTPlayerNum.p0) {
      if (mySubstring != "1" && mySubstring != "2") {
        print("SetPlayer1");
        _currentMQTTState.setPlayerNum(1);
        publish("1");
      } else if (mySubstring == "1") {
        _currentMQTTState.setPlayerNum(2);
        print("SetPlayer1::READY TO  PLAY");
        publish("Play");
      }

      //Play
    } else if (mySubstring == "Play") {
      _currentMQTTState.setCanPlay(true);

      //Code setup
    } else if (incomingMsg.contains("code::")) {
      if (incomingMsg.contains(_identifier)) {
        _currentMQTTState.setCodeWasChosen(true);
        print("MYCODE");
      } else {
        _currentMQTTState.setCodeToDecipher(mySubstring);
        print(mySubstring + "CODE TO DECIPHER");
      }

      if (_currentMQTTState.getCodeWasChosen && _currentMQTTState.getCodeToDecipher != "") {
        _currentMQTTState.increaseCurrentTurn();
        print("INCREASE TURN");
      }

      //Taking guesses
    } else if (incomingMsg.contains("guess::")) {
      if (incomingMsg.contains(_identifier)) {
        _currentMQTTState.setHasTried(true);
        print("MY GUESS");
      } else {
        _currentMQTTState.setOpponentHasTried(true);
        print("OPPONENT GUESS");
      }

      if (_currentMQTTState.getHasTried && _currentMQTTState.getOpponentHasTried) {
        _currentMQTTState.setHasTried(false);
        _currentMQTTState.setOpponentHasTried(false);
        _currentMQTTState.increaseCurrentTurn();
        print("INCREASE TURN");

        if (_currentMQTTState.getCurrentTurn > 10) {
          publish("Tie");
        }
      }

      //Win case scenario
    } else if (mySubstring == "Win") {
      _currentMQTTState.resetTurnCounter();
      if (incomingMsg.contains(_identifier)) {
        _currentMQTTState.setEndString("You Won!");
        print("WIN");
      } else {
        _currentMQTTState.setEndString("You Lost");
        print("LOSE");
      }

      //Tie case scenario
    } else if (mySubstring == "Tie") {
      _currentMQTTState.resetTurnCounter();
      _currentMQTTState.setEndString("Tie");
      print("TIE");
    }
  }
}

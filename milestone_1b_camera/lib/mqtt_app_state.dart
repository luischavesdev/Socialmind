import 'package:flutter/foundation.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

enum MQTTPlayerNum { p0, p1, p2 }

class MQTTAppState with ChangeNotifier {
  MQTTAppConnectionState _appConnectionState = MQTTAppConnectionState.disconnected;
  bool _idWasSent = false;
  MQTTPlayerNum _currentPlayerNum = MQTTPlayerNum.p0;
  bool _canPlay = false;
  bool _codeWasChosen = false;
  String _codeToDecipher = "";
  int _currentTurn = 0;
  bool _hasTried = false;
  bool _opponentHasTried = false;
  String _endString = "";

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  void setIdWasSent(bool incomingBool) {
    _idWasSent = incomingBool;
    notifyListeners();
  }

  void setPlayerNum(int incomingNum) {
    if (incomingNum == 1) {
      _currentPlayerNum = MQTTPlayerNum.p1;
    } else if (incomingNum == 2) {
      _currentPlayerNum = MQTTPlayerNum.p2;
    } else if (incomingNum == 0) {
      _currentPlayerNum = MQTTPlayerNum.p0;
    }

    notifyListeners();
  }

  void setCanPlay(bool incomingBool) {
    _canPlay = incomingBool;
    notifyListeners();
  }

  void setCodeWasChosen(bool incomingBool) {
    _codeWasChosen = incomingBool;
    notifyListeners();
  }

  void setCodeToDecipher(String incomingString) {
    _codeToDecipher = incomingString;
    notifyListeners();
  }

  void increaseCurrentTurn() {
    _currentTurn += 1;
    notifyListeners();
  }

  void resetTurnCounter() {
    _currentTurn = 0;
    notifyListeners();
  }

  void setHasTried(bool incomingBool) {
    _hasTried = incomingBool;
    notifyListeners();
  }

  void setOpponentHasTried(bool incomingBool) {
    _opponentHasTried = incomingBool;
    notifyListeners();
  }

  void setEndString(String incomingString) {
    _endString = incomingString;
    notifyListeners();
  }

  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;
  bool get getIdWasSent => _idWasSent;
  MQTTPlayerNum get getCurrentPlayerNum => _currentPlayerNum;
  bool get getCanPlay => _canPlay;
  bool get getCodeWasChosen => _codeWasChosen;
  String get getCodeToDecipher => _codeToDecipher;
  int get getCurrentTurn => _currentTurn;
  bool get getHasTried => _hasTried;
  bool get getOpponentHasTried => _opponentHasTried;
  String get getEndString => _endString;
}

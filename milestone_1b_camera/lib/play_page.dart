import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'mqtt_app_state.dart';
import 'mqtt_manager.dart';

// phone shake package
import 'package:shake/shake.dart';

const MaterialColor primaryBlack = MaterialColor(
  0xFF000000,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(0xFF000000),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);

const MaterialColor primaryWhite = MaterialColor(
  0xFFFFFFFF,
  <int, Color>{
    50: Color(0xFFFFFFFF),
    100: Color(0xFFFFFFFF),
    200: Color(0xFFFFFFFF),
    300: Color(0xFFFFFFFF),
    400: Color(0xFFFFFFFF),
    500: Color(0xFFFFFFFF),
    600: Color(0xFFFFFFFF),
    700: Color(0xFFFFFFFF),
    800: Color(0xFFFFFFFF),
    900: Color(0xFFFFFFFF),
  },
);

class ButtonController {
  late Function(int) onColorChange;
}

class IconController {
  late Function(int) onColorChange;
}

class ButtonRowController {
  late VoidCallback onSubmitted;
  late VoidCallback readyColorString;
  late Function(List<int>) setColors;
  late VoidCallback randomizeColors;
}

//COLOR BUTTON::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
class ColorButton extends StatefulWidget {
  ColorButton({super.key, required this.currentColorIndex});
  int currentColorIndex;
  late ButtonController colorController;

  @override
  State<ColorButton> createState() => _ColorButtonState();
}

class _ColorButtonState extends State<ColorButton> {
  List<MaterialColor> buttonColors = const [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    print("InitButton");
    widget.colorController = ButtonController();
    widget.colorController.onColorChange = setColor;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          iterateColor();
        });
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: buttonColors[widget.currentColorIndex],
      ),
      child: const Text(''),
    );
  }

  void iterateColor() {
    widget.currentColorIndex += 1;
    if (widget.currentColorIndex >= 6) {
      widget.currentColorIndex = 0;
    }
  }

  void setColor(int newColor) {
    setState(() {
      widget.currentColorIndex = newColor.clamp(0, 5);
    });
  }
}

//GUESS ICONS::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
class GuessIcon extends StatefulWidget {
  GuessIcon({super.key});
  int currentColorIndex = 0;
  late IconController iconController;

  @override
  State<GuessIcon> createState() => _GuessIconState();
}

class _GuessIconState extends State<GuessIcon> {
  List<MaterialColor> iconColors = const [
    Colors.grey,
    primaryWhite,
    primaryBlack,
  ];

  @override
  void initState() {
    super.initState();
    print("InitIcon");
    widget.iconController = IconController();
    widget.iconController.onColorChange = setColor;
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.circle,
      color: iconColors[widget.currentColorIndex],
    );
  }

  void setColor(int newIndex) {
    setState(() {
      widget.currentColorIndex = newIndex.clamp(0, 2);
    });
  }
}

//BUTTON ROW::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
class ButtonRow extends StatefulWidget {
  ButtonRow({super.key});
  late ButtonRowController rowController;
  String colorsString = "";

  @override
  State<ButtonRow> createState() => _ButtonRowState();
}

class _ButtonRowState extends State<ButtonRow> {
  List<ColorButton> rowButtons = [];
  bool hasBeenSubmitted = false;

  @override
  void initState() {
    super.initState();
    print("INITROW");
    widget.rowController = ButtonRowController();
    widget.rowController.onSubmitted = onSubmit;
    widget.rowController.readyColorString = readyColorsString;
    widget.rowController.setColors = setColors;
    widget.rowController.randomizeColors = randomizeColors;

    rowButtons.add(ColorButton(currentColorIndex: 0));
    rowButtons.add(ColorButton(currentColorIndex: 0));
    rowButtons.add(ColorButton(currentColorIndex: 0));
    rowButtons.add(ColorButton(currentColorIndex: 0));
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: hasBeenSubmitted,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          rowButtons[0],
          rowButtons[1],
          rowButtons[2],
          rowButtons[3],
        ],
      ),
    );
  }

  void readyColorsString() {
    widget.colorsString = "";
    for (var element in rowButtons) {
      widget.colorsString += element.currentColorIndex.toString();
    }
  }

  void setColors(List<int> incomingColors) {
    if (incomingColors.length == rowButtons.length) {
      for (var i = 0; i < rowButtons.length; ++i) {
        rowButtons[i].colorController.onColorChange(incomingColors[i]);
      }
    } else {
      print("ERROR:: unable to set colors!");
    }
  }

  void randomizeColors() {
    print("randomize");
    Random random = Random();
    List<int> tempList = [
      random.nextInt(6),
      random.nextInt(6),
      random.nextInt(6),
      random.nextInt(6)
    ];
    setColors(tempList);
  }

  void onSubmit() {
    setState(() {
      hasBeenSubmitted = true;
    });
  }
}

//GUESS SQUARE::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
class GuessSquare extends StatelessWidget {
  GuessSquare({super.key});
  List<GuessIcon> icons = [];
  bool hasGenIcons = false;

  @override
  Widget build(BuildContext context) {
    if (hasGenIcons == false) {
      hasGenIcons = true;
      icons.add(GuessIcon());
      icons.add(GuessIcon());
      icons.add(GuessIcon());
      icons.add(GuessIcon());
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          icons[0],
          icons[1],
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          icons[2],
          icons[3],
        ]),
      ],
    );
  }

  void setColors(List<int> incomingColors) {
    print("COLORS " + incomingColors.length.toString());
    print("ICONS " + icons.length.toString());
    if (incomingColors.length == icons.length) {
      for (var i = 0; i < icons.length; ++i) {
        icons[i].iconController.onColorChange(incomingColors[i]);
      }
    } else {
      print("ERROR:: unable to set colors!");
    }
  }
}

//SET CODE BUTTON::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
class SetCodeButton extends StatefulWidget {
  const SetCodeButton(
      {super.key, required this.mqttManagerRef, required this.rowRef});
  final CustomMQTTManager mqttManagerRef;
  final ButtonRow rowRef;

  @override
  State<SetCodeButton> createState() => _SetCodeButtonState();
}

class _SetCodeButtonState extends State<SetCodeButton> {
  bool hasBeenPressed = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: hasBeenPressed
          ? null
          : () {
              widget.rowRef.rowController.readyColorString();
              widget.mqttManagerRef
                  .publish("code::" + widget.rowRef.colorsString);
              widget.rowRef.rowController.onSubmitted();
              setState(() {
                hasBeenPressed = true;
              });
            },
      child: const Text("Set Code"),
    );
  }
}

//SUBMIT BUTTON::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
class SubmitButton extends StatefulWidget {
  const SubmitButton({
    super.key,
    required this.mqttManagerRef,
    required this.rowRef,
    required this.squareRef,
    required this.codeRef,
  });

  final CustomMQTTManager mqttManagerRef;
  final ButtonRow rowRef;
  final GuessSquare squareRef;
  final String codeRef;

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  bool hasBeenPressed = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: hasBeenPressed
          ? null
          : () {
              //Publish guess try
              widget.rowRef.rowController.readyColorString();
              widget.mqttManagerRef
                  .publish("guess::" + widget.rowRef.colorsString);

              //Deactivate Row Buttons
              widget.rowRef.rowController.onSubmitted();

              //Update guess square
              List<int> tempList = parseGuess(widget.rowRef.colorsString);
              widget.squareRef.setColors(tempList);

              //Check if code was guessed
              int tempCounter = 0;
              for (var i = 0; i < tempList.length; ++i) {
                if (tempList[i] == 2) {
                  tempCounter++;
                }
              }
              if (tempCounter == 4) {
                widget.mqttManagerRef.publish("Win");
              }

              //Disable button after press
              setState(() {
                hasBeenPressed = true;
              });
            },
      child: const Text("Submit"),
    );
  }

  List<int> parseGuess(String guessToParse) {
    //Final list with colors
    List<int> colorList = [];

    //Lists for each code
    List<String> codeList = [
      widget.codeRef[0],
      widget.codeRef[1],
      widget.codeRef[2],
      widget.codeRef[3],
    ];
    List<String> guessList = [
      widget.rowRef.colorsString[0],
      widget.rowRef.colorsString[1],
      widget.rowRef.colorsString[2],
      widget.rowRef.colorsString[3],
    ];

    //Lists to cache items to remove
    List<String> codeRemoveList = [];
    List<String> guessRemoveList = [];

    //Check colors on same position and add them to remove list
    for (var i = 0; i < 4; ++i) {
      if (guessList[i] == codeList[i]) {
        print("BLACK");
        colorList.add(2);
        codeRemoveList.add(codeList[i]);
        guessRemoveList.add(guessList[i]);
      }
    }

    //Remove "blacks" to then find "whites"
    for (var i = 0; i < guessRemoveList.length; ++i) {
      print("REMOVE");
      guessList.remove(guessRemoveList[i]);
      codeList.remove(codeRemoveList[i]);
    }

    //Run through remaining elements to find "whites". When a "white" is not found, a "grey" (neutral) is added instead
    int lengthCache = guessList.length;
    for (var i = 0; i < lengthCache; ++i) {
      if (codeList.indexOf(guessList[0]) != -1) {
        print("WHITE");
        colorList.add(1);
        codeList.remove(codeList[codeList.indexOf(guessList[0])]);
        guessList.remove(guessList[0]);
      } else {
        print("GREY");
        colorList.add(0);
        guessList.remove(guessList[0]);
      }
    }

    return colorList;
  }
}

//PLAY PAGE::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
class PlayPage extends StatefulWidget {
  const PlayPage({
    super.key,
    required this.mqttManagerRef,
  });
  final CustomMQTTManager mqttManagerRef;

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  // shake detector
  late ShakeDetector shakeDetector;
  List<ButtonRow> rows = [];
  List<GuessSquare> guesses = [];
  List<Consumer<MQTTAppState>> consumers = [];
  int rowNumber = 10;

  @override
  void initState() {
    super.initState();

    rows.add(ButtonRow());
    consumers.add(Consumer<MQTTAppState>(
        builder: (context, value, child) =>
            _buildFirstRow(value.getCodeWasChosen)));

    for (var i = 0; i < rowNumber; ++i) {
      rows.add(ButtonRow());
      guesses.add(GuessSquare());
      consumers.add(Consumer<MQTTAppState>(
          builder: (context, value, child) =>
              _buildGameRow(i, value.getCurrentTurn, value.getCodeToDecipher)));
    }

    shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () {
        // Do stuff on phone shake
        rows[0].rowController.randomizeColors();
      },
      minimumShakeCount: 1,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 1.7,
    );
  }

  @override
  void dispose() {
    // dispose shake detector
    shakeDetector.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          widget.mqttManagerRef.resetMQTTVars();
          Navigator.of(context).pop();
        },
        label: const Text("Quit"),
        icon: const Icon(Icons.close),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/socialmind_pattern.png"),
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Image(
                  image: AssetImage("images/logo_2x.png"),
                ),
              ),
              const SizedBox(height: 20),
              consumers[0],
              Consumer<MQTTAppState>(
                  builder: (context, value, child) => Text(value.getEndString)),
              consumers[1],
              consumers[2],
              consumers[3],
              consumers[4],
              consumers[5],
              consumers[6],
              consumers[7],
              consumers[8],
              consumers[9],
              consumers[10],
            ],
          ),
        ),
      ),
    );
  }

  //First Row
  Widget _buildFirstRow(bool codeWasChosen) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            rows[0],
            SetCodeButton(
                mqttManagerRef: widget.mqttManagerRef, rowRef: rows[0]),
          ],
        ),
        const SizedBox(height: 10)
      ],
    );
  }

  //Game Row
  Widget _buildGameRow(
      int incomingRowNumber, int currentTurn, String codeToDecipher) {
    int rowNumber = incomingRowNumber;
    bool isVisible = false;

    if (rowNumber < currentTurn) {
      isVisible = true;
    }

    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: isVisible,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              rows[rowNumber + 1],
              guesses[rowNumber],
              SubmitButton(
                mqttManagerRef: widget.mqttManagerRef,
                rowRef: rows[rowNumber + 1],
                squareRef: guesses[rowNumber],
                codeRef: codeToDecipher,
              ),
            ],
          ),
          const SizedBox(height: 10)
        ],
      ),
    );
  }
}

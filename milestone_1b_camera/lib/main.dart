import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:milestone_1b_camera/main_menu_screen.dart';
import 'package:milestone_1b_camera/mqtt_app_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'app_data_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => MQTTAppState()),
      ChangeNotifierProvider(create: (context) => AppDataProvider())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mastermind',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/': (context) => const MyHomePage(),
        '/mainMenu': (context) => const MainMenuScreen(),
      },
      supportedLocales: const [Locale('en'), Locale('pt')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _text;

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('username') != null) _text = prefs.getString('username');
    return prefs.getString('username');
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppDataProvider>(context);

    return FutureBuilder(
        future: getUsername(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(title: Text(AppLocalizations.of(context)!.mainPageTitle)),
              body: Center(
                  child: Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.userNameLabel,
                          textScaleFactor: 1.5, style: const TextStyle(color: Colors.grey)),
                      TextFormField(
                        initialValue: snapshot.data,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(), hintText: AppLocalizations.of(context)!.hintTextLabel),
                        onChanged: (newText) => _text = newText,
                      ),
                      const SizedBox(height: 40),
                      TextButton(
                          style: TextButton.styleFrom(
                              minimumSize: const Size(double.infinity, 40),
                              backgroundColor: const Color.fromARGB(255, 7, 57, 99),
                              foregroundColor: Colors.white),
                          onPressed: () async {
                            if (_text != null) {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('username', _text!);
                              provider.setUsername(_text!);
                              Navigator.of(context).pushNamed('/mainMenu');
                            }
                          },
                          child: Text(AppLocalizations.of(context)!.playButtonLabel))
                    ]),
              )),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

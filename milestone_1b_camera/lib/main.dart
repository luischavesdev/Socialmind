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
    final ThemeData theme = ThemeData();
    const Color backgroundColor = Color.fromARGB(255, 63, 61, 63);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Socialmind',

      // Customize theme
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: const Color.fromARGB(255, 24, 23, 23),
          onPrimary: const Color.fromARGB(255, 196, 195, 201),
          secondary: const Color.fromARGB(255, 167, 167, 172),
          // background uses the same color as surface
          background: backgroundColor,
          surface: backgroundColor,
        ),
      ),

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
    if (prefs.getString('username') != null)
      _text = prefs.getString('username');
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
              // appBar: AppBar(
              //     title: Text(AppLocalizations.of(context)!.mainPageTitle)),
              body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/socialmind_pattern.png"),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.background,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Image(
                          image: AssetImage("images/logo_2x.png"),
                        ),
                        const SizedBox(height: 20),
                        Text(AppLocalizations.of(context)!.userNameLabel,
                            textScaleFactor: 1.5,
                            style: const TextStyle(color: Colors.grey)),
                        TextFormField(
                          initialValue: snapshot.data,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText:
                                  AppLocalizations.of(context)!.hintTextLabel),
                          onChanged: (newText) => _text = newText,
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          style: TextButton.styleFrom(
                            minimumSize: const Size(double.infinity, 40),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          onPressed: () async {
                            if (_text != null) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('username', _text!);
                              provider.setUsername(_text!);
                              Navigator.of(context).pushNamed('/mainMenu');
                            }
                          },
                          child: Text(
                              AppLocalizations.of(context)!.playButtonLabel),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                )),
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

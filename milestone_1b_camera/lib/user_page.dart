import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'app_data_provider.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
    getImage();
  }

  Future<String?> getImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('image');
  }

  Widget imageDisplay() {
    return FutureBuilder(
        future: getImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 2,
                        maxWidth: MediaQuery.of(context).size.width / 1.5),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (snapshot.data != null &&
                            File(snapshot.data!).existsSync())
                          Image.file(File(snapshot.data!), fit: BoxFit.fill)
                        else
                          Container(
                              color: Theme.of(context).colorScheme.background,
                              child: Center(
                                  child: Text(AppLocalizations.of(context)!
                                      .noImageLabel))),
                        Positioned(
                          left: 6,
                          bottom: 1,
                          child: ElevatedButton(
                            child: Text(
                                AppLocalizations.of(context)!.loadImageLabel),
                            onPressed: () async {
                              final img = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (img == null) return;
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setString('image', img.path);
                              setState(() {});
                            },
                          ),
                        ),
                        Positioned(
                          right: 6,
                          bottom: 1,
                          child: ElevatedButton(
                            onPressed: () async {
                              final img = await ImagePicker()
                                  .pickImage(source: ImageSource.camera);
                              if (img == null) return;
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setString('image', img.path);
                              setState(() {});
                            },
                            child: const Icon(Icons.camera_alt),
                          ),
                        ),
                      ],
                    )),
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/socialmind_pattern.png"),
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Center(
          child: imageDisplay(),
        ),
      ),
    );
  }
}

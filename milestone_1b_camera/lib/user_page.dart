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
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2, maxWidth: MediaQuery.of(context).size.width / 1.5),
            child:
              Stack(
                fit: StackFit.expand,
                children: [
                  if (snapshot.data != null && File(snapshot.data!).existsSync())
                    Image.file(File(snapshot.data!), fit: BoxFit.fill)
                  else
                    Container(
                      color: Colors.grey,
                      child: Center(child: Text(AppLocalizations.of(context)!.noImageLabel))
                    ),
                  Positioned(
                    right: 10,
                    bottom: 5,
                    child: ElevatedButton(
                      style: TextButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color.fromARGB(255, 7, 57, 99), shape: RoundedRectangleBorder(side: const BorderSide(width: 3, color: Color.fromARGB(255, 7, 57, 99)), borderRadius: BorderRadius.circular(5.0))),
                      child: Text(AppLocalizations.of(context)!.loadImageLabel),
                      onPressed: () async {
                        final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (img == null) return;
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString('image', img.path);
                      },
                    ),
                  ),
                  Positioned(
                    right: 5,
                    top: 10,
                    child: ElevatedButton(
                      style: TextButton.styleFrom(backgroundColor: Colors.white, shape: const CircleBorder(side: BorderSide(width: 3, color: Color.fromARGB(255, 7, 57, 99)))),
                      onPressed: () async {
                        final img = await ImagePicker().pickImage(source: ImageSource.camera);
                        if (img == null) return;
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString('image', img.path);
                      },
                      child: const Icon(Icons.camera_alt, color: Color.fromARGB(255, 7, 57, 99)),
                    ),
                  ),
                ],
              )   
            );
        } else {
          return const CircularProgressIndicator();
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 7, 57, 99),
        child: Center(
          child: imageDisplay(),
        ),
      ),
    );
  }
}
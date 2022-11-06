import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:provider/provider.dart';

import 'app_data_provider.dart';

import 'dart:async';

class SearchMapPage extends StatefulWidget {
  const SearchMapPage({super.key});

  @override
  State<SearchMapPage> createState() => _SearchMapPageState();
}

class _SearchMapPageState extends State<SearchMapPage> {
  final LatLng _initialCameraPosition = const LatLng(20.5937, 78.9629);
  late GoogleMapController _controller;
  final Location _location = Location();
  final Set<Marker> _locations = {};
  AppDataProvider? provider;
  bool firstTimeCamUpdate = true;

  StreamSubscription<LocationData>? locationSubscription;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    provider = Provider.of<AppDataProvider>(context);
    provider!.setID();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    FirebaseFirestore.instance.collection("locations").doc(provider!.deviceID).delete();
    locationSubscription!.cancel();
  }

  void _onMapCreated(GoogleMapController cntlr) async {
    print("MAPCREATED");
    _controller = cntlr;

    locationSubscription = _location.onLocationChanged.listen((l) async {
      if (mounted) {
        print("FIREBASE CHECK");
        FirebaseFirestore.instance.collection("locations").doc(provider!.deviceID).set({
          "username": provider!.username,
          "latitude": l.latitude,
          "longitude": l.longitude,
        });

        if (firstTimeCamUpdate) {
          firstTimeCamUpdate = false;
          _controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 13),
            ),
          );
        }

        _locations.clear();
        final collection = await FirebaseFirestore.instance.collection("locations").get();

        if (mounted) {
          collection.docs.forEach((document) => {
                _locations.add(Marker(
                    markerId: MarkerId("marker-${document.id}"),
                    position: LatLng(document["latitude"], document["longitude"]),
                    icon: _getIcon(document.id, provider!.deviceID),
                    infoWindow: InfoWindow(
                        title: "Latitude: ${document["latitude"]}, Longitude: ${document["longitude"]}",
                        snippet:
                            "${AppLocalizations.of(context)!.userPageLabel}: ${document["username"]} (${document.id})")))
              });
          if (mounted) {
            setState(() {});
          }
        }
      }
    });
  }

  BitmapDescriptor _getIcon(id1, id2) {
    if (id1 != id2) {
      return BitmapDescriptor.defaultMarker;
    }
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
          initialCameraPosition: CameraPosition(target: _initialCameraPosition),
          mapType: MapType.hybrid,
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          markers: _locations),
    );
  }
}

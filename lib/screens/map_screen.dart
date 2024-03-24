// // import 'dart:js_util';
// import 'dart:typed_data';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart'; // latlong package is used with flutter_map for coordinates
// import 'dart:async';

// // 98d3:51:fe3626 - HC-05

// class MapScreen extends StatefulWidget {
//   final BluetoothConnection? bluetoothConnection;
//   MapScreen({Key? key, this.bluetoothConnection}) : super(key: key);

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   LatLng currentLocation = LatLng(0.0, 0.0);
//   LatLng mobileDeviceLocation = LatLng(0.0, 0.0);
//   Marker? mobileLocationMarker;
//   double carSpeed = 0.0;
//   Marker? carMarker;
//   Marker? destinationMarker;
//   Timer? locationUpdateTimer;
//   bool isDataReceived = false;
//   bool isLocationFetched = false;

//   @override
//   void initState() {
//     super.initState();
//     _setupBluetoothListner();
//     _fetchCurrentMobileLocation().then((_) {
//       setState(() {
//         isLocationFetched = true;
//       });
//     });
//     Timer.periodic(Duration(seconds: 5), (Timer t) => _checkBluetoothData());
//   }

//   Future<void> _fetchCurrentMobileLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     setState(() {
//       mobileDeviceLocation = LatLng(position.latitude, position.longitude);
//       mobileLocationMarker = Marker(
//         point: mobileDeviceLocation,
//         width: 30,
//         height: 30,
//         child:
//             const Icon(Icons.person_pin_circle, color: Colors.green, size: 50),
//       );
//     });
//   }

//   void _checkBluetoothData() {
//     print(
//         "Checking Bluetooth Data: ${isDataReceived ? "Received" : "Not Received"}");
//   }

//   void _setupBluetoothListner() {
//     widget.bluetoothConnection?.input?.listen((data) {
//       isDataReceived = true;
//       String recievedData = utf8.decode(data);
//       // print("Recieved Data: $recievedData");
//       _processRecievedData(recievedData);
//     }).onDone(() {
//       print("Bluetooth Stream closed");
//     });
//   }

//   void _processRecievedData(String data) {
//     if (data.startsWith('Car,')) {
//       List<String> splitData = data.split(',');
//       if (splitData.length >= 4) {
//         double carLatitude = double.tryParse(splitData[1]) ?? 0.0;
//         double carLongitude = double.tryParse(splitData[2]) ?? 0.0;
//         double carSpeed = double.tryParse(splitData[3]) ?? 0.0;
//         if (carLatitude != 0.0 && carLongitude != 0.0) {
//           setState(() {
//             currentLocation = LatLng(carLatitude, carLongitude);
//             carMarker = Marker(
//               point: currentLocation,
//               width: 30,
//               height: 30,
//               child: const Icon(Icons.directions_car_rounded,
//                   color: Colors.blue, size: 50),
//             );
//           });
//           print("Car Location updated: $currentLocation");
//         } else {
//           carMarker = null;
//         }
//       }
//     }
//   }

//   void _getCurrentMobileLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     setState(() {
//       mobileDeviceLocation = LatLng(position.latitude, position.longitude);
//       mobileLocationMarker = Marker(
//         point: mobileDeviceLocation,
//         width: 30,
//         height: 30,
//         child:
//             const Icon(Icons.person_pin_circle, color: Colors.green, size: 50),
//       );
//     });
//   }

//   void _addMarker(LatLng point) {
//     setState(() {
//       destinationMarker = Marker(
//         point: point,
//         width: 30,
//         height: 30,
//         child: const Icon(Icons.location_on_sharp, color: Colors.red, size: 50),
//       );
//     });
//     locationUpdateTimer?.cancel();
//     // String gpsMessage = 'GPS,${point.latitude},${point.longitude}\n';
//     // _sendDataOverBluetooth(gpsMessage);

//     // print("GPS STRING: $gpsMessage\n");
//     // Additional logic for sending data to the RC car can be added here
//   }

//   void _sendStopMessage() {
//     _sendDataOverBluetooth("STOP\n");
//     print("STOP string sent\n");
//   }

//   void _sendClearMessage() {
//     _sendDataOverBluetooth("CLEAR\n");
//     setState(() {
//       destinationMarker = null;
//     });
//     print("CLEAR string sent\n");
//   }

//   void _setCurrentLocationAsDestination() async {
//     if (locationUpdateTimer == null || !locationUpdateTimer!.isActive) {
//       locationUpdateTimer =
//           Timer.periodic(const Duration(seconds: 1), (Timer t) async {
//         Position position = await Geolocator.getCurrentPosition(
//             desiredAccuracy: LocationAccuracy.high);
//         setState(() {
//           destinationMarker = Marker(
//             point: LatLng(position.latitude, position.longitude),
//             width: 30,
//             height: 30,
//             child: const Icon(Icons.location_on_sharp,
//                 color: Colors.red, size: 50),
//           );
//         });
//       });
//     }
//   }

//   // Future<void> _sendDataOverBluetooth(LatLng coordinates) async {
//   //   if (widget.bluetoothConnection != null &&
//   //       widget.bluetoothConnection!.isConnected) {
//   //     final String message =
//   //         'GPS,${coordinates.latitude},${coordinates.longitude}\n';
//   //     widget.bluetoothConnection!.output
//   //         .add(Uint8List.fromList(message.codeUnits));
//   //     await widget.bluetoothConnection!.output.allSent;
//   //     print("Data sent: $message");
//   //   } else {
//   //     print("Bluetooth is not connected");
//   //   }
//   // }
//   Future<void> _sendDataOverBluetooth(String message) async {
//     if (widget.bluetoothConnection != null &&
//         widget.bluetoothConnection!.isConnected) {
//       widget.bluetoothConnection!.output
//           .add(Uint8List.fromList(message.codeUnits));
//       await widget.bluetoothConnection!.output.allSent;
//       print("Data sent: $message");
//     } else {
//       print("Bluetooth is not connected");
//     }
//   }

//   void _goBack() {
//     Navigator.pushReplacementNamed(context, '/');
//   }

//   @override
//   void dispose() {
//     locationUpdateTimer?.cancel(); // Cancel the timer
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//               onPressed: _goBack,
//               icon: const Icon(
//                 Icons.arrow_back,
//               )),
//           title: const Text('Location Tracker'),
//           backgroundColor: Colors.blue[200],
//         ),
//         body: isLocationFetched
//             ? _buildMap()
//             : Center(child: CircularProgressIndicator()));
//   }

//   Widget _buildMap() {
//     return Column(
//       children: [
//         Expanded(
//           child: Stack(children: [
//             FlutterMap(
//                 options: MapOptions(
//                   initialCenter: mobileDeviceLocation,
//                   initialZoom: 15,
//                   onTap: (tapPosition, point) => _addMarker(point),
//                 ),
//                 children: [
//                   TileLayer(
//                     urlTemplate:
//                         'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                     userAgentPackageName: 'com.example.com',
//                   ),
//                   MarkerLayer(markers: [
//                     if (carMarker != null) carMarker!,
//                     if (destinationMarker != null) destinationMarker!,
//                     if (mobileLocationMarker != null) mobileLocationMarker!,
//                   ]),
//                 ]),
//             _buildLocationInfoWidget(),
//             // Positioned(bottom: 20,right: 20,child: _buildLocationInfoWidget()),
//             Positioned(
//               bottom: 20,
//               right: 20,
//               child: FloatingActionButton.extended(
//                 heroTag: "btn1",
//                 onPressed: _setCurrentLocationAsDestination,
//                 backgroundColor: Colors.white.withOpacity(0.5),
//                 label: const Text("Follow/Summon"),
//                 icon: const Icon(Icons.navigation),
//               ),
//             ),
//             // Add this inside your build method, where you want the button to appear
//             Positioned(
//                 bottom: 20,
//                 left: 20,
//                 child: FloatingActionButton.extended(
//                   heroTag: "btn2",
//                   onPressed: () {
//                     if (destinationMarker != null) {
//                       String gpsMessage =
//                           'GPS,${destinationMarker!.point.latitude},${destinationMarker!.point.longitude}\n';
//                       _sendDataOverBluetooth(gpsMessage);
//                     } else {
//                       print("No destination set");
//                     }
//                   },
//                   label: const Text("Send"),
//                   backgroundColor: Colors.white.withOpacity(0.5),
//                 )),
//             Positioned(
//               bottom: 80,
//               right: 20,
//               child: FloatingActionButton.extended(
//                 heroTag: "btn3",
//                 onPressed: _sendStopMessage,
//                 backgroundColor: Colors.white.withOpacity(0.5),
//                 label: const Text("STOP"),
//                 icon: const Icon(Icons.stop),
//               ),
//             ),
//             Positioned(
//               bottom: 140,
//               right: 20,
//               child: FloatingActionButton.extended(
//                 heroTag: "btn4",
//                 onPressed: _sendClearMessage,
//                 backgroundColor: Colors.white.withOpacity(0.5),
//                 label: const Text("CLEAR"),
//                 icon: const Icon(Icons.clear),
//               ),
//             ),
//           ]),
//         )
//       ],
//     );
//   }

//   Widget _buildLocationInfoWidget() {
//     String currentLocInfo =
//         'Car: Lat: ${currentLocation.latitude}, Lng: ${currentLocation.longitude}, Speed: $carSpeed mph';
//     String destinationLocInfo = destinationMarker != null
//         ? 'Destination: Lat: ${destinationMarker!.point.latitude}, Lng: ${destinationMarker!.point.longitude}'
//         : 'Destination: Not Set';

//     return Container(
//       padding: EdgeInsets.all(10),
//       color: Colors.white.withOpacity(0.5),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(currentLocInfo),
//           Text(destinationLocInfo),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final BluetoothConnection? bluetoothConnection;
  MapScreen({Key? key, this.bluetoothConnection}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng currentLocation = LatLng(0.0, 0.0);
  LatLng mobileDeviceLocation = LatLng(0.0, 0.0);
  Marker? mobileLocationMarker;
  List<Marker> destinationMarkers = [];
  double carSpeed = 0.0;
  Marker? carMarker;
  Timer? locationUpdateTimer;
  bool isDataReceived = false;
  bool isLocationFetched = false;
  bool showLocationInfo = false;

  @override
  void initState() {
    super.initState();
    _setupBluetoothListener();
    _fetchCurrentMobileLocation().then((_) {
      setState(() {
        isLocationFetched = true;
      });
    });
    Timer.periodic(
        const Duration(seconds: 5), (Timer t) => _checkBluetoothData());
  }

  Future<void> _fetchCurrentMobileLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      mobileDeviceLocation = LatLng(position.latitude, position.longitude);
      mobileLocationMarker = Marker(
        point: mobileDeviceLocation,
        width: 30,
        height: 30,
        child:
            const Icon(Icons.person_pin_circle, color: Colors.green, size: 50),
      );
    });
  }

  void _checkBluetoothData() {
    print(
        "Checking Bluetooth Data: ${isDataReceived ? "Received" : "Not Received"}");
  }

  void _setupBluetoothListener() {
    widget.bluetoothConnection?.input?.listen((data) {
      isDataReceived = true;
      String receivedData = utf8.decode(data);
      _processReceivedData(receivedData);
    }).onDone(() {
      print("Bluetooth Stream closed");
    });
  }

  void _processReceivedData(String data) {
    if (data.startsWith('Car,')) {
      List<String> splitData = data.split(',');
      if (splitData.length >= 4) {
        double carLatitude = double.tryParse(splitData[1]) ?? 0.0;
        double carLongitude = double.tryParse(splitData[2]) ?? 0.0;
        carSpeed = double.tryParse(splitData[3]) ?? 0.0;
        if (carLatitude != 0.0 && carLongitude != 0.0) {
          setState(() {
            currentLocation = LatLng(carLatitude, carLongitude);
            carMarker = Marker(
              point: currentLocation,
              width: 30,
              height: 30,
              child: const Icon(Icons.directions_car_rounded,
                  color: Colors.blue, size: 50),
            );
          });
          print("Car Location updated: $currentLocation");
        } else {
          carMarker = null;
        }
      }
    }
  }

  void _summonCar() {
    setState(() {
      if (mobileDeviceLocation.latitude != 0.0 &&
          mobileDeviceLocation.longitude != 0.0) {
        destinationMarkers.add(
          Marker(
            point: mobileDeviceLocation,
            width: 30,
            height: 30,
            child: const Icon(Icons.location_on_sharp,
                color: Colors.red, size: 50),
          ),
        );
      }
    });
  }

  Future<void> _sendDataOverBluetooth(String message) async {
    if (widget.bluetoothConnection != null &&
        widget.bluetoothConnection!.isConnected) {
      widget.bluetoothConnection!.output
          .add(Uint8List.fromList(message.codeUnits));
      await widget.bluetoothConnection!.output.allSent;
      print("Data sent: $message");
    } else {
      print("Bluetooth is not connected");
    }
  }

  void _sendStartMessage() {
    _sendDataOverBluetooth("START\n");
    print("START string sent\n");
  }

  void _sendStopMessage() {
    _sendDataOverBluetooth("STOP\n");
    print("STOP string sent\n");
  }

  void _sendClearMessage() {
    _sendDataOverBluetooth("CLEAR\n");
    setState(() {
      destinationMarkers.clear();
    });
    print("CLEAR string sent\n");
  }

  void _goBack() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  void dispose() {
    locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
            IconButton(onPressed: _goBack, icon: const Icon(Icons.arrow_back)),
        title: const Text('Location Tracker'),
        backgroundColor: Colors.blue[200],
        actions: [
          IconButton(
            icon:
                Icon(showLocationInfo ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              setState(() {
                showLocationInfo = !showLocationInfo;
              });
            },
          ),
        ],
      ),
      body: isLocationFetched
          ? _buildMap()
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        heroTag: "btnSummon",
        onPressed: _summonCar,
        backgroundColor: Colors.white.withOpacity(0.8),
        child: const Icon(Icons.location_on),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMap() {
    return Stack(children: [
      FlutterMap(
        options: MapOptions(
          initialCenter: mobileDeviceLocation,
          initialZoom: 15,
          onTap: (tapPosition, point) {
            if (destinationMarkers.length < 15) {
              setState(() {
                destinationMarkers.add(
                  Marker(
                    point: point,
                    width: 30,
                    height: 30,
                    child: const Icon(Icons.location_on_sharp,
                        color: Colors.red, size: 50),
                  ),
                );
              });
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.com',
          ),
          MarkerLayer(markers: [
            if (carMarker != null) carMarker!,
            if (mobileLocationMarker != null) mobileLocationMarker!,
            ...destinationMarkers,
          ]),
        ],
      ),
      if (showLocationInfo) _buildLocationInfoWidget(),
    ]);
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: Colors.white.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "btnSendLocation",
            onPressed: () {
              if (destinationMarkers.isNotEmpty) {
                Marker lastMarker = destinationMarkers.last;
                String gpsMessage =
                    'GPS,${lastMarker.point.latitude},${lastMarker.point.longitude}\n';
                _sendDataOverBluetooth(gpsMessage);
                print("Location sent: ${lastMarker.point}");
              } else {
                print("No destination marker set");
              }
            },
            backgroundColor: Colors.white.withOpacity(0.8),
            child: const Icon(Icons.arrow_upward_rounded),
          ),
          FloatingActionButton(
            heroTag: "btnStart",
            onPressed: _sendStartMessage,
            backgroundColor: Colors.white.withOpacity(0.8),
            child: const Icon(Icons.play_arrow),
          ),
          FloatingActionButton(
            heroTag: "btnStop",
            onPressed: _sendStopMessage,
            backgroundColor: Colors.white.withOpacity(0.8),
            child: const Icon(Icons.stop),
          ),
          FloatingActionButton(
            heroTag: "btnClear",
            onPressed: _sendClearMessage,
            backgroundColor: Colors.white.withOpacity(0.8),
            child: const Icon(Icons.clear),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfoWidget() {
    String currentLocInfo =
        'Car: Lat: ${currentLocation.latitude}, Lng: ${currentLocation.longitude}';
    String destinationCountInfo =
        'Checkpoints: ${destinationMarkers.length} / 15';

    String checkpointsInfo = 'Checkpoints:\n';
    for (int i = 0; i < destinationMarkers.length; i++) {
      LatLng checkpoint = destinationMarkers[i].point as LatLng;
      checkpointsInfo +=
          'Checkpoint ${i + 1}: Lat: ${checkpoint.latitude}, Lng: ${checkpoint.longitude}\n';
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(10),
        color: Colors.white.withOpacity(0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentLocInfo),
            Text(destinationCountInfo),
            Text(checkpointsInfo),
          ],
        ),
      ),
    );
  }
}

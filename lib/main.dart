import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'; // Import for BluetoothConnection
import 'screens/bluetooth_screen.dart'; // Import BluetoothScreen
import 'screens/map_screen.dart'; // Import MapScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RC Car Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => BluetoothScreen());
          case '/map':
            // Now BluetoothConnection should be recognized as a type
            final connection = settings.arguments as BluetoothConnection?;
            return MaterialPageRoute(
              builder: (context) => MapScreen(bluetoothConnection: connection),
            );
          // Add more routes as needed
          default:
            return MaterialPageRoute(builder: (context) => BluetoothScreen());
        }
      },
    );
  }
}

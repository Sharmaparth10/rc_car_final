// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'map_screen.dart'; // Import your MapScreen

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  List<BluetoothDiscoveryResult> devicesList = [];
  late StreamSubscription<BluetoothDiscoveryResult>
      _discoveryStreamSubscription;
  BluetoothConnection? _connection;

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  void _startDiscovery() {
    _discoveryStreamSubscription = bluetooth.startDiscovery().listen((result) {
      setState(() {
        final existingIndex = devicesList.indexWhere(
            (element) => element.device.address == result.device.address);
        if (existingIndex >= 0) {
          devicesList[existingIndex] = result;
        } else {
          devicesList.add(result);
        }
      });
    });

    _discoveryStreamSubscription.onDone(() {
      if (mounted) {
        _startDiscovery(); // Restart discovery if it completes
      }
    });
  }

  ListView _buildListViewOfDevices() {
    return ListView(
      children: devicesList.map((BluetoothDiscoveryResult result) {
        return ListTile(
          title: Text(result.device.name ?? "Unknown Device"),
          subtitle: Text(result.device.address.toString()),
          trailing: ElevatedButton(
            child: Text('Connect'),
            onPressed: () async {
              await _connect(result.device);
            },
          ),
          onTap: () async {
            await _connect(result.device);
          },
        );
      }).toList(),
    );
  }

  Future<void> _connect(BluetoothDevice device) async {
    try {
      await _discoveryStreamSubscription
          .cancel(); // Stop discovery when connecting
      _connection =
          await BluetoothConnection.toAddress(device.address);
      print('Connected to the device');
      // Navigate to the MapScreen with the connection instance
      Navigator.pushReplacementNamed(
  context,
  '/map',
  arguments: _connection,
);
;
    } catch (e) {
      print('Cannot connect, exception occurred');
      print(e);
      // Restart discovery if connection fails
      _startDiscovery();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Bluetooth Device',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[200],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _buildListViewOfDevices(),
          ),
          ElevatedButton(
            child: Text('Go to Map'),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/map');
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _discoveryStreamSubscription
        .cancel(); // Cancel discovery when leaving screen
    super.dispose();
  }
}

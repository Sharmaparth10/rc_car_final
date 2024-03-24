class BluetoothDeviceModel {
  String name;
  String address;
  bool isConnected;

  BluetoothDeviceModel({required this.name, required this.address, this.isConnected = false});
}

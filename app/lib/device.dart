import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// Entrada de lista de dispositivos Bluetooth
class BluetoothDeviceListEntry extends StatelessWidget {
  // Funcion al seleccionar y dispositvo
  final Function onTap;
  final BluetoothDevice device;
  // Constructor
  BluetoothDeviceListEntry({this.onTap, @required this.device});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(Icons.devices),
      title: Text(device.name ?? "Unknown device"),
      subtitle: Text(device.address.toString()),
      trailing: FlatButton(
        child: Text('Connect'),
        onPressed: onTap,
        color: Colors.blue,
      ),
    );
  }
}

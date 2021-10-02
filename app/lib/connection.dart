import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:app/device.dart';

class SelectBondedDevicePage extends StatefulWidget {
  /// Si es verdadero, en el inicio de la página se realiza una busqueda de los dispositivos vinculados.
  /// Si no están disponibles, serán deshabilitados de la selección.
  final bool checkAvailability;
  final Function onCahtPage;
  const SelectBondedDevicePage(
      {this.checkAvailability = true, @required this.onCahtPage});
  @override
  // Constructor
  _SelectBondedDevicePage createState() => new _SelectBondedDevicePage();
}

enum _DeviceAvailability {
  maybe,
  yes,
}

// Dispositivos con disponibilidad de conexion
class _DeviceWithAvailability extends BluetoothDevice {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int rssi;
  // Constructor
  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

// Seleccion de dispositivos vinculados
class _SelectBondedDevicePage extends State<SelectBondedDevicePage> {
  // Lista de dispositivos
  List<_DeviceWithAvailability> devices = List<_DeviceWithAvailability>();
  // Disponibilidad
  StreamSubscription<BluetoothDiscoveryResult> _discoveryStreamSubscription;
  bool _isDiscovering;
  // Constructor
  _SelectBondedDevicePage();

  @override
  void initState() {
    super.initState();
    // Descubrimiento de dispositivos
    _isDiscovering = widget.checkAvailability;
    if (_isDiscovering) {
      _startDiscovery();
    }
    // Configurar una lista de dispositivos vinculados
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => _DeviceWithAvailability(
                device,
                widget.checkAvailability
                    ? _DeviceAvailability.maybe
                    : _DeviceAvailability.yes,
              ),
            )
            .toList();
      });
    });
  }

  void _startDiscovery() {
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        Iterator i = devices.iterator;
        while (i.moveNext()) {
          var _device = i.current;
          if (_device.device == r.device) {
            _device.availability = _DeviceAvailability.yes;
            _device.rssi = r.rssi;
          }
        }
      });
    });
    _discoveryStreamSubscription.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    // Evitar la pérdida de memoria y cancelar el descubrimiento
    _discoveryStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntry> list = devices
        .map(
          (_device) => BluetoothDeviceListEntry(
            device: _device.device,
            onTap: () {
              widget.onCahtPage(_device.device);
            },
          ),
        )
        .toList();
    return ListView(
      children: list,
    );
  }
}

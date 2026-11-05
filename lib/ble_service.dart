import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class BleService extends ChangeNotifier {
  final _ble = FlutterReactiveBle();

  bool isConnected = false;
  String statusMessage = "Ready to connect";
  String? connectedDeviceId;

  int currentReps = 0;
  String currentFeedback = "Waiting for first rep...";
  List<String> currentSetFeedbacks = [];

  StreamSubscription? _scanSub;
  StreamSubscription? _connectSub;
  StreamSubscription? _dataSub;

  final Uuid serviceUuid = Uuid.parse("12345678-1234-5678-1234-56789abcdef0");
  final Uuid movementCharUuid = Uuid.parse("12345678-1234-5678-1234-56789abcdef1");
  final Uuid rxCharUuid = Uuid.parse("12345678-1234-5678-1234-56789abcdef2");
  final Uuid labelCharUuid = Uuid.parse("12345678-1234-5678-1234-56789abcdef3");

  Future<void> init() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    scanAndConnect();
  }

  void scanAndConnect() {
    if (isConnected) return;
    statusMessage = "🔍 Searching for Glove...";
    notifyListeners();

    _scanSub?.cancel();
    _scanSub = _ble.scanForDevices(withServices: [serviceUuid]).listen((device) {
      if (device.name == "LeftGlove") {
        _scanSub?.cancel();
        _connectToDevice(device);
      }
    }, onError: (e) {
      statusMessage = "Scan Error: $e";
      notifyListeners();
    });
  }

  void _connectToDevice(DiscoveredDevice device) {
    statusMessage = "🔗 Connecting...";
    notifyListeners();

    _connectSub?.cancel();

    _connectSub = _ble.connectToDevice(
      id: device.id,
      connectionTimeout: const Duration(seconds: 5),
    ).listen((state) async {

      if (state.connectionState == DeviceConnectionState.connected) {
        isConnected = true;
        connectedDeviceId = device.id;
        statusMessage = "🟢 Connected";
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 1000));

        _subscribeToData(device.id);

      } else if (state.connectionState == DeviceConnectionState.disconnected) {
        isConnected = false;
        connectedDeviceId = null;
        statusMessage = "❌ Disconnected.";
        notifyListeners();

        await Future.delayed(const Duration(seconds: 2));
        scanAndConnect();
      }
    }, onError: (Object error) {
      print("🚨 VERBINDUNGS-FEHLER: $error");
      statusMessage = "Error: Connection failed";
      isConnected = false;
      notifyListeners();
    });
  }

  Future<void> _requestMtu(String deviceId) async {
    try {
      await _ble.requestMtu(deviceId: deviceId, mtu: 32);
    } catch (e) {
      print("MTU Request fehlgeschlagen: $e");
    }
  }

  void _subscribeToData(String deviceId) {
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: labelCharUuid,
      deviceId: deviceId,
    );

    _dataSub?.cancel();
    _dataSub = _ble.subscribeToCharacteristic(characteristic).listen((data) {
      if (data.isNotEmpty) {
        int labelIndex = data[0];
        currentReps++;
        String feedback = _getFeedbackForLabel(labelIndex);
        currentFeedback = feedback;
        currentSetFeedbacks.add(feedback);
        notifyListeners();
      }
    }, onError: (dynamic error) {
      print("🚨 SUBSCRIPTION-FEHLER: $error");
    });
  }

  Future<void> sendWorkoutSetup(int startCommand, int exerciseId, int targetReps, double weightKg) async {
    if (!isConnected || connectedDeviceId == null) return;
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharUuid,
      deviceId: connectedDeviceId!,
    );
    try {
      await _ble.writeCharacteristicWithResponse(
        characteristic,
        value: [startCommand, exerciseId, targetReps, weightKg.round()],
      );
    } catch (e) {
      print("Error sending setup: $e");
    }
  }

  void resetTrainingData() {
    currentReps = 0;
    currentFeedback = "Ready...";
    currentSetFeedbacks.clear();
    notifyListeners();
  }

  String _getFeedbackForLabel(int index) {
    switch (index) {
      case 0: return "angled elbows";
      case 1: return "bent wrists";
      case 2: return "correct form";
      case 3: return "incomplete motion";
      case 4: return "incorrect grip width";
      case 5: return "too fast";
      case 6: return "using momentum";
      default: return "unknown form";
    }
  }
}
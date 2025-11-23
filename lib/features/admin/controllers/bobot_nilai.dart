import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BobotProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final Map<String, double> _bobot = {
    'Tahfidz': 30,
    'Fiqh': 20,
    'Bahasa Arab': 20,
    'Akhlak': 20,
    'Kehadiran': 10,
  };

  Map<String, double> get bobot => _bobot;

  BobotProvider() {
    loadBobot();
  }

  Future<void> loadBobot() async {
    for (var key in _bobot.keys) {
      String? value = await _storage.read(key: key);
      if (value != null) {
        _bobot[key] = double.tryParse(value) ?? _bobot[key]!;
      }
    }
    notifyListeners();
    print("Bobot berhasil dimuat: $_bobot");
  }

  Future<void> setBobot(String key, double value) async {
    _bobot[key] = value;
    await _storage.write(key: key, value: value.toString());
    notifyListeners();
    print("Bobot '$key' berhasil diubah menjadi $value%");
  }
}

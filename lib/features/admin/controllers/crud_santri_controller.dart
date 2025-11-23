import 'package:flutter/material.dart';
import 'package:Santri/core/dbhelper.dart';
import 'package:Santri/features/admin/model/santri_model.dart';

class SantriProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  List<Santri> _santriList = [];

  List<Santri> get santriList => _santriList;

  SantriProvider() {
    loadSantri();
  }

  // Load semua Santri
  Future<void> loadSantri() async {
    _santriList = await _dbHelper.getAllSantri();
    notifyListeners(); // memberitahu UI untuk update
    print("Load Santri berhasil, total: ${_santriList.length}");
  }

  // Tambah Santri
  Future<void> addSantri(Santri santri) async {
    await _dbHelper.insertSantri(santri);
    print("Tambah Santri berhasil: ${santri.nama}");
    await loadSantri(); // reload data dan update UI
  }

  // Update Santri
  Future<void> updateSantri(Santri santri) async {
    await _dbHelper.updateSantri(santri);
    print("Update Santri berhasil: ${santri.nama}");
    await loadSantri(); // reload data dan update UI
  }

  // Delete Santri
  Future<void> deleteSantri(int id) async {
    await _dbHelper.deleteSantri(id);
    print("Hapus Santri berhasil, ID: $id");
    await loadSantri(); // reload data dan update UI
  }
}

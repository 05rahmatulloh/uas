import 'package:flutter/material.dart';
import 'package:Santri/core/dbhelper.dart';
import 'package:Santri/features/admin/model/santri_model.dart';
// import 'db_helper.dart';
// import 'santri_model.dart';

class SantriProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  List<Santri> _santriList = [];

  List<Santri> get santriList => _santriList;

  SantriProvider() {
    loadSantri();
  }

  Future<void> loadSantri() async {
    _santriList = await _dbHelper.getAllSantri();
    notifyListeners();
    print("Load Santri berhasil, total: ${_santriList.length}");
  }

  Future<void> addSantri(Santri santri) async {
    await _dbHelper.insertSantri(santri);
    print("Tambah Santri berhasil: ${santri.nama}");
    await loadSantri();
  }

  Future<void> updateSantri(Santri santri) async {
    await _dbHelper.updateSantri(santri);
    print("Update Santri berhasil: ${santri.nama}");
    await loadSantri();
  }

  Future<void> deleteSantri(int id) async {
    await _dbHelper.deleteSantri(id);
    print("Hapus Santri berhasil, ID: $id");
    await loadSantri();
  }
}

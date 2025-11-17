import 'package:firebase_database/firebase_database.dart';
import 'package:itull2/features/admin/dbhelper.dart';
// import 'dbhelper.dart';

class SyncService {
  final DBHelper dbHelper = DBHelper();
  final DatabaseReference ref = FirebaseDatabase.instance.ref();

  Future<void> syncAllData() async {
    // 1. Ambil semua santri
    final santriList = await dbHelper.getAllSantri();

    for (var s in santriList) {
      // 2. Ambil nilai santri
      final nilai = await dbHelper.getNilaiBySantri(s.id!);

      // 3. Kirim ke Firebase
      await ref.child('santri/${s.id}').set({
        'nama': s.nama,
        'nis': s.nis,
        'kamar': s.kamar,
        'angkatan': s.angkatan,
        'nilai': nilai ?? {},
      });
    }

    print("Sinkronisasi ke Firebase selesai!");
  }
}

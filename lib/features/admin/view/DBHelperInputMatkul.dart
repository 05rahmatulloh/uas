import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/santri_model.dart';

class DBHelperInputMatkul {
  static final DBHelperInputMatkul instance = DBHelperInputMatkul._();
  DBHelperInputMatkul._();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'e_penilaian.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE santri(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nis TEXT,
            nama TEXT,
            kamar TEXT,
            angkatan TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE nilai(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            santri_id INTEGER,
            mata_pelajaran TEXT,
            nilai INTEGER
          )
        ''');

        // Optional: Insert dummy data jika belum ada
        await db.insert('santri', {
          'nis': '001',
          'nama': 'Ahmad',
          'kamar': 'A1',
          'angkatan': '2025',
        });
        await db.insert('santri', {
          'nis': '002',
          'nama': 'Budi',
          'kamar': 'A2',
          'angkatan': '2025',
        });
      },
    );
  }

  Future<List<Santri>> getAllSantri() async {
    final db = await database;
    final res = await db.query('santri', orderBy: 'id ASC');
    return res.map((e) => Santri.fromMap(e)).toList();
  }

  Future<void> insertNilai({
    required int santriId,
    required String mataPelajaran,
    required int nilai,
  }) async {
    final db = await database;
    await db.insert('nilai', {
      'santri_id': santriId,
      'mata_pelajaran': mataPelajaran,
      'nilai': nilai,
    });
  }
}

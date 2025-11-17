import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:itull2/features/admin/model/santri_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;
  static const String _dbName = "santri.db";
  static const int _dbVersion = 2;

  static const String tableSantri = "santri";
  static const String tableNilai = "nilai_santri";

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel Santri
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableSantri (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nis TEXT NOT NULL,
        nama TEXT NOT NULL,
        kamar TEXT NOT NULL,
        angkatan INTEGER NOT NULL
      )
    ''');

    // Tabel Nilai Santri
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableNilai (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        santriId INTEGER NOT NULL,
        tahfidz INTEGER DEFAULT 0,
        fiqh INTEGER DEFAULT 0,
        akhlak INTEGER DEFAULT 0,
        bahasaArab INTEGER DEFAULT 0,
        kehadiran INTEGER DEFAULT 0,
        total INTEGER DEFAULT 0,
        status TEXT DEFAULT 'Tidak Lulus',
        FOREIGN KEY (santriId) REFERENCES santri(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _onCreate(db, newVersion);
    }
  }

  // ===== CRUD Santri =====
  Future<int> insertSantri(Santri santri) async {
    final db = await database;
    try {
      int id = await db.insert(
        tableSantri,
        santri.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      // otomatis buat record nilai default jika belum ada
      final exist = await db.query(
        tableNilai,
        where: 'santriId = ?',
        whereArgs: [id],
      );
      if (exist.isEmpty) {
        await db.insert(tableNilai, {
          'santriId': id,
          'tahfidz': 0,
          'fiqh': 0,
          'akhlak': 0,
          'bahasaArab': 0,
          'kehadiran': 0,
          'total': 0,
          'status': 'Tidak Lulus',
        });
      }

      return id;
    } catch (e) {
      print("Gagal insert, NIS sudah ada: $e");
      return -1;
    }
  }

Future<void> deleteDB() async {
    String path = join(await getDatabasesPath(), "santri.db");
    await deleteDatabase(path);
    print("Database lama dihapus!");
  }
  Future<List<Santri>> getAllSantri() async {
    final db = await database;
    final maps = await db.query(tableSantri, orderBy: "id DESC");
    return List.generate(maps.length, (i) => Santri.fromMap(maps[i]));
  }

  Future<int> updateSantri(Santri santri) async {
    final db = await database;
    return await db.update(
      tableSantri,
      santri.toMap(),
      where: 'id = ?',
      whereArgs: [santri.id],
    );
  }

  Future<int> deleteSantri(int id) async {
    final db = await database;
    await db.delete(tableNilai, where: 'santriId = ?', whereArgs: [id]);
    return await db.delete(tableSantri, where: 'id = ?', whereArgs: [id]);
  }

  // ===== CRUD Nilai Santri =====
  Future<void> updateNilai({
    required int santriId,
    int? tahfidz,
    int? fiqh,
    int? akhlak,
    int? bahasaArab,
    int? kehadiran,
  }) async {
    final db = await database;

    // ambil record yang sudah ada
    final res = await db.query(
      tableNilai,
      where: 'santriId = ?',
      whereArgs: [santriId],
    );
    if (res.isEmpty) return;

    final current = res.first;

    // update hanya nilai yang dikirim
    int newTahfidz = tahfidz ?? current['tahfidz'] as int;
    int newFiqh = fiqh ?? current['fiqh'] as int;
    int newAkhlak = akhlak ?? current['akhlak'] as int;
    int newBahasa = bahasaArab ?? current['bahasaArab'] as int;
    int newKehadiran = kehadiran ?? current['kehadiran'] as int;

    int total =
        ((newTahfidz + newFiqh + newAkhlak + newBahasa + newKehadiran) / 5)
            .round();
    String status =
        (newTahfidz >= 60 &&
            newFiqh >= 60 &&
            newAkhlak >= 60 &&
            newBahasa >= 60 &&
            newKehadiran >= 60)
        ? 'Lulus'
        : 'Tidak Lulus';

    await db.update(
      tableNilai,
      {
        'tahfidz': newTahfidz,
        'fiqh': newFiqh,
        'akhlak': newAkhlak,
        'bahasaArab': newBahasa,
        'kehadiran': newKehadiran,
        'total': total,
        'status': status,
      },
      where: 'santriId = ?',
      whereArgs: [santriId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllNilai() async {
    final db = await database;
    return await db.query(tableNilai, orderBy: 'santriId ASC');
  }

  Future<Map<String, dynamic>?> getNilaiBySantri(int santriId) async {
    final db = await database;
    final res = await db.query(
      tableNilai,
      where: 'santriId = ?',
      whereArgs: [santriId],
    );
    return res.isNotEmpty ? res.first : null;
  }
}

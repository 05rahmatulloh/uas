import 'dart:async';
import 'dart:io';
import 'package:Santri/features/admin/model/santri_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseConnectionProvider extends ChangeNotifier {
  // Singleton
  static final FirebaseConnectionProvider _instance =
      FirebaseConnectionProvider._internal();
  factory FirebaseConnectionProvider() => _instance;

  FirebaseConnectionProvider._internal() {
    _initConnectionListener();
    _startHeartbeat();
  }

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  late DatabaseReference _connectionRef;
  StreamSubscription<DatabaseEvent>? _subscription;
  Timer? _heartbeatTimer;

  void _initConnectionListener() {
    if (_subscription != null) return; // anti listener ganda

    // node untuk testing
    _connectionRef = FirebaseDatabase.instance.ref("makanan");

    _subscription = _connectionRef.onValue.listen(
      (event) {
        _setConnected(true); // berhasil baca → connected
      },
      onError: (_) {
        _setConnected(false); // gagal baca → disconnected
      },
    );
  }

  /// Fungsi untuk update status
  void _setConnected(bool value) {
    if (_isConnected != value) {
      _isConnected = value;
      notifyListeners();
      print("🔌 Firebase connection status: $_isConnected");
    }
  }

  /// Test manual satu kali
  Future<void> _testConnectionOnce() async {
    try {
      final snapshot = await _connectionRef.get();
      _setConnected(snapshot.exists);
    } catch (e) {
      _setConnected(false);
    }
  }

  /// 🔥 Heartbeat — cek setiap 5 detik
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();

    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _testConnectionOnce(),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _heartbeatTimer?.cancel();
    super.dispose();
  }
}

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;
  static const String _dbName = "santri.db";
  static const int _dbVersion = 2;

  static const String tableSantri = "santri";
  static const String tableNilai = "nilai_santri";

  final FirebaseConnectionProvider _firebaseConnection =
      FirebaseConnectionProvider();

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
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableSantri (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nis TEXT NOT NULL,
        nama TEXT NOT NULL,
        kamar TEXT NOT NULL,
        angkatan INTEGER NOT NULL
      )
    ''');

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

      // Sinkronisasi ke Firebase jika terhubung
      if (_firebaseConnection.isConnected) {
        try {
          final santriRef = FirebaseDatabase.instance.ref("santri/$id");
          final nilaiRef = FirebaseDatabase.instance.ref("nilai/$id");
          await santriRef.set({
            'nis': santri.nis,
            'nama': santri.nama,
            'kamar': santri.kamar,
            'angkatan': santri.angkatan,
          });
          await nilaiRef.set({
            'tahfidz': 0,
            'fiqh': 0,
            'akhlak': 0,
            'bahasaArab': 0,
            'kehadiran': 0,
            'total': 0,
            'status': 'Tidak Lulus',
          });
          print("✅ Data baru tersimpan di Firebase");
        } catch (e) {
          print("❌ Gagal sinkronisasi ke Firebase: $e");
        }
      }

      return id;
    } catch (e) {
      print("Gagal insert, NIS sudah ada: $e");
      return -1;
    }
  }

  Future<void> deleteDB() async {
    String path = join(await getDatabasesPath(), _dbName);
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
    int result = await db.update(
      tableSantri,
      santri.toMap(),
      where: 'id = ?',
      whereArgs: [santri.id],
    );

    // Sinkronisasi ke Firebase jika terhubung
    if (_firebaseConnection.isConnected) {
      try {
        final santriRef = FirebaseDatabase.instance.ref("santri/${santri.id}");
        await santriRef.update({
          'nis': santri.nis,
          'nama': santri.nama,
          'kamar': santri.kamar,
          'angkatan': santri.angkatan,
        });
        print("✅ Data santri ID ${santri.id} diperbarui di Firebase");
      } catch (e) {
        print("❌ Gagal update ke Firebase: $e");
      }
    }

    return result;
  }

  Future<int> deleteSantri(int id) async {
    final db = await database;

    // 1️⃣ Hapus nilai lokal dulu
    await db.delete(tableNilai, where: 'santriId = ?', whereArgs: [id]);

    // 2️⃣ Hapus data santri lokal
    int result = await db.delete(tableSantri, where: 'id = ?', whereArgs: [id]);

    // 3️⃣ Hapus dari Firebase jika terhubung
    if (_firebaseConnection.isConnected) {
      try {
        final santriRef = FirebaseDatabase.instance.ref("santri/$id");
        final nilaiRef = FirebaseDatabase.instance.ref("nilai/$id");
        await santriRef.remove();
        await nilaiRef.remove();
        print("✅ Data santri ID $id berhasil dihapus dari Firebase!");
      } catch (e) {
        print("❌ Gagal hapus data dari Firebase: $e");
      }
    }

    return result;
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

    final res = await db.query(
      tableNilai,
      where: 'santriId = ?',
      whereArgs: [santriId],
    );
    if (res.isEmpty) return;

    final current = res.first;

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

    // Sinkronisasi ke Firebase jika terhubung
    if (_firebaseConnection.isConnected) {
      try {
        final nilaiRef = FirebaseDatabase.instance.ref("nilai/$santriId");
        await nilaiRef.update({
          'tahfidz': newTahfidz,
          'fiqh': newFiqh,
          'akhlak': newAkhlak,
          'bahasaArab': newBahasa,
          'kehadiran': newKehadiran,
          'total': total,
          'status': status,
        });
        print("✅ Nilai santri ID $santriId diperbarui di Firebase");
      } catch (e) {
        print("❌ Gagal update nilai ke Firebase: $e");
      }
    }
  }

  Future<List<Map<String, dynamic>>> getAllNilai() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        n.id,
        n.santriId,
        s.nama,
        s.kamar,
        s.nis,
        s.angkatan,
        n.tahfidz,
        n.fiqh,
        n.akhlak,
        n.bahasaArab,
        n.kehadiran,
        n.total,
        n.status
      FROM $tableNilai n
      INNER JOIN $tableSantri s ON n.santriId = s.id
      ORDER BY n.santriId ASC
    ''');
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

  // ===== SYNC METHODS =====
  Future<void> syncLocalToFirebase() async {
    if (!_firebaseConnection.isConnected) {
      print("⚠ Tidak bisa sinkronisasi: Firebase offline!");
      return;
    }

    final db = await database;
    final santriRef = FirebaseDatabase.instance.ref("santri");
    final nilaiRef = FirebaseDatabase.instance.ref("nilai");

    print("⏳ Mulai sinkronisasi SQLite → Firebase...");

    final santriList = await db.query(tableSantri);
    for (var s in santriList) {
      final id = s['id'].toString();
      await santriRef.child(id).set({
        'nis': s['nis'],
        'nama': s['nama'],
        'kamar': s['kamar'],
        'angkatan': s['angkatan'],
      });
    }

    final nilaiList = await db.query(tableNilai);
    for (var n in nilaiList) {
      final santriId = n['santriId'].toString();
      await nilaiRef.child(santriId).set({
        'tahfidz': n['tahfidz'],
        'fiqh': n['fiqh'],
        'akhlak': n['akhlak'],
        'bahasaArab': n['bahasaArab'],
        'kehadiran': n['kehadiran'],
        'total': n['total'],
        'status': n['status'],
      });
    }

    print("✅ Sinkronisasi selesai: Semua data SQLite sudah di Firebase!");
  }

  Future<void> syncFirebaseToLocal() async {
    if (!_firebaseConnection.isConnected) {
      print("⚠ Tidak bisa sinkronisasi: Firebase offline!");
      return;
    }

    final db = await database;
    final santriRef = FirebaseDatabase.instance.ref("santri");
    final nilaiRef = FirebaseDatabase.instance.ref("nilai");

    print("⏳ Mulai sinkronisasi Firebase → SQLite...");

    final santriSnap = await santriRef.get();
    final nilaiSnap = await nilaiRef.get();

    Map santriData = {};
    Map nilaiData = {};

    if (santriSnap.exists) {
      if (santriSnap.value is Map) {
        santriData = santriSnap.value as Map;
      } else if (santriSnap.value is List) {
        final list = santriSnap.value as List;
        for (int i = 0; i < list.length; i++) {
          if (list[i] != null) santriData[i.toString()] = list[i];
        }
      }
    } else {
      print("⚠ Tidak ada data SANTRI di Firebase!");
    }

    if (nilaiSnap.exists) {
      if (nilaiSnap.value is Map) {
        nilaiData = nilaiSnap.value as Map;
      } else if (nilaiSnap.value is List) {
        final list = nilaiSnap.value as List;
        for (int i = 0; i < list.length; i++) {
          if (list[i] != null) nilaiData[i.toString()] = list[i];
        }
      }
    } else {
      print("⚠ Tidak ada data NILAI di Firebase!");
    }

    print("📥 Data Firebase berhasil diambil!");
    print("📦 Total Santri: ${santriData.length}");
    print("📦 Total Nilai: ${nilaiData.length}");

    await db.delete(tableNilai);
    await db.delete(tableSantri);
    print("🗑 Database lokal dikosongkan.");

    for (var entry in santriData.entries) {
      final id = int.tryParse(entry.key) ?? 0;
      final s = entry.value as Map;
      await db.insert(tableSantri, {
        "id": id,
        "nis": s["nis"] ?? "",
        "nama": s["nama"] ?? "",
        "kamar": s["kamar"] ?? "",
        "angkatan": s["angkatan"] ?? 0,
      });
    }

    for (var entry in nilaiData.entries) {
      final santriId = int.tryParse(entry.key) ?? 0;
      final n = entry.value as Map;
      await db.insert(tableNilai, {
        "santriId": santriId,
        "tahfidz": n["tahfidz"] ?? 0,
        "fiqh": n["fiqh"] ?? 0,
        "akhlak": n["akhlak"] ?? 0,
        "bahasaArab": n["bahasaArab"] ?? 0,
        "kehadiran": n["kehadiran"] ?? 0,
        "total": n["total"] ?? 0,
        "status": n["status"] ?? "Tidak Lulus",
      });
    }

    print("✅ Sinkronisasi selesai: Data lokal diperbarui dari Firebase!");
  }
}

class gets extends GetxController {
  var status = false.obs;

  void koneksi() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("makanan");

    try {
      final snapshot = await ref.get();
      if (snapshot.exists) {
        status.value = true;
        print("✅ Firebase Database berhasil diakses!");
        print("Jumlah data: ${snapshot.children.length}");
      } else {
        status.value = false;
        print("⚠ Node 'makanan' tidak ditemukan di Firebase Database.");
      }
    } catch (e) {
      status.value = false;
      print("❌ Gagal mengakses Firebase Database: $e");
    }
  }
}

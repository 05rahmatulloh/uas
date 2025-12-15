import 'dart:async';
import 'dart:io';

import 'package:Santri/features/admin/view/input/ustadz.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:get/utils.dart';
import 'package:provider/provider.dart';
import 'package:Santri/core/dbhelper.dart';
import 'package:Santri/features/admin/view/crud_santri.dart';
import 'package:Santri/features/admin/view/input_nilai_mapel.dart';
import 'package:Santri/features/admin/view/ubah_bobot.dart';
import 'package:Santri/features/admin/view/laporan.dart';
import 'package:Santri/features/admin/view/daftar_santri.dart';
import 'package:Santri/features/auth/view/login_page.dart';
import '../../../providers/providers_auth.dart';

class AdminPage extends StatefulWidget {
  AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final DBHelper db = DBHelper();
  bool firebaseStatus = false;
  Timer? timer;
  bool status = false;

  @override
  void initState() {
    super.initState();
    checkConnection(); // cek pertama
    koneksi();
    timer = Timer.periodic(Duration(seconds: 10), (_) => checkConnection());
  }

  void koneksi() async {
    final DatabaseReference ref = FirebaseDatabase.instance.ref("santri");

    try {
      final snapshot = await ref.get();
      if (snapshot.exists) {
        status = true;
        print("✅ Firebase Database berhasil diakses!");
        print("Jumlah data: ${snapshot.children.length}");
      } else {
        print("⚠ Database kosong tapi koneksi berhasil.");
      }
    } catch (e) {
      print("❌ Gagal akses Firebase Database: $e");
    }
  }

  Future<bool> checkConnection() async {
    try {
      // 🔹 1. CEK INTERNET dengan ping ke Google
      final result = await InternetAddress.lookup('google.com');

      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        print("❌ Tidak ada internet");
        return false;
      }

      print("🌐 Internet OK! lanjut cek Firebase...");

      // 🔹 2. CEK FIREBASE
      final ref = FirebaseDatabase.instance.ref("makanan");
      final snapshot = await ref.get();

      bool firebaseStatus = snapshot.exists;
      print("🔥 Firebase Connected: $firebaseStatus");

      status = firebaseStatus;

      return firebaseStatus;
    } catch (e) {
      print("❌ Error saat cek internet/Firebase: $e");
      status = firebaseStatus;

      return false;
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  final tes = Get.put(gets());

  @override
  Widget build(BuildContext context) {
    final userEmail = context.read<AuthProvider>().user?.email ?? '';
    // final firebaseStatus = context
    //     .watch<FirebaseConnectionProvider>()
    //     .isConnected;
    // koneksi();
tes.koneksi();
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: "Refresh Status",
            onPressed: () async {
              // cek ulang koneksi
              await checkConnection();
              setState(() {}); // refresh UI
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx((){
              {return tes.status.value 
                ? Icon(Icons.wifi, color: Colors.greenAccent)
                : Icon(Icons.wifi_off_outlined, color: Colors.red);}
            }),
            // Tombol Sinkronisasi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //   ElevatedButton(
                //     onPressed: status
                //         ? () async {
                //             await DBHelper().syncLocalToFirebase();
                //             ScaffoldMessenger.of(context).showSnackBar(
                //               SnackBar(
                //                 content: Text(
                //                   "Data Local → Firebase berhasil dikirim",
                //                 ),
                //               ),
                //             );
                //           }
                //         : null, // disable jika tidak ada koneksi
                //     child: Text("Kirim Ke server"),
                //   ),
                //   ElevatedButton(
                //     onPressed: status
                //         ? () async {
                //             await DBHelper().syncFirebaseToLocal();
                //             ScaffoldMessenger.of(context).showSnackBar(
                //               SnackBar(
                //                 content: Text(
                //                   "Data Firebase → Local berhasil disalin",
                //                 ),
                //               ),
                //             );
                //           }
                //         : null, // disable jika tidak ada koneksi
                //     child: Text("Refresh"),
                //   ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Selamat datang, Admin",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              userEmail,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildCard(
                    icon: Icons.person,
                    title: "Manage Santri",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CrudSantri()),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.book,
                    title: "Manage Subjects",
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MataPelajaranPage()),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.check_circle,
                    title: "Manage Grades",
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BobotFormPage()),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.analytics,
                    title: "Reports",
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NilaiDetailPage()),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.list_alt,
                    title: "Daftar Santri",
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DaftarSantriPage()),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.list_alt,
                    title: "Daftar Ustadz",
                    color: const Color.fromARGB(255, 148, 148, 148),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InputUserPageUstadz(),
                        ),
                      );
                    },
                  ),
                  // Tambahkan kartu lainnya...
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

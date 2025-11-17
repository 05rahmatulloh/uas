import 'package:flutter/material.dart';
import 'package:itull2/features/admin/controllers/bobot_nilai.dart';
// import 'package:itull2/features/admin/view/crud_mata_pelajaran.dart';
import 'package:itull2/features/admin/view/crud_santri.dart';
import 'package:itull2/features/admin/view/input_nilai_mapel.dart';
import 'package:itull2/features/admin/view/laporan.dart';
import 'package:itull2/features/admin/view/ubah_bobot.dart';
import 'package:itull2/features/santri/views/santri_page.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers_auth.dart';
import '../../auth/view/login_page.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userEmail = context.read<AuthProvider>().user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        actions: [
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
                    title: "Manage santri",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CrudSantri(), // halaman tujuan
                        ),
                      );
                    },
                  ),

                  _buildCard(
                    icon: Icons.book,
                    title: "Manage Subjects",
                    color: Colors.green,
                    onTap: () {
                      print("sudah");
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

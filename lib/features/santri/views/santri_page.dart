import 'package:flutter/material.dart';
import 'package:Santri/core/dbhelper.dart';
import 'package:Santri/features/admin/model/santri_model.dart';
import 'package:Santri/features/auth/view/login_page.dart';
import 'package:Santri/features/santri/views/santri_detile.dart';
import 'package:Santri/providers/providers_auth.dart';
import 'package:provider/provider.dart';
// import 'package:Santri/features/admin/services/db_helper.dart';
// import 'santri_nilai_detail_page.dart';

class SantriNilaiListPage extends StatefulWidget {
  const SantriNilaiListPage({super.key});

  @override
  _SantriNilaiListPageState createState() => _SantriNilaiListPageState();
}

class _SantriNilaiListPageState extends State<SantriNilaiListPage> {
  List<Santri> santriList = [];

  @override
  void initState() {
    super.initState();
    loadSantri();
  }

  Future<void> loadSantri() async {
    santriList = await DBHelper().getAllSantri();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daftar Nilai Santri"),
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
      body: santriList.isEmpty
          ? Center(child: Text("Belum ada data santri"))
          : ListView.builder(
              itemCount: santriList.length,
              itemBuilder: (context, index) {
                final santri = santriList[index];

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(santri.nama),
                    subtitle: Text(
                      "NIS: ${santri.nis} | Kamar: ${santri.kamar}",
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SantriNilaiDetailPage(santriId: santri.id!),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

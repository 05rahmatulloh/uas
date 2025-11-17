import 'package:flutter/material.dart';
import 'package:itull2/features/admin/controllers/bobot_nilai.dart';
import 'package:provider/provider.dart';
import 'package:itull2/features/admin/dbhelper.dart';
// import 'package:itull2/features/admin/controllers/bobot_provider.dart';

class NilaiDetailPage extends StatefulWidget {
  @override
  State<NilaiDetailPage> createState() => _NilaiDetailPageState();
}

class _NilaiDetailPageState extends State<NilaiDetailPage> {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> allNilai = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadNilai();
  }

  Future<void> loadNilai() async {
    final nilai = await dbHelper.getAllNilai();
    setState(() {
      allNilai = nilai;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bobot = Provider.of<BobotProvider>(context).bobot;

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Nilai Santri"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : ListView.builder(
              itemCount: allNilai.length,
              itemBuilder: (context, index) {
                final n = allNilai[index];

                double nilaiAkhir =
                    ((n['tahfidz'] * bobot['Tahfidz']!) +
                        (n['fiqh'] * bobot['Fiqh']!) +
                        (n['bahasaArab'] * bobot['Bahasa Arab']!) +
                        (n['akhlak'] * bobot['Akhlak']!) +
                        (n['kehadiran'] * bobot['Kehadiran']!)) /
                    100;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Santri ID: ${n['santriId']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text("Tahfidz: ${n['tahfidz']} x ${bobot['Tahfidz']}%"),
                        Text("Fiqh: ${n['fiqh']} x ${bobot['Fiqh']}%"),
                        Text(
                          "Bahasa Arab: ${n['bahasaArab']} x ${bobot['Bahasa Arab']}%",
                        ),
                        Text("Akhlak: ${n['akhlak']} x ${bobot['Akhlak']}%"),
                        Text(
                          "Kehadiran: ${n['kehadiran']} x ${bobot['Kehadiran']}%",
                        ),
                        Divider(),
                        Text(
                          "Nilai Akhir: ${nilaiAkhir.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text("Status: ${n['status']}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Santri/core/dbhelper.dart';
import 'package:Santri/features/admin/model/santri_model.dart';

class FormInputTahfidzPage extends StatefulWidget {
  const FormInputTahfidzPage({super.key});

  @override
  State<FormInputTahfidzPage> createState() => _FormInputTahfidzPageState();
}

class _FormInputTahfidzPageState extends State<FormInputTahfidzPage> {
  final DBHelper dbHelper = DBHelper();
  List<Santri> santriList = [];

  // Controller per santri
  Map<int, TextEditingController> setoranControllers = {};
  Map<int, TextEditingController> targetControllers = {};
  Map<int, TextEditingController> tajwidControllers = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSantri();
  }

  Future<void> loadSantri() async {
    List<Santri> list = await dbHelper.getAllSantri();
    setState(() {
      santriList = list;
      loading = false;

      for (var s in list) {
        setoranControllers[s.id!] = TextEditingController();
        targetControllers[s.id!] = TextEditingController();
        tajwidControllers[s.id!] = TextEditingController();
      }
    });
  }

  @override
  void dispose() {
    setoranControllers.forEach((_, c) => c.dispose());
    targetControllers.forEach((_, c) => c.dispose());
    tajwidControllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void simpanNilaiTahfidz(int santriId) async {
    final setoran = int.tryParse(setoranControllers[santriId]!.text);
    final target = int.tryParse(targetControllers[santriId]!.text);
    final tajwid = int.tryParse(tajwidControllers[santriId]!.text);

    if (setoran == null || target == null || tajwid == null || target == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pastikan semua nilai terisi dan target > 0")),
      );
      return;
    }

    // Perhitungan nilai
    double capaian = (setoran / target) * 100;
    if (capaian > 100) capaian = 100;

    int nilaiAkhir = ((0.5 * capaian) + (0.5 * tajwid)).round();

    // Simpan ke database memakai DBHelper.updateNilai
    await dbHelper.updateNilai(
      santriId: santriId,
      tahfidz: nilaiAkhir, // disimpan ke field tahfidz
    );

    // Reset input
    setoranControllers[santriId]!.clear();
    targetControllers[santriId]!.clear();
    tajwidControllers[santriId]!.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Nilai Tahfidz tersimpan: $nilaiAkhir")),
    );
  }

  Widget buildField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Input Nilai Tahfidz"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: santriList.length,
              itemBuilder: (context, index) {
                final s = santriList[index];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.green),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${s.nama} (${s.nis})",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),

                        buildField("Setoran", setoranControllers[s.id!]!),
                        SizedBox(height: 10),
                        buildField("Target", targetControllers[s.id!]!),
                        SizedBox(height: 10),
                        buildField("Tajwid", tajwidControllers[s.id!]!),

                        SizedBox(height: 12),

                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.save),
                            label: Text("Simpan"),
                            onPressed: () => simpanNilaiTahfidz(s.id!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

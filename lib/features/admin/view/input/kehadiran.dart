import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Santri/core/dbhelper.dart';
import 'package:Santri/features/admin/model/santri_model.dart';

class FormInputKehadiranPage extends StatefulWidget {
  const FormInputKehadiranPage({super.key});

  @override
  State<FormInputKehadiranPage> createState() => _FormInputKehadiranPageState();
}

class _FormInputKehadiranPageState extends State<FormInputKehadiranPage> {
  final DBHelper dbHelper = DBHelper();
  List<Santri> santriList = [];
  bool loading = true;

  Map<int, TextEditingController> hadirControllers = {};
  Map<int, TextEditingController> sakitControllers = {};
  Map<int, TextEditingController> izinControllers = {};
  Map<int, TextEditingController> alfaControllers = {};

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
        hadirControllers[s.id!] = TextEditingController();
        sakitControllers[s.id!] = TextEditingController();
        izinControllers[s.id!] = TextEditingController();
        alfaControllers[s.id!] = TextEditingController();
      }
    });
  }

  @override
  void dispose() {
    hadirControllers.forEach((_, c) => c.dispose());
    sakitControllers.forEach((_, c) => c.dispose());
    izinControllers.forEach((_, c) => c.dispose());
    alfaControllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void simpanNilai(int santriId) async {
    int? hadir = int.tryParse(hadirControllers[santriId]!.text);
    int? sakit = int.tryParse(sakitControllers[santriId]!.text);
    int? izin = int.tryParse(izinControllers[santriId]!.text);
    int? alfa = int.tryParse(alfaControllers[santriId]!.text);

    if ([hadir, sakit, izin, alfa].contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isi semua kolom terlebih dahulu')),
      );
      return;
    }

    int total = hadir! + sakit! + izin! + alfa!;
    if (total == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Total kehadiran tidak boleh 0')));
      return;
    }

    int nilaiKehadiran = ((hadir / total) * 100).round();

    await dbHelper.updateNilai(santriId: santriId, kehadiran: nilaiKehadiran);

    hadirControllers[santriId]!.clear();
    sakitControllers[santriId]!.clear();
    izinControllers[santriId]!.clear();
    alfaControllers[santriId]!.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nilai Kehadiran tersimpan: $nilaiKehadiran')),
    );
  }

  Widget buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Kehadiran'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: loading
            ? Center(child: CircularProgressIndicator(color: Colors.green))
            : santriList.isEmpty
            ? Center(child: Text('Tidak ada santri'))
            : ListView.builder(
                itemCount: santriList.length,
                itemBuilder: (context, index) {
                  final s = santriList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s.nama} (${s.nis})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 12),
                          buildInputField('Hadir', hadirControllers[s.id!]!),
                          SizedBox(height: 8),
                          buildInputField('Sakit', sakitControllers[s.id!]!),
                          SizedBox(height: 8),
                          buildInputField('Izin', izinControllers[s.id!]!),
                          SizedBox(height: 8),
                          buildInputField('Alfa', alfaControllers[s.id!]!),
                          SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.save),
                              label: Text('Simpan'),
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
                              onPressed: () => simpanNilai(s.id!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

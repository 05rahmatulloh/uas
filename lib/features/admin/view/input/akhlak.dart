import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Santri/core/dbhelper.dart';
import 'package:Santri/features/admin/model/santri_model.dart';

class FormInputAkhlakPage extends StatefulWidget {
  const FormInputAkhlakPage({super.key});

  @override
  State<FormInputAkhlakPage> createState() => _FormInputAkhlakPageState();
}

class _FormInputAkhlakPageState extends State<FormInputAkhlakPage> {
  final DBHelper dbHelper = DBHelper();
  List<Santri> santriList = [];
  bool loading = true;

  // Controller untuk keempat komponen akhlak
  Map<int, TextEditingController> disiplinControllers = {};
  Map<int, TextEditingController> adabControllers = {};
  Map<int, TextEditingController> kebersihanControllers = {};
  Map<int, TextEditingController> kerjasamaControllers = {};

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
        disiplinControllers[s.id!] = TextEditingController();
        adabControllers[s.id!] = TextEditingController();
        kebersihanControllers[s.id!] = TextEditingController();
        kerjasamaControllers[s.id!] = TextEditingController();
      }
    });
  }

  @override
  void dispose() {
    disiplinControllers.forEach((_, c) => c.dispose());
    adabControllers.forEach((_, c) => c.dispose());
    kebersihanControllers.forEach((_, c) => c.dispose());
    kerjasamaControllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void simpanNilai(int santriId) async {
    int? disiplin = int.tryParse(disiplinControllers[santriId]!.text);
    int? adab = int.tryParse(adabControllers[santriId]!.text);
    int? kebersihan = int.tryParse(kebersihanControllers[santriId]!.text);
    int? kerjasama = int.tryParse(kerjasamaControllers[santriId]!.text);

    if ([disiplin, adab, kebersihan, kerjasama].contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isi semua nilai terlebih dahulu')),
      );
      return;
    }

    for (var nilai in [disiplin!, adab!, kebersihan!, kerjasama!]) {
      if (nilai < 0 || nilai > 4) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Nilai harus antara 1–4')));
        return;
      }
    }

    double avg = (disiplin + adab + kebersihan + kerjasama) / 4;
    int nilaiAkhlak = ((avg / 4) * 100).round();

    await dbHelper.updateNilai(santriId: santriId, akhlak: nilaiAkhlak);

    disiplinControllers[santriId]!.clear();
    adabControllers[santriId]!.clear();
    kebersihanControllers[santriId]!.clear();
    kerjasamaControllers[santriId]!.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nilai Akhlak tersimpan: $nilaiAkhlak')),
    );
  }

  Widget buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(1), // hanya 1 digit 1–4
      ],
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
        title: Text('Input Nilai Akhlak'),
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
                          buildInputField(
                            'Disiplin (1-4)',
                            disiplinControllers[s.id!]!,
                          ),
                          SizedBox(height: 8),
                          buildInputField(
                            'Adab (1-4)',
                            adabControllers[s.id!]!,
                          ),
                          SizedBox(height: 8),
                          buildInputField(
                            'Kebersihan (1-4)',
                            kebersihanControllers[s.id!]!,
                          ),
                          SizedBox(height: 8),
                          buildInputField(
                            'Kerjasama (1-4)',
                            kerjasamaControllers[s.id!]!,
                          ),
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

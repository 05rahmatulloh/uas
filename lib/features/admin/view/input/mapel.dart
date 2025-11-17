import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itull2/features/admin/dbhelper.dart';
import 'package:itull2/features/admin/model/santri_model.dart';

class FormInputMapelPage extends StatefulWidget {
  final String mataPelajaran;
  FormInputMapelPage({required this.mataPelajaran});

  @override
  State<FormInputMapelPage> createState() => _FormInputMapelPageState();
}

class _FormInputMapelPageState extends State<FormInputMapelPage> {
  final DBHelper dbHelper = DBHelper();
  List<Santri> santriList = [];
  bool loading = true;

  Map<int, TextEditingController> formatifControllers = {};
  Map<int, TextEditingController> sumatifControllers = {};

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
        formatifControllers[s.id!] = TextEditingController();
        sumatifControllers[s.id!] = TextEditingController();
      }
    });
  }

  @override
  void dispose() {
    formatifControllers.forEach((_, c) => c.dispose());
    sumatifControllers.forEach((_, c) => c.dispose());
    super.dispose();
  }
void simpanNilai(int santriId) async {
    int? formatif = int.tryParse(formatifControllers[santriId]!.text);
    int? sumatif = int.tryParse(sumatifControllers[santriId]!.text);

    if (formatif == null && sumatif == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Isi setidaknya satu nilai')));
      return;
    }

    await dbHelper.updateNilai(
      santriId: santriId,
      fiqh: widget.mataPelajaran == 'Fiqh' ? formatif : null,
      bahasaArab: widget.mataPelajaran == 'Bahasa Arab' ? sumatif : null,
    );

    // Bersihkan hanya field yang diisi
    if (formatif != null) formatifControllers[santriId]!.clear();
    if (sumatif != null) sumatifControllers[santriId]!.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Nilai tersimpan')));
  }

  Widget buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
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
        title: Text('Input ${widget.mataPelajaran}'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: loading
            ? Center(child: CircularProgressIndicator(color: Colors.green))
            : santriList.isEmpty
            ? Center(
                child: Text(
                  'Tidak ada santri',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            : ListView.builder(
                itemCount: santriList.length,
                itemBuilder: (context, index) {
                  final s = santriList[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.green),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${s.nama} (${s.nis})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          buildInputField(
                            'Formatif (0-100)',
                            formatifControllers[s.id!]!,
                          ),
                          SizedBox(height: 10),
                          buildInputField(
                            'Sumatif (0-100)',
                            sumatifControllers[s.id!]!,
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

import 'package:flutter/material.dart';
import 'package:Santri/features/admin/controllers/bobot_nilai.dart';
import 'package:provider/provider.dart';
import 'package:Santri/core/dbhelper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class NilaiDetailPage extends StatefulWidget {
  const NilaiDetailPage({super.key});

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

  // ===== Generate PDF =====
  Future<void> generatePdf(
    Map<String, dynamic> n,
    Map<String, double> bobot,
  ) async {
    final pdf = pw.Document();

    double nilaiAkhir =
        ((n['tahfidz'] * bobot['Tahfidz']!) +
            (n['fiqh'] * bobot['Fiqh']!) +
            (n['bahasaArab'] * bobot['Bahasa Arab']!) +
            (n['akhlak'] * bobot['Akhlak']!) +
            (n['kehadiran'] * bobot['Kehadiran']!)) /
        100;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "RAPOR SANTRI",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),

              pw.Text(
                "Nama       : ${n['nama']}",
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                "Kamar      : ${n['kamar']}",
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                "Santri ID  : ${n['santriId']}",
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 16),

              pw.Text("Tahfidz: ${n['tahfidz']} x ${bobot['Tahfidz']}%"),
              pw.Text("Fiqh: ${n['fiqh']} x ${bobot['Fiqh']}%"),
              pw.Text(
                "Bahasa Arab: ${n['bahasaArab']} x ${bobot['Bahasa Arab']}%",
              ),
              pw.Text("Akhlak: ${n['akhlak']} x ${bobot['Akhlak']}%"),
              pw.Text("Kehadiran: ${n['kehadiran']} x ${bobot['Kehadiran']}%"),

              pw.Divider(),
              pw.Text(
                "Nilai Akhir: ${nilaiAkhir.toStringAsFixed(2)}",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text("Status: ${n['status']}"),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
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
                        // ==== Tambahan: Nama & Kamar di tampilan list ====
                        Text(
                          "Nama: ${n['nama']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        Text("Kamar: ${n['kamar']}"),
                        Text("Santri ID: ${n['santriId']}"),
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
                        SizedBox(height: 12),

                        ElevatedButton.icon(
                          onPressed: () => generatePdf(n, bobot),
                          icon: Icon(Icons.picture_as_pdf),
                          label: Text("Download PDF"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
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

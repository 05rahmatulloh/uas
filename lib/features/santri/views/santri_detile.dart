import 'package:flutter/material.dart';
import 'package:Santri/core/dbhelper.dart';

class SantriNilaiDetailPage extends StatefulWidget {
  final int santriId;

  const SantriNilaiDetailPage({super.key, required this.santriId});

  @override
  _SantriNilaiDetailPageState createState() => _SantriNilaiDetailPageState();
}

class _SantriNilaiDetailPageState extends State<SantriNilaiDetailPage> {
  Map<String, dynamic>? nilai;
  double nilaiAkhir = 0;
  String status = "-";

  @override
  void initState() {
    super.initState();
    loadNilai();
  }

  Future<void> loadNilai() async {
    nilai = await DBHelper().getNilaiBySantri(widget.santriId);

    if (nilai != null) {
      hitungNilaiAkhir();
    }

    setState(() {});
  }

  void hitungNilaiAkhir() {
    double tahfidz = nilai!["tahfidz"] * 1.0;
    double fiqh = nilai!["fiqh"] * 1.0;
    double bahasaArab = nilai!["bahasaArab"] * 1.0;
    double akhlak = nilai!["akhlak"] * 1.0;
    double kehadiran = nilai!["kehadiran"] * 1.0;

    // Bobot
    double bobotTahfidz = 30;
    double bobotFiqh = 20;
    double bobotBahasaArab = 20;
    double bobotAkhlak = 20;
    double bobotKehadiran = 10;

    nilaiAkhir =
        ((tahfidz * bobotTahfidz) +
            (fiqh * bobotFiqh) +
            (bahasaArab * bobotBahasaArab) +
            (akhlak * bobotAkhlak) +
            (kehadiran * bobotKehadiran)) /
        100;

    status = nilaiAkhir >= 75 ? "Lulus" : "Tidak Lulus";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Nilai Santri")),
      body: nilai == null
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(20),
              children: [
                buildTile("Tahfidz", nilai!["tahfidz"]),
                buildTile("Fiqh", nilai!["fiqh"]),
                buildTile("Akhlak", nilai!["akhlak"]),
                buildTile("Bahasa Arab", nilai!["bahasaArab"]),
                buildTile("Kehadiran", nilai!["kehadiran"]),
                Divider(height: 30),
                buildTile(
                  "Total Nilai (Akhir)",
                  nilaiAkhir.toStringAsFixed(2),
                  bold: true,
                ),

                buildTile(
                  "Status",
                  status,
                  bold: true,
                  color: status == "Lulus" ? Colors.green : Colors.red,
                ),
              ],
            ),
    );
  }

  Widget buildTile(
    String title,
    dynamic value, {
    bool bold = false,
    Color? color,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value.toString(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
      ),
    );
  }
}

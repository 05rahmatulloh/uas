import 'package:flutter/material.dart';
import 'package:itull2/features/admin/view/input/akhlak.dart';
import 'package:itull2/features/admin/view/input/kehadiran.dart';
// import 'package:itull2/features/admin/view/form_input_nilai.dart';
import 'package:itull2/features/admin/view/input/mapel.dart';
// import 'package:itull2/features/admin/view/form_input_tahfidz.dart';
// import 'package:itull2/features/admin/view/form_input_fiqh.dart';
// import 'package:itull2/features/admin/view/form_input_akhlak.dart';
// import 'package:itull2/features/admin/view/form_input_kehadiran.dart';
import 'package:itull2/features/admin/view/input/tahfiz.dart';

class MataPelajaranPage extends StatelessWidget {
  final List<String> mataPelajaran = [
    'Tahfidz',
    'Fiqh',
    'Bahasa Arab',
    'Akhlak',
    'Kehadiran',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pilih Mata Pelajaran')),
      body: ListView.builder(
        itemCount: mataPelajaran.length,
        itemBuilder: (context, index) {
          final mata = mataPelajaran[index];
          return ListTile(
            title: Text(mata),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Widget page;

              switch (mata) {
                case 'Tahfidz':
                  page = FormInputTahfidzPage();
                  break;
                case 'Fiqh':
                case 'Bahasa Arab':
                  page = FormInputMapelPage(mataPelajaran: '',);
                  break;
                case 'Akhlak':
                  page = FormInputAkhlakPage();
                  break;
                case 'Kehadiran':
                  page = FormInputKehadiranPage();
                  break;
                default:
                  page = FormInputTahfidzPage();
              }

              Navigator.push(context, MaterialPageRoute(builder: (_) => page));
            },
          );
        },
      ),
    );
  }
}

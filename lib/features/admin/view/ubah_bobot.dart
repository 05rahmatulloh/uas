import 'package:flutter/material.dart';
import 'package:itull2/features/admin/controllers/bobot_nilai.dart';
import 'package:provider/provider.dart';
// import 'bobot_provider.dart';

class BobotFormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bobotProvider = Provider.of<BobotProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Atur Bobot Nilai')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: bobotProvider.bobot.keys.map((mata) {
          final controller = TextEditingController(
            text: bobotProvider.bobot[mata]!.toString(),
          );

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(mata),
              trailing: SizedBox(
                width: 80,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(suffixText: '%'),
           onSubmitted: (value) {
                    double newValue =
                        double.tryParse(value) ?? bobotProvider.bobot[mata]!;

                    // Hitung total bobot sementara
                    double totalSebelum = bobotProvider.bobot.values.fold(
                      0,
                      (a, b) => a + b,
                    );
                    double totalSetelah =
                        totalSebelum - bobotProvider.bobot[mata]! + newValue;

                    if (totalSetelah > 100) {
                      // Tampilkan peringatan jika total lebih dari 100
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Total bobot tidak boleh lebih dari 100%! Saat ini total: $totalSetelah%',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      // Simpan bobot baru jika valid
                      bobotProvider.setBobot(mata, newValue);
                    }
                  },

                 ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:Santri/features/admin/controllers/bobot_nilai.dart';
import 'package:provider/provider.dart';
// import 'bobot_provider.dart';

class BobotFormPage extends StatelessWidget {
  const BobotFormPage({super.key});

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

                    // Hitung total bobot setelah perubahan
                    double totalSementara =
                        bobotProvider.bobot.values.fold(0.0, (a, b) => a + b) -
                        bobotProvider.bobot[mata]! +
                        newValue;

                    if (totalSementara > 100) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Total bobot tidak boleh lebih dari 100%! Saat ini: $totalSementara%',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (totalSementara < 100) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Total bobot harus 100%! Saat ini: $totalSementara%',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
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

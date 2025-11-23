import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:Santri/core/dbhelper.dart';
import 'package:Santri/features/admin/model/santri_model.dart';

class DaftarSantriPage extends StatefulWidget {
  const DaftarSantriPage({super.key});

  @override
  State<DaftarSantriPage> createState() => _DaftarSantriPageState();
}

class _DaftarSantriPageState extends State<DaftarSantriPage> {
  final DBHelper dbHelper = DBHelper();
  List<Santri> santriList = [];
  List<Santri> filteredList = [];

  String search = '';
  String? filterKamar;
  int? filterAngkatan;

  @override
  void initState() {
    super.initState();
    loadSantri();
  }

  Future<void> loadSantri() async {
    List<Santri> list = await dbHelper.getAllSantri();
    setState(() {
      santriList = list;
      filteredList = list;
    });
  }

  void applyFilter() {
    setState(() {
      filteredList = santriList.where((s) {
        final matchesSearch = s.nama.toLowerCase().contains(
          search.toLowerCase(),
        );
        final matchesKamar = filterKamar == null || s.kamar == filterKamar;
        final matchesAngkatan =
            filterAngkatan == null || s.angkatan == filterAngkatan;
        return matchesSearch && matchesKamar && matchesAngkatan;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Santri'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama santri...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                search = value;
                applyFilter();
              },
            ),
          ),
          // Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: filterKamar,
                    decoration: InputDecoration(
                      labelText: 'Filter Kamar',
                      border: OutlineInputBorder(),
                    ),
                    items: ['A1', 'A2', 'B1', 'B2']
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (v) {
                      filterKamar = v;
                      applyFilter();
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: filterAngkatan,
                    decoration: InputDecoration(
                      labelText: 'Filter Angkatan',
                      border: OutlineInputBorder(),
                    ),
                    items: [2023, 2024, 2025]
                        .map(
                          (a) => DropdownMenuItem(value: a, child: Text('$a')),
                        )
                        .toList(),
                    onChanged: (v) {
                      filterAngkatan = v;
                      applyFilter();
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          // List Santri
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final s = filteredList[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(s.nama),
                    subtitle: Text(
                      'NIS: ${s.nis} | Kamar: ${s.kamar} | Angkatan: ${s.angkatan}',
                    ),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailSantriPage(santri: s),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Detail Santri =====
class DetailSantriPage extends StatefulWidget {
  final Santri santri;
  const DetailSantriPage({super.key, required this.santri});

  @override
  State<DetailSantriPage> createState() => _DetailSantriPageState();
}

class _DetailSantriPageState extends State<DetailSantriPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final DBHelper dbHelper = DBHelper();
  Map<String, dynamic>? nilai;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    loadNilai();
  }

  Future<void> loadNilai() async {
    final n = await dbHelper.getNilaiBySantri(widget.santri.id!);
    setState(() {
      nilai = n;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.santri.nama),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Penilaian'),
            Tab(text: 'Kehadiran'),
            Tab(text: 'Grafik Tahfidz'),
            Tab(text: 'Rapor'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          // Penilaian
          nilai == null
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ListTile(
                      title: const Text('Tahfidz'),
                      trailing: Text('${nilai!['tahfidz']}'),
                    ),
                    ListTile(
                      title: const Text('Fiqh'),
                      trailing: Text('${nilai!['fiqh']}'),
                    ),
                    ListTile(
                      title: const Text('Bahasa Arab'),
                      trailing: Text('${nilai!['bahasaArab']}'),
                    ),
                    ListTile(
                      title: const Text('Akhlak'),
                      trailing: Text('${nilai!['akhlak']}'),
                    ),
                  ],
                ),

          // Kehadiran
          nilai == null
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ListTile(
                      title: const Text('Hadir'),
                      trailing: Text('${nilai!['kehadiran']} %'),
                    ),
                  ],
                ),

          // Grafik Tahfidz menggunakan fl_chart
          nilai == null
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('Tahfidz');
                                default:
                                  return const Text('');
                              }
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: (nilai!['tahfidz'] as int).toDouble(),
                              color: Colors.green,
                              width: 30,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

          // Rapor
          nilai == null
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ListTile(
                      title: const Text('Total'),
                      trailing: Text('${nilai!['total']}'),
                    ),
                    ListTile(
                      title: const Text('Status'),
                      trailing: Text('${nilai!['status']}'),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportList extends StatefulWidget {
  @override
  _ReportListState createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  List<Map<String, dynamic>> reportData = [];
  List<Map<String, dynamic>> filteredData = [];
  String? selectedKamar;
  DateTime? selectedDate;
  bool isLoading = true; // Variabel untuk menandakan status loading

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    reportData.clear(); // Kosongkan data sebelumnya
    setState(() {
      isLoading = true; // Set loading menjadi true saat mengambil data
    });

    // Mengambil semua dokumen dari koleksi 'laporan'
    final snapshot = await FirebaseFirestore.instance.collection('laporan').get();

    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        var itemData = doc.data();
        var dataList = itemData['data'] as List<dynamic>?;

        if (dataList != null) {
          for (var item in dataList) {
            // Menyimpan data ke dalam list reportData
            reportData.add({
              'bulan': doc.id,
              'jumlahKamar': item['jumlahKamar'],
              'kamar': item['kamar'],
              'tanggalCheckout': item['tanggalCheckout'],
              'tahun': item['tahun'],
            });
          }
        }
      }
    }

    // Setelah data diambil, set loading menjadi false
    setState(() {
      filteredData = reportData; // Mengatur filteredData ke reportData awal
      isLoading = false; // Mengatur status loading menjadi false
    });
  }

  void _filterData() {
    filteredData = reportData.where((report) {
      bool matchKamar = selectedKamar == null || selectedKamar == 'Semua' || report['kamar'] == selectedKamar;
      bool matchDate = selectedDate == null || report['tanggalCheckout'] == "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
      return matchKamar && matchDate;
    }).toList();
    setState(() {});
  }

  void _onKamarChanged(String? newValue) {
    setState(() {
      selectedKamar = newValue;
      // Jika "Semua" dipilih, reset tanggal juga
      if (selectedKamar == 'Semua') {
        selectedDate = null; // Reset tanggal
      }
    });
    _filterData();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _filterData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan semua nama kamar unik untuk dropdown
    final kamarNames = reportData.map((report) => report['kamar'] as String).toSet().toList();
    kamarNames.insert(0, 'Semua'); // Menambahkan pilihan "Semua"

    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Kamar"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    hint: const Text('Pilih Kamar'),
                    value: selectedKamar,
                    isExpanded: true,
                    onChanged: _onKamarChanged, // Menggunakan metode baru untuk menangani perubahan
                    items: kamarNames.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text(selectedDate == null ? 'Pilih Tanggal' : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading // Cek apakah loading
                ? Center(child: CircularProgressIndicator()) // Menampilkan indikator loading
                : filteredData.isEmpty
                    ? Center(child: Text('Tidak ada data yang ditemukan.')) // Menampilkan keterangan ketika tidak ada data
                    : ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          final report = filteredData[index];
                          return Card( // Menambahkan Card untuk setiap item
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 4,
                            child: ListTile(
                              title: Text('Kamar: ${report['kamar']}'),
                              subtitle: Text('Jumlah Kamar: ${report['jumlahKamar']} \n'
                                  'Tanggal Checkout: ${report['tanggalCheckout']} \n'
                                  'Bulan: ${report['bulan']}'),
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

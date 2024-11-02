import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<Map<String, dynamic>>? checkInDataList;

  @override
  void initState() {
    super.initState();
    _fetchCheckInData();
  }

  Future<void> _fetchCheckInData() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('checkin').get();
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        checkInDataList = querySnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Simpan ID dokumen untuk referensi nanti
          return data;
        }).toList();
      });
    } else {
      setState(() {
        checkInDataList = []; // Set list kosong jika tidak ada data
      });
    }
  }

  Future<void> _checkout(Map<String, dynamic> checkInData) async {
    if (checkInData != null) {
      try {
        final kamarNama = checkInData['kamar'];
        final jumlahKamar = checkInData['jumlahKamar'];

        // Mendapatkan tanggal checkout dalam format YYYY-MM-DD
        String checkOutDate = DateTime.now().toString().split(' ')[0];

        // Mendapatkan nama bulan
        String bulan = DateTime.now().month.toString(); // Mengambil bulan sebagai angka
        String tahun = DateTime.now().year.toString(); // Mengambil tahun

        // Menyimpan data laporan di bulan yang sesuai
        await FirebaseFirestore.instance.collection('laporan').doc('$tahun-$bulan').set({
          'bulan': bulan,
          'tahun': tahun,
          'data': FieldValue.arrayUnion([
            {
              'tanggalCheckout': checkOutDate,
              'kamar': kamarNama,
              'jumlahKamar': jumlahKamar,
            },
          ]),
        }, SetOptions(merge: true)); // Gunakan merge untuk mengupdate dokumen tanpa menghapus data yang ada

        // Mengupdate jumlah kamar
        final kamarSnapshot = await FirebaseFirestore.instance.collection('kamar').where('nama', isEqualTo: kamarNama).get();
        
        if (kamarSnapshot.docs.isNotEmpty) {
          final kamarDoc = kamarSnapshot.docs.first;
          await FirebaseFirestore.instance.collection('kamar').doc(kamarDoc.id).update({
            'jumlah': FieldValue.increment(jumlahKamar),
          });
        }

        // Menghapus data checkin setelah checkout
        await FirebaseFirestore.instance.collection('checkin').doc(checkInData['id']).delete();

        // Fetch ulang data check-in setelah checkout
        await _fetchCheckInData();

        // Tampilkan pesan berhasil tanpa navigasi
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkout berhasil! Data check-in dihapus.')));
      } catch (e) {
        print("Error during checkout: $e");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terjadi kesalahan saat checkout')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white), // Set warna ikon back menjadi putih
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16.0),
        child: checkInDataList != null 
          ? checkInDataList!.isNotEmpty // Memeriksa apakah data tidak kosong
            ? ListView.builder(
                itemCount: checkInDataList!.length,
                itemBuilder: (context, index) {
                  final checkInData = checkInDataList![index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.person, color: Colors.blueAccent), // Ikon untuk pemesan
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${checkInData['nama']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    Icon(Icons.perm_identity, color: Colors.blueAccent, size: 14), // Ikon untuk NIK
                                    const SizedBox(width: 5),
                                    Text('NIK: ${checkInData['nik']}', style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.room, color: Colors.blueAccent, size: 14), // Ikon untuk No Kamar
                                    const SizedBox(width: 5),
                                    Text('No Kamar: ${checkInData['noKamar']}', style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.hotel, color: Colors.blueAccent, size: 14), // Ikon untuk Tipe Kamar
                                    const SizedBox(width: 5),
                                    Text('${checkInData['kamar']}', style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.people, color: Colors.blueAccent, size: 14), // Ikon untuk Jumlah Kamar
                                    const SizedBox(width: 5),
                                    Text('Jumlah Kamar: ${checkInData['jumlahKamar']}', style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _checkout(checkInData),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Checkout', style: TextStyle(fontSize: 14 , color:  Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ) 
            : const Center(child: Text('Checkin tidak ditemukan')) // Tampilkan pesan jika tidak ada data
          : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class RoomListComponent extends StatefulWidget {
  const RoomListComponent({super.key});

  @override
  _RoomListComponentState createState() => _RoomListComponentState();
}

class _RoomListComponentState extends State<RoomListComponent> {
  List<String> roomNames = []; // Daftar nama kamar
  List<int> roomCounts = []; // Daftar jumlah kamar
  List<String> roomStatuses = []; // Daftar status kamar

  @override
  void initState() {
    super.initState();
    _loadRooms(); // Memuat data kamar
  }

  // Memuat data kamar dari Firestore
  Future<void> _loadRooms() async {
    final snapshot = await FirebaseFirestore.instance.collection('kamar').get();
    for (var doc in snapshot.docs) {
      roomNames.add(doc['nama']);
      roomCounts.add(doc['jumlah']);
      roomStatuses.add(roomCounts.last > 0 ? 'Tersedia' : 'Tidak Tersedia');
    }
    setState(() {}); // Memperbarui UI setelah data dimuat
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hotel, color: Colors.blueAccent),
              const SizedBox(width: 10),
              const Text(
                'Tersedia',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          roomNames.isEmpty // Menampilkan loading jika data belum ada
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  height: 180, // Atur tinggi yang sesuai
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal, // Scroll horizontal
                    itemCount: roomNames.length,
                    itemBuilder: (context, index) {
                      final roomName = roomNames[index]; // Nama kamar
                      final roomCount = roomCounts[index]; // Jumlah kamar
                      final roomStatus = roomStatuses[index]; // Status kamar
                      
                      // Daftar URL gambar
                      final List<String> imageUrls = [
                        'https://blog.bookingtogo.com/wp-content/uploads/2021/12/jenis-jenis-kamar-hotel.jpg',
                        'https://nusadayaacademy.com/wp-content/uploads/2023/08/Kamar-Hotel.jpg',
                        'https://mosaicart.id/wp-content/uploads/2020/10/Ciptakan-Kamar-Tidur-Mewah-Ala-Hotel-Berbintang-Panel-Dinding-Interior-Mosaicart.jpg',
                      ];

                      // Mengambil gambar secara acak
                      final randomImageUrl = imageUrls[Random().nextInt(imageUrls.length)];

                      return Container(
                        margin: const EdgeInsets.only(right: 10), // Spasi antara item
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12), // Sudut membulat
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black87, // Transparansi hitam lebih gelap
                              blurRadius: 2.0, // Jarak bayangan lebih jauh
                              spreadRadius: 2.0, // Jarak bayangan lebih luas
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              // Gambar kamar
                              Image.network(
                                randomImageUrl, // Menggunakan gambar acak
                                width: 250, // Atur lebar gambar
                                height: 200, // Atur tinggi gambar
                                fit: BoxFit.cover, // Sesuaikan gambar
                              ),
                              // Overlay dengan informasi kamar
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.black54, // Transparansi hitam lebih gelap
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                              // Informasi kamar
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text dengan pengaturan overflow dan softWrap
                                    Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 250, // Atur lebar maksimum
                                      ),
                                      child: Text(
                                        roomName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        softWrap: true, // Membungkus teks
                                        overflow: TextOverflow.visible, // Mengizinkan overflow
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      roomStatus,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Jumlah: $roomCount', // Menampilkan jumlah kamar
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

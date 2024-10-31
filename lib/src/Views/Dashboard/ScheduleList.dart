import 'package:flutter/material.dart';

class ScheduleListComponent extends StatelessWidget {
  const ScheduleListComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Jadwal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Menggunakan ListView untuk menampilkan jadwal secara horizontal
            SizedBox(
              height: 100, // Atur tinggi yang sesuai
              child: ListView(
                scrollDirection: Axis.horizontal, // Scroll horizontal
                children: _buildScheduleList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildScheduleList() {
    // Contoh data jadwal
    final List<Map<String, String>> schedule = [
      {'title': 'Jadwal 1', 'time': 'Check In - 10:00 AM'},
      {'title': 'Jadwal 2', 'time': 'Check Out - 12:00 PM'},
      {'title': 'Jadwal 3', 'time': 'Pertemuan - 2:00 PM'},
      {'title': 'Jadwal 4', 'time': 'Sarapan - 7:00 AM'},
    ];

    return schedule.map((item) {
      return Container(
        margin: const EdgeInsets.only(right: 10), // Spasi antara item
        decoration: BoxDecoration(
          color: Colors.blueAccent, // Warna latar belakang
          borderRadius: BorderRadius.circular(8), // Sudut membulat
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item['title']!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              item['time']!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

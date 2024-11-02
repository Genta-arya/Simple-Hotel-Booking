import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/Views/CheckIn/CheckinForm.dart';
import 'package:flutter_application_1/src/Views/Dashboard/ScheduleList.dart';
import 'package:flutter_application_1/src/Views/Kamar/Kamar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  // Mengambil email pengguna dari SharedPreferences
  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('userEmail');
    });
  }

  // Fungsi untuk logout
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail'); // Menghapus email pengguna
    // firebase juga logout hapus sesi difirebase
    // await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login'); // Navigasi ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        titleTextStyle: const TextStyle(color: Colors.white), // Warna judul
        toolbarHeight: 40, // Ukuran tulisan title
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // Warna background
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout, // Panggil fungsi logout saat ditekan
          ),
        ],
      ),
      body: Container(
        height: double.infinity, // Memastikan container mengisi seluruh tinggi layar
        padding: const EdgeInsets.all(16.0), // Padding di sekeliling
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
          children: [
            // Menampilkan email pengguna jika ada
            if (_userEmail != null)
              Text(
                'Logged in as: $_userEmail',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            const SizedBox(height: 4), // Spasi antara email dan header
            const Text(
              'Welcome Hotel K,one',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16), // Spasi antara header dan grid
            const MenuComponent(), // Memanggil komponen menu
            const SizedBox(height: 16), // Spasi antara menu dan jadwal
            const ScheduleListComponent(), // Memanggil komponen daftar jadwal
          ],
        ),
      ),
    );
  }
}

// Komponen Menu tetap sama seperti sebelumnya
class MenuComponent extends StatelessWidget {
  const MenuComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue, // Warna background Card
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding di dalam Card
        child: GridView.count(
          crossAxisCount: 2, // Jumlah kolom
          childAspectRatio: 1.5, // Rasio tinggi dan lebar kartu
          physics: const NeverScrollableScrollPhysics(), // Nonaktifkan scroll
          shrinkWrap: true, // Ukuran grid disesuaikan dengan isi
          children: [
            _buildCard(
              context,
              title: 'Check In',
              icon: Icons.check_circle,
              onTap: () {
                // Tindakan ketika kartu Check In ditekan
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CheckInForm()),
                );
              },
            ),
            _buildCard(
              context,
              title: 'Check Out',
              icon: Icons.check_circle_outline,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Check Out Dipilih')),
                );
              },
            ),
            _buildCard(
              context,
              title: 'Laporan',
              icon: Icons.receipt,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Laporan Dipilih')),
                );
              },
            ),
            _buildCard(
              context,
              title: 'Kamar',
              icon: Icons.room_service,
              onTap: () {
                // navigate
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KamarScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Mengatur ukuran column agar fit
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50, // Ukuran ikon
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center, // Rata tengah
            ),
          ],
        ),
      ),
    );
  }
}

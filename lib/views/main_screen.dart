import 'package:flutter/material.dart';
import 'gudang_page.dart';
import 'penjualan_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [Penjualan(), Gudang()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Penjualan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Gudang',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 75.0,
        width: 75.0,
        child: FloatingActionButton(
          heroTag: 'qr_code',
          onPressed: () {},
          child: Icon(
            Icons.qr_code,
            color: Colors.white,
            size: 40,
          ),
          backgroundColor: Colors.blue,
          shape: CircleBorder(),
        ),
      ),
    );
  }
}

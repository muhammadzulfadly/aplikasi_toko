import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'gudang_page.dart';
import 'penjualan_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? scannedBarcode;

  final List<Widget> _pages = [
    Penjualan(),
    Gudang(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      scannedBarcode = null;
    });
  }

  void _onBarcodeScanned(String barcode) {
    setState(() {
      _selectedIndex = 0;
      scannedBarcode = barcode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? Penjualan(barcode: scannedBarcode)
          : _pages[_selectedIndex],
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
        onTap: _onItemTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 75.0,
        width: 75.0,
        child: FloatingActionButton(
          heroTag: 'qr_code',
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SimpleBarcodeScannerPage()),
            );
            if (result != null) {
              _onBarcodeScanned(result);
            }
          },
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

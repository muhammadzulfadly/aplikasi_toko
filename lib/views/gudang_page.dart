import 'package:flutter/material.dart';
import 'package:aplikasi_toko/views/edit_page.dart';
import 'package:aplikasi_toko/views/tambah_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Gudang extends StatefulWidget {
  @override
  _GudangState createState() => _GudangState();
}

class _GudangState extends State<Gudang> {
  List produkList = [];
  List filteredProdukList = [];
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    final response = await http.get(
        Uri.parse('http://192.168.1.19/aplikasi_toko/lib/api/view_data.php'));

    if (response.statusCode == 200) {
      setState(() {
        produkList = json.decode(response.body);
        filteredProdukList = produkList;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void searchProduk(String query) {
    final results = produkList.where((produk) {
      final namaLower = produk['nama_barang'].toLowerCase();
      final queryLower = query.toLowerCase();

      return namaLower.contains(queryLower);
    }).toList();

    setState(() {
      filteredProdukList = results;
      isSearching = query.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                child: TextField(
                  controller: searchController,
                  onChanged: (query) {
                    searchProduk(query);
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari Barang',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: filteredProdukList.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredProdukList.length,
                      itemBuilder: (context, index) {
                        final produk = filteredProdukList[index];
                        return InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditProduk(id: int.parse(produk['id'])),
                              ),
                            );
                            if (result == true) {
                              fetchProduk();
                            }
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    produk['nama_barang'],
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Rp. ${produk['harga_eceran']}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                      'HARGA GROSIR : RP. ${produk['harga_grosir']}'),
                                  SizedBox(height: 5),
                                  Text('STOK : ${produk['stok_barang']}'),
                                  SizedBox(height: 5),
                                  Align(
                                    alignment: Alignment.centerRight,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        height: 60.0,
        width: 60.0,
        child: FloatingActionButton(
          heroTag: 'tambah',
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TambahProduk()),
            );
            if (result == true) {
              fetchProduk();
            }
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
          backgroundColor: Colors.blue,
          shape: CircleBorder(),
        ),
      ),
    );
  }
}

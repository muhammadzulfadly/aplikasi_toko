import 'package:aplikasi_toko/views/keranjang_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoriPenjualan extends StatefulWidget {
  @override
  _HistoriPenjualanState createState() => _HistoriPenjualanState();
}

class _HistoriPenjualanState extends State<HistoriPenjualan> {
  Map<String, List<Map<String, dynamic>>> historiMap = {};
  late Box keranjangBox;

  @override
  void initState() {
    super.initState();
    keranjangBox = Hive.box('keranjang');
    fetchHistori();
  }

  Future<void> fetchHistori() async {
    try {
      final response = await http.get(
          Uri.parse('http://shop.mzverse.my.id/api/histori_penjualan.php'));

      if (response.statusCode == 200) {
        List data = json.decode(response.body);

        data.forEach((item) {
          String transaksiId = item['transaksi_id'].toString();
          if (historiMap.containsKey(transaksiId)) {
            historiMap[transaksiId]?.add({
              'transaksi_id': item['transaksi_id'].toString(),
              'produk_id': item['produk_id'].toString(),
              'nama_barang': item['nama_barang'],
              'harga_jual': item['harga_jual'].toString(),
              'jumlah': item['jumlah'].toString(),
              'total_harga': item['total_harga'].toString(),
              'tanggal_penjualan': item['tanggal_penjualan'],
            });
          } else {
            historiMap[transaksiId] = [
              {
                'transaksi_id': item['transaksi_id'].toString(),
                'produk_id': item['produk_id'].toString(),
                'nama_barang': item['nama_barang'],
                'harga_jual': item['harga_jual'].toString(),
                'jumlah': item['jumlah'].toString(),
                'total_harga': item['total_harga'].toString(),
                'tanggal_penjualan': item['tanggal_penjualan'],
              }
            ];
          }
        });

        setState(() {});
      } else {
        print("Failed to fetch data");
      }
    } catch (e) {
      print("Error fetching histori: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchProdukDetails(String produkId) async {
    try {
      final url = Uri.parse('http://shop.mzverse.my.id/api/view_data.php');
      final response = await http.post(url, body: {'id': produkId});

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        print("Failed to fetch produk details");
        return [];
      }
    } catch (e) {
      print("Error fetching produk details: $e");
      return [];
    }
  }

  Future<void> deleteHistoriPenjualan(String transaksiId) async {
    final String apiUrl =
        "http://shop.mzverse.my.id/api/delete_histori_penjualan.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'transaksi_id': transaksiId,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          Navigator.pop(context, true);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Keranjang()),
          );
        } else {
          print(
              "Failed to delete histori penjualan: ${responseData['message']}");
        }
      } else {
        print("Failed to delete histori penjualan");
      }
    } catch (e) {
      print("Error deleting histori penjualan: $e");
    }
  }

  Future<void> restoreStokProduk(
      String produkId, String jumlah, String hargaJual) async {
    final String apiUrl =
        "http://shop.mzverse.my.id/api/restore_stok_produk.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'produk_id': produkId,
          'jumlah': jumlah,
          'harga_jual': hargaJual,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print('Stok berhasil dikembalikan');
        } else {
          String errorMessage =
              responseData['message'] ?? "Tidak ada pesan kesalahan";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal mengembalikan stok produk: $errorMessage"),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengembalikan stok produk"),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error restoring stok produk: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengembalikan stok produk"),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> showConfirmationDialog(
      BuildContext context, List<Map<String, dynamic>> historiList) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text(
            'Edit Data',
            style: TextStyle(color: Colors.blue),
          )),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Tindakan ini akan menghapus data yang sudah dijual'),
              ],
            ),
          ),
          actions: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              ElevatedButton(
                child: Text(
                  'Batal',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text('Edit', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  String transaksiId = historiList[0]['transaksi_id'];
                  Navigator.of(context).pop();

                  // Restore product stock
                  for (var item in historiList) {
                    await restoreStokProduk(
                        item['produk_id'], item['jumlah'], item['harga_jual']);
                  }

                  // Masukkan semua produk dalam transaksi_id tersebut ke dalam keranjang
                  for (var item in historiList) {
                    String produkId = item['produk_id'];
                    String jumlah = item['jumlah'];
                    List<Map<String, dynamic>> produkDetails =
                        await fetchProdukDetails(produkId);

                    if (produkDetails.isNotEmpty) {
                      var produk = produkDetails[0];
                      produk['jumlah'] =
                          jumlah; // Set jumlah dari histori penjualan
                      keranjangBox.put(produkId, produk);
                    }
                  }

                  // Delete the data from the database
                  await deleteHistoriPenjualan(transaksiId);
                },
              ),
            ])
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.blue,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Histori Penjualan',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: historiMap.isEmpty
          ? Center(child: Text('Tidak ada penjualan'))
          : ListView.builder(
              itemCount: historiMap.length,
              itemBuilder: (context, index) {
                String transaksiId = historiMap.keys.elementAt(index);
                List<Map<String, dynamic>>? historiList =
                    historiMap[transaksiId];

                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          historiList![0]['tanggal_penjualan'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit_square),
                          color: Colors.blue,
                          onPressed: () {
                            showConfirmationDialog(context, historiList);
                          },
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: historiList.length,
                        itemBuilder: (context, idx) {
                          final histori = historiList[idx];
                          return ListTile(
                            title: Text(histori['nama_barang']),
                            trailing: Text(
                                '${histori['jumlah']} x Rp. ${histori['harga_jual']}'),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

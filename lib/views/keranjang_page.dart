import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Keranjang extends StatefulWidget {
  @override
  _KeranjangState createState() => _KeranjangState();
}

class _KeranjangState extends State<Keranjang> {
  late Box keranjangBox;
  List<Map<String, dynamic>> keranjangList = [];
  int totalHarga = 0;
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  List<TextEditingController> controllers = [];

  @override
  void initState() {
    super.initState();
    keranjangBox = Hive.box('keranjang');
    fetchKeranjang();
  }

  Future<void> fetchKeranjang() async {
    final data = keranjangBox.values.toList();
    setState(() {
      keranjangList =
          data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      controllers = List.generate(keranjangList.length, (index) {
        return TextEditingController(text: keranjangList[index]['jumlah']);
      });
      hitungTotal();
    });
  }

  void hitungTotal() {
    int totalHargaBarang = 0;
    for (var produk in keranjangList) {
      totalHargaBarang +=
          int.parse(produk['harga_eceran']) * int.parse(produk['jumlah']);
    }
    setState(() {
      totalHarga = totalHargaBarang;
    });
  }

  Future<void> deleteProduk(int index) async {
    await keranjangBox.deleteAt(index);
    fetchKeranjang();
  }

  Future<void> jualBarang() async {
    bool success = true;
    for (var produk in keranjangList) {
      if (produk['id'] == null) {
        print("Produk tidak memiliki ID: $produk");
        continue;
      }

      String stok = produk['stok_barang'] ?? '0';
      String jumlah = produk['jumlah'] ?? '0';
      int currentStok = int.parse(stok);
      int jumlahJual = int.parse(jumlah);
      int newStok = currentStok - jumlahJual;

      if (newStok < 0) {
        print("Stok tidak cukup untuk produk: ${produk['nama_barang']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Stok tidak cukup untuk ${produk['nama_barang']}"),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
            backgroundColor: Colors.red,
          ),
        );
        continue;
      }

      print("ID: ${produk['id']}, New Stok: $newStok");

      var response = await http.post(
        Uri.parse('http://shop.mzverse.my.id/api/stok_data.php'),
        body: {
          'id': produk['id'].toString(),
          'stok_barang': newStok.toString(),
          'jumlah': jumlahJual.toString(),
        },
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      if (response.statusCode == 200) {
        try {
          var responseData = json.decode(response.body);
          print("Response from API: $responseData");

          if (responseData['success'] != 'true') {
            success = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Gagal menjual ${produk['nama_barang']}"),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
                backgroundColor: Colors.red,
              ),
            );
            break; // Stop the process if any product fails to be sold
          }
        } catch (e) {
          success = false;
          print("Error parsing JSON: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Gagal menjual ${produk['nama_barang']}, error parsing JSON"),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
              backgroundColor: Colors.red,
            ),
          );
          break;
        }
      } else {
        success = false;
        print("Server error: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Gagal menjual ${produk['nama_barang']}, server error"),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
            backgroundColor: Colors.red,
          ),
        );
        break; // Stop the process if any product fails to be sold
      }
    }
    if (success) {
      await keranjangBox.clear();
      fetchKeranjang();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Berhasil"),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
          backgroundColor: Colors.green,
        ),
      );
      _showPrintDialog();
    }
  }

  void _showPrintDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Print Struk"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<BluetoothDevice>(
                hint: Text('Pilih perangkat'),
                value: _selectedDevice,
                onChanged: (BluetoothDevice? value) {
                  setState(() {
                    _selectedDevice = value;
                  });
                },
                items: _devices.map((BluetoothDevice device) {
                  return DropdownMenuItem<BluetoothDevice>(
                    value: device,
                    child: Text(device.name!),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text("Home", style: TextStyle(color: Colors.blue)),
                  ),
                  ElevatedButton(
                    onPressed: _selectedDevice == null ? null : _printStruk,
                    child: Text(
                      "Print",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _printStruk() async {
    if (_selectedDevice != null) {
      await bluetooth.connect(_selectedDevice!);
      bluetooth.printCustom("Daftar Barang Terjual", 3, 1);
      for (var produk in keranjangList) {
        bluetooth.printNewLine();
        bluetooth.printLeftRight("${produk['nama_barang']}",
            "${produk['jumlah']} x ${produk['harga_eceran']}", 1);
      }
      bluetooth.printNewLine();
      bluetooth.printCustom("Total: $totalHarga", 2, 1);
      bluetooth.printNewLine();
      bluetooth.paperCut();
      await bluetooth.disconnect();
    }
    Navigator.of(context).pop();
  }

  Future<void> addToKeranjang(Map<String, dynamic> produk) async {
    if (produk['id'] == null) {
      print("Produk tidak memiliki ID: $produk");
      return; // Skip adding product if ID is null
    }

    produk['jumlah'] = '1';
    await keranjangBox.add(produk);
    fetchKeranjang();
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
          'Keranjang',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: keranjangList.isEmpty
            ? Center(child: Text("Keranjang kosong"))
            : ListView.builder(
                itemCount: keranjangList.length,
                itemBuilder: (context, index) {
                  final produk = keranjangList[index];
                  final controller = controllers[index];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                produk['nama_barang'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  deleteProduk(index);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            'RP. ${produk['harga_eceran']}',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    int currentValue =
                                        int.parse(controller.text);
                                    if (currentValue > 1) {
                                      currentValue--;
                                      controller.text = currentValue.toString();
                                      produk['jumlah'] =
                                          currentValue.toString();
                                      keranjangBox.putAt(index, produk);
                                      hitungTotal();
                                    }
                                  });
                                },
                                icon: Icon(Icons.remove),
                                color: Colors.blue,
                              ),
                              Container(
                                width: 50,
                                child: TextField(
                                  controller: controller,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 5),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value.isEmpty) {
                                        produk['jumlah'] = '0';
                                      } else {
                                        int newValue = int.parse(value);
                                        if (newValue < 1) {
                                          produk['jumlah'] = '1';
                                        } else {
                                          produk['jumlah'] =
                                              newValue.toString();
                                        }
                                      }
                                      keranjangBox.putAt(index, produk);
                                      hitungTotal();
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    int currentValue =
                                        int.parse(controller.text);
                                    currentValue++;
                                    controller.text = currentValue.toString();
                                    produk['jumlah'] = currentValue.toString();
                                    keranjangBox.putAt(index, produk);
                                    hitungTotal();
                                  });
                                },
                                icon: Icon(Icons.add),
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      'Rp. ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      '$totalHarga',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (keranjangList.isNotEmpty) {
                    jualBarang();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Keranjang kosong"),
                        duration: Duration(seconds: 1),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  minimumSize: Size(150, 50), // Button size
                ),
                child: Text(
                  'JUAL',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}

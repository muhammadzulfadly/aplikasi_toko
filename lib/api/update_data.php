<?php

include("dbconnection.php");
$con = dbconnection();

if (isset($_POST['id'])) {
    $id = $_POST['id'];
    $nama_barang = $_POST['nama_barang'] ?? null;
    $barcode_barang = $_POST['barcode_barang'] ?? null;
    $stok_barang = $_POST['stok_barang'] ?? null;
    $harga_modal = $_POST['harga_modal'] ?? null;
    $harga_eceran = $_POST['harga_eceran'] ?? null;
    $harga_grosir = $_POST['harga_grosir'] ?? null;
    $satuan_barang = $_POST['satuan_barang'] ?? null;
    $stok_besar_barang = $_POST['stok_besar_barang'] ?? null;
    $jumlah_isi_barang = $_POST['jumlah_isi_barang'] ?? null;
    $harga_eceran_besar = $_POST['harga_eceran_besar'] ?? null;
    $satuan_besar_barang = $_POST['satuan_besar_barang'] ?? null;

    $query = "UPDATE produks SET 
                nama_barang = IFNULL('$nama_barang', nama_barang), 
                barcode_barang = IFNULL('$barcode_barang', barcode_barang), 
                stok_barang = IFNULL('$stok_barang', stok_barang), 
                harga_modal = IFNULL('$harga_modal', harga_modal), 
                harga_eceran = IFNULL('$harga_eceran', harga_eceran), 
                harga_grosir = IFNULL('$harga_grosir', harga_grosir),
                satuan_barang = IFNULL('$satuan_barang', satuan_barang),
                stok_besar_barang = IFNULL('$stok_besar_barang', stok_besar_barang),
                jumlah_isi_barang = IFNULL('$jumlah_isi_barang', jumlah_isi_barang),
                harga_eceran_besar = IFNULL('$harga_eceran_besar', harga_eceran_besar),
                satuan_besar_barang = IFNULL('$satuan_besar_barang', satuan_besar_barang),
                updated_at = NOW() 
              WHERE id = '$id'";

    $exe = mysqli_query($con, $query);

    if ($exe) {
        $response = ['success' => 'true'];
    } else {
        $response = ['success' => 'false', 'message' => mysqli_error($con)];
    }

    print(json_encode($response));
} else {
    $response = ['success' => 'false', 'message' => 'ID is required'];
    print(json_encode($response));
}

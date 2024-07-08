<?php

include("dbconnection.php");
$con = dbconnection();

if (isset($_POST['id'])) {
    $id = $_POST['id'];
    $query = "SELECT id, nama_barang, barcode_barang, stok_barang, harga_modal, harga_eceran, harga_grosir, satuan_barang, stok_besar_barang, jumlah_isi_barang, harga_eceran_besar, satuan_besar_barang, created_at, updated_at FROM produks WHERE id = '$id'";
    $exe = mysqli_query($con, $query);

    $arr = [];
    while ($row = mysqli_fetch_assoc($exe)) {
        $arr[] = $row;
    }

    print(json_encode($arr));
} else {
    $query = "SELECT id, nama_barang, barcode_barang, stok_barang, harga_modal, harga_eceran, harga_grosir, satuan_barang, stok_besar_barang, jumlah_isi_barang, harga_eceran_besar, satuan_besar_barang, created_at, updated_at FROM produks";
    $exe = mysqli_query($con, $query);

    $arr = [];
    while ($row = mysqli_fetch_assoc($exe)) {
        $arr[] = $row;
    }

    print(json_encode($arr));
}

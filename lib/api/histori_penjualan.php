<?php
include("dbconnection.php");
$con = dbconnection();

header('Content-Type: application/json');

$query = "SELECT * FROM histori_penjualan ORDER BY tanggal_penjualan DESC";
$result = mysqli_query($con, $query);

$historiList = array();
while ($row = mysqli_fetch_assoc($result)) {
    // Konversi tipe data di sini jika diperlukan
    $row['transaksi_id'] = (int) $row['transaksi_id'];
    $row['produk_id'] = (int) $row['produk_id'];
    $row['harga_jual'] = (float) $row['harga_jual'];
    $row['jumlah'] = (float) $row['jumlah'];
    $row['total_harga'] = (float) $row['total_harga'];
    if ($row['user_id'] != null) {
        $row['user_id'] = (int) $row['user_id'];
    }

    $historiList[] = $row;
}

echo json_encode($historiList);

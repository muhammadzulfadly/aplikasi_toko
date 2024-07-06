<?php
include("dbconnection.php");
$con = dbconnection();

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $id = $_POST['id'];
    $stok_barang = $_POST['stok_barang'];
    $jumlah = $_POST['jumlah'];

    // Debugging output
    error_log("ID: $id, Stok: $stok_barang, Jumlah: $jumlah");

    if (!$con) {
        error_log("Koneksi ke database gagal: " . mysqli_connect_error());
        echo json_encode(array('success' => 'false', 'error' => 'Koneksi ke database gagal'));
        exit;
    }

    // Query untuk mengupdate stok
    $query = "UPDATE produks SET stok_barang = '$stok_barang' WHERE id = '$id'";
    error_log("Query: $query");

    $result = mysqli_query($con, $query);

    if ($result) {
        if (mysqli_affected_rows($con) > 0) {
            // Menambahkan histori penjualan
            $produk_query = "SELECT * FROM produks WHERE id = '$id'";
            $produk_result = mysqli_query($con, $produk_query);
            $produk = mysqli_fetch_assoc($produk_result);

            $nama_barang = $produk['nama_barang'];
            $harga_jual = $produk['harga_eceran'];
            $total_harga = $harga_jual * $jumlah;

            $histori_query = "INSERT INTO histori_penjualan (produk_id, nama_barang, harga_jual, jumlah, total_harga) 
                              VALUES ('$id', '$nama_barang', '$harga_jual', '$jumlah', '$total_harga')";
            mysqli_query($con, $histori_query);

            echo json_encode(array('success' => 'true'));
        } else {
            error_log("Query berhasil, tetapi tidak ada baris yang diupdate.");
            echo json_encode(array('success' => 'false', 'error' => 'Tidak ada baris yang diupdate'));
        }
    } else {
        $error_message = mysqli_error($con);
        error_log("Query Error: " . $error_message);
        echo json_encode(array('success' => 'false', 'error' => $error_message));
    }
} else {
    echo json_encode(array('success' => 'false', 'message' => 'Invalid request method'));
}

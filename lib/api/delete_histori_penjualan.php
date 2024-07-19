<?php
include("dbconnection.php");
$con = dbconnection();

// Check if transaksi_id is set and not empty
if (isset($_POST['transaksi_id']) && !empty($_POST['transaksi_id'])) {
    $transaksiId = $_POST['transaksi_id'];

    $query = "DELETE FROM histori_penjualan WHERE transaksi_id = $transaksiId";

    if (mysqli_query($con, $query)) {
        echo json_encode(array('success' => true));
    } else {
        echo json_encode(array('success' => false, 'message' => 'Gagal menghapus data dari database'));
    }
} else {
    echo json_encode(array('success' => false, 'message' => 'Transaksi ID tidak valid'));
}

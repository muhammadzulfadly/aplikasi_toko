<?php

include("dbconnection.php");
$con = dbconnection();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['id']) && isset($_POST['stok_barang'])) {
        $id = $_POST['id'];
        $stok_barang = $_POST['stok_barang'];

        $query = "UPDATE produks SET 
                    stok_barang = '$stok_barang', 
                    updated_at = NOW() 
                  WHERE id = '$id'";

        $exe = mysqli_query($con, $query);

        if ($exe) {
            $response = ['success' => 'true'];
        } else {
            $response = ['success' => 'false', 'message' => mysqli_error($con)];
        }
    } else {
        $response = ['success' => 'false', 'message' => 'Missing parameters'];
    }
} else {
    $response = ['success' => 'false', 'message' => 'Invalid request method'];
}

echo json_encode($response);

<?php

include("dbconnection.php");
$con = dbconnection();

if (isset($_POST['id'])) {
    $id = $_POST['id'];

    $query = "DELETE FROM produks WHERE id = '$id'";
    $exe = mysqli_query($con, $query);

    if ($exe) {
        $response = ['success' => 'true'];
    } else {
        $response = ['success' => 'false', 'message' => mysqli_error($con)];
    }
} else {
    $response = ['success' => 'false', 'message' => 'ID not provided'];
}

print(json_encode($response));

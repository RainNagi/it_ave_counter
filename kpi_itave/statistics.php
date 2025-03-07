<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'db_config.php';

$year = $_GET['year'] ?? date('Y'); 
$month = $_GET['month'] ?? date('m');

$sql = "SELECT button_name, COUNT(button_name) as occurrences FROM counter WHERE timestamp LIKE '$year-$month%' GROUP BY button_name;";
$result = $conn->query($sql);

$data = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = ["button_name" => $row["button_name"], "occurrences" => (int)$row["occurrences"]];
    }
}

echo json_encode($data);
?>

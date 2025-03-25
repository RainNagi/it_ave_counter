<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'db_config.php';

ini_set('display_errors', 1);
error_reporting(E_ALL);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$button_id = $_POST['button_id'] ?? '';

if (!empty($button_id)) {
    $stmt = $conn->prepare("INSERT INTO counter (button_id) VALUES (?)");
    
    if ($stmt === false) {
        die("Error preparing the statement: " . $conn->error);
    }

    $stmt->bind_param("s", $button_id);

    if ($stmt->execute()) {
        echo "Button click recorded successfully.";
    } else {
        echo "Error recording button click: " . $stmt->error;
    }

    $stmt->close();
}

$query = "SELECT b.button_name, COUNT(c.button_id) AS count FROM buttons AS b LEFT JOIN counter AS c ON b.button_id = c.button_id WHERE DATE(timestamp) = CURDATE() GROUP BY b.button_name;";

$result = $conn->query($query);

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[$row['button_name']] = $row['count'];
}

echo json_encode($data);

$conn->close();
?>

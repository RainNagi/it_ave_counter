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

$buttonType = $_POST['buttonType'] ?? '';

if (!empty($buttonType)) {
    $stmt = $conn->prepare("INSERT INTO counter (button_name) VALUES (?)");

    if ($stmt === false) {
        die("Error preparing the statement: " . $conn->error);
    }

    $stmt->bind_param("s", $buttonType);

    if ($stmt->execute()) {
        echo "Button click recorded successfully.";
    } else {
        echo "Error recording button click: " . $stmt->error;
    }

    $stmt->close();
} else {
    echo "No button type received.";
}

$conn->close();
?>

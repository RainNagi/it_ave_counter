<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'db_config.php';

if (isset($_GET['action'])) {
    $action = $_GET['action'];

    if ($action == "getYears") {
        $sql = "SELECT DISTINCT YEAR(timestamp) AS year FROM counter ORDER BY year DESC";
        $result = $conn->query($sql);

        $years = [];
        while ($row = $result->fetch_assoc()) {
            $years[] = $row['year'];
        }

        echo json_encode($years);
        exit();
    }

    if ($action == "getMonths" && isset($_GET['year'])) {
        $year = $_GET['year'];
        $sql = "SELECT DISTINCT MONTH(timestamp) AS month FROM counter WHERE YEAR(timestamp) = '$year' ORDER BY month ASC";
        $result = $conn->query($sql);

        $months = [];
        while ($row = $result->fetch_assoc()) {
            $months[] = str_pad($row['month'], 2, "0", STR_PAD_LEFT); // Ensure format "01", "02", etc.
        }

        echo json_encode($months);
        exit();
    }
    if ($action == "getWeekdays" && isset($_GET['department'])) {
        $department = $_GET['department'];
        $sql = "SELECT DAYNAME(timestamp) AS weekday, COUNT(*) as occurrences 
                FROM counter 
                WHERE button_name = '$department' 
                GROUP BY weekday ";
    
        $result = $conn->query($sql);
        $weekdays = [];
        while ($row = $result->fetch_assoc()) {
            $weekdays[] = ["weekday" => $row["weekday"], "occurrences" => (int)$row["occurrences"]];
        }
    
        echo json_encode($weekdays);
        exit();
    }
    
}

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

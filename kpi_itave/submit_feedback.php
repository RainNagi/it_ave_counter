<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

include 'db_config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $department_id = $_POST['department_id'] ?? null;
    $responses = isset($_POST['responses']) ? json_decode($_POST['responses'], true) : [];

    if (!$department_id || empty($responses)) {
        echo json_encode(["status" => "error", "message" => "Missing required fields"]);
        exit;
    }

    $conn->begin_transaction();
    try {
        // Get the last customer_id and increment it
        $query = "SELECT MAX(customer_id) AS last_id FROM feedback_responses";
        $result = $conn->query($query);
        $row = $result->fetch_assoc();
        $customer_id = $row['last_id'] ? $row['last_id'] + 1 : 1;

        // Generate customer name if not provided
        $customer_name = isset($_POST['customer_name']) && !empty($_POST['customer_name']) 
            ? $_POST['customer_name'] 
            : "Customer" . $customer_id;

        // Insert feedback responses
        $stmt = $conn->prepare("INSERT INTO feedback_responses (customer_name, customer_id, department_id, question_id, rating) VALUES (?, ?, ?, ?, ?)");

        foreach ($responses as $response) {
            $question_id = $response['question_id'];
            $rating = $response['rating'];

            $stmt->bind_param("siidd", $customer_name, $customer_id, $department_id, $question_id, $rating);
            $stmt->execute();
        }

        $conn->commit();
        echo json_encode(["status" => "success", "message" => "Feedback submitted", "customer_id" => $customer_id]);
    } catch (Exception $e) {
        $conn->rollback();
        echo json_encode(["status" => "error", "message" => "Failed to submit feedback", "error" => $e->getMessage()]);
    }
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
?>

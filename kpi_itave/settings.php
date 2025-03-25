<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

include 'db_config.php';

ini_set('display_errors', 1);
error_reporting(E_ALL);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Determine section from GET or POST
$section = '';
if (isset($_GET['section'])) {
    $section = $_GET['section'];
} elseif (isset($_POST['section'])) {
    $section = $_POST['section'];
}

if ($section === "buttons") {
    // Determine action from GET or POST
    $action = $_GET['action'] ?? ($_POST['action'] ?? '');

    if ($action == "getdepartments") {
        $filter = $_GET['filter'] ?? '';
        $sql = 'SELECT b.*, COUNT(c.button_id) AS counter_count 
                FROM buttons AS b 
                LEFT JOIN counter AS c ON b.button_id = c.button_id AND DATE(c.timestamp) = CURDATE()
                WHERE b.active = true';
        if (!empty($filter)) {
            $sql .= " AND b.button_name LIKE ?";
        }
        $sql .= " GROUP BY b.button_name ORDER BY button_id;";

        $stmt = $conn->prepare($sql);
        if (!empty($filter)) {
            $searchTerm = "%$filter%";
            $stmt->bind_param("s", $searchTerm);
        }
        $stmt->execute();
        $result = $stmt->get_result();
        $departments = [];
        while ($row = $result->fetch_assoc()) {
            $departments[] = $row;
        }
        echo json_encode($departments);
        exit;
    }

    if ($action == "archiveDepartment") {
        $departmentId = $_POST['departmentId'] ?? '';
        if (!empty($departmentId)) {
            $sql = "UPDATE buttons SET active = false WHERE button_id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("i", $departmentId);
            if ($stmt->execute()) {
                echo json_encode(["message" => "Department archived successfully."]);
            } else {
                echo json_encode(["error" => "Failed to archive department."]);
            }
            $stmt->close();
            exit;
        }
    }
    if ($action == "addDepartment") {

        $button_name = $_POST['button_name'];
        $button_icon = $_POST['button_icon'];

        if (!empty($button_name) && !empty($button_icon)) {
            // Check if the button already exists
            $checkQuery = $conn->prepare("SELECT * FROM buttons WHERE button_name = ?");
            $checkQuery->bind_param("s", $button_name);
            $checkQuery->execute();
            $result = $checkQuery->get_result();

            if ($result->num_rows > 0) {
                echo json_encode(["status" => "error", "message" => "Button already exists"]);
            } else {
                // Insert new department button
                $insertQuery = $conn->prepare("INSERT INTO buttons (button_name, button_icon, active) VALUES (?, ?, true)");
                $insertQuery->bind_param("ss", $button_name, $button_icon);

                if ($insertQuery->execute()) {
                    echo json_encode(["status" => "success", "message" => "Department added successfully"]);
                } else {
                    echo json_encode(["status" => "error", "message" => "Failed to add department"]);
                }
            }
            $checkQuery->close();
            exit;
        } else {
            echo json_encode(["status" => "error", "message" => "Missing required fields"]);
            exit;
        }
    }
    if ($action == "editDepartment") {
        $button_id = $_POST['button_id'];
        $button_name = $_POST['button_name'];
        $button_icon = $_POST['button_icon'];

        if (!empty($button_name) && !empty($button_icon)) {
            // Check if the button already exists
            $checkQuery = $conn->prepare("SELECT * FROM buttons WHERE button_name = ?");
            $checkQuery->bind_param("s", $button_name);
            $checkQuery->execute();
            $result = $checkQuery->get_result();

            if ($result->num_rows > 0) {
                echo json_encode(["status" => "error", "message" => "Button Name already exists"]);
            } else {
                $updateQuery = $conn->prepare("UPDATE buttons SET button_name = ?, button_icon = ? WHERE button_id = ?");
                $updateQuery->bind_param("ssi", $button_name, $button_icon, $button_id);

                if ($updateQuery->execute()) {
                    echo json_encode(["status" => "success", "message" => "Department updated successfully"]);
                } else {
                    echo json_encode(["status" => "error", "message" => "Failed to update department"]);
                }
            }
            $checkQuery->close();
            exit;
        } else {
            echo json_encode(["status" => "error", "message" => "Missing required fields"]);
            exit;
        }
    }
}

if ($section === "questions") {
    $action = $_GET['action'] ?? ($_POST['action'] ?? '');
    if ($action == "getQuestions") {
        $sql = 'SELECT * FROM questions WHERE active = true ORDER BY question_id ASC';
        $stmt = $conn->prepare($sql);
        $stmt->execute();
        $result = $stmt->get_result();
        $questions = [];
        while ($row = $result->fetch_assoc()) {
            $questions[] = $row;
        }
        echo json_encode($questions);
        exit;
    }
    if ($action == "addQuestion") {
        $question = $_POST['question'];

        if (!empty($question)) {
            // Check if the question already exists
            $checkQuery = $conn->prepare("SELECT * FROM questions WHERE question = ?");
            $checkQuery->bind_param("s", $question);
            $checkQuery->execute();
            $result = $checkQuery->get_result();

            if ($result->num_rows > 0) {
                echo json_encode(["status" => "error", "message" => "Question already exists"]);
            } else {
                // Insert new department button
                $insertQuery = $conn->prepare("INSERT INTO questions (question) VALUES (?)");
                $insertQuery->bind_param("s", $question);

                if ($insertQuery->execute()) {
                    echo json_encode(["status" => "success", "message" => "Question added successfully"]);
                } else {
                    echo json_encode(["status" => "error", "message" => "Failed to add question"]);
                }
            }
            $checkQuery->close();
            exit;
        } else {
            echo json_encode(["status" => "error", "message" => "Missing required fields"]);
            exit;
        }
    }
    if ($action == "editQuestion") {
        $question_id = $_POST['question_id'];
        $question = $_POST['question'];

        if (!empty($question)) {
            // Check if the button already exists
            $checkQuery = $conn->prepare("SELECT * FROM questions WHERE question = ?");
            $checkQuery->bind_param("s", $question);
            $checkQuery->execute();
            $result = $checkQuery->get_result();

            if ($result->num_rows > 0) {
                echo json_encode(["status" => "error", "message" => "Question already exists"]);
            } else {
                $updateQuery = $conn->prepare("UPDATE questions SET question = ? WHERE question_id = ?");
                $updateQuery->bind_param("si", $question, $question_id);

                if ($updateQuery->execute()) {
                    echo json_encode(["status" => "success", "message" => "Question updated successfully"]);
                } else {
                    echo json_encode(["status" => "error", "message" => "Failed to update question"]);
                }
            }
            $checkQuery->close();
            exit;
        } else {
            echo json_encode(["status" => "error", "message" => "Missing required fields"]);
            exit;
        }
    }
    if ($action == "archiveQuestion") {
        $questionId = $_POST['questionId'] ?? '';
        if (!empty($questionId)) {
            $sql = "UPDATE questions SET active = false WHERE question_id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("i", $questionId);
            if ($stmt->execute()) {
                echo json_encode(["message" => "Question archived successfully."]);
            } else {
                echo json_encode(["error" => "Failed to archive Question."]);
            }
            $stmt->close();
            exit;
        }
    }
}

echo json_encode(["error" => "Invalid request"]);
$conn->close();

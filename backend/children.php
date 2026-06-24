<?php
require 'db.php';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if (isset($_GET['parent_id'])) {
        $parent_id = (int)$_GET['parent_id'];
        $result = $conn->query("SELECT * FROM children WHERE parent_id = $parent_id");
        $children = [];
        while ($row = $result->fetch_assoc()) {
            $children[] = $row;
        }
        echo json_encode(["status" => "success", "data" => $children]);
    } else {
        echo json_encode(["status" => "error", "message" => "Missing parent_id"]);
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    
    if (isset($data->action) && $data->action === 'delete') {
        if (isset($data->child_id)) {
            $child_id = (int)$data->child_id;
            try {
                $conn->query("DELETE FROM stats WHERE child_id = $child_id");
                $conn->query("DELETE FROM progress WHERE child_id = $child_id");
                
                if ($conn->query("DELETE FROM children WHERE id = $child_id")) {
                    echo json_encode(["status" => "success", "message" => "Child profile deleted"]);
                } else {
                    echo json_encode(["status" => "error", "message" => "Failed to delete child"]);
                }
            } catch (Exception $e) {
                echo json_encode(["status" => "error", "message" => "Database error: " . $e->getMessage()]);
            }
        } else {
            echo json_encode(["status" => "error", "message" => "Missing child ID"]);
        }
    } elseif (isset($data->parent_id) && isset($data->name) && isset($data->age)) {
        $parent_id = (int)$data->parent_id;
        $name = $conn->real_escape_string($data->name);
        $age = (int)$data->age;
        
        if ($conn->query("INSERT INTO children (parent_id, name, age) VALUES ($parent_id, '$name', $age)")) {
            echo json_encode(["status" => "success", "child_id" => $conn->insert_id]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to add child"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Missing parameters"]);
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    // Parse input since DELETE doesn't populate $_POST
    $data = json_decode(file_get_contents("php://input"));
    
    // Also support getting ID from query string if that's how it's sent
    $child_id = null;
    if (isset($_GET['id'])) {
        $child_id = (int)$_GET['id'];
    } elseif (isset($data->id)) {
        $child_id = (int)$data->id;
    }
    
    if ($child_id !== null) {
        if ($conn->query("DELETE FROM children WHERE id = $child_id")) {
            echo json_encode(["status" => "success", "message" => "Child profile deleted"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to delete child"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Missing child ID"]);
    }
}
?>

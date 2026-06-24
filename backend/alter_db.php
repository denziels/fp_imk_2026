<?php
require 'db.php';
if ($conn->query("ALTER TABLE children ADD COLUMN profile_picture LONGTEXT;")) {
    echo "Success";
} else {
    echo "Error: " . $conn->error;
}
?>

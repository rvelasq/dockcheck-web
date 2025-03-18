<?php
header("Content-Type: application/json; charset=UTF-8");

if (file_exists('/data/running')) {
    echo '{ "message":"already in progress"}';
} else {
    $create_file_update = fopen("/var/www/html/update.txt", "w") or die("Unable to open file!");
    fwrite($create_file_update, "1");
    echo '{ "message":"check initiated"}';
}
?>
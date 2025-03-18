<?php
header("Content-Type: application/json; charset=UTF-8");

class UpdateStatus {
  public $running; 
}

$status = new UpdateStatus;

$status->running = file_exists('/data/running');

$jsonStr = json_encode($status);
echo $jsonStr;

?>
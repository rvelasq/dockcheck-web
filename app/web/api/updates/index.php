<?php
header("Content-Type: application/json; charset=UTF-8");

class UpdatesList {
    public $list;
    public $count;
}

class UpdatesBatch {
  public $host;
  public $asof;
  public $errors;
  public $latest;
  public $updates; 
}

$batch = new UpdatesBatch;
$batch->asof = time();
$batch->host = php_uname('n');
$batch->errors = new UpdatesList;
$batch->latest = new UpdatesList;
$batch->updates = new UpdatesList;

$filename = '/data/containers';

$conlatest_match = [];
$conerror_match = [];
$conupdate_match = [];

if (filesize($filename) != 0) {

    $f = fopen($filename, 'r');

    if ($f) {
        $batch->asof = filemtime($filename);

        $contents = fread($f, filesize($filename));
        fclose($f);
        preg_match("/(?<=Containers with errors, wont get updated:\n)(?s).*?(?=\n\n)/", $contents, $conerror_match); 
        $string_output_error = implode('', $conerror_match);
        $conerror_match = preg_split('`\n`', $string_output_error);

        preg_match("/(?<=Containers on latest version:\n)(?s).*?(?=\n\n)/", $contents, $conlatest_match);    
        $string_output_latest = implode('', $conlatest_match);
        $conlatest_match = preg_split('`\n`', $string_output_latest);

        preg_match("/(?<=Containers with updates available:\n)(?s).*?(?=\n\n)/", $contents, $conupdate_match);
        $string_output_update = implode('', $conupdate_match);
        $conupdate_match = preg_split('`\n`', $string_output_update);
    }

}

$batch->errors->count = count($conerror_match);
if ($batch->errors->count == 1 && $conerror_match[0] == "") {
    $batch->errors->count = 0;
    $batch->errors->list = [];
} else {
    $batch->errors->list = $conerror_match;
}

$batch->latest->count = count($conlatest_match);
if ($batch->latest->count == 1 && $conlatest_match[0] == "") {
    $batch->latest->count = 0;
    $batch->latest->list = [];
} else {
    $batch->latest->list = $conlatest_match;
}

$batch->updates->count = count($conupdate_match);
if ($batch->updates->count == 1 && $conupdate_match[0] == "") {
    $batch->updates->count = 0;
    $batch->updates->list = [];
} else {
    $batch->updates->list = $conupdate_match;
}


$jsonStr = json_encode($batch);
echo $jsonStr;

?>
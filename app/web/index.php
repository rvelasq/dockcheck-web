<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?php
            if (isset($_ENV['WINDOW_TITLE'])) {
                echo htmlspecialchars($_ENV['WINDOW_TITLE']);
            } else {
                echo 'Dockcheck';
            }
            ?></title>
    <link rel="stylesheet" href="bulma.min.css">
    <link rel="icon" href="favico.jpeg">
</head>
<body>
<section class="section">

    <div class="container">
        <h1 class="title">
            <a href=index.php><?php
                if (isset($_ENV['PAGE_TITLE'])) {
                    echo htmlspecialchars($_ENV['PAGE_TITLE']);
                } else {
                    echo 'Dockcheck';
                }
                ?>
            </a>
        </h1>
        <h2 class="subtitle">Image updates for your running containers.</h2>
    </div>

    <div class="container">
        <p>&nbsp;</p>
        <p><button id="cfu" type="button" class="button is-primary is-rounded">Check for updates</button></p>
        <p>&nbsp;</p>
    </div>
    <?

    $curl = curl_init();
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($curl, CURLOPT_FOLLOWLOCATION, 1);
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, 0);
    curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, 0);
    curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 10);    
    curl_setopt($curl, CURLOPT_URL, 'http://127.0.0.1/api/updates/');
    $res = curl_exec($curl);
    curl_close($curl);

    $json = json_decode($res);

    ?>
    <div class="container content">
        <blockquote class="p-2">
            As of <?php  
            $timezone = 'UTC';
            if (isset($_ENV['TZ'])) {
                $timezone = $_ENV['TZ'];
            }
            $epoch = $json->asof;
            $dt = new DateTime("@$epoch");
            $dt->setTimezone(new DateTimeZone($timezone));
            echo $dt->format('j F Y, g:i a');
            ?>
        </blockquote>
    </div>

    <div class="container">
    <div class="columns">
        
        <div class="column">
            <span class="title is-size-4 has-text-success is-capitalized">Updates available</span>
            <table class="table is-narrow">
            <?php
            if ($json->updates->count > 0) {
                $list = $json->updates->list;
                sort($list);
                for($i=0; $i < $json->updates->count; $i++) {
                    echo '<tr>';
                    echo '<td>' . $list[$i] . '</td>';
                    echo '</tr>';
                }

            }
            ?>
            </table>

        </div>            
        <div class="column">
            <span class="title is-size-4 has-text-info is-capitalized">Up-to-date</span>
            <table class="table is-narrow">
            <?php
            if ($json->latest->count > 0) {
                $list = $json->latest->list;
                sort($list);
                for($i=0; $i < $json->latest->count; $i++) {
                    echo '<tr>';
                    echo '<td>' . $list[$i] . '</td>';
                    echo '</tr>';
                }

            }
            ?>
            </table>
        </div>

        <div class="column">
            <span class="title is-size-4 has-text-danger is-capitalized">Error Getting Updates</span>
            <table class="table is-narrow">
            <?php
            if ($json->errors->count > 0) {
                $list = $json->errors->list;
                sort($list);
                for($i=0; $i < $json->errors->count; $i++) {
                    echo '<tr>';
                    echo '<td>' . $list[$i] . '</td>';
                    echo '</tr>';
                }

            }
            ?>
            </table>
        </div>
    </div>
</section>

<script>
document.addEventListener('DOMContentLoaded', () => {
  // Functions to open and close a modal
  function setLoading($el) {
    $el.classList.add('is-loading');
  }

  function endLoading($el) {
    $el.classList.remove('is-loading');
  }

  const cfuButton = document.querySelector('#cfu')
  cfuButton.addEventListener('click', () => {
      setLoading(cfuButton);
      fetch('/api/check/').then( r => r.text()).then( t => console.log(t))
      intervalId = window.setInterval(() => {
        fetch('/api/status/')
        .then( r => r.json())
        .then( j => {
            if (!j.running) {
                location.reload()
                endLoading(cfuButton)
                window.clearInterval(intervalId);
            }
        })
      }, 1000);
    });

    fetch('/api/status/')
    .then( r => r.json())
    .then( j => {
        if (j.running) {
            cfuButton.click()
        }
    })



});

</script>

</body>
</html>

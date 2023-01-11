<?php
// Build a playlist for jarvis to load

include 'includes/db.php';

echo "Hi Scott. Hope all is well.";

$sql = "SELECT filenamepath, artist, title FROM `library` WHERE `genre` LIKE '%Prog%' ORDER BY artist";

$result = $mysqli->query( $sql );

if(!$result){
    echo $mysqli->error; 
    exit;
}

$results = $result->fetch_all( MYSQLI_ASSOC );    

echo count( $results ). " results found." . PHP_EOL . "Generating file..";

$file = fopen("playlists/progressive.m3u","a");


foreach( $results as $row ){
                    // print $row['filenamepath'] . PHP_EOL;

                    fwrite($file,$row['filenamepath'].PHP_EOL);
    }
                
fclose($file);
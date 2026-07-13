<?php
    require_once '../PHP/datiGenerali.php';

    header('Content-Type: application/json');

    if(isset($_GET['action']) && $_GET['action'] == 'getClassifica'){
        $classifica_sql = getClassifica();
        if($classifica_sql){
            $classifica = json_encode($classifica_sql);
            echo $classifica;
        } else {
            echo json_encode(array('error' => "Nessuna classifica disponibile"));
        }
    } else {
        echo json_encode(array('error' => "Richiesta non valida"));
    }
?>
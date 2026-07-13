<?php
    require_once '../PHP/insertPunteggio.php';

    header('Content-Type: application/json');

    if(isset($_GET['action']) && $_GET['action'] == 'insertPunteggio' && isset($_POST['punteggio'])){
        $punteggio = $_POST['punteggio'];
        $insert_sql = insertPunteggio($punteggio);
        if(!$insert_sql){
            echo json_encode(array('error' => "Non è stato trovato nessun punteggio da inserire"));
        } else {
            echo json_encode(array('success' => "Punteggio inserito con successo"));  
        }
    } else {
        echo json_encode(array('error' => "Richiesta non valida"));
    }
?>
<?php
    require_once '../Database/configDatabase.php';

    // inserimento del nuovo punteggio nel database
    function insertPunteggio($punteggio){
        session_start();
        $connessione = new connectionDB();
        
        if(isset($_SESSION['username'])){
            $username  = $_SESSION['username'];
            try{
                $sql = "CALL insertPunteggio(?, ?)";
                $stmt = $connessione->prepare($sql);
                $stmt -> bind_param("si", $username, $punteggio);
                if(!$stmt -> execute()){
                    error_log("Problema nell'inserimento");
                    $connessione->close();
                    return false;
                };
            } catch (Error | Exception $e) {
                error_log('Caught exception: ' . $e->getMessage());
                error_log('On Line : ' . $e->getLine());
                error_log('Stack Trace : ' . print_r($e->getTrace(), true));
                return false;
            }

            $connessione->close();
            return true;
        }

        $connessione->close();
        return false;
    }

?>
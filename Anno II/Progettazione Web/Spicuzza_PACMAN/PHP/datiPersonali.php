<?php
    require_once '../Database/configDatabase.php';

    session_start();

    $connessione = new connectionDB();

    // mi permette di scrivere nella tabella personale (sx)
    // username e record dell'utente
    if(isset($_SESSION['username'])){
        $username = $_SESSION['username'];

        try{
            $sql = "CALL getRecord(?)";
            $stmt = $connessione->prepare($sql);
            $stmt -> bind_param("s", $username);
            $stmt -> execute();
            $result = $stmt -> get_result();
            if($result->num_rows !== 0){
                $record = $result -> fetch_assoc();
                echo "<script>
                        document.addEventListener('DOMContentLoaded', function(){
                            const record   = document.getElementById('record');
                            const username = document.getElementById('username');
                            record.innerText   = '".$record['record']."';
                            username.innerText = '".$username."';  
                        });
                    </script>";
                $result->free();
            }
        } catch (Error | Exception $e) {
            error_log('Caught exception: ' . $e->getMessage());
            error_log('On Line : ' . $e->getLine());
            error_log('Stack Trace : ' . print_r($e->getTrace(), true));
        } 
        
    }

    $connessione->close();

?>
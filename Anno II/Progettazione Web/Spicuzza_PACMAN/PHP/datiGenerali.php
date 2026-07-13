<?php
    require_once '../Database/configDatabase.php';

    // get della classifica dal database
    function getClassifica(){
        session_start();
        $connessione = new connectionDB();
        
        try{
            $max_classifica = 10;
            $sql = "CALL getClassifica(?)";
            $stmt = $connessione->prepare($sql);
            $stmt -> bind_param("i", $max_classifica);
            $stmt -> execute();
            $result = $stmt -> get_result();
            
            if($result->num_rows !== 0){
                $classifica = array();

                while($record = $result -> fetch_assoc()){
                    $classifica[] = $record;
                }
                $result->free();
                return $classifica;
            } else {
                return array();
            }
        } catch (Error | Exception $e) {
            return array();
        }

        $connessione->close();
    }

?>
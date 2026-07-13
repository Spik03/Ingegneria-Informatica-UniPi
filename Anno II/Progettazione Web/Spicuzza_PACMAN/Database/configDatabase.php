<?php

// breve classe che si occupa della connessione al database
class connectionDB{
    public $mysqli;

    function __construct(){
        try {
            $this->mysqli = new mysqli("localhost","root","","spicuzza_654788");
        } 
        catch (Exception $e) {
            error_log('Caught exception: ' . $e->getMessage());
            error_log('On Line : ' . $e->getLine());
            error_log('Stack Trace : ' . print_r($e->getTrace(), true));
        }
    }

    function getConnessione(){
        return $this->mysqli;
    }

    function close(){
        $this->mysqli->close();
    }

    function prepare($sql){
        return $this->mysqli->prepare($sql);
    }
}


?>
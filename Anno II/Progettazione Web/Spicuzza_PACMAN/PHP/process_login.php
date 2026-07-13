<?php
    if(session_status() === PHP_SESSION_NONE){
        session_start();
    }

    require_once '../Database/configDatabase.php';

    $connessione = new connectionDB();

    // gestione della richiesta di login / registrazione dell'utente
    if($_SERVER["REQUEST_METHOD"] == "POST") {
        $action = $_POST['action'];
        $username = $_POST['username'];
        $password = $_POST['password'];
        try{    
            if ($action == 'registrazione') {
                $sql = "CALL insertUtente(?, ?)";
                $stmt = $connessione->prepare($sql);
                $password_cripted = password_hash($password, PASSWORD_BCRYPT);
                $stmt -> bind_param("ss", $username, $password_cripted);
                    
                if($stmt->execute()){
                    successo($connessione, $username);
                } else {
                    errore("existing_user", $connessione);
                }
                $stmt->close();
            } else if ($action == "login") {
                $sql = "CALL getUtente(?)";
                $stmt = $connessione->prepare($sql);
                $stmt -> bind_param("s", $username);
                $stmt -> execute();
                $result = $stmt -> get_result();
                if($result->num_rows !== 0){
                    $utente = $result -> fetch_assoc();
                    if($utente && password_verify($password, $utente["password"])){
                        successo($connessione, $username);
                    } else {
                        errore("invalid_credentials", $connessione);
                    }
                } else {
                    errore("invalid_credentials", $connessione);
                }
            }
        } catch (Exception $e) {
            error_log('Caught exception: ' . $e->getMessage());
            error_log('On Line : ' . $e->getLine());
            error_log('Stack Trace : ' . print_r($e->getTrace(), true));
        }
    }
    
    function errore($messaggio, $connessione){
        $connessione->close();
        header("Location: ../HTML/login.php?error=" . "$messaggio");
        exit();
    }

    function successo($connessione, $username){
        $_SESSION['username'] = $username;
        $connessione->close();
        header("Location: ../HTML/pacman.php");
        exit();
    }
?>
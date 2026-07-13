<?php

require_once __DIR__ . "/GestioneCarrieraStudente.php";
require_once __DIR__ . "/ProspettoCommissione.php";
require_once __DIR__ . "/InvioProspetti.php";


header('Content-Type: text/event-stream');
header('Cache-Control: no-cache');
header('Connection: keep-alive');

$data = json_decode(file_get_contents("php://input"), true);
switch ($data["function"]) {
    case "invioProspetti" :
        invioProspetti($data);
        break;
    case "creazioneProspetti" :
        creazioneProspetti($data);
        break;
    default:
        echo "Errore nella richiesta";
}

/**
 * Invia tramite email il ProspettoStudente
 * @param array $data
 * @return void
 * @throws \PHPMailer\PHPMailer\Exception
 */
function invioProspetti(array $data): void
{
    $invioProspetti = new InvioProspetti($data["CdL"]);
    echo $invioProspetti->invia($data["matricola"]);
}

/**
 * Crea il ProspettoCommissione
 * (durante la sua generazione verranno generati
 *  anche i ProspettiStudenti)
 * @param array $data
 * @return void
 */
function creazioneProspetti(array $data): void
{
    $prospettoCommissione = new ProspettoCommissione($data["dataAppello"]);
    $prospettoCommissione->generaProspettoCommissione($data["CdL"], $data["matricole"]);

    if (!file_exists(__Dir__ . "/../data/{$data["CdL"]}")) {
        echo "Errore di creazione";
    }
    echo "Prospetti Creati";
}

?>
<?php

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require_once __DIR__ . "/../lib/PHPMailer/src/Exception.php";
require_once __DIR__ . "/../lib/PHPMailer/src/PHPMailer.php";
require_once __DIR__ . "/../lib/PHPMailer/src/SMTP.php";

class InvioProspetti
{
    private string $corsoDiLaurea;
    private string $subject;
    private string $body;
    private bool $test;

    /**
     * Costruttore della classe InvioProspetti
     * @param string $corsoDiLaurea
     * @param bool $test
     */
    public function __construct(string $corsoDiLaurea, bool $test = false)
    {
        $this->subject = "Appello di laurea in {$corsoDiLaurea}-indicatori per voto di laurea";
        $this->corsoDiLaurea = $corsoDiLaurea;

        $json = file_get_contents(__Dir__ . "/../config/config.json");
        $data = json_decode($json, true, 512, JSON_UNESCAPED_UNICODE);

        if ($data === null) {
            die("Errore nella codifica del JSON di configurazione per il body della mail");
        }
        $this->body = $data["InformazioniCorso"][$corsoDiLaurea]["BodyMail"];
        $this->test = $test;
    }

    /**
     * Funzione che si occupa dell'invio della mail allo studente
     * @param string $matricola
     * @return bool
     */
    public function invia(string $matricola): bool
    {
        if (!file_exists(
            __Dir__ . "/../" . ($this->test ? "test" : "data") . "/{$this->corsoDiLaurea}/{$matricola}_prospetto.pdf"
        )) {
            return false;
        }

        $email = GestioneCarrieraStudente::ottieniEmailStudente($matricola);

        $messaggio = new PHPMailer();

        $messaggio->IsSMTP();
        $messaggio->Host = "mixer.unipi.it";
        $messaggio->SMTPSecure = "tls";
        $messaggio->SMTPKeepAlive = false;
        $messaggio->SMTPOptions = array(
            'ssl' => array(
                'verify_peer' => false,
                'verify_peer_name' => false,
                'allow_self_signed' => true
            )
        );
        $messaggio->SMTPAuth = false;
        $messaggio->Port = 25;

        try {
            $messaggio->CharSet = "UTF-8";
            $messaggio->From = 'no-reply-laureandosi@ing.unipi.it';
            $messaggio->AddAddress($email);
            $messaggio->Subject = $this->subject;
            $messaggio->Body = $this->body;
            $messaggio->addAttachment(
                __Dir__ . "/../" . ($this->test ? "test" : "data") . "/{$this->corsoDiLaurea}/{$matricola}_prospetto.pdf"
            );

            if (!$messaggio->send()) {
                return false;
            }
            $messaggio->SmtpClose();
            unset($messaggio);
            return true;
        } catch (Exception) {
            return false;
        }
    }

}

?>
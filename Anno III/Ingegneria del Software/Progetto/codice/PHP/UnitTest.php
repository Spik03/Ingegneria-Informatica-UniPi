<?php

require_once __DIR__ . "/GestioneCarrieraStudente.php";
require_once __DIR__ . "/ProspettoCommissione.php";
require_once __DIR__ . "/InvioProspetti.php";

class UnitTest
{
    private mixed $studente;
    private string $dataLaurea;
    private mixed $outputAtteso;
    private array $campo;
    private static bool $jsGenerato = false;
    private bool $corsoValido;

    /**
     * Costruttore della classe UnitTest
     * @param array $input
     */
    public function __construct(array $input)
    {
        $this->corsoValido = UnitTest::existCorsoDiLaurea($input["corsoDiLaurea"]);

        if ($this->corsoValido) {
            $this->studente = UnitTest::getStudente($input["matricola"], $input["corsoDiLaurea"], $input["dataLaurea"]);
        } else {
            $this->studente = $input["matricola"];
        }
        $this->dataLaurea = $input["dataLaurea"];
        $this->outputAtteso = array_slice($input, 3, 5, true);
        $this->campo = ["media", "cfuMedia", "cfuCurriculari", "bonus", "mediaInformatica"];
    }

    /**
     * Funzione che si occupa del testing e della stampa dei risultati
     * per i valori calcolati per lo studente (e.g. media, cfuCurriculari)
     * @return void
     */
    public function testStudente(): void
    {
        if (!$this->corsoValido) {
            echo "<p style='color: red'>Corso non valido, test per {$this->studente} fallito</p><br>";
            return;
        }

        for ($i = 0; $i < count($this->campo); $i++) {
            if (property_exists($this->studente, $this->campo[$i])) {
                $output = $this->studente->{$this->campo[$i]};
                $outputAtteso = $this->outputAtteso[$this->campo[$i]];
                if ($this->campo[$i] === "media" || $this->campo[$i] === "mediaInformatica") {
                    $success = round($output, 3) === $outputAtteso;
                } else {
                    $success = $output === $outputAtteso;
                }
                self::echoResultTestStudente($this->campo[$i], $success, $output, $outputAtteso);
            }
        }
        echo "<br>";
    }

    /**
     * Funzione che testa la creazione dei prospetti, è statica perché non necessita delle informazioni
     * salvate per la singola istanza di UnitTest, ma solo di quelle passate in ingresso.
     *
     * Oltre alla stampa testuali dei risultati,
     * permette inoltre di aprire i prospetti generati e, nel caso di quelli per i singoli studenti,
     * aprire anche una versione corretta per poter essere comparate.
     * @param string $matricole
     * @param string $corsoDiLaurea
     * @param string $dataLaurea
     * @return void
     */
    public static function testCreazioneProspetti(string $matricole, string $corsoDiLaurea, string $dataLaurea): void
    {
        echo UnitTest::generaJavaScript();

        echo "<h4>{$corsoDiLaurea}</h4>";
        if (!UnitTest::existCorsoDiLaurea($corsoDiLaurea)) {
            echo "<p style='color: red'>Corso non valido, test fallito</p><br>";
            return;
        }

        $prospettoCommissione = new ProspettoCommissione($dataLaurea, true);
        $prospettoCommissione->generaProspettoCommissione($corsoDiLaurea, $matricole);

        $path = "/test/{$corsoDiLaurea}/commissione_prospetto.pdf";
        echo "Test 1: creazione ProspettoCommissione:";
        if (file_exists(__DIR__ . "/.." . $path)) {
            echo "<p><button style='color: green' onclick=\"apriProspettoTest('{$path}');\">PROSPETTO CREATO</button></p><br>";
        } else {
            echo "<p style='color: red'>FAILED </p><br>";
        }

        $vettoreMatricole = array_filter(preg_split('/[,\s]+/', trim(preg_replace('/[^0-9,\s]/', '', $matricole))));

        $pathOutput = "/test/ProspettiStudentiGiusti/";
        foreach ($vettoreMatricole as $matricola) {
            $studente = UnitTest::getStudente($matricola, $corsoDiLaurea, $dataLaurea);
            $path = "/test/{$corsoDiLaurea}/{$studente->matricola}_prospetto.pdf";
            echo "Test 2: creazione ProspettoStudente {$matricola}: ";
            if (file_exists(__DIR__ . "/.." . $path)) {
                $pathOutputCompleto = $pathOutput . "{$studente->matricola}_output.pdf";
                echo "<p style='white-space: nowrap;'>";
                echo "<button style='color: green' onclick=\"apriProspettoTest('{$path}');\">PROSPETTO CREATO</button> | ";
                echo "<button onclick=\"apriProspettoTest('{$pathOutputCompleto}');\">APRI PROSPETTO CORRETTO</button>";
                echo "</p><br>";
            } else {
                echo "<p style='color: red'>FAILED </p><br>";
            }
        }
    }

    /**
     * testa l'invio dei prospetti (l'email verrà mandata a quella dello studente,
     *  a meno di modifiche nella classe InvioProspetti.php).
     * Per far sì che possa essere richiamata senza necessitare di testCreazioneProspetti per l'esistenza
     * del prospetto, genera il prospetto prima di fare l'invio della mail.
     * é possibile inoltre poter mettere un tempo d'attesa a seguito dell'invio,
     * ciò bloccherà per $attesaSecondi secondi l'esecuzione del codice PHP.
     * @param int $attesaSecondi
     * @return void
     */
    public function testInvioProspetto(int $attesaSecondi=0): void
    {
        if (!$this->corsoValido) {
            echo "<p style='color: red'>Corso non valido, test per {$this->studente} fallito</p><br>";
            return;
        }

        $prospettoStudente = new ProspettoStudente($this->dataLaurea, true);
        $prospettoStudente->generaProspettoStudente($this->studente);

        $invioProspetto = new InvioProspetti($this->studente->corsoDiLaurea, true);
        echo "Test: Invio ProspettoStudente {$this->studente->matricola}: ";
        if ($invioProspetto->invia($this->studente->matricola)) {
            echo "<p style='color: green'>SUCCESS</p><br>";
        } else {
            echo "<p style='color: red'>FAILED </p><br>";
        }
        usleep(abs($attesaSecondi)*1000000);
    }

    /**
     * Controlla se il CorsoDiLaurea esiste nel file di configurazione
     * @param string $corsoDiLaurea
     * @return bool
     */
    private static function existCorsoDiLaurea(string $corsoDiLaurea): bool
    {
        $json = file_get_contents(__Dir__ . "/../config/config.json");
        $data = json_decode($json, true);

        if ($data === null) {
            die("Errore nella codifica del JSON di configurazione per gli esami non in carriera");
        }

        return isset($data["InformazioniCorso"][$corsoDiLaurea]);
    }

    /**
     * Funzione che fa l'eco dei risultati per la funzione testStudente
     * @param string $campo
     * @param string $success
     * @param mixed $output
     * @param mixed $outputAtteso
     * @return void
     */
    private function echoResultTestStudente(string $campo, string $success, mixed $output, mixed $outputAtteso): void
    {
        echo "Matricola: {$this->studente->matricola} - {$campo}"
            . " |  Output atteso: " . (is_bool(
                $outputAtteso
            ) ? ($outputAtteso ? 'true' : 'false') : $outputAtteso) . "<br>";
        echo '<p style="color: ' . ($success ? 'green' : 'red') . ';">';
        echo "Output: " . (is_bool($output) ? ($output ? 'true' : 'false') : (is_float($output) ? round(
                $output,
                3
            ) : $output));
        echo "</p><br>";
    }

    /**
     * Ritorna un oggetti di tipo CarrieraInformatico/CarrieraStudente
     * @param string $matricola
     * @param string $corsoDiLaurea
     * @param string $dataLaurea
     * @return CarrieraInformatico|CarrieraStudente|null
     */
    private static function getStudente(
        string $matricola,
        string $corsoDiLaurea,
        string $dataLaurea
    ): CarrieraInformatico|CarrieraStudente|null {
        return GestioneCarrieraStudente::ottieniAnagraficaStudente(
            $matricola,
            $corsoDiLaurea,
            $dataLaurea
        );
    }

    /**
     * Funzione che genera nella pagina web lo script presente in /JScript/ApriProspettiTest.js
     * Serve per permettere l'apertura dei prospetti creati
     * @return string
     */
    public static function generaJavaScript(): string
    {
        if (UnitTest::$jsGenerato) {
            return "";
        }
        UnitTest::$jsGenerato = true;
        $path = __DIR__ . '/../JScript/ApriProspettiTest.js';
        $file = file_get_contents($path);

        if ($file === false) {
            return "Errore: impossibile leggere il file JavaScript.";
        }

        return "<script>\n" . $file . "\n</script>";
    }

}
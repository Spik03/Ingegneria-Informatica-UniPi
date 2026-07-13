<?php

require_once __DIR__ . "/ProspettoStudente.php";

class ProspettoCommissione
{
    private ProspettoStudente $prospettoStudente;
    private string $font;
    private array $studenti;
    private int $numStudenti;
    private string $dataAppello;

    private array $infoParametro;
    private string $formula;
    private int $cfuCorso;
    private string $messaggioProspetto;
    private bool $test;

    /**
     * Costruttore della classe ProspettoCommissione
     * @param string $dataAppello
     * @param bool $test
     */
    public function __construct(string $dataAppello, bool $test = false)
    {
        $this->prospettoStudente = new ProspettoStudente($dataAppello, $test);
        $this->font = "Arial";
        $this->dataAppello = $dataAppello;
        $this->test = $test;
    }

    /**
     * Funzione che inizializza alcuni attributi della classe in base
     * al corsoDiLaurea in ingresso
     * @param string $corsoDiLaurea
     * @return void
     */
    private function inizializza(string $corsoDiLaurea): void
    {
        $this->studenti = [];
        $this->numStudenti = 0;
        $this->infoParametro = [];

        $this->formula = self::getInformazioneCorso($corsoDiLaurea, "Formula");
        $this->cfuCorso = self::getInformazioneCorso($corsoDiLaurea, "CFU");
        $this->messaggioProspetto = self::getInformazioneCorso($corsoDiLaurea, "MessaggioProspetto");
        self::salvaInfoParametro($corsoDiLaurea);
    }

    /**
     * Funzione che si occupa di richiamare tutte le funzioni necessarie per
     * generare il prospetto
     * @param string $corsoDiLaurea
     * @param string $listaMatricole
     * @return void
     */
    public function generaProspettoCommissione(string $corsoDiLaurea, string $listaMatricole): void
    {
        self::inizializza($corsoDiLaurea);

        $matricole = self::generaVettoreMatricole($listaMatricole);
        $pdf = new FPDF();

        self::eliminaProspettiAppelliPrecedenti($corsoDiLaurea);

        self::creaProspettoCommissione($corsoDiLaurea, $this->dataAppello, $matricole, $pdf);

        self::salvaProspettoCommissione($corsoDiLaurea, $pdf);
    }

    /**
     * Funzione che crea il ProspettoCommissione
     * @param string $corsoDiLaurea
     * @param string $dataAppello
     * @param array $matricole
     * @param fpdf $pdf
     * @return void
     */
    private function creaProspettoCommissione(
        string $corsoDiLaurea,
        string $dataAppello,
        array $matricole,
        fpdf $pdf
    ): void {
        $pdf->setMargins(11, 8);
        $pdf->setFont($this->font, "", 12);

        $pdf->addPage();

        $pdf->cell(0, 8, $corsoDiLaurea, 0, 1, "C");
        $pdf->Ln(1);

        self::addListaMatricole($pdf, $matricole, $corsoDiLaurea, $dataAppello);
        self::addProspettoStudente($pdf, $corsoDiLaurea);
    }

    /**
     * Funzione che salva le informazioni riguardante il parametro variabile
     * nella formula del volo di laurea
     * @param string $corsoDiLaurea
     * @return void
     */
    private function salvaInfoParametro(string $corsoDiLaurea): void
    {
        $this->infoParametro[0] = $this->getInformazioneCorso($corsoDiLaurea, "Parametro")["param"];
        $this->infoParametro[1] = $this->getInformazioneCorso($corsoDiLaurea, "Parametro")["min"];
        $this->infoParametro[2] = $this->getInformazioneCorso($corsoDiLaurea, "Parametro")["max"];
        $this->infoParametro[3] = $this->getInformazioneCorso($corsoDiLaurea, "Parametro")["step"];
    }

    /**
     * Funzione che serve per ottenere una data informazione del corsoDiLaurea dal json di configurazione
     * @param string $corsoDiLaurea
     * @param string $informazione
     * @return mixed
     */
    private function getInformazioneCorso(string $corsoDiLaurea, string $informazione): mixed
    {
        $json = file_get_contents(__Dir__ . "/../config/config.json");
        $data = json_decode($json, true);

        if ($data === null) {
            die("Errore nella codifica del JSON di configurazione per: " . $informazione);
        }

        return $data["InformazioniCorso"][$corsoDiLaurea][$informazione];
    }

    /**
     * Data una stringa in cui sono presenti delle matricole (o più in generale, dei codici numerici)
     * Separati da spazi o virgole
     * Ritorna un vettore dei singoli elementi
     * @param string $listaMatricole
     * @return array|false|string[]
     */
    private function generaVettoreMatricole(string $listaMatricole): array|bool
    {
        $listaPulita = preg_replace('/[^0-9,\s]/', '', $listaMatricole);
        return array_filter(preg_split('/[,\s]+/', trim($listaPulita)));
    }

    /**
     * Elimina tutti i prospettiStudenti presenti nella cartella
     *  /../{test : data}/corsoDiLaurea
     * @param string $corsoDiLaurea
     * @return void
     */
    private function eliminaProspettiAppelliPrecedenti(string $corsoDiLaurea): void
    {
        $folder = __Dir__ . "/../" . $this->test ? "test" : "data" . "/{$corsoDiLaurea}";
        $prospetto = glob($folder . "*_prospetto.pdf");

        foreach ($prospetto as $p) {
            if (is_file($p)) {
                unlink($p);
            }
        }
    }

    /**
     * Ritorna un oggetto di tipo CarrieraInformatico / CarrieraStudente
     * @param string $matricola
     * @param string $corsoDiLaurea
     * @param string $dataLaurea
     * @return CarrieraInformatico|CarrieraStudente|mixed|null
     */
    private function getStudente(string $matricola, string $corsoDiLaurea, string $dataLaurea): mixed
    {
        $this->studenti[$this->numStudenti] = GestioneCarrieraStudente::ottieniAnagraficaStudente(
            $matricola,
            $corsoDiLaurea,
            $dataLaurea
        );
        return $this->studenti[$this->numStudenti++];
    }

    /**
     * Salva il prospettoCommissione nella cartella
     * /../{test : data}/corsoDiLaurea
     * @param string $corsoDiLaurea
     * @param fpdf $pdf
     * @return void
     */
    private function salvaProspettoCommissione(string $corsoDiLaurea, fpdf $pdf): void
    {
        if (!file_exists(__Dir__ . "/../" . ($this->test ? "test" : "data") . "/{$corsoDiLaurea}")) {
            mkdir(__Dir__ . "/../" . ($this->test ? "test" : "data") . "/{$corsoDiLaurea}", 0777, true);
        }
        $pdf->Output(
            "F",
            __Dir__ . "/../" . ($this->test ? "test" : "data") . "/{$corsoDiLaurea}/commissione_prospetto.pdf"
        );
    }

    /**
     * Funzione che si occupa di generare la prima pagina del prospettoCommissione,
     * dove è presente la tabella delle matricole
     * @param fpdf $pdf
     * @param array $matricole
     * @param string $corsoDiLaurea
     * @param string $dataLaurea
     * @return void
     */
    private function addListaMatricole(fpdf $pdf, array $matricole, string $corsoDiLaurea, string $dataLaurea): void
    {
        $pdf->cell(0, 8, "LISTA LAUREANDI", 0, 1, "C");
        $pdf->Ln(1);

        $cell_x = ($pdf->GetPageWidth() - 22) / 4;
        $cell_y = 6;

        $pdf->cell($cell_x, $cell_y, "COGNOME", 1, 0, "C");
        $pdf->cell($cell_x, $cell_y, "NOME", 1, 0, "C");
        $pdf->cell($cell_x, $cell_y, "CDL", 1, 0, "C");
        $pdf->cell($cell_x, $cell_y, "VOTO LAUREA", 1, 1, "C");

        $pdf->setFontSize(11);

        foreach ($matricole as $matricola) {
            $studente = self::getStudente($matricola, $corsoDiLaurea, $dataLaurea);
            $pdf->cell($cell_x, $cell_y, $studente->cognome, 1, 0, "C");
            $pdf->cell($cell_x, $cell_y, $studente->nome, 1, 0, "C");
            $pdf->cell($cell_x, $cell_y, "", 1, 0, "C");
            $pdf->cell($cell_x, $cell_y, "   /110", 1, 1, "C");
        }

        $pdf->Ln(1);
    }

    /**
     * Funzione che si occupa di generare il ProspettoStudente per ogni studente, sia come pdf a sè stante,
     * sia come pagina del prospettoCommissione
     * @param fpdf $pdf
     * @param string $corsoDiLaurea
     * @return void
     */
    private function addProspettoStudente(fpdf $pdf, string $corsoDiLaurea): void
    {
        foreach ($this->studenti as $studente) {
            $this->prospettoStudente->generaProspettoStudente($studente);
            $this->prospettoStudente->creaProspettoStudente($studente, $pdf);
            $pdf->Ln(2);
            self::addTabellaSimulazione($studente, $pdf);
            self::addMessaggioProspetto($pdf);
        }
    }

    /**
     * Funzione che si occupa di aggiungere al pdf la tabella della simulazione del voto di laurea dello studente
     * @param CarrieraStudente|CarrieraInformatico $studente
     * @param fpdf $pdf
     * @return void
     */
    private function addTabellaSimulazione(CarrieraStudente|CarrieraInformatico $studente, fpdf $pdf): void
    {
        $numRighe = (int)(($this->infoParametro[2] - $this->infoParametro[1]) / $this->infoParametro[3] + 1);
        $righePerColonna = ($numRighe <= 7 ? 7 : ((int)($numRighe / 2) + 1));
        $cell_x = ($pdf->GetPageWidth() - 22) / ($numRighe <= $righePerColonna ? 2 : 4);
        $cell_y = 6;

        $pdf->cell($pdf->GetPageWidth() - 22, $cell_y, "SIMULAZIONE DI VOTO DI LAUREA", 1, 1, "C");

        for ($i = 0; $i < ($numRighe <= $righePerColonna ? 1 : 2); $i++) {
            $pdf->Cell(
                $cell_x,
                $cell_y,
                "VOTO " . ($this->infoParametro[0] == "C" ? "COMMISSIONE (C)" : "TESI (T)"),
                1,
                0,
                'C'
            );
            $pdf->Cell($cell_x, $cell_y, "VOTO LAUREA", 1, ($i == ($numRighe <= $righePerColonna ? 1 : 2) - 1), 'C');
        }

        $xIniziale = $pdf->GetX();
        $yIniziale = $pdf->GetY();

        for ($i = 0; $i < $numRighe; $i++) {
            $colonnaAttuale = floor($i / $righePerColonna);
            $rigaAttuale = $i % $righePerColonna;

            $x = $xIniziale + ($colonnaAttuale * 2 * $cell_x);
            $y = $yIniziale + ($rigaAttuale * $cell_y);

            $pdf->SetXY($x, $y);
            $pdf->Cell($cell_x, $cell_y, $this->infoParametro[1] + $i * $this->infoParametro[3], 1, 0, 'C');
            $pdf->Cell(
                $cell_x,
                $cell_y,
                self::calcolaVotoSimulato($studente, $this->infoParametro[1] + $i * $this->infoParametro[3]),
                1,
                1,
                'C'
            );
        }

        $x = $xIniziale;
        $y = $yIniziale + ((min($numRighe, $righePerColonna)) * $cell_y);
        $pdf->SetXY($x, $y);
    }

    /**
     * Funzione che simula il voto di laurea dello studente quando il parametro vale valoreParametro
     * @param CarrieraStudente|CarrieraInformatico $studente
     * @param float $valoreParametro
     * @return float
     */
    private function calcolaVotoSimulato(CarrieraStudente|CarrieraInformatico $studente, float $valoreParametro): float
    {
        $formula = $this->formula;
        $formula = preg_replace('/\bM\b/', $studente->media, $formula);
        $formula = preg_replace('/\bT\b/', $this->infoParametro[0] === 'T' ? $valoreParametro : '0', $formula);
        $formula = preg_replace('/\bC\b/', $this->infoParametro[0] === 'C' ? $valoreParametro : '0', $formula);
        $formula = preg_replace('/\bCFU\b/', $this->cfuCorso, $formula);

        return eval("return round($formula,3);");
    }

    /**
     * Funzione che aggiunge il messaggio specifico per corsoDiLaurea nel prospetto
     * @param fpdf $pdf
     * @return void
     */
    private function addMessaggioProspetto(fpdf $pdf): void
    {
        $pdf->Ln(3);
        $cell_x = ($pdf->GetPageWidth() - 22);
        $cell_y = 6;

        $pdf->multicell($cell_x, $cell_y, "VOTO DI LAUREA FINALE: " . $this->messaggioProspetto, 0, 1);
    }
}

?>
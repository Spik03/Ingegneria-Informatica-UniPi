<?php

require_once __DIR__ . "/../lib/fpdf184/fpdf.php";
require_once __DIR__ . "/CarrieraStudente.php";
require_once __DIR__ . "/CarrieraInformatico.php";

class ProspettoStudente
{
    public string $dataAppello;
    public bool $informatico;
    private string $font;
    private string $formula;
    private int $cfuCorso;
    private string $test;

    /**
     * Costruttore di ProspettoStudente
     * @param string $dataAppello
     * @param bool $test
     */
    public function __construct(string $dataAppello, bool $test = false)
    {
        $this->dataAppello = $dataAppello;
        $this->font = "Arial";
        $this->test = $test;
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
     * Funzione che si occupa di richiamare le funzioni per generare il prospettoStudente
     * @param CarrieraStudente|CarrieraInformatico $studente
     * @return void
     */
    public function generaProspettoStudente(CarrieraStudente|CarrieraInformatico $studente): void
    {
        $pdf = new FPDF();
        $this->formula = self::getInformazioneCorso($studente->corsoDiLaurea, "Formula");
        $this->cfuCorso = self::getInformazioneCorso($studente->corsoDiLaurea, "CFU");

        self::creaProspettoStudente($studente, $pdf);

        self::salvaProspettoStudente($studente, $pdf);
    }

    /**
     * Funzione che si occupa di salvare il ProspettoStudente
     * @param CarrieraStudente|CarrieraInformatico $studente
     * @param fpdf $pdf
     * @return void
     */
    private function salvaProspettoStudente(CarrieraStudente|CarrieraInformatico $studente, fpdf $pdf): void
    {
        if (!file_exists(__Dir__ . "/../" . ($this->test ? "test" : "data") . "/{$studente->corsoDiLaurea}")) {
            mkdir(__Dir__ . "/../" . ($this->test ? "test" : "data") . "/{$studente->corsoDiLaurea}", 0777, true);
        }
        $pdf->Output(
            "F",
            __Dir__ . "/../" . ($this->test ? "test" : "data") . "/{$studente->corsoDiLaurea}/{$studente->matricola}_prospetto.pdf"
        );
    }

    /**
     * Funzione che si occupa di creare il prospettoStudente
     * @param CarrieraStudente|CarrieraInformatico $studente
     * @param fpdf $pdf
     * @return void
     */
    public function creaProspettoStudente(CarrieraStudente|CarrieraInformatico $studente, fpdf $pdf): void
    {
        $this->informatico = ($studente instanceof CarrieraInformatico);

        $pdf->setMargins(11, 8);
        $pdf->setFont($this->font, "", 16);

        $pdf->addPage();

        $pdf->cell(0, 8, $studente->corsoDiLaurea, 0, 1, "C");
        $pdf->Ln(1);
        $pdf->cell(0, 8, "CARRIERA E SIMULAZIONE DEL VOTO DI LAUREA", 0, 1, "C");
        $pdf->Ln(3);

        self::addAnagrafica($studente, $pdf);
        self::addTabellaEsami($studente, $pdf);
        self::addTabellaMedia($studente, $pdf);
    }

    /**
     * Funzione che si occupa di aggiungere le informazioni anagrafiche
     * al prospetto
     * @param CarrieraStudente|CarrieraInformatico $studente
     * @param fpdf $pdf
     * @return void
     */
    private function addAnagrafica(CarrieraStudente|CarrieraInformatico $studente, fpdf $pdf): void
    {
        $pdf->setFontSize(11);
        $cell_x = 45;
        $cell_y = 6;

        $pdf->rect(
            $pdf->GetX(),
            $pdf->GetY(),
            $pdf->GetPageWidth() - 22,
            ($this->informatico ? $cell_y * 6 : $cell_y * 5)
        );
        $pdf->cell($cell_x, $cell_y, "Matricola", 0, 0, "L");
        $pdf->cell(0, $cell_y, $studente->matricola, 0, 1, "L");
        $pdf->cell($cell_x, $cell_y, "Nome:", 0, 0, "L");
        $pdf->cell(0, $cell_y, $studente->nome, 0, 1, "L");
        $pdf->cell($cell_x, $cell_y, "Cognome:", 0, 0, "L");
        $pdf->cell(0, $cell_y, $studente->cognome, 0, 1, "L");
        $pdf->cell($cell_x, $cell_y, "Email:", 0, 0, "L");
        $pdf->cell(0, $cell_y, $studente->email, 0, 1, "L");
        $pdf->cell($cell_x, $cell_y, "Data:", 0, 0, "L");
        $pdf->cell(0, $cell_y, $this->dataAppello, 0, 1, "L");
        if ($this->informatico) {
            $pdf->cell($cell_x, $cell_y, "Bonus:", 0, 0, "L");
            $pdf->cell(0, $cell_y, ($studente->bonus ? "SI" : "NO"), 0, 1, "L");
        }

        $pdf->Ln(2);
    }

    /**
     * Funzione che si occupa di aggiungere la tabella degli esami al prospetto
     * @param CarrieraStudente|CarrieraInformatico $studente
     * @param fpdf $pdf
     * @return void
     */
    private function addTabellaEsami(CarrieraStudente|CarrieraInformatico $studente, fpdf $pdf): void
    {
        $esami = $studente->esami;
        $cell_x = (($pdf->GetPageWidth() - 22) / 15);
        $cell_y = 4;
        $firstColumn_x = $cell_x * 11 + ($this->informatico ? 0 : $cell_x);

        $pdf->setFontSize(10);
        $pdf->cell($firstColumn_x, 5, "ESAME", 1, 0, "C");
        $pdf->cell($cell_x, 5, "CFU", 1, 0, "C");
        $pdf->cell($cell_x, 5, "VOT", 1, 0, "C");
        $pdf->cell($cell_x, 5, "MED", 1, ($this->informatico ? 0 : 1), "C");
        if ($this->informatico) {
            $pdf->cell($cell_x, 5, "INF", 1, 1, "C");
        }

        $pdf->setFontSize(9);
        $cfuCurriculari = $studente->cfuCurriculari;
        foreach ($esami as $esame) {
            $evidenzia = ($cfuCurriculari > $this->cfuCorso && $esame->isMedia() && !$esame->piano);
            $pdf->SetFillColor(255, 255, 0);
            $pdf->cell($firstColumn_x, $cell_y, $esame->nomeEsame, 1, 0, "L", $evidenzia);
            $pdf->cell($cell_x, $cell_y, $esame->CFU, 1, 0, "C", $evidenzia);
            $pdf->cell($cell_x, $cell_y, $esame->voto, 1, 0, "C", $evidenzia);
            $pdf->cell($cell_x, $cell_y, ($esame->isMedia() ? "X" : " "), 1, ($this->informatico ? 0 : 1), "C", $evidenzia);
            if ($this->informatico) {
                $pdf->cell($cell_x, $cell_y, ($esame->isInformatico() ? "X" : " "), 1, 1, "C", $evidenzia);
            }
        }

        $pdf->Ln(2);
    }

    /**
     * Funzione che si occupa di aggiungere al prospetto la tabella contenente informazioni
     * quali la media, i CFU richiesti, quelli acquisiti...
     * @param CarrieraStudente|CarrieraInformatico $studente
     * @param fpdf $pdf
     * @return void
     */
    private function addTabellaMedia(CarrieraStudente|CarrieraInformatico $studente, fpdf $pdf): void
    {
        $pdf->setFontSize(11);
        $cell_x = 75;
        $cell_y = 6;

        $pdf->rect(
            $pdf->GetX(),
            $pdf->GetY(),
            $pdf->GetPageWidth() - 22,
            ($this->informatico ? $cell_y * 6 : $cell_y * 4)
        );

        $pdf->cell($cell_x, $cell_y, "Media Pesata (M):", 0, 0, "L");
        $pdf->cell($cell_x, $cell_y, round($studente->media, 3), 0, 1, "L");
        $pdf->cell($cell_x, $cell_y, "Crediti che fannno media(CFU):", 0, 0, "L");
        $pdf->cell($cell_x, $cell_y, $studente->cfuMedia, 0, 1, "L");
        $pdf->cell($cell_x, $cell_y, "Crediti curriculari conseguiti:", 0, 0, "L");
        self::addCellaCFU($pdf, $cell_x, $cell_y, $studente->cfuCurriculari);
        if ($this->informatico) {
            $pdf->cell($cell_x, $cell_y, "Voto di tesi (T):", 0, 0, "L");
            $pdf->cell($cell_x, $cell_y, 0, 0, 1, "L");
        }
        $pdf->cell($cell_x, $cell_y, "Formula calcolo voto di laurea:", 0, 0, "L");
        $pdf->cell($cell_x, $cell_y, $this->formula, 0, 1, "L");
        if ($this->informatico) {
            $pdf->cell($cell_x, $cell_y, "Media Pesata esami INF:", 0, 0, "L");
            $pdf->cell($cell_x, $cell_y, round($studente->mediaInformatica, 3), 0, 1, "L");
        }

        $pdf->Ln(1);
    }

    /**
     * Funzione che serve per aggiungere nella tabellaMedia
     * la cella contenente il numero di CFU curriculari acquisiti
     * e di evidenziarli nel caso non fossero conformi a quelli richiesti
     * @param fpdf $pdf
     * @param float $cell_x
     * @param float $cell_y
     * @param int $cfuCurriculari
     * @return void
     */
    private function addCellaCfu(fpdf $pdf, float $cell_x, float $cell_y, int $cfuCurriculari): void
    {
        $testo = $cfuCurriculari . "/" . $this->cfuCorso;
        if ($cfuCurriculari !== $this->cfuCorso) {
            $this->evidenzia($pdf, $cell_y, $testo);
        }
        $pdf->cell($cell_x, $cell_y, $testo, 0, 1, "L");
    }

    /**
     * funzione che permette di evidenziare uno spazio
     * @param fpdf $pdf
     * @param float $cell_y
     * @param string $testo
     * @return void
     */
    private function evidenzia(fpdf $pdf, float $cell_y, string $testo): void
    {
        $larghezzaTesto = $pdf->GetStringWidth($testo);
        $pdf->SetFillColor(255, 255, 0);
        $pdf->Rect($pdf->GetX() + 1, $pdf->GetY(), $larghezzaTesto, $cell_y, "F");
    }

}

?>
<?php

class CarrieraInformatico extends CarrieraStudente
{
    public bool $bonus;
    public float $mediaInformatica;

    /**
     * Costruttore della classe CarrieraInformatico
     * Richiama il costruttore della classe padre CarrieraStudente
     * @param string $matricola
     * @param string $nome
     * @param string $cognome
     * @param string $email
     * @param string $corsoDiLaurea
     */
    public function __construct(string $matricola, string $nome, string $cognome, string $email, string $corsoDiLaurea)
    {
        parent::__construct($matricola, $nome, $cognome, $email, $corsoDiLaurea);
        $this->bonus = false;
    }

    /**
     * Funzione che imposta il bonus a true se lo studente
     * rispetta i requisiti: dataLaurea <= (dataIscrizione + 1 anno e 6 mesi)
     * @param string $dataIscrizione
     * @param string $dataLaurea
     * @return void
     */
    public function setBonus(string $dataIscrizione, string $dataLaurea): void
    {
        try {
            $date1 = DateTime::createFromFormat('Y-d-m', $dataLaurea);
            $date2 = DateTime::createFromFormat('m/d/Y', $dataIscrizione);
            $diff = $date1->diff($date2);
            $mesiCarriera = ($diff->y * 12) + $diff->m;
        } catch (Exception $e) {
            echo "Errore con le date: " . $e->getMessage();
            return;
        }
        if ($mesiCarriera <= (3 * 12 + 6)) {
            $this->bonus = true;
        }
    }

    /**
     * Funzione che calcola e imposta:
     *  media: la Media Pesata per CFU
     *  cfuMedia: I CFU che fanno media
     *  mediaInformatica: la media Pesata dei soli esami informatici
     *  cfuCurriculari: Il numero di CFU Curriculari
     *
     * Tiene conto del Bonus
     * @return void
     */
    public function calcolaMediaECFU(): void
    {
        $media = 0;
        $cfu = 0;
        $esameScarto = null;

        $mediaInformatica = 0;
        $cfuInformatico = 0;

        foreach ($this->esami as $esame) {
            if ($esame->isMedia()) {
                $media += $esame->voto * $esame->CFU;
                $cfu += $esame->CFU;

                if ($this->bonus && ($esameScarto === null || $esame->voto < $esameScarto->voto)) {
                    $esameScarto = $esame;
                } elseif ($this->bonus && $esame->voto === $esameScarto->voto && $esame->CFU > $esameScarto->CFU) {
                    $esameScarto = $esame;
                }
                if ($esame->isInformatico()) {
                    $mediaInformatica += $esame->voto * $esame->CFU;
                    $cfuInformatico += $esame->CFU;
                }
            }
            if ($esame->curriculare) {
                $this->cfuCurriculari += $esame->CFU;
            }
        }

        if ($this->bonus) {
            $esameScarto->faMedia = false;
            $media -= $esameScarto->voto * $esameScarto->CFU;
            $cfu -= $esameScarto->CFU;
        }

        $this->media = ($cfu !== 0 ? $media / $cfu : 0);
        $this->mediaInformatica = ($cfuInformatico !== 0 ? $mediaInformatica / $cfuInformatico : 0);
        $this->cfuMedia = $cfu;
    }
}

?>
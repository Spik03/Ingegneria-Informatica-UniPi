<?php

class EsameStudente
{
    public string $nomeEsame;
    public int $voto;
    public int $CFU;
    public bool $faMedia;
    public bool $curriculare;
    public bool $piano;

    /**
     * Costruttore della classe EsameStudente
     * @param string $nomeEsame
     * @param string|null $voto
     * @param int $CFU
     * @param int $curriculare
     * @param string $studenteCorsoDiLaurea
     */
    public function __construct(
        string $nomeEsame,
        string|null $voto,
        int $CFU,
        int $curriculare,
        string $studenteCorsoDiLaurea,
        bool $piano
    ) {
        $this->nomeEsame = $nomeEsame;
        $this->voto = self::setVoto($voto, $studenteCorsoDiLaurea);
        $this->CFU = $CFU;
        $this->faMedia = ($voto !== null && $voto !== "null");
        $this->curriculare = ($curriculare === 0);
        $this->piano = $piano;
    }

    /**
     * Ritorna true se l'esame è presente nella lista di esami informatici
     * del json di configurazione
     * @return bool
     */
    public function isInformatico(): bool
    {
        $json = file_get_contents(__Dir__ . "/../config/config.json");
        $data = json_decode($json, true);

        if ($data === null) {
            die("Errore nella codifica del JSON di configurazione per gli esami informatici");
        }

        $esameInformatico = $data["CarrieraInformatica"]["Esami"];
        // se un esame viene scartato per via del bonus, non va contato nella media degli esami informatici
        return in_array($this->nomeEsame, $esameInformatico) && $this->isMedia();
    }

    /**
     * Torna un valore booleano in base al fatto che l'esame debba essere tenuto
     * di conto per il calcolo della media
     *
     * note:
     * faMedia controlla che il voto non sia null/0, ma non che l'esame sia curriculare
     * per essere contato nella media, deve anche essere curriculare
     * @return bool
     */
    public function isMedia(): bool
    {
        return $this->faMedia && $this->curriculare;
    }

    /**
     * Setta il valore del voto in una notazione numerica.
     * In caso di "30  e lode" il valore numerico viene ottenuto dal file json di configurazione.
     * Se il voto è null, viene impostato a 0.
     * @param string|null $voto
     * @param string $studenteCorsoDiLaurea
     * @return int
     */
    private function setVoto(string|null $voto, string $studenteCorsoDiLaurea): int
    {
        if ($voto !== "30  e lode") {
            return ($voto !== null && $voto !== "null") ? $voto : 0;
        } else {
            $json = file_get_contents(__Dir__ . "/../config/config.json");
            $data = json_decode($json, true);

            if ($data === null) {
                die("Errore nella codifica del JSON di configurazione per il voto della lode");
            }

            return $data["InformazioniCorso"][$studenteCorsoDiLaurea]["Lode"];
        }
    }

}

?>
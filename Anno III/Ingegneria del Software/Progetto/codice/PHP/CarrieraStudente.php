<?php

include_once __DIR__ . "/EsameStudente.php";

class CarrieraStudente
{
    public string $matricola;
    public string $nome;
    public string $cognome;
    public string $corsoDiLaurea;
    public string $email;

    public array $esami;
    public int $numEsame;
    public float $media;
    public int $cfuMedia;
    public int $cfuCurriculari;

    /**
     * Costruttore della classe CarrieraStudente
     * @param string $matricola
     * @param string $nome
     * @param string $cognome
     * @param string $email
     * @param string $corsoDiLaurea
     */
    public function __construct(string $matricola, string $nome, string $cognome, string $email, string $corsoDiLaurea)
    {
        $this->matricola = $matricola;
        $this->nome = $nome;
        $this->cognome = $cognome;
        $this->email = $email;
        $this->esami = [];
        $this->corsoDiLaurea = $corsoDiLaurea;
        $this->numEsame = 0;
        $this->cfuCurriculari = 0;
    }

    /**
     * Aggiunge un esame al vettore degli esami
     * dello studente
     * @param EsameStudente $esame
     * @return void
     */
    public function addEsame(EsameStudente $esame): void
    {
        $this->esami[$this->numEsame] = $esame;
        $this->numEsame++;
    }

    /**
     * Funzione che calcola e imposta:
     *  media: la Media Pesata per CFU
     *  cfuMedia: I CFU che fanno media
     *  cfuCurriculari: Il numero di CFU Curriculari
     * @return void
     */
    public function calcolaMediaECFU(): void
    {
        $media = 0;
        $cfu = 0;
        foreach ($this->esami as $esame) {
            if ($esame->isMedia()) {
                $media += $esame->voto * $esame->CFU;
                $cfu += $esame->CFU;
            }
            if ($esame->curriculare) {
                $this->cfuCurriculari += $esame->CFU;
            }
        }
        $this->media = ($cfu !== 0 ? $media / $cfu : 0);
        $this->cfuMedia = $cfu;
    }

}

?>
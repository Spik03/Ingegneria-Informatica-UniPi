<?php

require_once __DIR__ . "/EsameStudente.php";
require_once __DIR__ . "/CarrieraStudente.php";
require_once __DIR__ . "/CarrieraInformatico.php";

class GestioneCarrieraStudente
{
    /**
     * Funzione che ritorna un oggetto di tipo carrieraStudente / Informatico,
     *  completo di Carriera.
     * Ricava i dati anagrafici dal file json/xxxxxx_anagrafica.json
     * @param string $matricola
     * @param string $corsoDiLaurea
     * @param string $dataLaurea
     * @return CarrieraInformatico|CarrieraStudente
     */
    public static function ottieniAnagraficaStudente(
        string $matricola,
        string $corsoDiLaurea,
        string $dataLaurea
    ): CarrieraInformatico|CarrieraStudente {
        $path = __Dir__ . "/../json/{$matricola}_anagrafica.json";
        if (!file_exists($path)) {
            die("Errore di creazione");
        }

        $json = file_get_contents($path);
        $data = json_decode($json, true);

        if ($data === null) {
            die("Errore nella codifica del JSON dell'anagrafica");
        }
        $entry = $data["Entries"]["Entry"];

        if (self::isInformatico($corsoDiLaurea)) {
            $studente = new CarrieraInformatico(
                $matricola,
                $entry["nome"],
                $entry["cognome"],
                $entry["email_ate"],
                $corsoDiLaurea
            );
        } else {
            $studente = new CarrieraStudente(
                $matricola,
                $entry["nome"],
                $entry["cognome"],
                $entry["email_ate"],
                $corsoDiLaurea
            );
        }

        self::ottieniCarrieraStudente($studente, $corsoDiLaurea, $dataLaurea);

        return $studente;
    }

    /**
     * Funzione che inserisce gli esami di uno studente nel suo vettore esame.
     * Gli esami vengono inseriti in maniera ordinata in base alla data di superamento.
     * Una volta inseriti gli esami viene richiamato la funzione di studente: calcolaMediaECfu().
     * Ricava gli esami dal file json/xxxxxx_esami.json
     * @param CarrieraStudente|CarrieraInformatico $studente
     * @param string $corsoDiLaurea
     * @param string $dataLaurea
     * @return void
     */
    private static function ottieniCarrieraStudente(
        CarrieraStudente|CarrieraInformatico $studente,
        string $corsoDiLaurea,
        string $dataLaurea
    ): void {
        $json = file_get_contents(__Dir__ . "/../json/{$studente->matricola}_esami.json");
        $data = json_decode($json, true);

        if ($data === null) {
            die("Errore nella codifica del JSON degli esami");
        }

        $esame = $data["Esami"]["Esame"];

        usort($esame, function ($a, $b) {
            if (is_array($a["DATA_ESAME"]) || is_array($b["DATA_ESAME"])) {
                return 0;
            }

            $data1 = DateTime::createFromFormat('d/m/Y', $a["DATA_ESAME"]);
            $data2 = DateTime::createFromFormat('d/m/Y', $b["DATA_ESAME"]);

            if ($data1 === null && $data2 === null) {
                return 0;
            } elseif ($data1 === null) {
                return -1;
            } elseif ($data2 === null) {
                return 1;
            }

            return $data1 <=> $data2;
        });

        foreach ($esame as $e) {
            if (self::nonInCarriera($studente->matricola, $corsoDiLaurea, $e["DES"]) || is_array($e["DES"]) || is_array(
                    $e["VOTO"]
                ) || is_array($e["PESO"]) || is_array($e["SOVRAN_FLG"])) {
                continue;
            }
            $piano = (!isset($e["PIANO"]["@nil"]) && $e["PIANO"] === "Y");
            $studente->addEsame(
                new EsameStudente($e["DES"], $e["VOTO"], $e["PESO"], $e["SOVRAN_FLG"], $corsoDiLaurea, $piano)
            );
        }

        if ($studente instanceof CarrieraInformatico) {
            $studente->setBonus($esame[0]["INIZIO_CARRIERA"], $dataLaurea);
        }

        $studente->calcolaMediaECFU();
    }

    /**
     * Funzione che ritorna l'email della matricola richiesta.
     * Ricava la mail dal file json/xxxxxx_anagrafica.json
     * @param string $matricola
     * @return string
     */
    public static function ottieniEmailStudente(string $matricola): string
    {
        $json = file_get_contents(__Dir__ . "/../json/{$matricola}_anagrafica.json");
        $data = json_decode($json, true);

        if ($data === null) {
            die("Errore nella codifica del JSON per l'anagrafica");
        }
        $entry = $data["Entries"]["Entry"];

        return $entry["email_ate"];
    }

    /**
     * Ritorna true se il corso di laurea è presente nella lista dei corsi informatici
     *  del json di configurazione.
     * @param string $corsoDiLaurea
     * @return bool
     */
    private static function isInformatico(string $corsoDiLaurea): bool
    {
        $json = file_get_contents(__Dir__ . "/../config/config.json");
        $data = json_decode($json, true);

        if ($data === null) {
            die("Errore nella codifica del JSON di configurazione per i corsi informatici");
        }
        $nomeCorsoInformatico = $data["CarrieraInformatica"]["Corso"];

        return in_array($corsoDiLaurea, $nomeCorsoInformatico);
    }

    /**
     * Ritorna true se l'esame non è da considerare come un esame della carriera del corso di laurea
     * dello studente.
     * Questa informazione è ricavata dal file json di configurazione.
     * @param string $matricola
     * @param string $corsoDiLaurea
     * @param string $esame
     * @return bool
     */
    private static function nonInCarriera(string $matricola, string $corsoDiLaurea, string|array $esame): bool
    {
        $json = file_get_contents(__Dir__ . "/../config/config.json");
        $data = json_decode($json, true);

        if ($data === null) {
            die("Errore nella codifica del JSON di configurazione per gli esami non in carriera");
        }

        $esamiNonInCarriera = $data["InformazioniCorso"][$corsoDiLaurea]["EsamiNonInCarriera"]["all"];

        if (array_key_exists($matricola, $data["InformazioniCorso"][$corsoDiLaurea]["EsamiNonInCarriera"])) {
            $esamiNonInCarrieraPersonale = $data["InformazioniCorso"][$corsoDiLaurea]["EsamiNonInCarriera"][$matricola];
            return in_array($esame, $esamiNonInCarriera) || in_array($esame, $esamiNonInCarrieraPersonale);
        }

        return in_array($esame, $esamiNonInCarriera);
    }
}

?>
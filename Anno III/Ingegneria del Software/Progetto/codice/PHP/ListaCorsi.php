<?php

$jsonData = file_get_contents("../config/config.json");
$data = json_decode($jsonData, true);
if (isset($data["InformazioniCorso"])) {
    $corsiDiLaurea = $data["InformazioniCorso"];
    foreach (array_keys($corsiDiLaurea) as $corso) {
        echo "<option value='" . $corso . "'>" . $corso . "</option>";
    }
} else {
    echo "<option disabled>Errore nel caricamento dei corsi</option>";
}
?>

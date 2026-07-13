<html lang="it">
<head>
    <meta charset='utf-8'>
    <meta http-equiv='X-UA-Compatible' content='IE=edge'>
    <title>Laureandosi</title>
    <meta name='viewport' content='width=device-width, initial-scale=1'>

    <link rel="stylesheet" type="text/css" href="../CSS/style.css">
    <script src="../JScript/AjaxRequester.js"></script>
    <script src="../JScript/ApriProspetti.js"></script>
</head>
<body>
<div id="main">
    <div>
        <p id="title">Gestione Prospetti di Laurea</p>
    </div>
    <div id="container">
        <div class="column lateral">
            <p id="cdl_titolo">CdL:</p>
            <select id="cdLSelezione">
                <option value="" disabled selected>Seleziona un CdL</option>
                <?php
                include("../PHP/ListaCorsi.php"); ?>
            </select>
            <p id="data_container">Data Laurea: <input type="date" id="data" name="data"></p>
        </div>
        <div class="column" id="center">
            <p id="matricole_titolo">Matricole:</p>
            <textarea id="matricole" name="matricole" wrap="soft"></textarea>
        </div>
        <div class="column lateral">
            <button class="crea_invia bottone" id="crea" onclick="creazioneProspetti()">Crea Prospetti</button>
            <button class="bottone" id="apri" onclick="apriProspetti()">apri prospetti</button>
            <button class="crea_invia bottone" id="invia" onclick="invioProspetti()">Invia Prospetti</button>
            <p id="info"></p>
        </div>
    </div>
</div>
</body>
</html>
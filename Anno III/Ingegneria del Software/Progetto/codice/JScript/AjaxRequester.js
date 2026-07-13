/**
 *  Funzione che genera la richiesta Ajax
 *  ed elabora la risposta ottenuta
 *  per la Creazione dei Prospetti
 */
function creazioneProspetti() {
    const dati = {
        "function": "creazioneProspetti",
        "CdL": document.getElementById("cdLSelezione").value,
        "dataAppello": document.getElementById("data").value,
        "matricole": document.getElementById("matricole").value,
    };
    if (Object.values(dati).some(valore => valore === null || valore === "")) {
        document.getElementById("info").innerText = "Seleziona CdL, Data Laurea e inserisci Matricole";
        return;
    }
    const xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (this.readyState === 4 && this.status === 200) {
            document.getElementById("info").innerHTML = this.responseText;
        }
    };
    xmlhttp.open("POST", "../PHP/AjaxHandler.php", true);
    xmlhttp.setRequestHeader("Content-Type", "application/json");
    xmlhttp.send(JSON.stringify(dati));
}

/**
 *  Funzione che genera la richiesta Ajax
 *  ed elabora la risposta ottenuta
 *  per l'Invio dei Prospetti
 */
async function invioProspetti() {
    let matricole = generaVettoreMatricole(document.getElementById("matricole").value);
    const corsoDiLaurea = document.getElementById("cdLSelezione").value;
    let num = 1;
    let valido = true;
    if ((corsoDiLaurea === null || corsoDiLaurea === "") || (matricole.length === 0)) {
        document.getElementById("info").innerText = "Seleziona CdL e inserisci Matricole";
        return;
    }
    for (const matricola of matricole) {
        const dati = {
            "function": "invioProspetti",
            "CdL": corsoDiLaurea,
            "matricola": matricola
        };

        const xmlhttp = new XMLHttpRequest();
        xmlhttp.onreadystatechange = function () {
            if (this.readyState === 4 && this.status === 200) {
                if (this.response)
                    document.getElementById("info").innerText = "Inviato prospetti " + num + "/" + matricole.length;
                else {
                    document.getElementById("info").innerText = "Errore invio prospetto " + num + "/" + matricole.length;
                    valido = false;
                }
                num++;
            }
        };
        if (!valido)
            break;
        xmlhttp.open("POST", "../PHP/AjaxHandler.php", true);
        xmlhttp.setRequestHeader("Content-Type", "application/json");
        xmlhttp.send(JSON.stringify(dati));

        await aspetta(3);
    }
}

/**
 * Data una stringa in cui sono presenti delle matricole (o più in generale, dei codici numerici)
 * Separati da spazi o virgole
 * Ritorna un vettore dei singoli elementi
 * @param listaMatricole
 * @returns {string[]}
 */
function generaVettoreMatricole(listaMatricole) {
    const listaPulita = listaMatricole.replace(/[^0-9\s]/g, '').trim();
    const matricole = listaPulita.trim().split(/[,\s]+/);
    return matricole.filter(matricola => matricola !== '');
}

/**
 * Funzione che permette di sospendere l'esecuzionedel codice per
 * un tempo (in secondi) passato in ingresso
 * Va chiamata in un await
 * @param secondi
 * @returns {Promise<unknown>}
 */
function aspetta(secondi) {
    return new Promise(resolve => setTimeout(resolve, secondi * 1000));
}

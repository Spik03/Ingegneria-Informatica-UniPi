/**
 * Funzione che permette l'apertura in una pagina web
 * del ProspettoCommissione del corsoDiLaurea selezionato
 * nella pagina web e presente come valore di un elemento che ha come Id
 * "cdLSelezione"
 */
function apriProspetti(){
    const corsoDiLaurea = document.getElementById("cdLSelezione").value;
    if(corsoDiLaurea === null || corsoDiLaurea === "") {
        document.getElementById("info").innerText = "Seleziona CdL";
        return;
    }
    let urlPdf = "/data/"+corsoDiLaurea+"/commissione_prospetto.pdf";
    let timestamp = new Date().getTime();
    let urlPdfSenzaCache = urlPdf + (urlPdf.indexOf('?') === -1 ? '?' : '&') + 't=' + timestamp;
    window.open(urlPdfSenzaCache, '_blank');
}
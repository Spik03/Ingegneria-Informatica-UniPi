/**
 * Funzione che permette l'apertura in una pagina web
 * di un pdf, il cui path / url è passato in ingresso
 */
function apriProspettoTest(urlPdf){
    let timestamp = new Date().getTime();
    let urlPdfSenzaCache = urlPdf + (urlPdf.indexOf('?') === -1 ? '?' : '&') + 't=' + timestamp;
    window.open(urlPdfSenzaCache, '_blank');
}
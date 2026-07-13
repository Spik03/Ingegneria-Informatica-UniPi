'use strict';

document.addEventListener('DOMContentLoaded', function () {
    document.addEventListener('FinePartita', nuovoPunteggio);
});

// funzione per l'inserimento del punteggio fatto
function nuovoPunteggio(){
    let punteggio = document.getElementById("punti");
    let record    = document.getElementById("record");

    if(!punteggio || !record){
        console.error("Elemento punteggio o record non trovato");
        return;
    }

    punteggio = punteggio.innerText;
    nuovoPunteggio_ajax(punteggio);
    

    if(Number(record.innerText) < Number(punteggio)){
        record.innerText = punteggio;
        record.classList.add("newRecord");
    }
}

function nuovoPunteggio_ajax(punteggio){
    fetch('../PHP/insertPunteggio_ajax.php?action=insertPunteggio', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'punteggio=' + encodeURIComponent(punteggio),
    })
        .then(response => response.json())
    .catch(error => console.error('Errore nella richiesta fetch nuovoPunteggio:', error));
}
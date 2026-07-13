'use strict';

document.addEventListener('DOMContentLoaded', classificaGenerale);
document.addEventListener('Classifica', classificaGenerale);

// funzione per l'aggiornamento della classifica (dx)
function classificaGenerale(){
    fetch('../PHP/datiGenerali_ajax.php?action=getClassifica')
        .then(response => response.json())
        .then(classifica => {
            if(classifica.error){
                console.error(classifica.error);
            } else {
                const last  = document.getElementById("last");
               
                const tmp = document.getElementsByClassName("toRemove");
                for(let i=tmp.length-1; i>=0; --i){
                    tmp[i].remove();
                }

                for(let i=0; i<classifica.length; ++i){
                    const row    = document.createElement("tr");
                    const th     = document.createElement("th");
                    const nome   = document.createElement("td");
                    const points = document.createElement("td");

                    row.classList.add("toRemove");
                    th.classList.add("Normale");
                    primiTre(th,nome,points,i);

                    row.appendChild(th);
                    row.appendChild(nome);
                    row.appendChild(points);

                    th.innerText     = (i+1);
                    nome.innerText   = classifica[i].username;
                    points.innerText = classifica[i].punteggio;

                    bordoTabellaGenerale(th, nome, points);

                    last.insertAdjacentElement("beforebegin", row);
                    addSpazioGenerale(last);
                }

                if(classifica.length === 0){
                    addSpazioGenerale(last);
                }
            }
        })
    .catch(error => console.error('Errore nella richiesta fetch ClassificaGenerale:', error));
}

// bordo e radius sono definite in principale.js
function bordoTabellaGenerale(th, td, td2){
    th.style.border = bordo;
    td.style.border = bordo;
    td2.style.border = bordo;

    th.style.borderTopLeftRadius    = radius;
    th.style.borderBottomLeftRadius = radius;
    td2.style.borderTopRightRadius = radius;
    td2.style.borderBottomRightRadius = radius;

    th.style.borderRight = "0";
    td.style.borderLeft = "0";
    td.style.borderRight = "0";
    td2.style.borderLeft = "0";
}

function addSpazioGenerale(last) {
    const spazio = document.createElement("tr");
    spazio.appendChild(document.createElement("td"));

    spazio.classList.add("toRemove");
    spazio.firstChild.classList.add("Spazio");

    spazio.firstChild.setAttribute("colspan",3);
    last.insertAdjacentElement("beforebegin", spazio);
}

function primiTre(th, nome, points, i){
    if(i<3){
        th.classList.add(("c"+i));
        nome.classList.add(("c"+i));
        points.classList.add(("c"+i));
    }
}
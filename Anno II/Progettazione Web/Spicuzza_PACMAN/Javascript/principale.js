'use strict';

// 0 movimento / oggetti possibile
// 1 muro
// 2 vuoto / fuori mappa
// 3 cancello
// 4 fine tunnel / effetto pac-man
// 5 Pillola
// 6 Tunnel
// P pm_spawn   //pacman
// R R_spawn    //fantasma rosso
// B B_spawn    //fantasma blu
// V P_spawn    //fantasma rosa (sia P che R erano già stati usati)
// O O_spawn    //fantasma arancione (Orange)
const map = [
    '2222222222222222222222222',
    '2111111111111111111111112',
    '2100000000001000000000012',
    '2101110111101011110111012',
    '2100000000000000000000012',
    '2151110101111111010111512',
    '2100000100001000010000012',
    '2111110111101011110111112',
    '222221010000R000010122222',
    '2111110101113111010111112',
    '46666600012BVO21000666664',
    '2111110101111111010111112',
    '222221010000P000010122222',
    '2111110101111111010111112',
    '2100000000001000000000012',
    '2151110111101011110111512',
    '2100010000000000000100012',
    '2101010101111111010101012',
    '2100000000000000000000012',
    '2111111111111111111111112',
    '2222222222222222222222222'
];
const larghezza = map[0].length;
const altezza = map.length;
const bordo = "4px solid blue";
const radius = "10px";

const pg = ["P", "R", "B", "V", "O"];
const pm_spawn = [12, 12];
const gs_spawn = [[8, 12], [10, 12], [10, 11], [10, 13]];
// pos attuale di pacman
let pm_pos = [12, 12];
// pos attuale dei fantasmi
let gs_pos = [[8, 12], [10, 12], [10, 11], [10, 13]];

//gs_ps => possibili stati dei fantasmi
const gs_ps = ["Vivo", "Morto", "Vulnerabile"];
const gs_stato = [gs_ps[0], gs_ps[0], gs_ps[0], gs_ps[0]];
let timer_vlnr = [5]; // i primi 4 sono dei fantasmi, il quinto del timer a schermo
let timer_morto = [4];
const tempi_respawn = [2500, 3000, 4000, 5000];
const punti_gs = [50, 40, 30, 20, 10];
const tempo_vlnr = [7500, 7500];
let vlnr_about_end = false; // è quasi finita la vulnerabilità

const frutta = ["Arancia", "Ciliegia", "Fragola", "Mela", "Melone", "Galassia", "Campana", "Key"];
const punti_F = [20, 30, 40, 50, 60, 70, 80, 90];
let timer_F;
const tempo_spawn_F = 20000;

const simbolo_punto = '\u2B24';
const punto = 1;   // per le pillole/vitamine: punto*5
let puntiRimasti = 0;

let gioco = false;
let fine  = false;
let regoleOnScreen = false;
let mangiato = false;
let movimento = "";
let timer = 0;
let punteggio = 0;
let dialog;

// Schermata di gioco

// Inizialziza la schermata di gioco
function inizializza() {
    creaTabellaPersonale();
    stileTabellaGenerale();
    creaMappa();
    creaBordi();
    posizionaPunti();
    poisizionaPg();
    posizionaPills();
}

// Crea la tabella personale (sx)
function creaTabellaPersonale() {
    const table = stileTabella("p_table");

    for (let i = 1; i < (pg.length + frutta.length); ++i) {
        addSpazio(table);
        const row = document.createElement("tr");
        const th = document.createElement("th");
        const td = document.createElement("td");
        if (i < pg.length) {
            th.classList.add(pg[i]);
            td.setAttribute("id", pg[i]);
        } else {
            th.classList.add(frutta[i - pg.length]);
            td.setAttribute("id", frutta[i - pg.length]);
            th.classList.add("PersonaleFrutta");
        }
        bordoTabellaPersonale(th, td);
        td.innerText = 0;
        row.appendChild(th);
        row.appendChild(td);
        table.appendChild(row);
    }
}

// Assegna lo stile alla tabella generale (dx)
function stileTabellaGenerale(){
    const table = stileTabella("g_table");
}

// crea la mappa di gioco
function creaMappa() {
    const table = document.getElementById("mappa");

    for (let i = 1; i < altezza - 1; ++i) {
        const row = document.createElement("tr");
        for (let j = 1; j < larghezza - 1; ++j) {
            const cella = document.createElement("td");
            cella.classList.add("Cella");
            switch (map[i][j]) {
                case '1':
                    cella.classList.add("Muro");
                    break;
                case '0':
                    cella.classList.add("PossibileSpawnFrutta");
                //Essendo che nel tunnel non possono entrare i fantasmi,
                //non faccio spawnare lì la frutta per questioni di bilanciamento
                case '6':
                    cella.classList.add("Punto");
                    break;
                case '5':
                    cella.classList.add("Pillola");
                    break;
                case '3':
                    cella.classList.add("Cancello");
                default:
                    break;
            }
            cella.setAttribute("id", i * larghezza + j);
            row.appendChild(cella);
        }
        table.appendChild(row);
    }
}

// crea i bordi / muri della mappa di gioco
function creaBordi() {

    for (let i = 1; i < altezza - 1; ++i) {
        for (let j = 1; j < larghezza - 1; ++j) {

            const cella = document.getElementById(i * larghezza + j);
            if (map[i][j] == 1) {
                if (map[i - 1][j] != 1) { //bordo superiore
                    cella.style.borderTop = bordo;
                }
                if (map[i][j - 1] != 1) { //borde sinistro
                    cella.style.borderLeft = bordo;
                }
                if (map[i + 1][j] != 1) { //bordo inferiore
                    cella.style.borderBottom = bordo;
                }
                if (map[i][j + 1] != 1) { //bordo destro
                    cella.style.borderRight = bordo;
                }
                if (map[i - 1][j] != 1 && map[i][j - 1] != 1) { //top left
                    cella.style.borderTopLeftRadius = radius;
                }
                if (map[i - 1][j] != 1 && map[i][j + 1] != 1) { //top right
                    cella.style.borderTopRightRadius = radius;
                }
                if (map[i + 1][j] != 1 && map[i][j - 1] != 1) { //bot left
                    cella.style.borderBottomLeftRadius = radius;
                }
                if (map[i + 1][j] != 1 && map[i][j + 1] != 1) { //bot right
                    cella.style.borderBottomRightRadius = radius;
                }
            }
        }
    }
}

// posiziona i punti e conta quanti ne sono rimasti
function posizionaPunti() {
    const punto = document.getElementsByClassName("Punto");
    puntiRimasti = 0;
    for (let i = 0; i < punto.length; ++i) {
        if (!Array.from(punto[i].classList).find(cls => pg.includes(cls)) && !punto[i].classList.contains("Pillola")) {
            puntiRimasti++;
            punto[i].innerText = simbolo_punto;
        }
    }
    return puntiRimasti;
}

// posiziona i PG (pacman + 4 fantasmi)
function poisizionaPg() {
    const pacman = document.getElementById(pm_spawn[0] * larghezza + pm_spawn[1]);
    pacman.classList.add(pg[0]);
    pm_pos = [...pm_spawn];

    const fantasma = [4];
    for (let i = 0; i < 4; ++i) {
        fantasma[i] = document.getElementById(gs_spawn[i][0] * larghezza + gs_spawn[i][1]);
        fantasma[i].classList.add(pg[i + 1]);
        gs_pos[i] = [...gs_spawn[i]];
    }
}

// Posiziona le pillole / vitamine
function posizionaPills() {
    const pillola = document.getElementsByClassName("Pillola");
    for (let i = 0; i < pillola.length; ++i) {
        if (!Array.from(pillola[i].classList).find(cls => pg.includes(cls))) {
            pillola[i].innerText = simbolo_punto;
        }
    }
}

// Funzioni di supporto per la Schermata di gioco

// Funzione che assegna lo stile a una tabella "tab" passata
function stileTabella(tab){
    const table = document.getElementById(tab);
    table.style.border = bordo;
    table.style.borderRadius = radius;
    table.style.borderCollapse = "separate";
    return table;
}

// aggiunge una riga vuota alla tabella data
function addSpazio(table) {
    const spazio = document.createElement("tr");
    spazio.appendChild(document.createElement("td"));
    spazio.firstChild.classList.add("Spazio");
    spazio.firstChild.setAttribute("colspan",2);
    table.appendChild(spazio);
}

// dato un th e un td assegna lo stile per il bordo
function bordoTabellaPersonale(th, td) {
    th.style.border = bordo;
    td.style.border = bordo;

    th.style.borderTopRightRadius = radius;
    th.style.borderBottomRightRadius = radius;
    td.style.borderTopRightRadius = radius;
    td.style.borderBottomRightRadius = radius;

    th.style.borderLeft = "0";
    td.style.borderLeft = "0";
}

// Gioco

// Avvia il gioco
function avvia(event) {
    const inizio = document.getElementById("start");
    if(inizio){
        inizio.style.display = "none";
        document.body.removeChild(inizio);
    }

    const regole = document.getElementById("regole");
    if(regole){
        regole.innerText = "Game Started";
        regole.setAttribute("id", "regoleOff");
    }

    gioco = true;
    setMovimentoPacman(event);

    timer_F = setInterval(posizionaFrutta, tempo_spawn_F);
    partita();
};

// posiziona un frutto a caso
function posizionaFrutta() {
    if (!gioco) {
        clearInterval(timer_F);
        return;
    }
    const frutto = frutta[Math.floor(Math.random() * frutta.length)];
    let cella = Array.from(document.getElementsByClassName("PossibileSpawnFrutta"));
    cella = cella.filter(elemento => !elemento.classList.contains("Punto"));

    const random = Math.floor(Math.random() * cella.length);

    if (!Array.from(cella[random].classList).find(cls => pg.includes(cls)) && !Array.from(cella[random].classList).find(cls => frutta.includes(cls))) {
        cella[random].classList.add(frutto);
    }
}

// Regola il funzionamento del gioco
function partita() {
    if (regoleOnScreen) {
        return;
    }
    if (!gioco) {
        operazioniFinali();
        fine  = true;
        gameOverOnScreen();
        clearTimeout(timer);
        clearInterval(timer_F);
        clearTimeout(timer_morto);
        clearTimeout(timer_vlnr);
        clearInterval(timer_vlnr[4]);

        const regole = document.getElementById("regoleOff");
        regole.innerText = "Clicca qui!";
        regole.setAttribute("id", "regole");
        return;
    }

    muoviPG(pg[0], pm_pos, movimento);
    specchiaSprite(pm_pos, movimento);

    for (let i = 1; i < pg.length && !mangiato; ++i) {
        const move = setMovimentoFantasma(gs_pos[i - 1], pg[i]);
        muoviPG(pg[i], gs_pos[i - 1], move);
        specchiaSprite(gs_pos[i - 1], move);
        setClasseStatoFantasma(i - 1);
    }

    if (!mangiato) {
        mangiaPunto();
        mangiaPillola();
        mangiaFrutta();
    }

    if (posizionaPunti() == 0 && !mangiato) {
        gioco = false;
    }

    posizionaPills();
    aggiornaPunteggio();
    timer = setTimeout(partita, 200);
}

// funzione che si occupa del movimento di un pg
// pos = posizione attuale
function muoviPG(_pg, pos, direzione) {
    let next_cella;
    const attuale = document.getElementById(pos[0] * larghezza + pos[1]);
    //evitare problemi di grafica dei pg
    attuale.style.transform = '';

    let move = false;

    switch (direzione) {
        case "U": // Muovi verso l'alto
            if (map[pos[0] - 1][pos[1]] !== '1') {
                next_cella = document.getElementById((pos[0] - 1) * larghezza + pos[1]);
                move = true;
                pos[0]--;
            }
            break;
        case "D": // Muovi verso il basso
            if (map[pos[0] + 1][pos[1]] !== '1' && map[pos[0] + 1][pos[1]] !== '3') {
                next_cella = document.getElementById((pos[0] + 1) * larghezza + pos[1]);
                move = true;
                pos[0]++;
            }
            break;
        case "L": // Muovi verso sinistra
            if (pos[1] > 1 && map[pos[0]][pos[1] - 1] !== '1') {
                next_cella = document.getElementById(pos[0] * larghezza + pos[1] - 1);
                move = true;
                pos[1]--;
            } else if (map[pos[0]][pos[1] - 1] === '4') { //effetto pacman
                pos[1] = larghezza - 2;
                next_cella = document.getElementById(pos[0] * larghezza + pos[1]);
                console.log("Effetto Pacman: ", pos[1]);
                move = true;
            }
            break;
        case "R": // Muovi verso destra
            if (pos[1] < larghezza - 2 && map[pos[0]][pos[1] + 1] !== '1') {
                next_cella = document.getElementById(pos[0] * larghezza + pos[1] + 1);
                move = true;
                pos[1]++;
            } else if (map[pos[0]][pos[1] + 1] === '4') { //effetto pacman
                pos[1] = 1;
                next_cella = document.getElementById(pos[0] * larghezza + pos[1]);
                console.log("Effetto Pacman: ", pos[1]);
                move = true;
            }
            break;
        default:
            break;
    }
    if (move) {
        next_cella.innerText = "";
        next_cella.classList.add(_pg);
        attuale.innerText = "";
        attuale.classList.remove(_pg);
        //se a muoversi è pacman il seguente comando non effettua modifiche,
        //essendo pacman solo 1/5 dei personaggi a muoversi ed essendo che non comporta problemi
        //lasciargli eseguire questo comando, ho preferito rimuovere il controllo di pg ed eseguire
        //in ogni caso:
        attuale.classList.remove("Vulnerabile1");
        attuale.classList.remove("Vulnerabile2");
    }
    //ad ogni movimento di ogni personaggio devo controllare se pacman è stato mangiato
    //per eseguire il controllo in partita() dovrei farlo prima e dopo il movimento di ogni fantasma
    if (gioco) {
        gioco = !collisionePacmanFantasma();
    }
}

/*
    Nel gioco reale i fantasmi hanno tutti una propria logica di movimento, semplificando in poche parole:
        1. si muove sempre in direzione di pacman
        2. si muove verso il Rosso e rincorre pacman quando esso è vicino
        3. cerca di mangiare Pacman "di viso"
        4. si allontana/avvicina a pacman in base a se pacman si avvicina/allontana
    ed inoltre alcuni di loro hanno delle zone che prediligono.
    In questa versione del gioco (la mia) il movimento dei fantasmi è molto semplificata, viene generato casualmente
    con un minimo di logica.
    Inizialmente si genera dei movimenti possibili "intelligenti" (verso pacman)
    e poi si generano i moviventi possibili generali (dunque "stupidi")
    e di tutti questi se ne prende uno casuale.
    Si può notare come un movimento intelligente è più probabile venga scelto
    essendo presente nel vettore 2 volte.
    Il fantasma rosso (logica 1) genera una mossa stupida solo se non può farne di intelligenti (la 
    generazione del movimento intelligente è molto basilare, se pacman e rosso sono allineati e di mezzo
    c'è un muro, rosso non potrebbe muoversi).
    Il fantasma blu (logica 2) semplicemte genera come movimenti intelligenti uno che ha come destinazione
    il fantasma rosso o Pacman in base a quale dei due sia più vicino.
    Sicuramente il tutto è migliorabile, ma funzionale per una versione del gioco basilare.

    La generazione del movimento non tiene conto dell'effetto pacman, per tale motivo non permetto ai fantasmi
    di usufruirne
*/
function setMovimentoFantasma(posizione, fantasma) {
    const possibiliMosse = [];
    const stato = gs_stato[pg.findIndex(f => f === fantasma) - 1];
    if (stato == gs_ps[1]) {
        return;
    }

    const destinazione = getDestinazione(fantasma, stato, posizione);
    movimentoIntelligente(possibiliMosse, posizione, destinazione, stato);

    // fantasma rosso deve muoversi in maniera meno casuale rispetto agli altri
    // se sono vulnerabili preferiscono scappare che generare movimenti casuali
    // se rosso è morto e blu è vivo, si comporta da rosso (logica 1)
    if ((stato != gs_ps[1] && fantasma !== pg[1]) || possibiliMosse.length == 0
        || (fantasma === pg[2] && stato == gs_ps[0] && gs_stato[0] == gs_ps[1] && possibiliMosse.length == 0)) {
        if (map[posizione[0] - 1][posizione[1]] !== '1' && !gs_pos.find(pos => pos[0] === posizione[0] - 1 && pos[1] === posizione[1])) {
            possibiliMosse.push("U"); // Su
        }
        if (map[posizione[0] + 1][posizione[1]] !== '1' && map[posizione[0] + 1][posizione[1]] !== '3'
            && !gs_pos.find(pos => pos[0] === posizione[0] + 1 && pos[1] === posizione[1])) {
            possibiliMosse.push("D"); // Giù
        }
        if (map[posizione[0]][posizione[1] - 1] !== '1' && !gs_pos.find(pos => pos[0] === posizione[0] && pos[1] === posizione[1] - 1)
            && map[posizione[0]][posizione[1] - 1] !== '6') {
            possibiliMosse.push("L"); // Sinistra
        }
        if (map[posizione[0]][posizione[1] + 1] !== '1' && !gs_pos.find(pos => pos[0] === posizione[0] && pos[1] === posizione[1] + 1)
            && map[posizione[0]][posizione[1] + 1] !== '6') {
            possibiliMosse.push("R"); // Destra
        }
    }

    // Scegli casualmente una delle possibili mosse
    const next = possibiliMosse[Math.floor(Math.random() * possibiliMosse.length)];
    return next;
}

// funzione che calcola i possibili movimenti intelligenti (verso la "destinazione")
function movimentoIntelligente(movimento, posizione, destinazione, stato) {
    const distX = destinazione[1] - posizione[1];
    const distY = destinazione[0] - posizione[0];

    //se vulnerabile scappa, sennò si avvicina
    if ((stato == gs_ps[2] ? distY > 0 : distY < 0) && map[posizione[0] - 1][posizione[1]] !== '1' && !gs_pos.find(pos => pos[0] === posizione[0] - 1 && pos[1] === posizione[1])) {
        movimento.push("U"); // Su
    }
    if ((stato == gs_ps[2] ? distY < 0 : distY > 0) && map[posizione[0] + 1][posizione[1]] !== '1' && map[posizione[0] + 1][posizione[1]] !== '3'
        && !gs_pos.find(pos => pos[0] === posizione[0] + 1 && pos[1] === posizione[1])) {
        movimento.push("D"); // Giù
    }
    if ((stato == gs_ps[2] ? distX > 0 : distX < 0) && map[posizione[0]][posizione[1] - 1] !== '1' && !gs_pos.find(pos => pos[0] === posizione[0] && pos[1] === posizione[1] - 1)
        && map[posizione[0]][posizione[1] - 1] !== '6') {
        movimento.push("L"); // Sinistra
    }
    if ((stato == gs_ps[2] ? distX < 0 : distX > 0) && map[posizione[0]][posizione[1] + 1] !== '1' && !gs_pos.find(pos => pos[0] === posizione[0] && pos[1] === posizione[1] + 1)
        && map[posizione[0]][posizione[1] + 1] !== '6') {
        movimento.push("R"); // Destra
    }
}

// dato un fantasma ritorna il suo obbiettivo / destinazione
function getDestinazione(fantasma, stato, posizione) {
    if (isFantasmaInBase(posizione)) {
        //se un fantasma è in base, il suo obbiettivo è uscire da essa
        //lo spawn iniziale del rosso è fuori dalla base (esattamente sopra il cancello)
        return gs_spawn[0];
    }
    // se fantasma è vulnerabile, se il fantasma blu è vivo mentre quello rosso è morto
    if (stato == gs_ps[2] || (fantasma == pg[2] && stato == gs_ps[0] && gs_stato[0] == gs_ps[1])) {
        return pm_pos;
    }
    if (fantasma == pg[2]) {    // blu rincorre rosso o pacman in base a qual è il più vicino
        const dist_rosso = Math.sqrt((Math.pow(gs_pos[0][0] - gs_pos[1][0], 2) + Math.pow(gs_pos[0][1] - gs_pos[1][1]), 2));
        const dist_pm = Math.sqrt((Math.pow(pm_pos[0] - gs_pos[1][0], 2) + Math.pow(pm_pos[0][1] - gs_pos[1][1]), 2));
        if (dist_rosso < dist_pm) {
            return gs_pos[0];
        }
    }
    // in tutti gli altri casi, l'obbiettivo è pacman
    return pm_pos;
}

// funziona che si occupa di cambiare graficamente il fantasma, in base al suo stato
function setClasseStatoFantasma(i) {
    const fantasma = document.getElementById(gs_pos[i][0] * larghezza + gs_pos[i][1]);
    switch (gs_stato[i]) {
        case gs_ps[2]: //vulnerabile
            if (!vlnr_about_end) {
                fantasma.classList.add("Vulnerabile1");
            } else { // se il tempo di vulnerabilità sta per finire
                fantasma.classList.add("Vulnerabile2");
            }
            break;
        case gs_ps[1]: //morto
            gs_pos[i] = [...getPosizioneRespawn(i)];
            const cella = document.getElementById(gs_pos[i][0] * larghezza + gs_pos[i][1]);
            cella.classList.add("Morto");
            timer_morto[i] = setTimeout(() => {
                cella.classList.remove("Morto");
                gs_stato[i] = gs_ps[0];
            }, tempi_respawn[i]);
        case gs_ps[0]: //vivo
            if (mangiato) {
                return;
            }
            clearTimeout(timer_vlnr[i]);
            fantasma.classList.remove("Vulnerabile1");
            fantasma.classList.remove("Vulnerabile2");
        default:
            break;
    }
}

function mangiaPunto() {
    const cella = document.getElementById(pm_pos[0] * larghezza + pm_pos[1]);
    if (cella.classList.contains("Punto")) {
        cella.classList.remove("Punto");
        punteggio += punto;
    }
}

// funzione che si occupa di ciò che succede quando viene mangiata una pillola / vitamina
function mangiaPillola() {
    let changeStato = false;
    const cella = document.getElementById(pm_pos[0] * larghezza + pm_pos[1]);
    if (cella.classList.contains("Pillola")) {
        cella.classList.remove("Pillola");
        punteggio += punto * 5;
        // tutti i fantasmi non morti diventano vulnerabili
        for (let i = 0; i < gs_stato.length; ++i) {
            if (gs_stato[i] !== gs_ps[1]) {
                gs_stato[i] = gs_ps[2];
                setClasseStatoFantasma(i);
                clearTimeout(timer_vlnr[i]);
                changeStato = true;
                timer_vlnr[i] = setTimeout(() => { gs_stato[i] = gs_ps[0]; setClasseStatoFantasma(i); vlnr_about_end = false; }, tempo_vlnr[0]);
            }
        }
        // serve per far cambiare colore ai vulnerabili quando manca poco tempo allo scadere di tale stato
        if (changeStato) {
            clearInterval(timer_vlnr[4]);
            vlnr_about_end = false;
            tempo_vlnr[1] = tempo_vlnr[0] / 1000;
            timer_vlnr[4] = setInterval(checkTempoVulnerabilita, 500);
        }
    }
}

function mangiaFrutta() {
    const cella = document.getElementById(pm_pos[0] * larghezza + pm_pos[1]);
    const frutto = Array.from(cella.classList).find(fruit => frutta.includes(fruit));
    if (frutto) {
        cella.classList.remove(frutto);
        punteggio += punti_F[frutta.findIndex(fruit => frutto == fruit)];
        console.log(frutto);
        aggiornaStats(frutto);
    };
}

// Interazione utente

// Regola cosa succede quando si preme un tasto
function tastoPremuto(event) {
    if (regoleOnScreen || fine) {
        return;
    }
    if (gioco) {
        setMovimentoPacman(event);
    } else {
        avvia(event);
    }
}

// in base al tasto premuto, modifica il movimento di pacman
function setMovimentoPacman(event) {
    switch (event.code) {
        case "ArrowUp":     // arrowUp
        case "KeyW":        // W
            movimento = "U";
            break;
        case "ArrowDown":   // arrowDown
        case "KeyS":        // S
            movimento = "D";
            break;
        case "ArrowLeft":   // arrowLeft
        case "KeyA":        // A
            movimento = "L";
            break;
        case "ArrowRight":  // arrowRight
        case "KeyD":        // D
            movimento = "R";
            break;
        default:
            break;
    }
}

// funzione di supporto per il gioco

// aggiorna il punteggio a schermo
// per motivi grafici, il massimo possibile è 9999
function aggiornaPunteggio() {
    if (punteggio > 9999) {
        punteggio = 9999;
    }

    document.getElementById("punti").innerText = punteggio;
}

// aggiorna la tabella dello stato del gioco (sx)
function aggiornaStats(id) {
    const point = document.getElementById(id);
    point.innerText = Number(point.innerText) + 1;
}

// funzione che ritorna il punto di respawn del fantasma "i"
function getPosizioneRespawn(i) {
    switch (i) {
        case 0:
            // Rosso deve respawnare in base, non può spawnare nel suo punto iniziale
            // quindi usiamo lo spawn di blu e lo spostiamo a sx di uno
            const spawn = [...gs_spawn[1]];
            spawn[1]--;
            return spawn;
            break;
        case 1:
        case 2:
        case 3:
            // per gli altri fantasmi, il punto di respawn coincide con quello di spawn iniziale
            return gs_spawn[i];
        default:
            break;
    }
}

function isFantasmaInBase(posizione) {
    const base = "2BVO3";
    return base.includes(map[posizione[0]][posizione[1]]);
}

// funzione che si occupa di gestire la collisione tra pacman e i fantasmi
function collisionePacmanFantasma() {
    mangiato = gs_pos.findIndex(pos => pos[0] === pm_pos[0] && pos[1] === pm_pos[1]);

    if (mangiato !== -1 && gs_stato[mangiato] == gs_ps[0]) { // fantasma mangia pacman
        const cella = document.getElementById(gs_pos[mangiato][0] * larghezza + gs_pos[mangiato][1]);
        cella.classList.remove(pg[0]);
        cella.style.transform = '';
        mangiato = true;
    } else if (mangiato !== -1 && gs_stato[mangiato] == gs_ps[2]) { // pacman mangia fantasma
        const cella = document.getElementById(gs_pos[mangiato][0] * larghezza + gs_pos[mangiato][1]);
        cella.classList.remove(pg[mangiato + 1]);
        cella.style.transform = '';
        aggiornaStats(pg[mangiato + 1]);
        gs_stato[mangiato] = gs_ps[1];
        setClasseStatoFantasma(mangiato);
        punteggio += punti_gs[mangiato];
        mangiato = false;
    } else { // non ci sono state collisioni
        mangiato = false;
    }

    return mangiato;
}

// funzione che si occupa di trasformare gli sprite in modo tale che
// i fantasmi guardano nella direzione "orizzontale" di dove si stanno muovendo
// pacman guardi la direzione (orizzontale o verticale) di dove si sta muovendo
function specchiaSprite(posizione, movimento) {
    const cella = document.getElementById(posizione[0] * larghezza + posizione[1]);
    switch (movimento) {
        case 'R': //Destra
            if (cella.classList.contains("P")) {
                cella.style.transform = 'scaleX(1)';
            } else {
                cella.style.transform = 'scaleX(-1)';
            }
            break;
        case 'L': //Sinistra
            if (cella.classList.contains("P")) {
                cella.style.transform = 'scaleX(-1)';
            } else {
                cella.style.transform = 'scaleX(1)';
            }
            break;
        case 'U': //Su
            if (cella.classList.contains("P")) {
                cella.style.transform = 'rotate(-90deg)';
            }
            break;
        case 'D': //Giù
            if (cella.classList.contains("P")) {
                cella.style.transform = 'rotate(90deg)';
            }
        default:
            break;
    }
}

// controlla se il tempo di vulnerabilità sia quasi giunto a termine
function checkTempoVulnerabilita() {
    if (tempo_vlnr[1] == 0) {
        return;
    } else if (tempo_vlnr[1] <= (tempo_vlnr[0] / 3000)) {
        vlnr_about_end = true;
    }
    tempo_vlnr[1] -= 0.5;
}

// Altre schermate per il gioco

// funzione che si occupa di mostrare a schermo il messaggio di game over
// negativo o positivo che sia
function gameOverOnScreen() {
    let scritta;
    if (mangiato) {
        scritta = "Game Over";
    } else {
        scritta = "Hai Vinto"
    }
    const posY = document.getElementById((pm_spawn[0] + 1) * larghezza + pm_spawn[1]).offsetTop;

    creaGameOver(scritta, posY);

    console.log(scritta, pm_pos);
}

// funzione che si occupa di creare il label per il messaggio di game over
function creaGameOver(scritta, posY) {
    const label = document.createElement("label");
    const div = document.getElementById("div");
    label.setAttribute("id", "GameOver");
    label.innerText = scritta;
    label.style.top = posY + "px";
    document.body.appendChild(label);

    label.addEventListener('click', () => {
        window.location.reload();
    });

}

// funzione che si occupa di creare il dialog per mostrare le regole
function creaDialog() {
    dialog = document.createElement("dialog");
    dialog.style.border = bordo;
    dialog.style.borderRadius = radius;

    const iframe = document.createElement("iframe");
    dialog.appendChild(iframe);

    const button = document.createElement("button");
    button.addEventListener('click', () => {
        // ho provato su diversi browser e mi è
        // capitato che alcune delle seguenti opzioni
        // non funzionassero correttamente
        // ecco perché ho scritto diversi modi per chiudere
        // e aprire il dialog
        // dialog.show() e dialog.close() mi è capitato
        // dessero errore (es. Firefox), quindi ho preferito non usarli
        dialog.setAttribute("open", false);
        dialog.removeAttribute("open");
        document.body.removeChild(dialog);
        regoleOnScreen = false;
    });
    button.setAttribute("id", "closeDialog");
    button.innerText = "Chiudi";
    dialog.appendChild(button);
}

// funzione che si occupa di mostrare le regole a schermo
function showRegole() {
    if (!gioco) {
        regoleOnScreen = true;
        dialog.firstChild.src = "Regole.html";
        dialog.setAttribute("open", true);
        document.body.appendChild(dialog);
    }
}

// Funzioni per interazione col server

// evento personale per l'aggiornamento della classifica (dx)
function eventoClassifica(){
    const event = new CustomEvent("Classifica", {
        detail: {
            messaggio: "Aggiorna Classifica"
        }
    });
    document.dispatchEvent(event);
}

// evento personale per l'inserimento del punteggio fatto a fine partita
function eventoFinePartita(){
    const event = new CustomEvent("FinePartita", {
        detail: {
            messaggio: "Insert Punteggio"
        }
    });
    document.dispatchEvent(event);
}

// si occupa di richiamare le due funzioni precedenti a partita terminata
function operazioniFinali(){
    console.log("Inserimento Punteggio");
    eventoFinePartita();
    console.log("Eventuale Aggiornamento Classifica");
    eventoClassifica();
}

// Funzione per il log out / Exit

// log out
function logout(){
    // replace non permette di ritornare alla pagina
    // usando il tasto "indietro"
    console.log("Log out eseguito");
    window.location.replace('../HTML/login.php');
}
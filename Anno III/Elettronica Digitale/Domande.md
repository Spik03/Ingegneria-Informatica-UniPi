### Note
Le domande sono state generate anche grazie all'aiuto di Gemini,
al quale avevo datto in input il registro elettronico delle lezioni del Corso di Elettronica Digitale di Ingegneria Informatica UniPi dell'anno 2025/2026.

È dunque possibile che ci siano domande che utilizzano una terminologia non conforme a quella effettiva del corso.

# Domande di Teoria - Elettronica

## 1. Fisica dei Semiconduttori e Conduzione
* **Modello di Drude:** Descrivi le ipotesi fisiche fondamentali del modello di Drude per la conduzione nei metalli e nei semiconduttori.
* **Corrente di Drift:** Definisci i concetti di corrente di drift e velocità di drift. Ricava i passaggi matematici principali per il calcolo dell'espressione della densità di corrente di drift.
* **Semiconduttore Intrinseco:** Cos'è un materiale semiconduttore? Spiega il concetto di lacuna e come si calcola la concentrazione di elettroni liberi nel silicio intrinseco.
* **Legge di Azione di Massa:** Quale relazione costante stabilisce tra elettroni e lacune all'equilibrio termodinamico e come varia quantitativamente con la temperatura?
* **Drogaggio:** Spiega in dettaglio il meccanismo di drogaggio (tipo $n$ e tipo $p$) e quali specie droganti si utilizzano nel silicio.
* **Influenza della Temperatura:** Analizza l'influenza della temperatura sulla conducibilità elettrica nel silicio intrinseco rispetto a quello drogato.
* **Corrente di Diffusione:** Spiega la forza motrice microscopica della corrente di diffusione e scrivi le relative formule analitiche.
* **Relazione di Einstein:** Quale legame stabilisce tra la costante di diffusione ($D$) e la mobilità ($\mu$) dei portatori di carica?
* **Costante di Diffusione:** Ricava l'unità di misura della costante di diffusione partendo da un modello analitico, indicando la formula e il verso del flusso.
* **Tensione Termica:** Qual è la definizione fisica della tensione termica ($V_T$ o $U_T$) e qual è il suo valore tipico a temperatura ambiente?

## 2. La Giunzione p-n e Circuiti a Diodi
* **Giunzione a Circuito Aperto:** Descrivi la formazione della regione di svuotamento e della barriera di potenziale in una giunzione p-n a circuito aperto.
* **Potenziale di Built-in:** Perché il potenziale di built-in ($V_{bi}$) della giunzione p-n non può essere direttamente osservato o misurato dall'esterno collegando un voltmetro?
* **Polarizzazione e Legge di Shockley:** Spiega il funzionamento della giunzione p-n in polarizzazione diretta e inversa introducendo la legge di Shockley e il significato del coefficiente di non idealità $n$.
* **Fenomeno di Breakdown:** Descrivi in dettaglio l'effetto Zener e l'effetto valanga nella giunzione p-n. Come influenza la temperatura la tensione di rottura nei due casi?
* **Diodo Zener:** Descrivi le caratteristiche principali del diodo Zener e disegna il suo simbolo circuitale.
* **Metodo della Retta di Carico:** Spiega il metodo della retta di carico per la determinazione grafica del punto di lavoro di un bipolo non lineare.
* **Modelli per Grandi Segnali:** Descrivi i circuiti equivalenti per grandi segnali del diodo: il modello ideale, il modello a caduta costante e il modello lineare a tratti.
* **Circuiti Multi-diodo:** Qual è la metodologia per risolvere un circuito contenente più diodi tramite la formulazione e la verifica delle ipotesi di lavoro?
* **Porte Logiche a Diodi:** Disegna e analizza le porte logiche AND e OR a diodi, evidenziando i problemi principali della logica a diodi (corrente assorbita, degrado dei livelli logici, mancanza della porta NOT).
* **Rilevatore di Picco:** Analizza il circuito del rilevatore di picco (raddrizzatore con filtro capacitivo) e spiega perché, in assenza di un carico resistivo in parallelo, il condensatore non ha effetto sul ripple dopo il primo picco.
* **Raddrizzatore a Doppia Semionda:** Analizza il funzionamento di un raddrizzatore a doppia semionda con trasformatore a presa centrale nei due semiperiodi.
* **Ponte di Graetz:** Descrivi il funzionamento del raddrizzatore a ponte di Graetz e analizza il percorso della corrente nelle due semionde.
* **Peak Inverse Voltage (PIV):** Cos'è questo parametro e perché è critico nel progetto e nel dimensionamento di un circuito raddrizzatore?
* **Modello per Piccoli Segnali (Diodo):** Definisci le condizioni di applicabilità e i limiti di validità dell'approssimazione lineare per piccoli segnali nel diodo.
* **Resistenza Differenziale:** Deriva analiticamente l'espressione della resistenza differenziale ($r_d$) nel modello per piccoli segnali partendo dallo sviluppo in serie di Taylor della corrente del diodo.
* **Capacità Parassite del Diodo:** Metti a confronto la capacità di transizione ($C_j$) e la capacità di diffusione ($C_d$). In quali condizioni di polarizzazione domina l'una o l'altra e quale delle due dipende linearmente dalla corrente?

## 3. Transistori BJT (Bipolar Junction Transistor)
* **Principio di Funzionamento:** Spiega il principio di funzionamento del transistore bipolare a giunzione (BJT) e le differenze strutturali tra $npn$ e $pnp$.
* **Profilo di Drogaggio:** Perché l'emettitore di un BJT è geometricamente molto più drogato rispetto alla base?
* **Regioni di Funzionamento:** Descrivi le quattro regioni di funzionamento del BJT basandoti sulle polarizzazioni delle giunzioni nel modello di Ebers-Moll.
* **Ebers-Moll in Zona Attiva Diretta:** Scrivi le equazioni costitutive e disegna il circuito equivalente del modello di Ebers-Moll in zona attiva diretta.
* **Ebers-Moll in Saturazione (NPN):** Come cambiano le equazioni e le condizioni sulle correnti nel modello di Ebers-Moll per un BJT $npn$ quando entra in saturazione?
* **Ebers-Moll in Zona Attiva Inversa (PNP):** Descrivi come ricavare analiticamente la corrente di base ($I_B$) in funzione della corrente di emettitore ($I_E$) nella zona attiva inversa per un BJT $pnp$.
* **Effetto Early nel BJT:** In che modo la tensione collettore-emettitore influenza la corrente di collettore? Spiega la fenomenologia e i fondamenti fisici basati sulla modulazione della larghezza di base.
* **Modello per Ampi Segnali:** Descrivi il modello per ampi segnali del transistore BJT (relazioni correnti-tensioni) per le regioni di interdizione, zona attiva e saturazione.
* **Polarizzazione a 4 Resistenze:** Analizza la stabilità del circuito di polarizzazione del BJT a 4 resistenze. Spiega il ruolo della resistenza di degenerazione di emettitore ($R_E$) e il "prezzo" che si paga sul guadagno dello stadio.
* **Guadagno $\beta$ di Saturazione:** Qual è la differenza concettuale e quantitativa tra il guadagno $\beta_F$ in zona attiva e il $\beta_{sat}$ valutato quando il BJT è saturo?
* **Invertitore a BJT:** Deriva la Caratteristica di Trasferimento di Tensione (VTC) di un circuito invertitore realizzato con un BJT con carico resistivo sul collettore.
* **Parametri Ibridi:** Descrivi il circuito equivalente per piccoli segnali a parametri $h$ (ibridi) a emettitore comune e spiega la procedura per la valutazione grafica o analitica del parametro $h_{re}$.

## 4. Transistori MOSFET
* **Condensatore MOS:** Descrivi la struttura fisica del condensatore MOS e spiega nel dettaglio cosa succede sulla superficie del semiconduttore nei tre regimi di funzionamento: accumulazione, svuotamento e inversione.
* **Pinch-Off e Regioni di Canale:** Spiega il fenomeno del *pinch-off* (strozzamento del canale) nel MOSFET e scrivi le relazioni analitiche tra corrente e tensioni nella zona di triodo e nella zona di saturazione.
* **Regione di Triodo:** Quali sono le precise condizioni geometriche e sulle tensioni applicate ($V_{GS}, V_{DS}, V_{th}$) affinché un transistore NMOS lavori in zona triodo?
* **Modulazione di Canale ($\lambda$):** A quale fenomeno fisico del BJT corrisponde la modulazione della lunghezza di canale nel MOSFET? Spiega perché la corrente di drain aumenta al variare di $V_{DS}$ in saturazione.
* **Tensione di Soglia:** Qual è la definizione fisica della tensione di soglia ($V_T$ o $V_{th}$) del MOSFET e qual è la differenza concettuale rispetto alla tensione termica del diodo?
* **Body Effect:** In un MOSFET integrato, come influisce la tensione presente tra Source e Bulk ($V_{SB}$) sulla tensione di soglia del dispositivo?

## 5. Amplificatori, Risposta in Frequenza e Reazione
* **Transconduttanza ($g_m$):** Cosa rappresenta fisicamente questo parametro e come si calcola analiticamente sia nel BJT che nel MOSFET?
* **Parametri di Piccolo Segnale del MOS:** Deriva analiticamente le espressioni dei parametri per piccoli segnali ($g_m$, $r_d$) per un MOSFET operante in zona di saturazione.
* **Stadio a Emettitore Comune:** Calcola il guadagno di tensione, il guadagno di corrente, la resistenza d'ingresso e d'uscita per uno stadio amplificatore a emettitore comune (analizza sia il caso con condensatore di bypass sull'emettitore, sia il caso senza).
* **Stadio a Collettore Comune:** Analizza lo stadio amplificatore a collettore comune (inseguitore di emettitore) ricavando i guadagni e le resistenze viste ai terminali.
* **Stadio a Source Comune:** Analizza lo stadio amplificatore a source comune per piccoli segnali con e senza resistenza di source, calcolandone il guadagno di tensione.
* **Stadio a Drain Comune:** Analizza lo stadio amplificatore a drain comune (inseguitore di source) e ricava la formula per il calcolo della resistenza vista guardando dentro il terminale di source.
* **Amplificatori Multistadio:** Spiega lo scopo degli amplificatori multistadio e descrivi l'effetto di carico di ciascuno stadio a valle su quello a monte.
* **Poli Non Interagenti:** Secondo il metodo delle resistenze viste (costanti di tempo), quando due condensatori si definiscono "non interagenti" per il calcolo delle frequenze di taglio del circuito?
* **Teorema di Miller:** In che modo questo teorema semplifica l'analisi di un'impedenza collegata in parallelo tra i nodi d'ingresso e d'uscita di un amplificatore invertente?
* **Teoria della Reazione Ideale:** Elenca le tre ipotesi semplificative della trattazione della reazione ideale e spiega come varia l'impedenza di uscita se si esegue un prelievo di tensione.
* **Amplificatore Differenziale a Transistori:** Definisci le tensioni a modo comune e a modo differenziale. Che cos'è il CMRR, come viene calcolato e perché un valore elevato è desiderabile? Ricava inoltre le formule per il guadagno differenziale e per il guadagno a modo comune.

## 6. Amplificatori Operazionali (Op-Amp)
* **Op-Amp Ideale e Corto Circuito Virtuale:** Elenca le caratteristiche ideali di un amplificatore operazionale e giustifica matematicamente e fisicamente il principio del corto circuito virtuale d'ingresso.
* **Funzionamento ad Anello Aperto:** Perché non è possibile usare direttamente un singolo amplificatore operazionale ideale ad anello aperto per fare la differenza esatta di due segnali senza l'uso di reti di retroazione?
* **Amplificatore Differenziale a 4 Resistenze:** Disegna il circuito di un amplificatore differenziale a 4 resistenze con Op-Amp ed effettua il calcolo delle resistenze viste dai due ingressi.
* **Configurazioni Lineari Base:** Disegna e ricava la funzione di trasferimento dei circuiti base con Op-Amp: amplificatore invertente, amplificatore non invertente e sommatore invertente.
* **Inseguitore di Tensione (Buffer):** Quali sono le caratteristiche di impedenza d'ingresso e d'uscita di un buffer e perché il suo utilizzo è utile per disaccoppiare i circuiti?
* **Integratore di Miller:** Ricava l'espressione di $V_o$ per l'integratore di Miller usando sia il metodo nel dominio del tempo che quello di Laplace. Spiega perché l'uscita è instabile in continua (criterio BIBO) e come viene impiegato nei circuiti dei convertitori ADC.
* **Prodotto Guadagno-Banda (GBWP):** Quale vincolo impone il parametro del Prodotto Guadagno-Banda sulla progettazione di un amplificatore operazionale reazionato?

## 7. Regolatori di Tensione (Lineari e Switching)
* **Regolatore a Zener:** Descrivi il circuito di un regolatore di tensione a diodo Zener e analizza cosa accade analiticamente alla regolazione se la resistenza di carico è molto grande, normale oppure nulla.
* **Regolatore Lineare Serie:** Descrivi il circuito, il funzionamento ideale e calcola analiticamente la resistenza di uscita vista in reazione.
* **Dimensionamento del Lineare Serie:** Nei regolatori lineari serie, perché si usa un doppio condensatore (uno in ingresso e uno in uscita)? Spiega solo tramite ragionamento come ottenere $V_o = 5\text{ V}$ in uscita se hai a disposizione un diodo Zener di riferimento con $V_z = 4.7\text{ V}$.
* **Integrati Monolitici 78xx e 79xx:** Descrivi le caratteristiche elettriche e le differenze applicative dei regolatori monolitici commerciali delle famiglie 78xx (positivi) e 79xx (negativi).
* **Regolatore di Corrente:** Spiega come realizzare un regolatore di corrente utilizzando un regolatore di tensione monolitico (es. serie 75xx). Descrivi il circuito e spiega qual è il limite massimo per la resistenza di carico oltre il quale il circuito smette di regolare.
* **Regolatore Switching di Base:** Spiega il principio di funzionamento e l'architettura a commutazione di un regolatore switching di base (struttura a interruttore).
* **Regolatore Switching Forward:** Analizza il circuito Forward e determina l'andamento della tensione sull'induttore L, sulla resistenza R e sulla capacità C con lo switch chiuso e con lo switch aperto. Evidenzia le differenze di efficienza rispetto al lineare serie.
* **Alimentatore Switching Flyback:** Descrivi il principio di funzionamento, i legami analitici del convertitore Flyback e i vantaggi legati all'isolamento galvanico ad alta frequenza tramite trasformatore.

## 8. Elettronica Digitale e Famiglie Logiche (CMOS / TTL)
* **Parametri delle Porte Logiche:** Definisci i concetti di Margine di Rumore, ritardo di propagazione, Fan-In, Fan-Out e il prodotto Potenza-Ritardo (PDP) per una generica porta logica digitale.
* **Rigenerazione dei Livelli Logici:** Spiega il fenomeno della rigenerazione dei livelli logici in una catena di inverter e qual è la condizione matematica necessaria sulla pendenza della VTC affinché questo si verifichi.
* **Soglia Logica ($V^*$):** Come viene definita e individuata graficamente la soglia logica sulla Caratteristica di Trasferimento (VTC) di un inverter?
* **Margini di Rumore nel CMOS:** Come si calcolano graficamente e analiticamente i margini $NM_H$ e $NM_L$ in un inverter CMOS partendo dai punti a pendenza unitaria ($\frac{dV_{out}}{dV_{in}} = -1$) della VTC?
* **Dissipazione di Potenza nell'Inverter CMOS:** Descrivi la struttura circuitale e analizza in dettaglio la potenza dissipata sia in regime statico che in regime dinamico, mostrando la derivazione della formula $P_{dyn} = C_L \cdot V_{DD}^2 \cdot f$.
* **Sintesi di Reti CMOS Complesse:** Spiega il principio di dualità per la sintesi delle reti di Pull-Up (PUN) e Pull-Down (PDN) in logica CMOS. Mostra come esempio l'implementazione di una porta NAND e di una porta NOR a due ingressi.
* **Dimensionamento e Area delle Porte CMOS:** Come si effettua il dimensionamento dei rapporti $W/L$ dei transistori in una porta CMOS complessa per pareggiare i tempi di salita e discesa? Spiega perché la porta NAND occupa meno area su silicio rispetto alla NOR.
* **Protezione ESD:** Descrivi il circuito di protezione dalle scariche elettrostatiche (ESD) tipicamente integrato all'ingresso delle porte logiche CMOS.
* **Logica Pass-Transistor:** Analizza la carica e la scarica di un condensatore di carico tramite un pass-transistor NMOS e un pass-transistor PMOS. Dimostra analiticamente che un pass-transistor NMOS non si comporta come un interruttore ideale quando deve trasmettere un '1' logico (problema della perdita della soglia $V_{th}$).
* **Transmission Gate:** Descrivi la struttura e le proprietà di trasmissione di un Transmission Gate (pass-gate) realizzato con NMOS e PMOS in parallelo.
* **Famiglia Logica TTL:** Descrivi la struttura interna della famiglia logica TTL classica con stadio d'uscita Totem-Pole. Disegna un invertitore TTL e spiega come può essere generalizzato modificando il transistore multi-emettitore per ottenere una porta NAND.

## 9. Circuiti Temporizzatori e Logica Sequenziale
* **Condizioni di Equilibrio e Latch:** Analizza le condizioni di equilibrio di un latch bistabile a due invertitori, descrivendo gli stati stabili, lo stato metastabile e il comportamento del circuito in funzione della soglia di $V_{DD}/2$.
* **Latch SR:** Descrivi il procedimento di lettura e di scrittura, mostrando le 2 possibili realizzazioni circuitali (a porte NOR o porte NAND) in tecnologia CMOS.
* **Flip-Flop D Master-Slave:** Descrivi il principio di funzionamento di un Flip-Flop D Edge-Triggered con struttura Master-Slave e specifica quale capacità parassita mantiene fisicamente memorizzato il dato durante le fasi di commutazione del clock non-overlapping.
* **Oscillatore ad Anello:** Descrivi la struttura di un oscillatore ad anello realizzato con inverter CMOS: spiega come si utilizza per il calcolo del tempo di propagazione ($t_p$), perché si chiama guadagno ad anello e discuti se la formula $f = \frac{1}{2 \cdot n \cdot t_p}$ è sempre valida.
* **NE555 come Monostabile:** Descrivi la struttura interna (comparatori, flip-flop, interruttore di scarica) del temporizzatore NE555 e spiega il suo funzionamento come circuito monostabile.
* **NE555 come Astabile:** Analizza l'NE555 configurato come multivibratore astabile ed effettua il calcolo del periodo totale di oscillazione e del duty cycle dell'onda quadra risultante.

## 10. Architetture e Tecnologie di Memoria
* **Organizzazione Matriciale:** Descrivi l'architettura generale e l'organizzazione matriciale in righe (word line) e colonne (bit line) delle memori a semiconduttore RAM e ROM.
* **Memorie SRAM:** Disegna lo schema circuitale di una cella di memoria SRAM a 6 transistori (6T) e descrivi accuratamente le fases di lettura e di scrittura dello stato bistabile.
* **Memorie DRAM:** Disegna lo schema di una cella di memoria DRAM (1T-1C). Descrivi il processo di lettura basato sul *charge sharing*, calcola la variazione di tensione $\Delta V$ sulla bit line e spiega perché è necessario il refresh periodico.
* **Sense Amplifier e Precarica:** Spiega il funzionamento dettagliato del *sense amplifier* (amplificatore di sblocco) e del circuito di precarica delle bit line. Perché si usa un PMOS collegato a VDD e un NMOS a ground? Perché lo stato metastabile è fondamentale per il funzionamento del sense amplifier?
* **Temporizzazione di Lettura delle RAM:** Analizza la temporizzazione completa di una fase di lettura in una memoria RAM, descrivendo la sequenza temporale dall'attivazione della word line all'uscita del dato stabilizzato.
* **Decodificatori di Indirizzo:** Descrivi la struttura circuitale di un decoder degli indirizzi di riga. Come va modificato per ottenere un decoder degli indirizzi di colonna e perché è necessaria questa modifica strutturale?
* **Memorie EPROM e Gate Flottante:** Spiega il principio di memorizzazione non volatile basato sul transistore con *floating gate* (gate flottante) e descrivi perché si utilizza la luce risonante UV per la cancellazione del dato.
* **Memorie EEPROM e FLOTOX:** Descrivi la struttura del transistore FLOTOX e spiega come viene impiegato per permettere la scrittura e la cancellazione elettrica (tramite effetto tunnel Fowler-Nordheim) del singolo bit in una memoria EEPROM.

## 11. Convertitori A/D e D/A
* **Convertitori D/A (DAC):** Definisci la caratteristica ingresso-uscita ideale di un convertitore Digitale/Analogico. Confronta l'architettura a resistori a pesi binari con la rete a scala $R\text{-}2R$, mettendone in luce i vantaggi tecnologici.
* **Convertitori A/D (ADC) e Quantizzazione:** Definisci la caratteristica ideale di un convertitore Analogico/Digitale ed effettua il calcolo dell'errore di quantizzazione associato al gradino del bit meno significativo (LSB).
* **ADC a Singola Rampa:** Descrivi lo schema circuitale e il principio di funzionamento di un convertitore ADC a singola rampa, effettuando i calcoli del tempo di conversione massimo.
* **ADC a Doppia Rampa:** Mostra l'andamento grafico della tensione sull'integratore di un ADC a doppia rampa durante le fasi di salita e discesa. Ricava analiticamente il risultato finale dimostrando l'indipendenza della misura dai valori assoluti di R e C.
* **ADC ad Approssimazioni Successive (SAR):** Spiega l'architettura interna e l'algoritmo di ricerca binaria utilizzato dal registro SAR per convertire il segnale in $N$ cicli di clock.
* **ADC Flash:** Calcola il numero di componenti hardware (comparatori e resistenze) necessari per bit in un convertitore Flash. Elenca i suoi vantaggi, svantaggi, come migliorarlo tramite l'architettura a due step (sub-ranging) e spiega perché si rende necessario un amplificatore analogico all'ingresso del circuito.
* **Codifica Termometrica:** In quale specifica architettura di convertitore ADC viene utilizzata la codifica termometrica e come funziona la scala di soglie dei comparatori per la generazione del codice?

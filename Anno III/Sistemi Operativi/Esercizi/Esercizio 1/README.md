# Esercizio: Sincronizzazione a Due Fasi con Thread POSIX

Si realizzi un programma in ambiente **UNIX/C** utilizzando la libreria `pthread.h` che gestisca la sincronizzazione di un processo composto da un thread principale (`main`) e **5 thread figli**.

I thread condividono un **vettore di interi di dimensione 10** inizializzato a `-1`.

L'esecuzione deve articolarsi in due fasi distinte:

---

### Fase 1:
* Ciascuno dei 5 thread figli genera un numero casuale (da 1 a 100) e lo inserisce nella prima posizione libera del vettore condiviso, aggiornando l'indice globale in mutua esclusione.
* Il thread `main`, dopo aver creato i figli, deve mettersi in attesa che tutti e 5 abbiano completato l'inserimento della prima fase.
* L'ultimo thread figlio ad aver effettuato l'inserimento deve svegliare il thread `main`.
* Tutti i thread figli, dopo l'inserimento, devono fermarsi ad attendere in una barriera di sincronizzazione l'inizio della Fase 2.

---

### Fase 2:
* Una volta risvegliato, il `main` stampa a video lo stato parziale del vettore.
* Successivamente, il `main` sblocca simultaneamente tutti i thread figli, dando il via alla seconda fase.
* I thread figli si risvegliano e ripetono l'operazione: generano un secondo numero casuale e lo inseriscono nella prima posizione libera del vettore (senza più bloccarsi).
* Al termine, il `main` attende la terminazione di tutti i thread (tramite `pthread_join`), stampa lo stato finale del vettore e libera le risorse prima di terminare.

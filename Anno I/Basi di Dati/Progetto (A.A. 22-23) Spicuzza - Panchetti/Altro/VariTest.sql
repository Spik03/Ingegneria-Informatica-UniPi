set @serverCentrale = 583;

USE `FilmSphere`;

-- Vari Test
-- Di seguito alcuni dei test eseguiti per verificare la correttezza di alcune funzionalità

-- Test Classifica
Call Classifica(0, 10, NULL, NULL, NULL, NULL);
Call Classifica(1, 10, 'Italia', NULL, NULL, NULL);
Call Classifica(2, 10, NULL, 'Italia', NULL, NULL);
Call Classifica(3, 10, NULL, NULL, 'A', 1.3);
Call Classifica(4, 10, 'Italia', 'Italia', NULL, NULL);
Call Classifica(5, 10, 'Italia', NULL, 'A', 1.3);
Call Classifica(6, 10, 'Italia', 'Italia', 'A', 1.3);
Call Classifica(7, 10, 'Italia', 'Italia', 'A', 1.3);
    
-- Test Operazioni
call FilmInclusiAbbonamentoUtente('mario_rossi91');

call FilmPiuVistiUltimi7Giorni();
    
call isFormatoSupportatodaDispositivo('Samsung', 'Galaxy S21', 'A', 1.3, @prova);
select if(@prova, 'true', 'false');
call isFormatoSupportatodaDispositivo('Samsung', 'Galaxy S21', 'J', 3.3, @prova);
select if(@prova, 'true', 'false');
   
call PopolaritaAttore('JHNNYDPP', @prova);
select @prova;
select * from Attore order by popolarita desc;
select * from film where id = 16;
    
call ClassificaFilm_stessaNazioneDellaConnessione('4.40.10.23', '2023-12-20 00:01:13', 'giulia_1990');
    
call TempoRimasto('giulia_1990', @prova);
select @prova as minuti,'->',round(@prova/60) as ore;
    
call CronologiaUtente('claudio81');

insert IGNORE into versione values (8, 'A', 1.3); -- inserimento di una versione di un film per provare le procedure seguenti
set @timestamp_di_prova = current_timestamp();
set @utente = 'fabio90';
call isFormatoSupportatodaDispositivo('Samsung', 'Galaxy S21', 'A', 1.3, @prova);
select @prova;
insert into Connessione(IP, TimestampInizio, Utente, TimestampFine, Nazione, MarcaDispositivo, ModelloDispositivo) values
 	('101.120.02.11', @timestamp_di_prova, @utente, null, 'Albania', 'Samsung', 'Galaxy S21');
call NuovoStreaming('101.120.02.11', @timestamp_di_prova, @utente, 8, 'A', 1.3);
select * from streaming order by timestampInizio desc;
select * from cronologia order by timestampInizio desc;

-- Test Custom Analytic     
call Formati_o_Film_piu_vietati(true, 10);
call Formati_o_Film_piu_vietati(false, 10);
    
-- Test RatingFilm / RatingUtente
select * from RatingFilm order by rating desc;

select * from RatingUtente order by Utente, rating desc;

select Film, count(*), round(avg(rating)) as media from RatingUtente group by film order by count(*) desc, media desc;

-- Test Pop
select * from PoP order by Server;

select Film, Count(*) as "Presenza nei server"
from PoP
where Server <> @serverCentrale
group by Film
order by count(*) desc;
    
select Server, Count(*) as "Film nel Server"
from PoP
where Server <> @serverCentrale
group by Server
order by count(*) desc;    
    
with FilmTotali as(
	select count(*) as Totale
    from Film
), FilmServerCentrale as(
	select count(*) as Conteggio
	from PoP
	where server = @serverCentrale
)
Select @serverCentrale as "Origin Server", Conteggio as "Film nel server", Totale as "Film Totali", if(Totale - conteggio = 0, "Corretto", "Errore") as "Correttezza"
from FilmTotali F
	join FilmServerCentrale C;

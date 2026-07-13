SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

USE `FilmSphere`;

-- Classifica dei film che hanno origine nella stessa Nazione della Connessione
drop procedure if exists ClassificaFilm_stessaNazioneDellaConnessione;
delimiter $$
create procedure ClassificaFilm_stessaNazioneDellaConnessione(IN _IP varchar(19), IN _TimestampInizio timestamp, IN _Utente char(20))
begin
	select F.id as codice, F.Titolo, RF.rating as Voto
    from Film F
		inner join RatingFilm RF
			on F.id = RF.Film
		inner join Connessione C
			on F.Nazione = C.nazione
	where C.ip = _IP 
		and C.timestampInizio = _Timestampinizio
        and C.Utente = _Utente
	order by RF.rating desc
    limit 10;
end $$
delimiter ;
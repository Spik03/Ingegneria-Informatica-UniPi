SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

USE `FilmSphere`;

-- Cronologia Utente
drop procedure if exists CronologiaUtente;
delimiter $$
create procedure CronologiaUtente(In _Utente char(20))
begin
	select date_format(date(C.TimestampInizio), "%d %M %Y") as "Visto il Giorno", F.id as Codice, F.Titolo
    from Film F
		inner join Cronologia C
        on F.ID = C.Film
	where C.NomeUtente = _Utente
    order by C.TimestampInizio desc;
end $$
delimiter ;
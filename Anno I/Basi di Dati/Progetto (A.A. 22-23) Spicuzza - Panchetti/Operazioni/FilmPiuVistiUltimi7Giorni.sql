SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

USE `FilmSphere`;

-- Film più visti negli ultimi 7 Giorni
	-- per scopi implementativi abbiamo considerato 7 mesi
drop procedure if exists FilmPiuVistiUltimi7Giorni;
delimiter $$
create procedure FilmPiuVistiUltimi7Giorni()
begin
	with FilmOrdinatiPerVisualizzazioni as(
		select F.Id, F.Titolo, F.Durata, F.AnnoProduzione, F.Voto, F.media, F.regista, F.classificazione, F.nazione, count(*) as Visualizzazioni
		from film F
			inner join cronologia c
				on F.id = c.film
		where timestampInizio >= current_timestamp() - interval 7 month
		group by F.Id
		order by count(*) desc
        limit 10
	) select  F.Id, F.Titolo, F.Durata, F.AnnoProduzione, F.Voto, F.media, F.regista, F.classificazione, F.nazione
		from FilmOrdinatiPerVisualizzazioni F;
end $$
delimiter ;
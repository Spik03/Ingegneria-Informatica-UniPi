SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

USE `FilmSphere`;

-- Custom
drop procedure if exists Formati_o_Film_piu_vietati;
delimiter $$
create procedure Formati_o_Film_piu_vietati(IN _scelta bool, IN _N int)
begin
    If(_scelta) then
		select F.*, count(*) as numeroNazioni
		from Formato F
			inner join Vietato V
				on F.Tipo = V.TipoFormato
					and F.Versione = V.VersioneFormato
		group by F.Tipo, F.Versione
		order by numeroNazioni desc
		limit _N;
    else
		with listaFormatiVietati as(
			select F.*, count(*) as numeroNazioni
			from Formato F
				inner join Vietato V
					on F.Tipo = V.TipoFormato
						and F.Versione = V.VersioneFormato
			group by F.Tipo, F.Versione
		), ListaFilmVietati as(
			select F.id, F.Titolo, R.Rating, F.voto, sum(numeroNazioni) as NumeroVersioniVietate_conMolteplicita 
            -- se due formati son vietati in una nazione, contano 2 e non 1
			From Film F
				inner join Versione V
					on F.Id = V.Film
				inner join listaFormatiVietati l
					on V.TipoFormato = l.Tipo
						and V.VersioneFormato = l.Versione
				inner join RatingFIlm R
					on F.id = R.Film
			group by F.id
		)
        select Id, Titolo, NumeroVersioniVietate_conMolteplicita
        from ListaFilmVietati
        order by NumeroVersioniVietate_conMolteplicita desc, Rating asc, voto asc
        limit _N;
    end if;
end $$
delimiter ;
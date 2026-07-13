SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

USE `FilmSphere`;

-- lista film inclusi nell'abbonamento dell'Utente
drop procedure if exists FilmInclusiAbbonamentoUtente;
delimiter $$
create procedure FilmInclusiAbbonamentoUtente(IN _Utente char(20))
begin
	select F.*
    From Film F
	where F.media not in(
		select M.Media
        from Abbonamento A
			inner join Utente U
				on U.abbonamento = A.nome
			inner join EscludereM M
				on A.nome = M.abbonamento
		where U.nomeUtente = _Utente
	)	and F.classificazione not in(
			select C.Classificazione
			from Abbonamento A
				inner join Utente U
					on U.abbonamento = A.nome
				inner join EscludereC C
					on A.nome = C.abbonamento
			where U.nomeUtente = _Utente
        );
end $$
delimiter ;
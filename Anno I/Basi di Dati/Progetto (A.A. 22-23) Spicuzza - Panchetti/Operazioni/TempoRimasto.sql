SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

USE `FilmSphere`;

-- Visualizzare quante ore l’Utente ha ancora a disposizione dal suo Abbonamento
drop procedure if exists TempoRimasto;
delimiter $$
create procedure TempoRimasto(IN _Utente varchar(16), OUT TempoRimasto_ int)
begin
	if ( (select Abbonamento from Utente) is NULL) then
		set TempoRimasto_ = 0;
	else
		with InizioAbbonamentoAttuale as(
			select DataPagamento
			from Fatturazione F
				inner join Utente U
					on F.Utente = U.nomeUtente
			where U.nomeutente = _Utente
			order by DataPagamento desc
			limit 1
		)
		,MinutiVisualizzati as(
			select sum(F.durata) as totale
			from Film F
				inner join Cronologia C
					on F.ID = C.film
			where date(C.timestampInizio) >= (select DataPagamento from InizioAbbonamentoAttuale I)
				and C.nomeUtente = _Utente
		)
		select (A.OreMassime*60 - (select totale from MinutiVisualizzati)) into TempoRimasto_
		from Abbonamento A
			inner join Utente U
				on A.nome = U.abbonamento
		where U.nomeUtente = _Utente;
	end if;
    
    -- tecnicamente tempoRimasto_ non può mai essere minore di 0
    -- ma per sicurezza eseguiamo anche questo controllo
    if(TempoRimasto_ <0) then
		set TempoRimasto_ = 0;
	end if;
    
end $$
delimiter ;
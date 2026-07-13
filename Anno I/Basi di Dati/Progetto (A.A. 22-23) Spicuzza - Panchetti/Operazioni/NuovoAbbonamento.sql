SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

USE `FilmSphere`;

-- Nuova Fatturazione / Nuovo Abbonamento
Drop Procedure if exists NuovoAbbonamento;
delimiter $$
create procedure NuovoAbbonamento(In _Utente char(20), IN _Abbonamento varchar(20), IN _carta varchar(16))
begin
	declare tempo int;
    
	call TempoRimasto(_Utente, tempo);
    
	if( (tempo is not null and tempo = 0) or ((select Abbonamento
												from Utente
												where NomeUtente = _Utente) is not null and tempo is not null)) then
        SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Abbonamento ancora in Corso, non è possibile comprarne uno nuovo!';
	else
		insert into Fatturazione(DataPagamento, Costo, Utente, Carta)
		select current_date, A.costo, _Utente, _carta
        from Abbonamento A
        where A.nome = _Abbonamento;
            
		Update Utente
        set Abbonamento = _Abbonamento
        where NomeUtente = _Utente;
        
    end if;
end $$
delimiter ;
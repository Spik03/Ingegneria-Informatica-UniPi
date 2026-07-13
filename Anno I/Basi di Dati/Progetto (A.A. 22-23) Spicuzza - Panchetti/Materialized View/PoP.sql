SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;
set @serverCentrale = 583;

USE `FilmSphere`;

-- PoP --
Drop table if exists PoP;
create table PoP(
	Server int not null,
	Film int not null,
    primary Key(Film, Server),
    foreign key(Film) references `Film`(`ID`)
	ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(Server) references `Server`(`Codice`)
	ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

Drop event if exists aggiornaPoP;
Delimiter $$
create event aggiornaPoP
on schedule every 1 week
DO
BEGIN
	call InsertPoP();
END $$
DELIMITER ;

drop procedure if exists InsertPop;
Delimiter $$
create procedure InsertPoP()
Begin
	delete  
    from PoP
    where server <> @serverCentrale;
    call InsertPoP_RatingUtente();
    call InsertPoP_RatingFilm();
END $$
DELIMITER ;

-- insertPoP fatto secondo il ratingUtente
DROP PROCEDURE IF EXISTS InsertPoP_RatingUtente;
Delimiter $$
Create Procedure InsertPoP_RatingUtente()
begin
	declare _Utente char(20);
    declare _nazione varchar(60);
    declare FINITO bool default false;
    Declare cur Cursor for(
		select NomeUtente
        from Utente
    );
    Declare continue handler for not found
		set finito = true;
    
	open cur;
    ciclo : loop
		fetch cur into _Utente;
        if finito then 
				leave ciclo;
		end if;
		call NazionePrincipale(_Utente, _Nazione);
        
        insert into PoP
        select s.codice, R.film
        from server s
			join (select RU.film
						from RatingUtente RU
                        where RU.Utente = _Utente
                        order by rating desc
                        limit 5) R
        where s.Nazione = _Nazione
			and not exists ( select ''
								from PoP
                                where Server = S.codice
									and Film = R.FIlm);
        
	end loop ciclo;
	close cur;
end $$
delimiter ;

drop procedure if exists NazionePrincipale;
delimiter $$
create procedure NazionePrincipale(IN _Utente char(20), OUT Nazione_ varchar(60))
begin
	declare tmp int default 0;
    
	select C.Nazione
		into Nazione_
    from Connessione C
    where C.Utente = _Utente
    group by C.Nazione
    having count(*) >= all (select count(*)
						from Connessione
                        where Utente = _Utente
                        group by Nazione)
    limit 1;
end $$
delimiter ;

-- insertPoP fatto secondo RatingFilm
drop procedure if exists InsertPoP_RatingFilm;
delimiter $$
create procedure InsertPoP_RatingFilm()
begin
	insert into pop
    select s.codice, R.film
    from server s
		join (Select RF.Film
				from RatingFilm RF
                order by Rating desc
                limit 10) R
	where not exists(select ''
						from PoP
                        where Server = s.codice
							and Film = R.Film);
end $$
delimiter ;
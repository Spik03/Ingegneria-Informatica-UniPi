SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

USE `FilmSphere`;

-- Rating Utente
Drop table if exists RatingUtente;
Create table RatingUtente(
	Utente char(20) not null,
	Film int not null,
    Rating int not null,
    primary key(Utente, Film),
    Foreign Key(Film) references `Film`(`ID`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    Foreign Key(Utente) references `Utente`(`NomeUtente`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    check(Rating between 0 and 10)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

Drop event if exists aggiornaRatingUtente;
Delimiter $$
create event aggiornaRatingUtente
on schedule every 1 week
DO
BEGIN
	call InsertRatingUtente();
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS InsertRatingUtente;
Delimiter $$
Create Procedure InsertRatingUtente()
Begin
	declare _Utente char(20);
    DECLARE FINITO bool default false;
    Declare cur Cursor for(
		select NomeUtente
        from Utente
    );
    Declare continue handler for not found
		set finito = true;
        
	truncate RatingUtente;
    
	open cur;
    ciclo : loop
		fetch cur into _Utente;
        if finito then 
				leave ciclo;
		end if;
        
        Insert into RatingUtente
		with NumeroGeneriPreferiti as(
			select A.Film, SUM(if( A.Genere = Any (select Genere from PreferireG where Utente = _Utente),1,0)) as NG
			from Appartenere A
			group by A.Film
		), NumeroAttoriPreferiti as(
			select R.Film, SUM(if( R.Attore = Any (select Attore from PreferireA where Utente = _Utente),1,0)) as NA
			from Recitazione R
			group by R.Film
		), MediaPreferito as(
			select id as Film, if( media = Any (select Media from PreferireM where Utente = _Utente),1,0) as M, voto
			from Film F
		), RegistaPreferito as(
			select id as Film, if( Regista = any (select Regista from PreferireR where Utente = _Utente),1,0) as R
			from Film F
		)
		select _Utente, F.Film, ((F.Rating*5 + 10*(NG.NG + NA.NA + M.M + R.R ))
				/(5 + NG.NG + NA.NA + M.M + R.R)) as Rating
		from RatingFilm F
			inner join NumeroGeneriPreferiti NG
				on F.Film = NG.Film
			inner join NumeroAttoriPreferiti NA
				on F.Film = NA.Film
			inner join MediaPreferito M
				on F.Film = M.Film
			inner join RegistaPreferito R
				on F.Film = R.Film
		order by Rating desc, F.Rating desc, voto desc -- ordino per ratingUtente, RatingFilm e voto della media ponderata recensioni/critiche
        Limit 10;
            
	end loop ciclo;
	close cur;
END $$
Delimiter ;
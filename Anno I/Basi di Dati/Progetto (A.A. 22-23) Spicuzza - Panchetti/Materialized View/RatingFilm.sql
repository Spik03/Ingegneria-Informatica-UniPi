SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

USE `FilmSphere`;

-- Rating Film
Drop Table if exists RatingFilm;
Create table RatingFilm(
	Film int not null,
    Rating int not null,
    primary key(Film),
    Foreign Key(Film) references `Film`(`ID`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    check(Rating between 0 and 10)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

Drop event if exists aggiornaRatingFilm;
Delimiter $$
create event aggiornaRatingFilm
on schedule every 1 week
DO
BEGIN
	call InsertRatingFilm();
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS InsertRatingFilm;
Delimiter $$
Create Procedure InsertRatingFilm()
Begin
	truncate RatingFilm;
    
	Insert into RatingFilm
    with MediaPopolaritaAttori as(
		select Film, AVG(A.Popolarita) as MPA
        From Recitazione R
			inner join Attore A
            on R.Attore = A.CodiceFiscale
		group by Film
    )
    select ID, ((Voto + (M.MPA + R.Popolarita)*0.5)/2) as Rating
    from Film F
		inner join MediaPopolaritaAttori M
        on F.ID = M.Film
        inner join Regista R
        on F.Regista = R.CodiceFiscale;
END $$
Delimiter ;
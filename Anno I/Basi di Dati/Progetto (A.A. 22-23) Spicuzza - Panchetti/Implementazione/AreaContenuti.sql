SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;
set @serverCentrale = 583;

-- Area Contenuti
USE `FilmSphere`;

-- Media --
DROP TABLE IF EXISTS Media;
Create Table  Media(
	Tipo varchar(20) not null,
    Primary Key(Tipo)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Genere --
DROP TABLE IF EXISTS Genere;
Create Table  Genere(
	Nome varchar(20) not null,
    Primary Key(Nome)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Attore --
DROP TABLE IF EXISTS Attore;
Create Table  Attore(
	CodiceFiscale varchar(16) not null,
    Nome char(20) not null,
    Cognome char(30) not null,
    DataNascita date not null,
    Popolarita int not null default 0,
    NomeDarte char(30) default NULL,
    Primary Key(CodiceFiscale),
    check(Popolarita BETWEEN 0 and 10)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TRIGGER IF EXISTS ControlloAttore;
DELIMITER $$
CREATE TRIGGER ControlloAttore
BEFORE INSERT ON Attore
FOR EACH ROW
BEGIN
	IF NEW.DataNascita > CURRENT_DATE() THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Un Attore non può avere una data di nascita maggiore di quella odierna";
	END IF;
END $$
DELIMITER ;

-- Regista --
DROP TABLE IF EXISTS Regista;
Create Table  Regista(
	CodiceFiscale varchar(16) not null,
    Nome char(20) not null,
    Cognome char(30) not null,
    DataNascita date not null,
    Popolarita int not null default 0,
    Primary Key(CodiceFiscale),
    check(Popolarita BETWEEN 0 and 10)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TRIGGER IF EXISTS ControlloRegista;
DELIMITER $$
CREATE TRIGGER ControlloRegista
BEFORE INSERT ON Regista
FOR EACH ROW
BEGIN
	IF NEW.DataNascita > CURRENT_DATE() THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Un regista non può avere una data di nascita maggiore di quella odierna";
	END IF;
END $$
DELIMITER ;

-- Lingua -- 
DROP TABLE IF EXISTS Lingua;
Create Table  Lingua(
	Lingua varchar(20) not null,
    Primary Key(Lingua)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Classificazione --
DROP TABLE IF EXISTS Classificazione;
Create Table  Classificazione(
	Categoria varchar(5) not null,
    Primary Key(Categoria)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Film --
DROP TABLE IF EXISTS Film;
Create Table Film(
	ID int not null Auto_increment,
    Titolo varchar(255) not null,
    Descrizione varchar(255) not null,
    Durata int not null,
    AnnoProduzione int(4) not null,
    Voto int not null,
    TotaleRecensioni int not null,
    Media varchar(20) not null,
    Regista varchar(16) not null,
    Classificazione varchar(5) not null,
    Nazione varchar(60) not null,
    Primary key(ID),
    Check (Durata > 0),
    check (voto BETWEEN 0 and 10),
    check (TotaleRecensioni >= 0),
    foreign key(Media) references `Media`(`Tipo`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(Regista) references `Regista`(`CodiceFiscale`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(Classificazione) references `Classificazione`(`Categoria`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(Nazione) references `Nazione`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TRIGGER IF EXISTS ControlloFilm;
DELIMITER $$
CREATE TRIGGER ControlloFilm
BEFORE INSERT ON Film
FOR EACH ROW
BEGIN
	IF NEW.AnnoProduzione > Year(CURRENT_DATE()) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Un Film non può avere una data di Produzione maggiore di quella odierna!";
	elseif (new.annoProduzione > (select DataNascita from Regista where CodiceFiscale = new.Regista)) then
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Un Film non può avere come regista una persona non ancora nata all'epoca!";
	END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS aggiorna_ridondanza_Popolarita;
delimiter $$
CREATE TRIGGER aggiorna_ridondanza_Popolarita
After UPDATE ON Film
FOR EACH ROW
Begin	
	CALL Calcolo_Popolarita_attore_Recitante(new.ID);
    CALL Calcolo_Popolarita_Regista_Direttore(New.ID);
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS Calcolo_Popolarita_attore_Recitante;
DELIMITER $$
CREATE PROCEDURE Calcolo_Popolarita_attore_Recitante(IN _FILM INT)
BEGIN
	DECLARE codFiscale VARCHAR(16);
    DECLARE media int default 0;
    DECLARE FINITO bool default false;
    Declare cur Cursor for(
		select distinct R.Attore
        from Recitazione R
		where R.Film = _FILM
    );
    Declare continue handler for not found
		set finito = true;
	open cur;
    ciclo : loop
		fetch cur into codFiscale;
        if finito then 
				leave ciclo;
		end if;
            
		call PopolaritaAttore(codFiscale, media);
        
		UPDATE Attore 
		SET Popolarita = media
		where CodiceFiscale = (SELECT distinct r.Attore FROM Recitazione r WHERE r.Attore = codFiscale);
            
	end loop ciclo;
	close cur;
END $$
DELimiter ;

DROP PROCEDURE IF EXISTS Calcolo_Popolarita_Regista_Direttore;
DELIMITER $$
CREATE PROCEDURE Calcolo_Popolarita_Regista_Direttore(IN _FILM INT)
BEGIN
    DECLARE codFiscale varchar(16) default null;
	DECLARE media int default 0;
    
    select Regista into codFiscale
    from Film
    where ID = _Film;
    
    call PopolaritaRegista(codFiscale, media);
    
	update Regista
    Set Popolarita = media
    Where CodiceFiscale = (Select regista from Film where ID=_Film);
END $$
DELimiter ;

drop trigger if exists AggiuntaNelServerCentrale;
delimiter $$
create trigger AggiuntaNelServerCentrale
after insert on FIlm
for each row
begin
	insert into PoP(Server, Film) values
		(@serverCentrale, new.id);
end $$
delimiter ;

-- Sottotitolaggio --
DROP TABLE IF EXISTS Sottotitolaggio;
Create Table Sottotitolaggio(
	Film int not null,
    Lingua varchar(20) not null,
    primary key(Film, Lingua),
    foreign key(Film) references `Film`(`ID`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(Lingua) references `Lingua`(`Lingua`)
    ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Doppiaggio --
DROP TABLE IF EXISTS Doppiaggio;
Create Table Doppiaggio(
	Film int not null,
    Lingua varchar(20) not null,
    primary key(Film, Lingua),
    foreign key(Film) references `Film`(`ID`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(Lingua) references `Lingua`(`Lingua`)
    ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Recitazione --
Drop table if exists Recitazione;
create table Recitazione(
	Film int not null,
   	Attore varchar(16) not null,
   	foreign key(Film) references `Film`(`ID`)
	ON DELETE CASCADE ON UPDATE CASCADE,
	foreign key(Attore) references `Attore`(`CodiceFiscale`)
   	ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

drop trigger if exists insertRecitazione;
delimiter $$
create trigger insertRecitazione
before insert on Recitazione
for each row
begin
	declare annoProduzione int;
    declare annoNascita int;
    
    select year(DataNascita) into annoNascita
    from attore
    where codiceFiscale = new.Attore;
    
    select annoProduzione into annoProduzione
    from film
    where id = new.film;
    
    if(annoProduzione < annoNascita) then
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Un attore non può recitare in un film se non ancora nato!";
	end if;
end $$
delimiter ;

-- Critica --
Drop table if exists Critica;
create table Critica(
	Film int not null,
	Critico varchar(16) not null,
    Voto int not null,
    Commento varchar(255) not null,
	foreign key(Film) references `Film`(`ID`)
	ON DELETE CASCADE ON UPDATE CASCADE,
	foreign key(Critico) references `Critico`(`CodiceFiscale`)
   	ON DELETE CASCADE ON UPDATE CASCADE,
    check (voto BETWEEN 0 and 10)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

drop trigger if exists InsertCritica;
delimiter $$
create trigger InsertCritica
before insert on Critica
for each row
begin
	if exists(Select ''
				from Critica c
				where c.Film = new.Film
					and c.Critico = new.Critico) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Un Critico non può criticare due volte lo stesso film";
	END IF;
END $$
Delimiter ;

drop trigger if exists Aggiorna_ridondanza_Critica;
delimiter $$
create trigger Aggiorna_ridondanza_Critica
after insert on Critica
for each row
begin
	update Film F
    set TotaleRecensioni = TotaleRecensioni +2,
		F.Voto = (F.Voto * (TotaleRecensioni -2) + new.Voto*2)/(TotaleRecensioni)
	where ID = new.Film;
end $$
delimiter ;

-- Appartenere --
Drop Table if exists Appartenere;
Create Table Appartenere(
	Film int not null,
    Genere varchar(20) not null,
	foreign key(Film) references `Film`(`ID`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(Genere) references `Genere`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Recensione --
Drop table if exists Recensione;
create table Recensione(
	Film int not null,
	Utente varchar(16) not null,
	Voto int not null,
	commento varchar(255) default '',
	foreign key(Film) references `Film`(`ID`)
	ON DELETE CASCADE ON UPDATE CASCADE,
	foreign key(Utente) references `Utente`(`NomeUtente`)
   	ON DELETE CASCADE ON UPDATE CASCADE,
    check (voto BETWEEN 0 and 10)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

drop trigger if exists InsertRecensione;
delimiter $$
create trigger InsertRecensione
before insert on Recensione
for each row
begin
	if (not exists(Select ''
					from cronologia c
                    where c.Film = new.Film
						and c.NomeUtente = new.Utente)
		or exists(Select ''
					from Recensione r
                    where r.Film = new.Film
						and r.Utente = new.Utente))THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Film non visualizzato dall'utente o già recensito!";
	END IF;
end $$
delimiter ;

drop trigger if exists Aggiorna_ridondanza_Recensione;
delimiter $$
create trigger Aggiorna_ridondanza_Recensione
after insert on Recensione
for each row
begin
	update Film F
    set TotaleRecensioni = TotaleRecensioni +1,
		F.Voto = (F.Voto * (TotaleRecensioni-1) + new.Voto)/(TotaleRecensioni)
	where ID = new.Film;
end $$
delimiter ;


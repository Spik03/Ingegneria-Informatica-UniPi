SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;
-- variabile globale per scopi implementativi
-- in modo tale da non ostacolare il popolamento di
-- istanze che risultano passate nel tempo
Set @presente = false;
set @serverCentrale = 583;

DROP DATABASE IF EXISTS `FilmSphere`; 
CREATE DATABASE IF NOT EXISTS `FilmSphere`; 


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

-- Abbonamento --
DROP TABLE IF EXISTS Abbonamento;
Create Table  Abbonamento(
	Nome varchar(20) not null,
    DownloadOffline boolean not null,
    OreMassime int(10),
    Costo int not null,
    Primary Key(Nome),
    check(OreMassime IS NULL or OreMassime > 0),
    check(Costo > 0)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Carta -- 
DROP TABLE IF EXISTS Carta;
Create Table  Carta(
	NumeroCarta varchar(16) not null,
    CVC int(3) not null,
    NomeProprietario char(20) not null,
    CognomeProprietario char(30) not null,
    Scadenza date not null,
    Primary Key(NumeroCarta)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

--  Critico --
DROP TABLE IF EXISTS Critico;
Create Table  Critico(
	CodiceFiscale varchar(16) not null,
    Nome char(20) not null,
    Cognome char(30) not null,
    DataNascita date not null,
    Primary Key(CodiceFiscale)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TRIGGER IF EXISTS ControlloCritico;
DELIMITER $$
CREATE TRIGGER ControlloCritico
BEFORE INSERT ON Critico
FOR EACH ROW
BEGIN
	IF NEW.DataNascita > CURRENT_DATE() THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Un Critico non può avere una data di nascita maggiore di quella odierna";
	END IF;
END $$
DELIMITER ;

-- Audio --
DROP TABLE IF EXISTS Audio;
Create Table Audio(
	Nome varchar(20) not null,
    Versione float not null,
    Dimensione int(10) not null,
    Bitrate int(10) not null,
    Qualita varchar(20) not null,
    Tipologia varchar(20) not null,
    Primary key(Nome,Versione),
    Check(Bitrate > 0),
    check(Dimensione > 0),
    Check(Versione > 0.0)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Video --
DROP TABLE IF EXISTS Video;
Create Table Video(
	Nome varchar(20) not null,
    Versione float not null,
    Dimensione int(10) not null,
    Bitrate int(10) not null,
    Risoluzione varchar(20) not null,
    RapportoDaspetto varchar(20) not null,
    Primary key(Nome,Versione),
    Check(Bitrate > 0),
    check(Dimensione > 0),
    Check(Versione > 0.0)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dispositivo --
DROP TABLE IF EXISTS Dispositivo;
Create Table Dispositivo(
	Marca varchar(20) not null,
    Modello varchar(20) not null,
    Tipologia varchar(15) not null,
    Primary key(Marca,Modello)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Nazione --
DROP TABLE IF EXISTS Nazione;
Create Table Nazione(
	Nome varchar(60) not null,
    Latitudine decimal(8,6) not null,
    Longitudine decimal(9,6) not null,
    Primary key(Nome)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

drop trigger if exists InsertNazione;
delimiter $$
create trigger InsertNazione
BEFORE INSERT ON Nazione
FOR EACH ROW
BEGIN
	IF Exists (Select ''
				From Nazione
                Where Latitudine = new.Latitudine 
					and Longitudine = new.Longitudine) Then
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Due Nazioni non possono avere le stesse coordinate!";
	END IF;
END $$
DELIMITER ;

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

-- Utente --
Drop table if exists Utente;
create table Utente(
	NomeUtente char(20) not null,
    Nome char(20) not null,
    Cognome char(30) not null,
    DataNascita date not null,
    mail varchar(30) not null,
    Password varchar(10) not null,
    Abbonamento varchar(20),
    primary key(nomeUtente),
    foreign key(Abbonamento) references `Abbonamento`(`Nome`)
	ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TRIGGER IF EXISTS ControlloUtente;
DELIMITER $$
CREATE TRIGGER ControlloUtente
BEFORE INSERT ON Utente
FOR EACH ROW
BEGIN
	IF NEW.DataNascita > CURRENT_DATE() THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Un Utente non può avere una data di nascita maggiore di quella odierna";
	END IF;
END $$
DELIMITER ;

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

-- Escludere(classficazione) --
Drop table if exists EscludereC;
create table EscludereC (
	Abbonamento varchar(20) not null,
    Classificazione varchar(5) not null,
    foreign key(Abbonamento) references `Abbonamento`(`Nome`)
	ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(Classificazione) references `Classificazione`(`Categoria`)
	ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Escludere(Media) --
Drop table if exists EscludereM;
create table EscludereM (
	Abbonamento varchar(20) not null,
    Media varchar(20) not null,
    foreign key(Abbonamento) references `Abbonamento`(`Nome`)
	ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(Media) references `Media`(`Tipo`)
	ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Fatturazione --
Drop table if exists Fatturazione;
Create table Fatturazione(
	NumeroFattura int not null auto_increment,
    DataPagamento date not null,
    Costo int not null,
    Utente varchar(20) not null,
    Carta varchar(16) not null,
    Primary key(NumeroFattura),
    Foreign key(Utente) references `Utente`(`NomeUtente`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    Foreign key(Carta) references `Carta`(`NumeroCarta`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    check(Costo > 0)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

drop trigger if exists DurataAbbonamento;
DELIMITER $$
CREATE TRIGGER DurataAbbonamento
After insert on Fatturazione
FOR EACH ROW
BEGIN
	if(@presente) then
		call ScadenzaAbbonamento;
	end if;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS ControlloFattura;
DELIMITER $$
CREATE TRIGGER ControlloFattura
BEFORE INSERT ON Fatturazione
FOR EACH ROW
BEGIN
	IF NEW.DataPagamento > CURRENT_DATE() THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Una Fattura non può avere una data di Fatturazione maggiore di quella odierna!abbonamentocronologia";
	ELSEIF (Select scadenza
			From Carta
            Where NumeroCarta = NEW.Carta) < new.DataPagamento THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Una Fattura non può essere pagata con una carta scaduta!";
	ELSEIF (new.costo <> all (select Costo from abbonamento)) then
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "Il costo non coincide con quello di nessun abbonamento!";
    END IF;
END $$
DELIMITER ;

DROP EVENT IF EXISTS ScadenzaAbbonamento;
DELIMITER $$
Create EVENT ScadenzaAbbonamento
ON SCHEDULE AT current_date + interval 1 month
DO
	UPDATE Utente
    set Abbonamento = null
    where NomeUtente = (select Utente
						from Fatturazione
                        where DataFatturazione = current_date - interval 1 month )
Delimiter ;


-- Preferire(Regista) --
Drop table if exists PreferireR;
create table PreferireR(
	Utente char(20) not null,
    Regista varchar(16) not null,
    foreign key(Utente) references `Utente`(`NomeUtente`)
	ON DELETE CASCADE ON UPDATE CASCADE,
	foreign key(Regista) references `Regista`(`CodiceFiscale`)
   	ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Preferire(Attore) --
Drop table if exists PreferireA;
create table PreferireA(
	Utente char(20) not null,
    Attore varchar(16) not null,
    foreign key(Utente) references `Utente`(`NomeUtente`)
	ON DELETE CASCADE ON UPDATE CASCADE,
	foreign key(Attore) references `Attore`(`CodiceFiscale`)
   	ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Preferire(Media) --
Drop table if exists PreferireM;
create table PreferireM(
	Utente char(20) not null,
    Media varchar(20) not null,
    foreign key(Utente) references `Utente`(`NomeUtente`)
	ON DELETE CASCADE ON UPDATE CASCADE,
	foreign key(Media) references `Media`(`Tipo`)
   	ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Preferire(Genere) --
Drop table if exists PreferireG;
create table PreferireG(
	Utente char(20) not null,
    Genere varchar(20) not null,
    foreign key(Utente) references `Utente`(`NomeUtente`)
	ON DELETE CASCADE ON UPDATE CASCADE,
	foreign key(Genere) references `Genere`(`Nome`)
   	ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Connessione --
Drop table if exists Connessione;
create table Connessione(
	IP varchar(19) not null,
    TimestampInizio timestamp not null,
    Utente char(20) not null,
    TimestampFine timestamp default null,
    Nazione varchar(60) not null,
    MarcaDispositivo varchar(20) not null,
    ModelloDispositivo varchar(20) not null,
    primary key(IP, TimestampInizio, Utente),
    foreign key(Utente) references `Utente`(`NomeUtente`)
	ON DELETE CASCADE ON UPDATE CASCADE,
	foreign key(Nazione) references `Nazione`(`Nome`)
   	ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(MarcaDispositivo, ModelloDispositivo) references `Dispositivo`(`Marca`,`Modello`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

drop trigger if exists ControlloConnessione;
DELIMITER $$
CREATE TRIGGER ControlloConnessione
BEFORE INSERT ON Connessione
FOR EACH ROW
BEGIN
	-- Nell'inserimento delle connessioni per il popolamento, non abbiamo inserito i timestampfine (aka sono tutti null)
    -- usando @presente è possibile far sì che il trigger sia attivo "dal presente in poi" (settandolo true)
    -- in questa maniera possiamo inserire connessioni avvenute nel passato e che hanno stesso IP
    IF(@presente) THEN
		-- Due connessioni possono avere lo stesso IP solo se non stanno avvenendo contemporaneamente (lo stesso IP 
		-- può essere usato o meno uno o più utenti, ma non contemporaneamente)
		-- Viene considerata come connessione aperta una connessione con timestampfine is NULL
		-- o quando esiste uno streaming con timestampfine is NULL (il quale si riferisce a una connessione,
		-- in questo caso la connessione potrebbe avere un timestampfine is not null perché è finito precedentemente uno streaming 
		-- che la riguardava)
		IF (exists(select distinct ''
					from Connessione
					where ip = new.ip
						and timestampfine is null)) OR
				(exists(select distinct ''
						from streaming
						where ip = new.ip
							and timestampfine is null)) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Esiste una connessione ancora in corso con lo stesso IP!";
		ELSEIF NEW.TimestampInizio > current_timestamp() THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Una Connessione non può avere un TimestampInizio maggiore di quello attuale";
		ELSEIF NEW.TimestampFine IS NOT NULL and (NEW.TimestampFine < new.TimeStampInizio OR NEW.TimestampFine > current_timestamp()) THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "TimestampFine della Connessione non valido";
		ELSEIF (exists (select ''
							from Connessione C
                            where c.Utente = new.Utente
                            and c.timestampFine is null)) then
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "L'utente ha un'altra connessione avviata!";
		           
        END IF;
	END IF;
END $$
DELIMITER ;

drop trigger if exists UpdateConnessione;
DELIMITER $$
CREATE TRIGGER updateConnessione
BEFORE UPDATE ON Connessione
FOR EACH ROW
BEGIN
	IF NEW.TimestampFine IS NOT NULL and (NEW.TimestampFine < new.TimeStampInizio OR NEW.TimestampFine > current_timestamp()) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "TimestampFine della Connessione non valido";
    END IF;
END $$
DELIMITER ;

-- Formato --
Drop table if exists Formato;
create table Formato( 
	Tipo varchar(20) not null,
    Versione float not null,
    TipoAudio varchar(20) not null,
    VersioneAudio float not null,
    TipoVideo varchar(20) not null,
    VersioneVideo float not null,
    primary key(Tipo,Versione),
    foreign key(TipoAudio, VersioneAudio) references `Audio`(`Nome`,`Versione`)
	ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(TipoVideo, VersioneVideo) references `Video`(`Nome`,`Versione`)
	ON DELETE CASCADE ON UPDATE CASCADE,
    Check(Versione > 0.0)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TRIGGER IF EXISTS ControlloFormato;
DELIMITER $$
CREATE TRIGGER controlloFormato
BEFORE Insert ON Formato
FOR EACH ROW
BEGIN
	IF Exists (Select '' 
				from Formato 
                where TipoAudio = new.TipoAudio and VersioneAudio = new.VersioneAudio
					and TipoVideo = new.TipoVideo and VersioneVideo = new.VersioneVideo) THEN
        SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "Non possono esistere due formati con le stesse specifiche tecniche";
    END IF;
END $$
DELIMITER ;

-- Cronologia --
Drop table if exists Cronologia;
create table Cronologia(
	Film int not null,
    IP varchar(19) not null,
    TimestampInizio timestamp not null,
    NomeUtente char(20) not null,
    primary key(Film, Ip, TimestampInizio, NomeUtente),
    foreign key(Film) references `Film`(`ID`)
	ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(IP, TimestampInizio, NomeUtente) references `Connessione`(`IP`,`TimestampInizio`,`Utente`)
	ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(NomeUtente) references `Utente`(`NomeUtente`)
	ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

drop trigger if exists InsertCronologia;
delimiter $$
create trigger InsertCronologia
before insert on cronologia
for each row
begin
	declare nomeUtente char(20);
    select utente
		into nomeUtente
	from connessione
    where ip = new.ip
		and timestampinizio = new.timestampinizio;
	-- è possibile aggiugnere un film in cronologia solo se l'utente è abbonato al momento della visione
    -- ciò è valido sia al presente che al passato
	if ((select U.abbonamento
		from utente U
        where U.nomeUtente = nomeUtente) is null and date(new.timestampinizio) = current_date()) then
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "L'utente non è abbonato!";
	elseif not exists( select''
						from Fatturazione
						where date(new.timestampinizio) between DataPagamento and (DataPagamento + interval 1 month)) then
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "L'utente non era abbonato!";
    end if;
end $$
delimiter ;

-- Vietato --
Drop table if exists Vietato;
create table Vietato(
	TipoFormato varchar(20) not null,
    VersioneFormato float not null,
    Nazione varchar(60) not null,
    primary key(TipoFormato, VersioneFormato, Nazione),
    foreign key(TipoFormato, VersioneFormato) references `Formato`(`Tipo`,`Versione`)
	ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(Nazione) references `Nazione`(`Nome`)
	ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Versione --
Drop table if exists Versione;
create table Versione(
	Film int not null,
	TipoFormato varchar(20) not null,
    VersioneFormato float not null,
    primary key(Film, TipoFormato, VersioneFormato),
    foreign key(TipoFormato, VersioneFormato) references `Formato`(`Tipo`,`Versione`)
	ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(Film) references `Film`(`ID`)
	ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

drop procedure if exists insert_random_versione;
delimiter $$
create procedure insert_random_versione()
Begin
	DECLARE IDF int; 
	DECLARE FINITO bool default false;
    Declare cur Cursor for(
		select ID
        from Film
    );
    Declare continue handler for not found
		set finito = true;
	open cur;
    ciclo : loop
		fetch cur into IDF;
        if finito then 
				leave ciclo;
		end if;
        
	Insert into Versione (Film, TipoFormato, VersioneFormato)
	Select T.ID, F.Tipo, F.versione
	from Film T
		Join (
			Select Tipo, Versione
			from Formato F
			order by RAND()
			Limit 4
			) F
	where T.ID = IDF;
    
	end loop ciclo;
	close cur;
END $$
Delimiter ;

-- Supportare(Audio) --
Drop table if exists SupportareA;
create table SupportareA(
	MarcaDispositivo varchar(20) not null,
    ModelloDispositivo varchar(20) not null,
    TipoAudio varchar(20) not null,
    VersioneAudio float not null,
    foreign key(MarcaDispositivo, ModelloDispositivo) references `Dispositivo`(`Marca`,`Modello`)
    ON DELETE CASCADE ON UPDATE CASCADE,
	foreign key(TipoAudio, VersioneAudio) references `Audio`(`Nome`,`Versione`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Supportare(Video) --
Drop table if exists SupportareV;
create table SupportareV(
	MarcaDispositivo varchar(20) not null,
    ModelloDispositivo varchar(20) not null,
    TipoVideo varchar(20) not null,
    VersioneVideo float not null,
    foreign key(MarcaDispositivo, ModelloDispositivo) references `Dispositivo`(`Marca`,`Modello`)
    ON DELETE CASCADE ON UPDATE CASCADE,
	foreign key(TipoVideo, VersioneVideo) references `Video`(`Nome`,`Versione`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Server --
Drop table if exists Server;
Create table Server(
	Codice int not null auto_increment,
    LarghezzaBanda int not null,
    ConnessioniAttuali int not null default 0,
    Nazione varchar(60) not null,
    primary key(codice),
    foreign key(Nazione) references `Nazione`(`Nome`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    check(LarghezzaBanda >= 0),
    check(ConnessioniAttuali Between 0 and LarghezzaBanda)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TRIGGER IF EXISTS UpdateServer;
DELIMITER $$
CREATE TRIGGER UpdateServer
BEFORE Update ON Server
FOR EACH ROW
BEGIN
	IF NEW.ConnessioniAttuali < 0 OR NEW.ConnessioniAttuali > new.LarghezzaBanda THEN
        SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "ConnessioniAttuali non valido";
    END IF;
END $$
DELIMITER ;

-- Streaming --
Drop table if exists Streaming;
create table Streaming(
	codice int not null auto_increment,
	CodiceServer int not null,
    IP varchar(19) not null,
    TimestampInizio timestamp not null,
    NomeUtente char(20) not null,
    TimeStampFine timestamp,
    Primary key(codice),
    foreign key(IP, TimestampInizio, NomeUtente) references `Connessione`(`IP`,`TimestampInizio`,`Utente`)
	ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(NomeUtente) references `Utente`(`NomeUtente`)
	ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key(CodiceServer) references `server`(`codice`)
	ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TRIGGER IF EXISTS InsertStreaming;
DELIMITER $$
CREATE TRIGGER InsertStreaming
BEFORE Insert ON Streaming
FOR EACH ROW
BEGIN
	declare LargBanda int;
    declare conAttuali int;
    
    if exists( select ''
				from streaming
                where timestampfine is NULL
					and ip = new.ip
                    and timestampinizio = new.TimestampInizio
                    and NomeUtente = new.NomeUtente) THEN
         SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "Esiste già uno streaming aperto sulla connessione";
	end if;
    
    select s.LarghezzaBanda, s.ConnessioniAttuali
		into LargBanda, conAttuali
	from server s
    where s.codice = new.CodiceServer;
	
    if(LargBanda < (conAttuali +1) and new.TimestampFine is null) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "Server non Disponibile";
	-- se timestampfine is not null al momento dell'inserimento, si sta inserendo, uno streaming già concluso avvenuto in precedenza
	elseif (new.timestampFine is not null and (new.timestampFine not between new.timestampInizio and current_timestamp())) then
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "TimestampFine non valido";
	elseif(new.timestampFine is null) then
		update Server
        set ConnessioniAttuali = conAttuali +1
        where codice = new.codiceServer;
	elseif(new.timestampfine is not null) then
		update connessione
        set timestampfine = new.timestampfine
        where (IP = new.IP and TimestampInizio = new.timestampInizio and utente=new.nomeUtente);
	END IF;
END $$
Delimiter ;

DROP TRIGGER IF EXISTS UpdateStreaming;
DELIMITER $$
CREATE TRIGGER updateStreaming
BEFORE UPDATE ON Streaming
FOR EACH ROW
BEGIN
	IF NEW.timestampfine < ANY( select timestampfine
								from streaming
								where ip = new.IP
									and timestampinizio = new.TimestampInizio
                                    and NomeUtente = new.NomeUtente) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "Uno streaming di una connessione non può finire in un tempo precedente ad un altro della medesima connessione!";
	END IF;
    
	IF NEW.TimestampFine IS NOT NULL and (NEW.TimestampFine < TimeStampInizio OR NEW.TimestampFine > current_timestamp()) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "TimestampFine della Connessione non valido";
	else
		UPDATE Connessione C
        Set TimeStampFine = New.TimestampFine
        Where C.IP = new.IP AND C.Timestampinizio = new.Timestampinizio and Utente = new.NomeUtente;
    END IF;
    
    IF(new.timestampfine is not null) then
		update server
        set connessioniattuali = connessioniattuali - 1
        where codice = new.codiceserver;
	END IF;
END $$
DELIMITER ;

drop trigger if exists DeleteStreaming;
DELIMITER $$
CREATE TRIGGER DeleteStreaming
before delete on Streaming
for each row
begin
	if (old.timeStampFine is null) then
		update server
        set ConnessioniAttuali = ConnessioniAttuali - 1
        where codice = old.codiceserver;
        
		update Connessione C
        set C.TimestampFine = current_timestamp()
        where C.ip = old.ip 
			and c.NomeUtente = old.NomeUtente
            and c.timestampInizio = old.TimestampInizio;
    end if;
end $$
delimiter ;

-- Scaricato
drop table if exists Scaricato;
create table Scaricato(
	IP varchar(19) not null,
    TimestampInizio timestamp not null,
    Utente char(20) not null,
    Film int not null,
    visualizzato bool not null default false,
    primary key(IP, TimestampInizio, Utente, Film),
    Foreign Key(Film) references `Film`(`ID`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    Foreign Key(Ip, TimestampInizio, Utente) references `Connessione`(`Ip`, `TimestampInizio`, `Utente`)
    ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

drop trigger if exists InsertScaricato;
delimiter $$
create trigger InsertScaricato
before insert on Scaricato
for each row
begin
	if( exists( select''
				from Scaricato S
                where new.Ip = S.Ip
					and new.TimestampInizio = S.TimestampInizio
                    and new.Utente = S.Utente)) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "Film già Scaricato!";
	END IF;
    If new.visualizzato = true then
		-- un film che è stato appena scaricato non può fisicamente essere stato già visto
		set new.visualizzato = false;
	end if;
end $$
delimiter ;

drop trigger if exists deleteScaricato;
delimiter $$
create trigger deleteScaricato
before delete on Scaricato
for each row
begin
	if(old.Visualizzato is true) then
		insert into Cronologia(Film, Ip, TimestampInizio, Utente) values
			(old.film, old.ip, old.timestampInizio, old.Utente);
	end if;
end $$
delimiter ;

-- Materialized View
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

-- Analytics --
-- Classifica
Drop procedure if exists classifica;
Delimiter $$
Create procedure classifica(IN _scelta int, IN _N int, IN _NazioneC varchar(60), IN _NazioneP varchar(60), IN _TipoFormato varchar(20), IN _VersioneFormato float)
begin
-- _scelta: 
-- 0 Classifica Globale per Visualizzazioni
-- 1 Classifica NAZIONale per visualizzazioni
-- 2 Classifica Globale per visualizzazioni di film provenienti da una data _NAZIONEP
-- 3 Classifica Globale per visualizzazioni di film di cui esiste un certo FORMATO
-- 4 Classifica NAZIONale per visualizzazioni di film provenienti da _NAZIONEP
-- 5 Classifica NAZIONale per visualizzazioni di film di cui esiste un certo FORMATO
-- 6 Classifica NAZIONale per visualizzazioni di film provenienti da una data _NAZIONEP di cui esiste un certo FORMATO
-- 7 Classifica Globale per visualizzazioni di film provenienti da una data _NAZIONEP di cui esiste un certo FORMATO
-- con NAZIONale si intendono le visualizzazioni fatte da una data Nazione (_NazioneC)
-- _N = grandezza classifica
	if (_N is null or _N < 1) then
		set _N = 10;
	end if;
    
	if( _scelta not between 0 and 7  ) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = '_Scelta non valida!';
	elseif((_scelta = 1 or _scelta between 4 and 6) and _NazioneC is null) then
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = '_NazioneC non valida!';
	elseif((_scelta = 2 or _scelta = 4 or _scelta between 6 and 7) and _NazioneP is null) then
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = '_NazioneP non valida!';
	elseif( (_scelta=3 or _scelta between 5 and 7) and (_tipoFormato is null or _VersioneFormato is null)) then
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Almeno uno dei valori _Formato non valido!';
	ELSE
		with Classifica as(
			select RF.Film as Codice, Titolo as Film, RF.rating as RatingFilm, Count(*) as Visualizzazioni
				from RatingFilm RF
					inner join Cronologia C
						on RF.Film = C.Film
					inner join Film F
						on F.id = RF.FIlm
					inner join Connessione Cn
						on (C.IP = Cn.IP and C.TimestampInizio = Cn.TimestampInizio
								and C.NomeUtente = Cn.Utente)
				where if(_scelta = 1 or _scelta between 4 and 6, Cn.Nazione = _NazioneC, true) and
						if(_Scelta = 2 or _scelta = 4 or _scelta between 6 and 7, F.Nazione = _NazioneP, true) and
                        if(_scelta = 3 or _scelta between 5 and 7, exists( select ''
																			from Versione V
                                                                            where V.TipoFormato = _TipoFormato and ABS(V.VersioneFormato - _VersioneFormato) < 0.001
																				and V.Film = F.ID), true)
				group by Codice, Film, RatingFilm
				order by Visualizzazioni desc, RF.rating desc
				limit _N
		) 	select Codice, Film, RatingFilm, visualizzazioni
			from Classifica;
	END IF;
end $$
delimiter ;

-- Formati vietati in più nazioni o Film con Versioni vietate in più nazioni
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

-- Operazioni --
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

-- Vedere se un formato è supportato dal dispositivo dell'utente
DROP PROCEDURE if exists isFormatoSupportatodaDispositivo;
delimiter $$
create procedure isFormatoSupportatodaDispositivo(IN _Marca varchar(20), IN _Modello varchar(20), IN _TipoFormato varchar(20), IN _Versione float, OUT Supportato_ bool)
begin
	if( exists(
		select ''
        from Formato F
			inner join SupportareA A
				on F.TipoAudio = A.tipoAudio
					and F.VersioneAudio = A.VersioneAudio
			inner join SupportareV V
				on F.TipoVideo = V.TipoVideo
					and F.VersioneVideo = V.VersioneVideo
		where A.MarcaDispositivo = V.MarcaDispositivo
			and A.ModelloDispositivo = V.ModelloDispositivo
            and A.MarcaDispositivo = _Marca
            and A.ModelloDispositivo = _Modello
            and F.tipo = _TipoFormato
            and F.versione = _Versione) ) then
		set supportato_ = true;
	else
		set supportato_ = false;
	end if;
end $$
delimiter ;

-- calcolo Popolarità di un attore
drop procedure if exists PopolaritaAttore;
delimiter $$
create procedure PopolaritaAttore(IN _Attore varchar(16), OUT Media_ int)
begin
	set Media_ = (select round(avg(f.voto))
					from Film F 
						inner join Recitazione R
							on R.Film = F.ID
					where R.Attore = _Attore);
end $$
delimiter ;

-- calcolo Popolarità di un regista
drop procedure if exists PopolaritaRegista;
delimiter $$
create procedure PopolaritaRegista(IN _Regista varchar(16), OUT Media_ int)
begin
	set Media_ = (select round(avg(f.voto))
					from Film F
					where F.Regista = _Regista);
end $$
delimiter ;

-- Classifica dei film che hanno origine nella stessa Nazione della Connessione
drop procedure if exists ClassificaFilm_stessaNazioneDellaConnessione;
delimiter $$
create procedure ClassificaFilm_stessaNazioneDellaConnessione(IN _IP varchar(19), IN _TimestampInizio timestamp, IN _Utente char(20))
begin
	select F.id as codice, F.Titolo, RF.rating as Voto
    from Film F
		inner join RatingFilm RF
			on F.id = RF.Film
		inner join Connessione C
			on F.Nazione = C.nazione
	where C.ip = _IP 
		and C.timestampInizio = _Timestampinizio
        and C.Utente = _Utente
	order by RF.rating desc
    limit 10;
end $$
delimiter ;

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

-- nuovo streaming
drop procedure if exists NuovoStreaming;
delimiter $$
create procedure NuovoStreaming(IN _IP varchar(19), IN _TimestampInizio timestamp, IN _Utente char(20), IN _Film int, in _TipoFormato varchar(20), IN _versioneFormato float)
begin
	declare _nazione varchar(60);
    declare _latitudine decimal(8,6);
    declare _longitudine decimal(9,6);
    declare _marcaDispositivo varchar(20);
    declare _modelloDispositivo varchar(20);
    declare _supportato bool;
    declare _tempoRimasto int;
    declare _distanza int;
    declare _server int;
    
    select C.Nazione, n.latitudine, n.longitudine, c.MarcaDispositivo, C.modelloDispositivo into _nazione, _latitudine, _longitudine, _marcaDispositivo, _modelloDispositivo
    from Connessione c
		inner join nazione n
			on n.nome = c.Nazione
    where C.IP = _IP 
		and C.TimestampInizio = _TimestampInizio
		and C.Utente = _Utente;
    
    -- se il formato è inserito, va controllato se non è vietato nella Nazione della connessione
	if( (_TipoFormato is not null and _VersioneFormato is not null) and exists( select ''
					from vietato V
					where V.nazione = _nazione
						and V.TipoFormato = _TipoFormato
						and V.VersioneFormato = _VersioneFormato)) then
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Formato non disponibile nella Nazione da dove sta avvenendo la connessione!';
	-- non è obbligatorio inserire il formato, ma eventualmente deve essere valido
	elseif (_TipoFormato is not null and _VersioneFormato is null) or (_TipoFormato is null and _VersioneFormato is not null) then
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Formato non valido!';
	else
        -- se l'utente ha inserito un formato ed è valido, si controlla se è supportato dal dispositivo in uso
		if(_TipoFormato is not null and _VersioneFormato is not null) then
			call isFormatoSupportatodaDispositivo(_marcaDispositivo, _ModelloDispositivo , _TipoFormato, _VersioneFormato, _supportato);
			if(_supportato is false) then 
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Formato non supportato dal dispositivo!';
		-- si controlla se esiste il film in tale formato
			elseif( not exists(select ''
								from versione v
								where v.Film = _film
									and v.tipoFormato = _TipoFormato
									and V.versioneFormato = _VersioneFormato)) then
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Non esiste una versione del film con tale formato!';
			else
            -- si controlla se il film dura meno del tempo rimasto all'utente nell'abbonamento, ed eventualmente si cerca il
            -- server più vicino con il film in cache
				call TempoRimasto(_utente, _tempoRimasto);
			-- se _tempoRimasto is null => abbonamento senza limite di tempo
                if( _tempoRimasto is null or _TempoRimasto >= (select Durata
										from Film
										where id = _Film) ) then
				
					select s.codice, ACOS(
						COS(_latitudine / 57.2958) * COS(n.latitudine / 57.2958) * COS(n.longitudine / 57.2958 - _longitudine / 57.2958) +
						SIN(@_latitudine / 57.2958) * SIN(@n.latitudine / 57.2958)
						) * 6371 as distanza into _server, _distanza -- formula trovata online
					from server s
						inner join nazione n
							on s.Nazione = n.nome
					where s.codice in (select p.server
										from PoP p
										where P.server = s.codice
											and p.Film = _Film)
						and S.connessioniAttuali <= LarghezzaBanda
					order by distanza desc
					limit 1;
				
					-- per scopi implementativi simuliamo che il film sia stato visto, aggiunto in cronologia e lo streaming terminato
					insert into streaming(CodiceServer, IP, TimestampInizio, NomeUtente, TimestampFine)
						values(_server, _IP, _TimestampInizio, _Utente, current_timestamp());
					insert into cronologia(Film, Ip, TimestampInizio, NomeUtente)
						values(_Film, _IP, _timestampInizio, _Utente);
				else
					SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT = 'Tempo nell\'abbonamento insufficiente per la visione di tale!';
				end if;
			end if;
        end if;
	end if;
end $$
delimiter ;

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

-- POPOLAMENTO E VariTest
USE `FilmSphere`;

-- Nazione --
INSERT INTO Nazione (Nome, Latitudine, Longitudine) VALUES
('Afghanistan', 34.5553, 69.2075),
('Albania', 41.3275, 19.8187),
('Algeria', 36.7372, 3.0869),
('Andorra', 42.5063, 1.5218),
('Angola', -8.8383, 13.2344),
('Antigua e Barbuda', 17.1175, -61.845),
('Arabia Saudita', 24.7136, 46.6753),
('Argentina', -34.6037, -58.3816),
('Armenia', 40.1872, 44.5152),
('Australia', -35.282, 149.1287),
('Austria', 48.2082, 16.3738),
('Azerbaijan', 40.4093, 49.8671),
('Bahamas', 25.0343, -77.3963),
('Bahrain', 26.2285, 50.586),
('Bangladesh', 23.8103, 90.4125),
('Belarus', 53.9045, 27.5615),
('Barbados', 13.1132, -59.5988),
('Belgio', 50.8503, 4.3517),
('Belize', 17.251, -88.759),
('Benin', 6.5244, 2.4418),
('Bhutan', 27.4728, 89.639),
('Bolivia', -16.5032, -68.1302),
('Bosnia e Erzegovina', 43.8563, 18.4131),
('Botswana', -24.6544, 25.9087),
('Brasile', -15.7801, -47.9292),
('Brunei Darussalam', 4.9031, 114.9403),
('Bulgaria', 42.6977, 23.3219),
('Burkina Faso', 12.3714, -1.5197),
('Burundi', -3.3818, 29.3639),
('Cambogia', 11.5564, 104.9282),
('Camerun', 3.848, 11.5021),
('Canada', 45.4215, -75.6919),
('Capo Verde', 14.933, -23.5133),
('Ciad', 12.1342, 15.0557),
('Cile', -33.4489, -70.6693),
('Cina', 39.9042, 116.4074),
('Cipro', 35.1667, 33.3667),
('Colombia', 4.7109, -74.0721),
('Comore', -11.7172, 43.2479),
('Congo (Repubblica del)', -4.2634, 15.2839),
('Costa Rica', 9.9281, -84.0907),
('Costa d’Avorio', 5.3599, -4.0083),
('Croazia', 45.815, 15.9819),
('Cuba', 23.1136, -82.3666),
('Danimarca', 55.6761, 12.5683),
('Dominica', 15.301, -61.388),
('Ecuador', -0.1807, -78.4678),
('Egitto', 30.0444, 31.2357),
('El Salvador', 13.6929, -89.2182),
('Emirati Arabi Uniti', 24.4539, 54.3773),
('Eritrea', 15.3229, 38.9251),
('Estonia', 59.437, 24.7536),
('Etiopia', 9.0084, 38.7575),
('Macedonia', 41.9962, 21.4314),
('Federazione Russa', 55.7558, 37.6176),
('Figi', -18.1248, 178.4501),
('Filippine', 14.5995, 120.9842),
('Finlandia', 60.1695, 24.9354),
('Francia', 48.8566, 2.3522),
('Gabon', 0.3883, 9.4546),
('Gambia', 13.4527, -16.578),
('Georgia', 41.7151, 44.8271),
('Germania', 52.5200, 13.4050),
('Ghana', 5.6037, -0.187),
('Giamaica', 18.0179, -76.8096),
('Giappone', 35.6895, 139.6917),
('Gibuti', 11.588, 43.145),
('Giordania', 31.9454, 35.9284),
('Grecia', 37.9838, 23.7275),
('Grenada', 12.0524, -61.7538),
('Guatemala', 14.6349, -90.5069),
('Guinea', 9.6412, -13.5784),
('Guinea Equatoriale', 3.7506, 8.7839),
('Guinea-Bissau', 11.863, -15.598),
('Guyana', 6.8013, -58.1551),
('Haiti', 18.5944, -72.3074),
('Honduras', 14.0723, -87.1922),
('India', 28.6139, 77.209),
('Indonesia', -6.2088, 106.8456),
('Iran', 35.6892, 51.389),
('Iraq', 33.3152, 44.3661),
('Irlanda', 53.3498, -6.2603),
('Islanda', 64.1265, -21.8174),
('Israele', 31.7683, 35.2137),
('Italia', 41.9028, 12.4964),
('Kazakistan', 51.1694, 71.4491),
('Kenya', -1.2921, 36.8219),
('Kirghizistan', 42.8746, 74.5698),
('Kiribati', 1.3384, 172.9036),
('Kuwait', 29.3759, 47.9774),
('Laos (Repubblica Democratica Popolare)', 17.9757, 102.6331),
('Lesotho', -29.3167, 27.4833),
('Lettonia', 56.9496, 24.1052),
('Libano', 33.8886, 35.4955),
('Liberia', 6.3004, -10.7969),
('Libia', 32.8872, 13.1913),
('Liechtestein', 47.141, 9.5215),
('Lituania', 54.6872, 25.2797),
('Lussemburgo', 49.6116, 6.1319),
('Madagascar', -18.8792, 47.5079),
('Malawi', -13.9632, 33.7741),
('Malesia', 3.139, 101.6869),
('Maldive', 4.1755, 73.5093),
('Mali', 12.6392, -8.0029),
('Malta', 35.8989, 14.5146),
('Marocco', 31.7917, -7.0926),
('Marshall, Isole', 7.1164, 171.185),
('Mauritania', 18.0735, -15.9582),
('Mauritius', -20.1654, 57.4896),
('Messico', 19.4326, -99.1332),
('Micronesia', 6.924, 158.161),
('Monaco', 43.7384, 7.4246),
('Mongolia', 47.9204, 106.9057),
('Montenegro', 42.4304, 19.2594),
('Mozambico', -25.9664, 32.5892),
('Myanmar', 16.8661, 96.1951),
('Namibia', -22.5597, 17.0832),
('Nauru', -0.5481, 166.9209),
('Nepal', 27.7172, 85.324),
('Nicaragua', 12.1149, -86.2362),
('Niger', 13.5127, 2.1126),
('Nigeria', 9.082, 8.6753),
('Norvegia', 59.9139, 10.7522),
('Nuova Zelanda', -41.2865, 174.7762),
('Oman', 23.6106, 58.59),
('Paesi Bassi', 52.3676, 4.9041),
('Pakistan', 33.6844, 73.0479),
('Palau', 7.5149, 134.5825),
('Panama', 8.9824, -79.5199),
('Papua Nuova Guinea', -9.4438, 147.1803),
('Paraguay', -25.2637, -57.5759),
('Perù', -12.0464, -77.0428),
('Polonia', 52.2297, 21.0122),
('Portogallo', 38.7223, -9.1393),
('Qatar', 25.2854, 51.531),
('Regno Unito', 51.5074, -0.1278),
('Repubblica Ceca', 50.0755, 14.4378),
('Repubblica Centrale Africana', 4.3947, 18.5582),
('Repubblica Democratica del Congo', -4.0383, 21.7587),
('Repubblica Democratica Popolare di Corea', 39.0392, 125.7625),
('Repubblica di Corea', 37.5665, 126.978),
('Repubblica di Moldavia', 47.0167, 28.8497),
('Repubblica Domenicana', 18.479, -69.8908),
('Repubblica Unita di Tanzania', -6.1659, 39.2026),
('Romania', 44.4268, 26.1025),
('Ruanda', -1.9706, 30.1044),
('San Kitts e Nevis', 17.3026, -62.7177),
('Santa Lucia', 14.0101, -60.987),
('Saint Vincent e Grenadine', 13.1658, -61.2246),
('Salomone, Isole', -9.433, 159.955),
('Samoa', -13.833, -171.75),
('San Marino', 43.9424, 12.4578),
('Sao Tomé e Principe', 0.336, 6.730),
('Senegal', 14.6937, -17.4441),
('Serbia', 44.7866, 20.4489),
('Seychelles', -4.6796, 55.492),
('Sierra Leone', 8.484, -13.2299),
('Singapore', 1.3521, 103.8198),
('Siria', 33.5138, 36.2765),
('Slovacchia', 48.1486, 17.1077),
('Slovenia', 46.0569, 14.5058),
('Somalia', 2.0469, 45.3182),
('Spagna', 40.4168, -3.7038),
('Sri Lanka', 6.9271, 79.8612),
('Stati Uniti d`America', 38.8951, -77.0364),
('Sud Africa', -25.746, 28.1871),
('Sudan', 15.5007, 32.5599),
('Sud Sudan', 4.8594, 31.5713),
('Suriname', 5.852, -55.2038),
('Svezia', 59.3293, 18.0686),
('Svizzera', 46.2044, 6.1432),
('Swaziland', -26.3054, 31.1367),
('Tagikistan', 38.5737, 68.7738),
('Thailandia', 13.7563, 100.5018),
('Timor Leste', -8.5569, 125.5603),
('Togo', 6.1258, 1.2255),
('Tonga', -21.1393, -175.2049),
('Trinidad e Tobago', 10.6918, -61.2225),
('Tunisia', 36.8065, 10.1815),
('Turchia', 39.9334, 32.8597),
('Turkmenistan', 37.9601, 58.3261),
('Tuvalu', -8.5174, 179.1962),
('Ucraina', 50.4501, 30.5234),
('Uganda', 0.3476, 32.5825),
('Ungheria', 47.4979, 19.0402),
('Uruguay', -34.9011, -56.1645),
('Uzbekistan', 41.2995, 69.2401),
('Vanuatu', -17.7404, 168.321),
('Venezuela', 10.4806, -66.9036),
('Viet Nam', 21.0285, 105.8542),
('Yemen', 15.3694, 44.191),
('Zambia', -15.3875, 28.3228),
('Zimbabwe', -17.8252, 31.0335);

-- Lingua
INSERT INTO Lingua (Lingua) VALUES
('Inglese'),
('Spagnolo'),
('Francese'),
('Tedesco'),
('Italiano'),
('Portoghese'),
('Cinese'),
('Giapponese'),
('Russo'),
('Arabo'),
('Hindi'),
('Bengalese'),
('Coreano'),
('Olandese'),
('Svedese');

-- Dispositivo --
INSERT INTO Dispositivo (Marca, Modello, Tipologia) VALUES
('Samsung', 'Galaxy S21', 'Smartphone'),
('Apple', 'iPhone 13', 'Smartphone'),
('Sony', 'PlayStation 5', 'Console'),
('Microsoft', 'XBox Serie X', 'Console'),
('Microsoft', 'Nokia Lumia', 'Smartphone'),
('LG', 'OLED C1', 'TV'),
('Microsoft', 'Surface Pro 7', 'Tablet'),
('Samsung', 'Galaxy Tab S7', 'Tablet'),
('Apple', 'iPad Air', 'Tablet'),
('Sony', 'BRAVIA XR A80J', 'TV'),
('LG', 'NanoCell 85 Series', 'TV'),
('Samsung', 'QLED Q90T', 'TV'),
('Google', 'Pixel 6', 'Smartphone'),
('Xiaomi', 'Mi 11', 'Smartphone'),
('Rumba', 'Galaxy s21', 'Smartphone'),
('Apple', 'iPhone 14 Pro', 'Smartphone'),
('Apple', 'iPhone 15 Pro Max', 'Smartphone'),
('Apple', 'iPhone 12 Mini', 'Smartphone');

-- Media--
INSERT INTO Media (Tipo) VALUES
('Live Action'),
('Animazione'),
('Tecnica Mista');

-- Classificazione--
INSERT INTO Classificazione (Categoria) VALUES
('T'),
('VM6'),
('VM14'),
('VM18');

-- Genere --
INSERT INTO Genere (Nome) VALUES
('Azione'),
('Avventura'),
('Commedia'),
('Drammatico'),
('Fantascienza'),
('Fantasy'),
('Horror'),
('Poliziesco'),
('Romantico'),
('Thriller'),
('Documentario'),
('Biografico'),
('Storico'),
('Musical'),
('Crime'),
('Western'),
('Guerra'),
('Sportivo'),
('Giallo'),
('Supereroi');

-- Regista --
Insert into Regista(CodiceFiscale, Nome, Cognome, DataNascita, Popolarita) Values
('QNTTRNTN63', 'Quentin', 'Tarantino', '1963-03-27', 0),
('TMBRTN2558', 'Tim', 'Burton', '1958-08-25', 0),
('JYPTKA1938', 'Joe', 'Pytka', '1938-11-04', 0),
('NTNHRSS970', 'Anthony', 'Russo', '1970-02-03', 0),
('RBRTLZMCKS', 'Robert', 'Zemeckis', '1952-05-14', 0),
('CHRSTORNLN', 'Christopher', 'Nolan', '1970-07-30', 0),
('CHRLSCPLNC', 'Charles Spencer', 'Chaplin', '1889-04-16', 0);

-- Film --
INSERT ignore INTO Film (Titolo, Descrizione, Durata, AnnoProduzione, Voto, TotaleRecensioni, Media, Regista, Classificazione, Nazione) VALUES
-- Quentin Tarantino
('Pulp Fiction', 'Una serie di storie intrecciate a Los Angeles', 154, 1994, 0, 0, 'Live Action', 'QNTTRNTN63', 'VM6', 'Stati Uniti d`America'),
('Kill Bill: Volume 1', 'Una sposa in cerca di vendetta', 111, 2003, 0, 0, 'Live Action', 'QNTTRNTN63', 'VM18', 'Regno Unito'),
('Django Unchained', 'Un ex schiavo cerca vendetta nel sud degli Stati Uniti', 165, 2012, 0, 0, 'Live Action', 'QNTTRNTN63', 'VM18', 'Italia'),
('Inglourious Basterds', 'Un gruppo di soldati ebrei si batte contro i nazisti', 153, 2009, 0, 0,'Live Action', 'QNTTRNTN63', 'VM14','Francia'),
('Reservoir Dogs', 'Una rapina che va storta e i suoi sviluppi', 99, 1992, 0, 0, 'Live Action', 'QNTTRNTN63', 'VM14', 'Stati Uniti d`America'),
-- Tim Burton
('Edward Scissorhands', 'Un uomo con forbici al posto delle mani', 105, 1990, 0, 0, 'Live Action', 'TMBRTN2558', 'T', 'Stati Uniti d`America'),
('Beetlejuice', 'Fantasmi che cercano di spaventare gli umani', 92, 1988, 0, 0, 'Live Action', 'TMBRTN2558', 'VM6', 'Regno Unito'),
('Batman', 'Un Uomo vestito da Pipistrello affronta Joker a Gotham City', 126, 1989, 0, 0, 'Live Action', 'TMBRTN2558', 'VM14', 'Stati Uniti d`America'),
('Corpse Bride', 'Un dramma in cui morte e amori fanno da padroni', 77, 2005, 0, 0, 'Animazione', 'TMBRTN2558', 'VM6', 'Spagna'),
('Alice in Wonderland', 'Alice esplora il Paese delle Meraviglie', 108, 2010, 0, 0, 'Live Action', 'TMBRTN2558', 'T', 'Paesi Bassi'),
-- Anthony Russo
('Captain America: The Winter Soldier', 'Avventura Marvel con Captain America', 136, 2014, 0, 0, 'Live Action', 'NTNHRSS970', 'VM6', 'Germania'),
('Avengers: Endgame', 'Epica conclusione degli Avengers', 181, 2019, 0, 0, 'Live Action', 'NTNHRSS970', 'T', 'Stati Uniti d`America'),
('Captain America: Civil War', 'Conflitto tra gli eroi Marvel', 147, 2016, 0, 0, 'Live Action', 'NTNHRSS970', 'T', 'Argentina'),
('Avengers: Infinity War', 'Gli Avengers affrontano Thanos', 149, 2018, 0, 0, 'Live Action', 'NTNHRSS970', 'T', 'Brasile'),
('Welcome to Collinwood', 'Un piano di rapina che va storto', 86, 2002, 0, 0, 'Live Action', 'NTNHRSS970', 'VM14', 'Stati Uniti d`America'),
-- Robert Zemeckis
('Forrest Gump', 'La vita straordinaria di Forrest Gump', 142, 1994, 0, 0, 'Live Action', 'RBRTLZMCKS', 'VM6', 'Federazione Russa'),
('Back to the Future', 'Viaggio nel tempo con Marty McFly', 116, 1985, 0, 0, 'Live Action', 'RBRTLZMCKS', 'VM14', 'Federazione Russa'),
('Cast Away', 'La drammatica storia di un uomo disperso in mezzo al nulla, insieme al suo strano amico: una palla', 143, 2000, 0, 0, 'Live Action', 'RBRTLZMCKS', 'T', 'Stati Uniti d`America'),
('The Polar Express', 'Un viaggio magico sulla Polar Express', 100, 2004, 0, 0, 'Animazione', 'RBRTLZMCKS', 'T', 'Stati Uniti d`America'),
('Contact', 'La ricerca di vita extraterrestre', 150, 1997, 0, 0, 'Live Action', 'RBRTLZMCKS', 'VM18', 'Italia'),
('Chi ha incastrato Roger Rabbit', 'Siete curiosi di sapere chi ha incastrato Roger Rabbit? Godetevi il Film' , 104, 1988, 0, 0, 'Tecnica Mista', 'RBRTLZMCKS', 'VM6', 'Stati Uniti d`America'),
-- Joe Pytka
('Space Jam', 'Michael Jordan e Bugs Bunny uniranno le forze in una partita spaziale', 88, 1996, 0, 0, 'Tecnica Mista', 'JYPTKA1938', 'T', 'Nigeria'),
-- Christopher Nolan
('Inception', 'Un ladro esperto si infiltra nei sogni altrui', 148, 2010, 0, 0, 'Live Action', 'CHRSTORNLN', 'VM14', 'Italia'),
('The Dark Knight', 'Batman affronta il criminale Joker', 152, 2008, 0, 0, 'Live Action', 'CHRSTORNLN', 'VM6', 'Spagna'),
('Interstellar', 'Capolavoro cinematografico nello spazio infinito', 169, 2014, 0, 0, 'Live Action', 'CHRSTORNLN', 'VM6', 'Italia'),
('Dunkirk', 'Dunkerque durante la Seconda Guerra Mondiale', 106, 2017, 0, 0, 'Live Action', 'CHRSTORNLN', 'VM18', 'Stati Uniti d`America'),
('The Prestige', 'Due illusionisti ingaggiati in una competizione amara', 130, 2006, 0, 0, 'Live Action', 'CHRSTORNLN', 'VM18', 'Francia'),
-- Charlie Chaplin
('Modern Times', 'Film Muto diretto dal noto attore Charlie Chaplin', 87, 1936, 0, 0, 'Live Action', 'CHRLSCPLNC', 'VM14', 'Francia');

-- Attore --
INSERT INTO Attore (CodiceFiscale, Nome, Cognome, DataNascita, Popolarita, NomeDarte) VALUES
('CHRBLCNHNHMCLNE', 'Christian', 'Bale', '1974-01-30', 0, NULL),
('HGJKMN', 'Hugh', 'Jackman', '1968-10-12', 0, NULL),
('DFTBWW', 'David Robert', 'Jones', '1947-01-08', 0, 'David Bowie'),
('THRSHTM', 'Thomas', 'Hardy', '1977-09-15', 0, 'Tom Hardy'),
('HRRSTLS', 'Harry', 'Styles', '1994-02-01', 0, NULL),
('MTTHWMCNCGH', 'Matthew', 'McConaughey', '1969-11-04', 0, NULL),
('NNHHTHWY', 'Anne', 'Hathaway', '1982-11-12', 0, NULL),
('MCLKN', 'Maurice', 'Micklewhite', '1933-03-14', 0, 'Michael Caine'),
('GRYLDMN', 'Gary', 'Oldman', '1958-03-21', 0, NULL),
('CLLMRPHY', 'Cillian', 'Murphy', '1976-05-25', 0, NULL),
('LDRCPC', 'Leonardo', 'DiCaprio', '1974-11-11', 0, NULL),
('MCHLJRDN', 'Michael', 'Jordan', '1963-02-17', 0, 'MJ'),
('WBRRN', 'Wayne', 'Knight', '1955-08-07', 0, NULL),
('BLLMRY', 'Bill', 'Murray', '1950-09-21', 0, NULL),
('DNNYDVL', 'Danny', 'DeVito', '1944-11-17', 0, NULL),
('THMS', 'Theresa', 'Randle', '1964-12-27', 0, NULL),
('RFYHNT', 'Robin', 'Wright', '1966-04-08', 0, NULL),
('GLNCLS', 'Gary', 'Sinise', '1955-03-17', 0, NULL),
('MCLFX', 'Michael', 'Andrew Fox', '1961-06-09', 0, 'Michael J. Fox'),
('CTHNLRD', 'Christopher', 'Lloyd', '1938-10-22', 0, NULL),
('LTHMPSN', 'Lea', 'Thompson', '1961-05-31', 0, NULL),
('THTMHNKS', 'Thomas', 'Hanks', '1956-07-09', 0, 'Tom Hanks'),
('JDNFSTR', 'Jodie', 'Foster', '1962-11-19', 0, NULL),
('JMK', 'James', 'Kamen', '1920-02-15', 0, NULL),
('BBSHRLY', 'Bob', 'Hoskins', '1942-10-26', 0, NULL),
('CRLWL', 'Christopher', 'Lloyd', '1938-10-22', 0, NULL),
('JNCD', 'Joanna', 'Cassidy', '1945-08-02', 0, NULL),
('CHRNSN', 'Chris', 'Evans', '1981-06-13', 0, NULL),
('SCRLTJHNSN', 'Scarlett', 'Johansson', '1984-11-22', 0, NULL),
('SBSTSTN', 'Sebastian', 'Stan', '1982-08-13', 0, NULL),
('RDDRJ', 'Robert', 'Downey Jr.', '1965-04-04', 0, 'RDJ'),
('CHDWC', 'Chris', 'Hemsworth', '1983-08-11', 0, NULL),
('MRKFRFL', 'Mark', 'Ruffalo', '1967-11-22', 0, NULL),
('JHNNYDPP', 'Johnny', 'Depp', '1963-06-09', 0, NULL),
('WINN', 'Winona', 'Ryder', '1971-10-29', 0, NULL),
('DCTRMRTN', 'Dianne', 'Wiest', '1948-03-28', 0, NULL),
('AGBRCM', 'Alec', 'Baldwin', '1958-04-03', 0, NULL),
('MCHLKN', 'Michael', 'Keaton', '1951-09-05', 0, NULL),
('KMLK', 'Kim', 'Basinger', '1953-12-08', 0, NULL),
('HLCNBNNCRTC', 'Helena', 'Bonham Carter', '1966-05-26', 0, NULL),
('EMLYWTSN', 'Emily', 'Watson', '1967-01-14', 0, NULL),
('MCHSHN', 'Michael', 'Sheen', '1969-02-05', 0, NULL),
('MSSMIA', 'Mia', 'Wasikowska', '1989-10-14', 0, NULL),
('WSLYSNPS', 'William', 'H. Macy', '1950-03-13', 0, NULL),
('ISBL', 'Isaiah', 'Washington', '1963-08-03', 0, NULL),
('SSRCKL', 'Samuel', 'Rockwell', '1968-11-05', 0, 'Sam Rockwell'),
('JHNLRT', 'John', 'Travolta', '1954-02-18', 0, NULL),
('SMLJCKSN', 'Samuel Leroy', 'Jackson', '1948-12-21', 0, 'Samuel L. Jackson'),
('UMT', 'Uma', 'Thurman', '1970-04-29', 0, NULL),
('DRCRDN', 'David', 'Carradine', '1936-12-08', 0, NULL),
('DRLHNNH', 'Daryl', 'Hannah', '1960-12-03', 0, NULL),
('HRLMKR', 'Harvey', 'Keitel', '1939-05-13', 0, NULL),
('TMRRTN', 'Tim', 'Roth', '1961-05-14', 0, NULL),
('STVBSM', 'Steven', 'Buscemi', '1957-12-13', 0, 'Steve Buscemi'),
('BRDPR', 'Bradley', 'Pitt', '1963-12-18', 0, 'Brad Pitt'),
('MLN', 'Mélanie', 'Laurent', '1983-02-21', 0, NULL),
('CHRSTPHWLTZ', 'Christoph', 'Waltz', '1956-10-04', 0, NULL),
('BRCWLLS', 'Bruce', 'Willis', '1955-05-19', 0, NULL),
('JMFXX', 'Jamie', 'Foxx', '1967-12-13', 0, NULL),
('JCKNCHLSN', 'Joseph', 'Nicholson', '1937-04-22', 0, 'Jack Nicholson'),
('CHRLSCPLNC', 'Charles Spencer', 'Chaplin', '1889-04-16', 0, 'Charlie Chaplin');

-- Recitazione --
INSERT INTO Recitazione (Film, Attore) VALUES
-- Pulp Fiction
(1, 'JHNLRT'),
(1, 'UMT'),
(1, 'SMLJCKSN'),
(1, 'BRCWLLS'),
-- Kill Bill: volume 1
(2, 'UMT'),
(2, 'DRCRDN'),
(2, 'DRLHNNH'),
-- Django Unchained
(2, 'JMFXX'),
(2, 'SMLJCKSN'),
(2, 'CHRSTPHWLTZ'),
(3, 'LDRCPC'),
-- INGLURIOUS BASTERDS
(4, 'CHRSTPHWLTZ'),
(4, 'BRDPR'),
(4, 'MLN'),
-- Reservoir Dogs
(5, 'HRLMKR'),
(5, 'TMRRTN'),
(5, 'STVBSM'),
-- Edward Scissorhands
(6, 'JHNNYDPP'),
(6, 'WINN'),
(6, 'DCTRMRTN'),
-- BeetleJuice
(7, 'AGBRCM'),
(7, 'MCHLKN'),
-- Batman
(8, 'MCHLKN'),
(8, 'JCKNCHLSN'),
(8, 'KMLK'),
-- Corpse Bride
(9, 'JHNNYDPP'),
(9, 'EMLYWTSN'),
(9, 'HLCNBNNCRTC'),
-- Alice in Wonderland
(10, 'JHNNYDPP'),
(10, 'NNHHTHWY'),
(10, 'HLCNBNNCRTC'),
(10, 'MSSMIA'),
(10, 'MCHSHN'),
-- Captain America: The Winter Soldier
(11, 'CHRNSN'),
(11, 'SCRLTJHNSN'),
(11, 'SMLJCKSN'),
-- Avengers: Endgame
(12, 'CHRNSN'),
(12, 'SCRLTJHNSN'),
(12, 'SMLJCKSN'),
(12, 'RDDRJ'),
(12, 'MRKFRFL'),
(12, 'CHDWC'),
-- Captain America: Civil War
(13, 'CHRNSN'),
(13, 'SCRLTJHNSN'),
(13, 'SMLJCKSN'),
(13, 'RDDRJ'),
(13, 'MRKFRFL'),
(13, 'SBSTSTN'),
(13, 'CHDWC'),
-- Avengers: Infinity War
(14, 'CHRNSN'),
(14, 'SCRLTJHNSN'),
(14, 'SMLJCKSN'),
(14, 'RDDRJ'),
(14, 'MRKFRFL'),
(14, 'CHDWC'),
-- Welcome to Collinwood
(15, 'ISBL'),
(15, 'SSRCKL'),
(15, 'WSLYSNPS'),
-- Forrest Gump
(16, 'THTMHNKS'),
(16, 'RFYHNT'),
(16, 'GLNCLS'),
-- Back to the Future
(17, 'MCLFX'),
(17, 'CTHNLRD'),
(17, 'LTHMPSN'),
-- Cast Away
(18, 'THTMHNKS'),
-- The Polar Express
(19, 'THTMHNKS'),
-- Contact
(20, 'JDNFSTR'),
(20, 'MTTHWMCNCGH'),
(20, 'JMK'),
-- Chi ha incastrato Roger Rabbit
(21, 'CRLWL'),
(21, 'BBSHRLY'),
(21, 'JNCD'),
-- Space Jam
(22, 'MCHLJRDN'),
(22, 'WBRRN'),
(22, 'BLLMRY'),
(22, 'DNNYDVL'),
(22, 'THMS'),
-- Inception
(23, 'LDRCPC'),
(23, 'THRSHTM'),
(23, 'CHRBLCNHNHMCLNE'),
(23, 'MCLKN'),
-- The Dark Knight
(24, 'THRSHTM'),
(24, 'CHRBLCNHNHMCLNE'),
(24, 'CLLMRPHY'),
(24, 'NNHHTHWY'),
(24, 'GRYLDMN'),
(24, 'MCLKN'),
-- Interstellar
(25, 'NNHHTHWY'),
(25, 'MTTHWMCNCGH'),
(25, 'MCLKN'),
-- Dunkirk
(26, 'THRSHTM'),
(26, 'CLLMRPHY'),
(26, 'HRRSTLS'),
-- The Prestige
(27, 'CHRBLCNHNHMCLNE'),
(27, 'HGJKMN'),
(27, 'DFTBWW'),
(27, 'MCLKN'),
-- Modern Times
(28, 'CHRLSCPLNC');

-- Utente --
INSERT INTO Utente (NomeUtente, Nome, Cognome, DataNascita, Mail, Password, Abbonamento) VALUES
('mario_rossi91', 'Mario', 'Rossi', '1991-03-15', 'mario.rossi@gmail.com', 'P@ssM91!', 'Premium'),
('anna.bianchi85', 'Anna', 'Bianchi', '1985-07-22', 'anna.bianchi@gmail.com', 'P@ssA85!', 'Basic'),
('luca_verdi98', 'Luca', 'Verdi', '1998-05-10', 'luca.verdi@icloud.com', 'P@ssL98!', 'Pro'),
('giulia_1990', 'Giulia', 'Verde', '1990-08-20', 'giulia.verde@gmail.com', 'P@ssG90!', 'Deluxe'),
('fabio90', 'Fabio', 'Bianchi', '1990-12-05', 'fabio.bianchi@icloud.com', 'P@ssF90!', 'Ultimate'),
('sara_giorgi', 'Sara', 'Giorgi', '1988-04-25', 'sara.giorgi@gmail.com', 'P@ssS88!', 'Pro'),
('claudio81', 'Claudio', 'Ricci', '1981-11-12', 'claudio.ricci@gmail.com', 'P@ssC81!', 'Premium'),
('laura_1995', 'Laura', 'Moretti', '1995-06-28', 'laura.moretti@icloud.com', 'P@ssL95!', 'Basic'),
('marco_b', 'Marco', 'Bianco', '1987-09-08', 'marco.bianco@gmail.com', 'P@ssM87!', 'Deluxe'),
('elena_1989', 'Elena', 'Ruggiero', '1989-04-15', 'elena.ruggiero@icloud.com', 'P@ssE89!', 'Pro'),
('paolo_m', 'Paolo', 'Monti', '1993-12-03', 'paolo.monti@gmail.com', 'P@ssP93!', 'Ultimate'),
('silvia_g', 'Silvia', 'Gatti', '1984-07-20', 'silvia.gatti@icloud.com', 'P@ssS84!', 'Basic');

-- Critico --
INSERT INTO Critico (CodiceFiscale, Nome, Cognome, DataNascita)
VALUES
('MRLGPP88P12H501T', 'Giuseppe', 'Marcelli', '1988-12-12'),
('FNCMRA92C08H501D', 'Davide', 'Ferrari', '1992-08-08'),
('BNCNNA75R29B570A', 'Roberta', 'Bianco', '1975-02-27'),
('GRNMRO80A01A662F', 'Marco', 'Greco', '1980-01-01'),
('SMNLMN95L25A456R', 'Melissa', 'Salerno', '1995-11-25'),
('RSCMRA88R01H501A', 'Antonio', 'Russo', '1988-01-01'),
('BNCGPP79T25B570P', 'Paola', 'Bianchi', '1979-12-25'),
('VRDLCA87A10L219S', 'Sara', 'Verdi', '1987-03-10'),
('GRNMRO81A01L219G', 'Giorgio', 'Greco', '1981-01-01'),
('FNCMRA90C08H501F', 'Francesca', 'Ferrari', '1990-08-08');

-- Carta --
INSERT INTO Carta (NumeroCarta, CVC, NomeProprietario, CognomeProprietario, Scadenza) VALUES
('1234567812345678', 123, 'Mario', 'Rossi', '2024-12-01'),
('2345678923456789', 234, 'Anna', 'Bianchi', '2025-10-01'),
('3456789034567890', 345, 'Luca', 'Verdi', '2024-06-01'),
('4567890145678901', 456, 'Giulia', 'Verde', '2024-09-01'),
('5678901256789012', 567, 'Fabio', 'Monti', '2025-04-01'),
('6789012367890123', 678, 'Sara', 'Giorgi', '2026-11-01'),
('7890123478901234', 789, 'Paolo', 'Monti', '2024-08-01'),
('8901234589012345', 890, 'Silvia', 'Gatti', '2025-03-01'),
('9012345690123456', 901, 'Elena', 'Ruggiero', '2025-07-01'),
('1234123412341234', 321, 'Marco', 'Bianco', '2024-05-01'),
('2345678923456780', 999, 'Laura', 'Moretti', '2024-11-01'),
('3456789034567899', 555, 'Claudio', 'Ricci', '2025-08-01'),
('7890123478901235', 777, 'Nicola', 'Ferrari', '2024-09-01');

-- Abbonamento–
INSERT INTO Abbonamento (Nome, DownloadOffline, OreMassime, Costo) VALUES
('Basic', false, 56, 5),
('Premium', false, 84, 10),
('Pro', false, 140, 15),
('Deluxe', true, 168, 20),
('Ultimate', true, Null, 25);

-- Fatturazione --
INSERT INTO Fatturazione (DataPagamento, Costo, Utente, Carta) VALUES
('2023-01-15', 20, 'giulia_1990', '4567890145678901'),
('2023-02-20', 25, 'fabio90', '5678901256789012'),
('2022-03-25', 15, 'sara_giorgi', '6789012367890123'),
('2023-04-30', 10, 'claudio81', '3456789034567899'),
('2023-05-04', 5, 'laura_1995', '2345678923456780'),
('2023-03-10', 20, 'marco_b', '1234123412341234'),
('2023-02-03', 25, 'paolo_m', '7890123478901234'),
('2023-12-15', 15, 'elena_1989', '9012345690123456'),
('2023-02-25', 5, 'silvia_g', '8901234589012345'),
('2023-07-15', 10, 'mario_rossi91', '1234567812345678'),
('2023-11-26', 5, 'anna.bianchi85', '2345678923456789'),
('2023-08-24', 15, 'luca_verdi98', '3456789034567890'),
('2019-12-31', 10, 'mario_rossi91', '1234567812345678'),
('2023-03-03', 10, 'mario_rossi91', '1234567812345678'),
('2023-02-03', 10, 'mario_rossi91', '1234567812345678'),
('2024-01-13', 10, 'mario_rossi91', '1234567812345678'),
('2024-02-03', 10, 'mario_rossi91', '1234567812345678'),
('2023-12-18', 5, 'anna.bianchi85', '2345678923456789'),
('2024-02-19', 5, 'anna.bianchi85', '2345678923456789'),
('2023-11-27', 5, 'anna.bianchi85', '2345678923456789'),
('2023-10-26', 5, 'anna.bianchi85', '2345678923456789'),
('2024-01-18', 5, 'anna.bianchi85', '2345678923456789'),
('2024-02-18', 15, 'luca_verdi98', '3456789034567890'),
('2019-11-28', 15, 'luca_verdi98', '3456789034567890'),
('2023-12-06', 20, 'giulia_1990', '4567890145678901'),
('2024-02-06', 20, 'giulia_1990', '4567890145678901'),
('2023-12-19', 25, 'fabio90', '5678901256789012'),
('2023-10-06', 25, 'fabio90', '5678901256789012'),
('2022-12-19', 25, 'fabio90', '5678901256789012'),
('2006-06-05', 25, 'fabio90', '5678901256789012'),
('2023-04-19', 25, 'fabio90', '5678901256789012'),
('2023-12-23', 15, 'sara_giorgi', '6789012367890123'), 
('2006-06-05', 15, 'sara_giorgi', '6789012367890123'), 
('2016-06-05', 15, 'sara_giorgi', '6789012367890123'), 
('2013-12-24', 15, 'sara_giorgi', '6789012367890123'), 
('2023-09-11', 10, 'claudio81', '3456789034567899'), 
('2023-06-25', 10, 'claudio81', '3456789034567899'),
('2023-08-19', 5, 'laura_1995', '2345678923456780'),  
('2023-07-14', 5, 'laura_1995', '2345678923456780'), 
('2023-03-27', 5, 'laura_1995', '2345678923456780'), 
('2023-11-01', 20, 'marco_b', '1234123412341234'),  
('2023-12-01', 20, 'marco_b', '1234123412341234'),
('2023-04-19', 20, 'marco_b', '1234123412341234'),   
('2023-08-06', 20, 'marco_b', '1234123412341234'),     
('2023-04-12', 15, 'elena_1989', '9012345690123456'),
('2023-01-13', 15, 'elena_1989', '9012345690123456'),        
('2023-03-12', 15, 'elena_1989', '9012345690123456'), 
('2023-10-08', 25, 'paolo_m', '7890123478901234'), 
('2023-11-19', 25, 'paolo_m', '7890123478901234'),   
('2023-12-19', 25, 'paolo_m', '7890123478901234'),     
('2023-07-16', 25, 'paolo_m', '7890123478901234'),   
('2023-09-10', 5, 'silvia_g', '8901234589012345'), 
('2023-07-07', 5, 'silvia_g', '8901234589012345'), 
('2023-01-18', 5, 'silvia_g', '8901234589012345'); 

-- per eseguire test
insert into Fatturazione(DataPagamento, Costo, Utente, Carta)
select current_date() - interval 20 day, costo, nomeUtente, '8901234589012345'
from Abbonamento A
	inner join Utente U
		on A.nome = U.abbonamento;

insert into escludereC (abbonamento, classificazione) values
( 'basic', 'VM14' ),
( 'basic', 'VM18' ),
( 'premium', 'VM14' ),
( 'premium', 'VM18' ),
( 'basic', 'VM6' ),
( 'pro', 'VM18' );

insert into escludereM (abbonamento, media) values
( 'basic', 'Live Action' ),
( 'basic', 'Tecnica Mista' ),
( 'Premium', 'Live Action' );

INSERT INTO Audio (Nome, Versione, Dimensione, Bitrate, Qualita, Tipologia) VALUES
('MP3', 1.0, 960, 128, 'Media', 'Stereo'),
('MP3', 1.5, 960, 128, 'Alta', 'Stereo'),
('WMA', 2.3, 720, 96, 'Bassa', 'Mono'),
('FLAC', 3.0, 5120, 120, 'Alta', 'Sorround'),
('OGG', 2.0, 960, 128, 'Bassa', 'Sorround');

insert into appartenere( film, genere) values
(1 , 'Drammatico'),
(1 , 'Thriller'),
(2 , 'Drammatico'),
(2 , 'Azione'),
(3 , 'Azione'),
(3 , 'Western'),
(4 , 'Guerra'),
(4 , 'Avventura'),
(4 , 'Azione'),
(5 , 'Crime'),
(5 , 'Thriller'),
(6 , 'Drammatico'),
(6 , 'Fantasy'),
(7 , 'Commedia'),
(7 , 'Fantasy'),
(8 , 'Supereroi'),
(8 , 'Fantasy'),
(8 , 'Azione'),
(9 , 'Fantasy'),
(9 , 'Romantico'),
(10 , 'Fantasy'),
(10 , 'Avventura'),
(11 , 'Avventura'),
(11 , 'Azione'),
(11 , 'Supereroi'),
(12 , 'Avventura'),
(12 , 'Azione'),
(12 , 'Supereroi'),
(13 , 'Avventura'),
(13 , 'Azione'),
(13 , 'Supereroi'),
(14 , 'Avventura'),
(14 , 'Azione'),
(14 , 'Supereroi'),
(15 , 'Commedia'),
(15 , 'Poliziesco'),
(16 , 'Commedia'),
(16 , 'Drammatico'),
(17 , 'Avventura'),
(17 , 'Commedia'),
(17 , 'Fantascienza'),
(18 , 'Avventura'),
(18 , 'Drammatico'),
(19 , 'Avventura'),
(19 , 'Fantasy'),
(20 , 'Fantascienza'),
(20 , 'Drammatico'),
(21 , 'Fantasy'),
(21 , 'Commedia'),
(22 , 'Sportivo'),
(22 , 'Fantasy'),
(22 , 'Commedia'),
(23 , 'Fantascienza'),
(23 , 'Thriller'),
(23 , 'Azione'),
(24 , 'Fantasy'),
(24 , 'Azione'),
(25 , 'Fantascienza'),
(25 , 'Avventura'),
(26 , 'Storico'),
(26 , 'Guerra'),
(26 , 'Azione'),
(27 , 'Thriller'),
(27 , 'Drammatico'),
(27 , 'Fantascienza');

INSERT INTO Sottotitolaggio (Film, Lingua) VALUES
(1, 'Inglese'), (1, 'Spagnolo'), (1, 'Francese'), (1, 'Tedesco'), (1, 'Italiano'),
(2, 'Portoghese'), (2, 'Cinese'), (2, 'Giapponese'), (2, 'Russo'), (2, 'Arabo'),
(3, 'Hindi'), (3, 'Bengalese'), (3, 'Coreano'), (3, 'Olandese'), (3, 'Svedese'),
(4, 'Inglese'), (4, 'Spagnolo'), (4, 'Francese'), (4, 'Tedesco'), (4, 'Italiano'),
(5, 'Portoghese'), (5, 'Cinese'), (5, 'Giapponese'), (5, 'Russo'), (5, 'Arabo'),
(6, 'Hindi'), (6, 'Bengalese'), (6, 'Coreano'), (6, 'Olandese'), (6, 'Svedese'),
(7, 'Inglese'), (7, 'Spagnolo'), (7, 'Francese'), (7, 'Tedesco'), (7, 'Italiano'),
(8, 'Portoghese'), (8, 'Cinese'), (8, 'Giapponese'), (8, 'Russo'), (8, 'Arabo'),
(9, 'Hindi'), (9, 'Bengalese'), (9, 'Coreano'), (9, 'Olandese'), (9, 'Svedese'),
(10, 'Inglese'), (10, 'Spagnolo'), (10, 'Francese'), (10, 'Tedesco'), (10, 'Italiano'),
(11, 'Portoghese'), (11, 'Cinese'), (11, 'Giapponese'), (11, 'Russo'), (11, 'Arabo'),
(12, 'Hindi'), (12, 'Bengalese'), (12, 'Coreano'), (12, 'Olandese'), (12, 'Svedese'),
(13, 'Inglese'), (13, 'Spagnolo'), (13, 'Francese'), (13, 'Tedesco'), (13, 'Italiano'),
(14, 'Portoghese'), (14, 'Cinese'), (14, 'Giapponese'), (14, 'Russo'), (14, 'Arabo'),
(15, 'Hindi'), (15, 'Bengalese'), (15, 'Coreano'), (15, 'Olandese'), (15, 'Svedese'),
(16, 'Inglese'), (16, 'Spagnolo'), (16, 'Francese'), (16, 'Tedesco'), (16, 'Italiano'),
(17, 'Tedesco'), (17, 'Italiano'), (17, 'Cinese'), (17, 'Giapponese'), (17, 'Russo'),
(18, 'Portoghese'), (18, 'Giapponese'), (18, 'Russo'), (18, 'Arabo'), (18, 'Hindi'),
(19, 'Inglese'), (19, 'Spagnolo'), (19, 'Francese'), (19, 'Tedesco'), (19, 'Italiano'),
(20, 'Portoghese'), (20, 'Cinese'), (20, 'Giapponese'), (20, 'Russo'), (20, 'Arabo'),
(21, 'Hindi'), (21, 'Inglese'), (21, 'Spagnolo'), (21, 'Francese'), (21, 'Tedesco'),
(22, 'Italiano'), (22, 'Portoghese'), (22, 'Cinese'), (22, 'Giapponese'), (22, 'Russo'),
(23, 'Arabo'), (23, 'Hindi'), (23, 'Inglese'), (23, 'Spagnolo'), (23, 'Francese'),
(24, 'Tedesco'), (24, 'Italiano'), (24, 'Portoghese'), (24, 'Cinese'), (24, 'Giapponese'),
(25, 'Russo'), (25, 'Arabo'), (25, 'Hindi'), (25, 'Inglese'), (25, 'Spagnolo'),
(26, 'Francese'), (26, 'Tedesco'), (26, 'Italiano'), (26, 'Portoghese'), (26, 'Cinese'),
(27, 'Giapponese'), (27, 'Russo'), (27, 'Arabo'), (27, 'Hindi'), (27, 'Inglese'),
(28, 'Giapponese'), (28, 'Russo'), (28, 'Francese'), (28, 'Italiano'), (28, 'Inglese');

INSERT INTO Doppiaggio (Film, Lingua) VALUES
(1, 'Inglese'), (1, 'Spagnolo'), (1, 'Francese'),
(2, 'Tedesco'), (2, 'Italiano'), (2, 'Cinese'),
(3, 'Portoghese'), (3, 'Giapponese'), (3, 'Russo'),
(4, 'Arabo'), (4, 'Hindi'), (4, 'Inglese'),
(5, 'Bengalese'), (5, 'Coreano'), (5, 'Olandese'),
(6, 'Svedese'), (6, 'Inglese'), (6, 'Spagnolo'),
(7, 'Francese'), (7, 'Tedesco'), (7, 'Italiano'),
(8, 'Portoghese'), (8, 'Cinese'), (8, 'Giapponese'),
(9, 'Russo'), (9, 'Arabo'), (9, 'Hindi'),
(10, 'Bengalese'), (10, 'Coreano'), (10, 'Olandese'),
(11, 'Svedese'), (11, 'Inglese'), (11, 'Spagnolo'),
(12, 'Francese'), (12, 'Tedesco'), (12, 'Italiano'),
(13, 'Portoghese'), (13, 'Cinese'), (13, 'Giapponese'),
(14, 'Russo'), (14, 'Arabo'), (14, 'Hindi'),
(15, 'Bengalese'), (15, 'Coreano'), (15, 'Olandese'),
(16, 'Inglese'), (16, 'Spagnolo'), (16, 'Francese'),
(17, 'Tedesco'), (17, 'Italiano'), (17, 'Cinese'),
(18, 'Portoghese'), (18, 'Giapponese'), (18, 'Russo'),
(19, 'Arabo'), (19, 'Hindi'), (19, 'Inglese'),
(20, 'Bengalese'), (20, 'Coreano'), (20, 'Olandese'),
(21, 'Svedese'), (21, 'Inglese'), (21, 'Spagnolo'),
(22, 'Francese'), (22, 'Tedesco'), (22, 'Italiano'),
(23, 'Portoghese'), (23, 'Cinese'), (23, 'Giapponese'),
(24, 'Russo'), (24, 'Arabo'), (24, 'Hindi'),
(25, 'Bengalese'), (25, 'Coreano'), (25, 'Olandese'),
(26, 'Svedese'), (26, 'Inglese'), (26, 'Spagnolo'),
(27, 'Francese'), (27, 'Tedesco'), (27, 'Italiano');

insert into preferirem (Utente, Media) values
('mario_rossi91' , 'Live Action'),
('anna.bianchi85' , 'Live Action'),
('luca_verdi98' , 'Live Action'),
('giulia_1990' , 'Live Action'),
('Fabio90' , 'Live Action'),
('sara_giorgi' , 'Animazione'),
('claudio81' , 'Animazione'),
('laura_1995' , 'Animazione'),
('marco_b' , 'Animazione'),
('elena_1989' , 'Animazione'),
('paolo_m' , 'Tecnica Mista'),
('silvia_g' , 'Tecnica Mista'),
('mario_rossi91' , 'Tecnica Mista'),
('anna.bianchi85' , 'Tecnica Mista'),
('luca_verdi98' , 'Tecnica Mista'),
('giulia_1990' , 'Animazione'),
('paolo_m' , 'Animazione'),
('marco_b' , 'Tecnica Mista'),
('mario_rossi91' , 'Animazione');

insert into Video(Nome, Versione, Dimensione, Bitrate, Risoluzione, RapportoDAspetto) values
('MP4', 3.2, 24, 16, '1440p', '4:3'),
('AVI', 5.3, 85, 56, '4K', '16:9'),
('MKV', 4.5, 12, 8, '1080p', '3:2'),
('MOV', 2.4, 12, 8, 'HD', '16:10'),
('WMV', 2.6,24,16, '1440p', '16:9');

insert into formato(Tipo, Versione, TipoAudio, VersioneAudio, TipoVideo, VersioneVideo) values
('A', 1.3, 'MP3', 1.0, 'MP4', 3.2),
('B', 1.3, 'MP3', 1.0, 'AVI', 5.3),
('C', 2.5, 'MP3', 1.0, 'MKV', 4.5),
('D', 3.2, 'MP3', 1.0, 'MOV', 2.4),
('E', 2.8, 'MP3', 1.0, 'WMV', 2.6),
('A', 2.6, 'MP3', 1.5, 'MP4', 3.2),
('F', 1.8, 'MP3', 1.5, 'AVI', 5.3),
('G', 3.0, 'MP3', 1.5, 'MKV', 4.5),
('H', 2.0, 'MP3', 1.5, 'MOV', 2.4),
('I', 1.3, 'MP3', 1.5, 'WMV', 2.6),
('J', 3.3, 'WMA', 2.3, 'MP4', 3.2),
('K', 2.2, 'WMA', 2.3, 'AVI', 5.3),
('C', 2.9, 'WMA', 2.3, 'MKV', 4.5),
('M', 3.6, 'WMA', 2.3, 'MOV', 2.4),
('N', 3.3, 'WMA', 2.3, 'WMV', 2.6),
('O', 4.3, 'FLAC', 3.0, 'MP4', 3.2),
('P', 2.1, 'FLAC', 3.0, 'AVI', 5.3),
('Q', 1.6, 'FLAC', 3.0, 'MKV', 4.5),
('D', 3.9, 'FLAC', 3.0, 'MOV', 2.4),
('S', 3.7, 'FLAC', 3.0, 'WMV', 2.6),
('T', 3.7, 'OGG', 2.0, 'MP4', 3.2),
('R', 2.0, 'OGG', 2.0, 'AVI', 5.3),
('U', 3.6, 'OGG', 2.0, 'MKV', 4.5),
('V', 4.9, 'OGG', 2.0, 'MOV', 2.4),
('E', 5.0, 'OGG', 2.0, 'WMV', 2.6);

INSERT INTO Critica (Film, Critico, Voto, Commento) VALUES
(5, 'MRLGPP88P12H501T', 8, 'Un film molto coinvolgente, ottima interpretazione degli attori.'),
(12, 'FNCMRA92C08H501D', 7, 'Una storia emozionante, peccato per alcuni difetti nella sceneggiatura.'),
(20, 'BNCNNA75R29B570A', 9, 'Un capolavoro assoluto, non ho parole per descriverlo.'),
(3, 'GRNMRO80A01A662F', 6, 'Un film mediocre, mi aspettavo di più.'),
(17, 'SMNLMN95L25A456R', 8, 'Una piacevole sorpresa, mi ha tenuto incollato allo schermo.'),
(10, 'RSCMRA88R01H501A', 7, 'Un film con una trama avvincente, ma alcuni dialoghi risultano forzati.'),
(25, 'BNCGPP79T25B570P', 8, 'Uno dei migliori film che abbia mai visto, perfetto sotto ogni aspetto.'),
(8, 'VRDLCA87A10L219S', 6, 'Un inizio promettente, ma la seconda metà del film delude.'),
(18, 'GRNMRO81A01L219G', 8, 'Interpretazioni eccezionali da parte degli attori principali, ma la regia lascia a desiderare.'),
(4, 'FNCMRA90C08H501F', 5, 'Deludente, non è riuscito a catturare il mio interesse.'),
(15, 'MRLGPP88P12H501T', 8, 'Un film che ti tiene sul filo del rasoio dall inizio alla fine, eccellente.'),
(6, 'FNCMRA92C08H501D', 7, 'Una storia coinvolgente, anche se prevedibile in alcuni punti.'),
(22, 'BNCNNA75R29B570A', 8, 'Una vera e propria gioia per gli occhi e per la mente, da vedere assolutamente.'),
(11, 'GRNMRO80A01A662F', 6, 'Una delusione, nonostante il cast stellare.'),
(27, 'SMNLMN95L25A456R', 8, 'Un esperienza cinematografica indimenticabile, da applaudire.'),
(9, 'RSCMRA88R01H501A', 3, 'Un film noioso e senza senso, mi ha deluso profondamente.'),
(21, 'BNCGPP79T25B570P', 4, 'Un vero spreco di tempo e denaro, evitatelo assolutamente.'),
(16, 'VRDLCA87A10L219S', 2, 'Una delle peggiori esperienze cinematografiche della mia vita.'),
(7, 'GRNMRO81A01L219G', 5, 'Non ha senso e sembra che gli attori non sappiano cosa stiano facendo.'),
(14, 'FNCMRA90C08H501F', 3, 'Mi ha fatto addormentare, davvero terribile.'),
(19, 'MRLGPP88P12H501T', 8, 'Un film emozionante che mi ha tenuto incollato allo schermo.'),
(2, 'FNCMRA92C08H501D', 2, 'Un vero disastro, non c è nulla da salvare in questo film.'),
(13, 'BNCNNA75R29B570A', 6, 'Una trama interessante, anche se alcuni dettagli sono stati trascurati.'),
(26, 'GRNMRO80A01A662F', 3, 'Mi aspettavo di più, la trama è troppo scontata.'),
(1, 'SMNLMN95L25A456R', 9, 'Uno dei migliori film degli ultimi anni, lo consiglio a tutti!'),
(23, 'RSCMRA88R01H501A', 7, 'Un film che offre una prospettiva interessante sulla vita, ben realizzato.'),
(5, 'BNCGPP79T25B570P', 4, 'Un film promettente che però cade nel cliché, mi aspettavo di più.'),
(27, 'VRDLCA87A10L219S', 8, 'Un capolavoro assoluto, da vedere e rivedere.'),
(11, 'GRNMRO81A01L219G', 3, 'Una delusione totale, la trama è inconsistente e gli attori poco convincenti.'),
(24, 'FNCMRA90C08H501F', 8, 'Un film coinvolgente con una colonna sonora straordinaria.'),
(28, 'FNCMRA90C08H501F', 9, 'Un Film Muto, in bianco e nero, che ha gettato le basi del Cinema moderno');

insert into vietato(TipoFormato, VersioneFormato, Nazione) values
('A', 1.3, 'Ghana'), ('A', 1.3, 'Georgia'), ('A', 1.3, 'Cile'), ('A', 1.3, 'Cina'), ('A', 1.3, 'Cipro'),
('B', 1.3, 'Romania'), ('B', 1.3, 'Libano'), ('B', 1.3, 'Angola'), ('B', 1.3, 'Argentina'), ('B', 1.3, 'Armenia'),
('C', 2.5, 'Islanda'), ('C', 2.5, 'Grecia'), ('C', 2.5, 'Austria'), ('C', 2.5, 'Belgio'), ('C', 2.5, 'Bolivia'),
('D', 3.2, 'Israele'), ('D', 3.2, 'Lettonia'), ('D', 3.2, 'Brasile'), ('D', 3.2, 'Cambogia'), ('D', 3.2, 'Camerun'),
('E', 2.8, 'Marocco'), ('E', 2.8, 'Canada'), ('E', 2.8, 'Ciad'), ('E', 2.8, 'Capo Verde'), ('E', 2.8, 'Cile'),
('A', 2.6, 'Cina'), ('A', 2.6, 'Cipro'), ('A', 2.6, 'Colombia'), ('A', 2.6, 'Comore'), ('A', 2.6, 'Costa Rica'),
('F', 1.8, 'Costa Rica'), ('F', 1.8, 'Croazia'),('F', 1.8, 'Cuba'),('F', 1.8, 'Danimarca'),('F', 1.8, 'Ecuador'),
('G', 3.0, 'Singapore'), ('G', 3.0, 'Egitto'),('G', 3.0, 'El Salvador'),('G', 3.0, 'Eritrea'),('G', 3.0, 'Estonia'),
('H', 2.0, 'Uruguay'), ('H', 2.0, 'Etiopia'),('H', 2.0, 'Figi'),('H', 2.0, 'Filippine'),('H', 2.0, 'Finlandia'),
('I', 1.3, 'Stati Uniti d`America'), ('I', 1.3, 'Francia'), ('I', 1.3, 'Gabon'), ('I', 1.3, 'Gambia'), ('I', 1.3, 'Georgia'),
('J', 3.3, 'Sudan'),('J', 3.3, 'Germania'),('J', 3.3, 'Ghana'),('J', 3.3, 'Giamaica'),('J', 3.3, 'Giappone'),
('K', 2.2, 'Svezia'),('K', 2.2, 'Gibuti'),('K', 2.2, 'Giordania'),('K', 2.2, 'Grecia'),('K', 2.2, 'Grenada'),
('C', 2.9,'Svizzera'),('C', 2.9,'Guatemala'),('C', 2.9,'Guinea'),('C', 2.9,'Haiti'),('C', 2.9,'Honduras'),
('M', 3.6,'Tunisia'),('M', 3.6,'India'),('M', 3.6,'Indonesia'),('M', 3.6,'Iran'),('M', 3.6,'Iraq'),
('N', 3.3,'Turchia'),('N', 3.3,'Irlanda'),('N', 3.3,'Islanda'),('N', 3.3,'Israele'),('N', 3.3,'Italia'),
('O', 4.3,'Ungheria'),('O', 4.3,'Kazakistan'),('O', 4.3,'Kenya'),('O', 4.3,'Kuwait'),('O', 4.3,'Lesotho'),
('P', 2.1,'Venezuela'),('P', 2.1,'Lettonia'),('P', 2.1,'Libano'),('P', 2.1,'Liberia'),('P', 2.1,'Libia'),
('Q', 1.6,'Ucraina'),('Q', 1.6,'Lituania'),('Q', 1.6,'Lussemburgo'),('Q', 1.6,'Madagascar'),('Q', 1.6,'Malawi'),
('D', 3.9,'Spagna'),('D', 3.9,'Malesia'),('D', 3.9,'Maldive'),('D', 3.9,'Mali'),('D', 3.9,'Malta'),
('S', 3.7,'Senegal'),('S', 3.7,'Marooco'),('S', 3.7,'Mauritania'),('S', 3.7,'Messico'),('S', 3.7,'Monaco'),
('T', 3.7,'Slovacchia'),('T', 3.7,'Mongolia'),('T', 3.7,'Montenegro'),('T', 3.7,'Mozambico'),('T', 3.7,'Namibia'),
('R', 2.0,'Slovenia'),('R', 2.0,'Nepal'),('R', 2.0,'Nicaragua'),('R', 2.0,'Niger'),('R', 2.0,'Nigeria'),
('U', 3.6,'Serbia'),('U', 3.6,'Norvegia'),('U', 3.6,'Nuova Zelanda'),('U', 3.6,'Oman'),('U', 3.6,'Paesi Bassi'),
('V', 4.9,'Ruanda'),('V', 4.9,'Pakistan'),('V', 4.9,'Panama'),('V', 4.9,'Perù'),('V', 4.9,'Polonia'),
('E', 5.0,'Polonia'),('E', 5.0,'Portogallo'),('E', 5.0,'Qatar'),('E', 5.0,'Regno Unito'),('E', 5.0,'Romania');

-- SupportareA --
Insert into SupportareA(MarcaDispositivo, ModelloDispositivo, TipoAudio, VersioneAudio) Values
('Samsung', 'Galaxy S21', 'MP3', 1.0), ('Apple', 'iPhone 13', 'MP3', 1.5),
('Sony', 'PlayStation 5', 'WMA', 2.3), ('Microsoft', 'XBox Serie X', 'FLAC', 3.0),
('Microsoft', 'Nokia Lumia', 'OGG', 2.0), ('LG', 'OLED C1', 'MP3', 1.0),
('Microsoft', 'Surface Pro 7', 'MP3', 1.5), ('Samsung', 'Galaxy Tab S7', 'WMA', 2.3),
('Apple', 'iPad Air', 'FLAC', 3.0), ('Sony', 'BRAVIA XR A80J', 'OGG', 2.0),
('LG', 'NanoCell 85 Series', 'MP3', 1.0), ('Samsung', 'QLED Q90T', 'MP3', 1.5),
('Google', 'Pixel 6', 'WMA', 2.3), ('Xiaomi', 'Mi 11', 'FLAC', 3.0),
('Rumba', 'Galaxy s21', 'OGG', 2.0), ('Apple', 'iPhone 14 Pro', 'MP3', 1.0),
('Apple', 'iPhone 15 Pro Max', 'MP3', 1.5), ('Apple', 'iPhone 12 Mini', 'WMA', 2.3),
('Samsung', 'Galaxy S21', 'FLAC', 3.0), ('Apple', 'iPhone 13', 'OGG', 2.0),
('Sony', 'PlayStation 5', 'MP3', 1.0), ('Microsoft', 'XBox Serie X', 'MP3', 1.5),
('Microsoft', 'Nokia Lumia', 'WMA', 2.3), ('LG', 'OLED C1', 'FLAC', 3.0),
('Microsoft', 'Surface Pro 7', 'OGG', 2.0), ('Samsung', 'Galaxy Tab S7', 'MP3', 1.0),
('Apple', 'iPad Air', 'MP3', 1.5), ('Sony', 'BRAVIA XR A80J', 'WMA', 2.3),
('LG', 'NanoCell 85 Series', 'FLAC', 3.0), ('Samsung', 'QLED Q90T', 'OGG', 2.0),
('Google', 'Pixel 6', 'MP3', 1.0), ('Xiaomi', 'Mi 11', 'MP3', 1.5),
('Rumba', 'Galaxy s21', 'WMA', 2.3), ('Apple', 'iPhone 14 Pro', 'FLAC', 3.0),
('Apple', 'iPhone 15 Pro Max', 'OGG', 2.0), ('Apple', 'iPhone 12 Mini', 'MP3', 1.0),
('Samsung', 'Galaxy S21', 'MP3', 1.5), ('Apple', 'iPhone 13', 'WMA', 2.3),
('Sony', 'PlayStation 5', 'FLAC', 3.0), ('Microsoft', 'XBox Serie X', 'OGG', 2.0),
('Microsoft', 'Nokia Lumia', 'MP3', 1.0), ('LG', 'OLED C1', 'MP3', 1.5),
('Microsoft', 'Surface Pro 7', 'WMA', 2.3), ('Samsung', 'Galaxy Tab S7', 'FLAC', 3.0),
('Apple', 'iPad Air', 'OGG', 2.0), ('Sony', 'BRAVIA XR A80J', 'MP3', 1.0),
('LG', 'NanoCell 85 Series', 'MP3', 1.5), ('Samsung', 'QLED Q90T', 'WMA', 2.3),
('Google', 'Pixel 6', 'FLAC', 3.0), ('Xiaomi', 'Mi 11', 'OGG', 2.0),
('Rumba', 'Galaxy s21', 'MP3', 1.0), ('Apple', 'iPhone 14 Pro', 'MP3', 1.5),
('Apple', 'iPhone 15 Pro Max', 'WMA', 2.3), ('Apple', 'iPhone 12 Mini', 'OGG', 2.0);

-- SupportareV --
insert into supportarev(MarcaDispositivo, ModelloDispositivo, TipoVideo, VersioneVideo) values
('Samsung', 'Galaxy S21', 'MP4', 3.2), ('Samsung', 'Galaxy S21', 'AVI', 5.3),('Samsung', 'Galaxy S21', 'MkV', 4.5),
('Apple', 'iPhone 13', 'MP4', 3.2),('Apple', 'iPhone 13', 'MOV', 2.4),('Apple', 'iPhone 13', 'WMV', 2.6),
('Sony', 'PlayStation 5', 'MP4', 3.2),('Sony', 'PlayStation 5', 'AVI', 5.3),('Sony', 'PlayStation 5', 'MkV', 4.5),
('Microsoft', 'XBox Serie X', 'MOV', 2.4),('Microsoft', 'XBox Serie X', 'WMV', 2.6),('Microsoft', 'XBox Serie X', 'MP4', 3.2),
('Microsoft', 'Nokia Lumia', 'AVI', 5.3),('Microsoft', 'Nokia Lumia', 'MkV', 4.5),('Microsoft', 'Nokia Lumia','MOV', 2.4),
('LG', 'OLED C1', 'WMV', 2.6),('LG', 'OLED C1', 'MP4', 3.2),('LG', 'OLED C1', 'AVI', 5.3),
('Microsoft', 'Surface Pro 7', 'MkV', 4.5),('Microsoft', 'Surface Pro 7', 'MOV', 2.4),('Microsoft', 'Surface Pro 7', 'WMV', 2.6),
('Samsung', 'Galaxy Tab S7', 'MP4', 3.2),('Samsung', 'Galaxy Tab S7', 'AVI', 5.3),('Samsung', 'Galaxy Tab S7', 'MkV', 4.5),
('Apple', 'iPad Air', 'MOV', 2.4),('Apple', 'iPad Air','WMV', 2.6),('Apple', 'iPad Air', 'MP4', 3.2),
('Sony', 'BRAVIA XR A80J', 'AVI', 5.3),('Sony', 'BRAVIA XR A80J', 'MkV', 4.5),('Sony', 'BRAVIA XR A80J', 'MOV', 2.4),
('LG', 'NanoCell 85 Series', 'WMV', 2.6),('LG', 'NanoCell 85 Series', 'MP4', 3.2),('LG', 'NanoCell 85 Series',  'AVI', 5.3),
('Samsung', 'QLED Q90T',  'MkV', 4.5),('Samsung', 'QLED Q90T',  'MOV', 2.4),('Samsung', 'QLED Q90T',  'WMV', 2.6),
('Google', 'Pixel 6',  'MP4', 3.2),('Google', 'Pixel 6', 'AVI', 5.3),('Google', 'Pixel 6', 'MkV', 4.5),
('Xiaomi', 'Mi 11', 'MOV', 2.4),('Xiaomi', 'Mi 11', 'WMV', 2.6),('Xiaomi', 'Mi 11', 'MP4', 3.2),
('Rumba', 'Galaxy s21','AVI', 5.3),('Rumba', 'Galaxy s21','MkV', 4.5),('Rumba', 'Galaxy s21', 'MOV', 2.4),
('Apple', 'iPhone 14 Pro','WMV', 2.6),('Apple', 'iPhone 14 Pro','MP4', 3.2),('Apple', 'iPhone 14 Pro', 'AVI', 5.3),
('Apple', 'iPhone 15 Pro Max', 'MkV', 4.5),('Apple', 'iPhone 15 Pro Max', 'MOV', 2.4),('Apple', 'iPhone 15 Pro Max', 'WMV', 2.6),
('Apple', 'iPhone 12 Mini', 'MP4', 3.2),('Apple', 'iPhone 12 Mini', 'AVI', 5.3),('Apple', 'iPhone 12 Mini', 'MkV', 4.5);

-- Versione --
CALL insert_random_versione();

-- server
insert into server(LarghezzaBanda, Nazione) values
(4, 'Afghanistan'),(4, 'Afghanistan'),(4, 'Afghanistan'),
(5, 'Albania'),(5, 'Albania'),(5, 'Albania'),
(6, 'Algeria'),(6, 'Algeria'),(6, 'Algeria'),
(7, 'Andorra'),(7, 'Andorra'),(7, 'Andorra'),
(4, 'Angola'),(4, 'Angola'),(4, 'Angola'),
(5, 'Antigua e Barbuda'),(5, 'Antigua e Barbuda'),(5, 'Antigua e Barbuda'),
(6, 'Arabia Saudita'),(6, 'Arabia Saudita'),(6, 'Arabia Saudita'),
(7, 'Argentina'),(7, 'Argentina'),(7, 'Argentina'),
(4, 'Armenia'),(4, 'Armenia'),(4, 'Armenia'),
(5, 'Australia'),(5, 'Australia'),(5, 'Australia'),
(6, 'Austria'),(6, 'Austria'),(6, 'Austria'),
(7, 'Azerbaijan'),(7, 'Azerbaijan'),(7, 'Azerbaijan'),
(4, 'Bahamas'),(4, 'Bahamas'),(4, 'Bahamas'),
(5, 'Bahrain'),(5, 'Bahrain'),(5, 'Bahrain'),
(6, 'Bangladesh'),(6, 'Bangladesh'),(6, 'Bangladesh'),
(7, 'Belarus'),(7, 'Belarus'),(7, 'Belarus'),
(4, 'Barbados'),(4, 'Barbados'),(4, 'Barbados'),
(5, 'Belgio'),(5, 'Belgio'),(5, 'Belgio'),
(6, 'Belize'),(6, 'Belize'),(6, 'Belize'),
(7, 'Benin'),(7, 'Benin'),(7, 'Benin'),
(4, 'Bhutan'),(4, 'Bhutan'),(4, 'Bhutan'),
(5, 'Bolivia'),(5, 'Bolivia'),(5, 'Bolivia'),
(6, 'Bosnia e Erzegovina'),(6, 'Bosnia e Erzegovina'),(6, 'Bosnia e Erzegovina'),
(7, 'Botswana'),(7, 'Botswana'),(7, 'Botswana'),
(4, 'Brasile'),(4, 'Brasile'),(4, 'Brasile'),
(5, 'Brunei Darussalam'),(5, 'Brunei Darussalam'),(5, 'Brunei Darussalam'),
(6, 'Bulgaria'),(6, 'Bulgaria'),(6, 'Bulgaria'),
(7, 'Burkina Faso'),(7, 'Burkina Faso'),(7, 'Burkina Faso'),
(4, 'Burundi'),(4, 'Burundi'),(4, 'Burundi'),
(5, 'Cambogia'),(5, 'Cambogia'),(5, 'Cambogia'),
(6, 'Camerun'),(6, 'Camerun'),(6, 'Camerun'),
(7, 'Canada'),(7, 'Canada'),(7, 'Canada'),
(4, 'Capo Verde'),(4, 'Capo Verde'),(4, 'Capo Verde'),
(5, 'Ciad'),(5, 'Ciad'),(5, 'Ciad'),
(6, 'Cile'),(6, 'Cile'),(6, 'Cile'),
(7, 'Cina'),(7, 'Cina'),(7, 'Cina'),
(4, 'Cipro'),(4, 'Cipro'),(4, 'Cipro'),
(5, 'Colombia'),(5, 'Colombia'),(5, 'Colombia'),
(6, 'Comore'),(6, 'Comore'),(6, 'Comore'),
(7, 'Congo (Repubblica del)'),(7, 'Congo (Repubblica del)'),(7, 'Congo (Repubblica del)'),
(4, 'Costa Rica'),(4, 'Costa Rica'),(4, 'Costa Rica'),
(5, 'Costa d’Avorio'),(5, 'Costa d’Avorio'),(5, 'Costa d’Avorio'),
(6, 'Croazia'),(6, 'Croazia'),(6, 'Croazia'),
(7, 'Cuba'),(7, 'Cuba'),(7, 'Cuba'),
(4, 'Danimarca'),(4, 'Danimarca'),(4, 'Danimarca'),
(5, 'Dominica'),(5, 'Dominica'),(5, 'Dominica'),
(6, 'Ecuador'),(6, 'Ecuador'),(6, 'Ecuador'),
(7, 'Egitto'),(7, 'Egitto'),(7, 'Egitto'),
(4, 'El Salvador'),(4, 'El Salvador'),(4, 'El Salvador'),
(5, 'Emirati Arabi Uniti'),(5, 'Emirati Arabi Uniti'),(5, 'Emirati Arabi Uniti'),
(6, 'Eritrea'),(6, 'Eritrea'),(6, 'Eritrea'),
(7, 'Estonia'),(7, 'Estonia'),(7, 'Estonia'),
(4, 'Etiopia'),(4, 'Etiopia'),(4, 'Etiopia'),
(5, 'Ex-Repubblica Iugoslava di Macedonia'),(5, 'Ex-Repubblica Iugoslava di Macedonia'),(5, 'Ex-Repubblica Iugoslava di Macedonia'),
(6, 'Federazione Russa'),(6, 'Federazione Russa'),(6, 'Federazione Russa'),
(7, 'Figi'),(7, 'Figi'),(7, 'Figi'),
(4, 'Filippine'),(4, 'Filippine'),(4, 'Filippine'),
(5, 'Finlandia'),(5, 'Finlandia'),(5, 'Finlandia'),
(6, 'Francia'),(6, 'Francia'),(6, 'Francia'),
(7, 'Gabon'),(7, 'Gabon'),(7, 'Gabon'),
(4, 'Gambia'),(4, 'Gambia'),(4, 'Gambia'),
(5, 'Georgia'),(5, 'Georgia'),(5, 'Georgia'),
(6, 'Germania'),(6, 'Germania'),(6, 'Germania'),
(7, 'Ghana'),(7, 'Ghana'),(7, 'Ghana'),
(4, 'Giamaica'),(4, 'Giamaica'),(4, 'Giamaica'),
(5, 'Giappone'), (5, 'Giappone'),(5, 'Giappone'),
(6, 'Gibuti'),(6, 'Gibuti'),(6, 'Gibuti'),
(7, 'Giordania'),(7, 'Giordania'),(7, 'Giordania'),
(4, 'Grecia'),(4, 'Grecia'),(4, 'Grecia'),
(5, 'Grenada'),(5, 'Grenada'),(5, 'Grenada'),
(6, 'Guatemala'),(6, 'Guatemala'),(6, 'Guatemala'),
(7, 'Guinea'),(7, 'Guinea'),(7, 'Guinea'),
(4, 'Guinea Equatoriale'),(4, 'Guinea Equatoriale'),(4, 'Guinea Equatoriale'),
(5, 'Guinea-Bissau'),(5, 'Guinea-Bissau'),(5, 'Guinea-Bissau'),
(6, 'Guyana'),(6, 'Guyana'),(6, 'Guyana'),
(7, 'Haiti'),(7, 'Haiti'),(7, 'Haiti'),
(4, 'Honduras'),(4, 'Honduras'),(4, 'Honduras'),
(5, 'India'),(5, 'India'),(5, 'India'),
(6, 'Indonesia'),(6, 'Indonesia'),(6, 'Indonesia'),
(7, 'Iran'),(7, 'Iran'),(7, 'Iran'),
(4, 'Iraq'),(4, 'Iraq'),(4, 'Iraq'),
(5, 'Irlanda'),(5, 'Irlanda'),(5, 'Irlanda'),
(6, 'Islanda'),(6, 'Islanda'),(6, 'Islanda'),
(7, 'Israele'),(7, 'Israele'),(7, 'Israele'),
(7, 'Italia'),(7, 'Italia'),(7, 'Italia'),
(4, 'Kazakistan'),(4, 'Kazakistan'),(4, 'Kazakistan'),
(5, 'Kenya'),(5, 'Kenya'),(5, 'Kenya'),
(6, 'Kirghizistan'),(6, 'Kirghizistan'),(6, 'Kirghizistan'),
(7, 'Kirghizistan'),(7, 'Kirghizistan'),(7, 'Kirghizistan'),
(4, 'Kiribati'),(4, 'Kiribati'),(4, 'Kiribati'),
(5, 'Kuwait'),(5, 'Kuwait'),(5, 'Kuwait'),
(6, 'Laos (Repubblica Democratica Popolare)'),(6, 'Laos (Repubblica Democratica Popolare)'),(6, 'Laos (Repubblica Democratica Popolare)'),
(7, 'Lesotho'),(7, 'Lesotho'),(7, 'Lesotho'),
(4, 'Lettonia'),(4, 'Lettonia'),(4, 'Lettonia'),
(5, 'Libano'),(5, 'Libano'),(5, 'Libano'),
(6, 'Liberia'),(6, 'Liberia'),(6, 'Liberia'),
(7, 'Libia'),(7, 'Libia'),(7, 'Libia'),
(4, 'Liechtenstein'),(4, 'Liechtenstein'),(4, 'Liechtenstein'),
(5, 'Lituania'),(5, 'Lituania'),(5, 'Lituania'),
(6, 'Lussemburgo'),(6, 'Lussemburgo'),(6, 'Lussemburgo'),
(7, 'Madagascar'),(7, 'Madagascar'),(7, 'Madagascar'),
(4, 'Malawi'),(4, 'Malawi'),(4, 'Malawi'),
(5, 'Malesia'),(5, 'Malesia'),(5, 'Malesia'),
(6, 'Maldive'),(6, 'Maldive'),(6, 'Maldive'),
(7, 'Mali'),(7, 'Mali'),(7, 'Mali'),
(4, 'Malta'),(4, 'Malta'),(4, 'Malta'),
(5, 'Marocco'),(5, 'Marocco'),(5, 'Marocco'),
(6, 'Marshall, Isole'),(6, 'Marshall, Isole'),(6, 'Marshall, Isole'),
(7, 'Mauritania'),(7, 'Mauritania'),(7, 'Mauritania'),
(4, 'Mauritius'),(4, 'Mauritius'),(4, 'Mauritius'),
(5, 'Messico'),(5, 'Messico'),(5, 'Messico'),
(6, 'Micronesia'),(6, 'Micronesia'),(6, 'Micronesia'),
(7, 'Monaco'),(7, 'Monaco'),(7, 'Monaco'),
(4, 'Mongolia'),(4, 'Mongolia'),(4, 'Mongolia'),
(5, 'Montenegro'),(5, 'Montenegro'),(5, 'Montenegro'),
(6, 'Mozambico'),(6, 'Mozambico'),(6, 'Mozambico'),
(7, 'Myanmar'),(7, 'Myanmar'),(7, 'Myanmar'),
(4, 'Namibia'),(4, 'Namibia'),(4, 'Namibia'),
(5, 'Nauru'),(5, 'Nauru'),(5, 'Nauru'),
(6, 'Nepal'),(6, 'Nepal'),(6, 'Nepal'),
(7, 'Nicaragua'),(7, 'Nicaragua'),(7, 'Nicaragua'),
(4, 'Niger'),(4, 'Niger'),(4, 'Niger'),
(5, 'Nigeria'),(5, 'Nigeria'),(5, 'Nigeria'),
(6, 'Norvegia'),(6, 'Norvegia'),(6, 'Norvegia'),
(7, 'Nuova Zelanda'),(7, 'Nuova Zelanda'),(7, 'Nuova Zelanda'),
(4, 'Oman'),(4, 'Oman'),(4, 'Oman'),
(5, 'Paesi Bassi'),(5, 'Paesi Bassi'),(5, 'Paesi Bassi'),
(6, 'Pakistan'),(6, 'Pakistan'),(6, 'Pakistan'),
(7, 'Palau'),(7, 'Palau'),(7, 'Palau'),
(4, 'Panama'),(4, 'Panama'),(4, 'Panama'),
(5, 'Papua Nuova Guinea'),(5, 'Papua Nuova Guinea'),(5, 'Papua Nuova Guinea'),
(6, 'Paraguay'),(6, 'Paraguay'),(6, 'Paraguay'),
(7, 'Perù'),(7, 'Perù'),(7, 'Perù'),
(4, 'Polonia'),(4, 'Polonia'),(4, 'Polonia'),
(5, 'Portogallo'),(5, 'Portogallo'),(5, 'Portogallo'),
(6, 'Qatar'),(6, 'Qatar'),(6, 'Qatar'),
(7, 'Regno Unito'),(7, 'Regno Unito'),(7, 'Regno Unito'),
(4, 'Repubblica Ceca'),(4, 'Repubblica Ceca'),(4, 'Repubblica Ceca'),
(5, 'Repubblica Centrale Africana'),(5, 'Repubblica Centrale Africana'),(5, 'Repubblica Centrale Africana'),
(6, 'Repubblica Democratica del Congo'),(6, 'Repubblica Democratica del Congo'),(6, 'Repubblica Democratica del Congo'),
(7, 'Repubblica Democratica Popolare di Corea'),(7, 'Repubblica Democratica Popolare di Corea'),(7, 'Repubblica Democratica Popolare di Corea'),
(4, 'Repubblica di Corea'),(4, 'Repubblica di Corea'),(4, 'Repubblica di Corea'),
(5, 'Repubblica di Moldavia'),(5, 'Repubblica di Moldavia'),(5, 'Repubblica di Moldavia'),
(6, 'Repubblica Domenicana'),(6, 'Repubblica Domenicana'),(6, 'Repubblica Domenicana'),
(7, 'Repubblica Unita di Tanzania'),(7, 'Repubblica Unita di Tanzania'),(7, 'Repubblica Unita di Tanzania'),
(4, 'Romania'),(4, 'Romania'),(4, 'Romania'),
(5, 'Ruanda'),(5, 'Ruanda'),(5, 'Ruanda'),
(6, 'San Kitts e Nevis'),(6, 'San Kitts e Nevis'),(6, 'San Kitts e Nevis'),
(7, 'Santa Lucia'),(7, 'Santa Lucia'),(7, 'Santa Lucia'),
(4, 'Saint Vincent e Grenadine'),(4, 'Saint Vincent e Grenadine'),(4, 'Saint Vincent e Grenadine'),
(5, 'Salomone, Isole'),(5, 'Salomone, Isole'),(5, 'Salomone, Isole'),
(6, 'Samoa'),(6, 'Samoa'),(6, 'Samoa'),
(7, 'San Marino'),(7, 'San Marino'),(7, 'San Marino'),
(4, 'Sao Tomé e Principe'),(4, 'Sao Tomé e Principe'),(4, 'Sao Tomé e Principe'),
(5, 'Senegal'),(5, 'Senegal'),(5, 'Senegal'),
(6, 'Serbia'),(6, 'Serbia'),(6, 'Serbia'),
(7, 'Seychelles'),(7, 'Seychelles'),(7, 'Seychelles'),
(4, 'Sierra Leone'),(4, 'Sierra Leone'),(4, 'Sierra Leone'),
(5, 'Singapore'),(5, 'Singapore'),(5, 'Singapore'),
(6, 'Siria'),(6, 'Siria'),(6, 'Siria'),
(7, 'Slovacchia'),(7, 'Slovacchia'),(7, 'Slovacchia'),
(4, 'Slovenia'),(4, 'Slovenia'),(4, 'Slovenia'),
(5, 'Somalia'),(5, 'Somalia'),(5, 'Somalia'),
(6, 'Spagna'),(6, 'Spagna'),(6, 'Spagna'),
(7, 'Sri Lanka'),(7, 'Sri Lanka'),(7, 'Sri Lanka'),
(4, 'Stati Uniti d`America'),(4, 'Stati Uniti d`America'),(4, 'Stati Uniti d`America'),
(5, 'Sud Africa'),(5, 'Sud Africa'),(5, 'Sud Africa'),
(6, 'Sudan'),(6, 'Sudan'),(6, 'Sudan'),
(7, 'Sud Sudan'),(7, 'Sud Sudan'),(7, 'Sud Sudan'),
(4, 'Suriname'),(4, 'Suriname'),(4, 'Suriname'),
(5, 'Svezia'),(5, 'Svezia'),(5, 'Svezia'),
(6, 'Svizzera'),(6, 'Svizzera'),(6, 'Svizzera'),
(7, 'Swaziland'),(7, 'Swaziland'),(7, 'Swaziland'),
(4, 'Tagikistan'),(4, 'Tagikistan'),(4, 'Tagikistan'),
(5, 'Thailandia'),(5, 'Thailandia'),(5, 'Thailandia'),
(6, 'Timor Leste'),(6, 'Timor Leste'),(6, 'Timor Leste'),
(7, 'Togo'),(7, 'Togo'),(7, 'Togo'),
(4, 'Tonga'),(4, 'Tonga'),(4, 'Tonga'),
(5, 'Trinidad e Tobago'),(5, 'Trinidad e Tobago'),(5, 'Trinidad e Tobago'),
(6, 'Tunisia'),(6, 'Tunisia'),(6, 'Tunisia'),
(7, 'Turchia'),(7, 'Turchia'),(7, 'Turchia'),
(4, 'Turkmenistan'),(4, 'Turkmenistan'),(4, 'Turkmenistan'),
(5, 'Tuvalu'),(5, 'Tuvalu'),(5, 'Tuvalu'),
(6, 'Ucraina'),(6, 'Ucraina'),(6, 'Ucraina'),
(7, 'Uganda'),(7, 'Uganda'),(7, 'Uganda'),
(4, 'Ungheria'),(4, 'Ungheria'),(4, 'Ungheria'),
(5, 'Uruguay'),(5, 'Uruguay'),(5, 'Uruguay'),
(6, 'Uzbekistan'),(6, 'Uzbekistan'),(6, 'Uzbekistan'),
(7, 'Vanuatu'),(7, 'Vanuatu'),(7, 'Vanuatu'),
(4, 'Venezuela'),(4, 'Venezuela'),(4, 'Venezuela'),
(5, 'Viet Nam'),(5, 'Viet Nam'),(5, 'Viet Nam'),
(6, 'Yemen'),(6, 'Yemen'),(6, 'Yemen'),
(7, 'Zambia'),(7, 'Zambia'),(7, 'Zambia'),
(4, 'Zimbabwe'),(4, 'Zimbabwe'),(4, 'Zimbabwe'),
(20, 'Italia');	-- Server Centrale

-- PreferireR(regista)-- 
insert into preferirer(Utente, Regista) values
('mario_rossi91', 'QNTTRNTN63'),('mario_rossi91', 'TMBRTN2558'),
('anna.bianchi85', 'JYPTKA1938'),('anna.bianchi85', 'NTNHRSS970'),
('luca_verdi98', 'RBRTLZMCKS'),('luca_verdi98', 'CHRSTORNLN'),
('giulia_1990', 'QNTTRNTN63'),('giulia_1990', 'TMBRTN2558'),
('fabio90', 'JYPTKA1938'),('fabio90', 'NTNHRSS970'),
('sara_giorgi', 'RBRTLZMCKS'),('sara_giorgi', 'CHRSTORNLN'),
('claudio81', 'QNTTRNTN63'),('claudio81', 'TMBRTN2558'),
('laura_1995', 'JYPTKA1938'),('laura_1995', 'NTNHRSS970'),
('marco_b', 'RBRTLZMCKS'),('marco_b', 'CHRSTORNLN'),
('elena_1989', 'QNTTRNTN63'),('elena_1989', 'TMBRTN2558'),
('paolo_m', 'JYPTKA1938'),('paolo_m', 'NTNHRSS970'),
('silvia_g', 'RBRTLZMCKS'),('silvia_g', 'CHRSTORNLN');

-- PreferireG(genere)--
insert into preferireg(Utente, Genere) values
('mario_rossi91', 'Azione'),('mario_rossi91', 'Avventura'),('mario_rossi91', 'Commedia'),
('anna.bianchi85', 'Drammatico'),('anna.bianchi85', 'Fantascienza'),('anna.bianchi85', 'Fantasy'),
('luca_verdi98', 'Horror'),('luca_verdi98', 'Poliziesco'),('luca_verdi98', 'Romantico'),
('giulia_1990', 'Thriller'),('giulia_1990', 'Documentario'),('giulia_1990', 'Biografico'),
('fabio90', 'Storico'),('fabio90', 'Musical'),('fabio90', 'Crime'),
('sara_giorgi', 'Western'),('sara_giorgi', 'Guerra'),('sara_giorgi', 'Sportivo'),
('claudio81', 'Giallo'),('claudio81', 'Supereroi'),('claudio81', 'Azione'),
('laura_1995', 'Avventura'),('laura_1995', 'Commedia'),('laura_1995', 'Drammatico'),
('marco_b', 'Fantascienza'),('marco_b', 'Fantasy'),('marco_b', 'Horror'),
('elena_1989', 'Poliziesco'),('elena_1989', 'Romantico'),('elena_1989', 'Thriller'),
('paolo_m', 'Documentario'),('paolo_m', 'Biografico'),('paolo_m', 'Storico'),
('silvia_g', 'Azione'),('silvia_g', 'Avventura'),('silvia_g', 'Thriller');


-- PreferireA(Attore)--
insert into preferirea(Utente, Attore) values
('mario_rossi91', 'CHRBLCNHNHMCLNE'),('mario_rossi91', 'HGJKMN'),('mario_rossi91', 'DFTBWW'),('mario_rossi91', 'THRSHTM'),('mario_rossi91', 'HRRSTLS'),('mario_rossi91', 'JCKNCHLSN'),
('anna.bianchi85', 'MTTHWMCNCGH'),('anna.bianchi85', 'NNHHTHWY'),('anna.bianchi85', 'MCLKN'),('anna.bianchi85', 'GRYLDMN'),('anna.bianchi85', 'CLLMRPHY'),
('luca_verdi98', 'LDRCPC'),('luca_verdi98', 'MCHLJRDN'),('luca_verdi98', 'WBRRN'),('luca_verdi98', 'BLLMRY'),('luca_verdi98', 'DNNYDVL'),
('giulia_1990', 'THMS'),('giulia_1990', 'RFYHNT'),('giulia_1990', 'GLNCLS'),('giulia_1990', 'MCLFX'),('giulia_1990', 'CTHNLRD'),
('fabio90', 'LTHMPSN'),('fabio90', 'THTMHNKS'),('fabio90', 'JDNFSTR'),('fabio90', 'MTTHWMCNCGH'),('fabio90', 'JMK'),
('sara_giorgi', 'BBSHRLY'),('sara_giorgi', 'CRLWL'),('sara_giorgi', 'JNCD'),('sara_giorgi', 'CHRNSN'),('sara_giorgi', 'SCRLTJHNSN'),('sara_giorgi', 'LDRCPC'),
('claudio81', 'SBSTSTN'),('claudio81', 'RDDRJ'),('claudio81', 'CHDWC'),('claudio81', 'MRKFRFL'),('claudio81', 'JHNNYDPP'),
('laura_1995', 'WINN'),('laura_1995', 'DCTRMRTN'),('laura_1995', 'AGBRCM'),('laura_1995', 'MCHLKN'),('laura_1995', 'KMLK'),
('marco_b', 'HLCNBNNCRTC'),('marco_b', 'EMLYWTSN'),('marco_b', 'MCHSHN'),('marco_b', 'MSSMIA'),('marco_b', 'WSLYSNPS'),('marco_b', 'DCTRMRTN'),
('elena_1989', 'ISBL'),('elena_1989', 'SSRCKL'),('elena_1989', 'JHNLRT'),('elena_1989', 'SMLJCKSN'),('elena_1989', 'UMT'),
('paolo_m', 'DRCRDN'),('paolo_m', 'DRLHNNH'),('paolo_m', 'HRLMKR'),('paolo_m', 'TMRRTN'),('paolo_m', 'STVBSM'),('paolo_m', 'STVBSM'),
('silvia_g', 'BRDPR'),('silvia_g', 'MLN'),('silvia_g', 'CHRSTPHWLTZ'),('silvia_g', 'BRCWLLS'),('silvia_g', 'JMFXX'), ('silvia_g', 'CHRLSCPLNC');

-- Connessione
insert into connessione(IP, TimestampInizio, Utente, Nazione, MarcaDispositivo, ModelloDispositivo) values
    ('110.10.100.1','2020-01-01 10:34:01', 'mario_rossi91', 'Afghanistan', 'Google', 'Pixel 6'),
    ('10.110.10.100', '2023-03-04 08:00:46', 'mario_rossi91', 'Afghanistan', 'Google', 'Pixel 6'),
    ('10.110.10.101', '2023-02-04 08:00:46', 'mario_rossi91', 'Afghanistan', 'Google', 'Pixel 6'),
    ('10.110.10.110', '2024-01-14 08:10:46', 'mario_rossi91', 'Afghanistan', 'Google', 'Pixel 6'),
    ('10.101.10.101', '2024-02-04 08:00:46', 'mario_rossi91', 'Afghanistan', 'Google', 'Pixel 6'),
    ('220.20.220.200', '2024-01-01 00:00:01', 'anna.bianchi85','Albania', 'Sony', 'Playstation 5'),
    ('110.10.100.1', '2024-02-20 09:46:13', 'anna.bianchi85', 'Albania', 'Apple', 'Iphone 15 Pro Max'),
    ('220.20.220.255', '2023-12-01 00:00:01', 'anna.bianchi85','Albania', 'Sony', 'Playstation 5'),
    ('112.10.100.21', '2023-11-20 09:46:13', 'anna.bianchi85', 'Italia', 'Apple', 'Iphone 15 Pro Max'),
    ('110.10.100.211', '2024-02-13 11:46:13', 'anna.bianchi85', 'Cuba', 'Apple', 'Iphone 15 Pro Max'),
    ('123.30.3.33', '2024-02-19 10:30:01', 'luca_verdi98', 'Bahamas', 'Apple', 'Iphone 12 mini'),
    ('123.30.3.33', '2019-11-30 10:30:01', 'luca_verdi98', 'Bahamas', 'Xiaomi', 'Mi 11'),
    ('123.30.3.33', '2024-02-20 10:30:01', 'luca_verdi98', 'Bahamas', 'Apple', 'Iphone 12 mini'),
    ('133.230.56.33', '2019-11-29 08:30:01', 'luca_verdi98', 'Federazione Russa', 'Xiaomi', 'Mi 11'),
    ('123.130.83.123', '2024-02-21 04:30:01', 'luca_verdi98', 'Federazione Russa', 'Apple', 'Iphone 12 mini'),
    ('40.4.0.255', '2023-12-07 12:30:00', 'giulia_1990', 'Cuba', 'Microsoft', 'XBox Serie X'),
    ('4.40.10.23', '2023-12-20 00:01:13', 'giulia_1990', 'Italia', 'Microsoft', 'Nokia Lumia'),
    ('40.4.0.255', '2023-12-08 12:30:00', 'giulia_1990', 'Cuba', 'Microsoft', 'XBox Serie X'),
    ('42.40.120.231', '2024-02-20 00:01:13', 'giulia_1990', 'Italia', 'Microsoft', 'Nokia Lumia'),
    ('41.4.100.255', '2024-02-07 12:30:00', 'giulia_1990', 'Cuba', 'Microsoft', 'XBox Serie X'),
    ('255.255.50.05', '2023-12-20 00:01:13', 'fabio90', 'Tagikistan', 'Rumba', 'Galaxy s21'),
    ('50.5.5.120', '2023-10-7 06:02:40', 'fabio90', 'Israele', 'LG', 'NanoCell 85 Series'),
    ('255.255.50.05', '2022-12-20 00:01:13', 'fabio90', 'Tagikistan', 'Rumba', 'Galaxy s21'),
    ('120.12.120.12', '2006-06-06 06:56:56', 'fabio90', 'Israele', 'LG', 'OLED C1'),
    ('60.6.123.43', '2023-04-20 00:01:13', 'fabio90', 'Tagikistan', 'Samsung', 'Galaxy s21'),
    ('60.6.123.43', '2023-12-25 00:00:01', 'sara_giorgi', 'Bulgaria', 'Samsung', 'Galaxy S21'),
    ('0.6.6.6', '2006-06-06 06:56:56', 'sara_giorgi', 'Norvegia', 'LG', 'OLED C1'),
    ('60.6.123.43', '2023-12-24 00:00:01', 'sara_giorgi', 'Bulgaria', 'Samsung', 'Galaxy S21'),
    ('120.12.120.12', '2016-06-06 08:56:56', 'sara_giorgi', 'Norvegia', 'LG', 'OLED C1'),
    ('70.7.70.7', '2013-12-25 10:00:01', 'sara_giorgi', 'Bulgaria', 'Samsung', 'Galaxy S21'),
	('120.12.120.12', '2023-06-26 13:00:00','claudio81', 'Spagna', 'Apple', 'iPhone 15 Pro Max'),
	('12.120.12.120', '2023-07-12 12:00:00','claudio81', 'Spagna', 'Apple', 'iPhone 15 Pro Max'),
	('70.7.70.7', '2023-05-05 11:00:00','laura_1995', 'Portogallo', 'Xiaomi', 'Mi 11'),
	('7.70.7.70', '2023-08-20 10:00:00','laura_1995', 'Portogallo', 'Samsung', 'Galaxy Tab S7'),
	('8.80.8.80', '2023-11-02 10:00:00','marco_b', 'San Marino', 'Apple', 'iPad Air'),
	('80.8.80.8', '2023-12-02 09:00:00','marco_b', 'Serbia', 'LG', 'OLED C1'),
	('9.90.9.90', '2023-04-13 07:00:00','elena_1989', 'Regno Unito', 'Sony', 'PlayStation 5'),
	('90.9.90.9', '2023-12-25 09:00:00','elena_1989', 'Regno Unito', 'Sony', 'PlayStation 5'),
	('100.1.100.1', '2023-10-09 10:00:00','paolo_m', 'Paesi Bassi', 'Sony', 'BRAVIA XR A80J'),
	('1.100.1.100', '2023-11-20 02:00:00','paolo_m', 'Paesi Bassi', 'Samsung', 'Galaxy S21'),
	('110.11.110.11', '2023-09-11 08:45:00','silvia_g', 'Stati Uniti d`America', 'Apple', 'iPhone 12 Mini'),
	('11.110.11.110', '2023-10-08 06:00:00','silvia_g', 'Svizzera', 'Apple', 'iPhone 12 Mini'),
	('14.140.14.140', '2023-09-12 12:00:00','claudio81', 'Spagna', 'Apple', 'iPhone 15 Pro Max'),
	('15.150.15.150', '2023-10-02 12:00:00','claudio81', 'Spagna', 'Apple', 'iPhone 15 Pro Max'),
	('16.160.16.160', '2023-05-24 12:00:00','claudio81', 'Spagna', 'Apple', 'iPhone 15 Pro Max'),
	('17.170.17.170', '2023-07-15 10:00:00','laura_1995', 'Portogallo', 'Samsung', 'Galaxy Tab S7'),
	('18.180.18.180', '2023-03-28 10:00:00','laura_1995', 'Portogallo', 'Samsung', 'Galaxy Tab S7'),
	('19.190.19.190', '2023-07-29 10:00:00','laura_1995', 'Portogallo', 'Samsung', 'Galaxy Tab S7'),
	('20.200.20.200', '2023-04-20 10:00:00','marco_b', 'San Marino', 'Apple', 'iPad Air'),
	('21.210.21.210', '2023-12-06 10:00:00','marco_b', 'San Marino', 'Apple', 'iPad Air'),
	('22.220.22.220', '2023-08-07 10:00:00','marco_b', 'San Marino', 'Apple', 'iPad Air'),
	('23.230.23.230', '2023-01-14 09:00:00','elena_1989', 'Regno Unito', 'Sony', 'PlayStation 5'),
	('24.240.24.240', '2023-03-17 09:00:00','elena_1989', 'Regno Unito', 'Sony', 'PlayStation 5'),
	('25.250.25.250', '2023-04-26 09:00:00','elena_1989', 'Regno Unito', 'Sony', 'PlayStation 5'),
	('26.260.26.260', '2023-12-20 02:00:00','paolo_m', 'Paesi Bassi', 'Samsung', 'Galaxy S21'),
	('27.270.27.270', '2023-07-17 02:00:00','paolo_m', 'Paesi Bassi', 'Samsung', 'Galaxy S21'),
	('28.280.28.280', '2023-02-04 02:00:00','paolo_m', 'Paesi Bassi', 'Samsung', 'Galaxy S21'),
	('29.290.29.290', '2023-03-07 06:00:00','silvia_g', 'Svizzera', 'Apple', 'iPhone 12 Mini'),
	('30.300.30.300', '2023-07-08 06:00:00','silvia_g', 'Svizzera', 'Apple', 'iPhone 12 Mini'),
	('31.310.31.310', '2023-01-19 06:00:00','silvia_g', 'Svizzera', 'Apple', 'iPhone 12 Mini');

-- Cronologia
insert into cronologia(Film, IP, TimestampInizio, NomeUtente) values
(1, '110.10.100.1','2020-01-01 10:34:01', 'mario_rossi91'),
(2, '110.10.100.1','2020-01-01 10:34:01', 'mario_rossi91'),
(3, '10.110.10.100','2023-03-04 08:00:46', 'mario_rossi91'),
(4, '10.110.10.100','2023-03-04 08:00:46', 'mario_rossi91'),
(5, '10.110.10.101','2023-02-04 08:00:46', 'mario_rossi91'),
(6, '10.110.10.101','2023-02-04 08:00:46', 'mario_rossi91'),
(7, '10.110.10.110','2024-01-14 08:10:46', 'mario_rossi91'),
(27, '10.110.10.110','2024-01-14 08:10:46', 'mario_rossi91'),
(9, '10.101.10.101','2024-02-04 08:00:46', 'mario_rossi91'),
(10, '10.101.10.101','2024-02-04 08:00:46', 'mario_rossi91'),
(7, '220.20.220.200','2024-01-01 00:00:01', 'anna.bianchi85'),
(8, '220.20.220.200','2024-01-01 00:00:01', 'anna.bianchi85'),
(9, '110.10.100.1','2024-02-20 09:46:13', 'anna.bianchi85'),
(10, '110.10.100.1','2024-02-20 09:46:13', 'anna.bianchi85'),
(11, '220.20.220.255','2023-12-01 00:00:01', 'anna.bianchi85'),
(12, '220.20.220.255','2023-12-01 00:00:01', 'anna.bianchi85'),
(13, '112.10.100.21','2023-11-20 09:46:13', 'anna.bianchi85'),
(3, '112.10.100.21','2023-11-20 09:46:13', 'anna.bianchi85'),
(15, '110.10.100.211','2024-02-13 11:46:13', 'anna.bianchi85'),
(16, '110.10.100.211','2024-02-13 11:46:13', 'anna.bianchi85'),
(14, '123.30.3.33','2024-02-19 10:30:01', 'luca_verdi98'),
(15, '123.30.3.33','2024-02-19 10:30:01', 'luca_verdi98'),
(16, '123.30.3.33','2019-11-30 10:30:01', 'luca_verdi98'),
(17, '123.30.3.33','2019-11-30 10:30:01', 'luca_verdi98'),
(18, '123.30.3.33','2024-02-20 10:30:01', 'luca_verdi98'),
(5, '123.30.3.33','2024-02-20 10:30:01', 'luca_verdi98'),
(20, '133.230.56.33','2019-11-29 08:30:01', 'luca_verdi98'),
(21, '133.230.56.33','2019-11-29 08:30:01', 'luca_verdi98'),
(22, '123.130.83.123','2024-02-21 04:30:01', 'luca_verdi98'),
(23, '123.130.83.123','2024-02-21 04:30:01', 'luca_verdi98'),
(19, '40.4.0.255','2023-12-07 12:30:00', 'giulia_1990'),
(20, '40.4.0.255','2023-12-07 12:30:00', 'giulia_1990'),
(21, '4.40.10.23','2023-12-20 00:01:13', 'giulia_1990'),
(22, '4.40.10.23','2023-12-20 00:01:13', 'giulia_1990'),
(23, '40.4.0.255','2023-12-08 12:30:00', 'giulia_1990'),
(24, '40.4.0.255','2023-12-08 12:30:00', 'giulia_1990'),
(25, '42.40.120.231','2024-02-20 00:01:13', 'giulia_1990'),
(7, '42.40.120.231','2024-02-20 00:01:13', 'giulia_1990'),
(27, '41.4.100.255','2024-02-07 12:30:00', 'giulia_1990'),
(1, '41.4.100.255','2024-02-07 12:30:00', 'giulia_1990'),
(1, '255.255.50.05','2023-12-20 00:01:13', 'fabio90'),
(2, '255.255.50.05','2023-12-20 00:01:13', 'fabio90'),
(3, '50.5.5.120','2023-10-7 06:02:40', 'fabio90'),
(4, '50.5.5.120','2023-10-7 06:02:40', 'fabio90'),
(5, '255.255.50.05','2022-12-20 00:01:13', 'fabio90'),
(6, '255.255.50.05','2022-12-20 00:01:13', 'fabio90'),
(7, '120.12.120.12','2006-06-06 06:56:56', 'fabio90'),
(8, '120.12.120.12','2006-06-06 06:56:56', 'fabio90'),
(9, '60.6.123.43','2023-04-20 00:01:13', 'fabio90'),
(10, '60.6.123.43','2023-04-20 00:01:13', 'fabio90'),
(7, '60.6.123.43','2023-12-25 00:00:01', 'sara_giorgi'),
(8, '60.6.123.43','2023-12-25 00:00:01', 'sara_giorgi'),
(9, '0.6.6.6','2006-06-06 06:56:56', 'sara_giorgi'),
(10, '0.6.6.6','2006-06-06 06:56:56', 'sara_giorgi'),
(11, '60.6.123.43','2023-12-24 00:00:01', 'sara_giorgi'),
(12, '60.6.123.43','2023-12-24 00:00:01', 'sara_giorgi'),
(13, '120.12.120.12','2016-06-06 08:56:56', 'sara_giorgi'),
(14, '120.12.120.12','2016-06-06 08:56:56', 'sara_giorgi'),
(20, '70.7.70.7','2013-12-25 10:00:01', 'sara_giorgi'),
(16, '70.7.70.7','2013-12-25 10:00:01', 'sara_giorgi'),
(1, '120.12.120.12','2023-06-26 13:00:00', 'claudio81'),
(2, '120.12.120.12','2023-06-26 13:00:00', 'claudio81'),
(3, '12.120.12.120','2023-07-12 12:00:00', 'claudio81'),
(4, '12.120.12.120','2023-07-12 12:00:00', 'claudio81'),
(5, '14.140.14.140','2023-09-12 12:00:00', 'claudio81'),
(6, '14.140.14.140','2023-09-12 12:00:00', 'claudio81'),
(27, '15.150.15.150','2023-10-02 12:00:00', 'claudio81'),
(8, '15.150.15.150','2023-10-02 12:00:00', 'claudio81'),
(9, '16.160.16.160','2023-05-24 12:00:00', 'claudio81'),
(13, '16.160.16.160','2023-05-24 12:00:00', 'claudio81'),
(1, '70.7.70.7','2023-05-05 11:00:00', 'laura_1995'),
(2, '70.7.70.7','2023-05-05 11:00:00', 'laura_1995'),
(3, '7.70.7.70','2023-08-20 10:00:00', 'laura_1995'),
(4, '7.70.7.70','2023-08-20 10:00:00', 'laura_1995'),
(5, '17.170.17.170','2023-07-15 10:00:00', 'laura_1995'),
(6, '17.170.17.170','2023-07-15 10:00:00', 'laura_1995'),
(15, '18.180.18.180','2023-03-28 10:00:00', 'laura_1995'),
(26, '18.180.18.180','2023-03-28 10:00:00', 'laura_1995'),
(7, '19.190.19.190','2023-07-29 10:00:00', 'laura_1995'),
(8, '19.190.19.190','2023-07-29 10:00:00', 'laura_1995'),
(1, '8.80.8.80','2023-11-02 10:00:00', 'marco_b'),
(2, '8.80.8.80','2023-11-02 10:00:00', 'marco_b'),
(3, '80.8.80.8', '2023-12-02 09:00:00', 'marco_b'),
(4, '80.8.80.8', '2023-12-02 09:00:00', 'marco_b'),
(5, '20.200.20.200', '2023-04-20 10:00:00', 'marco_b'),
(6, '20.200.20.200', '2023-04-20 10:00:00', 'marco_b'),
(17, '21.210.21.210', '2023-12-06 10:00:00', 'marco_b'),
(27, '21.210.21.210', '2023-12-06 10:00:00', 'marco_b'),
(7, '22.220.22.220', '2023-08-07 10:00:00', 'marco_b'),
(8, '22.220.22.220', '2023-08-07 10:00:00', 'marco_b'),
(24, '9.90.9.90', '2023-04-13 07:00:00', 'elena_1989'),
(27, '9.90.9.90', '2023-04-13 07:00:00', 'elena_1989'),
(26, '90.9.90.9', '2023-12-25 09:00:00', 'elena_1989'),
(25, '90.9.90.9', '2023-12-25 09:00:00', 'elena_1989'),
(23, '23.230.23.230', '2023-01-14 09:00:00', 'elena_1989'),
(22, '23.230.23.230', '2023-01-14 09:00:00', 'elena_1989'),
(21, '24.240.24.240', '2023-03-17 09:00:00', 'elena_1989'),
(20, '24.240.24.240', '2023-03-17 09:00:00', 'elena_1989'),
(19, '25.250.25.250', '2023-04-26 09:00:00', 'elena_1989'),
(18, '25.250.25.250', '2023-04-26 09:00:00', 'elena_1989'),
(27, '100.1.100.1', '2023-10-09 10:00:00', 'paolo_m'),
(26, '100.1.100.1', '2023-10-09 10:00:00', 'paolo_m'),
(25, '1.100.1.100', '2023-11-20 02:00:00', 'paolo_m'),
(24, '1.100.1.100', '2023-11-20 02:00:00', 'paolo_m'),
(23, '26.260.26.260', '2023-12-20 02:00:00', 'paolo_m'),
(22, '26.260.26.260', '2023-12-20 02:00:00', 'paolo_m'),
(21, '27.270.27.270', '2023-07-17 02:00:00', 'paolo_m'),
(20, '27.270.27.270', '2023-07-17 02:00:00', 'paolo_m'),
(19, '28.280.28.280', '2023-02-04 02:00:00', 'paolo_m'),
(18, '28.280.28.280', '2023-02-04 02:00:00', 'paolo_m'),
(26, '110.11.110.11', '2023-09-11 08:45:00', 'silvia_g'),
(25, '110.11.110.11', '2023-09-11 08:45:00', 'silvia_g'),
(24, '11.110.11.110', '2023-10-08 06:00:00', 'silvia_g'),
(23, '11.110.11.110', '2023-10-08 06:00:00', 'silvia_g'),
(22, '29.290.29.290', '2023-03-07 06:00:00', 'silvia_g'),
(21, '29.290.29.290', '2023-03-07 06:00:00', 'silvia_g'),
(20, '30.300.30.300', '2023-07-08 06:00:00', 'silvia_g'),
(19, '30.300.30.300', '2023-07-08 06:00:00', 'silvia_g'),
(18, '31.310.31.310', '2023-01-19 06:00:00', 'silvia_g'),
(17, '31.310.31.310', '2023-01-19 06:00:00', 'silvia_g'),
(28, '31.310.31.310', '2023-01-19 06:00:00', 'silvia_g');

-- Recensione
INSERT INTO Recensione (Film, Utente, Voto, Commento) VALUES
(1, 'mario_rossi91', 7, 'Mi ha colpito molto, ottima regia e interpretazione degli attori.'),
(2, 'mario_rossi91', 7, 'Interessante, ma alcune parti mi hanno lasciato perplesso.'),
(3, 'mario_rossi91', 9, 'Fantastico, uno dei migliori film visti quest\'anno.'),
(4, 'mario_rossi91', 6, 'Carino, ma mi aspettavo qualcosa di più.'),
(5, 'mario_rossi91', 8, 'Emozionante e coinvolgente, mi ha lasciato senza parole.'),
(6, 'mario_rossi91', 8, 'Spettacolare, uno dei migliori film visti quest\'anno.'),
(7, 'anna.bianchi85', 8, 'Emozionante e ben recitato, mi ha coinvolto fin dall\'inizio.'),
(8, 'anna.bianchi85', 7, 'Mi è piaciuto molto, trama avvincente e ottima recitazione degli attori.'),
(9, 'anna.bianchi85', 9, 'Fantastico, mi ha emozionato dall\'inizio alla fine.'),
(10, 'anna.bianchi85', 6, 'Divertente, ma un po\' troppo prevedibile.'),
(11, 'anna.bianchi85', 8, 'Bel film, ben diretto e con una trama intrigante.'),
(12, 'anna.bianchi85', 7, 'Interessante, mi ha fatto riflettere su diversi temi.'),
(13, 'anna.bianchi85', 8, 'Mi è piaciuto molto, ottima regia e interpretazione degli attori.'),
(14, 'luca_verdi98', 9, 'Un film avvincente, consigliato agli amanti del genere.'),
(15, 'luca_verdi98', 8, 'Mi ha colpito molto, ottima regia e interpretazione degli attori.'),
(16, 'luca_verdi98', 7, 'Bel film, ben diretto e con una trama intrigante.'),
(17, 'luca_verdi98', 6, 'Carino, ma mi aspettavo qualcosa di più.'),
(18, 'luca_verdi98', 7, 'Emozionante e coinvolgente, mi ha lasciato senza parole.'),
(19, 'giulia_1990', 7, 'Mi ha colpito molto, ottima regia e interpretazione degli attori.'),
(20, 'giulia_1990', 7, 'Interessante, ma alcune parti mi hanno lasciato perplesso.'),
(21, 'giulia_1990', 9, 'Fantastico, uno dei migliori film visti quest\'anno.'),
(22, 'giulia_1990', 5, 'Carino, ma mi aspettavo qualcosa di più.'),
(23, 'giulia_1990', 8, 'Emozionante e coinvolgente, mi ha lasciato senza parole.'),
(24, 'giulia_1990', 9, 'Spettacolare, uno dei migliori film visti quest\'anno.'),
(25, 'giulia_1990', 7, 'Interessante, mi ha fatto riflettere su diversi temi.'),
(1, 'fabio90', 7, 'Fantastico, mi ha emozionato dall\'inizio alla fine.'),
(2, 'fabio90', 6, 'Mi è piaciuto molto, trama avvincente e ottima recitazione degli attori.'),
(3, 'fabio90', 8, 'Uno dei migliori film visti quest\'anno.'),
(4, 'fabio90', 9, 'Divertente, ma un po\' troppo lungo.'),
(5, 'fabio90', 7, 'Fantastico, uno dei migliori film visti quest\'anno.'),
(6, 'fabio90', 8, 'Mi ha colpito molto, ottima regia e interpretazione degli attori.'),
(7, 'fabio90', 6, 'Interessante, mi ha fatto riflettere su diversi temi.'),
(7, 'sara_giorgi', 7, 'Mi ha colpito molto, ottima regia e interpretazione degli attori.'),
(8, 'sara_giorgi', 6, 'Interessante, ma alcune parti mi hanno lasciato perplesso.'),
(9, 'sara_giorgi', 8, 'Fantastico, uno dei migliori film visti quest\'anno.'),
(10, 'sara_giorgi', 5, 'Carino, ma mi aspettavo qualcosa di più.'),
(11, 'sara_giorgi', 7, 'Emozionante e coinvolgente, mi ha lasciato senza parole.'),
(12, 'sara_giorgi', 7, 'Spettacolare, uno dei migliori film visti quest\'anno.'),
(13, 'sara_giorgi', 9, 'Bel film, ben diretto e con una trama intrigante.'),
(14, 'sara_giorgi', 8, 'Mi è piaciuto molto, ottima regia e interpretazione degli attori.'),
(1, 'claudio81', 7, 'Fantastico, mi ha emozionato dall\'inizio alla fine.'),
(2, 'claudio81', 7, 'Mi è piaciuto molto, trama avvincente e ottima recitazione degli attori.'),
(3, 'claudio81', 9, 'Uno dei migliori film visti quest\'anno.'),
(4, 'claudio81', 10, 'Adrenalina Pura.'),
(5, 'claudio81', 7, 'Fantastico, uno dei migliori film visti quest\'anno.'),
(6, 'claudio81', 8, 'Mi ha colpito molto, ottima regia e interpretazione degli attori.'),
(1, 'laura_1995', 7, 'Fantastico, mi ha emozionato dall\'inizio alla fine.'),
(2, 'laura_1995', 7, 'Mi è piaciuto molto, trama avvincente e ottima recitazione degli attori.'),
(3, 'laura_1995', 8, 'Uno dei migliori film visti quest\'anno.'),
(4, 'laura_1995', 6, 'Divertente, ma un po\' troppo lungo.'),
(5, 'laura_1995', 10, 'Fantastico, uno dei migliori film visti quest\'anno.'),
(6, 'laura_1995', 9, 'Mi ha colpito molto, ottima regia e interpretazione degli attori.'),
(1, 'marco_b', 8, 'Fantastico, mi ha emozionato dall\'inizio alla fine.'),
(2, 'marco_b', 7, 'Mi è piaciuto molto, trama avvincente e ottima recitazione degli attori.'),
(3, 'marco_b', 9, 'Uno dei migliori film visti quest\'anno.'),
(4, 'marco_b', 6, 'Divertente, ma un po\' troppo lungo.'),
(5, 'marco_b', 8, 'Fantastico, uno dei migliori film visti quest\'anno.'),
(6, 'marco_b', 9, 'Mi ha colpito molto, ottima regia e interpretazione degli attori.'),
(26, 'laura_1995', 8, 'Fantastico, mi ha emozionato dall\'inizio alla fine.'),
(27, 'marco_b', 7, 'Mi è piaciuto molto, trama avvincente e ottima recitazione degli attori.'),
(27, 'claudio81', 9, 'Uno dei migliori film visti quest\'anno.'),
(27, 'mario_rossi91', 3, 'Troppo deludente, non lo consiglio affatto.'),
(3, 'anna.bianchi85', 2, 'Pessimo, uno spreco di tempo.'),
(5, 'luca_verdi98', 4, 'Questo film è un Picasso, e io odio Picasso.'),
(7, 'giulia_1990', 5, 'Pessimo, un\'offesa al mondo cinematografico.'),
(9, 'fabio90', 4, 'Buona storia, ma mal recitata.'),
(20, 'sara_giorgi', 3, 'Assolutamente niente di speciale, mi aspettavo di più.'),
(13, 'claudio81', 2, 'Poco interessante, noioso.'),
(15, 'laura_1995', 1, 'Uno dei peggiori film che abbia mai visto.'),
(17, 'marco_b', 5, 'Assolutamente da evitare, preferivo cenare con la suocera.'),
(24, 'elena_1989', 0, 'Interessante, ma avrei preferito non sprecare il mio tempo vedendo questa roba.'),
(27, 'paolo_m', 9, 'Bel Film'),
(26, 'paolo_m', 8, 'Daje!'),
(25, 'paolo_m', 7, 'Carino, sembra quasi un film di Sorrentino'),
(24, 'paolo_m', 6, 'Meh, Meh'),
(23, 'paolo_m', 9, 'Tanta Roba, lo rivedrei'),
(26, 'silvia_g', 6, 'Mi aspettavo di più da questo regista'),
(25, 'silvia_g', 7, 'Gli attori potevano fare un lavoro migliore'),
(24, 'silvia_g', 8, 'Mi sono sentita dentro al film, spettacolare'),
(23, 'silvia_g', 9, 'Penso abbia rivoluzionato la mia vita!'),
(22, 'silvia_g', 7, 'Carino dai!'),
(21, 'silvia_g', 4, 'Mi manca la me stessa di 2h fa'),
(28, 'silvia_g', 6, 'Carino');

insert into Streaming(CodiceServer, Ip, TimestampInizio, NomeUtente, TimestampFine) Values
	(1, '110.10.100.1','2020-01-01 10:34:01', 'mario_rossi91', '2020-01-01 13:46:01'),
	(1, '10.110.10.100', '2023-03-04 08:00:46', 'mario_rossi91', '2023-03-04 14:00:46'),
	(2, '10.110.10.101', '2023-02-04 08:00:46', 'mario_rossi91', '2023-02-04 16:00:32'),
	(2, '10.110.10.110', '2024-01-14 08:10:46', 'mario_rossi91', '2024-01-14 10:16:07'),
	(3, '10.101.10.101', '2024-02-04 08:00:46', 'mario_rossi91', '2024-02-04 12:01:34'),
	(4, '220.20.220.200', '2024-01-01 00:00:01', 'anna.bianchi85', '2024-01-01 04:43:56'),
	(4, '110.10.100.1', '2024-02-20 09:46:13', 'anna.bianchi85', '2024-02-20 12:46:13'),
	(4, '220.20.220.255', '2023-12-01 00:00:01', 'anna.bianchi85', '2023-12-01 05:40:01'),
	(253, '112.10.100.21', '2023-11-20 09:46:13', 'anna.bianchi85', '2023-11-20 14:32:13'),
	(130, '110.10.100.211', '2024-02-13 11:46:13', 'anna.bianchi85', '2024-02-13 13:51:08'),
	(37, '123.30.3.33', '2024-02-19 10:30:01', 'luca_verdi98', '2024-02-19 12:30:01'),
	(38, '123.30.3.33', '2019-11-30 10:30:01', 'luca_verdi98', '2019-11-30 10:30:01'),
	(39, '123.30.3.33', '2024-02-20 10:30:01', 'luca_verdi98', '2024-02-20 13:30:01'),
	(163, '133.230.56.33', '2019-11-29 08:30:01', 'luca_verdi98', '2019-11-29 18:30:01'),
	(165, '123.130.83.123', '2024-02-21 04:30:01', 'luca_verdi98', '2024-02-21 07:30:01'),
	(131, '40.4.0.255', '2023-12-07 12:30:00', 'giulia_1990', '2023-12-07 14:31:04'),
	(254, '4.40.10.23', '2023-12-20 00:01:13', 'giulia_1990', '2023-12-20 04:01:13'),
	(132, '40.4.0.255', '2023-12-08 12:30:00', 'giulia_1990', '2023-12-08 13:30:00'),
	(256, '42.40.120.231', '2024-02-20 00:01:13', 'giulia_1990', '2024-02-20 02:01:13'),
	(130, '41.4.100.255', '2024-02-07 12:30:00', 'giulia_1990', '2024-02-07 16:00:41'),
	(521, '255.255.50.05', '2023-12-20 00:01:13', 'fabio90', '2023-12-20 02:01:13'),
	(250, '50.5.5.120', '2023-10-7 06:02:40', 'fabio90', '2023-10-7 08:02:40'),
	(520, '255.255.50.05', '2022-12-20 00:01:13', 'fabio90', '2022-12-20 02:01:13'),
	(251, '120.12.120.12', '2006-06-06 06:56:56', 'fabio90', '2006-06-06 08:56:56'),
	(521, '60.6.123.43', '2023-04-20 00:01:13', 'fabio90', '2023-04-20 03:01:13'),
	(79, '60.6.123.43', '2023-12-25 00:00:01', 'sara_giorgi', '2023-12-25 02:00:01'),
	(370, '0.6.6.6', '2006-06-06 06:56:56', 'sara_giorgi', '2006-06-06 08:46:36'),
	(80, '60.6.123.43', '2023-12-24 00:00:01', 'sara_giorgi', '2023-12-24 03:10:01'),
	(371, '120.12.120.12', '2016-06-06 08:56:56', 'sara_giorgi', '2016-06-06 10:46:13'),
	(80, '70.7.70.7', '2013-12-25 10:00:01', 'sara_giorgi', '2013-12-25 10:00:01'),
    (1, '110.10.100.1','2020-01-01 10:34:01', 'mario_rossi91', '2020-01-01 15:46:01'),
	(1, '10.110.10.100', '2023-03-04 08:00:46', 'mario_rossi91', '2023-03-04 16:00:46'),
	(2, '10.110.10.101', '2023-02-04 08:00:46', 'mario_rossi91', '2023-02-04 18:00:32'),
	(2, '10.110.10.110', '2024-01-14 08:10:46', 'mario_rossi91', '2024-01-14 13:16:07'),
	(3, '10.101.10.101', '2024-02-04 08:00:46', 'mario_rossi91', '2024-02-04 15:01:34'),
	(4, '220.20.220.200', '2024-01-01 00:00:01', 'anna.bianchi85', '2024-01-01 07:43:56'),
	(4, '110.10.100.1', '2024-02-20 09:46:13', 'anna.bianchi85', '2024-02-20 15:46:13'),
	(4, '220.20.220.255', '2023-12-01 00:00:01', 'anna.bianchi85', '2023-12-01 15:40:01'),
	(253, '112.10.100.21', '2023-11-20 09:46:13', 'anna.bianchi85', '2023-11-20 15:32:13'),
	(130, '110.10.100.211', '2024-02-13 11:46:13', 'anna.bianchi85', '2024-02-13 14:51:08'),
	(37, '123.30.3.33', '2024-02-19 10:30:01', 'luca_verdi98', '2024-02-19 14:30:01'),
	(38, '123.30.3.33', '2019-11-30 10:30:01', 'luca_verdi98', '2019-11-30 12:30:01'),
	(39, '123.30.3.33', '2024-02-20 10:30:01', 'luca_verdi98', '2024-02-20 16:30:01'),
	(163, '133.230.56.33', '2019-11-29 08:30:01', 'luca_verdi98', '2019-11-29 20:30:01'),
	(165, '123.130.83.123', '2024-02-21 04:30:01', 'luca_verdi98', '2024-02-21 17:30:01'),
	(131, '40.4.0.255', '2023-12-07 12:30:00', 'giulia_1990', '2023-12-07 17:31:04'),
	(254, '4.40.10.23', '2023-12-20 00:01:13', 'giulia_1990', '2023-12-20 14:01:13'),
	(132, '40.4.0.255', '2023-12-08 12:30:00', 'giulia_1990', '2023-12-08 15:30:00'),
	(256, '42.40.120.231', '2024-02-20 00:01:13', 'giulia_1990', '2024-02-20 04:01:13'),
	(130, '41.4.100.255', '2024-02-07 12:30:00', 'giulia_1990', '2024-02-07 18:00:41'),
	(521, '255.255.50.05', '2023-12-20 00:01:13', 'fabio90', '2023-12-20 03:01:13'),
	(250, '50.5.5.120', '2023-10-7 06:02:40', 'fabio90', '2023-10-7 10:02:40'),
	(520, '255.255.50.05', '2022-12-20 00:01:13', 'fabio90', '2022-12-20 12:01:13'),
	(251, '120.12.120.12', '2006-06-06 06:56:56', 'fabio90', '2006-06-06 18:56:56'),
	(521, '60.6.123.43', '2023-04-20 00:01:13', 'fabio90', '2023-04-20 13:01:13'),
	(79, '60.6.123.43', '2023-12-25 00:00:01', 'sara_giorgi', '2023-12-25 12:00:01'),
	(370, '0.6.6.6', '2006-06-06 06:56:56', 'sara_giorgi', '2006-06-06 18:46:36'),
	(80, '60.6.123.43', '2023-12-24 00:00:01', 'sara_giorgi', '2023-12-24 13:10:01'),
	(371, '120.12.120.12', '2016-06-06 08:56:56', 'sara_giorgi', '2016-06-06 12:46:13'),
	(80, '70.7.70.7', '2013-12-25 10:00:01', 'sara_giorgi', '2013-12-25 12:00:01'),
    (1, '110.10.100.1','2020-01-01 10:34:01', 'mario_rossi91', '2020-01-01 17:46:01'),
	(2, '10.110.10.110', '2024-01-14 08:10:46', 'mario_rossi91', '2024-01-14 15:16:07'),
	(3, '10.101.10.101', '2024-02-04 08:00:46', 'mario_rossi91', '2024-02-04 17:01:34'),
	(4, '220.20.220.200', '2024-01-01 00:00:01', 'anna.bianchi85', '2024-01-01 17:43:56'),
	(130, '110.10.100.211', '2024-02-13 11:46:13', 'anna.bianchi85', '2024-02-13 17:51:08'),
	(37, '123.30.3.33', '2024-02-19 10:30:01', 'luca_verdi98', '2024-02-19 15:30:01'),
	(38, '123.30.3.33', '2019-11-30 10:30:01', 'luca_verdi98', '2019-11-30 17:30:01'),
	(39, '123.30.3.33', '2024-02-20 10:30:01', 'luca_verdi98', '2024-02-20 18:30:01'),
	(163, '133.230.56.33', '2019-11-29 08:30:01', 'luca_verdi98', '2019-11-29 21:30:01'),
	(132, '40.4.0.255', '2023-12-08 12:30:00', 'giulia_1990', '2023-12-08 18:30:00'),
	(256, '42.40.120.231', '2024-02-20 00:01:13', 'giulia_1990', '2024-02-20 14:01:13'),
	(130, '41.4.100.255', '2024-02-07 12:30:00', 'giulia_1990', '2024-02-07 20:00:41'),
	(521, '255.255.50.05', '2023-12-20 00:01:13', 'fabio90', '2023-12-20 13:01:13'),
	(490, '14.140.14.140', '2023-09-12 12:00:00' ,'claudio81', '2023-09-12 14:00:00' ),
	(490, '14.140.14.140', '2023-09-12 12:00:00' ,'claudio81', '2023-09-12 16:00:00' ),
	(491, '15.150.15.150', '2023-10-02 12:00:00' ,'claudio81', '2023-10-02 14:00:00' ),
	(492, '16.160.16.160', '2023-05-24 12:00:00' ,'claudio81', '2023-05-24 14:00:00' ),
	(492, '16.160.16.160', '2023-05-24 12:00:00' ,'claudio81', '2023-05-24 16:00:00' ),
	(490, '120.12.120.12', '2023-06-26 13:00:00' ,'claudio81', '2023-06-26 15:00:00' ),
	(491, '12.120.12.120', '2023-07-12 12:00:00' ,'claudio81', '2023-07-12 14:00:00' ),
	(492, '12.120.12.120', '2023-07-12 12:00:00' ,'claudio81', '2023-07-12 16:00:00' ),
	(403, '70.7.70.7', '2023-05-05 11:00:00' ,'laura_1995', '2023-05-05 13:00:00' ),
	(403, '70.7.70.7', '2023-05-05 11:00:00' ,'laura_1995', '2023-05-05 15:00:00' ),
	(404, '7.70.7.70', '2023-08-20 10:00:00' ,'laura_1995', '2023-08-20 12:00:00' ),
	(405, '17.170.17.170', '2023-07-15 10:00:00' ,'laura_1995', '2023-07-15 12:00:00' ),
	(405, '17.170.17.170', '2023-07-15 10:00:00' ,'laura_1995', '2023-07-15 14:00:00' ),
	(403, '18.180.18.180', '2023-03-28 10:00:00' ,'laura_1995', '2023-03-28 12:00:00' ),
	(404, '19.190.19.190', '2023-07-29 10:00:00' ,'laura_1995', '2023-07-29 12:00:00' ),
	(404, '19.190.19.190', '2023-07-29 10:00:00' ,'laura_1995', '2023-07-29 14:00:00' ),
	(457, '8.80.8.80', '2023-11-02 10:00:00' ,'marco_b', '2023-11-02 12:00:00' ),
	(458, '8.80.8.80', '2023-11-02 10:00:00' ,'marco_b', '2023-11-02 14:00:00' ),
	(466, '80.8.80.8', '2023-12-02 09:00:00' ,'marco_b', '2023-12-02 11:00:00' ),
	(457, '20.200.20.200', '2023-04-20 10:00:00','marco_b', '2023-04-20 12:00:00' ),
	(458, '20.200.20.200', '2023-04-20 10:00:00','marco_b', '2023-04-20 14:00:00' ),
	(459, '21.210.21.210', '2023-12-06 10:00:00','marco_b', '2023-12-06 12:00:00' ),
	(457, '22.220.22.220', '2023-08-07 10:00:00','marco_b', '2023-08-07 12:00:00' ),
	(458, '22.220.22.220', '2023-08-07 10:00:00','marco_b', '2023-08-07 14:00:00' ),
	(409, '9.90.9.90', '2023-04-13 07:00:00','elena_1989', '2023-04-13 09:00:00' ),
	(410, '9.90.9.90', '2023-04-13 07:00:00','elena_1989', '2023-04-13 11:00:00' ),
	(411, '90.9.90.9', '2023-12-25 09:00:00','elena_1989', '2023-12-25 11:00:00' ),
	(409, '23.230.23.230', '2023-01-14 09:00:00','elena_1989', '2023-01-14 11:00:00' ),
	(410, '23.230.23.230', '2023-01-14 09:00:00','elena_1989', '2023-01-14 13:00:00' ),
	(411, '24.240.24.240', '2023-03-17 09:00:00','elena_1989', '2023-03-17 11:00:00' ),
	(409, '25.250.25.250', '2023-04-26 09:00:00','elena_1989', '2023-04-26 11:00:00' ),
	(410, '25.250.25.250', '2023-04-26 09:00:00','elena_1989', '2023-04-26 13:00:00' ),
	(379, '100.1.100.1', '2023-10-09 10:00:00','paolo_m', '2023-10-09 12:00:00' ),
	(380, '100.1.100.1', '2023-10-09 10:00:00','paolo_m', '2023-10-09 14:00:00' ),
	(381, '1.100.1.100', '2023-11-20 02:00:00','paolo_m', '2023-11-20 04:00:00' ),
	(379, '26.260.26.260', '2023-12-20 02:00:00','paolo_m', '2023-12-20 04:00:00' ),
	(380, '26.260.26.260', '2023-12-20 02:00:00','paolo_m', '2023-12-20 06:00:00' ),
	(381, '27.270.27.270', '2023-07-17 02:00:00','paolo_m', '2023-07-17 04:00:00' ),
	(379, '28.280.28.280', '2023-02-04 02:00:00','paolo_m', '2023-02-04 04:00:00' ),
	(380, '28.280.28.280', '2023-02-04 02:00:00','paolo_m', '2023-02-04 06:00:00' ),
	(496, '110.11.110.11', '2023-09-11 08:45:00','silvia_g', '2023-09-11 10:45:00' ),
	(497, '110.11.110.11', '2023-09-11 08:45:00','silvia_g', '2023-09-11 12:45:00' ),
	(514, '11.110.11.110', '2023-10-08 06:00:00','silvia_g', '2023-10-08 08:00:00' ),
	(515, '29.290.29.290', '2023-03-07 06:00:00','silvia_g', '2023-03-07 08:00:00' ),
	(516, '29.290.29.290', '2023-03-07 06:00:00','silvia_g', '2023-03-07 10:00:00' ),
	(514, '30.300.30.300', '2023-07-08 06:00:00','silvia_g', '2023-07-08 08:00:00' ),
	(515, '31.310.31.310', '2023-01-19 06:00:00','silvia_g', '2023-01-19 08:00:00' ),
	(516, '31.310.31.310', '2023-01-19 06:00:00','silvia_g', '2023-01-19 10:00:00' );

call InsertRatingFilm();
call InsertRatingUtente();
call insertPoP();

set @presente = true; -- da adesso operiamo nel presente

 
	-- Call Classifica(0, 10, NULL, NULL, NULL, NULL);
	-- Call Classifica(1, 10, 'Italia', NULL, NULL, NULL);
	-- Call Classifica(2, 10, NULL, 'Italia', NULL, NULL);
	-- Call Classifica(3, 10, NULL, NULL, 'A', 1.3);
	-- Call Classifica(4, 10, 'Italia', 'Italia', NULL, NULL);
	-- Call Classifica(5, 10, 'Italia', NULL, 'A', 1.3);
	-- Call Classifica(6, 10, 'Italia', 'Italia', 'A', 1.3);
	-- Call Classifica(7, 10, 'Italia', 'Italia', 'A', 1.3);
    
    -- call FilmInclusiAbbonamentoUtente('mario_rossi91');
	-- call FilmPiuVistiUltimi7Giorni();
    
    -- call isFormatoSupportatodaDispositivo('Samsung', 'Galaxy S21', 'A', 1.3, @prova);
    -- select if(@prova, 'true', 'false');
    -- call isFormatoSupportatodaDispositivo('Samsung', 'Galaxy S21', 'J', 3.3, @prova);
	-- select if(@prova, 'true', 'false');
   
    -- call PopolaritaAttore('JHNNYDPP', @prova);
    -- select @prova;
    -- select * from Attore order by popolarita desc;
    -- select * from film where id = 16;
    
    -- call ClassificaFilm_stessaNazioneDellaConnessione('4.40.10.23', '2023-12-20 00:01:13', 'giulia_1990');
    
    -- call TempoRimasto('giulia_1990', @prova);
    -- select @prova as minuti,'->',round(@prova/60) as ore;
    
    -- call CronologiaUtente('claudio81');

     -- insert IGNORE into versione values (8, 'A', 1.3); -- inserimento di una versione di un film per provare le procedure seguenti
	 -- set @timestamp_di_prova = current_timestamp();
     -- set @utente = 'fabio90';
     -- call isFormatoSupportatodaDispositivo('Samsung', 'Galaxy S21', 'A', 1.3, @prova);
     -- select @prova;
     -- insert into Connessione(IP, TimestampInizio, Utente, TimestampFine, Nazione, MarcaDispositivo, ModelloDispositivo) values
	 -- 	('101.120.02.11', @timestamp_di_prova, @utente, null, 'Albania', 'Samsung', 'Galaxy S21');
	 -- call NuovoStreaming('101.120.02.11', @timestamp_di_prova, @utente, 8, 'A', 1.3);
     -- select * from streaming order by timestampInizio desc;
	 -- select * from cronologia order by timestampInizio desc;
     
    -- call Formati_o_Film_piu_vietati(true, 10);
    -- call Formati_o_Film_piu_vietati(false, 10);
    
    -- select * from RatingFilm order by rating desc;
    -- select * from RatingUtente order by Utente, rating desc;
    -- select Film, count(*), round(avg(rating)) as media from RatingUtente group by film order by count(*) desc, media desc;
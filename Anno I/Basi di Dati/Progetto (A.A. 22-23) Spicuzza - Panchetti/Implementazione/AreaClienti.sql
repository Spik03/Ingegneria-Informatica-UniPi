SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;
-- variabile globale per scopi implementativi
-- in modo tale da non ostacolare il popolamento di
-- istanze che risultano passate nel tempo
Set @presente = false;

-- Creazione DB
DROP DATABASE IF EXISTS `FilmSphere`; 
CREATE DATABASE IF NOT EXISTS `FilmSphere`; 

-- Area Clienti
USE `FilmSphere`;

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
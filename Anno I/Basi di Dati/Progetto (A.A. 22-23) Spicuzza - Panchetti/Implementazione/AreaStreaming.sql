SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

-- AreaStreaming
USE `FilmSphere`;

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

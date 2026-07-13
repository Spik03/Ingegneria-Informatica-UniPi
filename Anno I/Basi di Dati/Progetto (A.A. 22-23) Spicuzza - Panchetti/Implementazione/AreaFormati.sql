SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

-- AreaFormati
USE `FilmSphere`;

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

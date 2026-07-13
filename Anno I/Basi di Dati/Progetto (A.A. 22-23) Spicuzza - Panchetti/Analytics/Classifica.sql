SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

USE `FilmSphere`;

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
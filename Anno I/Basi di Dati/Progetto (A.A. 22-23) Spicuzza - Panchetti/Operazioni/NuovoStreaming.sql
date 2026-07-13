SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

USE `FilmSphere`;

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
						SIN(_latitudine / 57.2958) * SIN(n.latitudine / 57.2958)
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
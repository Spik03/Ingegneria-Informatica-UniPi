SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

USE `FilmSphere`;

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
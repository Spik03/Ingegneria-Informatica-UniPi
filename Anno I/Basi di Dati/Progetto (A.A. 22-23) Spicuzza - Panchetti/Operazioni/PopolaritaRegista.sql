SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

USE `FilmSphere`;

drop procedure if exists PopolaritaRegista;
delimiter $$
create procedure PopolaritaRegista(IN _Regista varchar(16), OUT Media_ int)
begin
	set Media_ = (select round(avg(f.voto))
					from Film F
					where F.Regista = _Regista);
end $$
delimiter ;
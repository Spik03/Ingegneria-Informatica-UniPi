SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

USE `FilmSphere`;

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
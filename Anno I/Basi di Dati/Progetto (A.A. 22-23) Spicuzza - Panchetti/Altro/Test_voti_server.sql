USE `FilmSphere`;

-- Volevamo vedere quali fossero i server con i film con qualità maggiori (aka voti superiori)
-- abbiamo notato come in un server, più film ci sono salvati per via del caching secondo Rating Utente,
-- più le sue medie si abbassano
-- Il server centrale ha i voti più bassi perché ha salvato tutti i film, indistintamente dai loro rating
with dati as(
	select Server, (round(avg(RF.rating), 2) + round(avg(RU.rating), 2) + round(avg(F.voto), 2))/3 as MediaTotale
		,round(avg(RF.rating), 2) as MediaRF, 
		round(avg(RU.rating), 2) as MediaRU, round(avg(F.voto), 2) as MediaVoti
	from PoP P
		inner join RatingUtente RF
			on P.Film = RF.film
		inner join RatingUtente RU
			on P.Film = RU.Film
		inner join FIlm F
			on P.Film = F.id
	group by Server
), FilmServer as(
	select server, count(*) as Conteggio
	from PoP
    group by server
)
select F.Server, F.Conteggio as FilmNellaCache, round(MediaTotale, 2) as MediaTotale, MediaRF, MediaRU,  MediaVoti
from dati d
	inner join FilmServer F
		on d.server = F.server
order by MediaTotale desc, MediaRF desc, MediaRU desc, MediaVoti desc, Conteggio desc;
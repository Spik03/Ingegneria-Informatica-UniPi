/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.server;

import jakarta.transaction.Transactional;
import java.util.List;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

/**
 *  Repository di listafilm
 * @author Spicuzza
 */
public interface ListaFilmRepository extends CrudRepository<ListaFilm, Long>{
    
    /**
     * Query che esegue una left join tra film e listafilm
     * per ottenere i campi necessari a instanziare un ProdottoDTO
     * @param username
     * @return 
     */
    @Query(value="SELECT f.id, f.title, f.voteAverage, f.voteCount, (lf.watchList = 1) AS watchList, (lf.watched = 1) AS watched, (lf.preferito = 1) AS preferito, "+
            "f.description, (f.adult = 1) as adult, f.posterPath "+
            "FROM film f LEFT JOIN listafilm lf ON f.id = lf.id_film AND lf.user = :username order by f.popularity DESC;", nativeQuery=true)
    public List<Object[]> getListaFilm(@Param("username") String username);
    
    /**
     * Query per verificare l'esistenza di un film nella listafilm dell'utente
     * @param id film
     * @param username
     * @return 
     */
    @Query(value="SELECT IF(COUNT(*)>0, true, false) FROM listafilm WHERE id_film= :id AND user= :username;", nativeQuery=true )
    public int exists(@Param("id") long id, @Param("username") String username);
    
    /**
     * Query per l'inserimento in listafilm
     * @param id film
     * @param username
     * @param watchlist
     * @param watched
     * @param preferito 
     */
    @Transactional
    @Modifying
    @Query(value="INSERT INTO listafilm (id_film, user, watchList, watched, preferito) VALUES (:id, :username, :watchlist, :watched, :preferito);", nativeQuery = true)
    public void insert(@Param("id") long id, @Param("username") String username, @Param("watchlist") boolean watchlist, @Param("watched") boolean watched, @Param("preferito") boolean preferito);

    /**
     * Query per eseguire l'update in listafilm
     * @param id film
     * @param username
     * @param watchlist
     * @param watched
     * @param preferito 
     */
    @Transactional
    @Modifying
    @Query(value="UPDATE listafilm SET watchlist= :watchlist, watched= :watched, preferito= :preferito WHERE id_film= :id AND user= :username", nativeQuery=true)
    public void update(@Param("id") long id, @Param("username") String username, @Param("watchlist") boolean watchlist, @Param("watched") boolean watched, @Param("preferito") boolean preferito);

    /**
     * Query per eseguire la delete in listafilm
     * @param id film
     * @param username 
     */
    @Transactional
    @Modifying
    @Query(value="DELETE FROM listafilm WHERE id_film = :id AND user = :username;", nativeQuery = true)
    public void delete(@Param("id") long id, @Param("username") String username);

}

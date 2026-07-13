/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.server;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * Classe che descrive l'entità tabella listafilm del DB
 * @author Spicuzza
 */
@Entity
@Table(name = "listafilm")
public class ListaFilm extends ListaUtente {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    
    @Column(name="id_film")
    private long id_film;

    /**
     * Costruttore
     * watchlist, watched e preferito sono indipendenti uno dall'altro in modo 
     * tale che ogni utente li possa gestire come desidera
     * @param id_film
     * @param user
     * @param watchList
     * @param watched
     * @param preferito 
     */
    public ListaFilm(long id_film, String user, boolean watchList, boolean watched, boolean preferito) {
        super(user, watchList, watched, preferito);
        this.id_film = id_film;
    }
    
    public ListaFilm() {
    }

    public long getFilm() {
        return id_film;
    }

    public void setFilm(long id_film) {
        this.id_film = id_film;
    }
    
}

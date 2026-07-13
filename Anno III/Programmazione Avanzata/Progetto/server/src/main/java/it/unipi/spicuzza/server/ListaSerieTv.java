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
 * Classe che descrive l'entità tabella listaserietv del DB
 * @author Spicuzza
 */
@Entity
@Table(name = "listaserietv")
public class ListaSerieTv extends ListaUtente {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    
    @Column(name="id_serie")
    private long id_serie;

    /**
     * Costruttore
     * watchlist, watched e preferito sono indipendenti uno dall'altro in modo 
     * tale che ogni utente li possa gestire come desidera
     * @param id_serie
     * @param user
     * @param watchList
     * @param watched
     * @param preferito 
     */
    public ListaSerieTv(long id_serie, String user, boolean watchList, boolean watched, boolean preferito) {
        super(user, watchList, watched, preferito);
        this.id_serie = id_serie;
    }
    
    public ListaSerieTv(){
    }

    public long getSerie() {
        return id_serie;
    }

    public void setSerie(long id_serie) {
        this.id_serie = id_serie;
    }
    
}

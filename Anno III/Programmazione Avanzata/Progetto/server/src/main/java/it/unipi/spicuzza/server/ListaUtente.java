/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.server;

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import java.io.Serializable;

/**
 * Superclasse di listafilm e listaserietv
 * @author Spicuzza
 */
@MappedSuperclass
public abstract class ListaUtente implements Serializable{
    @Column(name="user")
    private String user;
    @Column(name="watchlist")
    private boolean watchList;
    @Column(name="watched")
    private boolean watched;
    @Column(name="preferito")
    private boolean preferito;

    /**
     * Costruttore
     * @param user
     * @param watchList
     * @param watched
     * @param preferito 
     */
    public ListaUtente(String user, boolean watchList, boolean watched, boolean preferito) {
        this.user = user;
        this.watched = watched;
        this.preferito = preferito;
    }
    
    public ListaUtente(){
    }

    public String getUser() {
        return user;
    }

    public void setUser(String user) {
        this.user = user;
    }

    public boolean isWatched() {
        return watched;
    }

    public void setWatched(boolean watched) {
        this.watched = watched;
    }

    public boolean isPreferito() {
        return preferito;
    }

    public void setPreferito(boolean preferito) {
        this.preferito = preferito;
    }

    public boolean isWatchList() {
        return watchList;
    }

    public void setWatchList(boolean watchList) {
        this.watchList = watchList;
    }
    
    
    
}

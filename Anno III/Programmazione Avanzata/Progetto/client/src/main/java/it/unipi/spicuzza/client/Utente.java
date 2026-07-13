/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.client;

import java.io.Serializable;

/**
 *  Classe contente le informazioni dell'utente
 * @author Spicuzza
 */
public class Utente implements Serializable{
    private String username;
    private String password;
    
    /**
     * Costruttore di Utente
     * @param username
     * @param password 
     */
    public Utente(String username, String password) {
        this.username = username;
        this.password = password;
        if(username.isBlank()|| password.isBlank() || username.contains(" ") || password.contains(" "))
            throw new IllegalArgumentException("Devono esistere entrambi i campi, non possono essere vuoti e non possono contenere spazi");
    }
    
    public Utente(){
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}

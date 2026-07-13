/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.server;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.io.Serializable;

/**
 * Classe che descrive l'entità tabella utente del DB
 * @author Spicuzza
 */
@Entity
@Table(name="utente")
public class Utente implements Serializable{
    @Id
    @Column(name = "username")
    private String username;
    @Column(name="password")
    private String password;

    /**
     * Costruttore
     * @param username
     * @param password 
     */
    public Utente(String username, String password) {
        this.username = username;
        this.password = password;
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
    
    public String toString(){
        return "Username: "+ username + "; psw: " + password; 
    }
}

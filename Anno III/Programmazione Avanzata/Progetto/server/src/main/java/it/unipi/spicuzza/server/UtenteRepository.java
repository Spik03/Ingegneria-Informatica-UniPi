/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.server;

import org.springframework.data.repository.CrudRepository;

/**
 *  Repository di utente
 * @author Spicuzza
 */
public interface UtenteRepository extends CrudRepository<Utente, String>{
    /**
     * Cerca un record di utente attraverso la sua chiave primaria (username)
     * @param n username
     * @return 
     */
    Utente findByUsername(String n);
    
    
}

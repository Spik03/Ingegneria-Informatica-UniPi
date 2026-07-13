/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.server;

import com.google.gson.Gson;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * Controller di Utente
 * fornisce le API per l'interazione con utente nel DB
 * @author Spicuzza
 */
@Controller
@RequestMapping(path="/utente")
public class UtenteController {
    @Autowired
    private UtenteRepository utenteRepository;
    
    /**
     * API per il login, verifica che l'utente esista
     * e che la password (criptata) sia giusta
     * @param utente
     * @return 
     */
    @PostMapping(path="/login")
    public @ResponseBody String login(@RequestBody Utente utente){
        System.out.println("Request: "+utente);
        Utente u = utenteRepository.findByUsername(utente.getUsername());
        Gson gson = new Gson();
        System.out.println("Find: "+u);
        
        if(u!=null && BCrypt.checkpw(utente.getPassword(), u.getPassword()))
            return gson.toJson(true);
        else
            return gson.toJson(false);
    }
    
    /**
     * API per la registrazione di un nuovo utente
     * Verifica che non esista un utente con lo stesso username (chiave primaria)
     * ed eventualmente ne cripta la password prima di inserirlo nel DB
     * @param utente
     * @return 
     */
    @PutMapping(path="/register")
    public @ResponseBody String register(@RequestBody Utente utente){
        System.out.println(utente);
        Gson gson = new Gson();
        if(utenteRepository.findByUsername(utente.getUsername())!=null)
            return gson.toJson(false);
        Utente u = new Utente(utente.getUsername(), BCrypt.hashpw(utente.getPassword(), BCrypt.gensalt()));
        utenteRepository.save(u);
        System.out.println(u);
        return gson.toJson(true);
    }

    public void setUtenteRepository(UtenteRepository utenteRepository) {
        this.utenteRepository = utenteRepository;
    }
    
    
    
}

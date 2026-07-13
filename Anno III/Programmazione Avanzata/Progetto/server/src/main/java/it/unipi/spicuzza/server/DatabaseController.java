/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.server;

import com.google.gson.Gson;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

/**
 * Controller dell'omonimo Service
 * Contiene le API per testare l'esistenza del DB 
 * o di crearlo, quando richiesto
 * @author Spicuzza
 */
@RestController
@RequestMapping("/DB")
public class DatabaseController {
    @Autowired
    private DatabaseService databaseService;
    
    /**
     * API per il test dell'esistenza del DB
     */
    @GetMapping("/test")
    public @ResponseBody String TestDB(){
        Gson gson = new Gson();
        return gson.toJson(databaseService.testDB());   
    }
    
    /**
     * API per la creazione del DB
     * @return 
     */
    @PostMapping("/create")
    public @ResponseBody String creaDB(){
        Gson gson = new Gson();
        return gson.toJson(databaseService.creaDB());
    }
}

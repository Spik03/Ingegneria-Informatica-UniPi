/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.client;

import com.google.gson.JsonElement;

/**
 *  Classe che si occupa dell'interazione col Server
 *  per il controllo dell'esistenza del database e della sua eventuale creazione
 * @author Spicuzza
 */
public class DatabaseCreator extends Thread{
    
    private static boolean databaseCreato = false;
    
    private String request_path;
    private String request_method;
    
    @Override
    /**
     * Metodo che si occupa dell'invio e processazione della richiesta al server
     */
    public void run(){
        JsonCreator j = new JsonCreator(request_path, request_method);
        j.start();
        JsonElement json = j.getJson();
        databaseCreato = (json==null ? false : json.getAsBoolean());
        System.out.println("Database Esistente: "+databaseCreato);
    }
    
    /**
     * Metodo che si occupa di settare i campi request_path/metod
     * per poter inviare la richiesta di check dell'esistenza del server
     */
    public void testDB(){
        request_path = "DB/test";
        request_method = "GET";
        this.start();
    }
    
    /**
     * Metodo che si occupa di settare i campi request_path/metod
     * per poter inviare la richiesta di creazione del server (requisito di progetto)
     */
    public void creaDB(){
        request_path = "DB/create";
        request_method = "POST";
        this.start();
    }

    /**
     * ! non c'è una sincronizzazione per verificare che run() abbia eseguito
     * (verrà gestito con una join)
     * @return DB esistente o meno
     */
    public static boolean isDatabaseCreato(){
        return databaseCreato;
    }
    
}

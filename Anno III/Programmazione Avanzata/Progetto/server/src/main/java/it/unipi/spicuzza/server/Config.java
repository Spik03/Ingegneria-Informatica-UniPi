/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.server;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import org.hibernate.boot.cfgxml.internal.ConfigLoader;

/**
 * Classe Java che si occupa di caricare alcune costanti del file config.properties
 * @author Spicuzza
 */
public class Config{
    public static String TMDB_API_KEY;
    public static int MAX_PAGE;
    public static String DB;
    public static String API_URL;

    static {
        try (InputStream input = ConfigLoader.class.getClassLoader().getResourceAsStream("config.properties")) {
            if (input == null) {
                throw new IOException("Impossibile trovare config.properties");
            }

            Properties p = new Properties();
            p.load(input);

            TMDB_API_KEY = p.getProperty("TMDB_API_KEY");
            MAX_PAGE = Integer.parseInt(p.getProperty("MAX_PAGE"));
            DB = p.getProperty("DB");
            API_URL = p.getProperty("API_URL");
        } catch (IOException ex) {
            System.err.println(ex.getMessage());
        }
    }
    
    public static boolean testApi(){
        if (TMDB_API_KEY == null) {
            return false;
        } else {
            return true;
        }
    }
}

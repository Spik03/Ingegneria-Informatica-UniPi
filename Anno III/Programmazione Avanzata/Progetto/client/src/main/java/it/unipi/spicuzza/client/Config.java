/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.client;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import org.hibernate.boot.cfgxml.internal.ConfigLoader;

/**
 * Classe Java che si occupa di caricare alcune costanti del file config.properties
 * e l'username dell'utente
 * @author Spicuzza
 */
public class Config {
    public static String URL_MYSQL; // MYSQL
    public static String URL_REQ;   // SPRING
    public static String UTENTE;

    static {
        try (InputStream input = ConfigLoader.class.getClassLoader().getResourceAsStream("config.properties")) {
            if (input == null) {
                throw new IOException("Impossibile trovare config.properties");
            }

            Properties p = new Properties();
            p.load(input);

            URL_MYSQL = p.getProperty("URL_mysql");
            URL_REQ = p.getProperty("URL_req");
        } catch (IOException ex) {
            System.err.println(ex.getMessage());
        }
    }
}

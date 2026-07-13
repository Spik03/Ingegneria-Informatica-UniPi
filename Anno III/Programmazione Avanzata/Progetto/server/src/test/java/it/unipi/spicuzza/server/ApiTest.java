/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.server;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.fail;
import org.junit.jupiter.api.Test;

/**
 * UnitTest
 * @author Spicuzza
 */
public class ApiTest {
            
        /**
         * Testa la corretta importazione dell'API_KEY dal file di configurazione
         * e il suo funzionamento
         */
        @Test
        void testApi(){
            boolean test = Config.testApi();
            assertTrue(test, "Chiave API non trovata! Assicurati che 'config.properties' esista.");
            
            try {
                URL url = new URL(Config.API_URL + "/movie/popular?api_key=" + Config.TMDB_API_KEY);

                HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                connection.setRequestMethod("GET");
                connection.connect();

                int responseCode = connection.getResponseCode();
                assertTrue(responseCode == 200, "La chiave API non è funzionante. Stato risposta: " + responseCode);
            } catch (IOException ex){
                fail("Errore durante la connesione a TMDB: " + ex.getMessage());
            }
    }
}

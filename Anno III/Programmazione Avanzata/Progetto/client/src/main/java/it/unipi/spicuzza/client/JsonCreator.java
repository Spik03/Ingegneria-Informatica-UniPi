/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.client;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URL;
import javafx.application.Platform;
import javafx.scene.control.Alert;
import static javafx.scene.layout.Region.USE_PREF_SIZE;

/**
 * Classe che si occupa della creazione delle richieste al server
 * @author Spicuzza
 */
public class JsonCreator extends Thread{
    private final String URL = Config.URL_MYSQL;
    
    private final String request_path;
    private final String request_method;
    private final String request_body; // corpo richiesta POST/PUT
    private JsonElement json;
    private boolean finito;

    /**
     * Costruttore
     * @param request_path  richiesta al server
     * @param request_method tipo di richiesta (GET, POST, PUT)
     * @param request_body body della richiesta
     */
    public JsonCreator(String request_path, String request_method, String request_body){
        this.request_path = request_path;
        this.request_method = request_method.toUpperCase();
        this.request_body = request_body;
        finito = false;
    }
    
    /**
     * Costruttore per quando non è previsto un body
     * @param request_path  richiesta al server
     * @param request_method tipo di richiesta (GET, POST, PUT)
     */
    public JsonCreator(String request_path, String request_method) {
        this(request_path, request_method, null);
    }  
    
    /**
     * Metodo che si occupa dell'effettiva richiesta al server
     * in caso di connessione al server non riuscita, apre un alert
     */
    public void run(){
        synchronized (this) {
            try {
                URL url = new URL(Config.URL_REQ+ request_path);
                HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                connection.setRequestMethod(request_method); // tipo di richiesta
                
                if(request_body != null){
                    connection.setDoOutput(true);   // per scrivere nel flusso di uscita 
                    connection.setRequestProperty("content-type", "application/json"); // invieremo dei json
                    
                    // corpo della richiesta
                    try(OutputStream os = connection.getOutputStream()){
                        os.write(request_body.getBytes());
                        os.flush();
                    } 
                }

                // lettura risposta
                StringBuilder content = new StringBuilder();
                try (BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
                    String inputLine;
                    while ((inputLine = in.readLine()) != null) {
                        content.append(inputLine);
                    }
                }
                
                Gson gson = new Gson();
                json = gson.fromJson(content.toString(), JsonElement.class);
                LoginController.connected = true;
            } catch (MalformedURLException ex) {
                System.err.println("J0: "+ex.getMessage());
            } catch (ProtocolException ex) {
                System.err.println("J1: "+ex.getMessage());
            } catch (IOException ex) {
                System.err.println("J2: "+ex.getMessage());
                if(ex.getMessage().equals("Connection refused: connect")){
                    alert();
                }
            } finally{
                finito = true;
            }
        }
    }
    
    /**
     * Getter del JsonElement di risposta,
     * aspetta che la richiesta sia stata mandata e processata dal server
     * @return il JsonElement di risposta
     */
    public synchronized JsonElement getJson(){
        try {
            while(!finito){
                wait();
            }
            return json;
        }catch (InterruptedException ex) {
            System.err.println("J3: "+ex.getMessage());
        }
        
        return null;
    }
    
    /**
     * Metodo che si occupa di creare e lanciare l'alert
     */
    private void alert(){
        Platform.runLater(new Runnable(){
            @Override
            public void run(){
                Alert alert = new Alert(Alert.AlertType.WARNING);
                alert.setTitle("Attenzione");
                alert.setHeaderText("Connessione Fallita");
                alert.setContentText("Aspettare qualche secondo e ritentare o assicurarsi che il server sia online!");
                LoginController.connected = false;
                alert.getDialogPane().setExpandableContent(null);
                alert.getDialogPane().setMinHeight(USE_PREF_SIZE);
                alert.showAndWait();
            }
        });
    }
}

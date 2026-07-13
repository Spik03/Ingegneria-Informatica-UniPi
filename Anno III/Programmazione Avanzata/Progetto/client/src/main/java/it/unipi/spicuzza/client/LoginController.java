package it.unipi.spicuzza.client;

import com.google.gson.JsonElement;
import java.io.IOException;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;

/**
 *  File Controller dell'omonimo FXML
 * @author Spicuzza
 */
public class LoginController {
    @FXML private Label popolaDatabase;
    @FXML private TextField user;
    @FXML private PasswordField password;
    @FXML private Button login;
    @FXML private Button register;
    
    private DatabaseCreator d;
    
    public static boolean connected;

    /**
     * metodo che si occupa di cambiare schermata in quella principale
     * @throws IOException 
     */
    private void switchToMain() throws IOException {
        App.setRoot("main", 600, 820);
    }
    
    @FXML
    /**
     * testa il DB e resetta utente
     */
    public void initialize(){
        user.setPromptText("Username");
        password.setPromptText("Password");
        testDB();
        Config.UTENTE = "";
    }
    
    /**
     * Metodo che si occupa di inviare al server
     * la richiesta di testare l'esistenza del database
     */
    private void testDB(){
        d = new DatabaseCreator();
        d.testDB();
        try {
            d.join();
        } catch (InterruptedException ex) {
            System.err.println("LC1: "+ex.getMessage());
        }
    }
    
    @FXML
    /**
     * Metodo che si occupa di inviare al server
     * la richiesta di creazione del DB (requisito di progetto)
     */
    private void popolaDatabase(){
        d = new DatabaseCreator();
        popolaDatabase.getStyleClass().remove("text_errore");
        d.creaDB();
        try {
            d.join();
        } catch (InterruptedException ex) {
            System.err.println("LC1: "+ex.getMessage());
        }
    }
    
    @FXML
    private void login() throws IOException{
        Utente u = getUtente();
        if(u==null)
            return;
        userRequest(u, "utente/login", "POST", "{\"username\":\""+u.getUsername()+"\",\"password\":\"" + u.getPassword()+"\"}");
    }
    
    @FXML
    private void register() throws IOException{
        Utente u = getUtente();      
        if(u==null)
            return;
        userRequest(u, "utente/register", "PUT", "{\"username\":\""+u.getUsername()+"\",\"password\":\"" + u.getPassword()+"\"}");
    }
    
    private boolean userRequest(Utente u, String request_path, String request_method, String request_body){
        login.getStyleClass().remove("text_errore");
        register.getStyleClass().remove("text_errore");
        testDB();
        if(DatabaseCreator.isDatabaseCreato()){
            if(u!=null){
                JsonCreator j = new JsonCreator(request_path, request_method, request_body);
                j.start();
                JsonElement json = j.getJson();
                
                if(json==null || !json.getAsBoolean()){
                    if(request_path.contains("utente/login") && connected)
                        login.getStyleClass().add("text_errore");
                    else if(request_path.contains("utente/register") && connected)
                        register.getStyleClass().add("text_errore");
                    return false;
                }
                
                try {
                    Config.UTENTE = u.getUsername();
                    switchToMain();
                } catch (IOException ex) {
                    System.err.println("LC: "+ex.getMessage());
                }
                
                return true;
            }
        } else {
            popolaDatabase.getStyleClass().add("text_errore");
        }
        return false;
    }
    
    private Utente getUtente(){
        try{
            Utente u = new Utente(user.getText(), password.getText());
            user.getStyleClass().remove("background_errore");
            password.getStyleClass().remove("background_errore");
            return u;
        } catch(IllegalArgumentException ex){
            System.err.println("LC: "+ex.getMessage());
            user.getStyleClass().add("background_errore");
            password.getStyleClass().add("background_errore");
            return null;
        }
    }
    
}

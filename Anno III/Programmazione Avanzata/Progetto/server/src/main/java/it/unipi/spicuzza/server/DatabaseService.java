/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.server;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * Classe Service del Database
 * @author Spicuzza
 */
@Service
public class DatabaseService{
    @Value("${spring.datasource.username}")
    private String USERNAME;
    
    @Value("${spring.datasource.password}")
    private String PASSWORD;
    
    @Value("${spring.datasource.url}")
    private String URL;
    
    private final String SFILM = "film";
    private final String SSERIETV = "serieTv";
    
    private final String DB_NOME = Config.DB;
    private static final String API_URL = Config.API_URL;
    private static final String  API_KEY = Config.TMDB_API_KEY;
    
    private static boolean databaseCreato = false;
    
    /**
     * Test dell'esistenza del server
     * Essendo che, in caso non esistesse, Spring si occupa di crearlo,
     * per verificarne l'effettivà utilità si fa una select di utente
     * se da errore, le tabelle non esistono 
     * (si considera come se il DB non esistesse)
     * @return 
     */
    public boolean testDB(){
        try (Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD)){
            Statement statement = connection.createStatement(); 
            statement.executeUpdate("USE `"+DB_NOME+"`");
            statement.executeQuery("SELECT * FROM utente");
            System.out.println("Database esistente");
            databaseCreato = true;
        } catch (SQLException ex) {
            System.out.println("Database non esistente");
            databaseCreato = false;
        }
        
        return databaseCreato;
    }
    
    /**
     * Creazione del Database
     * Si occupa anche di popolare le tabelle Film e SerieTv
     * @return 
     */
    public boolean creaDB(){
        String query = "CREATE DATABASE IF NOT EXISTS `" + DB_NOME + "`";  
        
        try(Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD)){
            Statement statement = connection.createStatement();
            
            statement.executeUpdate(query);
            statement.execute("USE `"+DB_NOME+"`");
                
            statement.executeUpdate(
            // Utente
                    "Create Table utente( "
                    + " username varchar(255) NOT NULL,"
                    + " password varchar(255) NOT NULL,"
                    + " PRIMARY KEY(username));");
            // FILM
            statement.executeUpdate(
                    "Create Table film( "
                    + " id BIGINT NOT NULL," 
                    + " title VARCHAR(255) NOT NULL,"
                    + " description TEXT," 
                    + " popularity DOUBLE," 
                    + " voteAverage DOUBLE," 
                    + " voteCount INT," 
                    + " adult BOOLEAN,"
                    + " posterPath VARCHAR(255),"
                    + " PRIMARY KEY(id));");
            // SERIE TV
            statement.executeUpdate(
                    "Create Table serieTv( "
                    + " id BIGINT NOT NULL," 
                    + " title VARCHAR(255) NOT NULL,"
                    + " description TEXT," 
                    + " popularity DOUBLE," 
                    + " voteAverage DOUBLE," 
                    + " voteCount INT," 
                    + " adult BOOLEAN,"
                    + " posterPath VARCHAR(255),"
                    + " PRIMARY KEY(id));");
            // ListaFilm x utente
            statement.executeUpdate(
                        "Create TABLE listaFilm("
                        + " id BIGINT auto_increment,"
                        + " user VARCHAR(255) NOT NULL,"
                        + " watchlist BOOLEAN not null,"
                        + " watched BOOLEAN not null,"
                        + " preferito BOOLEAN not null,"
                        + " id_film BIGINT not null,"
                        + " FOREIGN KEY(user) REFERENCES utente(username) ON DELETE CASCADE ON UPDATE CASCADE,"
                        + " FOREIGN KEY(id_film) REFERENCES film(id) ON DELETE CASCADE ON UPDATE CASCADE,"
                        + " PRIMARY KEY(id));");
            // ListaSerieTv x utente
            statement.executeUpdate(
                        "Create TABLE listaSerieTv("
                        + " id BIGINT auto_increment,"
                        + " user VARCHAR(255) NOT NULL,"
                        + " watchlist BOOLEAN not null,"
                        + " watched BOOLEAN not null,"
                        + " preferito BOOLEAN not null,"
                        + " id_serie BIGINT not null,"
                        + " FOREIGN KEY(user) REFERENCES utente(username) ON DELETE CASCADE ON UPDATE CASCADE,"
                        + " FOREIGN KEY(id_serie) REFERENCES serieTv(id) ON DELETE CASCADE ON UPDATE CASCADE,"
                        + " PRIMARY KEY(id));");
                
            // otteniamo prima i Film popolari
            insertFilmsOSerie(connection, "/movie/popular?api_key="+API_KEY+"&language=it-IT&include_adult=false&sort_by=vote_average.desc", SFILM);
            // otteniamo le SerieTv popolari
            insertFilmsOSerie(connection, "/tv/popular?api_key="+API_KEY+"&language=it-IT&include_adult=false&sort_by=vote_average.desc", SSERIETV);    
            
            return true;
        } catch (SQLException ex){
            System.err.println("DC0: "+ex.getMessage());
            return ex.getMessage().contains("Table 'utente' already exists");
        }
    }
    
    /**
     * Metodo che si occupa della richiesta a TMDB (attraverso le API)
     * della lista di Film o SerieTv e di inserirli nel DB
     * @param connection
     * @param urlPath
     * @param table 
     */
    public boolean insertFilmsOSerie(Connection connection, String urlPath,String table) { 
        int extra = 0;
        for(int i=1; i<= (Config.MAX_PAGE+extra) ; ++i){
            try {
                URL url = new URL(API_URL + urlPath + "&page="+i);
                HttpURLConnection con = (HttpURLConnection) url.openConnection();
                con.setRequestMethod("GET");
                
                StringBuilder content = new StringBuilder();
                try (BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()))) {
                    String inputLine;
                    while ((inputLine = in.readLine()) != null) {
                        content.append(inputLine);
                    }
                }
                // System.out.println("Pagina "+i+" "+content.toString());
                Gson gson = new Gson();
                JsonElement json = gson.fromJson(content.toString(), JsonElement.class);
                JsonArray results = json.getAsJsonObject().get("results").getAsJsonArray();
                
                try (
                    PreparedStatement ps = connection.prepareStatement("INSERT INTO "+table+" (id, title, description, popularity, voteAverage, voteCount, adult, posterPath) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"))
                {
                    for (JsonElement element : results) {
                        JsonObject temp = element.getAsJsonObject();
                        
                        // System.out.println(temp.get("id")+" "+temp.get("title"));
                        
                        ps.setLong(1, temp.get("id").getAsLong());
                        
                        switch(table){
                            case SFILM:
                                if(checkCampo(temp, "title")){
                                    ps.setString(2, temp.get("title").getAsString());
                                } else if(checkCampo(temp, "title"))
                                    ps.setString(2, temp.get("original_title").getAsString());
                                else
                                    continue;
                                break;
                            case SSERIETV:
                                if(checkCampo(temp, "name")){
                                    ps.setString(2, temp.get("name").getAsString());
                                } else if(checkCampo(temp, "original_name"))
                                    ps.setString(2, temp.get("original_name").getAsString());
                                else
                                    continue;
                                break;
                            default:
                                continue;
                        }
                        
                        ps.setString(3, (!checkCampo(temp, "overview") ? "" : temp.get("overview").getAsString()));
                        ps.setDouble(4, (!checkCampo(temp, "popularity") ? 0 : temp.get("popularity").getAsDouble()));
                        ps.setDouble(5, (!checkCampo(temp, "vote_average") ? 0 : temp.get("vote_average").getAsDouble()));
                        ps.setInt(6,    (!checkCampo(temp, "vote_count") ? 0 : temp.get("vote_count").getAsInt()));
                        ps.setBoolean(7,(!checkCampo(temp, "adult") ? false : Boolean.parseBoolean(temp.get("adult").getAsString())));
                        ps.setString(8, (!checkCampo(temp, "poster_path") ? "" : temp.get("poster_path").getAsString()));
                        
                        ps.addBatch();
                    }
                    ps.executeBatch();
                } catch (SQLException ex) {
                    // TheMovieDB ha dei film / serieTv ridondanti, quindi in caso ne trovasse una,
                    // tento fino a max_page/2 pagine extra rispetto di contenuti 
                    extra += (extra<Config.MAX_PAGE/2 ? 1 : 0);
                    
                    System.err.println("DC1: "+ex.getMessage());
                }
            }   catch (MalformedURLException ex) {
                System.err.println("DC2: "+ex.getMessage());
                return false;
            } catch (IOException ex) {
                System.err.println("DC3: "+ex.getMessage());
                return false;
            }
        }
        
        databaseCreato = true;
        return true;
    }
    
    /**
     * Controlla se il campo desiderato nel JsonObject esiste, non è nullo
     * e in caso dei seguenti campi: name, original_name, title, original_title
     * abbia solo caratteri latini, numeri e punteggiatura
     * @param obj
     * @param campo
     * @return 
     */
    public boolean checkCampo(JsonObject obj, String campo){
        return obj.has(campo) && !obj.get(campo).isJsonNull() && (campo.contains("name") || campo.contains("title") ? obj.get(campo).getAsString().matches("^[a-zA-Z\\s\\p{Punct}0-9]*$") : true);
    }
    
    /**
     * ! non c'è un controllo per verificare se prima è stato
     * eseguito uno dei metodi sopraelencati
     * @return DB esistente o meno
     */
    public static boolean isDatabaseCreato(){
        return databaseCreato;
    }
    
    /**
     * Setter di databaseCreato
     * @param b 
     */
    public static void setDatabaseCreato(boolean b){
        databaseCreato = b;
    }
    
}

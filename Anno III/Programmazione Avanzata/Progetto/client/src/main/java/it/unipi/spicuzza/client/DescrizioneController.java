package it.unipi.spicuzza.client;


import it.unipi.spicuzza.client.ProdottoDTO;
import javafx.fxml.FXML;
import javafx.scene.control.Label;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.text.Text;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 *  File Controller dell'omonimo FXML
 * @author Spicuzza
 */
public class DescrizioneController {
    @FXML private ImageView poster;
    @FXML private Text descrizione;
    @FXML private Label voteAverage;
    @FXML private Label voteCount;
    @FXML private Label adult;
    
    private ProdottoDTO p;
    
    @FXML
    /**
     * Imposta i campi di descrizione.fxml
     * Non prevede interazione con l'utente
     * (Tralasciando quelle default)
     */
    public void initialize(){
        p = MainController.getSelezionato();
        
        poster.setImage(new Image("https://image.tmdb.org/t/p/w185"+p.getPosterPath()));
        descrizione.setWrappingWidth(350);
        descrizione.setText((p.getDescription().isBlank() ? "Descrizione non presente" : p.getDescription()));
        voteAverage.setText("Voto: " + p.getVoteAverage());
        voteCount.setText("N.Voti: "+p.getVoteCount());
        adult.setText("Over18: "+ (p.isAdult() ? "Sì" : "No"));
        
        voteAverage.getStyleClass().add("label_desc");
        voteCount.getStyleClass().add("label_desc");
        adult.getStyleClass().add("label_desc");
    }
}

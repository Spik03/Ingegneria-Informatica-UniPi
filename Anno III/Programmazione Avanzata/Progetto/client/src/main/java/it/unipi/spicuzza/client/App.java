package it.unipi.spicuzza.client;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.io.IOException;
import javafx.scene.image.Image;

/**
 * JavaFX App
 */
public class App extends Application {

    private static Scene scene;

    @Override
    public void start(Stage stage) throws IOException {
        scene = new Scene(loadFXML("login"), 400, 420);
        scene.getStylesheets().add("style.css");
        
        centraStage( stage );
        
        stage.getIcons().add(new Image("/image/icon.png"));
        stage.setTitle("Showcase Platform International Cinema");
        stage.setResizable(false);
        stage.setScene(scene);
        stage.show();
    }

    static void setRoot(String fxml) throws IOException {
        scene.setRoot(loadFXML(fxml));
    }
    
    static void setRoot(String fxml, int width, int height) throws IOException{
        scene.getWindow().setWidth(width);
        scene.getWindow().setHeight(height);
        setRoot(fxml);
    }
    
    static void openDescription(String fxml, String title) throws IOException{
        Stage desc = new Stage();
        scene = new Scene(loadFXML(fxml), 600, 321);
        scene.getStylesheets().add("style.css");
        
        centraStage( desc );
        
        desc.getIcons().add(new Image("/image/icon.png"));
        desc.setTitle(title);
        desc.setResizable(false);
        desc.setScene(scene);
        desc.show();
    }

    private static Parent loadFXML(String fxml) throws IOException {
        FXMLLoader fxmlLoader = new FXMLLoader(App.class.getResource(fxml + ".fxml"));
        return fxmlLoader.load();
    }
    
    private static void centraStage(Stage stage){
        stage.setOnShown(event -> {
            centra(stage);
        });
        
        stage.widthProperty().addListener((obs, oldWidth, newWidth) -> centra(stage));
        stage.heightProperty().addListener((obs, oldHeight, newHeight) -> centra(stage));
    }
    
    private static void centra(Stage stage){
        javafx.geometry.Rectangle2D screenBounds = javafx.stage.Screen.getPrimary().getVisualBounds();
        double x = screenBounds.getMinX() + (screenBounds.getWidth() - stage.getWidth()) / 2;
        double y = screenBounds.getMinY() + (screenBounds.getHeight() - stage.getHeight()) / 2;
        stage.setX(x);
        stage.setY(y);
    }

    public static void main(String[] args) {
        launch();
    }

}
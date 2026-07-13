module it.unipi.spicuzza.client {
    requires javafx.controls;
    requires javafx.fxml;
    
    requires java.sql; 
    requires java.net.http; 
    requires com.google.gson;
    requires org.hibernate.orm.core;
    
    requires com.fasterxml.jackson.databind;
    requires com.fasterxml.jackson.core;

    opens it.unipi.spicuzza.client to javafx.fxml;
    exports it.unipi.spicuzza.client;
}

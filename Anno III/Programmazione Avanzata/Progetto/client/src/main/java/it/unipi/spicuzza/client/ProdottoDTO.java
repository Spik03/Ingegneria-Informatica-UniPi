/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.client;

/**
 * Prodotto Data Transfer Object
 * Film e SerieTv hanno gli stessi attributi nel DB
 * ed inoltre i dati complessivi che l'applicazione necessita
 * sono il result di una left join con un'altra tabella
 * Per questo ho optato per usare un DTO rispetto a delle classi singole
 * per ogni entità del DB
 * @author Spicuzza
 */
public class ProdottoDTO {
    private long id;
    private String title;
    private double voteAverage;
    private int voteCount;
    private boolean watchList;
    private boolean watched;
    private boolean preferito;
    
    private String description;
    private boolean adult;
    private String posterPath;

    /**
     * Costruttore
     * @param id    id film / serie
     * @param title titolo
     * @param voteAverage   voto medio
     * @param voteCount numero di voti
     * @param watchList se è nella watchlist dell'utente
     * @param watched   se è nei watched dell'utente
     * @param preferito se è nei prefeferiti dell'utente
     * @param description   descrizione film / serie
     * @param adult se è per adulti
     * @param posterPath    url del poster / immagine di copertina / preview
     */
    public ProdottoDTO(long id, String title, double voteAverage, int voteCount, boolean watchList, boolean watched, boolean preferito, String description, boolean adult, String posterPath) {
        this.id = id;
        this.title = title;
        this.voteAverage = voteAverage;
        this.voteCount = voteCount;
        this.watchList = watchList;
        this.watched = watched;
        this.preferito = preferito;
        this.description = description;
        this.adult = adult;
        this.posterPath = posterPath;
    }
    
    public ProdottoDTO(){
    }
    
    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public double getVoteAverage() {
        return voteAverage;
    }

    public void setVoteAverage(double voteAverage) {
        this.voteAverage = voteAverage;
    }

    public int getVoteCount() {
        return voteCount;
    }

    public void setVoteCount(int voteCount) {
        this.voteCount = voteCount;
    }

    public boolean isWatchList() {
        return watchList;
    }

    public void setWatchList(boolean watchList) {
        this.watchList = watchList;
    }

    public boolean isWatched() {
        return watched;
    }

    public void setWatched(boolean watched) {
        this.watched = watched;
    }

    public boolean isPreferito() {
        return preferito;
    }

    public void setPreferito(boolean preferito) {
        this.preferito = preferito;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isAdult() {
        return adult;
    }

    public void setAdult(boolean adult) {
        this.adult = adult;
    }

    public String getPosterPath() {
        return posterPath;
    }

    public void setPosterPath(String posterPath) {
        this.posterPath = posterPath;
    }
    
    public String toString(){
        return id+" "+title+" "+watchList+" "+watched+" "+preferito;
    }
    
}

package it.unipi.spicuzza.client;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.google.gson.JsonElement;
import java.io.IOException;
import java.util.Set;
import javafx.collections.transformation.FilteredList;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;
import javafx.application.Platform;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.concurrent.Task;
import javafx.scene.control.TableCell;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableRow;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import javafx.scene.control.ToggleButton;
import javafx.scene.control.Tooltip;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.image.ImageView;


/**
 *  File Controller dell'omonimo FXML
 * @author Spicuzza
 */
public class MainController {
    
    private String utente;

    @FXML private Button all;
    @FXML private Button watchList;
    @FXML private Button watched;
    @FXML private Button preferito;
    @FXML private Button exit;
    @FXML private TextField search;
    @FXML private ToggleButton fos;
    @FXML private TableView table_View;
    
    private FilteredList<ProdottoDTO> film;
    private FilteredList<ProdottoDTO> serieTv;
    
    private final String[] SYMBOL = {"s", "w0", "w1", "o0", "o1", "c0", "c1", "e", "f", "t"};
    
    //isFilm / all / watchList / watched / preferito
    private boolean[] filter = {true, true, false, false, false};
    
    private static ProdottoDTO prodSelezionato;
    
    @FXML
    /**
     * Metodo che si occupa del ritorno alla pagina di login/registrazione
     */
    private void switchToLogin() throws IOException {
        App.setRoot("login", 400, 420);
    }
    
    @FXML
    /**
     * Metodo che si occupa dell'inizializzazione della scena
     * e di importare i Film e le SerieTv dal DB
     */
    public void initialize(){
        this.utente = Config.UTENTE;
        System.out.println("Utente: "+utente+ " Config: "+Config.UTENTE);
        
        all.getStyleClass().add(SYMBOL[0]);
        watchList.getStyleClass().add(SYMBOL[2]);
        watched.getStyleClass().add(SYMBOL[4]);
        preferito.getStyleClass().add(SYMBOL[6]);
        exit.getStyleClass().add(SYMBOL[7]);
        
        fos.getStyleClass().add(SYMBOL[8]);
        fos.setTooltip(new Tooltip("Film"));
        
        importFilmOrSerie(true);
        importFilmOrSerie(false);
        
        configurazioneTableView();
        tableViewMouseInteraction();
        filter[0] = true;
        setTableView(filter[0]);
        setSearchBar();
        setFilter();
    }
    
    /**
     * Si occupa di importare i Film o le Serie Tv dal DB
     * Non è una Task in quanto viene eseguito al momento dell'inizializzazione
     * e mi devo assicurare che siano importati prima di mostrare la schermata
     * @param isFilm true=film / false=serieTv
     * @return 
     */
    private boolean importFilmOrSerie(boolean isFilm){
        ObservableList<ProdottoDTO> ol;
        try{
            if(isFilm){
                JsonCreator j = new JsonCreator("listafilm/all?username="+utente, "GET");
                j.start();
                
                ol = prepareObservableList(j);
                if(ol == null)
                    return false;
                
                film = new FilteredList<>(ol, p -> true);

                return true;
            } else {
                JsonCreator j = new JsonCreator("listaserietv/all?username="+utente, "GET");
                j.start();
                
                ol = prepareObservableList(j);
                if(ol == null)
                    return false;
                
                serieTv = new FilteredList<>(ol, p -> true);

                return true;
            }
        } catch(JsonProcessingException ex){
            System.err.println("MC0: "+ex.getMessage());
            return false;
        }
    }
    
    /**
     * Metodo che prepara la ObservableList
     * @param j j.getJson() mi restituisce il json con i film / serieTv
     * @return  l'ObservableList
     * @throws JsonProcessingException 
     */
    private ObservableList<ProdottoDTO> prepareObservableList(JsonCreator j) throws JsonProcessingException{
        JsonElement json = j.getJson();

        if(json==null || json.isJsonNull() || !json.isJsonArray() || json.getAsJsonArray().size() == 0)
            return null;

        ObjectMapper mapper = new ObjectMapper();
        Set<ProdottoDTO> lista = mapper.readValue(json.toString(), new TypeReference<Set<ProdottoDTO>>() {});
        
        if (lista == null || lista.isEmpty()) {
            System.err.println("MC1: La lista è vuota o null.");
            return null;
        }
        
        return FXCollections.observableArrayList(lista);
    }

    /**
     * Metodo che si occupa della creazione delle colonne della TableView
     */
    private void configurazioneTableView() {
        TableColumn id = new TableColumn("ID");
        id.setCellValueFactory (new PropertyValueFactory<>("id"));
        id.setVisible(false);
        
        TableColumn titolo = new TableColumn("Titolo");
        titolo.setCellValueFactory (new PropertyValueFactory<>("title"));
        titolo.setId("titolo");
        
        TableColumn voto = new TableColumn("Voto");
        voto.setCellValueFactory (new PropertyValueFactory<>("voteAverage"));
        
        TableColumn nVoto = new TableColumn("N.Voti");
        nVoto.setCellValueFactory (new PropertyValueFactory<>("voteCount"));
        
        TableColumn watchList = new TableColumn("Lista");
        watchList.setCellFactory ( col -> createButtonCell("watchList"));
        watchList.getStyleClass().add("centra");
        
        TableColumn visto = new TableColumn("Visto");
        visto.setCellFactory ( col -> createButtonCell("watched"));
        visto.getStyleClass().add("centra");
        
        TableColumn preferito = new TableColumn("Preferito");
        preferito.setCellFactory ( col -> createButtonCell("preferito"));
        preferito.getStyleClass().add("centra");
        
        table_View.getColumns().addAll(id, titolo, voto, nVoto, watchList, visto, preferito);
    }

    /**
     * Metodo che switcha dalla visualizzazione dei film a quella delle serieTv
     * o viceversa
     * @param isFilm true=film / false=serieTv
     */
    private void setTableView(boolean isFilm) {
        if(isFilm){
            table_View.setItems(film);
        } else {
            table_View.setItems(serieTv);
        }
    }
    
    @FXML
    /**
     * Metodo che setta se attualmente si sta lavorando coi Film
     * o con le serieTv (in base allo stato del bottone
     * fos : "Film or SerieTv)
     */
    private void switchProdotto(){
        filter[0] = !filter[0];
        setTableView(filter[0]);
        
        if (fos.isSelected()) {
            fos.getStyleClass().remove(SYMBOL[8]);
            fos.getStyleClass().add(SYMBOL[9]);
            fos.setTooltip(new Tooltip("SerieTv"));
        } else {
            fos.getStyleClass().remove(SYMBOL[9]);
            fos.getStyleClass().add(SYMBOL[8]);
            fos.setTooltip(new Tooltip("Film"));
        }
    }

    /**
     * Metodo che si occupa di creare i 3 bottoni delle relative colonne della tableView
     * @param tipo
     * @return 
     */
    private TableCell<ProdottoDTO, Void> createButtonCell(String tipo) {
        return new TableCell<>(){
            private Button temp = new Button();
            {
                temp.setOnAction(event -> {
                    ProdottoDTO p = getTableRow().getItem();
                    
                    switch(tipo){
                        case "watchList":
                            p.setWatchList(!p.isWatchList());
                            break;
                        case "watched":
                            p.setWatched(!p.isWatched());
                            break;
                        case "preferito":
                            p.setPreferito(!p.isPreferito());
                        default:
                            break;   
                    }
                    
                    aggiornaLista(p, filter[0]);
                    aggiornaCella(p, tipo);
                    
                });
            }
            
            @Override
            protected void updateItem(Void item, boolean empty){
                super.updateItem(item, empty);
                if(empty || getTableRow()==null || getTableRow().getItem()==null){
                    setGraphic(null);
                }else{
                    ProdottoDTO prodotto = getTableRow().getItem();
                    aggiornaCella(prodotto, tipo);
                    setGraphic(temp);
                    temp.getStyleClass().add("button_table");
                }
            }
            
            private void aggiornaCella(ProdottoDTO p, String tipo){
                int s = 0;
                boolean b = false;
                switch(tipo){
                    case "watchList":
                        s = 1;
                        b = p.isWatchList();
                        break;
                    case "watched":
                        s = 3;
                        b = p.isWatched();
                        break;
                    case "preferito":
                        s = 5;
                        b = p.isPreferito();
                    default:
                        break; 
                }
                
                if(b){
                    temp.getStyleClass().remove(SYMBOL[s]);
                    temp.getStyleClass().add(SYMBOL[s+1]);
                }else{
                    temp.getStyleClass().remove(SYMBOL[s+1]);
                    temp.getStyleClass().add(SYMBOL[s]);
                }
            }

            private void aggiornaLista(ProdottoDTO p, boolean isFilm) {
                updateLista(p, isFilm);
            }
        };
    }
                
    /**
     * Metodo che si occupa di gestire la richiesta di Update dei seguenti attributi del film/serieTv al server:
     * watchList = Lista Utente
     * Watched = Visto
     * Preferito
     * i tre attributi sono indipendenti uno dall'altro in modo tale che ogni utente li possa gestire come desidera
     * Nonostante si chiami Update in realtà il server potrebbe eseguire una insert o una delete in base ai valori dei 3 attributi
     * @param p Film / SerieTv
     * @param isFilm true=Film / false=SerieTv
     * @return true=eseguito / false=non eseguito
     */
    private void updateLista(ProdottoDTO p, boolean isFilm){
        Task t = new Task<Boolean>(){
            public Boolean call(){
                if(p==null)
                    return false;

                String body = String.format(
                    "{\"id\": %d, \"user\": %s, \"watchList\": %b, \"watched\": %b, \"preferito\": %b}",
                    p.getId(),
                    "\""+utente+"\"",
                    p.isWatchList(),
                    p.isWatched(),
                    p.isPreferito()
                );
                String request = (isFilm ? "listafilm" : "listaserietv") +"/update";

                JsonCreator j = new JsonCreator(request, "POST", body);
                j.start();
                JsonElement json = j.getJson();

                if(json==null)
                    return false;

                if(json.getAsBoolean()){
                    Platform.runLater(new Runnable(){
                        public void run(){
                            filtraPerFiltri(film);
                        filtraPerFiltri(serieTv);
                        table_View.refresh();
                        }
                    });

                    System.out.println("MC2: Update eseguito");
                } else
                    System.err.println("MC2: errore nell'Update");

                return json.getAsBoolean();
            }
        };
        Thread thread = new Thread(t);
        thread.start();
    }       

    /**
     * Metodo che si occupa della configurazione della barra di ricerca
     */
    private void setSearchBar() {
        search.setPromptText("Cerca...");
        search.textProperty().addListener((observable, oldValue, newValue) -> {
            filtraPerTitoli(film, newValue);
            filtraPerTitoli(serieTv, newValue);
        });
    }
    
    /**
     * Permette il filtraggio in base al titolo
     * @param f lista di film/serietv
     * @param newValue stringa di ricerca
     */
    private void filtraPerTitoli(FilteredList<ProdottoDTO> f, String newValue){
        f.setPredicate(item -> {
            if(newValue == null || newValue.isBlank())
                return true;
            
            String lowerCase = newValue.toLowerCase();
            return item.getTitle().toLowerCase().contains(lowerCase);
        });
    }

    /**
     * Metodo che si occupa di impostare il Filtro per "Filtri"
     * true intesi come:
     * filter = { film , all, watchList, watched, preferito }
     * filter[0] se impostato a false: serieTv
     */
    private void setFilter() {
        all.setOnAction( e-> {
            filter = new boolean[]{filter[0], true, false, false, false};
            filtraPerFiltri(film);
            filtraPerFiltri(serieTv);
            System.out.println("Filter: " + outputFilter(filter) );
        });
        watchList.setOnAction( e-> {
            filter = new boolean[]{filter[0], false, true, false, false};
            filtraPerFiltri(film);
            filtraPerFiltri(serieTv);
            System.out.println("Filter: " + outputFilter(filter) );
        });
        watched.setOnAction( e-> {
            filter = new boolean[]{filter[0], false, false, true, false};
            filtraPerFiltri(film);
            filtraPerFiltri(serieTv);
            System.out.println("Filter: " + outputFilter(filter) );
        });
        preferito.setOnAction( e-> {
            filter = new boolean[]{filter[0], false, false, false, true};
            filtraPerFiltri(film);
            filtraPerFiltri(serieTv);
            System.out.println("Filter: " + outputFilter(filter) );
        });
    }
    
    /**
     * Richiama il FiltroPerFiltri in base a quale filtro è true
     * @param f lista di film/serietv
     */
    private void filtraPerFiltri(FilteredList<ProdottoDTO> f){
        if(filter[2]){
            filtraPerFiltri(f, "watchList");
        } else if(filter[3]){
            filtraPerFiltri(f, "watched");
        } else if(filter[4]){
            filtraPerFiltri(f, "preferito");
        } else
            filtraPerFiltri(f, "all");
    }
    
    /**
     * Si occupa dell'effettivo Filtraggio per filtri
     * se la barra di ricerca non è vuota, ne tiene in considerazione
     * @param f lista di film/serietv
     * @param filtro nome del filtro attivo
     */
    private void filtraPerFiltri(FilteredList<ProdottoDTO> f, String filtro){
        f.setPredicate(item -> {
            boolean filtroTitolo = search.getText()==null || search.getText().isBlank() || item.getTitle().toLowerCase().contains(search.getText().toLowerCase());
            switch(filtro){
                case "watchList":
                    return item.isWatchList() && filtroTitolo;
                case "watched":
                    return item.isWatched() && filtroTitolo;
                case "preferito":
                    return item.isPreferito() && filtroTitolo;
                default:
                    return true && filtroTitolo;
            }
        });
    }
    
    /**
     * Metodo per il debug per la stampa dei valori di
     * @param filter
     * @return 
     */
    private String outputFilter(boolean[] filter){
        String s = "";
        for(boolean x : filter){
            s+=x+" ";
        }
        return s;
    }
    
    @FXML
    /**
     * Metodo che si occupa di rimuovere il prodotto selezionato dalla WatchList
     * quando viene scelta la relativa opzione al click destro (requisito di progetto)
     */
    private void removeFromWatchList(){
        ProdottoDTO p = (ProdottoDTO) table_View.getSelectionModel().getSelectedItem();
        p.setWatchList(false);
        updateLista(p, filter[0]);
    }
    
    @FXML
    /**
     * Metodo che si occupa di rimuovere il prodotto selezionato dai Watched
     * quando viene scelta la relativa opzione al click destro (requisito di progetto)
     */
    private void removeFromWatched(){
        ProdottoDTO p = (ProdottoDTO) table_View.getSelectionModel().getSelectedItem();
        p.setWatched(false);
        updateLista(p, filter[0]);
    }
    
    @FXML
    /**
     * Metodo che si occupa di rimuovere il prodotto selezionato dai preferiti
     * quando viene scelta la relativa opzione al click destro (requisito di progetto)
     */
    private void removeFromPreferito(){
        ProdottoDTO p = (ProdottoDTO) table_View.getSelectionModel().getSelectedItem();
        p.setPreferito(false);
        updateLista(p, filter[0]);
    }

    /**
     * Metodo che si occupa dell'interazione del mouse con la TableView
     * in particolare si occupa di gestire la visualizzazione del poster / preview
     * quando il mouse è sopra un prodotto
     * e di aprire la pagina di descrizione del prodotto al doppio click
     */
    private void tableViewMouseInteraction() {
        table_View.setRowFactory(e -> {
            TableRow<ProdottoDTO> row = new TableRow<>();
            
            Tooltip t = new Tooltip();
            
            row.setOnMouseEntered(event -> {
                if(!row.isEmpty()){
                    ProdottoDTO p = row.getItem();
                    ImageView img = new ImageView("https://image.tmdb.org/t/p/w185"+p.getPosterPath());
                    img.setFitWidth(185);
                    img.setFitHeight(278);
                    t.setGraphic(img);
                    Tooltip.install(row, t);
                }
            });
            
            row.setOnMouseExited( event -> {
                Tooltip.uninstall(row, t);
            });
            
            row.setOnMouseClicked( event -> {
                if(event.getClickCount()==2){
                    try {
                        prodSelezionato = row.getItem();
                        App.openDescription("descrizione", prodSelezionato.getTitle());
                    } catch (IOException ex) {
                        System.err.println("MC3: "+ex.getMessage());
                    }
                }
            });
            
            return row;
        });
    }
    
    /**
     * ritorna il prodotto selezionato al doppio click
     * @return 
     */
    public static ProdottoDTO getSelezionato(){
        return prodSelezionato;
    }
}
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.server;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.google.gson.Gson;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * Controller di listaserietv
 * fornisce le API per l'interazione con listaserietv nel DB
 * @author Spicuzza
 */
@Controller
@RequestMapping(path="/listaserietv")
public class ListaSerieTvController {
    @Autowired
    private ListaSerieTvRepository listaSerieTvRepository;
    
    /**
     * API per ottenere il set ottenuto dalla left join tra serietv e listaserietv
     * in modo tale da avere tutti i dati necessari per una gestione
     * semplificata
     * @param username
     * @return
     * @throws JsonProcessingException 
     */
    @GetMapping(path="/all")
    public @ResponseBody Set<ProdottoDTO> getListaSerieTv(@RequestParam String username) throws JsonProcessingException{
        try{
            List<Object[]> result = listaSerieTvRepository.getListaSerieTv(username);
            return  result.stream().map(row -> {
                return new ProdottoDTO(
                    ((Number) row[0]).longValue(),
                    ((String) row[1]),              
                    ((Number) row[2]).doubleValue(),
                    ((Number) row[3]).intValue(),   
                    (row[4] != null && ((Number) row[4]).intValue() == 1),            
                    (row[5] != null && ((Number) row[5]).intValue() == 1), 
                    (row[6] != null && ((Number) row[6]).intValue() == 1),
                    ((String) row[7]),
                    (row[8] != null && ((Number) row[8]).intValue() == 1),
                    ((String) row[9]));
                }  
            ).collect(Collectors.toSet());
        } catch(Exception ex){
            System.err.println("tv: "+ ex.getMessage());
            return null;
        }
    }
    
    /**
     * API per l'update di listaserietv nel DB
     * nonostante si chiami "update" in realtà in base ai valori di
     * watchlist, watched, preferito e all'esistenza o meno di un record
     * con id_serie == id (serietv) AND user == username (quest'ultima espressione la chiameremo "vincolo")
     * ha un comportamento diverso:
     * 1) i tre valori booleani sono tutti false: elimina, se esiste,
     *      il record che rispetta il vincolo
     * 2) non esiste un record che rispetta il vincolo: lo crea e imposta i valori
     *      booleani omonimi
     * 3) esiste un valore che rispetta il vincolo; lo aggiorna secondo
     *      i valori booleani omonimi
     * @param values id (serietv) , user, watchlist, watched, preferito
     * @return 
     */    
    @PostMapping(path="/update")
    public @ResponseBody String updateListaSerieTv(@RequestBody Map<String, Object> values){
        long id = ((Number) values.get("id")).longValue();
        String username = values.get("user").toString();
        boolean watchList = (boolean) values.get("watchList");
        boolean watched = (boolean) values.get("watched");
        boolean preferito = (boolean) values.get("preferito");
        
        Gson gson = new Gson();
        
        try{
            if(!watchList && !watched && !preferito){
                if(listaSerieTvRepository.exists(id, username) == 1)
                    listaSerieTvRepository.delete(id, username);
            }else if(listaSerieTvRepository.exists(id, username) == 1)
                listaSerieTvRepository.update(id, username, watchList, watched, preferito);
            else
                listaSerieTvRepository.insert(id, username, watchList, watched, preferito);
            return gson.toJson(true);
        } catch(Exception ex){
            System.err.println("tv: "+ex.getMessage());
            return gson.toJson(false);
        }
    }
}

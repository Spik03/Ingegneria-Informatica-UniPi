/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package it.unipi.spicuzza.server;

import com.google.gson.Gson;
import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import org.springframework.security.crypto.bcrypt.BCrypt;

/**
 * unit test
 * @author Spicuzza
 */
public class UtenteTest {
    private UtenteController utenteController;
    private UtenteRepository utenteRepositoryMock;
    private Gson gson;
    
    @BeforeEach
    void setUp(){
        utenteRepositoryMock = mock(UtenteRepository.class);
        utenteController = new UtenteController();
        utenteController.setUtenteRepository(utenteRepositoryMock);
        gson = new Gson();
    }
    
    /**
     * Testa il login in caso di successo
     */
    @Test
    void testLogin(){
        Utente prova = new Utente("prova", "prova");
        Utente rep = new Utente("prova", BCrypt.hashpw("prova", BCrypt.gensalt()));
        
        when(utenteRepositoryMock.findByUsername("prova")).thenReturn(rep);
        String result = utenteController.login(prova);
        
        assertEquals(gson.toJson(true), result, "Il login dovrebbe avere successo");
        verify(utenteRepositoryMock, times(1)).findByUsername("prova");
    }
    
    /**
     * testa il login in caso di fallimento
     */
    @Test
    void  testLoginBadPassword(){
        Utente prova = new Utente("prova", "tentativo");
        Utente rep = new Utente("prova", BCrypt.hashpw("prova", BCrypt.gensalt()));
        
        when(utenteRepositoryMock.findByUsername("prova")).thenReturn(rep);
        String result = utenteController.login(prova);
        
        assertEquals(gson.toJson(false), result, "Il login dovrebbe fallire");
        verify(utenteRepositoryMock, times(1)).findByUsername("prova");
    }
    
    /**
     * testa il login in caso di fallimento
     */
    @Test
    void  testLoginBadUsername(){
        Utente prova = new Utente("tentativo", "tentativo");
        
        when(utenteRepositoryMock.findByUsername("tentativo")).thenReturn(null);
        String result = utenteController.login(prova);
        
        assertEquals(gson.toJson(false), result, "Il login dovrebbe fallire");
        verify(utenteRepositoryMock, times(1)).findByUsername("tentativo");
    }
    
    /**
     * testa la registrazione in caso di successo
     */
    @Test
    void testRegister(){
        Utente prova = new Utente("prova", "prova");
        
        when(utenteRepositoryMock.findByUsername("prova")).thenReturn(null);
        String result = utenteController.register(prova);
        
        assertEquals(gson.toJson(true), result, "La registrazione dovrebbe avere successo");
        verify(utenteRepositoryMock, times(1)).findByUsername("prova");
        verify(utenteRepositoryMock, times(1)).save(any(Utente.class));
    }
    
    /**
     * testa la registrazione in caso di insucceso
     */
    @Test
    void testRegisterBadUser(){
        Utente prova = new Utente("prova", "prova");
        
        when(utenteRepositoryMock.findByUsername("prova")).thenReturn(new Utente("prova","prova"));
        String result = utenteController.register(prova);
        
        assertEquals(gson.toJson(false), result, "La registrazione dovrebbe fallire");
        verify(utenteRepositoryMock, times(1)).findByUsername("prova");
        verify(utenteRepositoryMock, times(0)).save(any(Utente.class));        
    }
    
}

'use strict';

// mi permette di "registrare" cosa è stato premuto
function clicked(choice) {
    const action = document.getElementById("action");
    if (choice) {
        action.value = "login";
        console.log("Action: login");
    } else {
        action.value = "registrazione";
        console.log("Action: registrazione");
    }
}

// messaggio di errore in base alla situazione
function errore(){
    const error     =  new URLSearchParams(window.location.search).get('error');
    const div       = document.getElementById("div_messaggio");
    const messaggio = document.getElementById("messaggio"); 
    switch(error){
        case "invalid_credentials":
            div.style.display="block";
            messaggio.innerText = "Username o Password Errato";
            break;
        case "existing_user":
            div.style.display="block";
            messaggio.innerText = "Username già Esistente";
            break;
        default:
            div.style.display="none";
            break;
    }
}
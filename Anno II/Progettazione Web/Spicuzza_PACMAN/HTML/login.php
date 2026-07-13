<!DOCTYPE html>
<html lang="it">
    <head>
        <meta charset='utf-8'>
        <meta http-equiv='X-UA-Compatible' content='IE=edge'>
        <title>Pac-Man</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <link rel="icon" href="../Sprite/Icona/Icona.gif" type="image/gif">
        <link href="../CSS/style.css" rel="stylesheet" type="text/css">
        <link href="../CSS/login.css" rel="stylesheet" type="text/css">

        <script src="../Javascript/login.js"></script>
    </head>
    <body onload="errore();">
        <div id="container">
            <div>
                <label id="titolo">PAC-MAN</label>
            </div>
            <form id="login" method="post" action="../PHP/process_login.php">
                <div class="Flex-r">
                    <label for="username">Username:</label>
                    <input id="username" name="username" type="text" required pattern="^[a-zA-Z0-9]{1,5}$" title="Inserire da 1 a 5 caratteri alfanumerici">
                </div>
                <div class="Flex-r">
                    <label for="password">Password:</label>
                    <input id="password" name="password" type="password" required pattern="^[a-zA-Z0-9]{10}$" title="Inserire 10 caratteri">
                </div>
                <div class="Flex-r" id="last">
                    <input type="hidden" name="action" id="action">
                    <button class="Login_form" type="submit" id="Login" onclick="clicked(true);">Login</button>
                    <button class="Login_form" type="submit" id="Registrati" onclick="clicked(false);">Registrati</button>
                </div>
            </form>
            <div class="Flex-r" id="div_messaggio">
                <label id="messaggio"></label>
            </div>
        </div>
    </body>
</html>
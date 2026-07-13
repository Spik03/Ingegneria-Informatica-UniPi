<html>
<head>
    <meta charset='utf-8'>
    <meta http-equiv='X-UA-Compatible' content='IE=edge'>
    <title>TestPage</title>
    <meta name='viewport' content='width=device-width, initial-scale=1'>

    <link rel="stylesheet" type="text/css" href="../CSS/testStyle.css">
</head>
<body>
    <h1>Unit Test</h1>
    <h3>Test valori da calcolare per gli studenti</h3>
    <?php
        include("../PHP/UnitTest.php");
        $json = file_get_contents(__Dir__ . "/../config/testData.json");
        $testData = json_decode($json,true);
        if($testData === null){
            echo "Errore nella decodifica del JSON testData";
            return;
        }
        $test=[];
        $i = 0;
        foreach($testData as $data){
            $test[$i] = new UnitTest($data);
            $test[$i]->testStudente();
            $i++;
            echo "<br>";
        }
    ?>
    <h3>Test Creazione Prospetti</h3>
    <?php
        UnitTest::testCreazioneProspetti(implode(", ", [$testData[0]["matricola"],$testData[1]["matricola"]]), $testData[0]["corsoDiLaurea"], $testData[0]["dataLaurea"]);
        echo "<br>";

        for($i=2; $i<count($testData); $i++){
            UnitTest::testCreazioneProspetti($testData[$i]["matricola"], $testData[$i]["corsoDiLaurea"], $testData[$i]["dataLaurea"]);
            echo "<br>";
        }
    ?>
    <h3>Test Invio Prospetti</h3>
    <?php
        foreach($test as $t){
            $t->testInvioProspetto(3);
            echo "<br>";
        }

    ?>

</body>
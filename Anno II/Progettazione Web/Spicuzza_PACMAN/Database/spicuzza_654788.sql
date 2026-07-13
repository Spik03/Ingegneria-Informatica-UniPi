-- Progettazione Web 
DROP DATABASE if exists spicuzza_654788; 
CREATE DATABASE spicuzza_654788; 
USE spicuzza_654788; 
-- MySQL dump 10.13  Distrib 5.7.28, for Win64 (x86_64)
--
-- Host: localhost    Database: spicuzza_654788
-- ------------------------------------------------------
-- Server version	5.7.28

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `punteggio`
--

DROP TABLE IF EXISTS `punteggio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `punteggio` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(5) NOT NULL,
  `punteggio` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `username` (`username`),
  CONSTRAINT `punteggio_ibfk_1` FOREIGN KEY (`username`) REFERENCES `utente` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `punteggio`
--

LOCK TABLES `punteggio` WRITE;
/*!40000 ALTER TABLE `punteggio` DISABLE KEYS */;
INSERT INTO `punteggio` VALUES (1,'Ciao',500),(2,'Ciao',955),(3,'Ciao',45),(4,'Ciao',200),(5,'Ciao',646),(6,'Ciao',5),(7,'Ciao',11),(8,'Ciao',5),(9,'Ciao',6),(10,'Ciao',29),(11,'Ciao',9),(12,'Ciao',12),(13,'Ciao',5),(14,'Ciao',5),(15,'Ciao',136),(16,'Ciao',124),(17,'Ciao',10),(18,'Ciao',5),(19,'Ciao',5),(20,'Ciao',29),(21,'Ciao',6),(22,'Ciao',6),(23,'Ciao',5),(24,'Ciao',5),(25,'Ciao',6),(26,'Ciao',5),(27,'Ciao',6),(28,'Ciao',315),(29,'Ciao',219),(30,'Ciao',190),(31,'Spik',251),(32,'Spik',276),(33,'Ciao',61),(34,'Spik',399);
/*!40000 ALTER TABLE `punteggio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `utente`
--

DROP TABLE IF EXISTS `utente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `utente` (
  `username` varchar(5) NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `utente`
--

LOCK TABLES `utente` WRITE;
/*!40000 ALTER TABLE `utente` DISABLE KEYS */;
INSERT INTO `utente` VALUES ('Ciao','$2y$10$9fY2iOhvg3s6lKIZUI54gOZJTsZcSpjkke38xnuHreB7BB0l56kB.'),('Spik','$2y$10$FD2bpE/6Q.ZfT52PveJUkeQYOgnWHo0PpZMRsWTCtK04StqFbwQBe');
/*!40000 ALTER TABLE `utente` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-07-12 18:17:20

-- Stored Procedure --

-- Inserimento Utente --
DROP PROCEDURE IF EXISTS insertUtente;
DELIMITER $$
CREATE PROCEDURE insertUtente(IN _user VARCHAR(5), IN _password VARCHAR(255))
BEGIN
    INSERT INTO Utente (username, password) VALUES (_user, _password);
END $$
$$
DELIMITER ;

-- Recupero Utente --
DROP PROCEDURE IF EXISTS getUtente;
DELIMITER $$
CREATE PROCEDURE getUtente(IN _user VARCHAR(5))
BEGIN
    SELECT username, password
    FROM Utente 
    WHERE username = _user;
END $$
$$
DELIMITER ;

-- Inserimento Punteggio --
DROP PROCEDURE IF EXISTS insertPunteggio;
DELIMITER $$
CREATE PROCEDURE insertPunteggio(IN _user VARCHAR(5), IN _punteggio INT)
BEGIN
    INSERT INTO Punteggio (username, punteggio) VALUES (_user, _punteggio);
END $$
$$
DELIMITER ;

-- Classifica --
DROP PROCEDURE IF EXISTS getClassifica;
DELIMITER $$
CREATE PROCEDURE getClassifica(IN N INT)
BEGIN
    IF (N < 1) THEN
        SET N = 1;
    END IF;
    SELECT username, punteggio 
    FROM Punteggio 
    ORDER BY punteggio DESC 
    LIMIT N;
END $$
$$
DELIMITER ;

-- Record --
DROP PROCEDURE IF EXISTS getRecord;
DELIMITER $$
CREATE PROCEDURE getRecord(IN _user VARCHAR(5))
BEGIN
    SELECT IFNULL(MAX(punteggio), 0) AS record
    FROM Punteggio
    WHERE username = _user;
END $$
$$
DELIMITER ;

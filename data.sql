-- MySQL dump 10.13  Distrib 8.0.24, for macos11 (x86_64)
--
-- Host: 127.0.0.1    Database: db_JDMC
-- ------------------------------------------------------
-- Server version	5.5.5-10.5.11-MariaDB-1:10.5.11+maria~focal

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping data for table `tbl_AffiliateLevel`
--

LOCK TABLES `tbl_AffiliateLevel` WRITE;
/*!40000 ALTER TABLE `tbl_AffiliateLevel` DISABLE KEYS */;
INSERT INTO `tbl_AffiliateLevel` VALUES (1,'Platinum'),(2,'Gold'),(3,'Silver');
/*!40000 ALTER TABLE `tbl_AffiliateLevel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `tbl_Profile`
--

LOCK TABLES `tbl_Profile` WRITE;
/*!40000 ALTER TABLE `tbl_Profile` DISABLE KEYS */;
INSERT INTO `tbl_Profile` VALUES (1,'SuperUser'),(2,'Staff'),(3,'Dentist');
/*!40000 ALTER TABLE `tbl_Profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `tbl_UserInformation`
--

LOCK TABLES `tbl_UserInformation` WRITE;
/*!40000 ALTER TABLE `tbl_UserInformation` DISABLE KEYS */;
INSERT INTO `tbl_UserInformation` VALUES (1,'10101','Admin',NULL,'Admin',NULL,'09123456789','webmaster@email.com',1,1,'admin','cc83897986bf5b2d48c9622ddb0e62c5','2021-06-10 00:00:00',NULL,NULL,_binary '\0'),(25,'','Jhay','Tolentino','Mendoza','','09123456789','jrockhackerz@gmail.com',3,1,'jhay006','None','2021-07-11 00:00:00',NULL,NULL,_binary '\0'),(26,'111222','Zhai','Dooma','Tello','','','',2,0,'jhay12','None','2021-07-11 00:00:00',NULL,NULL,_binary '\0');
/*!40000 ALTER TABLE `tbl_UserInformation` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-07-15  7:27:22

-- MySQL dump 10.13  Distrib 8.0.24, for macos11 (x86_64)
--
-- Host: 127.0.0.1    Database: db_JDMC
-- ------------------------------------------------------
-- Server version	5.5.5-10.5.11-MariaDB-1:10.5.11+maria~focal

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `tbl_AffiliateLevel`
--

DROP TABLE IF EXISTS `tbl_AffiliateLevel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_AffiliateLevel` (
  `fld_AffiliateLevelID` int(11) NOT NULL AUTO_INCREMENT,
  `fld_AffiliateLevelName` varchar(20) NOT NULL,
  PRIMARY KEY (`fld_AffiliateLevelID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbl_AffiliateLevel`
--

LOCK TABLES `tbl_AffiliateLevel` WRITE;
/*!40000 ALTER TABLE `tbl_AffiliateLevel` DISABLE KEYS */;
INSERT INTO `tbl_AffiliateLevel` VALUES (1,'Platinum'),(2,'Gold'),(3,'Silver');
/*!40000 ALTER TABLE `tbl_AffiliateLevel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbl_Profile`
--

DROP TABLE IF EXISTS `tbl_Profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_Profile` (
  `fld_ProfileID` int(11) NOT NULL AUTO_INCREMENT,
  `fld_ProfileName` varchar(20) NOT NULL,
  PRIMARY KEY (`fld_ProfileID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbl_Profile`
--

LOCK TABLES `tbl_Profile` WRITE;
/*!40000 ALTER TABLE `tbl_Profile` DISABLE KEYS */;
INSERT INTO `tbl_Profile` VALUES (1,'SuperUser'),(2,'Staff'),(3,'Dentist');
/*!40000 ALTER TABLE `tbl_Profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbl_UserInformation`
--

DROP TABLE IF EXISTS `tbl_UserInformation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_UserInformation` (
  `fld_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `fld_EmployeeNo` varchar(20) DEFAULT NULL,
  `fld_FirstName` varchar(50) NOT NULL,
  `fld_MiddleName` varchar(50) DEFAULT NULL,
  `fld_LastName` varchar(50) NOT NULL,
  `fld_Suffix` varchar(10) DEFAULT NULL,
  `fld_ContactNumber` varchar(15) DEFAULT NULL,
  `fld_EmailAddress` varchar(100) DEFAULT NULL,
  `fld_ProfileID` int(11) NOT NULL,
  `fld_AffiliateLevelID` int(11) NOT NULL,
  `fld_Username` varchar(30) NOT NULL,
  `fld_Password` varchar(150) NOT NULL,
  `fld_DateRegistered` datetime DEFAULT NULL,
  `fld_DateUpdated` datetime DEFAULT NULL,
  `fld_DateDeleted` datetime DEFAULT NULL,
  `fld_IsDeleted` bit(1) DEFAULT NULL,
  PRIMARY KEY (`fld_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbl_UserInformation`
--

LOCK TABLES `tbl_UserInformation` WRITE;
/*!40000 ALTER TABLE `tbl_UserInformation` DISABLE KEYS */;
INSERT INTO `tbl_UserInformation` VALUES (1,'10101','Admin',NULL,'Admin',NULL,'09123456789','webmaster@email.com',1,1,'admin','cc83897986bf5b2d48c9622ddb0e62c5','2021-06-10 00:00:00',NULL,NULL,_binary '\0'),(25,'','Jhay','Tolentino','Mendoza','','09123456789','jrockhackerz@gmail.com',3,1,'jhay006','None','2021-07-11 00:00:00',NULL,NULL,_binary '\0'),(26,'111222','Zhai','Dooma','Tello','','','',2,0,'jhay12','None','2021-07-11 00:00:00',NULL,NULL,_binary '\0');
/*!40000 ALTER TABLE `tbl_UserInformation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'db_JDMC'
--
/*!50003 DROP PROCEDURE IF EXISTS `usp_AddAccount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_AddAccount`(
employee_no varchar(20),
first_name varchar(50),
middle_name varchar(50),
last_name varchar(50),
suffix varchar(10),
contact_number varchar(15),
email_address varchar(100),
profile_id int,
affiliate_level_id int,
username varchar(30),
your_password varchar(150)
)
BEGIN
	DECLARE exist int default 0;
	SELECT COUNT(*) INTO exist
    FROM tbl_UserInformation
    WHERE (fld_Username=username 
		OR fld_EmployeeNo=employee_no
    )
    AND fld_IsDeleted=false;
	IF exist = 0
		THEN
			INSERT INTO tbl_UserInformation
			(
				fld_EmployeeNo,
				fld_FirstName,
				fld_MiddleName,
				fld_LastName,
				fld_Suffix,
				fld_ContactNumber,
				fld_EmailAddress,
				fld_ProfileID,
				fld_AffiliateLevelID,
				fld_Username,
				fld_Password,
				fld_DateRegistered,
				fld_IsDeleted
			)
			VALUES
			(
				employee_no,
				first_name,
				middle_name,
				last_name,
				suffix,
				contact_number,
				email_address,
				profile_id,
				affiliate_level_id,
				username,
				your_password,
				curdate(),
				false
    
			);
		
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account is existing';
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `usp_GetLoginInformation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_GetLoginInformation`(
username varchar(30),
password varchar(150)
)
BEGIN
	SELECT fld_EmployeeNo AS employee_no,
			fld_FirstName AS first_name,
            fld_MiddleName AS middle_name,
            fld_LastName AS last_name,
            fld_Suffix AS suffix,
            fld_ContactNumber AS contact_number,
            fld_EmailAddress AS email_address,
            fld_ProfileID AS profile_id,
            fld_AffiliateLevelID AS affiliate_level_id,
            fld_DateRegistered AS date_registered
    FROM tbl_UserInformation
    WHERE fld_Username=username AND password=password
    AND fld_IsDeleted=false
    ;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `usp_GetUserInformation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_GetUserInformation`(
profile_id int,
affiliate_level int
)
BEGIN
IF affiliate_level = 0
	THEN
		SELECT fld_EmployeeNo AS employee_no,
			   fld_FirstName AS first_name,
               fld_MiddleName as middle_name,
               fld_LastName as last_name,
               fld_Suffix as suffix,
               fld_ContactNumber as contact_number,
               fld_EmailAddress as email_address,
               fld_AffiliateLevelID as affiliate_level_id,
               fld_Username as username,
               fld_DateRegistered as date_registered,
               fld_ProfileID as 'profile_id'
        FROM tbl_UserInformation
        WHERE fld_ProfileID = profile_id
        AND fld_IsDeleted = false
        ;
ELSE 
	
		SELECT fld_EmployeeNo AS employee_no,
			   fld_FirstName AS first_name,
               fld_MiddleName as middle_name,
               fld_LastName as last_name,
               fld_Suffix as suffix,
               fld_ContactNumber as contact_number,
               fld_EmailAddress as email_address,
               fld_AffiliateLevelID as affiliate_level_id,
               fld_Username as username,
               fld_DateRegistered as date_registered
        FROM tbl_UserInformation
        WHERE fld_ProfileID = profile_id
        AND fld_AffiliateLevelID = affiliate_level
        AND fld_IsDeleted = false;
END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-07-15  7:22:02

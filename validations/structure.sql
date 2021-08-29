-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3307
-- Generation Time: Jul 25, 2021 at 07:11 AM
-- Server version: 10.5.11-MariaDB-1:10.5.11+maria~focal
-- PHP Version: 8.0.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_JDMC`
--
DROP DATABASE IF EXISTS `db_JDMC`;
CREATE DATABASE IF NOT EXISTS `db_JDMC` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `db_JDMC`;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `usp_AddAccount`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_AddAccount` (`employee_no` VARCHAR(20), `first_name` VARCHAR(50), `middle_name` VARCHAR(50), `last_name` VARCHAR(50), `suffix` VARCHAR(10), `contact_number` VARCHAR(15), `email_address` VARCHAR(100), `profile_id` INT, `affiliate_level_id` INT, `username` VARCHAR(30), `your_password` VARCHAR(150))  BEGIN
	
	DECLARE exist int default 0;
    IF employee_no is not NULL OR employee_no !='None'
		then
        	SELECT COUNT(*) INTO exist
			FROM tbl_UserInformation
			WHERE (fld_Username=username
				OR (fld_EmployeeNo=employee_no AND ( fld_EmployeeNo is not NULL OR fld_EmployeeNo !='None'))
			)
			AND fld_IsDeleted=false;
	else
		SELECT COUNT(*) INTO exist
        FROM tbl_UserInformation
        WHERE fld_Username=username
        AND fld_IsDeleted=false;
	end if;
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
				fld_IsDeleted,
                fld_IsActivated,
                fld_IstemporaryPassword
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
				false,
                false,
                true
    
			);
		
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account is existing';
	END IF;
END$$

DROP PROCEDURE IF EXISTS `usp_ChangePassword`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_ChangePassword` (`new_password` VARCHAR(150), `current_password` VARCHAR(150), `username` VARCHAR(30))  BEGIN
	DECLARE exist int default 0;
    SELECT COUNT(*) INTO exist
    FROM tbl_UserInformation
    WHERE fld_Username=username
    AND fld_Password=current_password
    AND fld_IsDeleted=false;
    
    IF exist > 0
		THEN
			UPDATE tbl_UserInformation
            SET fld_Password=new_password,
				fld_DateUpdated=curdate(),
                fld_IsTemporaryPassword=false
			WHERE fld_Username=username
            AND fld_IsDeleted=false;
	else
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Account does not exist, or the current password is invalid';
	END IF;
			
END$$

DROP PROCEDURE IF EXISTS `usp_GetInformationByUsername`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_GetInformationByUsername` (`username` VARCHAR(30))  BEGIN
	DECLARE exist int default 0;
    SELECT COUNT(*) INTO exist
    FROM tbl_UserInformation
    WHERE fld_Username=username
    AND fld_IsDeleted=false;
    
    if exist > 0
		then
			SELECT fld_EmployeeNo AS employee_no,
			   fld_FirstName AS first_name,
               fld_MiddleName as middle_name,
               fld_LastName as last_name,
               fld_Suffix as suffix,
               fld_ContactNumber as contact_number,
               fld_EmailAddress as email_address,
               fld_AffiliateLevelID as affiliate_level_id,
               fld_Username as 'username',
               fld_DateRegistered as date_registered,
               fld_ProfileID as profile_id,
               fld_IsActivated as is_activated,
               fld_DateRegistered as date_registered,
               fld_IsTemporaryPassword as is_temporary_password
			FROM tbl_UserInformation
			WHERE fld_Username=username
			AND fld_IsDeleted = false;
	else
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username does not exist';
	end if;
    
END$$

DROP PROCEDURE IF EXISTS `usp_GetLoginInformation`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_GetLoginInformation` (`username` VARCHAR(30), `password` VARCHAR(150))  BEGIN
	SELECT fld_EmployeeNo AS employee_no,
			fld_FirstName AS first_name,
            fld_MiddleName AS middle_name,
            fld_LastName AS last_name,
            fld_Suffix AS suffix,
            fld_ContactNumber AS contact_number,
            fld_EmailAddress AS email_address,
            fld_ProfileID AS profile_id,
            fld_AffiliateLevelID AS affiliate_level_id,
            fld_DateRegistered AS date_registered,
            fld_IsActivated AS is_activated,
            fld_IsTemporaryPassword AS is_temporary_password,
            fld_Username AS 'username'
    FROM tbl_UserInformation
    WHERE fld_Username=username AND password=password
    AND fld_IsDeleted=false
    ;
END$$

DROP PROCEDURE IF EXISTS `usp_GetUserInformation`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_GetUserInformation` (`profile_id` INT, `affiliate_level` INT)  BEGIN
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
               fld_DateRegistered as date_registered,
               fld_IsActivated as is_activated
        FROM tbl_UserInformation
        WHERE fld_ProfileID = profile_id
        AND fld_AffiliateLevelID = affiliate_level
        AND fld_IsDeleted = false;
END IF;

END$$

DROP PROCEDURE IF EXISTS `usp_UpdateAccount`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_UpdateAccount` (`employee_no` VARCHAR(20), `first_name` VARCHAR(50), `middle_name` VARCHAR(50), `last_name` VARCHAR(50), `suffix` VARCHAR(10), `contact_no` VARCHAR(15), `email_address` VARCHAR(100), `profile_id` INT, `affiliate_level_id` INT, `username` VARCHAR(30), `is_activated` BIT, `new_employee_no` VARCHAR(20), `new_username` VARCHAR(20))  BEGIN
	DECLARE exist int default 0;

    if employee_no is not NULL AND
		employee_no !=new_employee_no
        then
			IF username !=new_username
				then
				SELECT COUNT(*) INTO exist
				FROM tbl_UserInformation
				WHERE ( fld_EmployeeNo = new_employee_no
				OR fld_Username=new_username)
                AND fld_IsDeleted = false;
                
			else
				SELECT COUNT(*) INTO exist
                FROM tbl_UserInformation
                WHERE fld_EmployeeNo = new_employee_no
                AND fld_IsDeleted=false;
			end if;
	else
		if username != new_username
			then
				SELECT COUNT(*) INTO exist
                FROM  tbl_UserInformation
                WHERE fld_Username=new_username
                AND fld_IsDeleted=false;
		END IF;
	END IF;
    
	if exist = 0
		then
			update tbl_UserInformation
            SET fld_FirstName =first_name,
				fld_MiddleName=middle_name,
                fld_LastName= last_name,
                fld_Suffix=suffix,
                fld_ContactNumber = contact_no,
                fld_EmailAddress = email_address,
                fld_ProfileID = profile_id,
                fld_AffiliateLevelID=affiliate_level_id,
                fld_EmployeeNo=new_employee_no,
                fld_Username=new_username,
                fld_IsActivated= is_activated,
                fld_DateUpdated= curdate()
			WHERE fld_Username=username;
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username/employee number was already taken, Please chooose anohter username or employee number';	
    end if;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_AffiliateLevel`
--

DROP TABLE IF EXISTS `tbl_AffiliateLevel`;
CREATE TABLE `tbl_AffiliateLevel` (
  `fld_AffiliateLevelID` int(11) NOT NULL,
  `fld_AffiliateLevelName` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_Profile`
--

DROP TABLE IF EXISTS `tbl_Profile`;
CREATE TABLE `tbl_Profile` (
  `fld_ProfileID` int(11) NOT NULL,
  `fld_ProfileName` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_UserInformation`
--

DROP TABLE IF EXISTS `tbl_UserInformation`;
CREATE TABLE `tbl_UserInformation` (
  `fld_ID` bigint(20) NOT NULL,
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
  `fld_Password` varchar(150) DEFAULT NULL,
  `fld_IsActivated` bit(1) DEFAULT NULL,
  `fld_IsTemporaryPassword` bit(1) DEFAULT NULL,
  `fld_DateRegistered` datetime DEFAULT NULL,
  `fld_DateUpdated` datetime DEFAULT NULL,
  `fld_DateDeleted` datetime DEFAULT NULL,
  `fld_IsDeleted` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_AffiliateLevel`
--
ALTER TABLE `tbl_AffiliateLevel`
  ADD PRIMARY KEY (`fld_AffiliateLevelID`);

--
-- Indexes for table `tbl_Profile`
--
ALTER TABLE `tbl_Profile`
  ADD PRIMARY KEY (`fld_ProfileID`);

--
-- Indexes for table `tbl_UserInformation`
--
ALTER TABLE `tbl_UserInformation`
  ADD PRIMARY KEY (`fld_ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_AffiliateLevel`
--
ALTER TABLE `tbl_AffiliateLevel`
  MODIFY `fld_AffiliateLevelID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_Profile`
--
ALTER TABLE `tbl_Profile`
  MODIFY `fld_ProfileID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_UserInformation`
--
ALTER TABLE `tbl_UserInformation`
  MODIFY `fld_ID` bigint(20) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

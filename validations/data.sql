-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3307
-- Generation Time: Jul 25, 2021 at 07:13 AM
-- Server version: 10.5.11-MariaDB-1:10.5.11+maria~focal
-- PHP Version: 8.0.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Database: `db_JDMC`
--

--
-- Dumping data for table `tbl_Profile`
--

INSERT INTO `tbl_Profile` (`fld_ProfileID`, `fld_ProfileName`) VALUES
(1, 'SuperUser'),
(2, 'Staff'),
(3, 'Dentist');


INSERT INTO `tbl_AffiliateLevel` (`fld_AffiliateLevelID`, `fld_AffiliateLevelName`) VALUES
(1, 'Platinum'),
(2, 'Gold'),
(3, 'Silver');

INSERT INTO `tbl_UserInformation` (`fld_ID`, `fld_EmployeeNo`, `fld_FirstName`, `fld_MiddleName`, `fld_LastName`, `fld_Suffix`, `fld_ContactNumber`, `fld_EmailAddress`, `fld_ProfileID`, `fld_AffiliateLevelID`, `fld_Username`, `fld_Password`, `fld_IsActivated`, `fld_IsTemporaryPassword`, `fld_DateRegistered`, `fld_DateUpdated`, `fld_DateDeleted`, `fld_IsDeleted`) VALUES
(1, '10101', 'Admin', NULL, 'Admin', NULL, '09123456789', 'webmaster@email.com', 1, 1, 'admin', 'cc83897986bf5b2d48c9622ddb0e62c5', b'1', b'0', '2021-06-10 00:00:00', '2021-07-25 00:00:00', NULL, b'0');


COMMIT;


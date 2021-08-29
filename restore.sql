-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3307
-- Generation Time: Aug 29, 2021 at 09:51 AM
-- Server version: 10.5.11-MariaDB-1:10.5.11+maria~focal
-- PHP Version: 8.0.9

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
                OR fld_EmailAddress=email_address
			)
			AND fld_IsDeleted=false;
	else
		SELECT COUNT(*) INTO exist
        FROM tbl_UserInformation
        WHERE (fld_Username=username OR fld_Emailaddress =email_address)
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
				current_timestamp(),
				false,
                false,
                true
    
			);
		
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account is existing';
	END IF;
END$$

DROP PROCEDURE IF EXISTS `usp_AddAppointment`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_AddAppointment` (`patient_name` VARCHAR(150), `patient_contact_no` VARCHAR(15), `email_address` VARCHAR(60), `branch_code` VARCHAR(5), `branch_name` VARCHAR(60), `appointment_date` DATETIME, `start_timeslot` INT, `end_timeslot` INT, `appointby` VARCHAR(30), `reference_code` VARCHAR(30))  BEGIN
DECLARE exist int default 0;
DECLARE insert_id bigint default 0;
SELECT COUNT(*) INTO exist
FROM tbl_Appointment
WHERE fld_DateOfAppointment = appointment_date
AND fld_StartTimeSlot >=start_timeslot
AND fld_EndTimeSlot <= end_timeslot
ANd fld_IsDeleted=0
AND fld_AppointBy = appointby;

if exist = 0
	then
		INSERT INTO tbl_Appointment
		(
			fld_PatientName,
			fld_PatientContactNumber,
			fld_EmailAddress,
			fld_BranchCode,
			fld_BranchName,
			fld_DateOfAppointment,
			fld_StartTimeSlot,
			fld_EndTimeSlot,
			fld_AppointBy,
			fld_IsDeleted

		)
		VALUES
		(
			patient_name,
			patient_contact_no,
			email_address,
			branch_code,
			branch_name,
			appointment_date,
			start_timeslot,
			end_timeslot,
			appointby,
			0

		);
        SELECT LAST_INSERT_ID() INTO insert_id;
        if insert_id > 0
			then
				call usp_InsertAppointmentReference(reference_code,insert_id);
		end if;
       
        
	ELSE 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Slot is not available';
	END IF;
END$$

DROP PROCEDURE IF EXISTS `usp_CancelAppointment`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_CancelAppointment` (`appointment_id` BIGINT, `cancelled_by` VARCHAR(30))  BEGIN
	UPDATE tbl_Appointment
    SET fld_IsCancelled=1,
		fld_DateCancelled=current_timestamp(),
        fld_CancelledBy= cancelled_by
    WHERE fld_AppointmentId = appointment_id;

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
				fld_DateUpdated=current_timestamp(),
                fld_IsTemporaryPassword=false
			WHERE fld_Username=username
            AND fld_IsDeleted=false;
	else
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Account does not exist, or the current password is invalid';
	END IF;
			
END$$

DROP PROCEDURE IF EXISTS `usp_ForgotPasswordChange`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_ForgotPasswordChange` (IN `email_address` VARCHAR(100), `reset_key` VARCHAR(100), `new_password` VARCHAR(150))  BEGIN
	DECLARE uid bigint default 0;
	SELECT fld_ID INTO uid
	FROM tbl_UserInformation	
	WHERE fld_EmailAddress= email_address
	AND fld_IsDeleted=false LIMIT 1;
    if uid > 0
		then
			UPDATE tbl_UserInformation
            SET fld_Password=new_password,
				fld_IsTemporaryPassword=false,
				fld_DateUpdated=current_timestamp()
			WHERE fld_EmailAddress=email_address
            AND fld_IsDeleted=false;
            UPDATE tbl_PasswordReset
            SET fld_IsAlreadyUsed=true
            WHERE fld_ResetKey=reset_key
            AND fld_Uid=uid;
	else
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Account does not exist';
end if;
END$$

DROP PROCEDURE IF EXISTS `usp_GetActiveResetKey`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_GetActiveResetKey` (`email_address` VARCHAR(100))  BEGIN
DECLARE uid bigint default 0;
DECLARE username varchar(30) default null;
SELECT fld_ID,fld_Username INTO uid,username
FROM tbl_UserInformation
WHERE fld_EmailAddress= email_address
AND fld_IsDeleted=false LIMIT 1;

if uid > 0
	then 
		SELECT ufn_NotExpiredKey(uid) AS 'reset_key',
			username as 'username'
        
        ;
else
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Account does not exist';
end if;

END$$

DROP PROCEDURE IF EXISTS `usp_GetAllReferenceCode`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_GetAllReferenceCode` ()  BEGIN
	SELECT fld_ReferenceId 'reference_id',
		   fld_ReferenceCode 'reference_code',
           fld_AppointmentId 'appointment_id',
           fld_DateCreated 'date_created',
           fld_DateUsed 'date_used',
           fld_IsUsed 'is_used'
    FROM tbl_AppointmentReference
    WHERE fld_IsDeleted=0;
END$$

DROP PROCEDURE IF EXISTS `usp_GetAppointmentByDate`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_GetAppointmentByDate` (`lookup_date` DATETIME, `appoint_by` VARCHAR(30), `branch_code` VARCHAR(5))  BEGIN
	SELECT  tbl_Appointment.fld_AppointmentId 'appointment_id',
			tbl_AppointmentReference.fld_ReferenceCode 'reference_code',
			tbl_Appointment.fld_PatientName 'patient_name',
			tbl_Appointment.fld_PatientContactNumber 'patient_contact_no',
            tbl_Appointment.fld_EmailAddress 'email_address',
            tbl_Appointment.fld_BranchCode 'branch_code',
            tbl_Appointment.fld_BranchName 'branch_name',
            tbl_Appointment.fld_DateOfAppointment 'appointment_date',
            tbl_Appointment.fld_StartTimeSlot 'start_timeslot',
            tbl_Appointment.fld_EndTimeSlot 'end_timeslot',
            tbl_Appointment.fld_AppointBy 'appoint_by',
            tbl_Appointment.fld_DateCancelled 'cancelled_date',
            tbl_Appointment.fld_CancelledBy 'cancelled_by',
            tbl_Appointment.fld_IsCancelled 'is_cancelled'
    FROM tbl_Appointment 
    LEFT JOIN tbl_AppointmentReference 
	ON tbl_AppointmentReference.fld_AppointmentId = tbl_Appointment.fld_appointmentId
    WHERE tbl_Appointment.fld_DateOfAppointment = lookup_date
    AND tbl_Appointment.fld_IsCancelled = false AND tbl_Appointment.fld_IsDeleted=false
    AND tbl_Appointment.fld_BranchCode=branch_code
    ANd tbl_Appointment.fld_AppointBy=appoint_by;
END$$

DROP PROCEDURE IF EXISTS `usp_GetAppointmentByRange`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_GetAppointmentByRange` (`from_range` DATETIME, `to_range` DATETIME, `branch_code` VARCHAR(5), `appoint_by` VARCHAR(30))  BEGIN
	SELECT A.fld_AppointmentId 'appointment_id',
		   A.fld_PatientName 'patient_name',
           A.fld_PatientContactNumber 'patient_contact_no',
           A.fld_EmailAddress 'email_address',
           A.fld_BranchCode 'branch_code',
           A.fld_BranchName 'branch_name',
           A.fld_DateOfAppointment 'appointment_date',
		   A.fld_StartTimeSlot 'start_timeslot',
           A.fld_EndTimeSlot 'end_timeslot',
           A.fld_AppointBy 'appoint_by',
           A.fld_DateCancelled 'cancelled_date',
           A.fld_CancelledBy 'cancelled_by',
           A.fld_IsCancelled 'is_cancelled',
           B.fld_ReferenceCode 'reference_code'
    FROM tbl_Appointment as A
    LEFT JOIN tbl_AppointmentReference as B
    ON A.fld_AppointmentId=B.fld_AppointmentId
    WHERE A.fld_DateOfAppointment >= from_range
    AND A.fld_DateOfAppointment <=to_range
    AND A.fld_AppointBy= appoint_by
    AND A.fld_BranchCode= branch_code
    AND A.fld_IsDeleted=false;
END$$

DROP PROCEDURE IF EXISTS `usp_GetAppointmentInfo`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_GetAppointmentInfo` (`appointment_id` BIGINT)  BEGIN
	SELECT fld_AppointmentId 'appointment_id',
		   fld_PatientName 'patient_name' ,
		   fld_PatientContactNumber 'patient_contact_no',
		   fld_EmailAddress 'email_address',
		   fld_BranchCode 'branch_code',
           fld_BranchName 'branch_name',
           fld_DateOfAppointment 'appointment_date',
           fld_StartTimeSlot 'start_timeslot',
           fld_EndTimeSlot 'end_timeslot',
           fld_AppointBy 'appoint_by'
    FROM tbl_Appointment
    WHERE fld_IsDeleted=0
    AND fld_AppointmentId= appointment_id
    ;
END$$

DROP PROCEDURE IF EXISTS `usp_GetAppointmentList`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_GetAppointmentList` ()  BEGIN
	SELECT fld_AppointmentId 'appointment_id',
		   fld_PatientName 'patient_name' ,
		   fld_PatientContactNumber 'patient_contact_no',
		   fld_EmailAddress 'email_address',
		   fld_BranchCode 'branch_code',
           fld_BranchName 'branch_name',
           fld_DateOfAppointment 'appointment_date',
           fld_StartTimeSlot 'start_timeslot',
           fld_EndTimeSlot 'end_timeslot',
           fld_AppointBy 'appoint_by'
    FROM tbl_Appointment
    WHERE fld_IsDeleted=0;
END$$

DROP PROCEDURE IF EXISTS `usp_GetAppointmentListBy`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_GetAppointmentListBy` (`username` VARCHAR(30), `branch_code` VARCHAR(30))  BEGIN
		SELECT appointment.fld_AppointmentId 'appointment_id',
		   appointment.fld_PatientName 'patient_name' ,
		   appointment.fld_PatientContactNumber 'patient_contact_no',
		   appointment.fld_EmailAddress 'email_address',
		   appointment.fld_BranchCode 'branch_code',
           appointment. fld_BranchName 'branch_name',
           appointment. fld_DateOfAppointment 'appointment_date',
           appointment. fld_StartTimeSlot 'start_timeslot',
           appointment. fld_EndTimeSlot 'end_timeslot',
           appointment. fld_AppointBy 'appoint_by',
           appointment. fld_IsCancelled 'is_cancelled',
           appointment. fld_DateCancelled 'cancelled_date',
           appointment. fld_CancelledBy 'cancelled_by',
          
           appointment_reference.fld_ReferenceCode 'reference_code'
           
    FROM tbl_Appointment as appointment
    LEFT JOIN tbl_AppointmentReference as appointment_reference
    ON appointment_reference.fld_AppointmentId=appointment.fld_AppointmentId
    WHERE appointment.fld_IsDeleted=0
    AND ( (branch_code is not NULL AND appointment.fld_BranchCode=branch_code)
			OR (branch_code is NULL) )
    AND appointment.fld_AppointBy=username
    ;
END$$

DROP PROCEDURE IF EXISTS `usp_GetBranchList`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_GetBranchList` ()  BEGIN
SELECT 
	fld_BranchId 'branch_id',
    fld_BranchCode 'branch_code',
    fld_BranchName 'branch_name',
    fld_BranchAddress 'branch_address',
    fld_OpenTime 'open_time',
    fld_CloseTime 'close_time',
    fld_DateCreated 'date_created'
FROM tbl_Branch
WHERE fld_IsActive=true;
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

DROP PROCEDURE IF EXISTS `usp_GetReferenceCode`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_GetReferenceCode` (IN `appointment_id` BIGINT)  BEGIN
	SELECT fld_ReferenceId 'reference_id',
		   fld_ReferenceCode 'reference_code',
		   fld_AppointmentId 'appointment_id',
           fld_DateCreated 'date_created',
           fld_DateUsed 'date_used',
           fld_IsUsed 'is_used'
    FROM tbl_AppointmentReference
    WHERE fld_IsDeleted=0
    AND fld_AppointmentId=appointment_id;

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

DROP PROCEDURE IF EXISTS `usp_InsertAppointmentReference`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_InsertAppointmentReference` (`reference_code` VARCHAR(30), `appointment_id` BIGINT)  BEGIN
	INSERT INTO tbl_AppointmentReference
    (
		fld_ReferenceCode,
        fld_AppointmentId,
        fld_DateCreated,
        fld_IsUsed,
        fld_IsDeleted
    
    )
    VALUES
    (
		reference_code,
        appointment_id,
        current_timestamp(),
        0,
        0
    
    );
END$$

DROP PROCEDURE IF EXISTS `usp_IsValidResetKey`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_IsValidResetKey` (`email_address` VARCHAR(100), `reset_key` VARCHAR(100))  BEGIN

DECLARE uid bigint default 0;
DECLARE exist int default 0;
SELECT fld_ID INTO uid
FROM tbl_UserInformation
WHERE fld_EmailAddress= email_address
AND fld_IsDeleted=false LIMIT 1;

if uid > 0
	then
		SELECT COUNT(*) INTO exist
        FROM tbl_PasswordReset
        WHERE fld_EmailAddress=email_address
        AND fld_ResetKey=reset_key
        AND ((fld_ShouldExpire=false) OR (fld_ShouldExpire=true AND fld_DateExpiration > current_timestamp()))
        AND fld_IsAlreadyUsed=false;
        
        if exist > 0
			then
            
				SELECT true as 'is_valid';
		else
			SELECT false as 'is_valid'; 
		end if;
else
	SELECT false as 'is_valid';
end if;

END$$

DROP PROCEDURE IF EXISTS `usp_ReferenceCodeIsUsed`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_ReferenceCodeIsUsed` (`reference_code` VARCHAR(30))  BEGIN
	
    DECLARE is_exist bit default 0;
    
    SELECT (COUNT(*) > 0) INTO is_exist
    FROM tbl_AppointmentReference
    WHERE fld_ReferenceCode = reference_code
    AND fld_IsDeleted=0;
    
    IF is_exist > 0
		then
			SELECT (COUNT(*) > 0) 'is_used',
					is_exist 'is_exist'
            FROM tbl_AppointmentReference
            WHERE fld_ReferenceCode= reference_code
            AND fld_IsDeleted= 0 AND fld_IsUsed = 1;
	ELSE
		SELECT 0 'is_used',
			   0 'is_exist';
	END IF;
            
END$$

DROP PROCEDURE IF EXISTS `usp_SavePasswordReset`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_SavePasswordReset` (`email_address` VARCHAR(100), `reset_key` VARCHAR(100), `should_expire` BIT)  BEGIN
declare uid bigint default 0;
declare not_expired_key varchar(100) default null;
declare username varchar(30) default null;
SELECT fld_ID,fld_Username INTO uid,username
FROM tbl_UserInformation
WHERE fld_EmailAddress = email_address
AND fld_IsDeleted= false LIMIT 1;



if uid > 0
	then 
    
	  SET not_expired_key=ufn_NotExpiredKey(uid);
      if not_expired_key is NULL
		then
			insert into tbl_PasswordReset
			(
				fld_Uid,
				fld_EmailAddress,
				fld_ResetKey,
				fld_DateRequested,
                fld_DateExpiration,
				fld_ShouldExpire,
				fld_IsAlreadyUsed
			)
			values
			(
				uid,
				email_address,
				reset_key,
				current_timestamp(),
                DATE_ADD(current_timestamp(),INTERVAL 30 minute),
				should_expire,
				0
			);
            SELECT username as 'username';
		else
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There has an active key on this account';
	end if;
else
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account is not exist';
end if;
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
                fld_DateUpdated= current_timestamp()
			WHERE fld_Username=username;
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username/employee number was already taken, Please chooose anohter username or employee number';	
    end if;
END$$

DROP PROCEDURE IF EXISTS `usp_UpdateAppointment`$$
CREATE DEFINER=`jmdc`@`%` PROCEDURE `usp_UpdateAppointment` (`appointment_id` BIGINT, `patient_name` VARCHAR(150), `patient_contact_no` VARCHAR(15), `email_address` VARCHAR(60), `branch_code` VARCHAR(5), `branch_name` VARCHAR(60), `appointment_date` DATETIME, `start_timeslot` INT, `end_timeslot` INT, `modified_by` VARCHAR(30))  BEGIN

UPDATE tbl_Appointment
SET fld_PatientName=patient_name,
	fld_PatientContactNumber=patient_contact_no,
    fld_EmailAddress = email_address,
    fld_BranchCode = branch_code,
    fld_BranchName = branch_name,
    fld_DateOfAppointment = appointment_date,
    fld_StartTimeSlot = start_timeslot,
    fld_EndTimeSlot = end_timeslot,
    fld_ModifiedBy= modified_by,
    fld_DateModified= current_timestamp()
WHERE fld_AppointmentId= appointment_id
AND (fld_IsCancelled= 0 OR fld_IsDeleted=0);

END$$

--
-- Functions
--
DROP FUNCTION IF EXISTS `ufn_NotExpiredKey`$$
CREATE DEFINER=`jmdc`@`%` FUNCTION `ufn_NotExpiredKey` (`uid` BIGINT) RETURNS VARCHAR(100) CHARSET utf8mb4 BEGIN
DECLARE reset_key varchar(100) default null;
SELECT fld_ResetKey INTO reset_key
FROM tbl_PasswordReset
WHERE fld_Uid=uid
AND ((fld_ShouldExpire=false) OR (fld_ShouldExpire=true AND fld_DateExpiration > current_timestamp()))
AND fld_IsAlreadyUsed=false;

RETURN reset_key;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_AffiliateLevel`
--

DROP TABLE IF EXISTS `tbl_AffiliateLevel`;
CREATE TABLE IF NOT EXISTS `tbl_AffiliateLevel` (
  `fld_AffiliateLevelID` int(11) NOT NULL AUTO_INCREMENT,
  `fld_AffiliateLevelName` varchar(20) NOT NULL,
  PRIMARY KEY (`fld_AffiliateLevelID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_AffiliateLevel`
--

TRUNCATE TABLE `tbl_AffiliateLevel`;
--
-- Dumping data for table `tbl_AffiliateLevel`
--

INSERT INTO `tbl_AffiliateLevel` (`fld_AffiliateLevelID`, `fld_AffiliateLevelName`) VALUES
(1, 'Platinum'),
(2, 'Gold'),
(3, 'Silver');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_Appointment`
--

DROP TABLE IF EXISTS `tbl_Appointment`;
CREATE TABLE IF NOT EXISTS `tbl_Appointment` (
  `fld_AppointmentId` bigint(20) NOT NULL AUTO_INCREMENT,
  `fld_PatientName` varchar(150) DEFAULT NULL,
  `fld_PatientContactNumber` varchar(15) DEFAULT NULL,
  `fld_EmailAddress` varchar(60) DEFAULT NULL,
  `fld_BranchCode` varchar(5) DEFAULT NULL,
  `fld_BranchName` varchar(60) DEFAULT NULL,
  `fld_DateOfAppointment` datetime DEFAULT NULL,
  `fld_StartTimeSlot` int(11) DEFAULT NULL,
  `fld_EndTimeSlot` int(11) DEFAULT NULL,
  `fld_AppointBy` varchar(30) DEFAULT NULL,
  `fld_DateCancelled` datetime DEFAULT NULL,
  `fld_ModifiedBy` varchar(30) DEFAULT NULL,
  `fld_DateModified` datetime DEFAULT NULL,
  `fld_CancelledBy` varchar(30) DEFAULT NULL,
  `fld_DateDeleted` datetime DEFAULT NULL,
  `fld_DeletedBy` varchar(30) DEFAULT NULL,
  `fld_IsDeleted` bit(1) DEFAULT NULL,
  `fld_IsCancelled` bit(1) DEFAULT NULL,
  PRIMARY KEY (`fld_AppointmentId`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_Appointment`
--

TRUNCATE TABLE `tbl_Appointment`;
--
-- Dumping data for table `tbl_Appointment`
--

INSERT INTO `tbl_Appointment` (`fld_AppointmentId`, `fld_PatientName`, `fld_PatientContactNumber`, `fld_EmailAddress`, `fld_BranchCode`, `fld_BranchName`, `fld_DateOfAppointment`, `fld_StartTimeSlot`, `fld_EndTimeSlot`, `fld_AppointBy`, `fld_DateCancelled`, `fld_ModifiedBy`, `fld_DateModified`, `fld_CancelledBy`, `fld_DateDeleted`, `fld_DeletedBy`, `fld_IsDeleted`, `fld_IsCancelled`) VALUES
(1, 'Jhay Mendoza', '09381250716', 'jrockhackerz@gmail.com', 'BR1', 'Branch 1', '2021-08-29 00:00:00', 600, 800, 'admin', NULL, NULL, NULL, NULL, NULL, NULL, b'0', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_AppointmentReference`
--

DROP TABLE IF EXISTS `tbl_AppointmentReference`;
CREATE TABLE IF NOT EXISTS `tbl_AppointmentReference` (
  `fld_ReferenceId` bigint(20) NOT NULL AUTO_INCREMENT,
  `fld_ReferenceCode` varchar(30) DEFAULT NULL,
  `fld_AppointmentId` bigint(20) DEFAULT NULL,
  `fld_DateCreated` datetime DEFAULT NULL,
  `fld_DateUsed` datetime DEFAULT NULL,
  `fld_IsUsed` bit(1) DEFAULT NULL,
  `fld_IsDeleted` bit(1) DEFAULT NULL,
  PRIMARY KEY (`fld_ReferenceId`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_AppointmentReference`
--

TRUNCATE TABLE `tbl_AppointmentReference`;
--
-- Dumping data for table `tbl_AppointmentReference`
--

INSERT INTO `tbl_AppointmentReference` (`fld_ReferenceId`, `fld_ReferenceCode`, `fld_AppointmentId`, `fld_DateCreated`, `fld_DateUsed`, `fld_IsUsed`, `fld_IsDeleted`) VALUES
(1, 'AP2021-08-0001', 1, '2021-08-28 11:23:39', NULL, b'0', b'0');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_Branch`
--

DROP TABLE IF EXISTS `tbl_Branch`;
CREATE TABLE IF NOT EXISTS `tbl_Branch` (
  `fld_BranchId` bigint(20) NOT NULL AUTO_INCREMENT,
  `fld_BranchCode` varchar(5) DEFAULT NULL,
  `fld_BranchName` varchar(60) DEFAULT NULL,
  `fld_BranchAddress` varchar(250) DEFAULT NULL,
  `fld_OpenTime` int(11) DEFAULT NULL,
  `fld_CloseTime` int(11) DEFAULT NULL,
  `fld_DateCreated` datetime DEFAULT NULL,
  `fld_IsActive` bit(1) DEFAULT NULL,
  PRIMARY KEY (`fld_BranchId`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_Branch`
--

TRUNCATE TABLE `tbl_Branch`;
--
-- Dumping data for table `tbl_Branch`
--

INSERT INTO `tbl_Branch` (`fld_BranchId`, `fld_BranchCode`, `fld_BranchName`, `fld_BranchAddress`, `fld_OpenTime`, `fld_CloseTime`, `fld_DateCreated`, `fld_IsActive`) VALUES
(1, 'BR1', 'Branch 1', 'Makati City', 600, 2200, '2021-08-21 00:00:00', b'1'),
(2, 'BR2', 'Branch 2', 'Pasig City', 600, 2200, '2021-08-21 00:00:00', b'1'),
(3, 'BR3', 'Branch 3', 'Pasay City', 600, 2200, '2021-08-21 00:00:00', b'1');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_PasswordReset`
--

DROP TABLE IF EXISTS `tbl_PasswordReset`;
CREATE TABLE IF NOT EXISTS `tbl_PasswordReset` (
  `fld_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `fld_Uid` bigint(20) NOT NULL,
  `fld_EmailAddress` varchar(100) NOT NULL,
  `fld_ResetKey` varchar(100) NOT NULL,
  `fld_DateRequested` datetime DEFAULT NULL,
  `fld_DateExpiration` datetime DEFAULT NULL,
  `fld_ShouldExpire` bit(1) DEFAULT NULL,
  `fld_IsAlreadyUsed` bit(1) DEFAULT NULL,
  PRIMARY KEY (`fld_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_PasswordReset`
--

TRUNCATE TABLE `tbl_PasswordReset`;
--
-- Dumping data for table `tbl_PasswordReset`
--

INSERT INTO `tbl_PasswordReset` (`fld_ID`, `fld_Uid`, `fld_EmailAddress`, `fld_ResetKey`, `fld_DateRequested`, `fld_DateExpiration`, `fld_ShouldExpire`, `fld_IsAlreadyUsed`) VALUES
(1, 31, 'jrockhackerz@gmail.com', 'ca3ffaec3234ac991286ed0433611cf1', '2021-08-01 00:00:00', '2021-08-01 00:30:00', b'1', b'0'),
(2, 31, 'jrockhackerz@gmail.com', '4f7451d004640be5d2409f5a50be0f5a', '2021-08-01 11:39:39', '2021-08-01 12:09:39', b'1', b'1'),
(3, 31, 'jrockhackerz@gmail.com', '7d66d6216a0bca0b1e76d08f1e88f44a', '2021-08-01 13:10:19', '2021-08-01 13:40:19', b'1', b'1'),
(4, 31, 'jrockhackerz@gmail.com', '8a1e031a161b3cbb748aa863260ffcda', '2021-08-14 09:28:07', '2021-08-14 09:58:07', b'1', b'0'),
(5, 49, 'jordanamurao@gmail.com', '2472b8229658a8217ed6c8f9aaabee56', '2021-08-14 09:50:04', '2021-08-14 10:20:04', b'1', b'0');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_Profile`
--

DROP TABLE IF EXISTS `tbl_Profile`;
CREATE TABLE IF NOT EXISTS `tbl_Profile` (
  `fld_ProfileID` int(11) NOT NULL AUTO_INCREMENT,
  `fld_ProfileName` varchar(20) NOT NULL,
  PRIMARY KEY (`fld_ProfileID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_Profile`
--

TRUNCATE TABLE `tbl_Profile`;
--
-- Dumping data for table `tbl_Profile`
--

INSERT INTO `tbl_Profile` (`fld_ProfileID`, `fld_ProfileName`) VALUES
(1, 'SuperUser'),
(2, 'Staff'),
(3, 'Dentist');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_UserInformation`
--

DROP TABLE IF EXISTS `tbl_UserInformation`;
CREATE TABLE IF NOT EXISTS `tbl_UserInformation` (
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
  `fld_Password` varchar(150) DEFAULT NULL,
  `fld_IsActivated` bit(1) DEFAULT NULL,
  `fld_IsTemporaryPassword` bit(1) DEFAULT NULL,
  `fld_DateRegistered` datetime DEFAULT NULL,
  `fld_DateUpdated` datetime DEFAULT NULL,
  `fld_DateDeleted` datetime DEFAULT NULL,
  `fld_IsDeleted` bit(1) DEFAULT NULL,
  PRIMARY KEY (`fld_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_UserInformation`
--

TRUNCATE TABLE `tbl_UserInformation`;
--
-- Dumping data for table `tbl_UserInformation`
--

INSERT INTO `tbl_UserInformation` (`fld_ID`, `fld_EmployeeNo`, `fld_FirstName`, `fld_MiddleName`, `fld_LastName`, `fld_Suffix`, `fld_ContactNumber`, `fld_EmailAddress`, `fld_ProfileID`, `fld_AffiliateLevelID`, `fld_Username`, `fld_Password`, `fld_IsActivated`, `fld_IsTemporaryPassword`, `fld_DateRegistered`, `fld_DateUpdated`, `fld_DateDeleted`, `fld_IsDeleted`) VALUES
(1, '10101', 'Admin', NULL, 'Admin', NULL, '09123456789', 'webmaster@email.com', 1, 1, 'admin', 'cc83897986bf5b2d48c9622ddb0e62c5', b'1', b'0', '2021-06-10 00:00:00', '2021-07-25 00:00:00', NULL, b'0'),
(31, NULL, 'test name', 'test middle', 'test last', NULL, '09123456789', 'jrockhackerz@gmail.com', 3, 3, 'jhay123', 'c3afcf5fcd49b950cb354b3b94cc72ad', b'0', b'0', '2021-07-18 00:00:00', '2021-08-01 13:39:36', NULL, b'0'),
(38, '111111', 'test', 'test', 'test edit', NULL, NULL, NULL, 2, 0, 'jhay06', NULL, b'0', NULL, '2021-07-18 00:00:00', '2021-07-24 00:00:00', NULL, b'0'),
(39, '111999', 'ziciely', 'dooma', 'tello', NULL, NULL, 'zhai@gmail.com', 2, 0, 'zhai123', 'ac551dd4ce6f105e915c1ef80b660aba', b'0', NULL, '2021-07-25 00:00:00', NULL, NULL, b'0'),
(40, '120292', 'test', 'test', 'test last', NULL, NULL, 'test@gmail.com1', 2, 0, 'user123', 'da594ab6c4c675392b81fd4d0304ffbb', b'0', b'1', '2021-07-25 00:00:00', NULL, NULL, b'0'),
(41, '198989', 'test', 'test', 'Mendoza', NULL, NULL, 'test@gmail.com', 2, 0, 'user457', 'add8a3f3997818cd5f26a8301e736d3f', b'0', b'1', '2021-07-25 00:00:00', NULL, NULL, b'0'),
(42, NULL, 'Test', 'Accre', 'Accre', NULL, '09199728282', 'test@gmail.com', 3, 1, 'TestAccr123', '24a3dad540fb0619523fe06028b851c9', b'0', b'0', '2021-07-25 00:00:00', '2021-07-25 00:00:00', NULL, b'0'),
(43, '191111', 'tanos', 'tolentino', 'mendoza', NULL, NULL, 'test@gmail.com', 2, 0, 'test155', '4b0bb1aada001fb2af45b06b5cb5f006', b'0', b'0', '2021-07-25 00:00:00', '2021-07-25 00:00:00', NULL, b'0'),
(44, '111223', 'test', 'test', 'test', NULL, NULL, 'test@gmail.com', 2, 0, 'zhai893', '8c37b204d1d9ab32bf815368867cd60d', b'0', b'0', '2021-07-25 00:00:00', '2021-07-25 00:00:00', NULL, b'0'),
(45, '192898', 'tst', 'twst', 'test', NULL, NULL, 'test@gmail.com', 2, 0, 'test909', 'ca33668a6ef725d0b3e7ce81c5927bdb', b'0', b'1', '2021-07-25 00:00:00', NULL, NULL, b'0'),
(46, '191191', 'Jhay', 'Tolentino', 'Mendoza', NULL, NULL, 'jrockhackerz@gmail.com4', 2, 0, 'jhayar123', 'fc1a1cdae9fe0b76ce0c28eb47b0e975', b'0', b'1', '2021-07-25 00:00:00', NULL, NULL, b'0'),
(47, '1911911', 'Jhay', 'Tolentino', 'Mendoza', NULL, NULL, 'jrockhackerz@gmail.com2', 2, 0, 'jhayar1233', 'ef1dde85fc858ba3be2c886c490fdeff', b'0', b'1', '2021-07-25 00:00:00', NULL, NULL, b'0'),
(48, '1911912', 'Jhay', 'Tolentino', 'Mendoza', NULL, NULL, 'jrockhackerz@gmail.com23', 2, 0, 'jhayar122', 'd5130b06f2d78462e827e1dd643a63a5', b'0', b'1', '2021-07-25 00:00:00', NULL, NULL, b'0'),
(49, '112323', 'jordan', '', 'amurao', NULL, NULL, 'jordanamurao@gmail.com', 2, 0, 'jordan12', '4043efeec93f7dfe610dcc3404957830', b'0', b'1', '2021-07-25 00:00:00', NULL, NULL, b'0'),
(50, NULL, 'test', 'test', 'test', NULL, '09199288933', 'jrockhackerz@gmail.com1', 3, 1, 'testuser19', 'e8e06630f857a21c1831ddfbe71eb48d', b'0', b'0', '2021-07-25 00:00:00', '2021-07-25 00:00:00', NULL, b'0');
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

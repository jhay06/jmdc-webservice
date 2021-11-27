-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3307
-- Generation Time: Nov 27, 2021 at 11:02 AM
-- Server version: 10.5.11-MariaDB-1:10.5.11+maria~focal
-- PHP Version: 8.0.12

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
CREATE DATABASE IF NOT EXISTS `db_JMDC` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `db_JMDC`;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `usp_AddAccount`$$
CREATE  PROCEDURE `usp_AddAccount` (`employee_no` VARCHAR(20), `first_name` VARCHAR(50), `middle_name` VARCHAR(50), `last_name` VARCHAR(50), `suffix` VARCHAR(10), `contact_number` VARCHAR(15), `email_address` VARCHAR(100), `profile_id` INT, `affiliate_level_id` INT, `username` VARCHAR(30), `your_password` VARCHAR(150), `is_active` BIT)  BEGIN
	
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
                fld_IstemporaryPassword,
                fld_IsActive
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
                true,
                is_active
    
			);
		
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account is existing';
	END IF;
END$$

DROP PROCEDURE IF EXISTS `usp_AddAppointment`$$
CREATE  PROCEDURE `usp_AddAppointment` (`patient_name` VARCHAR(150), `patient_contact_no` VARCHAR(15), `email_address` VARCHAR(60), `branch_code` VARCHAR(5), `branch_name` VARCHAR(60), `appointment_date` DATETIME, `start_timeslot` INT, `end_timeslot` INT, `appointby` VARCHAR(30), `reference_code` VARCHAR(30))  BEGIN
DECLARE exist int default 0;
DECLARE insert_id bigint default 0;
SELECT COUNT(*) INTO exist
FROM tbl_Appointment
WHERE fld_DateOfAppointment = appointment_date
AND (
            
                ( start_timeslot <= fld_StartTimeSlot  AND end_timeslot >= fld_EndTimeSlot)
			   OR (start_timeslot >= fld_StartTimeSlot AND end_timeSlot <= fld_EndTimeSlot)
               )
AND (fld_IsCancelled = 0 OR fld_IsCancelled IS NULL)
ANd fld_IsDeleted=0
AND fld_BranchCode = branch_code
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

DROP PROCEDURE IF EXISTS `usp_AddPromotion`$$
CREATE  PROCEDURE `usp_AddPromotion` (`file_type` VARCHAR(10), `file_content_type` VARCHAR(60), `file_name` VARCHAR(100), `file_size` INT, `file_content` LONGBLOB, `created_by` VARCHAR(30), `image_id` VARCHAR(30), `promotion_description` LONGTEXT, `promotion_status` VARCHAR(10), `promotion_name` VARCHAR(60))  BEGIN
	DECLARE exist int default 0;
    SELECT COUNT(*) INTO exist
    FROM tbl_Promotions
    WHERE (fld_ImageId = image_id OR fld_PromotionName = promotion_name)
    AND fld_IsDeleted =0;
    
    IF exist = 0
		THEN

		CALL usp_InsertFile(
			file_type,
			file_content_type,
			file_name,
			file_size,
			file_content,
			created_by,
			@image_id
		);
		IF @image_id > 0
			THEN
				INSERT INTO tbl_Promotions
				(
					fld_PromotionName,
					fld_ImageId,
					fld_Description,
					fld_Status,
					fld_FileId,
					fld_DateCreated,
					fld_CreatedBy,
					fld_IsDeleted
                
				)
				VALUES
				(
					promotion_name,
					image_id,
                    promotion_description,
                    promotion_status,
					@image_id,
					current_timestamp(),
					created_by,
					0
            
				);
		ELSE
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot upload the image';	
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Promotion already exist';
	END IF;
END$$

DROP PROCEDURE IF EXISTS `usp_AddTutorial`$$
CREATE  PROCEDURE `usp_AddTutorial` (`youtube_id` VARCHAR(50), `youtube_title` VARCHAR(150), `youtube_link` VARCHAR(100), `youtube_description` LONGTEXT, `created_by` VARCHAR(30))  BEGIN
DECLARE exist INT default 0;
SELECT COUNT(*) INTO exist
FROM tbl_Tutorials
WHERE ( fld_YoutubeId= youtube_id
OR fld_YoutubeTitle = youtube_title
OR fld_YoutubeLink = youtube_link )
AND fld_IsDeleted =0;
if exist = 0
	THEN 
		INSERT INTO tbl_Tutorials
        (
			fld_YoutubeId,
            fld_YoutubeTitle,
            fld_YoutubeLink,
            fld_YoutubeDescription,
            fld_CreatedBy,
            fld_DateCreated,
            fld_IsDeleted
        )
        VALUES
        (
			youtube_id,
            youtube_title,
            youtube_link,
            youtube_description,
            created_by,
            current_timestamp(),
            0
        );
else
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='This tutorial was already exist';
END IF;
        
END$$

DROP PROCEDURE IF EXISTS `usp_CancelAppointment`$$
CREATE  PROCEDURE `usp_CancelAppointment` (`reference_code` VARCHAR(30), `cancelled_by` VARCHAR(30))  BEGIN
	DECLARE appointment_id BIGINT default 0;
    DECLARE message varchar(150) default null;
	SELECT fld_AppointmentId INTO appointment_id
    FROM tbl_AppointmentReference
    WHERE fld_ReferenceCode=reference_code
    AND fld_IsDeleted=0;
    
    if appointment_id > 0
		then
        	UPDATE tbl_Appointment
			SET fld_IsCancelled=1,
			fld_DateCancelled=current_timestamp(),
			fld_CancelledBy= cancelled_by
			WHERE fld_AppointmentId = appointment_id;
	else
		SET message=CONCAT('Reference code: ',reference_code,' is not exist');
        
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = message;
	end if;
END$$

DROP PROCEDURE IF EXISTS `usp_ChangePassword`$$
CREATE  PROCEDURE `usp_ChangePassword` (`new_password` VARCHAR(150), `current_password` VARCHAR(150), `username` VARCHAR(30))  BEGIN
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

DROP PROCEDURE IF EXISTS `usp_DeleteFile`$$
CREATE  PROCEDURE `usp_DeleteFile` (`file_id` BIGINT, `deleted_by` VARCHAR(30))  BEGIN
	UPDATE tbl_FileStore
    SET fld_IsDeleted =1,
		fld_DateDeleted= current_timestamp(),
        fld_DeletedBy =deleted_by
	WHERE fld_FileId= file_id;
END$$

DROP PROCEDURE IF EXISTS `usp_DeletePromotion`$$
CREATE  PROCEDURE `usp_DeletePromotion` (IN `promotion_id` BIGINT, `deleted_by` VARCHAR(30))  BEGIN
	DECLARE image_id BIGINT default 0;
    SELECT fld_FileId INTO image_id
    FROM tbl_Promotions
    WHERE fld_PromotionId = promotion_id
    AND fld_IsDeleted =0;
    
    IF image_id > 0
		THEN
        CALL usp_DeleteFile(
			image_id,
            deleted_by
        );
	END IF;
    UPDATE tbl_Promotions
    SET fld_IsDeleted=1
		, fld_DateDeleted = current_timestamp()
        , fld_DeletedBy = deleted_by
	WHERE fld_PromotionId = promotion_id;
    
END$$

DROP PROCEDURE IF EXISTS `usp_DeleteTutorial`$$
CREATE  PROCEDURE `usp_DeleteTutorial` (`video_id` BIGINT, `deleted_by` VARCHAR(30))  BEGIN
UPDATE tbl_Tutorials
SET fld_DeletedBy = deleted_by
	, fld_DateDeleted =current_timestamp()
    , fld_IsDeleted =1
WHERE fld_TutorialId = video_id;

END$$

DROP PROCEDURE IF EXISTS `usp_DeletProduct`$$
CREATE  PROCEDURE `usp_DeletProduct` (IN `service_id` BIGINT, `deleted_by` VARCHAR(30))  BEGIN
	DECLARE image_id BIGINT default 0;
    SELECT fld_ProductImageId INTO image_id
    FROM tbl_Service
    WHERE fld_ServiceId = service_id
    AND fld_IsDeleted =0;
    
    IF image_id > 0
		THEN
        CALL usp_DeleteFile(
			image_id,
            deleted_by
        );
	END IF;
    UPDATE tbl_Service
    SET fld_IsDeleted=1
		, fld_DateDeleted = current_timestamp()
        , fld_DeletedBy = deleted_by
	WHERE fld_ServiceId = service_id;
    
END$$

DROP PROCEDURE IF EXISTS `usp_ForgotPasswordChange`$$
CREATE  PROCEDURE `usp_ForgotPasswordChange` (IN `email_address` VARCHAR(100), `reset_key` VARCHAR(100), `new_password` VARCHAR(150))  BEGIN
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
CREATE  PROCEDURE `usp_GetActiveResetKey` (`email_address` VARCHAR(100))  BEGIN
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
CREATE  PROCEDURE `usp_GetAllReferenceCode` ()  BEGIN
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
CREATE  PROCEDURE `usp_GetAppointmentByDate` (`lookup_date` DATETIME, `appoint_by` VARCHAR(30), `branch_code` VARCHAR(5))  BEGIN
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
CREATE  PROCEDURE `usp_GetAppointmentByRange` (`from_range` DATETIME, `to_range` DATETIME, `branch_code` VARCHAR(5), `appoint_by` VARCHAR(30))  BEGIN
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
    #AND A.fld_AppointBy= appoint_by
    AND A.fld_BranchCode= branch_code
    AND A.fld_IsDeleted=false;
END$$

DROP PROCEDURE IF EXISTS `usp_GetAppointmentInfo`$$
CREATE  PROCEDURE `usp_GetAppointmentInfo` (`appointment_id` BIGINT)  BEGIN
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
CREATE  PROCEDURE `usp_GetAppointmentList` ()  BEGIN
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
CREATE  PROCEDURE `usp_GetAppointmentListBy` (`username` VARCHAR(30), `branch_code` VARCHAR(30))  BEGIN
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
CREATE  PROCEDURE `usp_GetBranchList` ()  BEGIN
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

DROP PROCEDURE IF EXISTS `usp_GetClassification`$$
CREATE  PROCEDURE `usp_GetClassification` ()  BEGIN
	SELECT fld_ClassId 'class_id',
			fld_ClassCode 'class_code',
            fld_ClassName 'class_name'
    FROM tbl_ProductClass
    WHERE fld_IsActive=true;
    
END$$

DROP PROCEDURE IF EXISTS `usp_GetFileData`$$
CREATE  PROCEDURE `usp_GetFileData` (`file_id` BIGINT)  BEGIN
	SELECT fld_FileId 'file_id',
			fld_FileType 'file_type',
            fld_FileContentType 'file_content_type',
            fld_FileName 'file_name',
            fld_FileSize 'file_size'
    FROM tbl_FileStore
    WHERE fld_FileId= file_id
    AND fld_IsDeleted=0;
    
END$$

DROP PROCEDURE IF EXISTS `usp_GetInformationByUsername`$$
CREATE  PROCEDURE `usp_GetInformationByUsername` (`username` VARCHAR(30))  BEGIN
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
               fld_IsTemporaryPassword as is_temporary_password,
               fld_IsActive as is_active
			FROM tbl_UserInformation
			WHERE fld_Username=username
			AND fld_IsDeleted = false;
	else
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username does not exist';
	end if;
    
END$$

DROP PROCEDURE IF EXISTS `usp_GetLoginInformation`$$
CREATE  PROCEDURE `usp_GetLoginInformation` (`username` VARCHAR(30), `password` VARCHAR(150))  BEGIN
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
            fld_Username AS 'username',
            fld_IsActive AS is_active
    FROM tbl_UserInformation
    WHERE fld_Username=username AND fld_Password = password
    AND fld_IsDeleted=false
    ;
END$$

DROP PROCEDURE IF EXISTS `usp_GetProductById`$$
CREATE  PROCEDURE `usp_GetProductById` (`product_id` BIGINT)  BEGIN
	SELECT service.fld_ServiceId 'service_id',
			service.fld_ProductCode 'product_code',
            service.fld_ProductName 'product_name',
            service.fld_ClassId 'class_id',
            classification.fld_ClassCode 'class_code',
            classification.fld_ClassName 'class_name',
            service.fld_ProductDescription 'product_description',
            service.fld_ProductImageId 'image_id',
            filestore.fld_FileType 'file_type',
            filestore.fld_FileName 'file_name',
            filestore.fld_FileSize 'file_size',
            filestore.fld_FileContentType 'file_content_type',
            filestore.fld_FileContent 'file_content'
    FROM tbl_Service as service
    LEFT JOIN tbl_ProductClass as classification
    ON classification.fld_ClassId=service.fld_ClassId
    LEFT JOIN tbl_FileStore as filestore
    ON filestore.fld_FileId= service.fld_ProductImageId
    WHERE service.fld_IsDeleted=0
    AND service.fld_ServiceId= product_id
    AND classification.fld_IsActive=1
    AND filestore.fld_IsDeleted=0;
END$$

DROP PROCEDURE IF EXISTS `usp_GetProductByProductCode`$$
CREATE  PROCEDURE `usp_GetProductByProductCode` (`product_code` VARCHAR(30))  BEGIN
SELECT service.fld_ServiceId 'service_id',
			service.fld_ProductCode 'product_code',
            service.fld_ProductName 'product_name',
            service.fld_ClassId 'class_id',
            classification.fld_ClassCode 'class_code',
            classification.fld_ClassName 'class_name',
            service.fld_ProductDescription 'product_description',
            service.fld_ProductImageId 'image_id',
            filestore.fld_FileType 'file_type',
            filestore.fld_FileName 'file_name',
            filestore.fld_FileSize 'file_size',
            filestore.fld_FileContentType 'file_content_type',
            filestore.fld_FileContent 'file_content'
    FROM tbl_Service as service
    LEFT JOIN tbl_ProductClass as classification
    ON classification.fld_ClassId=service.fld_ClassId
    LEFT JOIN tbl_FileStore as filestore
    ON filestore.fld_FileId= service.fld_ProductImageId
    WHERE service.fld_IsDeleted=0
    AND service.fld_ProductCode=product_code
    AND classification.fld_IsActive=1
    AND filestore.fld_IsDeleted=0;
END$$

DROP PROCEDURE IF EXISTS `usp_GetProductList`$$
CREATE  PROCEDURE `usp_GetProductList` ()  BEGIN
	SELECT service.fld_ServiceId 'service_id',
			service.fld_ProductCode 'product_code',
            service.fld_ProductName 'product_name',
            service.fld_ClassId 'class_id',
            classification.fld_ClassCode 'class_code',
            classification.fld_ClassName 'class_name',
            service.fld_ProductDescription 'product_description',
            service.fld_ProductImageId 'image_id',
            filestore.fld_FileType 'file_type',
            filestore.fld_FileName 'file_name',
            filestore.fld_FileSize 'file_size',
            filestore.fld_FileContentType 'file_content_type',
            filestore.fld_FileContent 'file_content'
    FROM tbl_Service as service
    LEFT JOIN tbl_ProductClass as classification
    ON classification.fld_ClassId=service.fld_ClassId
    LEFT JOIN tbl_FileStore as filestore
    ON filestore.fld_FileId= service.fld_ProductImageId
    WHERE service.fld_IsDeleted=0
    AND classification.fld_IsActive=1
    AND filestore.fld_IsDeleted=0;
    
    
    

END$$

DROP PROCEDURE IF EXISTS `usp_GetPromotionById`$$
CREATE  PROCEDURE `usp_GetPromotionById` (`promotion_id` BIGINT)  BEGIN
	SELECT  promo.fld_PromotionId 'promotion_id',
			promo.fld_ImageId 'image_id',
            promo.fld_Description 'description',
            promo.fld_Status 'status',
            promo.fld_FileId 'file_id',
            promo.fld_PromotionName 'promotion_name',
            filestore.fld_FileType 'file_type',
            filestore.fld_FileName 'file_name',
            filestore.fld_FileSize 'file_size',
            filestore.fld_FileContentType 'file_content_type',
            filestore.fld_FileContent 'file_content'
    FROM tbl_Promotions as promo
    LEFT JOIN tbl_FileStore as filestore
    ON filestore.fld_FileId= promo.fld_FileId
    WHERE promo.fld_IsDeleted=0
    AND promo.fld_PromotionId= promotion_id
    AND filestore.fld_IsDeleted=0;
END$$

DROP PROCEDURE IF EXISTS `usp_GetPromotionByImageId`$$
CREATE  PROCEDURE `usp_GetPromotionByImageId` (`image_id` VARCHAR(60))  BEGIN
SELECT  promo.fld_PromotionId 'promotion_id',
			promo.fld_ImageId 'image_id',
            promo.fld_Description 'description',
            promo.fld_Status 'status',
            promo.fld_FileId 'file_id',
            promo.fld_PromotionName 'promotion_name',
            filestore.fld_FileType 'file_type',
            filestore.fld_FileName 'file_name',
            filestore.fld_FileSize 'file_size',
            filestore.fld_FileContentType 'file_content_type',
            filestore.fld_FileContent 'file_content'
    FROM tbl_Promotions as promo
    LEFT JOIN tbl_FileStore as filestore
    ON filestore.fld_FileId= promo.fld_FileId
    WHERE promo.fld_IsDeleted= 0 
    AND promo.fld_ImageId = image_id;
END$$

DROP PROCEDURE IF EXISTS `usp_GetPromotionList`$$
CREATE  PROCEDURE `usp_GetPromotionList` ()  BEGIN
	SELECT  promo.fld_PromotionId 'promotion_id',
			promo.fld_ImageId 'image_id',
            promo.fld_Description 'description',
            promo.fld_PromotionName 'promotion_name',
            promo.fld_Status 'status',
            promo.fld_FileId 'file_id',
            filestore.fld_FileType 'file_type',
            filestore.fld_FileName 'file_name',
            filestore.fld_FileSize 'file_size',
            filestore.fld_FileContentType 'file_content_type',
            filestore.fld_FileContent 'file_content'
    FROM tbl_Promotions as promo
    LEFT JOIN tbl_FileStore as filestore
    ON filestore.fld_FileId= promo.fld_FileId
    WHERE promo.fld_IsDeleted=0
    AND filestore.fld_IsDeleted=0;
    
    
    

END$$

DROP PROCEDURE IF EXISTS `usp_GetReferenceCode`$$
CREATE  PROCEDURE `usp_GetReferenceCode` (IN `appointment_id` BIGINT)  BEGIN
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

DROP PROCEDURE IF EXISTS `usp_GetTutorialById`$$
CREATE  PROCEDURE `usp_GetTutorialById` (`tutorial_id` BIGINT)  BEGIN
	SELECT fld_TutorialId 'tutorial_id',
		fld_YoutubeId 'youtube_id',
        fld_YoutubeTitle 'youtube_title',
		fld_YoutubeDescription 'youtube_description'
    FROM tbl_Tutorials
    WHERE fld_IsDeleted=0
    AND fld_TutorialId = tutorial_id;
END$$

DROP PROCEDURE IF EXISTS `usp_GetTutorialByYoutubeId`$$
CREATE  PROCEDURE `usp_GetTutorialByYoutubeId` (`youtube_id` VARCHAR(100))  BEGIN
	SELECT fld_TutorialId 'video_id',
		    fld_YoutubeId 'youtube_id',
            fld_YoutubeTitle 'video_title',
            fld_YoutubeLink 'youtube_link',
            fld_YoutubeDescription 'video_description'
    FROM tbl_Tutorials
    WHERE fld_YoutubeId=youtube_id
    ANd fld_IsDeleted =0;

END$$

DROP PROCEDURE IF EXISTS `usp_GetTutorialList`$$
CREATE  PROCEDURE `usp_GetTutorialList` ()  BEGIN
	SELECT fld_TutorialId 'video_id',
		fld_YoutubeId 'youtube_id',
        fld_YoutubeTitle 'video_title',
        fld_YoutubeLink 'youtube_link',
        fld_YoutubeDescription 'video_description'
    FROM tbl_Tutorials
    WHERE fld_IsDeleted= 0;
END$$

DROP PROCEDURE IF EXISTS `usp_GetUserInformation`$$
CREATE  PROCEDURE `usp_GetUserInformation` (`profile_id` INT, `affiliate_level` INT)  BEGIN
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
               fld_ProfileID as 'profile_id',
               fld_IsActive as is_active
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
CREATE  PROCEDURE `usp_InsertAppointmentReference` (`reference_code` VARCHAR(30), `appointment_id` BIGINT)  BEGIN
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

DROP PROCEDURE IF EXISTS `usp_InsertFile`$$
CREATE  PROCEDURE `usp_InsertFile` (`file_type` VARCHAR(10), `file_content_type` VARCHAR(60), `file_name` VARCHAR(100), `file_size` INT, `file_content` LONGBLOB, `created_by` VARCHAR(30), OUT `image_id` BIGINT)  BEGIN
INSERT INTO tbl_FileStore
    (
		fld_FileType,
        fld_FileContentType,
        fld_FileName,
        fld_FileSize,
        fld_FileContent,
        fld_DateCreated,
        fld_CreatedBy,
        fld_IsDeleted
    )
    VALUES
    (	
		file_type,
        file_content_type,
        file_name,
        file_size,
        UNHEX(file_content),
        current_timestamp(),
        created_by,
        0
	);
    SELECT LAST_INSERT_ID() INTO image_id;
END$$

DROP PROCEDURE IF EXISTS `usp_InsertService`$$
CREATE  PROCEDURE `usp_InsertService` (`file_type` VARCHAR(10), `file_content_type` VARCHAR(60), `file_name` VARCHAR(100), `file_size` INT, `file_content` LONGBLOB, `created_by` VARCHAR(30), `product_code` VARCHAR(30), `product_name` VARCHAR(150), `class_id` INT, `product_description` VARCHAR(8000))  BEGIN
	DECLARE exist int default 0;
    SELECT COUNT(*) INTO exist
    FROM tbl_Service
    WHERE (fld_ProductCode = product_code
    OR fld_ProductName = product_name)
    AND fld_IsDeleted =0;
    
    IF exist = 0
		THEN

		CALL usp_InsertFile(
			file_type,
			file_content_type,
			file_name,
			file_size,
			file_content,
			created_by,
			@image_id
		);
		IF @image_id > 0
			THEN
				INSERT INTO tbl_Service
				(
					fld_ProductCode,
					fld_ProductName,
					fld_ClassId,
					fld_ProductDescription,
					fld_ProductImageId,
					fld_DateCreated,
					fld_CreatedBy,
					fld_IsDeleted
                
				)
				VALUES
				(
					product_code,
					product_name,
					class_id,
					product_description,
					@image_id,
					current_timestamp(),
					created_by,
					0
            
				);
		ELSE
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot upload the image';	
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Product already exist';
	END IF;
END$$

DROP PROCEDURE IF EXISTS `usp_IsValidResetKey`$$
CREATE  PROCEDURE `usp_IsValidResetKey` (`email_address` VARCHAR(100), `reset_key` VARCHAR(100))  BEGIN

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
CREATE  PROCEDURE `usp_ReferenceCodeIsUsed` (`reference_code` VARCHAR(30))  BEGIN
	
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
CREATE  PROCEDURE `usp_SavePasswordReset` (`email_address` VARCHAR(100), `reset_key` VARCHAR(100), `should_expire` BIT)  BEGIN
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

DROP PROCEDURE IF EXISTS `usp_submitFeedback`$$
CREATE  PROCEDURE `usp_submitFeedback` (`full_name` VARCHAR(150), `contact_no` VARCHAR(15), `email_address` VARCHAR(200), `message` LONGTEXT)  BEGIN
	INSERT INTO tbl_Feedback
    (	
		fld_FullName,
        fld_ContactNumber,
        fld_EmailAddress,
        fld_Message,
        fld_DateSubmitted,
        fld_IsDeleted
    
    )
    VALUES
    (
		full_name,
        contact_no,
        email_address,
        message,
        current_timestamp(),
        0
    );
END$$

DROP PROCEDURE IF EXISTS `usp_UpdateAccount`$$
CREATE  PROCEDURE `usp_UpdateAccount` (`employee_no` VARCHAR(20), `first_name` VARCHAR(50), `middle_name` VARCHAR(50), `last_name` VARCHAR(50), `suffix` VARCHAR(10), `contact_no` VARCHAR(15), `email_address` VARCHAR(100), `profile_id` INT, `affiliate_level_id` INT, `username` VARCHAR(30), `is_activated` BIT, `new_employee_no` VARCHAR(20), `new_username` VARCHAR(20), `is_active` BIT)  BEGIN
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
                fld_DateUpdated= current_timestamp(),
                fld_IsActive = is_active
			WHERE fld_Username=username;
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username/employee number was already taken, Please chooose anohter username or employee number';	
    end if;
END$$

DROP PROCEDURE IF EXISTS `usp_UpdateAppointment`$$
CREATE  PROCEDURE `usp_UpdateAppointment` (`reference_code` VARCHAR(30), `patient_name` VARCHAR(150), `patient_contact_no` VARCHAR(15), `email_address` VARCHAR(60), `branch_code` VARCHAR(5), `branch_name` VARCHAR(60), `appointment_date` DATETIME, `start_timeslot` INT, `end_timeslot` INT, `modified_by` VARCHAR(30))  BEGIN
DECLARE appointment_id BIGINT DEFAULT 0;
DECLARE appointment_exist INT DEFAULT 0;
DECLARE message VARCHAR(150) DEFAULT NULL;
SELECT fld_AppointmentId INTO appointment_id
FROM tbl_AppointmentReference 
WHERE fld_ReferenceCode=reference_code
AND fld_IsDeleted=0;

IF appointment_id > 0
	THEN
		SELECT COUNT(*) INTO appointment_exist
        FROM tbl_Appointment
        WHERE  fld_AppointmentId !=appointment_id
        AND fld_DateOfAppointment = appointment_date
        AND (
            
                ( start_timeslot <= fld_StartTimeSlot  AND end_timeslot >= fld_EndTimeSlot)
			   OR (start_timeslot >= fld_StartTimeSlot AND end_timeSlot <= fld_EndTimeSlot)
               )
			   
		AND fld_BranchCode = branch_code
		AND (fld_IsCancelled= 0 OR fld_IsCancelled IS NULL) AND fld_IsDeleted =0;
    
        IF appointment_exist = 0
			THEN
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
				AND ((fld_IsCancelled= 0 OR fld_IsCancelled IS NULL) OR fld_IsDeleted=0);
		ELSE
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The slot you had requested was not available';
		END IF;
	ELSE
		SET message= CONCAT('The reference code ''',reference_code,''' does not exist');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = message;
	END IF;
END$$

DROP PROCEDURE IF EXISTS `usp_UpdateProduct`$$
CREATE  PROCEDURE `usp_UpdateProduct` (`service_id` BIGINT, `upload_new_file` BIT, `file_type` VARCHAR(10), `file_content_type` VARCHAR(60), `file_name` VARCHAR(100), `file_size` INT, `file_content` LONGBLOB, `modified_by` VARCHAR(30), `product_code` VARCHAR(30), `product_name` VARCHAR(150), `class_id` INT, `product_description` VARCHAR(8000))  BEGIN
	DECLARE exist INT default 0;
    DECLARE image_id BIGINT default 0;
    SELECT COUNT(*) INTO exist
    FROM tbl_Service 
    WHERE (fld_ProductCode = product_code
    OR fld_ProductName = product_name)
    AND fld_IsDeleted = 0
    AND fld_ServiceId !=service_id;
    if exist = 0
		THEN
			If upload_new_file = 1
				THEN
					CALL usp_InsertFile(
						file_type,
						file_content_type,
						file_name,
						file_size,
						file_content,
						modified_by,
						@image_id
					);
					SET image_id= @image_id;
			ELSE
				SELECT fld_ProductImageId INTO image_id
                FROM tbl_Service
                WHERE fld_ServiceId = service_id;
			END IF;
			IF image_id > 0
				THEN
					UPDATE tbl_Service
                    SET fld_ProductCode = product_code
						, fld_ProductName = product_name
                        , fld_ClassId = class_id
                        , fld_ProductImageId = image_id
                        , fld_ModifiedBy = modified_by
                        , fld_DateModified = current_timestamp()
                        , fld_IsDeleted =0
					WHERE fld_ServiceId = service_id;
			ELSE
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot upload image file';
			END IF;
            
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product already exist';
		
    END IF;
    
END$$

DROP PROCEDURE IF EXISTS `usp_UpdatePromotion`$$
CREATE  PROCEDURE `usp_UpdatePromotion` (`promotion_id` BIGINT, `upload_new_file` BIT, `file_type` VARCHAR(10), `file_content_type` VARCHAR(60), `file_name` VARCHAR(100), `file_size` INT, `file_content` LONGBLOB, `modified_by` VARCHAR(30), `image_id` VARCHAR(30), `promotion_description` LONGTEXT, `promotion_status` VARCHAR(10), `promotion_name` VARCHAR(60))  BEGIN
	DECLARE exist INT default 0;
    DECLARE file_id BIGINT default 0;
    SELECT COUNT(*) INTO exist
    FROM tbl_Promotions
    WHERE (fld_ImageId = image_id OR fld_PromotionName = promotion_name)
    AND fld_IsDeleted = 0
    AND fld_PromotionId !=promotion_id;
    if exist = 0
		THEN
			If upload_new_file = 1
				THEN
					CALL usp_InsertFile(
						file_type,
						file_content_type,
						file_name,
						file_size,
						file_content,
						modified_by,
						@image_id
					);
					SET file_id= @image_id;
			ELSE
				SELECT fld_FileId INTO file_id
                FROM tbl_Promotions
                WHERE fld_PromotionId = promotion_id;
			END IF;
			IF file_id > 0
				THEN
					UPDATE tbl_Promotions
                    SET fld_ImageId = image_id
						, fld_Description = promotion_description
                        , fld_Status = promotion_status
                        , fld_FileId = file_id
                        , fld_PromotionName = promotion_name
                        , fld_ModifiedBy = modified_by
                        , fld_DateModified = current_timestamp()
                        , fld_IsDeleted =0
					WHERE fld_PromotionId = promotion_id;
			ELSE
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot upload image file';
			END IF;
            
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Promotion already exist';
		
    END IF;
    
END$$

DROP PROCEDURE IF EXISTS `usp_UpdateTutorial`$$
CREATE  PROCEDURE `usp_UpdateTutorial` (`video_id` BIGINT, `youtube_id` VARCHAR(50), `video_title` VARCHAR(150), `youtube_link` VARCHAR(100), `video_description` LONGTEXT, `modified_by` VARCHAR(30))  BEGIN
DECLARE exist int default 0;
SELECT COUNT(*) INTO exist
FROM tbl_Tutorials
WHERE fld_TutorialId !=video_id
AND ( fld_YoutubeId = youtube_id OR fld_YoutubeTitle = video_title OR fld_YoutubeLink = youtube_link  )
AND fld_IsDeleted= 0;

IF exist = 0
	THEN
		UPDATE tbl_Tutorials
        SET fld_YoutubeId = youtube_id
			, fld_YoutubeTitle = video_title
            , fld_YoutubeLink = youtube_link
            , fld_YoutubeDescription = video_description
            , fld_ModifiedBy= modified_by
            , fld_DateModified =current_timestamp()
            , fld_IsDeleted =0
		WHERE fld_TutorialId= video_id;
ELSE
	BEGIN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='This tutorial was already exist';
    
    END;
END IF;
END$$

--
-- Functions
--
DROP FUNCTION IF EXISTS `ufn_NotExpiredKey`$$
CREATE  FUNCTION `ufn_NotExpiredKey` (`uid` BIGINT) RETURNS VARCHAR(100) CHARSET utf8mb4 BEGIN
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
CREATE TABLE `tbl_AffiliateLevel` (
  `fld_AffiliateLevelID` int(11) NOT NULL,
  `fld_AffiliateLevelName` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
CREATE TABLE `tbl_Appointment` (
  `fld_AppointmentId` bigint(20) NOT NULL,
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
  `fld_IsCancelled` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_Appointment`
--

TRUNCATE TABLE `tbl_Appointment`;
-- --------------------------------------------------------

--
-- Table structure for table `tbl_AppointmentReference`
--

DROP TABLE IF EXISTS `tbl_AppointmentReference`;
CREATE TABLE `tbl_AppointmentReference` (
  `fld_ReferenceId` bigint(20) NOT NULL,
  `fld_ReferenceCode` varchar(30) DEFAULT NULL,
  `fld_AppointmentId` bigint(20) DEFAULT NULL,
  `fld_DateCreated` datetime DEFAULT NULL,
  `fld_DateUsed` datetime DEFAULT NULL,
  `fld_IsUsed` bit(1) DEFAULT NULL,
  `fld_IsDeleted` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_AppointmentReference`
--

TRUNCATE TABLE `tbl_AppointmentReference`;
--
-- Dumping data for table `tbl_AppointmentReference`
--

INSERT INTO `tbl_AppointmentReference` (`fld_ReferenceId`, `fld_ReferenceCode`, `fld_AppointmentId`, `fld_DateCreated`, `fld_DateUsed`, `fld_IsUsed`, `fld_IsDeleted`) VALUES
(1, 'AP2021-09-0001', 1, '2021-09-12 08:11:15', NULL, b'0', b'0'),
(2, 'AP2021-09-0002', 2, '2021-09-12 14:02:46', NULL, b'0', b'0'),
(3, 'AP2021-09-0003', 3, '2021-09-12 14:35:52', NULL, b'0', b'0'),
(4, 'AP2021-09-0004', 4, '2021-09-12 14:40:10', NULL, b'0', b'0'),
(5, 'AP2021-10-0001', 5, '2021-10-23 13:19:10', NULL, b'0', b'0');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_Branch`
--

DROP TABLE IF EXISTS `tbl_Branch`;
CREATE TABLE `tbl_Branch` (
  `fld_BranchId` bigint(20) NOT NULL,
  `fld_BranchCode` varchar(5) DEFAULT NULL,
  `fld_BranchName` varchar(60) DEFAULT NULL,
  `fld_BranchAddress` varchar(250) DEFAULT NULL,
  `fld_OpenTime` int(11) DEFAULT NULL,
  `fld_CloseTime` int(11) DEFAULT NULL,
  `fld_DateCreated` datetime DEFAULT NULL,
  `fld_IsActive` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
-- Table structure for table `tbl_Feedback`
--

DROP TABLE IF EXISTS `tbl_Feedback`;
CREATE TABLE `tbl_Feedback` (
  `fld_FeedbackId` bigint(20) NOT NULL,
  `fld_FullName` varchar(200) DEFAULT NULL,
  `fld_ContactNumber` varchar(15) DEFAULT NULL,
  `fld_EmailAddress` varchar(250) DEFAULT NULL,
  `fld_Message` longtext DEFAULT NULL,
  `fld_DateSubmitted` datetime DEFAULT NULL,
  `fld_DateDeleted` datetime DEFAULT NULL,
  `fld_DeletedBy` varchar(30) DEFAULT NULL,
  `fld_IsDeleted` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_Feedback`
--

TRUNCATE TABLE `tbl_Feedback`;
-- --------------------------------------------------------

--
-- Table structure for table `tbl_FileStore`
--

DROP TABLE IF EXISTS `tbl_FileStore`;
CREATE TABLE `tbl_FileStore` (
  `fld_FileId` bigint(20) NOT NULL,
  `fld_FileType` varchar(10) DEFAULT NULL,
  `fld_FileContentType` varchar(60) DEFAULT NULL,
  `fld_FileName` varchar(100) DEFAULT NULL,
  `fld_FileSize` int(11) DEFAULT NULL,
  `fld_FileContent` longblob DEFAULT NULL,
  `fld_DateCreated` datetime DEFAULT NULL,
  `fld_CreatedBy` varchar(30) DEFAULT NULL,
  `fld_DateModified` datetime DEFAULT NULL,
  `fld_ModifiedBy` varchar(30) DEFAULT NULL,
  `fld_DateDeleted` datetime DEFAULT NULL,
  `fld_DeletedBy` varchar(30) DEFAULT NULL,
  `fld_IsDeleted` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_FileStore`
--

TRUNCATE TABLE `tbl_FileStore`;
-- --------------------------------------------------------

--
-- Table structure for table `tbl_PasswordReset`
--

DROP TABLE IF EXISTS `tbl_PasswordReset`;
CREATE TABLE `tbl_PasswordReset` (
  `fld_ID` bigint(20) NOT NULL,
  `fld_Uid` bigint(20) NOT NULL,
  `fld_EmailAddress` varchar(100) NOT NULL,
  `fld_ResetKey` varchar(100) NOT NULL,
  `fld_DateRequested` datetime DEFAULT NULL,
  `fld_DateExpiration` datetime DEFAULT NULL,
  `fld_ShouldExpire` bit(1) DEFAULT NULL,
  `fld_IsAlreadyUsed` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_PasswordReset`
--

TRUNCATE TABLE `tbl_PasswordReset`;
-- --------------------------------------------------------

--
-- Table structure for table `tbl_ProductClass`
--

DROP TABLE IF EXISTS `tbl_ProductClass`;
CREATE TABLE `tbl_ProductClass` (
  `fld_ClassId` int(11) NOT NULL,
  `fld_ClassCode` varchar(30) DEFAULT NULL,
  `fld_ClassName` varchar(150) DEFAULT NULL,
  `fld_IsActive` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_ProductClass`
--

TRUNCATE TABLE `tbl_ProductClass`;
--
-- Dumping data for table `tbl_ProductClass`
--

INSERT INTO `tbl_ProductClass` (`fld_ClassId`, `fld_ClassCode`, `fld_ClassName`, `fld_IsActive`) VALUES
(1, 'CL1', 'Class 1', b'1'),
(2, 'CL2', 'Class 2', b'1'),
(3, 'CL3', 'Class 3', b'1');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_Profile`
--

DROP TABLE IF EXISTS `tbl_Profile`;
CREATE TABLE `tbl_Profile` (
  `fld_ProfileID` int(11) NOT NULL,
  `fld_ProfileName` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
-- Table structure for table `tbl_Promotions`
--

DROP TABLE IF EXISTS `tbl_Promotions`;
CREATE TABLE `tbl_Promotions` (
  `fld_PromotionId` bigint(20) NOT NULL,
  `fld_ImageId` varchar(30) DEFAULT NULL,
  `fld_PromotionName` varchar(60) DEFAULT NULL,
  `fld_Description` longtext DEFAULT NULL,
  `fld_Status` varchar(10) DEFAULT NULL,
  `fld_FileId` bigint(20) DEFAULT NULL,
  `fld_CreatedBy` varchar(30) DEFAULT NULL,
  `fld_DateCreated` datetime DEFAULT NULL,
  `fld_ModifiedBy` varchar(30) DEFAULT NULL,
  `fld_DateModified` datetime DEFAULT NULL,
  `fld_DeletedBy` varchar(30) DEFAULT NULL,
  `fld_DateDeleted` datetime DEFAULT NULL,
  `fld_IsDeleted` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_Promotions`
--

TRUNCATE TABLE `tbl_Promotions`;
-- --------------------------------------------------------

--
-- Table structure for table `tbl_Service`
--

DROP TABLE IF EXISTS `tbl_Service`;
CREATE TABLE `tbl_Service` (
  `fld_ServiceId` bigint(20) NOT NULL,
  `fld_ProductCode` varchar(30) DEFAULT NULL,
  `fld_ProductName` varchar(150) DEFAULT NULL,
  `fld_ClassId` int(11) DEFAULT NULL,
  `fld_ProductDescription` varchar(8000) DEFAULT NULL,
  `fld_ProductImageId` bigint(20) DEFAULT NULL,
  `fld_DateCreated` datetime DEFAULT NULL,
  `fld_CreatedBy` varchar(30) DEFAULT NULL,
  `fld_DateModified` datetime DEFAULT NULL,
  `fld_ModifiedBy` varchar(30) DEFAULT NULL,
  `fld_DateDeleted` datetime DEFAULT NULL,
  `fld_DeletedBy` varchar(30) DEFAULT NULL,
  `fld_IsDeleted` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_Service`
--

TRUNCATE TABLE `tbl_Service`;
-- --------------------------------------------------------

--
-- Table structure for table `tbl_Tutorials`
--

DROP TABLE IF EXISTS `tbl_Tutorials`;
CREATE TABLE `tbl_Tutorials` (
  `fld_TutorialId` bigint(20) NOT NULL,
  `fld_YoutubeId` varchar(50) DEFAULT NULL,
  `fld_YoutubeTitle` varchar(150) DEFAULT NULL,
  `fld_YoutubeLink` varchar(100) DEFAULT NULL,
  `fld_YoutubeDescription` longtext DEFAULT NULL,
  `fld_CreatedBy` varchar(30) DEFAULT NULL,
  `fld_DateCreated` datetime DEFAULT NULL,
  `fld_ModifiedBy` varchar(30) DEFAULT NULL,
  `fld_DateModified` datetime DEFAULT NULL,
  `fld_DeletedBy` varchar(30) DEFAULT NULL,
  `fld_DateDeleted` datetime DEFAULT NULL,
  `fld_IsDeleted` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_Tutorials`
--

TRUNCATE TABLE `tbl_Tutorials`;
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
  `fld_IsActive` bit(1) DEFAULT NULL,
  `fld_DateRegistered` datetime DEFAULT NULL,
  `fld_DateUpdated` datetime DEFAULT NULL,
  `fld_DateDeleted` datetime DEFAULT NULL,
  `fld_IsDeleted` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Truncate table before insert `tbl_UserInformation`
--

TRUNCATE TABLE `tbl_UserInformation`;
--
-- Dumping data for table `tbl_UserInformation`
--

INSERT INTO `tbl_UserInformation` (`fld_ID`, `fld_EmployeeNo`, `fld_FirstName`, `fld_MiddleName`, `fld_LastName`, `fld_Suffix`, `fld_ContactNumber`, `fld_EmailAddress`, `fld_ProfileID`, `fld_AffiliateLevelID`, `fld_Username`, `fld_Password`, `fld_IsActivated`, `fld_IsTemporaryPassword`, `fld_IsActive`, `fld_DateRegistered`, `fld_DateUpdated`, `fld_DateDeleted`, `fld_IsDeleted`) VALUES
(1, '10101', 'Admin', NULL, 'Admin', NULL, '09123456789', 'webmaster@email.com', 1, 1, 'admin', 'cc83897986bf5b2d48c9622ddb0e62c5', b'1', b'0', b'1', '2021-06-10 00:00:00', '2021-07-25 00:00:00', NULL, b'0');
--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_AffiliateLevel`
--
ALTER TABLE `tbl_AffiliateLevel`
  ADD PRIMARY KEY (`fld_AffiliateLevelID`);

--
-- Indexes for table `tbl_Appointment`
--
ALTER TABLE `tbl_Appointment`
  ADD PRIMARY KEY (`fld_AppointmentId`);

--
-- Indexes for table `tbl_AppointmentReference`
--
ALTER TABLE `tbl_AppointmentReference`
  ADD PRIMARY KEY (`fld_ReferenceId`);

--
-- Indexes for table `tbl_Branch`
--
ALTER TABLE `tbl_Branch`
  ADD PRIMARY KEY (`fld_BranchId`);

--
-- Indexes for table `tbl_Feedback`
--
ALTER TABLE `tbl_Feedback`
  ADD PRIMARY KEY (`fld_FeedbackId`);

--
-- Indexes for table `tbl_FileStore`
--
ALTER TABLE `tbl_FileStore`
  ADD PRIMARY KEY (`fld_FileId`);

--
-- Indexes for table `tbl_PasswordReset`
--
ALTER TABLE `tbl_PasswordReset`
  ADD PRIMARY KEY (`fld_ID`);

--
-- Indexes for table `tbl_ProductClass`
--
ALTER TABLE `tbl_ProductClass`
  ADD PRIMARY KEY (`fld_ClassId`);

--
-- Indexes for table `tbl_Profile`
--
ALTER TABLE `tbl_Profile`
  ADD PRIMARY KEY (`fld_ProfileID`);

--
-- Indexes for table `tbl_Promotions`
--
ALTER TABLE `tbl_Promotions`
  ADD PRIMARY KEY (`fld_PromotionId`);

--
-- Indexes for table `tbl_Service`
--
ALTER TABLE `tbl_Service`
  ADD PRIMARY KEY (`fld_ServiceId`);

--
-- Indexes for table `tbl_Tutorials`
--
ALTER TABLE `tbl_Tutorials`
  ADD PRIMARY KEY (`fld_TutorialId`);

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
  MODIFY `fld_AffiliateLevelID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `tbl_Appointment`
--
ALTER TABLE `tbl_Appointment`
  MODIFY `fld_AppointmentId` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_AppointmentReference`
--
ALTER TABLE `tbl_AppointmentReference`
  MODIFY `fld_ReferenceId` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tbl_Branch`
--
ALTER TABLE `tbl_Branch`
  MODIFY `fld_BranchId` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `tbl_Feedback`
--
ALTER TABLE `tbl_Feedback`
  MODIFY `fld_FeedbackId` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_FileStore`
--
ALTER TABLE `tbl_FileStore`
  MODIFY `fld_FileId` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_PasswordReset`
--
ALTER TABLE `tbl_PasswordReset`
  MODIFY `fld_ID` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_ProductClass`
--
ALTER TABLE `tbl_ProductClass`
  MODIFY `fld_ClassId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tbl_Profile`
--
ALTER TABLE `tbl_Profile`
  MODIFY `fld_ProfileID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `tbl_Promotions`
--
ALTER TABLE `tbl_Promotions`
  MODIFY `fld_PromotionId` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_Service`
--
ALTER TABLE `tbl_Service`
  MODIFY `fld_ServiceId` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_Tutorials`
--
ALTER TABLE `tbl_Tutorials`
  MODIFY `fld_TutorialId` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_UserInformation`
--
ALTER TABLE `tbl_UserInformation`
  MODIFY `fld_ID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

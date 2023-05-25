CREATE DEFINER=`root`@`localhost` PROCEDURE 
`usp_UpdateProduct`(`service_id` BIGINT, `upload_new_file` BIT, 
`file_type` VARCHAR(10), `file_content_type` VARCHAR(60), `file_name` 
VARCHAR(100), `file_size` INT, `file_content` LONGBLOB, `modified_by` 
VARCHAR(30), `product_code` VARCHAR(30), `product_name` VARCHAR(150), 
`class_id` INT, `product_description` VARCHAR(8000))
BEGIN
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
						, fld_ProductName = 
product_name
                        , fld_ClassId = class_id
                        , fld_ProductImageId = image_id
                        , fld_ModifiedBy = modified_by
                        , fld_ProductDescription = product_description
                        , fld_DateModified = current_timestamp()
                        , fld_IsDeleted =0
					WHERE fld_ServiceId = service_id;
			ELSE
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 
'Cannot upload image file';
			END IF;
            
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product 
already exist';
		
    END IF;
    
END

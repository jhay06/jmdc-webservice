import mysql.connector
from ariadne import ObjectType
from database.connection import (Database, DatabaseConnection)
from database.json_result import JsonResult
from api.response.base_response import BaseResponse
from validations.base_validation import BaseValidation, FileValidation
import base64
import binascii
class Service:
    @staticmethod
    def resolve_all(query: ObjectType):
        if query is not None:
            query.set_field('add_service', Service.add_service)
            query.set_field('delete_service', Service.delete_service)
            query.set_field('update_service',Service.update_service)

    @staticmethod
    def add_service(obj, info, input: dict):
        try:

            product_code = input['product_code']
            product_name = input['product_name']
            product_description = input['product_description']
            image_file = input['image_file']
            file_content=image_file['file_content'].strip()
            b64=base64.b64decode(file_content)
            base_validation: BaseValidation = BaseValidation()
            validated = [base_validation.validate("product_code", product_code),
                         base_validation.validate("product_name", product_name),
                         base_validation.validate("product_description", product_description),
                         base_validation.validate("image_file", image_file)
                         ]

            for x in validated:
                if x is not None:
                    return BaseResponse(
                        type='failed',
                        message=x
                    )

            class_id = input['class_id']
            created_by = input['created_by']

            db = Database(db_config_file='db_config.json')
            db_con = DatabaseConnection(db)
            cursor = db_con.get_connection().cursor()
            content_types= {
                ".jpg": "image/jpg",
                ".jpeg": "image/jpeg",
                ".png": "image/png"
            }
            args = [
                image_file['file_type'],
                content_types[image_file['file_type']],
                image_file['file_name'],
                len(b64),
                binascii.hexlify(b64),
                created_by,
                product_code,
                product_name,
                class_id,
                product_description
            ]
            cursor.callproc('usp_InsertService', args)
            db_con.get_connection().commit()
            return BaseResponse(
                type='success',
                message='Service has been added successfully'
            )

        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )

    @staticmethod
    def delete_service(obj, info, input: dict):
        service_id =input['service_id']
        deleted_by = input['deleted_by']
        try:
            db=Database(db_config_file='db_config.json')
            dbcon=DatabaseConnection(db)
            cursor= dbcon.get_connection().cursor()
            cursor.callproc('usp_DeletProduct', args= [ service_id, deleted_by])
            dbcon.get_connection().commit()
            return BaseResponse(
                type='success',
                message='Successfully deleted'
            )
        except mysql.connector.Error as err:
            return BaseResponse(
                type='failed',
                message=err.msg
            )

    @staticmethod
    def update_service(obj, info, input: dict):
        try:
            service_id = input['service_id']
            upload_new_file=input['upload_new_file']
            product_code = input['product_code']
            product_name = input['product_name']
            product_description = input['product_description']
            image_file = input['image_file']
            b64=""
            if upload_new_file:
                file_content=image_file['file_content'].strip()

                b64=base64.b64decode(file_content)
            base_validation: BaseValidation = BaseValidation()
            validated = [base_validation.validate("product_code", product_code),
                         base_validation.validate("product_name", product_name),
                         base_validation.validate("product_description", product_description),
                         ]

            for x in validated:
                if x is not None:
                    return BaseResponse(
                        type='failed',
                        message=x
                    )
            if upload_new_file:
                image_file_validation= base_validation.validate("image_file", image_file)
                if image_file_validation is not None:
                    return BaseResponse(
                        type='failed',
                        message=image_file_validation
                    )

            class_id = input['class_id']
            modified_by = input['modified_by']
            db = Database(db_config_file='db_config.json')
            db_con = DatabaseConnection(db)
            cursor = db_con.get_connection().cursor()
            content_types= {
                ".jpg": "image/jpg",
                ".jpeg": "image/jpeg",
                ".png": "image/png"
            }
            file_type=None
            content_type=None
            image_file_name=None
            image_size=0
            image_data=None
            if upload_new_file:
                file_type=image_file['file_type']
                content_type=content_types[image_file['file_type']]
                image_file_name=image_file['file_name']
                image_size=len(b64)
                image_data=binascii.hexlify(b64)
            args = [
                service_id,
                upload_new_file,
                file_type,
                content_type,
                image_file_name,
                image_size,
                image_data,
                modified_by,
                product_code,
                product_name,
                class_id,
                product_description
            ]
            cursor.callproc('usp_UpdateProduct', args)
            db_con.get_connection().commit()
            return BaseResponse(
                type='success',
                message='Service successfully updated'
            )

        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )


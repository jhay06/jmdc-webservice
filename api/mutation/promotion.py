import mysql.connector
from ariadne import ObjectType
from database.connection import (Database, DatabaseConnection)
from database.json_result import JsonResult
from api.response.base_response import BaseResponse
from validations.base_validation import BaseValidation, FileValidation
import base64
import binascii
from datetime import datetime


class Promotion:
    @staticmethod
    def resolve_all(query: ObjectType):
        if query is not None:
            query.set_field('add_promotion', Promotion.add_promotion)
            query.set_field('delete_promotion', Promotion.delete_promotion)
            query.set_field('update_promotion', Promotion.update_promotion)

    @staticmethod
    def add_promotion(obj, info, input: dict):
        try:
            now = datetime.now()
            month = str(now.month)
            if len(month) == 1:
                month = '0' + month
            day = str(now.day)
            if len(day) == 1:
                day = '0' + day

            hour = str(now.hour)
            if len(hour) == 1:
                hour = '0' + hour
            min = str(now.minute)
            if len(min) == 1:
                min = '0' + min
            sec = str(now.second)
            if len(sec) == 1:
                sec = '0' + sec

            image_id = "Promotion_{year}{month}{day}{hour}{min}{sec}".format(
                year=now.year,
                month=month,
                day=day,
                hour=hour,
                min=min,
                sec=sec
            )

            promotion_name = input['promotion_name']
            promotion_description = input['description']
            status = input['status']

            image_file = input['image_file']
            file_content = image_file['file_content'].strip()
            b64 = base64.b64decode(file_content)
            base_validation: BaseValidation = BaseValidation()
            validated = [base_validation.validate("promotion_name", promotion_name),
                         base_validation.validate("promotion_description", promotion_description),
                         base_validation.validate("image_file", image_file)
                         ]

            for x in validated:
                if x is not None:
                    return BaseResponse(
                        type='failed',
                        message=x
                    )

            created_by = input['created_by']

            db = Database(db_config_file='db_config.json')
            db_con = DatabaseConnection(db)
            cursor = db_con.get_connection().cursor()
            content_types = {
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
                image_id,
                promotion_description,
                status,
                promotion_name
            ]
            cursor.callproc('usp_AddPromotion', args)
            db_con.get_connection().commit()
            return BaseResponse(
                type='success',
                message='Promotion has been added successfully'
            )

        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )

    @staticmethod
    def delete_promotion(obj, info, input: dict):
        promotion_id = input['promotion_id']
        deleted_by = input['deleted_by']
        try:
            db = Database(db_config_file='db_config.json')
            dbcon = DatabaseConnection(db)
            cursor = dbcon.get_connection().cursor()
            cursor.callproc('usp_DeletePromotion', args=[promotion_id, deleted_by])
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
    def update_promotion(obj, info, input: dict):
        try:
            promotion_id = input['promotion_id']
            upload_new_file = input['upload_new_file']
            image_id = input['image_id']
            promotion_name = input['promotion_name']
            promotion_description = input['description']
            status = input['status']
            image_file = input['image_file']
            b64 = ""
            if upload_new_file:
                file_content = image_file['file_content'].strip()

                b64 = base64.b64decode(file_content)
            base_validation: BaseValidation = BaseValidation()
            validated = [
                         base_validation.validate("promotion_name", promotion_name),
                         base_validation.validate("promotion_description", promotion_description),
                         ]

            for x in validated:
                if x is not None:
                    return BaseResponse(
                        type='failed',
                        message=x
                    )
            if upload_new_file:
                image_file_validation = base_validation.validate("image_file", image_file)
                if image_file_validation is not None:
                    return BaseResponse(
                        type='failed',
                        message=image_file_validation
                    )

            modified_by = input['modified_by']
            db = Database(db_config_file='db_config.json')
            db_con = DatabaseConnection(db)
            cursor = db_con.get_connection().cursor()
            content_types = {
                ".jpg": "image/jpg",
                ".jpeg": "image/jpeg",
                ".png": "image/png"
            }
            file_type = None
            content_type = None
            image_file_name = None
            image_size = 0
            image_data = None
            if upload_new_file:
                file_type = image_file['file_type']
                content_type = content_types[image_file['file_type']]
                image_file_name = image_file['file_name']
                image_size = len(b64)
                image_data = binascii.hexlify(b64)
            args = [
                promotion_id,
                upload_new_file,
                file_type,
                content_type,
                image_file_name,
                image_size,
                image_data,
                modified_by,
                image_id,
                promotion_description,
                status,
                promotion_name,

            ]
            cursor.callproc('usp_UpdatePromotion', args)
            db_con.get_connection().commit()
            return BaseResponse(
                type='success',
                message='Promotion successfully updated'
            )

        except mysql.connector.Error as err:

            return BaseResponse(
                type='error',
                message=err.msg
            )

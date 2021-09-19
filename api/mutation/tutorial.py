from ariadne import ObjectType

from api.response.base_response import BaseResponse
from database.connection import DatabaseConnection, Database
from validations.base_validation import BaseValidation
import mysql.connector

class Tutorial:
    @staticmethod
    def resolve_all(query: ObjectType):
        if query is not None:
            query.set_field("add_tutorial", Tutorial.add_tutorial)
            query.set_field('update_tutorial', Tutorial.update_tutorial)
            query.set_field('delete_tutorial', Tutorial.delete_tutorial)

    @staticmethod
    def add_tutorial(obj, info, input):
        youtube_id = input['youtube_id']
        video_title = input['video_title']
        youtube_description = input['video_description']
        youtube_link = input['youtube_link']
        created_by = input['created_by']
        base=BaseValidation()
        valid=[
            base.validate('youtube_id',youtube_id),
            base.validate('video_title',video_title),
            base.validate('youtube_link',youtube_link),
            base.validate('video_description',youtube_description)
        ]
        for x in valid:
            if x is not None:
                return BaseResponse(
                    type='failed',
                    message=x
                )
        try:
            db=Database(db_config_file='db_config.json')
            db_con=DatabaseConnection(db)
            cursor= db_con.get_connection().cursor()
            args=[
                youtube_id,
                video_title,
                youtube_link,
                youtube_description,
                created_by
            ]
            cursor.callproc('usp_AddTutorial',args=args)
            db_con.get_connection().commit()
            return BaseResponse(
                type='success',
                message='Tutorial successfully added'
            )
        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )
    @staticmethod
    def update_tutorial(obj, info, input):
        video_id= input['video_id']
        youtube_id = input['youtube_id']
        video_title = input['video_title']
        youtube_description = input['video_description']
        youtube_link = input['youtube_link']
        modified_by = input['modified_by']
        base = BaseValidation()
        valid = [
            base.validate('youtube_id', youtube_id),
            base.validate('video_title', video_title),
            base.validate('youtube_link', youtube_link),
            base.validate('video_description', youtube_description)
        ]
        for x in valid:
            if x is not None:
                return BaseResponse(
                    type='failed',
                    message=x
                )
        try:
            db = Database(db_config_file='db_config.json')
            db_con = DatabaseConnection(db)
            cursor = db_con.get_connection().cursor()
            args = [
                video_id,
                youtube_id,
                video_title,
                youtube_link,
                youtube_description,
                modified_by
            ]
            cursor.callproc('usp_UpdateTutorial', args=args)
            db_con.get_connection().commit()
            return BaseResponse(
                type='success',
                message='Tutorial successfully updated'
            )
        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )

    @staticmethod
    def delete_tutorial(obj, info, input):
        video_id = input['video_id']
        deleted_by = input['deleted_by']
        print(video_id)
        try:
            db=Database(db_config_file='db_config.json')
            db_con=DatabaseConnection(db)
            cursor=db_con.get_connection().cursor()
            args=[video_id, deleted_by]
            cursor.callproc('usp_DeleteTutorial', args=args)
            db_con.get_connection().commit()
            return BaseResponse(
                type='success',
                message='Tutorial Successfully Deleted'
            )
        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )

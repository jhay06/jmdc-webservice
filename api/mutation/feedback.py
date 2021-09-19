import mysql
from ariadne import ObjectType

from api.response.base_response import BaseResponse
from database.connection import Database, DatabaseConnection
from validations.base_validation import BaseValidation

class Feedback:
    @staticmethod
    def resolve_all(query: ObjectType):
        if query is not None:
            query.set_field("submit_feedback", Feedback.submit_feedback)

    @staticmethod
    def submit_feedback(obj,info,input):
        full_name=input['full_name']
        contact_no=input['contact_no']
        email_address=input['email_address']
        message=input['message']
        validate=BaseValidation()
        valid= [
            validate.validate('full_name',full_name),
            validate.validate('contact_number',contact_no),
            validate.validate('email_address',email_address),
            validate.validate('message',message)
        ]
        for x in valid:
            if x is not None:
                return BaseResponse(
                    type='failed',
                    message=x
                )

        try:
            db=Database(db_config_file='db_config.json')
            con=DatabaseConnection(db)
            cursor=con.get_connection().cursor()
            args=[
                full_name,
                contact_no,
                email_address,
                message
            ]
            cursor.callproc('usp_submitFeedback',args=args)
            con.get_connection().commit()
            return BaseResponse(
                type='success',
                message='Message has been sent'
            )
        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )
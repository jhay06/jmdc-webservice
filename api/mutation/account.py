import mysql.connector

from database.connection import (
    Database,
    DatabaseConnection
)
from api.response.login_response import LoginResponse
from api.response.base_response import BaseResponse
from validations.base_validation import BaseValidation
import hashlib
from database.model.login_information import LoginInformation
import json, base64
from bson import json_util


class Account:
    @staticmethod
    def change_password(obj,info,input:dict):
        new_password=input['new_password']
        base = BaseValidation()
        valid = base.validate('password', new_password)
        if valid is not None:
            return BaseResponse(
                type='failed',
                message=valid
            )

        new_pass_string=input['username']+";"+new_password
        new_pass_md5=hashlib.md5(new_pass_string.encode('utf-8')).hexdigest()
        old_pass_string=input['username']+";"+input['old_password']
        old_pass_md5=hashlib.md5(old_pass_string.encode('utf-8')).hexdigest()
        try:
            db=Database(db_config_file='db_config.json')
            con=DatabaseConnection(db)
            cursor=con.get_connection().cursor()
            input_data=[new_pass_md5,old_pass_md5,input['username'] ]
            cursor.callproc('usp_ChangePassword',input_data)
            con.get_connection().commit()
            return BaseResponse(
                type='success',
                message='Password updated'
            )
        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )

    @staticmethod
    def update_account(obj, info, input: dict):

        suffix = None
        middle_name = None
        employee_no = None
        new_employee_no = None
        if "suffix" in input.keys():
            if input['suffix'] is not None:
                suffix = input['suffix']

        if "middle_name" in input.keys():
            if input['middle_name'] is not None:
                middle_name = input['middle_name']
        if "employee_no" in input.keys():
            if input['employee_no'] is not None:
                employee_no = input['employee_no']
        if "new_employee_no" in input.keys():

            if input['new_employee_no'] is not None:
                new_employee_no = input['new_employee_no']

        for x in input.keys():
            base = BaseValidation()
            valid = base.validate(x, input[x])
            if valid is not None:
                return BaseResponse(
                    type='failed',
                    message=valid
                )

        try:
            db = Database(db_config_file="db_config.json")
            con = DatabaseConnection(db)
            cursor = con.get_connection().cursor()
            input_data = [
                employee_no,
                input['first_name'],
                middle_name,
                input['last_name'],
                suffix,
                input['contact_no'],
                input['email_address'],
                input['profile_id'],
                input['affiliate_level_id'],
                input['username'],
                input['is_activated'],
                new_employee_no,
                input['new_username']

            ]
            cursor.callproc("usp_UpdateAccount", input_data)

            con.get_connection().commit()
            login_info = LoginInformation(employee_no=new_employee_no,
                                          first_name=input['first_name'],
                                          middle_name=middle_name,
                                          last_name=input['last_name'],
                                          suffix=suffix,
                                          email_address=input['email_address'],
                                          username=input['new_username'],
                                          profile_id=input['profile_id'],
                                          contact_number=input['contact_no'],
                                          affiliate_level_id=input['affiliate_level_id'],
                                          date_registered=input['date_registered'])
            info = json.dumps(login_info.__dict__, default=json_util.default);
            hash = base64.b64encode(info.encode('utf-8')).decode('utf-8')
            login_user = LoginResponse()
            login_user.username = input['new_username']
            login_user.login_hash = hash
            return BaseResponse(
                type='success',
                message='Update successful',
                data=login_user
            )

        except mysql.connector.Error as err:

            return BaseResponse(
                type='failed',
                message=err.msg
            )

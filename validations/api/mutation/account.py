import mysql.connector

from database.connection import (
    Database,
    DatabaseConnection
)
from database.json_result import JsonResult
from api.response.login_response import LoginResponse
from api.response.base_response import BaseResponse
from validations.base_validation import BaseValidation
import hashlib
from database.model.login_information import LoginInformation
import json, base64
from bson import json_util
from modules.email_sender import SendMail
import random


class Account:
    @staticmethod
    def forgot_password(obj,info,input:dict):
        email_address=input['email_address']
        reset_key=input['reset_key']
        username=input['username']
        new_password=input['new_password']
        base=BaseValidation()
        valid_email=base.validate('email_address',email_address)
        valid_password=base.validate('password',new_password)
        valid=[valid_email,valid_password]
        for x in valid:
            if x is not None:
                return BaseResponse(
                    type='failed',
                    message=x
                )
        try:
            pass_string = username + ";" + new_password
            password_md5 = hashlib.md5(pass_string.encode('utf-8')).hexdigest()
            db=Database(db_config_file='db_config.json')
            con=DatabaseConnection(db)
            is_valid=Account.is_valid_reset_key(email_address,reset_key,con)
            if is_valid==False:
                return BaseResponse(
                    type='failed',
                    message='Expired/Invalid reset key'
                )
            cursor=con.get_connection().cursor()
            cursor.callproc('usp_ForgotPasswordChange',[email_address,reset_key,password_md5])
            con.get_connection().commit()
            return BaseResponse(
                type='success',
                message='Password successfully changed'
            )
        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )

    @staticmethod
    def is_valid_reset_key(email_address,reset_key,con:DatabaseConnection):

            cursor=con.get_connection().cursor()
            cursor.callproc('usp_IsValidResetKey',[email_address,reset_key])
            is_valid=False
            for result in cursor.stored_results():
                data=JsonResult(result).to_json()
                is_valid=data['is_valid']
                break
            if is_valid:
                return True
            else:
                return False



    @staticmethod
    def validate_reset_key(obj,info,input:dict):
        email_address=input['email_address']
        reset_key=input['reset_key']
        base=BaseValidation()
        valid=base.validate('email_address',email_address)
        if valid is not None:
            return BaseResponse(
                type='failed',
                message=valid
            )
        try:
            db=Database(db_config_file='db_config.json')
            con=DatabaseConnection(db)
            is_valid=Account.is_valid_reset_key(email_address,reset_key,con)
            if is_valid:
                return BaseResponse(
                    type='success',
                    message='Reset key still active'
                )
            else:
                return BaseResponse(
                    type='failed',
                    message='Reset key invalid'
                )
        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )
    @staticmethod
    def request_forgot_pass_key(obj, info, input: dict):
        email_address = input['email_address']
        base = BaseValidation()
        valid = base.validate('email_address', email_address)
        if valid is not None:
            return BaseResponse(
                type='failed',
                message=valid
            )
        try:
            f = open('assets/emails/reset_key.html', "r")
            html_part = f.read()
            f.close()
            reset_int = str(random.randint(100000000, 999999999))
            reset_key = hashlib.md5(reset_int.encode('utf-8')).hexdigest()
            message = ""
            db = Database(db_config_file='db_config.json')
            con = DatabaseConnection(db=db)
            cursor = con.get_connection().cursor()
            cursor.callproc('usp_GetActiveResetKey', [email_address])
            active_key = None
            username=None
            for result in cursor.stored_results():
                data = JsonResult(result).to_json()
                username=data['username']
                active_key = data['reset_key']
                break
            if active_key is not None:
                message = html_part.format(domain='localhost:2022',
                                           reset_key=active_key,
                                           email_address=email_address,
                                           username=username
                                           )
            else:
                cursor.callproc('usp_SavePasswordReset', [email_address, reset_key, True])
                con.get_connection().commit()
                for result in cursor.stored_results():
                    data=JsonResult(result).to_json()
                    username=data['username']
                    break
                message = html_part.format(domain='localhost:2022',
                                           reset_key=reset_key,
                                           email_address=email_address,
                                           username=username
                                           )
            send_mail = SendMail(subject='JMDC: Forgot Password', message=message, is_html=True,
                                 from_addr='no-reply@gmail.com', to_addr=email_address,
                                 config='smtp_config.json')
            send_mail.send()
            return BaseResponse(
                type='success',
                message='Successfully request'
            )
        except mysql.connector.Error as err:
            return BaseResponse(
                type='failed',
                message=err.msg
            )

    @staticmethod
    def change_password(obj, info, input: dict):
        new_password = input['new_password']
        base = BaseValidation()
        valid = base.validate('password', new_password)
        if valid is not None:
            return BaseResponse(
                type='failed',
                message=valid
            )

        new_pass_string = input['username'] + ";" + new_password
        new_pass_md5 = hashlib.md5(new_pass_string.encode('utf-8')).hexdigest()
        old_pass_string = input['username'] + ";" + input['old_password']
        old_pass_md5 = hashlib.md5(old_pass_string.encode('utf-8')).hexdigest()
        try:
            db = Database(db_config_file='db_config.json')
            con = DatabaseConnection(db)
            cursor = con.get_connection().cursor()
            input_data = [new_pass_md5, old_pass_md5, input['username']]
            cursor.callproc('usp_ChangePassword', input_data)
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

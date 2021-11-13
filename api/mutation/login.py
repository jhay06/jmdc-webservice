import mysql.connector

from api.response.login_response import LoginResponse
from api.response.base_response import BaseResponse
from database.connection import (
    Database,
    DatabaseConnection
)
from database.model.login_information import LoginInformation
import json
from database.json_result import JsonResult
import hashlib
from bson import json_util
import base64


class Login:
    @staticmethod
    def process_login(obj, info, input):

        input_error = False
        input_error_message = None
        has_info = False
        if input['username'] is None:
            input_error = True
            input_error_message = 'Username is required'
        elif len(input['username'].strip()) == 0:
            input_error = True
            input_error_message = 'Username is required'
        elif input['password'] is None:
            input_error = True
            input_error_message = "Password is required"
        elif len(input['password'].strip()) == 0:
            input_error = True
            input_error_message = 'Password is required'

        if not input_error:
            db = Database(db_config_file="db_config.json")
            try:
                con = DatabaseConnection(db)
                cursor = con.get_connection().cursor()
                pass_string = input['username'] + ';' + input['password']

                password_md5 = hashlib.md5(pass_string.encode('utf-8')).hexdigest()
             
                cursor.callproc('usp_GetLoginInformation', args=(input['username'], password_md5))

                login_info: LoginInformation = None
                for result in cursor.stored_results():
                    data = JsonResult(result)
                    if data.to_json() is not None:
                        has_info = True
                        login_info = LoginInformation(**data.to_json())
                        break
                login_response = LoginResponse()
                base_response = BaseResponse(
                    type="success",
                    message="login successful",
                    data=login_response
                )
            except mysql.connector.Error as err:
                login_response = LoginResponse()
                base_response = BaseResponse(
                    type="failed",
                    message="Could not connect to database " + err.msg
                )
                return base_response
            login_response.username = input['username']
            if has_info:
                info = json.dumps(login_info.__dict__, default=json_util.default);
                hash = base64.b64encode(info.encode('utf-8')).decode('utf-8')

                base_response.type = 'success'
                login_response.login_hash = hash

            else:
                base_response.type = 'failed'
                base_response.message = 'no login information'
            return base_response
        else:
            return BaseResponse(
                type="failed",
                message=input_error_message

            )

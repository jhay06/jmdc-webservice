
from validations.base_validation import BaseValidation
from api.response.base_response import BaseResponse
from api.response.registration_response import RegistrationResponse
from database.connection import ( Database,
                                  DatabaseConnection,
                                  DatabaseConfig
                                )
import mysql.connector
import hashlib
import json
from database.json_result import JsonResult
from modules.email_sender import SendMail
class Register:
    @staticmethod
    def process_registration(obj, info, input: dict):

        reg = RegistrationResponse()
        input_error=False
        input_error_message=None
        profile_id=2
        is_accreditation=input['is_accreditation']
        affiliate_level=0
        email_address=None
        contact_number=None
        suffix=None
        middle_name=None
        employee_no=None

        if "suffix" in input.keys():
            if input['suffix'] is not None:
                suffix=input['suffix']
        if "middle_name" in input.keys():
            if input['middle_name'] is not None:
                middle_name=input['middle_name']
        if "employee_no" in input.keys():
            if input['employee_no'] is not None:
                employee_no=input['employee_no']
        if "email_address" in input.keys():
            if input['email_address'] is not None:
                email_address=input['email_address']
            else:
                input_error = True
                input_error_message = 'Email address is required'
        else:
            input_error = True
            input_error_message = 'Email address is required'

        if is_accreditation:
            profile_id=3

            if not input['affiliate_level']:
                input_error=True
                input_error_message = 'Affiliate level is required'

            elif not input['contact_number']:
                input_error=True
                input_error_message='Contact number is required'
            else:
                affiliate_level=input['affiliate_level']
                email_address=input['email_address']
                contact_number=input['contact_number']
        if affiliate_level is None:
            affiliate_level=0



        for x in input.keys():
            base = BaseValidation()
            valid = base.validate(x , input[x])
            if valid is not None:
                return BaseResponse(
                    type='failed',
                    message=valid
                )
        if not input_error:
            try:
                db=Database(db_config_file="db_config.json")
                con=DatabaseConnection(db)
                cursor=con.get_connection().cursor()
                password_md5=None
                if 'password' in input.keys():
                    if input['password'] is not None:
                        pass_string= input['username']+";"+input['password']
                        password_md5= hashlib.md5(pass_string.encode('utf-8')).hexdigest()


                cursor.callproc("usp_AddAccount",args=(
                        employee_no,
                        input['first_name'],
                        middle_name,
                        input['last_name'],
                        suffix,
                        contact_number,
                        email_address,
                        profile_id,
                        affiliate_level,
                        input['username'],
                        password_md5

                    ))
                con.get_connection().commit()
                if email_address is not None:
                    f=open('assets/emails/account_registration.html',"r")

                    html_part=f.read()
                    f.close()
                    message=html_part.format(username=input['username'], password=input['password'])
                    send_mail=SendMail(subject='Copy of JMDC Password',message=message,is_html=True,
                                       from_addr='no-reply@gmail.com',to_addr=email_address,
                                       config='smtp_config.json')
                    send_mail.send()

                return BaseResponse(
                        type = 'success',
                        message= 'Registration successful',
                        data=reg
                )

                reg.username=input['username']
            except mysql.connector.Error as err:
                
                return BaseResponse(
                    type = 'failed',
                    message=err.msg
                )

from ariadne import ObjectType
from validations.base_validation import BaseValidation
from api.response.base_response import BaseResponse
from database.connection import (Database,DatabaseConnection)
from database.json_result import JsonResult
from database.model.reference_code import ReferenceCode
from datetime import datetime
import mysql.connector

class Appointment:
    @staticmethod
    def add_appointment(obj, info, input):
        patient_name = input['patient_name']
        patient_contact_no = input['patient_contact_no']
        email_address = input['email_address']
        branch_code = input['branch_code']
        branch_name = input['branch_name']
        appointment_date = input['appointment_date']
        start_timeslot = int(input['start_timeslot'])
        end_timeslot = int(input['end_timeslot'])
        appoint_by = input['appoint_by']
        validator = BaseValidation()
        patient_name_validate = validator.validate('patient_name', patient_name)
        if patient_name_validate is not None:
            return BaseResponse(
                type='failed',
                message=patient_name_validate
            )
        patient_contact_no_validate = validator.validate('contact_number', patient_contact_no)
        if patient_contact_no_validate is not None:
            return BaseValidation(
                type='failed',
                message=patient_contact_no_validate
            )
        email_address_validate = validator.validate('email_address', email_address)
        if email_address_validate is not None:
            return BaseValidation(
                type='failed',
                message=email_address_validate
            )
        try:
            generated_code=Appointment.generate_reference_code()
            if generated_code.type !='success':
                return BaseResponse(
                    type='failed',
                    message='Unable to generate a reference code'
                )

            reference_code=generated_code.data['code']
            db=Database(db_config_file='db_config.json')
            db_con=DatabaseConnection(db=db)
            cursor=db_con.get_connection().cursor()
            cursor.callproc('usp_AddAppointment',args=(
                patient_name,
                patient_contact_no,
                email_address,
                branch_code,
                branch_name,
                appointment_date,
                start_timeslot,
                end_timeslot,
                appoint_by,
                reference_code
            ))
            db_con.get_connection().commit()
            return BaseResponse(
                type='success',
                message='Appointment Added'
            )

        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )
    @staticmethod
    def convert_to_zeroes_string(d:int,max_length:int):
        x=str(d)
        zeroes=0
        if len(x) < max_length:
            zeroes=max_length-len(x)
        i=0
        while i < zeroes:
            x='0'+x
            i+=1
        return x

    @staticmethod
    def generate_reference_code(obj=None,info=None):
        code_format='AP{year}-{month}'
        now=datetime.now()
        month=str(now.month)
        if len(month) == 1:
            month='0'+month
        lookup=code_format.format(year=now.year,month=month)

        try:
            db=Database(db_config_file='db_config.json')
            db_con=DatabaseConnection(db)
            cursor=db_con.get_connection().cursor()
            cursor.callproc('usp_GetAllReferenceCode')
            list=[]
            has_next=False
            for result in cursor.stored_results():
                data=JsonResult(result)
                if data.rows > 0:
                    i=0
                    while i < data.rows:
                        js=data.to_json(i)
                        ref_code=ReferenceCode(**js)
                        if lookup in ref_code.reference_code:
                            list.append(ref_code)
                        i+=1
            if len(list) > 0:
               has_next=True

            last_form=1
            if has_next:
               last_form=len(list)
               last_form+=1

            code_final=lookup+'-'+Appointment.convert_to_zeroes_string(last_form,4)
            return BaseResponse(
                type='success',
                message='generated code',
                data={
                    'code':code_final
                }
            )

        except mysql.connector.Error as err:
            return BaseResponse(
                type='failed',
                message=err.msg
            )

    @staticmethod
    def update_appointment(obj, info, input):
        pass

    @staticmethod
    def cancel_appointment(obj, info, input):
        pass

    @staticmethod
    def resolve_all(query: ObjectType):
        query.set_field('generate_appointment_reference_code',Appointment.generate_reference_code)
        query.set_field('add_appointment',Appointment.add_appointment)


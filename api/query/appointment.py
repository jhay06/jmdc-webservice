import mysql.connector
from ariadne import ObjectType
from database.connection import (Database, DatabaseConnection)
from database.json_result import JsonResult
from api.response.base_response import BaseResponse
from database.model.appointment_model import AppointmentModel


class Appointment:
    @staticmethod
    def get_active_appointment_list(obj, info):
        pass

    @staticmethod
    def get_cancelled_appointment_list(obj, info):
        pass

    @staticmethod
    def get_active_appointment_by_range(obj,info,input:dict):
        appoint_by=input['username']
        branch_code=input['branch_code']
        from_range=input['from_range']
        to_range=input['to_range']
        try:
            db=Database(db_config_file='db_config.json')
            db_con=DatabaseConnection(db)
            cursor=db_con.get_connection().cursor()
            args=[from_range,to_range,branch_code,appoint_by]
            cursor.callproc('usp_GetAppointmentByRange',args)
            list=[]
            for result in cursor.stored_results():
                data=JsonResult(result)
                if data.rows > 0:
                    i=0;
                    while i< data.rows:
                        data_js= data.to_json(i)
                        appointment=AppointmentModel(**data_js)
                        if not appointment.is_cancelled:
                            list.append(appointment)
                        i+=1
            return BaseResponse(
                type='success',
                message='Get active appointment list',
                data=list
            )
        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )


    @staticmethod
    def get_active_appointment_list_by(obj, info, input):
        username = input['username']
        branch_code=None
        if 'branch_code' in input.keys():
            branch_code=input['branch_code']
        try:
            db = Database(db_config_file='db_config.json')
            db_con = DatabaseConnection(db)
            cursor = db_con.get_connection().cursor()
            args = [username,branch_code]
            cursor.callproc('usp_GetAppointmentListBy', args)
            list = []
            for result in cursor.stored_results():
                data = JsonResult(result)
                if data.rows > 0:
                    i = 0
                    while i < data.rows:
                        data_js = data.to_json(i)
                        appointment = AppointmentModel(**data_js)
                        if not appointment.is_cancelled:
                            list.append(appointment)
                        i += 1
            return BaseResponse(
                type='success',
                message='Got list',
                data=list

            )
        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )

    @staticmethod
    def get_cancelled_appointment_list_by(obj, info, input):
        pass

    @staticmethod
    def get_appointment_info(obj, info, input):
        pass

    @staticmethod
    def resolve_all(query: ObjectType):
        query.set_field('get_active_appointment_by_username', Appointment.get_active_appointment_list_by)
        query.set_field('get_active_appointment_by_range',Appointment.get_active_appointment_by_range)

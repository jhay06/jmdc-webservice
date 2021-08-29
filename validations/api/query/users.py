import mysql.connector

from api.response.base_response import BaseResponse
from database.model.login_information import LoginInformation
from database.connection import (Database, DatabaseConnection)
from database.json_result import JsonResult
from ariadne.objects import ObjectType


class Users:
    @staticmethod
    def get_user_info(obj, info, input: dict):
        if 'username' not in input.keys():
            return BaseResponse(
                type='failed',
                message='Please add username'
            )
        try:
            db = Database(db_config_file='db_config.json')
            con = DatabaseConnection(db)
            cursor = con.get_connection().cursor()
            username=input['username']

            cursor.callproc("usp_GetInformationByUsername", [username])
            info: LoginInformation = None
            for result in cursor.stored_results():
                data = JsonResult(result)
                data_json = data.to_json()
                info = LoginInformation(**data_json)
                break
            if info is not None:
                return BaseResponse(
                    type='success',
                    message='Got information of ' + input['username'],
                    data=info
                )
            else:
                return BaseResponse(
                    type='failed',
                    message='No information found for ' + input['username']

                )
        except mysql.connector.Error as e:
            return BaseResponse(
                type='error',
                message=e.msg
            )

    @staticmethod
    def get_user_list(obj, info, input: dict):

        if input['profile_id'] == 0:
            return BaseResponse(
                type='failed',
                message='Invalid profile id'
            )
        try:
            db = Database(db_config_file='db_config.json')
            con = DatabaseConnection(db)
            cursor = con.get_connection().cursor()

            affiliate_level = 0
            if 'affiliate_level' in input.keys():
                if input['affiliate_level'] is not None:
                    affiliate_level = input['affiliate_level']

            cursor.callproc('usp_GetUserInformation', args=(input['profile_id'], affiliate_level))
            list_info = []
            for result in cursor.stored_results():
                data = JsonResult(result)
                i = 0
                while i < data.rows:
                    data_json = data.to_json(i)
                    user_info = LoginInformation(**data_json)
                    list_info.append(user_info)
                    i += 1
            return BaseResponse(
                type='success',
                message='got list',
                data={'users': list_info}
            )

        except:
            return BaseResponse(
                type='failed',
                message='Could not connect to database server'
            )

    @staticmethod
    def resolve_all(query: ObjectType):
        query.set_field('get_user_list', Users.get_user_list)
        query.set_field('get_user_info',Users.get_user_info)

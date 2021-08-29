from ariadne import ObjectType
import mysql.connector

from api.response.base_response import BaseResponse
from database.connection import (Database, DatabaseConnection)
from database.json_result import JsonResult
from database.model.branch import BranchModel


class Branch:
    @staticmethod
    def get_all_branch(obj, info):
        try:
            db = Database(db_config_file='db_config.json')
            con = DatabaseConnection(db)
            cursor = con.get_connection().cursor()
            cursor.callproc('usp_GetBranchList', args=())
            branches = []
            for result in cursor.stored_results():
                data = JsonResult(result)
                i = 0
                while i < data.rows:
                    data_json = data.to_json(i)
                    branch = BranchModel(**data_json)
                    branches.append(branch)
                    i += 1
            return BaseResponse(
                type='success',
                message='got list',
                data=branches
            )
        except Exception as err:
            return BaseResponse(
                type='error',
                message='Unknown error, Please try again'

            )

    @staticmethod
    def resolve_all(query: ObjectType):
        query.set_field('get_branches', Branch.get_all_branch);

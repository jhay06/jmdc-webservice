from ariadne import ObjectType

from api.response.base_response import BaseResponse
from database.connection import Database, DatabaseConnection
from database.json_result import JsonResult
import mysql.connector
from database.model.product_class import ProductClass


class Product:
    @staticmethod
    def resolve_all(query: ObjectType):
        if query is not None:
            query.set_field('get_product_class_list', Product.get_product_classes)

    @staticmethod
    def get_product_classes(obj, info):
        try:
            db = Database(db_config_file='db_config.json')
            dbcon = DatabaseConnection(db)
            cursor = dbcon.get_connection().cursor()
            cursor.callproc('usp_GetClassification', args=())
            list = []
            for res in cursor.stored_results():

                data = JsonResult(res)
                i = 0

                while i < data.rows:
                    data_json = data.to_json(i)
                    prod = ProductClass(**data_json)
                    list.append(prod)
                    i += 1
            return BaseResponse(
                type='success',
                message='got list of product class',
                data=list
            )
        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )

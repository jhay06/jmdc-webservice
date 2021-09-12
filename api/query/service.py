from ariadne import ObjectType

from api.response.base_response import BaseResponse
from database.connection import Database, DatabaseConnection
from database.model.product_model import ProductModel
from database.json_result import JsonResult
import mysql.connector
class Service:
    @staticmethod
    def resolve_all(query: ObjectType = None):
        if query is not None:
            query.set_field('get_services', Service.get_service)
            query.set_field('get_product_by_id',Service.get_service_by_id)
            query.set_field('get_product_by_product_code',Service.get_service_by_product_code)

    @staticmethod
    def get_service_by_product_code(obj,info,input):
        product_code=input['product_code']
        try:
            db = Database(db_config_file='db_config.json')
            dbcon = DatabaseConnection(db)
            cursor = dbcon.get_connection().cursor()
            cursor.callproc('usp_GetProductByProductCode', args=[product_code])
            product_info = None
            for result in cursor.stored_results():
                data = JsonResult(result)
                if data.rows > 0:
                    data_json = data.to_json()
                    product_info = ProductModel(**data_json)
                    return BaseResponse(
                        type='success',
                        message='got product',
                        data=product_info
                    )
                else:
                    return BaseResponse(
                        type='failed',
                        message='No such product'
                    )
        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )
    @staticmethod
    def get_service_by_id(obj,info,input):
        service_id=input['service_id']
        try:
            db=Database(db_config_file='db_config.json')
            dbcon=DatabaseConnection(db)
            cursor=dbcon.get_connection().cursor()
            cursor.callproc('usp_GetProductById',args=[service_id])
            product_info=None
            for result in cursor.stored_results():
                data=JsonResult(result)
                if data.rows > 0:
                    data_json=data.to_json()
                    product_info=ProductModel(**data_json)
                    return BaseResponse(
                        type='success',
                        message='got product',
                        data=product_info
                    )
                else:
                    return BaseResponse(
                        type='failed',
                        message='No such product'
                    )
        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )
    @staticmethod
    def get_service(obj, info):
        try:
            db = Database(db_config_file='db_config.json')
            dbcon = DatabaseConnection(db)
            cursor = dbcon.get_connection().cursor()
            cursor.callproc('usp_GetProductList')
            list = []
            for result in cursor.stored_results():
                data = JsonResult(result)
                i = 0
                while i < data.rows:
                    data_json = data.to_json(i)
                    list.append(ProductModel(**data_json))
                    i += 1
            return BaseResponse(
                type='success',
                message='Got product list',
                data=list
            )

        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )

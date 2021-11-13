from ariadne import ObjectType

from api.response.base_response import BaseResponse
from database.connection import Database, DatabaseConnection
from database.model.promotion_model import PromotionModel
from database.json_result import JsonResult
from api.utils.pagination import Pagination, PaginationResponse
import mysql.connector


class Promotion:
    @staticmethod
    def resolve_all(query: ObjectType = None):
        if query is not None:
            query.set_field('get_promotion_list', Promotion.get_promotion_list)
            query.set_field('get_promotion_by_id', Promotion.get_promotion_by_id)
            query.set_field('get_promotion_by_image_id',Promotion.get_promotion_by_image_id)


    @staticmethod
    def get_promotion_by_id(obj, info, input):
        promotion_id = input['promotion_id']
        try:
            db = Database(db_config_file='db_config.json')
            dbcon = DatabaseConnection(db)
            cursor = dbcon.get_connection().cursor()
            cursor.callproc('usp_GetPromotionById', args=[promotion_id])
            promotion_info = None
            for result in cursor.stored_results():
                data = JsonResult(result)
                if data.rows > 0:
                    data_json = data.to_json()
                    promotion_info = PromotionModel(**data_json)
                    return BaseResponse(
                        type='success',
                        message='got promotion',
                        data=promotion_info
                    )
                else:
                    return BaseResponse(
                        type='failed',
                        message='No such promotion'
                    )
        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )

    @staticmethod
    def get_promotion_by_image_id(obj,info,input={}):
        image_id = input['image_id']
        try:
            db = Database(db_config_file='db_config.json')
            dbcon = DatabaseConnection(db)
            cursor = dbcon.get_connection().cursor()
            cursor.callproc('usp_GetPromotionByImageId', args=[image_id])
            promotion_info = None
            for result in cursor.stored_results():
                data = JsonResult(result)
                if data.rows > 0:
                    data_json = data.to_json()
                    promotion_info = PromotionModel(**data_json)
                    return BaseResponse(
                        type='success',
                        message='got promotion',
                        data=promotion_info
                    )
                else:
                    return BaseResponse(
                        type='failed',
                        message='No such promotion'
                    )
        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )

    @staticmethod
    def get_promotion_list(obj, info, pagination={}):
        paging = Pagination(**pagination)

        try:
            db = Database(db_config_file='db_config.json')
            dbcon = DatabaseConnection(db)
            cursor = dbcon.get_connection().cursor()
            cursor.callproc('usp_GetPromotionList')
            list = []
            total_count = 0

            for result in cursor.stored_results():
                data = JsonResult(result)
                i = 0
                total_count = data.rows
                total_row = data.rows
                if paging.has_pagination:

                    if paging.limit_page < data.rows:
                        if paging.page == 0:
                            paging.page = 1

                        i = (paging.page - 1) * paging.limit_page
                        total_row = (paging.limit_page) * paging.page
                        if total_row > total_count:
                            total_row = total_count

                while i < total_row:

                    data_json = data.to_json(i)
                    list.append(PromotionModel(**data_json))
                    i += 1
            return BaseResponse(
                type='success',
                message='Got promotion list',
                data=list,
                pagination=PaginationResponse(
                    current_page=paging.page,
                    total_count=total_count
                ).__dict__
            )

        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )

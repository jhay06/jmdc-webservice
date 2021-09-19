from ariadne import ObjectType

from api.response.base_response import BaseResponse
from database.connection import Database, DatabaseConnection
from database.json_result import JsonResult
from database.model.tutorial_model import TutorialModel
import mysql.connector
from api.utils.pagination import Pagination, PaginationResponse


class Tutorial:
    @staticmethod
    def resolve_all(query: ObjectType):
        if query is not None:
            query.set_field('get_tutorial_list', Tutorial.get_tutorial_list)
            query.set_field('get_tutorial_info',Tutorial.get_tutorial_info)

    @staticmethod
    def get_tutorial_list(obj,info,pagination={}):
        paging=Pagination(**pagination)
        try:
            db=Database(db_config_file='db_config.json')
            db_con=DatabaseConnection(db)
            cursor=db_con.get_connection().cursor()
            cursor.callproc('usp_GetTutorialList')
            total_count=0
            list=[]
            for result in cursor.stored_results():
                data=JsonResult(result)
                i=0
                total_count=data.rows
                total_row=data.rows
                if paging.has_pagination:

                    if paging.limit_page < data.rows:
                        if paging.page == 0:
                            paging.page = 1

                        i = (paging.page - 1) * paging.limit_page
                        total_row = (paging.limit_page) * paging.page
                        if (total_row > total_count):
                            total_row = total_count
                while i < total_row:
                    data_js=data.to_json(i)
                    list.append(TutorialModel(**data_js))
                    i += 1

            return BaseResponse(
                type='success',
                message='Got list',
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

    @staticmethod
    def get_tutorial_info(obj,info,input):
        try:
            youtube_id=input['youtube_id']
            db=Database(db_config_file='db_config.json')
            db_con=DatabaseConnection(db)
            cursor= db_con.get_connection().cursor()
            cursor.callproc('usp_GetTutorialByYoutubeId',args=[youtube_id])
            video_info=None
            for result in cursor.stored_results():
                data=JsonResult(result)
                if data.rows > 0:
                    info =data.to_json()
                    video_info=TutorialModel(**info)

            return BaseResponse(
                type='success',
                message='Got tutorial',
                data=video_info
            )

        except mysql.connector.Error as err:
            return BaseResponse(
                type='error',
                message=err.msg
            )
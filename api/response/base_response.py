from api.utils.pagination import PaginationResponse
class BaseResponse:
    def __init__(self, type=None, message=None, data=None, pagination={}, *args, **kwargs):
        self.type = type
        self.message = message
        self.data = data
        self.pagination=PaginationResponse(**pagination)


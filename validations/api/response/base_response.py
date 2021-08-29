class BaseResponse:
    def __init__(self,type=None,message=None,data=None,*args,**kwargs):
        self.type=type
        self.message=message
        self.data=data
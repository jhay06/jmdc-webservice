class MinimumValue:
    def __init__(self,val=0,error=None,*args,**kwargs):
        self.val=val
        self.error=error
    def is_valid(self,value:int):
        if value is not None:
            if value < self.val:
                return self.error
            else:
                return None

        else:
            return None
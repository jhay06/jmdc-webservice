class MaxLength:
    def __init__(self,val=0,error=None,*args,**kwargs):
        self.val=val
        self.error=error
    def is_valid(self,value):
        if value is not None:
            if len(value) > self.val:
                return self.error

            else:
                return None        


        else:
            return None

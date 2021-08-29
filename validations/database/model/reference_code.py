from datetime import datetime
class ReferenceCode:
    def __init__(self,
                 reference_id=0,
                 reference_code=None,
                 appointment_id=0,
                 date_created=None,
                 date_used=None,
                 is_used=False,
                 *args,**kwargs
                 ):
        self.reference_id:int=reference_id
        self.reference_code:str=reference_code
        self.appointment_id:int=appointment_id
        self.date_created:datetime=date_created
        self.date_used:datetime= date_used
        self.is_used:bool=is_used
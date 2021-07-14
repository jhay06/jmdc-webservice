from email_validator import validate_email
class EmailValidation:
    def __init__(self,format={},*args,**kwargs):
        self.format=format
    def is_valid(self,value):
        if value is not None:
            try:
                valid=validate_email(value)
                return None
            except:
                return self.format['error']
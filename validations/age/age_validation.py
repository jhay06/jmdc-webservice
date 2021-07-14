from validations.age.date_format_validation import DateFormat
from validations.age.max_age_validation import MaxAge
from validations.age.min_age_validation import MinAge
from datetime import datetime
class AgeValidation:
    def __init__(self,min={},max={},date_format={},*args,**kwargs):
        self.min=min
        self.max=max
        self.format=date_format
        
    def is_valid(self,value):
        
        format=DateFormat(**self.format)
        format_validate=format.is_valid(value)
        if format_validate is not None:
            return format_validate
        set_date=datetime.strptime(value,format.val)
        age=self.compute_age(set_date)
        min=MinAge(**self.min)
        min_validate=min.is_valid(age)
        if min_validate is not None:
            return min_validate
        max=MaxAge(**self.max)
        max_validate=max.is_valid(age)
        if max_validate is not None:
            return max_validate

    def compute_age(self,set_date:datetime):
        now=datetime.now()
        set_month=set_date.month
        set_day=set_date.day
        set_year=set_date.year

        month=now.month
        day=now.day
        year=now.year
        age=year-set_year
        if set_month < month:
            age-=1
        elif set_month==month:
            if set_day < day:
                age-=1
        
        return age
        


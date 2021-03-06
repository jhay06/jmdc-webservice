from datetime import datetime


class LoginInformation:
    def __init__(self,
                 employee_no=None,
                 first_name=None,
                 middle_name=None,
                 last_name=None,
                 suffix=None,
                 contact_number=None,
                 email_address=None,
                 profile_id=-1,
                 affiliate_level_id=-1,
                 date_registered=None,
                 username=None,
                 is_activated=False,
                 is_temporary_password=False,
                 is_active = False,
                 *args, **kwargs

                 ):
        self.employee_no = employee_no
        self.first_name = first_name
        self.middle_name = middle_name
        self.last_name = last_name
        self.suffix = suffix
        self.contact_number = contact_number
        self.email_address = email_address
        self.profile_id = profile_id
        self.affiliate_level_id = affiliate_level_id
        self.date_registered = date_registered
        self.username = username
        self.is_activated = is_activated
        self.is_temporary_password = is_temporary_password
        self.date_login = datetime.now()
        self.is_active = is_active

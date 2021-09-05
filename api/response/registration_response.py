from datetime import datetime


class RegistrationResponse:
    def __init__(self):
        self.registration_date = datetime.now()
        self.username = None

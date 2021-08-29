from datetime import datetime


class DateFormat:
    def __init__(self, val=None, error=None, *args, **kwargs):
        self.val = val
        self.error = error

    def is_valid(self, value):
        if value is not None:
            try:
                dformat = datetime.strptime(value, self.val)

                return None
            except ValueError:

                return self.error
        elif self.val is not None:
            return self.error
        else:
            return None

import re


class NoSpaces:
    def __init__(self, error=None, *args, **kwargs):
        self.error = error

    def is_valid(self, value):
        pattern = "[ ]"
        if value is not None:
            x = re.findall(pattern, value)
            if len(x) > 0:
                return self.error
            else:
                return None
        else:
            return None

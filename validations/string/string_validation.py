from validations.string.minlength_validation import MinLength
from validations.string.maxlength_validation import MaxLength
import re


class StringValidation:
    def __init__(self, min={}, max={}, no_regex=False, regex={}, *args, **kwargs):
        self.min = min
        self.max = max
        self.no_regex = no_regex
        self.regex = regex

    def is_valid(self, value):
        min = MinLength(**self.min)
        min_validate = min.is_valid(value)
        if min_validate is not None:
            return min_validate
        max = MaxLength(**self.max)
        max_validate = max.is_valid(value)
        if max_validate is not None:
            return max_validate
        if self.no_regex == False and min.val > 0:
            pattern = self.regex['val']
            error = self.regex['error']
            x = re.findall(pattern, value)
            if len(x) == 0:
                return error
            else:
                return None
        else:
            return None

from validations.numerical.max_value import MaximumValue
from validations.numerical.min_value import MinimumValue


class NumericalValidation:
    def __init__(self, min={}, max={}, *args, **kwargs):
        self.min = min
        self.max = max

    def is_valid(self, value):
        min = MinimumValue(**self.min)
        min_validate = min.is_valid(value)
        if min_validate is not None:
            return min_validate
        max = MaximumValue(**self.max)
        max_validate = max.is_valid(value)
        if max_validate is not None:
            return max_validate

        return None

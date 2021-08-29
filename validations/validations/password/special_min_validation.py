from validations.password.minlength_validation import MinLength
import re


class SpecialCharacterMinimum(MinLength):
    def is_valid(self, value):
        pattern = "[-.!@#%^&*_+=?/|]"
        if value is not None:
            x = re.findall(pattern, value)

            if len(x) < self.val:
                return self.error
            else:
                return None
        elif self.val > 0:
            return self.error
        else:
            return None

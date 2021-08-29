import json
from validations.string.string_validation import StringValidation
from validations.password.password_validation import PasswordValidation
from validations.numerical.numerical_validation import NumericalValidation
from validations.age.age_validation import AgeValidation
from validations.email.email_validation import EmailValidation


class BaseValidation:
    def __init__(self):
        f = open("configs/validation_config.json")
        data = f.read()
        f.close()

        self.json = json.loads(data)

    def get_validator(self, key):
        if self.json is not None:
            try:

                return self.json[key]
            except:
                pass
        return None

    def validate(self, input_name, value):
        try:
            conf = self.json[input_name]
            if value is not None:
                if conf['type'] == "string":
                    str_validation = StringValidation(**conf['config'])
                    valid = str_validation.is_valid(value)
                    if valid is not None:
                        return valid
                elif conf['type'] == "password":
                    pass_validation = PasswordValidation(**conf['config'])
                    valid = pass_validation.is_valid(value)
                    if valid is not None:
                        return valid
                elif conf['type'] == 'number':
                    number_validation = NumericalValidation(**conf['config'])
                    valid = number_validation.is_valid(value)
                    if valid is not None:
                        return valid
                elif conf['type'] == 'age':

                    age_validation = AgeValidation(**conf['config'])
                    valid = age_validation.is_valid(value)
                    if valid is not None:
                        return valid
                elif conf['type'] == 'email':
                    email_validation = EmailValidation(**conf['config'])
                    valid = email_validation.is_valid(value)
                    if valid is not None:
                        return valid
                else:
                    return None
            else:
                return None
        except:
            return None

from api.response.base_response import BaseResponse
from validations.base_validation import BaseValidation
import json


class Validator:
    @staticmethod
    def get_validator(obj, info, input):
        print('here',flush=True)
        validation = BaseValidation()
        ret_data = {}
        has_data = False
        if input is not None:
            for x in input['validate']:
                val = validation.get_validator(x)

                if val is not None:
                    has_data = True
                    ret_data[x] = val

        if has_data:
            return BaseResponse(type='success',
                                message='got validator',
                                data=json.dumps(ret_data))

        else:
            return BaseResponse(type='failed',
                                message='no validator',
                                data=None)

from validations.file.min_size_validation import MinSizeValidation
from validations.file.max_size_validation import MaxSizeValidation
from validations.file.mime_validation import MimeValidation


class FileValidation:
    def __init__(self,
                 min={},
                 max={},
                 mimes={},
                 *args,
                 **kwargs):
        self.min = min
        self.max = max
        self.mimes = mimes



    def is_valid(self, value: dict = {}):
        if ('file_type' not in value.keys()
                or 'file_content' not in value.keys()
        ):
            return "This is not a file"

        min_size = MinSizeValidation(self.min)
        max_size = MaxSizeValidation(self.max)
        mimes = MimeValidation(
            error=self.mimes['error'],
            extension=self.mimes['extension']
        )

        min_size_validate = min_size.is_valid(len(value['file_content']))
        if min_size_validate is not None:
            return min_size_validate
        max_size_validate = max_size.is_valid(len(value['file_content']))
        if max_size_validate is not None:
            return max_size_validate
        print('napasok')
        mime_validate = mimes.is_valid(value['file_type'])
        if mime_validate is not None:
            return mime_validate

    @staticmethod
    def get_content_type(value:dict={}):
        mime_validate=MimeValidation()
        return mime_validate.get_content_type(value['file_type'])



class MimeValidation:
    def __init__(self,
                 error=None,
                 extension=None,
                 *args,
                 **kwargs):

        self.extn=extension

        self.error=error

    def is_valid(self, value):

        try:

            keys=self.extn.keys()

            if value not in keys:
                return self.error
        except:
            return self.error


import base64
class ProductModel:
    def __init__(self,
                 service_id=-1,
                 product_code=None,
                 product_name=None,
                 class_id=-1,
                 class_code=None,
                 class_name=None,
                 product_description=None,
                 image_id=-1,
                 file_type=None,
                 file_name=None,
                 file_size=0,
                 file_content_type=None,
                 file_content=None,
                 *args,
                 **kwargs
                 ):

        self.service_id = service_id
        self.product_code = product_code
        self.product_name = product_name
        self.class_id = class_id
        self.class_code = class_code
        self.class_name = class_name
        self.product_description = product_description
        self.image_id = image_id
        self.file_type = file_type
        self.file_name = file_name
        self.file_size = file_size
        self.file_content_type = file_content_type
        self.file_content = base64.b64encode( file_content).decode('utf-8')

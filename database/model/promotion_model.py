import base64


class PromotionModel:
    def __init__(self,
                 promotion_id=0,
                 image_id=None,
                 description=None,
                 status=None,
                 file_id=0,
                 promotion_name = None,
                 file_type = None,
                 file_name = None,
                 file_size = None,
                 file_content_type = None,
                 file_content = None,
                 *args,
                 **kwargs):
        self.promotion_id = promotion_id
        self.image_id = image_id
        self.description = description
        self.status = status
        self.file_id = file_id
        self.promotion_name = promotion_name
        self.file_type = file_type
        self.file_name = file_name
        self.file_size = file_size
        self.file_content_type = file_content_type
        self.file_content = base64.b64encode(file_content).decode('utf-8')
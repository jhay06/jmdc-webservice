class Pagination:
    def __init__(self,
                 page=0,
                 limit_page=0,
                 has_pagination=False,
                 *args,
                 **kwargs):
        self.page=page
        self.limit_page=limit_page
        self.has_pagination=has_pagination

class PaginationResponse:
    def __init__(self,
                 current_page=0,
                 total_count=0,
                 *args,
                 **kwargs):
        self.current_page=current_page
        self.total_count=total_count
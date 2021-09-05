class BranchModel:
    def __init__(self,
                 branch_id=0,
                 branch_code=None,
                 branch_name=None,
                 branch_address=None,
                 open_time=0,
                 close_time=0,
                 date_created=None
                 ):
        self.branch_id = branch_id
        self.branch_code = branch_code
        self.branch_name = branch_name
        self.branch_address = branch_address
        self.date_created = date_created
        self.open_time = str(open_time)
        self.close_time = str(close_time)
        if len(self.open_time) == 3:
            self.open_time = '0' + self.open_time

        if len(self.close_time) == 3:
            self.close_time = '0' + self.close_time

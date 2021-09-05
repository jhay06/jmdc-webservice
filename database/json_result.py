from mysql.connector.cursor import MySQLCursorBufferedDict


class JsonResult:
    def __init__(self, result: MySQLCursorBufferedDict = None):
        self.__json = None
        self.rows = 0
        self.__res = []
        self.__columns = None
        self.__column_count = 0
        if result is not None:
            self.__columns = result.column_names
            self.__column_count = len(self.__columns)

            self.__res = result.fetchall()
            self.rows = len(self.__res)

    def to_json(self, index: int = 0):
        if self.__res is not None:
            i = 0
            json = {}
            try:
                data = self.__res[index]
                while i < self.__column_count:
                    json[self.__columns[i]] = data[i]
                    i += 1
                self.__json = json
            except:
                pass

        return self.__json

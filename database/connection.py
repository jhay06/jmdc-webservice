import json

import mysql.connector


class DatabaseConfig:
    def __init__(self,
                 db_host=None,
                 db_port=3306,
                 user=None,
                 password=None,
                 db_name=None
                 ):
        self.db_host = db_host
        self.db_port = db_port
        self.user = user
        self.password = password
        self.db_name = db_name


class Database:
    def __init__(self, db_config_file=None):
        self.__db = None
        if db_config_file is not None:
            try:
                f = open('configs/' + db_config_file)
                data = f.read()
                f.close()
                self.__db = DatabaseConfig(**json.loads(data))
            except:
                pass

    def get_config(self) -> DatabaseConfig:
        return self.__db


class DatabaseConnection:
    def __init__(self, db: Database = None):
        try:
            if db is not None:
                conf = db.get_config()
                self.db = mysql.connector.connect(
                    host=conf.db_host,
                    user=conf.user,
                    password=conf.password,
                    port=conf.db_port,
                    database=conf.db_name
                )
        except:
            raise ConnectionRefusedError('Could not reach database server')

    def get_connection(self):
        return self.db

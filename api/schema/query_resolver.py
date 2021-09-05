from ariadne import ObjectType
from api.query.validators import Validator
from api.query.users import Users
from api.query.branch import Branch
from api.query.appointment import Appointment

class QueryResolver:
    def __init__(self):
        self.__query = ObjectType("Query")

    def resolve_all(self):
        self.resolve_get_validator()
        Users.resolve_all(self.__query)
        Branch.resolve_all(self.__query)
        Appointment.resolve_all(self.__query)

    def resolve_get_validator(self):
        self.__query.set_field('get_validator', Validator.get_validator)


    def get_definition(self) -> ObjectType:
        return self.__query

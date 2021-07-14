from ariadne import ObjectType
from api.mutation.login import Login
from api.mutation.register import Register

class MutationResolver:
	def __init__(self):
		self.__query=ObjectType("Mutation")
	def login(self): 
		self.__query.set_field("login",Login.process_login)
	def register(self): 
		self.__query.set_field('register',Register.process_registration)
	def resolve_all(self):
		self.login()
		self.register()
	def get_definition(self)->ObjectType:
		return self.__query

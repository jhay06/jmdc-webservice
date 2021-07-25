from ariadne import ObjectType
from api.mutation.login import Login
from api.mutation.register import Register
from api.mutation.account import Account


class MutationResolver:
	def __init__(self):
		self.__query = ObjectType("Mutation")

	def login(self):
		self.__query.set_field("login", Login.process_login)

	def register(self):
		self.__query.set_field('register', Register.process_registration)

	def update_info(self):
		self.__query.set_field('update_account', Account.update_account)

	def change_password(self):
		self.__query.set_field('change_password', Account.change_password)

	def resolve_all(self):
		self.login()
		self.register()
		self.update_info()
		self.change_password()
		
	def get_definition(self) -> ObjectType:
		return self.__query

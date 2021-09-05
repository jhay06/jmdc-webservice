from ariadne import (
    make_executable_schema,
    snake_case_fallback_resolvers,
    load_schema_from_path
)
from api.schema.query_resolver import QueryResolver
from api.schema.mutation_resolver import MutationResolver


class SchemaLoader:
    def __init__(self, typedefs: load_schema_from_path):
        query = QueryResolver()
        query.resolve_all()
        mutation = MutationResolver()
        mutation.resolve_all()
        self.__schema = make_executable_schema(
            typedefs,
            query.get_definition(),
            mutation.get_definition(),
            snake_case_fallback_resolvers
        )

    def get_schema(self):
        return self.__schema

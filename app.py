import sys

sys.path.append("source")
from flask import (
    Flask,
    request,
    jsonify
)
from ariadne.constants import PLAYGROUND_HTML
from ariadne import (
    load_schema_from_path,
    graphql_sync

)
from api.schema.schema_loader import SchemaLoader

type_defs = load_schema_from_path('schema.graphql')
schema = SchemaLoader(type_defs)
app = Flask(__name__)


@app.route("/", methods=['GET'])
def home():
    return "hello world"


@app.route('/graphql', methods=['GET'])
def graphql_ui():
    return PLAYGROUND_HTML, 200


@app.route('/graphql', methods=['POST'])
def graphql_server():
    # print(request,flush=True)
    data = request.get_json()
    success, result = graphql_sync(
        schema.get_schema(),
        data,
        context_value=request,
        debug=app.debug
    )
    status_code = 200 if success else 400
    return result, status_code


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=2021, debug=True)

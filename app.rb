require 'cuba'
require 'json'
require 'graphql'

GraphiQL = <<-EOF
<!DOCTYPE html>
<head>
<meta charset="utf-8" />
<title>tinrb graphiql</title>
<script src="//cdnjs.cloudflare.com/ajax/libs/es6-promise/4.1.0/es6-promise.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/fetch/2.0.3/fetch.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/react/15.4.2/react.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/react/15.4.2/react-dom.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/graphiql/0.9.3/graphiql.min.js"></script>
<link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/graphiql/0.9.3/graphiql.min.css" />
<style>html,body{height:100%;margin:0;overflow:hidden;width:100%;}</style>
</head>
<body>
Loading...
<script>
function graphQLFetcher(graphQLParams) {
  return fetch('/graphql', {
    method: 'post',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(graphQLParams),
    credentials: 'include',
  }).then(function (response) {
    return response.text();
  }).then(function (responseBody) {
    try {
      return JSON.parse(responseBody);
    } catch (error) {
      return responseBody;
    }
  });
}
ReactDOM.render(React.createElement(GraphiQL, { fetcher: graphQLFetcher }), document.body);
</script>
</body>
</html>
EOF

HelloType = GraphQL::ObjectType.define do
  name 'Hello'
  field :world, !types.String do
    resolve ->(o,a,c){'Hello, world!'}
  end
  field :any, !types.String do
    argument :name, types.String
    resolve ->(o,a,c) do
        "Hello, #{a[:name] or "world"}!"
    end
  end
end

RootQueryType = GraphQL::ObjectType.define do
  name 'RootQuery'
  field :hello, !HelloType do
    resolve ->(o,a,c){true}
  end
end
 
Schema = GraphQL::Schema.define do
  query RootQueryType
end

App = Cuba.new do
  on get, root do
    res.headers['Content-Type'] = 'text/html'
    res.write GraphiQL
  end
  on post, 'graphql' do
    params = JSON.parse(req.body.read)
    qstring = params['query']
    payload = Schema.execute(qstring,
      variables: params['variables'],
      operation_name: params['operationName'],
      context: {optics_agent: env[:optics_agent].with_document(qstring)}
    )

    res.headers['Content-Type'] = 'application/json; charset=utf-8'
    res.write JSON.dump payload
  end
end
